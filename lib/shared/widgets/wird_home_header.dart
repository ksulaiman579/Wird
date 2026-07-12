import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// The Home tab's chrome header (M23.2 design spec): a profile roundel
/// (left, opens More/Settings), the calligraphic Arabic wordmark centered,
/// and a bell (right, opens notification settings). Other screens keep
/// [GlassAppBar] for now — the inner-screen header variant (back + title +
/// subtitle + gold underline) arrives with the hub-page work in M23.4.
class WirdHomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const WirdHomeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final gold = glass.chromeForeground;

    return Container(
      color: glass.chromeColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'وِرد',
                  style: TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 26,
                    color: gold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: gold.withValues(alpha: 0.18),
                    child: Icon(Icons.person_outline, color: gold, size: 18),
                  ),
                  tooltip: AppLocalizations.of(context).headerProfileTooltip,
                  onPressed: () => context.push('/settings'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, color: gold),
                  tooltip: AppLocalizations.of(context).headerRemindersTooltip,
                  onPressed: () => context.push('/settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
