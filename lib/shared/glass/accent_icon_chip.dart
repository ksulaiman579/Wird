import 'package:flutter/material.dart';

/// A rounded icon on a soft pastel circle (M20.5) — the playful list-row
/// accent used on the Duas groups, Hadith shelf, and Today cards. [color]
/// defaults to the theme's primary; the background is a low-alpha wash of
/// the same hue so it stays pastel in both light and dark modes.
class AccentIconChip extends StatelessWidget {
  const AccentIconChip({
    super.key,
    required this.icon,
    this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accent, size: size * 0.55),
    );
  }
}
