import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../glass/glass.dart';
import '../ui/ui.dart';
import 'global_mini_player.dart';
import 'wird_tour_overlay.dart';

/// Persistent bottom navigation (M23.2): Home · Quran · Explore · Duas ·
/// More, with Al-Manhaj as a 6th branch reachable by pressing and swiping
/// the nav bar past the trailing edge (see [GlassNavBar]). Quran and
/// Hadith still share the "Quran" slot (a hub screen linking to both, the
/// former "Read" tab) so Al-Manhaj can join the bar without crowding it.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _tourSeenKey = 'wird_tour_seen';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTour());
  }

  Future<void> _maybeShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_tourSeenKey) ?? false) return;
    if (!mounted) return;
    // Mark seen *before* showing (Item A7): the tour is a one-time
    // orientation aid, so navigating away or reloading mid-tour must not
    // make it reappear — previously the flag was only written after the
    // user tapped "Got it", so any other dismissal re-showed it every boot.
    await prefs.setBool(_tourSeenKey, true);
    if (!mounted) return;
    await showWirdTourOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GlobalMiniPlayer(),
          GlassNavBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) => widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            ),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today_rounded),
                label: AppLocalizations.of(context).navHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories_rounded),
                label: AppLocalizations.of(context).navQuran,
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: AppLocalizations.of(context).navExplore,
              ),
              NavigationDestination(
                // Raised/cupped hands of supplication, not a meditating
                // figure (Item 1.3) — the shared design glyph, tinted to
                // match the nav bar's selected/unselected icon colour.
                icon: _PalmsNavIcon(),
                label: AppLocalizations.of(context).navDuas,
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz_rounded),
                label: AppLocalizations.of(context).navMore,
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded),
                label: AppLocalizations.of(context).navAlManhaj,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The Duas tab's raised-hands glyph, sized like a Material nav icon and
/// tinted from the ambient [IconTheme] so it dims/brightens with the tab's
/// selected state exactly like the sibling Material icons.
class _PalmsNavIcon extends StatelessWidget {
  const _PalmsNavIcon();

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return WirdIcon(
      WirdGlyph.palms,
      size: iconTheme.size ?? 24,
      color: iconTheme.color,
      strokeWidth: 1.8,
    );
  }
}
