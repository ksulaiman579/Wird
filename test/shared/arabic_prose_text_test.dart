import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/shared/ui/arabic_prose_text.dart';

// Audit WQA-009: commas drawn by the Quran font looked like ayah markers.
void main() {
  test('only Arabic punctuation gets the fallback font; text is unchanged', () {
    const text = 'حَدَّثَنَا وَكِيعٌ، عَنْ كَهْمَسٍ؛ قَالَ؟';
    const style = TextStyle(fontFamily: 'UthmanicHafs');
    final spans = arabicProseSpans(text, style).cast<TextSpan>();
    expect(spans.map((s) => s.text).join(), text);
    final marks = spans.where((s) => s.style?.fontFamily == 'Roboto');
    expect(marks.map((s) => s.text), ['،', '؛', '؟']);
  });

  test('text without punctuation is a single span', () {
    expect(arabicProseSpans('بِسْمِ اللَّهِ', null), hasLength(1));
  });
}
