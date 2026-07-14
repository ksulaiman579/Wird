import 'package:drift/drift.dart';

import '../../core/chunking/selection_ordering.dart';
import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';
import '../../core/db/database.dart';

/// The SM-2 review state used for a portion the user already knows: mirrors
/// a freshly *graduated* item (7-day interval, `review`/Manzil status) rather
/// than `new`, so it is treated as long-term revision — it resurfaces for
/// spaced retention but never as a new item to learn. Kept here (not private)
/// so the unit test can assert against the same constants.
const int kMemorizedIntervalDays = 7;
const int kMemorizedRepetitions = 2;

/// Marks a Quran selection (a surah or a juz) as already memorized: every
/// portion the planner would chunk it into is upserted as a review item.
/// Existing plan items with the same contentKey are promoted to review in
/// place (keeping their orderIndex); portions not yet in the plan are
/// appended after the current items. Returns the number of portions marked.
///
/// `ref` is `dynamic` for the same reason as [applyQuranPlanEdit] — it is
/// called from a `WidgetRef`.
Future<int> markQuranMemorized(
  dynamic ref, {
  required String selectionType, // 'surahs' | 'juz'
  required List<int> selectionIds,
  required DateTime now,
}) async {
  final AppDatabase db = ref.read(appDatabaseProvider);
  final QuranRepository quranRepo = ref.read(quranRepositoryProvider);
  final QuranMeta meta = await quranRepo.loadMeta();

  final slices = orderSelection(
    meta: meta,
    selectionType: selectionType,
    selectionIds: selectionIds,
    direction: 'forward',
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
    direction: 'forward',
  );
  if (groups.isEmpty) return 0;

  final dueDate = now.add(const Duration(days: kMemorizedIntervalDays));

  await db.transaction(() async {
    // Append after the current plan so memorized portions never jump the
    // new-item queue; the highest existing orderIndex + 1 onward.
    final existing = await db.select(db.srsItems).get();
    var nextOrder = existing.isEmpty
        ? 0
        : existing.map((e) => e.orderIndex).reduce((a, b) => a > b ? a : b) + 1;

    for (final group in groups) {
      await db.into(db.srsItems).insert(
            SrsItemsCompanion.insert(
              contentType: 'quran',
              contentKey: group.contentKey,
              orderIndex: nextOrder++,
              wordCount: group.wordCount,
              status: const Value('review'),
              intervalDays: const Value(kMemorizedIntervalDays),
              repetitions: const Value(kMemorizedRepetitions),
              dueDate: Value(dueDate),
              introducedAt: Value(now),
            ),
            onConflict: DoUpdate(
              (_) => SrsItemsCompanion(
                status: const Value('review'),
                intervalDays: const Value(kMemorizedIntervalDays),
                repetitions: const Value(kMemorizedRepetitions),
                dueDate: Value(dueDate),
                introducedAt: Value(now),
              ),
              target: [db.srsItems.contentKey],
            ),
          );
    }
  });
  return groups.length;
}
