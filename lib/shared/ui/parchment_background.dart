import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A subtle paper-grain texture tinted by the current surface color, so the
/// page always *reads as parchment* rather than a flat fill — regardless of
/// which palette swatch (M22.2) the user has picked (M23 design spec).
///
/// The grain is a deterministic scatter of low-alpha dots/flecks painted
/// once per size via [CustomPainter] (no image asset, no per-frame cost —
/// [shouldRepaint] is false unless the tint or size actually changes).
/// Intensity is tuned low enough to be a texture, not a pattern: at normal
/// viewing distance it reads as "paper", not "dots". In dark mode the tint
/// is a faint highlight instead of a shadow, keeping it near-invisible
/// rather than muddying the dark surface.
class ParchmentBackground extends StatelessWidget {
  const ParchmentBackground({
    super.key,
    required this.child,
    this.baseColor,
    this.intensity = 1.0,
  });

  final Widget child;

  /// Surface color to tint the grain against. Defaults to the current
  /// theme's scaffold background / surface color.
  final Color? baseColor;

  /// Scales the grain's opacity — cards use a lighter touch than the page
  /// background. 1.0 is the page default.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = baseColor ?? theme.colorScheme.surface;
    final isDark = theme.brightness == Brightness.dark;

    return CustomPaint(
      painter: _ParchmentPainter(
        base: base,
        isDark: isDark,
        intensity: intensity,
      ),
      child: child,
    );
  }
}

class _ParchmentPainter extends CustomPainter {
  const _ParchmentPainter({
    required this.base,
    required this.isDark,
    required this.intensity,
  });

  final Color base;
  final bool isDark;
  final double intensity;

  // Fixed seed: the grain must look identical frame-to-frame and rebuild-to
  // -rebuild (a live-changing texture would read as noise/shimmer, not
  // paper).
  static const _seed = 20260707;
  static const _flecksPerCell = 1;
  static const _cellSize = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);

    // Dark mode: near-invisible faint highlight flecks, not cream grain —
    // the design spec calls for the texture to fade almost away rather
    // than tint dark surfaces cream.
    final fleckColor = isDark
        ? Colors.white.withValues(alpha: 0.020 * intensity)
        : Colors.black.withValues(alpha: 0.028 * intensity);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.012 * intensity)
        : Colors.white.withValues(alpha: 0.035 * intensity);

    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(_seed);

    final cols = (size.width / _cellSize).ceil() + 1;
    final rows = (size.height / _cellSize).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        for (var f = 0; f < _flecksPerCell; f++) {
          final cx = col * _cellSize + random.nextDouble() * _cellSize;
          final cy = row * _cellSize + random.nextDouble() * _cellSize;
          final radius = 0.4 + random.nextDouble() * 0.9;
          paint.color = random.nextBool() ? fleckColor : highlightColor;
          canvas.drawCircle(Offset(cx, cy), radius, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParchmentPainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.isDark != isDark ||
      oldDelegate.intensity != intensity;
}
