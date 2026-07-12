import 'package:flutter/material.dart';

/// The manuscript corner-flourish accent (an "L" with a nested arc) that
/// gives Quran cards their render-faithful frame (M23). Extracted here so the
/// same signature can extend to hadith and dua cards (D10) — a single visual
/// identity across the app's content surfaces. Hand-drawn so it needs no
/// glyph asset.
///
/// Drop [cornerFlourishes] into a [Stack] alongside the card's content; the
/// marks are [Positioned] to the four corners so they never influence the
/// Stack's size (safe inside intrinsic-height list cards, not just fixed
/// grid cells).
List<Widget> cornerFlourishes(
  BuildContext context, {
  double alpha = 0.35,
  double size = 16,
}) {
  final color = Theme.of(context).colorScheme.secondary.withValues(alpha: alpha);
  Widget mark(int quarterTurns) => RotatedBox(
        quarterTurns: quarterTurns,
        child: CustomPaint(
          size: Size(size, size),
          painter: CornerFlourishPainter(color),
        ),
      );
  return [
    Positioned(top: 0, left: 0, child: mark(0)),
    Positioned(top: 0, right: 0, child: mark(1)),
    Positioned(bottom: 0, left: 0, child: mark(3)),
    Positioned(bottom: 0, right: 0, child: mark(2)),
  ];
}

/// Paints one corner mark: two short strokes meeting at the corner with a
/// small nested quarter-arc. Rotate via [RotatedBox] for the other corners.
class CornerFlourishPainter extends CustomPainter {
  const CornerFlourishPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset.zero, Offset(size.width, 0), paint)
      ..drawLine(Offset.zero, Offset(0, size.height), paint)
      ..drawArc(
        Rect.fromCircle(center: Offset.zero, radius: size.width * 0.55),
        0,
        1.5708,
        false,
        paint,
      );
  }

  @override
  bool shouldRepaint(covariant CornerFlourishPainter oldDelegate) =>
      oldDelegate.color != color;
}
