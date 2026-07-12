import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'parchment_painter.dart';

/// A [Scaffold] painted over the theme's [GlassTheme.backgroundGradient],
/// with its content width-capped and centered on wide screens.
///
/// Every restyled screen uses this instead of a bare [Scaffold] so the
/// glass cards inside always have a gradient to refract, and so no screen
/// ends up as a narrow phone-width column floating in empty space on a
/// tablet/desktop window (responsive-layout rule in `PLAN.md`).
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.maxContentWidth = 720,
    this.contentPadding = const EdgeInsets.all(16),
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Wide-screen content cap. `null` disables capping (full-bleed body,
  /// e.g. a screen that manages its own width-constrained sections).
  final double? maxContentWidth;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final isLight = Theme.of(context).brightness == Brightness.light;

    Widget content = Padding(padding: contentPadding, child: body);
    if (maxContentWidth != null) {
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: glass.backgroundGradient,
          ),
        ),
        child: CustomPaint(
          painter: isLight ? const ParchmentPainter() : null,
          child: SafeArea(child: content),
        ),
      ),
    );
  }
}
