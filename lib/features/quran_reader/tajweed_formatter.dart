import 'package:flutter/material.dart';

/// Formats Uthmanic Hafs Arabic text with Tajweed highlights and color-coded
/// waqf (stop) signs (Item 5.4).
class TajweedTextFormatter {
  static const _waqfMandatory = '\u06D8'; // ۘ
  static const _waqfPermissible = '\u06DA'; // ۚ
  static const _waqfContinuePref = '\u06D6'; // ۖ
  static const _waqfStopPref = '\u06D7'; // ۗ
  static const _waqfNoStop = '\u06D9'; // ۙ
  static const _waqfThreeDots = '\u06DB'; // ۛ
  static const _sajdahMark = '\u06E9'; // ۩

  static bool isWaqfMark(String char) {
    return char == _waqfMandatory ||
        char == _waqfPermissible ||
        char == _waqfContinuePref ||
        char == _waqfStopPref ||
        char == _waqfNoStop ||
        char == _waqfThreeDots ||
        char == _sajdahMark;
  }

  static Color? getWaqfColor(String char) {
    switch (char) {
      case _waqfMandatory:
        return Colors.redAccent;
      case _waqfPermissible:
        return Colors.orangeAccent;
      case _waqfStopPref:
        return Colors.amber;
      case _waqfContinuePref:
        return Colors.green;
      case _waqfNoStop:
        return Colors.blueAccent;
      case _waqfThreeDots:
        return Colors.purpleAccent;
      case _sajdahMark:
        return Colors.teal;
      default:
        return null;
    }
  }

  /// Formats Arabic string into styled [TextSpan]s.
  static TextSpan format(
    String arabic, {
    required double fontSize,
    Color? baseColor,
    required bool enabled,
    double height = 2.0,
  }) {
    final baseStyle = TextStyle(
      fontFamily: 'UthmanicHafs',
      fontSize: fontSize,
      height: height,
      color: baseColor,
    );

    if (!enabled) {
      return TextSpan(text: arabic, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final buffer = StringBuffer();

    for (var i = 0; i < arabic.length; i++) {
      final char = arabic[i];

      if (isWaqfMark(char)) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }
        final waqfColor = getWaqfColor(char);
        spans.add(
          TextSpan(
            text: char,
            style: baseStyle.copyWith(
              color: waqfColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (char == '\u06E4' || char == '\u0653') {
        // Madd elongation mark
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
          buffer.clear();
        }
        spans.add(
          TextSpan(
            text: char,
            style: baseStyle.copyWith(color: Colors.cyan),
          ),
        );
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: baseStyle));
    }

    return TextSpan(children: spans, style: baseStyle);
  }
}
