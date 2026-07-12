import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/core/srs/sm2_scheduler.dart' as sm2;
import 'package:wird/features/session/session_controller.dart';
import 'package:wird/features/today/today_providers.dart' show dayKeyFor;

import '../test_helpers/first_value.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> insertPlan({int dailyMinutes = 30}) {
    return db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            dailyMinutes: dailyMinutes,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<int> insertItem({
    required String contentKey,
    required String status,
    int wordCount = 10,
    int orderIndex = 0,
    DateTime? dueDate,
    int learningStep = 0,
    int intervalDays = 0,
  }) {
    return db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: contentKey,
            orderIndex: orderIndex,
            wordCount: wordCount,
            status: Value(status),
            dueDate: Value(dueDate),
            learningStep: Value(learningStep),
            intervalDays: Value(intervalDays),
          ),
        );
  }

  test('queue orders due reviews before new items', () async {
    await insertPlan(dailyMinutes: 30);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    await insertItem(
      contentKey: 'q:1:1',
      status: 'review',
      dueDate: dateOnly,
      orderIndex: 0,
    );
    await insertItem(contentKey: 'q:1:2', status: 'new', orderIndex: 1);

    final state = await firstValue<SessionState>(
      container,
      sessionControllerProvider,
    );

    expect(state.totalCount, 2);
    expect(state.queue[0].phase, SessionItemPhase.review);
    expect(state.queue[0].srsItem.contentKey, 'q:1:1');
    expect(state.queue[1].phase, SessionItemPhase.newItem);
    expect(state.queue[1].srsItem.contentKey, 'q:1:2');
  });

  test('grading a new item moves it into learning and advances the queue',
      () async {
    await insertPlan(dailyMinutes: 30);
    await insertItem(contentKey: 'q:1:1', status: 'new', orderIndex: 0);

    await firstValue<SessionState>(container, sessionControllerProvider);
    final controller = container.read(sessionControllerProvider.notifier);
    await controller.gradeCurrent(sm2.Grade.good);

    final updated = container.read(sessionControllerProvider).value!;
    expect(updated.currentIndex, 1);
    expect(updated.newItemsDone, 1);
    expect(updated.isComplete, true);

    final row = await (db.select(db.srsItems)
          ..where((t) => t.contentKey.equals('q:1:1')))
        .getSingle();
    expect(row.status, 'learning');
    expect(row.introducedAt, isNotNull);
  });

  test(
      'resuming a learning item reads its persisted learningStep instead of '
      'restarting the ladder', () async {
    await insertPlan(dailyMinutes: 30);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    // Simulate an item that's already one step into the learning ladder
    // (steps [0, 1, 3]) from a previous day's session, now due again today.
    // Without persisting learningStep, this grading would treat it as
    // starting fresh (step 0 -> 1) instead of advancing (step 1 -> 2).
    await insertItem(
      contentKey: 'q:1:1',
      status: 'learning',
      dueDate: dateOnly,
      learningStep: 1,
      intervalDays: 1,
    );

    await firstValue<SessionState>(container, sessionControllerProvider);
    await container.read(sessionControllerProvider.notifier).gradeCurrent(
          sm2.Grade.good,
        );

    final row = await (db.select(db.srsItems)
          ..where((t) => t.contentKey.equals('q:1:1')))
        .getSingle();
    expect(row.status, 'learning');
    expect(row.learningStep, 2);
    expect(row.intervalDays, 3);
  });

  test('grading a review item writes a review_logs row and updates counts',
      () async {
    await insertPlan(dailyMinutes: 30);
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    await insertItem(
      contentKey: 'q:1:1',
      status: 'review',
      dueDate: dateOnly,
      orderIndex: 0,
    );

    final dayKey = dayKeyFor(today);
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: dayKey,
            newItemsPlanned: 0,
            reviewsPlanned: 1,
          ),
        );

    await firstValue<SessionState>(container, sessionControllerProvider);
    await container.read(sessionControllerProvider.notifier).gradeCurrent(
          sm2.Grade.easy,
        );

    final logs = await db.select(db.reviewLogs).get();
    expect(logs, hasLength(1));
    expect(logs.single.grade, sm2.Grade.easy.q);

    final session = await (db.select(db.dailySessions)
          ..where((t) => t.day.equals(dayKey)))
        .getSingle();
    expect(session.reviewsDone, 1);
    expect(session.completed, true,
        reason: 'this was the only queued item, so the portion is done');
  });

  test(
      'completing the last queued item marks daily_sessions.completed and '
      'updates streak_state, setting justCompletedStreak', () async {
    await insertPlan(dailyMinutes: 30);
    await insertItem(contentKey: 'q:1:1', status: 'new', orderIndex: 0);

    final dayKey = dayKeyFor(DateTime.now());
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: dayKey,
            newItemsPlanned: 1,
            reviewsPlanned: 0,
          ),
        );

    await firstValue<SessionState>(container, sessionControllerProvider);
    await container.read(sessionControllerProvider.notifier).gradeCurrent(
          sm2.Grade.good,
        );

    final updated = container.read(sessionControllerProvider).value!;
    expect(updated.justCompletedStreak, 1);

    final session = await (db.select(db.dailySessions)
          ..where((t) => t.day.equals(dayKey)))
        .getSingle();
    expect(session.completed, true);

    final streakRow = await db.select(db.streakState).getSingle();
    expect(streakRow.currentStreak, 1);
    expect(streakRow.longestStreak, 1);
  });
}
