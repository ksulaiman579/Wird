import 'package:drift/drift.dart' show InsertMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';
import '../../core/db/database.dart';
import '../../core/gamification/achievements.dart';
import '../adhkar/adhkar_reader_screen.dart' show completedPrefsKey;

final achievementsStreamProvider =
    StreamProvider<List<Achievement>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.achievements).watch();
});

bool _isMemorized(String status) => status == 'review' || status == 'lapsed';

bool _juzFullyMemorized(
  JuzSpan span,
  Map<int, Set<int>> memorizedAyahsBySurah,
  QuranMeta meta,
) {
  for (var surahNum = span.start.surah; surahNum <= span.end.surah; surahNum++) {
    final surahMeta = meta.surahs.firstWhere((s) => s.number == surahNum);
    final startAyah = surahNum == span.start.surah ? span.start.ayah : 1;
    final endAyah =
        surahNum == span.end.surah ? span.end.ayah : surahMeta.ayahCount;
    final memorized = memorizedAyahsBySurah[surahNum] ?? const <int>{};
    for (var ayah = startAyah; ayah <= endAyah; ayah++) {
      if (!memorized.contains(ayah)) return false;
    }
  }
  return true;
}

/// Consecutive days (ending today if today's already done, else
/// yesterday) the user completed [period]'s adhkar — mirrors
/// `adhkar_reader_screen.dart`'s own shared_preferences key format so the
/// two never drift out of sync.
Future<int> _consecutiveAdhkarDays(String period) async {
  final prefs = await SharedPreferences.getInstance();
  var day = DateTime.now();
  if (!(prefs.getBool(completedPrefsKey(period, day)) ?? false)) {
    day = day.subtract(const Duration(days: 1));
  }
  var count = 0;
  while (prefs.getBool(completedPrefsKey(period, day)) ?? false) {
    count++;
    day = day.subtract(const Duration(days: 1));
  }
  return count;
}

/// Assembles an [AchievementStats] snapshot from `srs_items` +
/// `streak_state` + bundled Quran meta + adhkar completion prefs,
/// evaluates every rule, persists any newly-satisfied ids to the
/// `achievements` table, and returns just the newly-unlocked rules (for a
/// celebration). Call this after a session or adhkar completion.
///
/// [ref] is `dynamic` for the same reason as `notification_providers.dart`'s
/// `rescheduleNotifications` — callers pass either a `Ref` or `WidgetRef`.
/// Point-in-time [AchievementStats] snapshot from `srs_items` +
/// `streak_state` + bundled Quran meta + adhkar prefs, shared by the
/// unlock evaluator and the achievements screen's progress hints (Item
/// 1.23) so the two never compute progress differently.
Future<AchievementStats> computeAchievementStats(
  dynamic ref, {
  bool earlyBirdSession = false,
  bool nightOwlSession = false,
}) async {
  final db = ref.read(appDatabaseProvider);
  final items = await db.select(db.srsItems).get();
  final streakRow = await db.select(db.streakState).getSingleOrNull();
  final meta = await ref.read(quranRepositoryProvider).loadMeta();

  final memorizedAyahsBySurah = <int, Set<int>>{};
  var totalAyahGroupsMemorized = 0;
  for (final item in items.where((i) => i.contentType == 'quran')) {
    final parsed = parseQuranContentKey(item.contentKey);
    if (parsed == null || !_isMemorized(item.status)) continue;
    totalAyahGroupsMemorized++;
    memorizedAyahsBySurah.putIfAbsent(parsed.surah, () => {}).addAll(parsed.ayahs);
  }

  var completedSurahCount = 0;
  for (final entry in memorizedAyahsBySurah.entries) {
    final surahMeta = meta.surahs.firstWhere((s) => s.number == entry.key);
    if (entry.value.length >= surahMeta.ayahCount) completedSurahCount++;
  }

  final completedJuz = <int>{
    for (final span in meta.juzMap)
      if (_juzFullyMemorized(span, memorizedAyahsBySurah, meta)) span.juz,
  };

  final hadithMemorizedCount = items
      .where((i) => i.contentType == 'hadith' && _isMemorized(i.status))
      .length;
  final duaMemorizedCount = items
      .where((i) => i.contentType == 'dua' && _isMemorized(i.status))
      .length;
  final planFullyCompleted =
      items.isNotEmpty && items.every((i) => _isMemorized(i.status));

  return AchievementStats(
    totalAyahGroupsMemorized: totalAyahGroupsMemorized,
    completedSurahCount: completedSurahCount,
    completedJuz: completedJuz,
    hadithMemorizedCount: hadithMemorizedCount,
    duaMemorizedCount: duaMemorizedCount,
    currentStreak: streakRow?.currentStreak ?? 0,
    morningAdhkarStreakDays: await _consecutiveAdhkarDays('morning'),
    planFullyCompleted: planFullyCompleted,
    earlyBirdSession: earlyBirdSession,
    nightOwlSession: nightOwlSession,
  );
}

/// A watchable snapshot for the achievements screen's progress hints.
final achievementStatsProvider = FutureProvider<AchievementStats>((ref) {
  // Re-evaluate whenever unlocks change (e.g. right after a session).
  ref.watch(achievementsStreamProvider);
  return computeAchievementStats(ref);
});

Future<List<AchievementRule>> evaluateAndUnlockAchievements(
  dynamic ref, {
  bool earlyBirdSession = false,
  bool nightOwlSession = false,
}) async {
  final db = ref.read(appDatabaseProvider);
  final alreadyIds = (await db.select(db.achievements).get())
      .map((a) => a.achievementId)
      .toSet();

  final stats = await computeAchievementStats(
    ref,
    earlyBirdSession: earlyBirdSession,
    nightOwlSession: nightOwlSession,
  );

  final newlyUnlockedIds =
      unlockedAchievementIds(stats).difference(alreadyIds);
  if (newlyUnlockedIds.isEmpty) return const [];

  final now = DateTime.now();
  await db.batch((batch) {
    batch.insertAll(
      db.achievements,
      [
        for (final id in newlyUnlockedIds)
          AchievementsCompanion.insert(achievementId: id, unlockedAt: now),
      ],
      mode: InsertMode.insertOrIgnore,
    );
  });

  final rulesById = {for (final r in buildAchievementRules()) r.id: r};
  return [for (final id in newlyUnlockedIds) rulesById[id]!];
}
