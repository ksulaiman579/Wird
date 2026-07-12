import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The render-style content icon set (M23 design spec): gold-line
/// geometric/calligraphic motifs, hand-drawn as [CustomPainter]s so the app
/// never depends on a third-party icon pack or SVG asset pipeline. No
/// living beings, per the app's content-integrity rules.
enum WirdGlyph { book, minaret, scale, compass, misbaha, scroll, palms }

/// Renders a single [WirdGlyph] as a stroked line-drawing that tints with
/// [color] (defaults to the current gold accent) — the icon used in
/// [HubCard]s, section headers, and nav accents.
class WirdIcon extends StatelessWidget {
  const WirdIcon(this.glyph, {super.key, this.size = 32, this.color, this.strokeWidth = 1.6});

  final WirdGlyph glyph;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WirdGlyphPainter(glyph: glyph, color: tint, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _WirdGlyphPainter extends CustomPainter {
  const _WirdGlyphPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  final WirdGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case WirdGlyph.book:
        _paintBook(canvas, size, paint);
      case WirdGlyph.minaret:
        _paintMinaret(canvas, size, paint);
      case WirdGlyph.scale:
        _paintScale(canvas, size, paint);
      case WirdGlyph.compass:
        _paintCompass(canvas, size, paint);
      case WirdGlyph.misbaha:
        _paintMisbaha(canvas, size, paint);
      case WirdGlyph.scroll:
        _paintScroll(canvas, size, paint);
      case WirdGlyph.palms:
        _paintPalms(canvas, size, paint);
    }
  }

  void _paintBook(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    final spineTop = Offset(w * 0.5, h * 0.18);
    final spineBottom = Offset(w * 0.5, h * 0.82);
    final leftPath = Path()
      ..moveTo(spineTop.dx, spineTop.dy)
      ..quadraticBezierTo(w * 0.08, h * 0.24, w * 0.1, h * 0.5)
      ..quadraticBezierTo(w * 0.08, h * 0.76, spineBottom.dx, spineBottom.dy);
    final rightPath = Path()
      ..moveTo(spineTop.dx, spineTop.dy)
      ..quadraticBezierTo(w * 0.92, h * 0.24, w * 0.9, h * 0.5)
      ..quadraticBezierTo(w * 0.92, h * 0.76, spineBottom.dx, spineBottom.dy);
    canvas
      ..drawPath(leftPath, p)
      ..drawPath(rightPath, p)
      ..drawLine(spineTop, spineBottom, p);
  }

  void _paintMinaret(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    canvas
      ..drawLine(Offset(w * 0.5, h * 0.06), Offset(w * 0.5, h * 0.18), p)
      ..drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.1, height: w * 0.1), p)
      ..drawLine(Offset(w * 0.38, h * 0.32), Offset(w * 0.62, h * 0.32), p)
      ..drawLine(Offset(w * 0.4, h * 0.32), Offset(w * 0.4, h * 0.72), p)
      ..drawLine(Offset(w * 0.6, h * 0.32), Offset(w * 0.6, h * 0.72), p)
      ..drawLine(Offset(w * 0.28, h * 0.72), Offset(w * 0.72, h * 0.72), p)
      ..drawLine(Offset(w * 0.2, h * 0.9), Offset(w * 0.8, h * 0.9), p)
      ..drawLine(Offset(w * 0.28, h * 0.72), Offset(w * 0.2, h * 0.9), p)
      ..drawLine(Offset(w * 0.72, h * 0.72), Offset(w * 0.8, h * 0.9), p);
  }

  void _paintScale(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    final centerTop = Offset(w * 0.5, h * 0.12);
    final beamY = h * 0.28;
    canvas
      ..drawLine(centerTop, Offset(w * 0.5, h * 0.85), p)
      ..drawLine(Offset(w * 0.15, beamY), Offset(w * 0.85, beamY), p)
      ..drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, beamY), p)
      ..drawLine(Offset(w * 0.3, h * 0.85), Offset(w * 0.7, h * 0.85), p);
    // pans
    canvas
      ..drawLine(Offset(w * 0.15, beamY), Offset(w * 0.08, h * 0.45), p)
      ..drawLine(Offset(w * 0.08, h * 0.45), Offset(w * 0.22, h * 0.45), p)
      ..drawLine(Offset(w * 0.22, h * 0.45), Offset(w * 0.15, beamY), p)
      ..drawLine(Offset(w * 0.85, beamY), Offset(w * 0.78, h * 0.45), p)
      ..drawLine(Offset(w * 0.78, h * 0.45), Offset(w * 0.92, h * 0.45), p)
      ..drawLine(Offset(w * 0.92, h * 0.45), Offset(w * 0.85, beamY), p);
  }

  void _paintCompass(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    final center = Offset(w * 0.5, h * 0.5);
    canvas.drawCircle(center, w * 0.4, p);
    final needle = Path()
      ..moveTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.58, h * 0.5)
      ..lineTo(w * 0.5, h * 0.8)
      ..lineTo(w * 0.42, h * 0.5)
      ..close();
    canvas.drawPath(needle, p);
    canvas.drawCircle(center, w * 0.03, p..style = PaintingStyle.fill);
  }

  void _paintMisbaha(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    final center = Offset(w * 0.5, h * 0.48);
    const beadCount = 10;
    for (var i = 0; i < beadCount; i++) {
      final angle = (i / beadCount) * 2 * math.pi;
      final bead = Offset(
        center.dx + w * 0.32 * math.cos(angle),
        center.dy + w * 0.32 * math.sin(angle),
      );
      canvas.drawCircle(bead, w * 0.045, p);
    }
    canvas.drawLine(center, Offset(w * 0.5, h * 0.92), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.92), width: w * 0.08, height: h * 0.1), p);
  }

  void _paintScroll(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    canvas
      ..drawLine(Offset(w * 0.22, h * 0.2), Offset(w * 0.78, h * 0.2), p)
      ..drawLine(Offset(w * 0.22, h * 0.8), Offset(w * 0.78, h * 0.8), p)
      ..drawLine(Offset(w * 0.22, h * 0.2), Offset(w * 0.22, h * 0.8), p)
      ..drawLine(Offset(w * 0.78, h * 0.2), Offset(w * 0.78, h * 0.8), p)
      ..drawArc(Rect.fromCircle(center: Offset(w * 0.14, h * 0.2), radius: w * 0.08), 1.57, 3.14, false, p)
      ..drawArc(Rect.fromCircle(center: Offset(w * 0.14, h * 0.8), radius: w * 0.08), -1.57, 3.14, false, p)
      ..drawArc(Rect.fromCircle(center: Offset(w * 0.86, h * 0.2), radius: w * 0.08), -1.57, -3.14, false, p)
      ..drawArc(Rect.fromCircle(center: Offset(w * 0.86, h * 0.8), radius: w * 0.08), 1.57, -3.14, false, p);
  }

  void _paintPalms(Canvas canvas, Size s, Paint p) {
    final w = s.width, h = s.height;
    // Two cupped palms raised in supplication, drawn as a single symmetric
    // closed "bowl" with a soft V-notch at the top centre where the hands
    // meet — a clean, recognisable dua motif that stays legible at nav size
    // (24px), unlike the earlier detached squiggles.
    final bowl = Path()
      ..moveTo(w * 0.5, h * 0.52) // deep top-centre notch where the palms part
      ..quadraticBezierTo(w * 0.42, h * 0.26, w * 0.24, h * 0.30) // left fingers up to tip
      ..quadraticBezierTo(w * 0.06, h * 0.42, w * 0.5, h * 0.86) // outer-left sweep to wrist
      ..quadraticBezierTo(w * 0.94, h * 0.42, w * 0.76, h * 0.30) // outer-right up to tip
      ..quadraticBezierTo(w * 0.58, h * 0.26, w * 0.5, h * 0.52) // right fingers back to notch
      ..close();
    canvas.drawPath(bowl, p);
  }

  @override
  bool shouldRepaint(covariant _WirdGlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
