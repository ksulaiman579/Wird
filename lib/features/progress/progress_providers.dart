import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';
import '../../core/db/database.dart';
import '../../core/gamification/progress_stats.dart';

bool _isMemorized(String status) => status == 'review' || status == 'lapsed';

/// A single surah or juz's memorization progress, for a completion bar.
class CoverageProgress {
  const CoverageProgress({
    required this.label,
    required this.memorizedAyahs,
    required this.totalAyahs,
  });

  final String label;
  final int memorizedAyahs;
  final int totalAyahs;

  double get fraction => totalAyahs == 0 ? 0 : memorizedAyahs / totalAyahs;
}

class ProgressStats {
  const ProgressStats({
    required this.activityByDay,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysConsistentTotal,
    required this.ayahsMemorized,
    required this.hadithMemorized,
    required this.duasMemorized,
    required this.surahProgress,
    required this.juzProgress,
    required this.accuracy,
    required this.estimatedCompletionDate,
  });

  /// Day key (`yyyy-MM-dd`) -> total items done that day, for the heatmap.
  final Map<String, int> activityByDay;
  final int currentStreak;
  final int longestStreak;
  final int daysConsistentTotal;
  final int ayahsMemorized;
  final int hadithMemorized;
  final int duasMemorized;
  final List<CoverageProgress> surahProgress;
  final List<CoverageProgress> juzProgress;
  final double? accuracy;
  final DateTime? estimatedCompletionDate;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _dayKeyFor(DateTime d) {
  final dt = _dateOnly(d);
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

final progressStatsProvider = FutureProvider<ProgressStats>((ref) async {
  final db = ref.watch(appDatabaseProvider);

  final sessions = await db.select(db.dailySessions).get();
  final streakRow =
      await db.select(db.streakState).getSingleOrNull();
  final reviewLogs = await db.select(db.reviewLogs).get();
  final items = await db.select(db.srsItems).get();
  final plan = await db.select(db.userPlans).getSingleOrNull();

  final activityByDay = {
    for (final s in sessions) s.day: s.newItemsDone + s.reviewsDone,
  };
  final daysConsistentTotal = sessions.where((s) => s.completed).length;

  final quranMeta = await ref.watch(quranRepositoryProvider).loadMeta();

  final memorizedAyahsBySurah = <int, Set<int>>{};
  var ayahsMemorized = 0;
  for (final item in items.where((i) => i.contentType == 'quran')) {
    final parsed = parseQuranContentKey(item.contentKey);
    if (parsed == null) continue;
    if (_isMemorized(item.status)) {
      ayahsMemorized += parsed.ayahs.length;
      memorizedAyahsBySurah.putIfAbsent(parsed.surah, () => {}).addAll(parsed.ayahs);
    }
  }
  final touchedSurahs = {
    for (final item in items.where((i) => i.contentType == 'quran'))
      parseQuranContentKey(item.contentKey)?.surah,
  }..removeWhere((s) => s == null);

  final surahProgress = [
    for (final surahNumber in touchedSurahs.cast<int>().toList()..sort())
      CoverageProgress(
        label: quranMeta.surahs
            .firstWhere((s) => s.number == surahNumber)
            .nameTransliterated,
        memorizedAyahs: memorizedAyahsBySurah[surahNumber]?.length ?? 0,
        totalAyahs:
            quranMeta.surahs.firstWhere((s) => s.number == surahNumber).ayahCount,
      ),
  ];

  final juzProgress = [
    for (final span in quranMeta.juzMap)
      if (_juzTouchesPlan(span, touchedSurahs.cast<int>().toSet()))
        CoverageProgress(
          label: 'Juz ${span.juz}',
          memorizedAyahs: _juzMemorizedCount(span, memorizedAyahsBySurah, quranMeta),
          totalAyahs: _juzTotalAyahs(span, quranMeta),
        ),
  ];

  final hadithMemorized = items
      .where((i) => i.contentType == 'hadith' && _isMemorized(i.status))
      .length;
  final duasMemorized = items
      .where((i) => i.contentType == 'dua' && _isMemorized(i.status))
      .length;

  final againCount = reviewLogs.where((l) => l.grade == 1).length;
  final accuracy = reviewAccuracy(
    totalReviews: reviewLogs.length,
    againCount: againCount,
  );

  final itemsIntroduced = items.where((i) => i.introducedAt != null).length;
  final itemsRemaining = items.length - itemsIntroduced;
  final daysSincePlanStarted = plan == null
      ? 0
      : _dateOnly(DateTime.now()).difference(_dateOnly(plan.createdAt)).inDays;
  final estimatedCompletionDate = estimateCompletionDate(
    now: DateTime.now(),
    itemsRemaining: itemsRemaining,
    itemsIntroducedSoFar: itemsIntroduced,
    daysSincePlanStarted: daysSincePlanStarted,
  );

  return ProgressStats(
    activityByDay: activityByDay,
    currentStreak: streakRow?.currentStreak ?? 0,
    longestStreak: streakRow?.longestStreak ?? 0,
    daysConsistentTotal: daysConsistentTotal,
    ayahsMemorized: ayahsMemorized,
    hadithMemorized: hadithMemorized,
    duasMemorized: duasMemorized,
    surahProgress: surahProgress,
    juzProgress: juzProgress,
    accuracy: accuracy,
    estimatedCompletionDate: estimatedCompletionDate,
  );
});

bool _juzTouchesPlan(JuzSpan span, Set<int> touchedSurahs) {
  for (var s = span.start.surah; s <= span.end.surah; s++) {
    if (touchedSurahs.contains(s)) return true;
  }
  return false;
}

int _juzTotalAyahs(JuzSpan span, QuranMeta meta) {
  var total = 0;
  for (var surahNum = span.start.surah; surahNum <= span.end.surah; surahNum++) {
    final surahMeta = meta.surahs.firstWhere((s) => s.number == surahNum);
    final startAyah = surahNum == span.start.surah ? span.start.ayah : 1;
    final endAyah =
        surahNum == span.end.surah ? span.end.ayah : surahMeta.ayahCount;
    total += endAyah - startAyah + 1;
  }
  return total;
}

int _juzMemorizedCount(
  JuzSpan span,
  Map<int, Set<int>> memorizedAyahsBySurah,
  QuranMeta meta,
) {
  var total = 0;
  for (var surahNum = span.start.surah; surahNum <= span.end.surah; surahNum++) {
    final surahMeta = meta.surahs.firstWhere((s) => s.number == surahNum);
    final startAyah = surahNum == span.start.surah ? span.start.ayah : 1;
    final endAyah =
        surahNum == span.end.surah ? span.end.ayah : surahMeta.ayahCount;
    final memorized = memorizedAyahsBySurah[surahNum] ?? const <int>{};
    for (var ayah = startAyah; ayah <= endAyah; ayah++) {
      if (memorized.contains(ayah)) total++;
    }
  }
  return total;
}

/// Exposed for the heatmap widget, which needs day keys for the visible
/// window regardless of whether any activity happened that day.
String dayKeyForDate(DateTime d) => _dayKeyFor(d);
