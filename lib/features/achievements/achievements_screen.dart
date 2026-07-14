import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gamification/achievements.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import 'achievement_providers.dart';

/// Which themed journey an achievement rule belongs to (M23.7, render
/// qz6f2v) — derived from the rule id so it stays in sync with
/// `buildAchievementRules()` without a second source of truth.
enum _Journey { quran, hadith, devotion, consistency }

_Journey _journeyOf(String id) {
  if (id.startsWith('hadith_')) return _Journey.hadith;
  if (id.startsWith('streak_')) return _Journey.consistency;
  if (id.startsWith('dua_') ||
      id == 'adhkar_7day' ||
      id == 'early_bird' ||
      id == 'night_owl') {
    return _Journey.devotion;
  }
  // first_ayah, first_surah, juz_*, plan_complete, and any future
  // Quran-memorization rules.
  return _Journey.quran;
}

String _journeyTitle(_Journey j, AppLocalizations l) => switch (j) {
  _Journey.quran => l.achievementsQuranicJourney,
  _Journey.hadith => l.achievementsPathOfHadith,
  _Journey.devotion => l.achievementsDhikrDevotion,
  _Journey.consistency => l.achievementsConsistency,
};

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsStreamProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).achievementsTitle)),
      contentPadding: EdgeInsets.zero,
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (unlocked) {
          final unlockedIds = unlocked.map((a) => a.achievementId).toSet();
          final rules = buildAchievementRules();
          final total = rules.length;
          final done = rules.where((r) => unlockedIds.contains(r.id)).length;
          // Point-in-time snapshot for locked-badge progress hints (1.23);
          // null while it loads — tiles just omit the hint then.
          final stats = ref.watch(achievementStatsProvider).value;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OverallBar(done: done, total: total),
              for (final journey in _Journey.values)
                ..._journeySection(context, journey, rules, unlockedIds, stats),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _journeySection(
    BuildContext context,
    _Journey journey,
    List<AchievementRule> rules,
    Set<String> unlockedIds,
    AchievementStats? stats,
  ) {
    final inJourney = rules.where((r) => _journeyOf(r.id) == journey).toList();
    if (inJourney.isEmpty) return const [];
    return [
      SectionHeader(_journeyTitle(journey, AppLocalizations.of(context))),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: inJourney.length,
        itemBuilder: (context, i) => _BadgeTile(
          rule: inJourney[i],
          isUnlocked: unlockedIds.contains(inJourney[i].id),
          stats: stats,
        ),
      ),
    ];
  }
}

/// The render's "Unlocked: n / total" progress header.
class _OverallBar extends StatelessWidget {
  const _OverallBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : done / total;
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).achievementsUnlocked,
                  style: theme.textTheme.titleMedium),
              Text(
                '$done / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: theme.colorScheme.secondary,
              backgroundColor: theme.colorScheme.secondary.withValues(
                alpha: 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.rule,
    required this.isUnlocked,
    this.stats,
  });

  final AchievementRule rule;
  final bool isUnlocked;
  final AchievementStats? stats;

  IconData _iconForAchievement(String id) {
    if (id.startsWith('first_ayah') ||
        id.startsWith('first_surah') ||
        id.startsWith('juz_')) {
      return Icons.menu_book_rounded;
    }
    if (id.startsWith('hadith_')) {
      return Icons.auto_stories_rounded;
    }
    if (id.startsWith('dua_')) {
      return Icons.volunteer_activism_rounded;
    }
    if (id.startsWith('streak_')) {
      return Icons.local_fire_department_rounded;
    }
    if (id.startsWith('early_bird')) {
      return Icons.wb_sunny_rounded;
    }
    if (id.startsWith('night_owl')) {
      return Icons.nightlight_round;
    }
    return Icons.workspace_premium_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconData = _iconForAchievement(rule.id);

    // "how close am I" hint for still-locked, countable badges (Item 1.23).
    final (int, int)? progress =
        (!isUnlocked && stats != null) ? rule.progressOf?.call(stats!) : null;

    return Tooltip(
      message: rule.description,
      child: GlassCard(
        enableBlur: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Opacity(
                  opacity: isUnlocked ? 1.0 : 0.35,
                  child: Icon(
                    iconData,
                    size: 38,
                    color: isUnlocked ? scheme.secondary : scheme.outline,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 14,
                    color: isUnlocked
                        ? Colors.green.shade600
                        : scheme.outline.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rule.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? null
                        : scheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 2),
              Text(
                '${progress.$1} / ${progress.$2}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

