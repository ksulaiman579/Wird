import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/backup/reset_service.dart';
import 'package:wird/core/db/database.dart';

void main() {
  late AppDatabase db;
  late ResetService service;

  Future<int> addItem(String contentType, String contentKey, {int orderIndex = 0}) {
    return db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: contentType,
            contentKey: contentKey,
            orderIndex: orderIndex,
            wordCount: 10,
            status: const Value('review'),
            easeFactor: const Value(3.0),
            intervalDays: const Value(14),
            repetitions: const Value(3),
            dueDate: Value(DateTime(2026, 2, 1)),
            introducedAt: Value(DateTime(2026, 1, 1)),
          ),
        );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    service = ResetService(db);

    final quranId = await addItem('quran', 'q:1:1-2');
    final hadithId = await addItem('hadith', 'h:1');
    final duaId = await addItem('dua', 'd:hm-1');

    for (final itemId in [quranId, hadithId, duaId]) {
      await db.into(db.reviewLogs).insert(
            ReviewLogsCompanion.insert(
              itemId: itemId,
              reviewedAt: DateTime(2026, 1, 20),
              grade: 4,
              intervalBefore: 7,
              intervalAfter: 14,
            ),
          );
    }

    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: '2026-01-20',
            newItemsPlanned: 1,
            reviewsPlanned: 2,
            completed: const Value(true),
          ),
        );
    await db.into(db.achievements).insert(
          AchievementsCompanion.insert(
            achievementId: 'first_ayah',
            unlockedAt: DateTime(2026, 1, 2),
          ),
        );
    await db.into(db.streakState).insert(
          StreakStateCompanion.insert(
            id: const Value(1),
            currentStreak: const Value(5),
            longestStreak: const Value(5),
            lastCompletedDay: Value(DateTime(2026, 1, 20)),
          ),
        );
    await db.into(db.duaSelections).insert(
          DuaSelectionsCompanion.insert(duaId: 'hm-1', addedAt: DateTime(2026, 1, 3)),
        );
  });

  tearDown(() => db.close());

  test('per-track reset only resets that track\'s items, leaving others and '
      'aggregates untouched', () async {
    await service.reset(ResetScope.quran);

    final items = await db.select(db.srsItems).get();
    final quran = items.singleWhere((i) => i.contentType == 'quran');
    final hadith = items.singleWhere((i) => i.contentType == 'hadith');
    final dua = items.singleWhere((i) => i.contentType == 'dua');

    expect(quran.status, 'new');
    expect(quran.easeFactor, 2.5);
    expect(quran.intervalDays, 0);
    expect(quran.repetitions, 0);
    expect(quran.dueDate, isNull);
    expect(quran.introducedAt, isNull);

    expect(hadith.status, 'review');
    expect(dua.status, 'review');

    expect(await db.select(db.reviewLogs).get(), hasLength(2));
    expect(await db.select(db.dailySessions).get(), hasLength(1));
    expect(await db.select(db.achievements).get(), hasLength(1));
    expect(await db.select(db.streakState).get(), hasLength(1));
    expect(await db.select(db.duaSelections).get(), hasLength(1));
  });

  test('dua reset also clears dua selections', () async {
    await service.reset(ResetScope.dua);

    final dua = (await db.select(db.srsItems).get())
        .singleWhere((i) => i.contentType == 'dua');
    expect(dua.status, 'new');
    expect(await db.select(db.duaSelections).get(), isEmpty);
  });

  test('full reset resets every item and clears cross-track aggregates',
      () async {
    await service.reset(ResetScope.full);

    final items = await db.select(db.srsItems).get();
    expect(items.every((i) => i.status == 'new'), true);
    expect(items.every((i) => i.dueDate == null), true);

    expect(await db.select(db.reviewLogs).get(), isEmpty);
    expect(await db.select(db.dailySessions).get(), isEmpty);
    expect(await db.select(db.achievements).get(), isEmpty);
    expect(await db.select(db.streakState).get(), isEmpty);
    expect(await db.select(db.duaSelections).get(), isEmpty);
  });
}
