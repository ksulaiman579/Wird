import 'package:flutter/widgets.dart';

/// Arabic punctuation the Quran font (UthmanicHafs) draws as ornaments:
/// its glyph for the Arabic comma is a ring like an ayah marker, which made
/// every comma in hadith and dua text look like a verse end (audit WQA-009).
final _punctuation = RegExp('[،؛؟]'); // ، ؛ ؟

/// Splits [text] so only the punctuation marks fall back to the system
/// font; the words keep [style] (UthmanicHafs). The text itself is never
/// changed.
List<InlineSpan> arabicProseSpans(String text, TextStyle? style) {
  final spans = <InlineSpan>[];
  var start = 0;
  final markStyle = (style ?? const TextStyle()).copyWith(fontFamily: 'Roboto');
  for (final m in _punctuation.allMatches(text)) {
    if (m.start > start) spans.add(TextSpan(text: text.substring(start, m.start)));
    spans.add(TextSpan(text: m.group(0), style: markStyle));
    start = m.end;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return spans;
}

/// Drop-in for `Text(arabic, style: ...)` on non-Quran Arabic (hadith,
/// duas, adhkar): same look, normal commas.
class ArabicProseText extends StatelessWidget {
  const ArabicProseText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textDirection,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(style: style, children: arabicProseSpans(text, style)),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        textDirection: textDirection,
      );
}
