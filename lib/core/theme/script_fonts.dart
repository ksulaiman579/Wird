import 'package:flutter/material.dart';

/// Bundled fonts for scripts the phone (and, offline, the web app) may not
/// have: Bengali, Devanagari (Hindi), Malayalam, and Nastaliq for Urdu.
/// Used as per-character fallbacks, so Latin text keeps the normal font.
/// Nastaliq is only added for the Urdu UI — Arabic text stays in Naskh.
List<String> scriptFontFallbacks(String languageCode) => [
      if (languageCode == 'ur') 'NotoNastaliqUrdu',
      'NotoSansBengali',
      'NotoSansDevanagari',
      'NotoSansMalayalam',
    ];

/// [theme] with the script fallbacks applied to every text style.
ThemeData withScriptFonts(ThemeData theme, String languageCode) {
  final fallbacks = scriptFontFallbacks(languageCode);
  TextTheme apply(TextTheme t) => t.apply(fontFamilyFallback: fallbacks);
  return theme.copyWith(
    textTheme: apply(theme.textTheme),
    primaryTextTheme: apply(theme.primaryTextTheme),
  );
}
