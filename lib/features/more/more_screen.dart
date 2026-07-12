import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:go_router/go_router.dart';

import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';

/// The "More" tab as the renders' Account & Settings hub (M23.4, render
/// bk48sq): the app's secondary destinations grouped into
/// Profile & Journey / App Preferences / Resources & Support sections of
/// illustrated hub cards, replacing the old flat tile list.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.moreTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            l.moreYourJourney,
            padding: const EdgeInsets.only(bottom: 12),
          ),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.compass,
                title: l.moreProgressTitle,
                description: l.moreProgressDesc,
                ctaLabel: l.commonReview,
                onTap: () => context.push('/progress'),
              ),
              HubCard(
                glyph: WirdGlyph.book,
                title: l.moreAchievementsTitle,
                description: l.moreAchievementsDesc,
                ctaLabel: l.commonView,
                onTap: () => context.push('/achievements'),
              ),
            ],
          ),
          SectionHeader(l.moreLibraryDownloads),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.book,
                title: l.knowledgeLibraryTitle,
                description: l.moreKnowledgeDesc,
                ctaLabel: l.commonExplore,
                onTap: () => context.push('/knowledge'),
                ornamented: true,
              ),
              HubCard(
                glyph: WirdGlyph.scroll,
                title: l.moreContentLibraryTitle,
                description: l.moreContentLibraryDesc,
                ctaLabel: l.commonOpen,
                onTap: () => context.push('/library'),
              ),
              HubCard(
                glyph: WirdGlyph.minaret,
                title: l.alManhajTitle,
                description: l.moreAlManhajDesc,
                ctaLabel: l.moreDiscover,
                onTap: () => context.push('/almanhaj'),
              ),
            ],
          ),
          SectionHeader(l.moreSettingsAbout),
          _MoreTile(
            icon: Icons.settings_outlined,
            label: l.commonSettings,
            subtitle: l.moreSettingsSubtitle,
            route: '/settings',
          ),
          _MoreTile(
            icon: Icons.info_outline_rounded,
            label: l.aboutTitle,
            subtitle: l.moreAboutSubtitle,
            route: '/settings/about',
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.route,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        enableBlur: false,
        onTap: () => context.push(route),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
