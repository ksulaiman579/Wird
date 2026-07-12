/// Pure per-surah download planning: which surahs a given scope needs, and
/// rough storage-size estimates. No Flutter/background_downloader imports.
library;

/// Total ayahs in the whole Quran — used to derive a rough average
/// per-ayah file size from a reciter's full-Quran total (see
/// IMPLEMENTATION_PLAN.md's download-size figures: ~550MB @ 64kbps,
/// ~1.1GB @ 128kbps for the full Quran).
const int totalQuranAyahs = 6236;

/// Rough average per-ayah file size in bytes for a reciter key (e.g.
/// `Husary_128kbps`), derived from its declared bitrate. This is an
/// estimate shown to the user before downloading, not an exact figure.
int averageBytesPerAyah(String reciterKey) {
  final is64kbps = reciterKey.contains('64kbps');
  final totalBytes = is64kbps ? 550 * 1024 * 1024 : 1100 * 1024 * 1024;
  return totalBytes ~/ totalQuranAyahs;
}

class SurahDownloadPlan {
  const SurahDownloadPlan({required this.surah, required this.ayahCount});

  final int surah;
  final int ayahCount;

  int estimatedBytes(String reciterKey) =>
      ayahCount * averageBytesPerAyah(reciterKey);
}

/// Builds the list of surahs to download for [scope]: `'plan'` downloads
/// only the surahs in [planSurahs] (the surahs actually touched by the
/// user's memorization plan); `'full'` downloads every surah in
/// [ayahCountsBySurah] (all 114).
List<SurahDownloadPlan> buildDownloadPlan({
  required String scope,
  required Map<int, int> ayahCountsBySurah,
  Set<int> planSurahs = const {},
}) {
  final surahs = scope == 'plan'
      ? planSurahs
      : ayahCountsBySurah.keys.toSet();

  final sorted = surahs.toList()..sort();
  return [
    for (final s in sorted)
      SurahDownloadPlan(surah: s, ayahCount: ayahCountsBySurah[s] ?? 0),
  ];
}

int totalEstimatedBytes(List<SurahDownloadPlan> plan, String reciterKey) =>
    plan.fold(0, (sum, p) => sum + p.estimatedBytes(reciterKey));
