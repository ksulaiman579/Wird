import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/glass/glass.dart';
import 'progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).progressTitle)),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (stats) => ListView(
          children: [
            GlassCard(
              enableBlur: false,
              child: _HeatmapCard(activityByDay: stats.activityByDay),
            ),
            const SizedBox(height: 16),
            GlassCard(
              enableBlur: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context)
                                .progressCurrentStreak,
                            value: '${stats.currentStreak}'),
                      ),
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context)
                                .progressLongestStreak,
                            value: '${stats.longestStreak}'),
                      ),
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context)
                                .progressDaysConsistent,
                            value: '${stats.daysConsistentTotal}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context).progressAyahs,
                            value: '${stats.ayahsMemorized}'),
                      ),
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context).progressHadith,
                            value: '${stats.hadithMemorized}'),
                      ),
                      Expanded(
                        child: _StatTile(
                            label: AppLocalizations.of(context).progressDuas,
                            value: '${stats.duasMemorized}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatTile(
                    label: AppLocalizations.of(context).progressReviewAccuracy,
                    value: stats.accuracy == null
                        ? AppLocalizations.of(context).progressNoReviews
                        : '${(stats.accuracy! * 100).round()}%',
                  ),
                  const SizedBox(height: 8),
                  _StatTile(
                    label:
                        AppLocalizations.of(context).progressEstimatedCompletion,
                    value: stats.estimatedCompletionDate == null
                        ? AppLocalizations.of(context).progressNoPaceData
                        : '${stats.estimatedCompletionDate!.year}-'
                            '${stats.estimatedCompletionDate!.month.toString().padLeft(2, '0')}-'
                            '${stats.estimatedCompletionDate!.day.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
            if (stats.surahProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              GlassCard(
                enableBlur: false,
                padding: EdgeInsets.zero,
                // Overall Quran % up top (memorized ayahs / 6236, the
                // canonical total), collapsed by default; tap to expand the
                // granular per-surah bars (Item 1.22).
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    title: Text(AppLocalizations.of(context).quranTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    subtitle: _OverallQuranBar(
                        memorizedAyahs: stats.ayahsMemorized),
                    children: [
                      for (final surah in stats.surahProgress)
                        _CoverageBar(coverage: surah),
                    ],
                  ),
                ),
              ),
            ],
            if (stats.juzProgress.isNotEmpty) ...[
              const SizedBox(height: 16),
              GlassCard(
                enableBlur: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Juz', style: Theme.of(context).textTheme.titleMedium),
                    for (final juz in stats.juzProgress)
                      _CoverageBar(coverage: juz),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.coverage});

  final CoverageProgress coverage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(coverage.label, overflow: TextOverflow.ellipsis)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: coverage.fraction, minHeight: 8),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(coverage.fraction * 100).round()}%'),
        ],
      ),
    );
  }
}

/// The collapsed-header overall-Quran progress: memorized ayahs against the
/// canonical 6,236-ayah total, as a labelled bar (Item 1.22).
class _OverallQuranBar extends StatelessWidget {
  const _OverallQuranBar({required this.memorizedAyahs});

  static const _totalAyahs = 6236;

  final int memorizedAyahs;

  @override
  Widget build(BuildContext context) {
    final fraction = (memorizedAyahs / _totalAyahs).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: fraction, minHeight: 8),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(fraction * 100).round()}% · $memorizedAyahs/$_totalAyahs'),
        ],
      ),
    );
  }
}

/// A GitHub-style activity heatmap for the last 52 weeks, oldest week
/// first, each column a week (Sun-Sat) and each cell shaded by that day's
/// item count.
class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.activityByDay});

  final Map<String, int> activityByDay;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    const weeks = 52;
    final firstDay = startOfWeek.subtract(const Duration(days: 7 * (weeks - 1)));

    final maxCount = activityByDay.values.isEmpty
        ? 1
        : activityByDay.values.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            for (var week = 0; week < weeks; week++)
              Column(
                children: [
                  for (var day = 0; day < 7; day++)
                    _HeatmapCell(
                      date: firstDay.add(Duration(days: week * 7 + day)),
                      activityByDay: activityByDay,
                      maxCount: maxCount,
                      color: scheme.primary,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.date,
    required this.activityByDay,
    required this.maxCount,
    required this.color,
  });

  final DateTime date;
  final Map<String, int> activityByDay;
  final int maxCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final key = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final count = activityByDay[key] ?? 0;
    final opacity = count == 0 ? 0.08 : (0.25 + 0.75 * (count / maxCount)).clamp(0.25, 1.0);

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Tooltip(
        message: '$key: $count',
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
