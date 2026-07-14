import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/adhkar/adhkar_window.dart';
import '../../core/content/dua_search.dart';
import '../../core/notifications/notification_providers.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/corner_flourishes.dart';
import '../adhkar/adhkar_reader_screen.dart' show completedPrefsKey;
import 'dua_category_titles.dart';
import 'dua_group_titles.dart';
import 'dua_providers.dart';
import 'dua_theme_groups.dart';

/// Which adhkar period ("morning"/"evening") is current right now, using
/// today's real Fajr/Asr when a location is set (falling back to the
/// 06:00/17:00 convention otherwise, same as notification scheduling).
final _currentAdhkarPeriodProvider = FutureProvider<AdhkarPeriod>((ref) async {
  final times = await ref.watch(prayerTimesPreviewProvider.future);
  return adhkarPeriodFor(DateTime.now(), fajr: times?.fajr, asr: times?.asr);
});

final _adhkarCompletedTodayProvider =
    FutureProvider.family<bool, String>((ref, period) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(completedPrefsKey(period, DateTime.now())) ?? false;
});

/// The Duas tab root (M20.4, time-awareness + search added in M14.2): a
/// time-aware "Daily Adhkar" card — Morning or Evening, whichever period
/// it currently is — followed by the Hisnul Muslim categories clubbed
/// into circumstance-theme groups, with a search box that flattens all
/// 130 categories when typing (bypassing the group structure so a search
/// hit is never buried in the wrong theme group).
class DuaCategoriesScreen extends ConsumerStatefulWidget {
  const DuaCategoriesScreen({super.key});

  @override
  ConsumerState<DuaCategoriesScreen> createState() =>
      _DuaCategoriesScreenState();
}

class _DuaCategoriesScreenState extends ConsumerState<DuaCategoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final periodAsync = ref.watch(_currentAdhkarPeriodProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).duasTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context).duasDailyAdhkar, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          periodAsync.when(
            loading: () => const _CurrentAdhkarCard(
              period: AdhkarPeriod.morning,
              loading: true,
            ),
            error: (e, st) =>
                const _CurrentAdhkarCard(period: AdhkarPeriod.morning),
            data: (period) => _CurrentAdhkarCard(period: period),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).duasSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
          const SizedBox(height: 16),
          if (_query.isEmpty) ...[
            Text(AppLocalizations.of(context).duasEssential, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const _EssentialShelf(),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).duasByCircumstance, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final group in duaThemeGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  enableBlur: false,
                  onTap: () => context.push('/duas/group/${group.id}'),
                  child: Stack(
                    children: [
                      ...cornerFlourishes(context),
                      Row(
                        children: [
                          AccentIconChip(
                              icon: _groupIcons[group.id] ??
                                  Icons.auto_awesome_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(duaGroupTitle(context, group.id),
                                    overflow: TextOverflow.ellipsis),
                                Text(
                                  AppLocalizations.of(context).duasOccasionCount(
                                      group.categoryIds.length),
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ] else
            _SearchResults(query: _query),
        ],
      ),
    );
  }
}

/// Horizontal shelf of the most-reached-for duas (M22.5) — a quick entry
/// point so the everyday ones aren't buried inside theme groups.
class _EssentialShelf extends ConsumerWidget {
  const _EssentialShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);
    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 96,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const SizedBox.shrink(),
      data: (hisnulMuslim) {
        final byId = {for (final c in hisnulMuslim.categories) c.id: c};
        final items = [
          for (final id in essentialDuaCategoryIds)
            if (byId[id] != null) byId[id]!,
        ];
        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final c = items[i];
              return SizedBox(
                width: 160,
                child: GlassCard(
                  enableBlur: false,
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push('/duas/${c.id}'),
                  child: Stack(
                    children: [
                      ...cornerFlourishes(context),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const AccentIconChip(icon: Icons.star_rounded),
                          Text(
                            duaCategoryTitleFor(context, ref, c),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(AppLocalizations.of(context).commonFailedToLoad('$error')),
      data: (hisnulMuslim) {
        final matches = duaSearchMatches(hisnulMuslim.categories, query);
        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(AppLocalizations.of(context).duasNoMatch),
            ),
          );
        }
        return Column(
          children: [
            for (final category in matches)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  enableBlur: false,
                  onTap: () => context.push('/duas/${category.id}'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(duaCategoryTitleFor(context, ref, category),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

const _groupIcons = <String, IconData>{
  'daily-routine': Icons.wb_twilight_rounded,
  'prayer': Icons.mosque_rounded,
  'morning-evening-sleep': Icons.bedtime_rounded,
  'distress-protection': Icons.shield_rounded,
  'food-social-family': Icons.restaurant_rounded,
  'illness-death': Icons.healing_rounded,
  'travel-hajj': Icons.flight_takeoff_rounded,
  'remembrance-nature': Icons.spa_rounded,
};

class _CurrentAdhkarCard extends ConsumerWidget {
  const _CurrentAdhkarCard({required this.period, this.loading = false});

  final AdhkarPeriod period;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMorning = period == AdhkarPeriod.morning;
    final periodKey = isMorning ? 'morning' : 'evening';
    final otherKey = isMorning ? 'evening' : 'morning';
    final completedAsync = ref.watch(_adhkarCompletedTodayProvider(periodKey));
    final completed = completedAsync.value ?? false;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          enableBlur: false,
          onTap: () => context.push('/adhkar/$periodKey'),
          child: Row(
            children: [
              AccentIconChip(
                icon: isMorning
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMorning
                          ? AppLocalizations.of(context).exploreMorningAdhkarTitle
                          : AppLocalizations.of(context).exploreEveningAdhkarTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      completed
                          ? AppLocalizations.of(context).duasCompletedToday
                          : AppLocalizations.of(context).duasNotDoneToday,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (completed)
                Icon(Icons.check_circle_rounded, color: scheme.primary)
              else
                const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push('/adhkar/$otherKey'),
            child: Text(
              otherKey == 'morning'
                  ? AppLocalizations.of(context).duasViewMorning
                  : AppLocalizations.of(context).duasViewEvening,
            ),
          ),
        ),
      ],
    );
  }
}
