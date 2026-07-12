import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The ornamental ayah-number medallion from the mushaf renders (M23.5): a
/// gold eight-point star outline enclosing the verse number, hand-drawn
/// with a [CustomPainter] so it needs no glyph asset. Used as the verse
/// marker in the Quran reader.
class VerseRoundel extends StatelessWidget {
  const VerseRoundel({
    super.key,
    required this.number,
    this.size = 34,
    this.color,
  });

  final int number;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(tint),
        child: Center(
          // FittedBox lets multi-digit numbers (e.g. Bukhari #7563) shrink to
          // fit the star instead of overflowing, while 1–2 digit verse/hadith
          // numbers still render at the natural size.
          child: Padding(
            padding: EdgeInsets.all(size * 0.22),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$number',
                textAlign: TextAlign.center,
                // height 1.0 removes the font's default line-leading so the
                // digit sits truly centred inside the star (Item 1.4).
                style: TextStyle(
                  fontSize: size * 0.32,
                  height: 1.0,
                  fontWeight: FontWeight.w600,
                  color: tint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.46;
    final inner = size.width * 0.36;
    // Two overlaid squares rotated 45° read as an eight-point star — the
    // classic Islamic khatam motif — without tracing 16 vertices.
    for (final rot in [0.0, math.pi / 4]) {
      final path = Path();
      for (var i = 0; i < 4; i++) {
        final a = rot + i * math.pi / 2;
        final p = Offset(
          center.dx + outer * math.cos(a),
          center.dy + outer * math.sin(a),
        );
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(center, inner, paint..strokeWidth = 0.8);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}
