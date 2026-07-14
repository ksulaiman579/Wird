import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/gamification/achievements.dart';
import '../../core/i18n/bidi.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import '../../shared/widgets/wird_home_header.dart';
import '../achievements/achievement_providers.dart';
import '../quran_browser/quran_providers.dart';
import '../quran_reader/reader_prefs.dart';
import '../quran_reader/reading_streak.dart';
import '../update/update_ui.dart';
import 'today_providers.dart';

/// `AchievementRule.id` → human title, e.g. `'streak_7'` → `'7-Day Streak'`
/// (M23.3's Recent Activity card). Falls back to the raw id if a rule was
/// ever renamed/removed after being unlocked.
String _achievementTitle(String id) {
  for (final rule in buildAchievementRules()) {
    if (rule.id == id) return rule.title;
  }
  return id;
}

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensures today's daily_sessions row exists; result isn't used directly.
    ref.watch(ensureDailySessionProvider);

    final profileAsync = ref.watch(userProfileStreamProvider);
    final breakdownAsync = ref.watch(todayBreakdownProvider);
    final readerPrefs = ref.watch(readerPrefsProvider).value;
    final hasReadBefore = readerPrefs?.hasReadBefore ?? false;

    final name = profileAsync.value?.name ?? '';

    return GlassScaffold(
      appBar: const WirdHomeHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title per the "My Progress" render (M23.3) — the
            // per-name greeting moves under it as a smaller subtitle
            // rather than being the headline itself.
            Text(
              AppLocalizations.of(context).todayMyProgress,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              name.isEmpty
                  ? AppLocalizations.of(context).todayGreeting
                  : AppLocalizations.of(context).todayGreetingNamed(name),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const UpdateBanner(),
            breakdownAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(AppLocalizations.of(context).commonFailedToLoad('$e')),
              data: (breakdown) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (breakdown.easeBackActive) const _WelcomeBackBanner(),
                  if (breakdown.easeBackActive) const SizedBox(height: 12),
                  _TodayHeroCard(breakdown: breakdown),
                ],
              ),
            ),
            if (hasReadBefore) ...[
              const SizedBox(height: 24),
              _SectionLabel(AppLocalizations.of(context).todaySectionContinue),
              const _ContinueReadingCard(),
            ],
            const SizedBox(height: 24),
            _SectionLabel(AppLocalizations.of(context).todaySectionRecent),
            const _RecentActivityCard(),
            const SizedBox(height: 24),
            _SectionLabel(AppLocalizations.of(context).todaySectionStreak),
            const Row(
              children: [
                Expanded(child: _StreakCard()),
                SizedBox(width: 12),
                Expanded(child: _ReadingStreakCard()),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(AppLocalizations.of(context).todaySectionRemembrance),
            const _AdhkarTiles(),
            const SizedBox(height: 24),
            _SectionLabel(AppLocalizations.of(context).todaySectionTools),
            const _ToolsRow(),
            const SizedBox(height: 24),
            const _AlManhajTeaserCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A small gold uppercase eyebrow that heads each Today section — the
/// "structure is information" device from the design pass (M22.1).
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        // Sentence case as written (Item D2) — the previous ALL-CAPS wide
        // tracking read un-iOS and looked wrong under RTL. Kept gold as the
        // brand eyebrow device, just de-shouted.
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFFB8891F), // deeper gold, AA on cream
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// The Today "hero": a gold progress ring for today's portion (the
/// signature element from the reference renders), the streak, and the
/// Start Session CTA — the one bold moment on the screen.
class _TodayHeroCard extends ConsumerWidget {
  const _TodayHeroCard({required this.breakdown});

  final TodayBreakdown breakdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak =
        ref.watch(streakStateStreamProvider).value?.currentStreak ?? 0;
    final goal =
        ref.watch(weeklyGoalProvider).value ?? WeeklyGoalProgress.empty;

    // Today's completion: done vs the day's planned total. Sessions row is
    // the source of truth (planned is fixed at day start, done increments).
    final sessions = ref.watch(dailySessionsStreamProvider).value ?? const [];
    final today = _todayKey();
    final row = sessions.where((s) => s.day == today).firstOrNull;
    final planned =
        (row?.newItemsPlanned ?? breakdown.sabaqCount) +
        (row?.reviewsPlanned ?? breakdown.sabqiCount + breakdown.manzilCount);
    final done = (row?.newItemsDone ?? 0) + (row?.reviewsDone ?? 0);
    final ratio = planned == 0 ? 1.0 : (done / planned).clamp(0.0, 1.0);
    final allDone = breakdown.totalCount == 0;

    return GlassCard(
      enableBlur: false,
      child: Column(
        children: [
          Row(
            children: [
              GlassProgressRing(
                progress: ratio,
                size: 96,
                strokeWidth: 10,
                center: Text(
                  '$done/$planned',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone
                          ? AppLocalizations.of(context).todayGoalDone
                          : AppLocalizations.of(context)
                              .todayGoalProgress(done, planned),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Bidi.isolateNumbers(
                        AppLocalizations.of(context).todayBreakdown(
                          breakdown.sabaqCount,
                          breakdown.sabqiCount + breakdown.manzilCount,
                          breakdown.estimatedMinutes,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFE08A1E),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            Bidi.isolateNumbers(
                              AppLocalizations.of(context).todayStreakWeek(
                                streak,
                                goal.completed,
                                goal.goal,
                              ),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BreakdownRow(
            label: AppLocalizations.of(context).todaySabaq,
            count: breakdown.sabaqCount,
          ),
          _BreakdownRow(
            label: AppLocalizations.of(context).todaySabqi,
            count: breakdown.sabqiCount,
          ),
          _BreakdownRow(
            label: AppLocalizations.of(context).todayManzil,
            count: breakdown.manzilCount,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: allDone ? null : () => context.push('/session'),
              child: Text(allDone ? AppLocalizations.of(context).todayAllDone : AppLocalizations.of(context).todayStartSession),
            ),
          ),
        ],
      ),
    );
  }

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

class _WelcomeBackBanner extends StatelessWidget {
  const _WelcomeBackBanner();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.favorite_outline_rounded),
          const SizedBox(width: 8),
          Expanded(child: Text(AppLocalizations.of(context).todayWelcomeBack)),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text('$count'),
        ],
      ),
    );
  }
}

/// Quick access to the M15 interactive tools (Qibla/Zakah/Tasbih) — the
/// plan's accepted nav-rework recommendation is to surface these as a
/// prominent section on Today/More rather than give them their own
/// bottom-nav slots (M16.2).
class _ToolsRow extends StatelessWidget {
  const _ToolsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassPill(
            enableBlur: false,
            onTap: () => context.push('/qibla'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore_outlined, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).qiblaTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassPill(
            enableBlur: false,
            onTap: () => context.push('/zakah'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate_outlined, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).zakahShort,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassPill(
            enableBlur: false,
            onTap: () => context.push('/tasbih'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint_rounded, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).tasbihTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdhkarTiles extends StatelessWidget {
  const _AdhkarTiles();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassPill(
            enableBlur: false,
            onTap: () => context.push('/adhkar/morning'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).exploreMorningAdhkarTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassPill(
            enableBlur: false,
            onTap: () => context.push('/adhkar/evening'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nights_stay_outlined, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).exploreEveningAdhkarTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(readerPrefsProvider);
    final metaAsync = ref.watch(quranMetaProvider);

    final surah = prefsAsync.value?.lastSurah ?? 1;
    final surahName = metaAsync.maybeWhen(
      data: (meta) =>
          meta.surahs.firstWhere((s) => s.number == surah).nameTransliterated,
      orElse: () => 'Surah $surah',
    );

    return GlassCard(
      enableBlur: false,
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).todayContinueReading),
                Text(surahName, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GoldPillButton(
            label: AppLocalizations.of(context).readingResume,
            onPressed: () => context.push('/read?surah=$surah'),
          ),
        ],
      ),
    );
  }
}

/// "Recent Activity" (M23.3 design spec): today's session progress plus
/// the most recently unlocked achievement, if any — a couple of concrete,
/// real check-off items rather than a generic feed.
class _RecentActivityCard extends ConsumerWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(todayBreakdownProvider);
    final achievementsAsync = ref.watch(achievementsStreamProvider);

    final latestAchievement = achievementsAsync.maybeWhen(
      data: (list) => list.isEmpty
          ? null
          : (list.toList()
                  ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt)))
                .first,
      orElse: () => null,
    );

    final sessionDone = breakdownAsync.maybeWhen(
      data: (b) => b.totalCount == 0,
      orElse: () => false,
    );

    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActivityRow(
            label: sessionDone
                ? AppLocalizations.of(context).todaySessionCompleted
                : AppLocalizations.of(context).todaySessionInProgress,
            done: sessionDone,
          ),
          if (latestAchievement != null) ...[
            const SizedBox(height: 8),
            _ActivityRow(
              label: AppLocalizations.of(context).todayUnlocked(
                _achievementTitle(latestAchievement.achievementId),
              ),
              done: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label)),
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: done ? theme.colorScheme.secondary : theme.colorScheme.outline,
          size: 20,
        ),
      ],
    );
  }
}

/// Left half of the Streak/Insights 2-up row (M23.3 design spec).
class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak =
        ref.watch(streakStateStreamProvider).value?.currentStreak ?? 0;
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).todayCurrentStreak,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFE08A1E),
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).todayStreakDays(streak),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Right half of the Streak row: the *normal Quran reading* streak, tracked
/// separately from the memorization/SRS streak in `_StreakCard`. Counts days
/// the user actually read in the Quran reader (see `readingStreakProvider`) —
/// this replaced the old "Key Insights" 7-day bar chart per the user's
/// request for a distinct non-lesson reading streak.
class _ReadingStreakCard extends ConsumerWidget {
  const _ReadingStreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(readingStreakProvider).value?.currentStreak ?? 0;
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).todayReadingStreak,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).todayStreakDays(streak),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Al-Manhaj teaser card (M23.3 design spec) — a small nudge toward the
/// off-screen-by-default tab (M23.2's swipeable nav), since it otherwise
/// has no visible presence on Home.
class _AlManhajTeaserCard extends StatelessWidget {
  const _AlManhajTeaserCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      onTap: () => context.push('/almanhaj'),
      child: Row(
        children: [
          const Icon(Icons.school_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(AppLocalizations.of(context).todayAlManhajTeaser),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
