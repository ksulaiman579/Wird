import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/settings/plan_edit_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> insertPlan({
    String selectionType = 'surahs',
    List<int> selectionIds = const [1],
    String direction = 'normal',
    int dailyMinutes = 20,
  }) {
    return db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            quranSelectionType: Value(selectionType),
            quranSelectionJson: Value('[${selectionIds.join(',')}]'),
            direction: Value(direction),
            dailyMinutes: dailyMinutes,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  }

  test('growing the selection preserves existing items\' SRS state and adds '
      'the new surah fresh', () async {
    await insertPlan(selectionIds: [1]);
    // Al-Fatihah generates one group; simulate it already having progress.
    final existing = await db.select(db.srsItems).get();
    expect(existing, isEmpty);

    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      direction: 'normal',
      dailyMinutes: 20,
    );

    final afterFirstPlan = await db.select(db.srsItems).get();
    expect(afterFirstPlan, isNotEmpty);

    // Advance one item's SRS state as if it had been reviewed.
    final firstItem = afterFirstPlan.first;
    await (db.update(db.srsItems)..where((t) => t.id.equals(firstItem.id)))
        .write(const SrsItemsCompanion(
          status: Value('review'),
          easeFactor: Value(3.1),
          intervalDays: Value(14),
          repetitions: Value(4),
        ));

    // Expand the selection to include surah 2 as well.
    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1, 2],
      direction: 'normal',
      dailyMinutes: 25,
    );

    final afterEdit = await db.select(db.srsItems).get();
    final survivor = afterEdit.singleWhere((i) => i.contentKey == firstItem.contentKey);
    expect(survivor.status, 'review');
    expect(survivor.easeFactor, 3.1);
    expect(survivor.intervalDays, 14);
    expect(survivor.repetitions, 4);

    // New surah's items are present and fresh.
    expect(afterEdit.any((i) => i.contentKey.startsWith('q:2:')), true);
    expect(
      afterEdit.where((i) => i.contentKey.startsWith('q:2:')).every((i) => i.status == 'new'),
      true,
    );

    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1))).getSingle();
    expect(plan.dailyMinutes, 25);
    expect(plan.quranSelectionJson, '[1,2]');
  });

  test('shrinking the selection removes the dropped surah\'s items and logs',
      () async {
    await insertPlan(selectionIds: [1, 2]);
    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1, 2],
      direction: 'normal',
      dailyMinutes: 20,
    );

    final beforeShrink = await db.select(db.srsItems).get();
    final surah2Item = beforeShrink.firstWhere((i) => i.contentKey.startsWith('q:2:'));
    await db.into(db.reviewLogs).insert(
          ReviewLogsCompanion.insert(
            itemId: surah2Item.id,
            reviewedAt: DateTime(2026, 1, 5),
            grade: 4,
            intervalBefore: 1,
            intervalAfter: 3,
          ),
        );

    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      direction: 'normal',
      dailyMinutes: 20,
    );

    final afterShrink = await db.select(db.srsItems).get();
    expect(afterShrink.any((i) => i.contentKey.startsWith('q:2:')), false);
    expect(await db.select(db.reviewLogs).get(), isEmpty);
  });

  test('keeps hadith/dua items contiguously ordered after a resized quran '
      'selection', () async {
    await insertPlan(selectionIds: [1]);
    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      direction: 'normal',
      dailyMinutes: 20,
    );
    final quranCountBefore = (await db.select(db.srsItems).get()).length;

    await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'hadith',
            contentKey: 'h:1',
            orderIndex: quranCountBefore,
            wordCount: 20,
          ),
        );

    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1, 2],
      direction: 'normal',
      dailyMinutes: 20,
    );

    final items = await db.select(db.srsItems).get();
    final quranMaxOrder = items
        .where((i) => i.contentType == 'quran')
        .map((i) => i.orderIndex)
        .reduce((a, b) => a > b ? a : b);
    final hadithOrder = items.singleWhere((i) => i.contentType == 'hadith').orderIndex;
    expect(hadithOrder, greaterThan(quranMaxOrder));
  });
}
