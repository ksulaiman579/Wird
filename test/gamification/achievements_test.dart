import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/gamification/achievements.dart';

void main() {
  test('buildAchievementRules covers first_ayah, first_surah, all 30 juz, '
      'hadith/dua/streak milestones, early_bird/night_owl, adhkar_7day, and '
      'plan_complete with no duplicate ids', () {
    final rules = buildAchievementRules();
    final ids = rules.map((r) => r.id).toSet();

    expect(ids.length, rules.length, reason: 'no duplicate ids');
    expect(ids.contains('first_ayah'), true);
    expect(ids.contains('first_surah'), true);
    for (var juz = 1; juz <= 30; juz++) {
      expect(ids.contains('juz_$juz'), true);
    }
    for (final n in hadithMilestones) {
      expect(ids.contains('hadith_$n'), true);
    }
    for (final n in duaMilestones) {
      expect(ids.contains('dua_$n'), true);
    }
    for (final n in streakMilestones) {
      expect(ids.contains('streak_$n'), true);
    }
    expect(ids.containsAll({'early_bird', 'night_owl', 'adhkar_7day', 'plan_complete'}), true);
  });

  test('an empty stats snapshot unlocks nothing', () {
    expect(unlockedAchievementIds(const AchievementStats()), isEmpty);
  });

  test('totalAyahGroupsMemorized unlocks first_ayah only, not first_surah', () {
    final unlocked = unlockedAchievementIds(
      const AchievementStats(totalAyahGroupsMemorized: 3),
    );
    expect(unlocked.contains('first_ayah'), true);
    expect(unlocked.contains('first_surah'), false);
  });

  test('completedJuz unlocks exactly the matching juz ids', () {
    final unlocked = unlockedAchievementIds(
      const AchievementStats(completedJuz: {1, 15, 30}),
    );
    expect(unlocked.contains('juz_1'), true);
    expect(unlocked.contains('juz_15'), true);
    expect(unlocked.contains('juz_30'), true);
    expect(unlocked.contains('juz_2'), false);
  });

  test('hadith milestones unlock cumulatively at their threshold', () {
    final at25 = unlockedAchievementIds(
      const AchievementStats(hadithMemorizedCount: 25),
    );
    expect(at25.contains('hadith_10'), true);
    expect(at25.contains('hadith_20'), true);
    expect(at25.contains('hadith_30'), false);
    expect(at25.contains('hadith_40'), false);
  });

  test('streak milestones unlock cumulatively', () {
    final unlocked = unlockedAchievementIds(
      const AchievementStats(currentStreak: 45),
    );
    expect(unlocked.contains('streak_7'), true);
    expect(unlocked.contains('streak_30'), true);
    expect(unlocked.contains('streak_100'), false);
  });

  test('early_bird/night_owl reflect the session-timing flags directly', () {
    final earlyBird = unlockedAchievementIds(
      const AchievementStats(earlyBirdSession: true),
    );
    expect(earlyBird.contains('early_bird'), true);
    expect(earlyBird.contains('night_owl'), false);

    final nightOwl = unlockedAchievementIds(
      const AchievementStats(nightOwlSession: true),
    );
    expect(nightOwl.contains('night_owl'), true);
    expect(nightOwl.contains('early_bird'), false);
  });

  test('adhkar_7day requires at least 7 consecutive days', () {
    expect(
      unlockedAchievementIds(const AchievementStats(morningAdhkarStreakDays: 6))
          .contains('adhkar_7day'),
      false,
    );
    expect(
      unlockedAchievementIds(const AchievementStats(morningAdhkarStreakDays: 7))
          .contains('adhkar_7day'),
      true,
    );
  });

  test('plan_complete reflects the flag directly', () {
    expect(
      unlockedAchievementIds(const AchievementStats(planFullyCompleted: true))
          .contains('plan_complete'),
      true,
    );
  });
}
