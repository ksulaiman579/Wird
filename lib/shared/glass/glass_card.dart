import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A frosted-glass container: a blurred, translucent, gold-bordered surface
/// over whatever sits behind it.
///
/// Per the app's glass performance rule, a screen should have at most one
/// blurred region — typically the scaffold background. Cards nested inside
/// an already-blurred region must set [enableBlur] to `false` so they paint
/// a flat translucent fill instead of stacking a second [BackdropFilter]
/// (list tiles of ayahs/hadith are the common case).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.enableBlur = true,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.fillColor,
  });

  final Widget child;
  final bool enableBlur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  /// Overrides [GlassTheme.fillColor] — used by the Quran/Hadith readers'
  /// cream "mushaf page" cards (M21.5); null keeps the theme fill.
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final radius = BorderRadius.circular(glass.cardRadius);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor ?? glass.fillColor,
        borderRadius: radius,
        border: Border.all(color: glass.borderColor, width: glass.borderWidth),
      ),
      // A ListTile/InkWell descendant paints its background and ink
      // splashes on the *nearest* Material ancestor. Without this, that
      // ancestor is the app's root Scaffold Material far up the tree, and
      // this Container's own decoration paints over it — silently hiding
      // ink feedback (Flutter raises a debug-mode assertion for exactly
      // this). A transparent Material here gives such descendants a
      // correct, nearby paint surface without changing this card's look.
      child: Material(type: MaterialType.transparency, child: child),
    );

    if (enableBlur && glass.blurSigma > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: glass.blurSigma,
          sigmaY: glass.blurSigma,
        ),
        child: content,
      );
    }

    final clipped = ClipRRect(borderRadius: radius, child: content);

    // Soft drop shadow gives the light-mode white cards depth over the
    // cream page (M21.7); empty list on dark/AMOLED, so this is a no-op
    // there. Painted on a separate box behind the clip so the blur/border
    // don't clip it away.
    return Container(
      margin: margin,
      decoration: glass.cardShadow.isEmpty
          ? null
          : BoxDecoration(
              borderRadius: radius,
              boxShadow: glass.cardShadow,
            ),
      child: onTap == null
          ? clipped
          : Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: onTap,
                child: clipped,
              ),
            ),
    );
  }
}
