import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a subtle parchment paper texture overlay (warm vignette and soft
/// organic grain) for light-mode screens in Wird.
class ParchmentPainter extends CustomPainter {
  const ParchmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Soft warm radial vignette
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: const [
          Colors.transparent,
          Color(0x0C8A7340), // subtle warm shadow at edges
        ],
        stops: const [0.6, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);

    // Subtle deterministic paper texture speckles
    final grainPaint = Paint()
      ..color = const Color(0x08705C30)
      ..style = PaintingStyle.fill;

    final rand = math.Random(1337);
    final stepX = 28.0;
    final stepY = 28.0;

    for (double y = 0; y < size.height; y += stepY) {
      for (double x = 0; x < size.width; x += stepX) {
        final dx = x + (rand.nextDouble() - 0.5) * stepX * 0.8;
        final dy = y + (rand.nextDouble() - 0.5) * stepY * 0.8;
        final radius = 0.6 + rand.nextDouble() * 0.8;
        canvas.drawCircle(Offset(dx, dy), radius, grainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParchmentPainter oldDelegate) => false;
}
