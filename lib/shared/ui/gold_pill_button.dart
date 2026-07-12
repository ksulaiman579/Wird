import 'package:flutter/material.dart';

/// The renders' primary CTA: a full-width gold pill (e.g. "View surah",
/// "Calculate", "Resume"). Thin wrapper over the app's [FilledButton] theme
/// (`AppTheme._build`'s `filledButtonTheme`), which already sets the gold
/// fill / black foreground / pill shape.
///
/// Labels render in sentence case as written (Item D1) — the previous
/// force-uppercase read as SHOUTING and un-iOS, and mangled non-Latin
/// scripts under localization. Call sites pass already-cased (localized)
/// labels.
class GoldPillButton extends StatelessWidget {
  const GoldPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: const TextStyle(letterSpacing: 0.3),
    );

    if (icon == null) {
      return FilledButton(onPressed: onPressed, child: child);
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: child,
    );
  }
}
