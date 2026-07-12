import '../content/models/quran_models.dart';
import 'ayah_grouper.dart';

/// A contiguous run of ayahs within one surah, as determined by the
/// user's surah/juz selection — before word-count grouping is applied.
class SurahSlice {
  const SurahSlice({
    required this.surah,
    required this.startAyah,
    required this.endAyah,
  });

  final int surah;
  final int startAyah;
  final int endAyah;
}

/// Breaks a single juz's (possibly multi-surah) span into one slice per
/// surah it touches, in ascending mushaf order.
List<SurahSlice> _slicesForJuz(QuranMeta meta, JuzSpan juz) {
  final start = juz.start;
  final end = juz.end;

  if (start.surah == end.surah) {
    return [SurahSlice(surah: start.surah, startAyah: start.ayah, endAyah: end.ayah)];
  }

  final slices = <SurahSlice>[];
  final startSurahMeta = meta.surahs.firstWhere((s) => s.number == start.surah);
  slices.add(SurahSlice(
    surah: start.surah,
    startAyah: start.ayah,
    endAyah: startSurahMeta.ayahCount,
  ));

  for (var s = start.surah + 1; s < end.surah; s++) {
    final surahMeta = meta.surahs.firstWhere((x) => x.number == s);
    slices.add(SurahSlice(surah: s, startAyah: 1, endAyah: surahMeta.ayahCount));
  }

  slices.add(SurahSlice(surah: end.surah, startAyah: 1, endAyah: end.ayah));
  return slices;
}

/// Merges consecutive same-surah slices whose ayah ranges are adjacent
/// (in either direction), so a juz boundary in the middle of a surah
/// doesn't produce an artificially small leftover group when the
/// following slice picks up exactly where it left off.
List<SurahSlice> _mergeAdjacentSlices(List<SurahSlice> slices) {
  if (slices.isEmpty) return slices;

  final merged = <SurahSlice>[slices.first];
  for (final next in slices.skip(1)) {
    final last = merged.last;
    final contiguous = last.surah == next.surah &&
        (next.startAyah == last.endAyah + 1 || next.endAyah + 1 == last.startAyah);

    if (contiguous) {
      merged[merged.length - 1] = SurahSlice(
        surah: last.surah,
        startAyah: last.startAyah < next.startAyah ? last.startAyah : next.startAyah,
        endAyah: last.endAyah > next.endAyah ? last.endAyah : next.endAyah,
      );
    } else {
      merged.add(next);
    }
  }
  return merged;
}

/// Orders a Quran selection into surah slices ready for ayah-grouping.
///
/// - `selectionType: 'surahs'` always visits the selected surahs in
///   ascending mushaf order (direction only applies to juz/whole-Quran
///   selections in the onboarding flow — an arbitrary surah pick has no
///   traditional "reversed" reading order).
/// - `selectionType: 'juz'` or `'whole'`: `direction: 'normal'` visits
///   selected juz ascending; `'reversed'` visits them descending (juz
///   30 → 1 for a whole-Quran selection) with surahs *within* each juz
///   also in reverse mushaf order, while ayahs inside each surah slice
///   stay in normal ascending order — the traditional "from the back"
///   memorization order.
List<SurahSlice> orderSelection({
  required QuranMeta meta,
  required String selectionType,
  required List<int> selectionIds,
  required String direction,
}) {
  final reversed = direction == 'reversed';

  if (selectionType == 'surahs') {
    final sorted = [...selectionIds]..sort();
    return sorted.map((surahNumber) {
      final surahMeta = meta.surahs.firstWhere((s) => s.number == surahNumber);
      return SurahSlice(surah: surahNumber, startAyah: 1, endAyah: surahMeta.ayahCount);
    }).toList();
  }

  final juzNumbers = selectionType == 'whole'
      ? List.generate(30, (i) => i + 1)
      : ([...selectionIds]..sort());
  final orderedJuzNumbers = reversed ? juzNumbers.reversed.toList() : juzNumbers;

  final slices = <SurahSlice>[];
  for (final juzNumber in orderedJuzNumbers) {
    final juz = meta.juzMap.firstWhere((j) => j.juz == juzNumber);
    final juzSlices = _slicesForJuz(meta, juz);
    slices.addAll(reversed ? juzSlices.reversed : juzSlices);
  }

  return _mergeAdjacentSlices(slices);
}

/// Builds the final, ordered list of [AyahGroup]s for a Quran selection.
/// [ayahsBySurah] must contain every surah touched by the selection
/// (loaded ahead of time by the caller — this stays pure/synchronous).
/// The returned list's position is the item's `orderIndex`.
List<AyahGroup> planQuranItems({
  required QuranMeta meta,
  required Map<int, List<Ayah>> ayahsBySurah,
  required String selectionType,
  required List<int> selectionIds,
  required String direction,
}) {
  final slices = orderSelection(
    meta: meta,
    selectionType: selectionType,
    selectionIds: selectionIds,
    direction: direction,
  );

  final groups = <AyahGroup>[];
  for (final slice in slices) {
    final ayahs = ayahsBySurah[slice.surah]!
        .where((a) => a.ayah >= slice.startAyah && a.ayah <= slice.endAyah)
        .toList()
      ..sort((a, b) => a.ayah.compareTo(b.ayah));
    groups.addAll(groupAyahs(slice.surah, ayahs));
  }
  return groups;
}
