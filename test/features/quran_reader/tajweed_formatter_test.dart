import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/features/quran_reader/tajweed_formatter.dart';

void main() {
  test('TajweedTextFormatter returns single span when disabled', () {
    const arabic = 'بِسْمِ ٱللَّهِۘ';
    final span = TajweedTextFormatter.format(
      arabic,
      fontSize: 24,
      enabled: false,
    );
    expect(span.text, 'بِسْمِ ٱللَّهِۘ');
    expect(span.children, isNull);
  });

  test('TajweedTextFormatter highlights mandatory waqf sign in red Accent', () {
    const arabic = 'بِسْمِ ٱللَّهِۘ';
    final span = TajweedTextFormatter.format(
      arabic,
      fontSize: 24,
      enabled: true,
    );

    expect(span.children, isNotNull);
    // Find the child span for the stop mark
    final waqfSpan = span.children!.last as TextSpan;
    expect(waqfSpan.text, 'ۘ');
    expect(waqfSpan.style?.color, Colors.redAccent);
  });
}
