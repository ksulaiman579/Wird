import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:go_router/go_router.dart';

import '../../core/adhkar/adhkar_window.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';

/// The "Explore" tab (M23.2, expanded in M23.4) — the renders' hub-page
/// pattern (search bar + sectioned card grids) over the app's standalone
/// destinations that don't own a bottom-nav slot: a global search, Duas &
/// Adhkar, Hadith collections, the tools (Zakah/Qibla/Tasbih), and
/// time-aware reminders. Duas also keeps its own tab per the user's
/// decision — this is an additional entry point, not the only one.
class ExploreHubScreen extends StatelessWidget {
  const ExploreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.exploreTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cream rounded search field per the renders' "Resource
          // Explorer" — tapping it opens the global search screen (a real
          // field there; this is a lightweight launcher so the hub itself
          // stays a simple scroll).
          _SearchLauncher(onTap: () => context.push('/search')),
          SectionHeader(l.exploreSectionDuasAdhkar),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.misbaha,
                title: l.exploreDailyAdhkarTitle,
                description: l.exploreDailyAdhkarDesc,
                ctaLabel: l.commonOpen,
                onTap: () => context
                    .push('/adhkar/${adhkarPeriodFor(DateTime.now()).name}'),
              ),
              HubCard(
                glyph: WirdGlyph.palms,
                title: l.exploreDuaCollectionsTitle,
                description: l.exploreDuaCollectionsDesc,
                ctaLabel: l.commonBrowse,
                onTap: () => context.go('/duas'),
              ),
            ],
          ),
          SectionHeader(l.exploreSectionStudy),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.scroll,
                title: l.hadithCollectionsTitle,
                description: l.exploreHadithDesc,
                ctaLabel: l.commonBrowse,
                onTap: () => context.push('/hadith'),
                ornamented: true,
              ),
              HubCard(
                glyph: WirdGlyph.book,
                title: l.knowledgeLibraryTitle,
                description: l.exploreKnowledgeDesc,
                ctaLabel: l.commonExplore,
                onTap: () => context.push('/knowledge'),
                ornamented: true,
              ),
            ],
          ),
          SectionHeader(l.exploreSectionCalcNavigate),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.scale,
                title: l.zakahTitle,
                description: l.exploreZakahDesc,
                ctaLabel: l.exploreCalculate,
                onTap: () => context.push('/zakah'),
              ),
              HubCard(
                glyph: WirdGlyph.compass,
                title: l.qiblaTitle,
                description: l.exploreQiblaDesc,
                ctaLabel: l.exploreFindQibla,
                onTap: () => context.push('/qibla'),
              ),
            ],
          ),
          SectionHeader(l.exploreSectionReminders),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.minaret,
                title: l.exploreMorningAdhkarTitle,
                description: l.exploreMorningAdhkarDesc,
                ctaLabel: l.exploreRecite,
                onTap: () => context.push('/adhkar/morning'),
              ),
              HubCard(
                glyph: WirdGlyph.minaret,
                title: l.exploreEveningAdhkarTitle,
                description: l.exploreEveningAdhkarDesc,
                ctaLabel: l.exploreRecite,
                onTap: () => context.push('/adhkar/evening'),
              ),
            ],
          ),
          SectionHeader(l.exploreSectionDhikr),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.misbaha,
                title: l.exploreTasbihTitle,
                description: l.exploreTasbihDesc,
                ctaLabel: l.exploreOpenTasbih,
                onTap: () => context.push('/tasbih'),
              ),
              HubCard(
                glyph: WirdGlyph.book,
                title: l.namesOfAllahTitle,
                description: l.exploreNamesDesc,
                ctaLabel: l.exploreOpenNames,
                onTap: () => context.push('/asma'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchLauncher extends StatelessWidget {
  const _SearchLauncher({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      enableBlur: false,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context).exploreSearchHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
