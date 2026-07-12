
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The app's chrome bar (M21.5 "Royal Emerald"): an opaque deep-emerald
/// band with gold title/icons, per the inspiration renders — no longer a
/// frosted-glass surface (an opaque chrome band has nothing to refract,
/// so the old BackdropFilter is gone too, a small perf win per screen).
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;

    return Container(
      color: glass.chromeColor,
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: glass.chromeForeground,
        iconTheme: IconThemeData(color: glass.chromeForeground),
        actionsIconTheme: IconThemeData(color: glass.chromeForeground),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: glass.chromeForeground,
              fontWeight: FontWeight.w600,
            ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
