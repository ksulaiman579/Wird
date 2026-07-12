import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A pillbox-shaped glass button/chip — the app's recurring "pillbox UI"
/// element (tags, filter chips, small actions, nav items).
///
/// Touch target is kept at a minimum 48dp height regardless of [padding] so
/// small pills stay accessible.
class GlassPill extends StatefulWidget {
  const GlassPill({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.enableBlur = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry padding;
  final bool enableBlur;

  @override
  State<GlassPill> createState() => _GlassPillState();
}

class _GlassPillState extends State<GlassPill> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final onTap = widget.onTap;
    final selected = widget.selected;
    final padding = widget.padding;
    final enableBlur = widget.enableBlur;
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>() ?? GlassTheme.light;
    final fill = selected
        ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.55)
        : glass.fillColor;
    final border = selected
        ? theme.colorScheme.secondary
        : glass.borderColor;

    Widget content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: glass.borderWidth),
        ),
        child: child,
      ),
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

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: content,
    );

    if (onTap == null) return clipped;

    // Pressed-scale micro-interaction (M23.14): a subtle dip on tap-down.
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          child: clipped,
        ),
      ),
    );
  }
}
