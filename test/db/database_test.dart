import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('inserts and reads back a user plan', () async {
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            dailyMinutes: 10,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    final plan = await db.select(db.userPlans).getSingle();
    expect(plan.scope, 'quran');
    expect(plan.dailyMinutes, 10);
    expect(plan.direction, 'normal');
    expect(plan.reciter, 'Husary_128kbps');
    expect(plan.weeklyGoal, 7);
  });

  test('inserts an srs item and enforces unique contentKey', () async {
    await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:1:1-3',
            orderIndex: 0,
            wordCount: 12,
          ),
        );

    final items = await db.select(db.srsItems).get();
    expect(items.single.status, 'new');
    expect(items.single.easeFactor, 2.5);

    expect(
      () => db.into(db.srsItems).insert(
            SrsItemsCompanion.insert(
              contentType: 'quran',
              contentKey: 'q:1:1-3',
              orderIndex: 1,
              wordCount: 5,
            ),
          ),
      throwsA(anything),
    );
  });

  test('content pack enforces unique (type, edition) and tracks progress', () async {
    await db.into(db.contentPacks).insert(
          ContentPacksCompanion.insert(
            type: 'translation',
            languageOrCollection: 'fr',
            editionOrCollection: 'fra_muhammadhamidul',
          ),
        );

    final pack = await db.select(db.contentPacks).getSingle();
    expect(pack.status, 'notDownloaded');
    expect(pack.progress, 0.0);

    expect(
      () => db.into(db.contentPacks).insert(
            ContentPacksCompanion.insert(
              type: 'translation',
              languageOrCollection: 'fr',
              editionOrCollection: 'fra_muhammadhamidul',
            ),
          ),
      throwsA(anything),
    );
  });

  test('bookmark enforces unique contentKey', () async {
    await db.into(db.bookmarks).insert(
          BookmarksCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:2:255',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

    final bookmarks = await db.select(db.bookmarks).get();
    expect(bookmarks.single.contentType, 'quran');

    expect(
      () => db.into(db.bookmarks).insert(
            BookmarksCompanion.insert(
              contentType: 'quran',
              contentKey: 'q:2:255',
              createdAt: DateTime(2026, 1, 2),
            ),
          ),
      throwsA(anything),
    );
  });

  test('daily session tracks planned vs done counts', () async {
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: '2026-01-01',
            newItemsPlanned: 3,
            reviewsPlanned: 5,
          ),
        );

    final session = await db.select(db.dailySessions).getSingle();
    expect(session.newItemsDone, 0);
    expect(session.completed, isFalse);
  });
}
