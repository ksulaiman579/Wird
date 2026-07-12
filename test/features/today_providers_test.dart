import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/today/today_providers.dart';

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

  Future<void> insertItem({
    required String contentKey,
    required String status,
    int wordCount = 10,
    int orderIndex = 0,
    DateTime? dueDate,
  }) {
    return db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: contentKey,
            orderIndex: orderIndex,
            wordCount: wordCount,
            status: Value(status),
            dueDate: Value(dueDate),
          ),
        );
  }

  Future<TodayBreakdown> readBreakdown() async {
    await firstValue(container, userPlanStreamProvider);
    await firstValue(container, srsItemsStreamProvider);
    await firstValue(container, easeBackActiveProvider);
    return container.read(todayBreakdownProvider).value!;
  }

  test('no plan yet yields TodayBreakdown.empty', () async {
    await insertItem(contentKey: 'q:1:1', status: 'new');
    final breakdown = await readBreakdown();
    expect(breakdown.totalCount, 0);
  });

  test('splits due items into sabqi (learning/lapsed) and manzil (review)',
      () async {
    await insertPlan(dailyMinutes: 30);
    // The real scheduler always stores date-only due dates (see
    // sm2_scheduler.dart's _dateOnly normalization) — match that here,
    // since a same-day dueDate with a later time-of-day than midnight
    // would otherwise look "not yet due" to todayBreakdownProvider's own
    // date-only comparison.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await insertItem(
      contentKey: 'q:1:1',
      status: 'learning',
      dueDate: today,
      orderIndex: 0,
    );
    await insertItem(
      contentKey: 'q:1:2',
      status: 'lapsed',
      dueDate: today,
      orderIndex: 1,
    );
    await insertItem(
      contentKey: 'q:1:3',
      status: 'review',
      dueDate: today,
      orderIndex: 2,
    );
    await insertItem(contentKey: 'q:1:4', status: 'new', orderIndex: 3);

    final breakdown = await readBreakdown();

    expect(breakdown.sabqiCount, 2);
    expect(breakdown.manzilCount, 1);
    expect(breakdown.sabaqCount, 1);
  });

  test('ignores review items not yet due', () async {
    await insertPlan(dailyMinutes: 30);
    final farFuture = DateTime.now().add(const Duration(days: 30));

    await insertItem(
      contentKey: 'q:1:1',
      status: 'review',
      dueDate: farFuture,
      orderIndex: 0,
    );

    final breakdown = await readBreakdown();
    expect(breakdown.manzilCount, 0);
  });

  test('ensureDailySessionProvider writes a session row exactly once',
      () async {
    await insertPlan(dailyMinutes: 30);
    await insertItem(contentKey: 'q:1:1', status: 'new', wordCount: 20);

    // ensureDailySessionProvider watches todayBreakdownProvider, which in
    // turn watches these streams — make sure they've all already emitted
    // before relying on the derived breakdown having a value.
    await firstValue(container, userPlanStreamProvider);
    await firstValue(container, srsItemsStreamProvider);
    await firstValue(container, easeBackActiveProvider);
    await firstValue(container, ensureDailySessionProvider);

    final dayKey = dayKeyFor(DateTime.now());
    final session = await (db.select(db.dailySessions)
          ..where((t) => t.day.equals(dayKey)))
        .getSingle();
    expect(session.newItemsPlanned, 1);

    // Add another new item after the fact; the planned count must not
    // retroactively change for a session already recorded today.
    await insertItem(contentKey: 'q:1:2', status: 'new', orderIndex: 1);
    // Let the reactive srsItemsStreamProvider pick up the new row before
    // re-checking.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    container.invalidate(ensureDailySessionProvider);
    await firstValue(container, ensureDailySessionProvider);

    final sessionAfter = await (db.select(db.dailySessions)
          ..where((t) => t.day.equals(dayKey)))
        .getSingle();
    expect(sessionAfter.newItemsPlanned, 1);
  });

  test('weeklyGoalProvider counts only this week\'s completed sessions',
      () async {
    await insertPlan();
    final today = DateTime.now();
    final wayBack = today.subtract(const Duration(days: 30));
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: dayKeyFor(today),
            newItemsPlanned: 1,
            reviewsPlanned: 0,
            completed: const Value(true),
          ),
        );
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: dayKeyFor(wayBack),
            newItemsPlanned: 1,
            reviewsPlanned: 0,
            completed: const Value(true),
          ),
        );

    await firstValue(container, userPlanStreamProvider);
    await firstValue(container, dailySessionsStreamProvider);

    final progress = container.read(weeklyGoalProvider).value!;
    expect(progress.completed, 1);
  });

  test('easeBackActive halves the new-item budget after a 3+ day gap',
      () async {
    await insertPlan(dailyMinutes: 30);
    for (var i = 0; i < 10; i++) {
      await insertItem(contentKey: 'n$i', status: 'new', wordCount: 30, orderIndex: i);
    }
    await db.into(db.streakState).insert(
          StreakStateCompanion.insert(
            lastCompletedDay:
                Value(DateTime.now().subtract(const Duration(days: 5))),
          ),
        );

    final breakdown = await readBreakdown();
    expect(breakdown.easeBackActive, true);
    expect(breakdown.sabaqCount, lessThan(10));
  });
}
