/// Pure achievements engine: a declarative rule list evaluated against a
/// point-in-time [AchievementStats] snapshot. No Flutter/DB import — the
/// caller (features/achievements) assembles the snapshot from Drift +
/// shared_preferences, then calls [unlockedAchievementIds] and diffs the
/// result against what's already persisted in the `achievements` table to
/// find newly-unlocked ids.
library;

const int _juzCount = 30;

/// Milestone thresholds. Hadith's are given explicitly by the plan; dua
/// milestones aren't specified there, so 5/15/30 is a judgment call
/// (small/medium/large, matching the roughly-24-item starter adhkar set).
const List<int> hadithMilestones = [10, 20, 30, 40];
const List<int> duaMilestones = [5, 15, 30];
const List<int> streakMilestones = [7, 30, 100, 365];

class AchievementStats {
  const AchievementStats({
    this.totalAyahGroupsMemorized = 0,
    this.completedSurahCount = 0,
    this.completedJuz = const {},
    this.hadithMemorizedCount = 0,
    this.duaMemorizedCount = 0,
    this.currentStreak = 0,
    this.morningAdhkarStreakDays = 0,
    this.planFullyCompleted = false,
    this.earlyBirdSession = false,
    this.nightOwlSession = false,
  });

  final int totalAyahGroupsMemorized;
  final int completedSurahCount;
  final Set<int> completedJuz;
  final int hadithMemorizedCount;
  final int duaMemorizedCount;
  final int currentStreak;

  /// Consecutive days (ending today or yesterday) the user completed
  /// their morning adhkar.
  final int morningAdhkarStreakDays;

  /// Every item in the user's plan has graduated to `review` at least
  /// once, and the plan is non-empty.
  final bool planFullyCompleted;

  /// Whether the just-completed session's first grading happened before
  /// today's Fajr — evaluated fresh per session, since the achievement
  /// only needs to have happened once.
  final bool earlyBirdSession;

  /// Whether the just-completed session happened late at night. There's
  /// no Isha time available yet (`PrayerTimesService` only computes
  /// Fajr/Asr), so "late at night" is approximated as 22:00+ local time —
  /// a judgment call, documented in TASKS.md.
  final bool nightOwlSession;
}

class AchievementRule {
  const AchievementRule({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.progressOf,
  });

  final String id;
  final String title;
  final String description;
  final bool Function(AchievementStats stats) isUnlocked;

  /// Optional `(current, target)` for countable milestones, so the UI can
  /// show a "how close am I" hint on still-locked badges (Item 1.23).
  /// Null for one-shot/boolean achievements (Early Bird, a specific juz…).
  final (int current, int target) Function(AchievementStats stats)? progressOf;
}

/// Clamps [current] into `0..target` for a tidy progress hint.
(int, int) _clampProgress(int current, int target) =>
    (current < 0 ? 0 : (current > target ? target : current), target);

List<AchievementRule> buildAchievementRules() {
  return [
    AchievementRule(
      id: 'first_ayah',
      title: 'First Steps',
      description: 'Memorize your first ayah-group.',
      isUnlocked: (s) => s.totalAyahGroupsMemorized >= 1,
      progressOf: (s) => _clampProgress(s.totalAyahGroupsMemorized, 1),
    ),
    AchievementRule(
      id: 'first_surah',
      title: 'A Complete Surah',
      description: 'Fully memorize one surah.',
      isUnlocked: (s) => s.completedSurahCount >= 1,
      progressOf: (s) => _clampProgress(s.completedSurahCount, 1),
    ),
    for (var juz = 1; juz <= _juzCount; juz++)
      AchievementRule(
        id: 'juz_$juz',
        title: 'Juz $juz Complete',
        description: 'Fully memorize juz $juz.',
        isUnlocked: (s) => s.completedJuz.contains(juz),
      ),
    for (final n in hadithMilestones)
      AchievementRule(
        id: 'hadith_$n',
        title: '$n Hadith',
        description: 'Memorize $n of the 40 Hadith of an-Nawawi.',
        isUnlocked: (s) => s.hadithMemorizedCount >= n,
        progressOf: (s) => _clampProgress(s.hadithMemorizedCount, n),
      ),
    for (final n in duaMilestones)
      AchievementRule(
        id: 'dua_$n',
        title: '$n Duas',
        description: 'Memorize $n duas.',
        isUnlocked: (s) => s.duaMemorizedCount >= n,
        progressOf: (s) => _clampProgress(s.duaMemorizedCount, n),
      ),
    for (final n in streakMilestones)
      AchievementRule(
        id: 'streak_$n',
        title: '$n-Day Streak',
        description: 'Keep a $n-day streak.',
        isUnlocked: (s) => s.currentStreak >= n,
        progressOf: (s) => _clampProgress(s.currentStreak, n),
      ),
    AchievementRule(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a session before Fajr.',
      isUnlocked: (s) => s.earlyBirdSession,
    ),
    AchievementRule(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete a session late at night.',
      isUnlocked: (s) => s.nightOwlSession,
    ),
    AchievementRule(
      id: 'adhkar_7day',
      title: 'Adhkar Consistency',
      description: 'Complete morning adhkar for 7 days in a row.',
      isUnlocked: (s) => s.morningAdhkarStreakDays >= 7,
      progressOf: (s) => _clampProgress(s.morningAdhkarStreakDays, 7),
    ),
    AchievementRule(
      id: 'plan_complete',
      title: 'Plan Complete',
      description: 'Memorize everything in your plan.',
      isUnlocked: (s) => s.planFullyCompleted,
    ),
  ];
}

/// The ids of every rule currently satisfied by [stats] — the caller
/// diffs this against what's already persisted to find newly-unlocked
/// achievements (already-unlocked ones simply appear again here; that's
/// fine, the caller's diff is a no-op for those).
Set<String> unlockedAchievementIds(AchievementStats stats) {
  return buildAchievementRules()
      .where((rule) => rule.isUnlocked(stats))
      .map((rule) => rule.id)
      .toSet();
}
