import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/chunking/plan_diff.dart';
import '../../core/chunking/selection_ordering.dart';
import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';
import '../../core/db/database.dart';

/// Re-plans the Quran portion of an existing plan — new selection type/ids
/// and/or direction, plus the daily time budget — diffing the freshly
/// generated item list against what's on disk by contentKey
/// ([diffPlan]) so items that survive the edit keep their SM-2 progress.
///
/// `ref` is `dynamic` because this is called from a `WidgetRef` (the
/// settings screen); see `test_helpers/first_value.dart` for the same
/// pragmatic choice elsewhere in this codebase.
Future<void> applyQuranPlanEdit(
  dynamic ref, {
  required String selectionType,
  required List<int> selectionIds,
  required String direction,
  required int dailyMinutes,
}) async {
  final AppDatabase db = ref.read(appDatabaseProvider);
  final QuranRepository quranRepo = ref.read(quranRepositoryProvider);
  final QuranMeta meta = await quranRepo.loadMeta();

  final slices = orderSelection(
    meta: meta,
    selectionType: selectionType,
    selectionIds: selectionIds,
    direction: direction,
  );
  final touchedSurahs = slices.map((s) => s.surah).toSet();
  final ayahsBySurah = {
    for (final surahNumber in touchedSurahs)
      surahNumber: (await quranRepo.loadSurah(surahNumber)).ayahs,
  };
  final groups = planQuranItems(
    meta: meta,
    ayahsBySurah: ayahsBySurah,
    selectionType: selectionType,
    selectionIds: selectionIds,
    direction: direction,
  );
  final newItems = [
    for (var i = 0; i < groups.length; i++)
      PlanItem(
        contentKey: groups[i].contentKey,
        orderIndex: i,
        wordCount: groups[i].wordCount,
      ),
  ];

  final existingQuranItems = await (db.select(db.srsItems)
        ..where((t) => t.contentType.equals('quran')))
      .get();
  final diff = diffPlan(
    existingContentKeys: existingQuranItems.map((i) => i.contentKey),
    newItems: newItems,
  );

  await db.transaction(() async {
    if (diff.toRemoveContentKeys.isNotEmpty) {
      final removedIds = existingQuranItems
          .where((i) => diff.toRemoveContentKeys.contains(i.contentKey))
          .map((i) => i.id)
          .toList();
      await (db.delete(db.reviewLogs)..where((t) => t.itemId.isIn(removedIds)))
          .go();
      await (db.delete(db.srsItems)
            ..where((t) => t.contentKey.isIn(diff.toRemoveContentKeys)))
          .go();
    }

    for (final item in diff.toReorder) {
      await (db.update(db.srsItems)
            ..where((t) => t.contentKey.equals(item.contentKey)))
          .write(SrsItemsCompanion(
            orderIndex: Value(item.orderIndex),
            wordCount: Value(item.wordCount),
          ));
    }

    if (diff.toAdd.isNotEmpty) {
      await db.batch((batch) => batch.insertAll(db.srsItems, [
            for (final item in diff.toAdd)
              SrsItemsCompanion.insert(
                contentType: 'quran',
                contentKey: item.contentKey,
                orderIndex: item.orderIndex,
                wordCount: item.wordCount,
              ),
          ]));
    }

    // Quran's item count may have grown/shrunk — shift hadith/dua orderIndex
    // by the same delta so they stay contiguously after every quran item
    // (matches onboarding's original ordering: quran, then hadith, then
    // dua), rather than interleaving with whatever range quran now occupies.
    final delta = newItems.length - existingQuranItems.length;
    if (delta != 0) {
      final rest = await (db.select(db.srsItems)
            ..where((t) => t.contentType.isIn(const ['hadith', 'dua'])))
          .get();
      for (final item in rest) {
        await (db.update(db.srsItems)..where((t) => t.id.equals(item.id)))
            .write(SrsItemsCompanion(orderIndex: Value(item.orderIndex + delta)));
      }
    }

    await (db.update(db.userPlans)..where((t) => t.id.equals(1))).write(
      UserPlansCompanion(
        quranSelectionType: Value(selectionType),
        quranSelectionJson: Value(jsonEncode(selectionIds)),
        direction: Value(direction),
        dailyMinutes: Value(dailyMinutes),
      ),
    );
  });
}
