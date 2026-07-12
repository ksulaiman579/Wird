import 'dart:ui';

/// Whether the readers should show the Latin transliteration and the English
/// translation alongside the Arabic source.
///
/// When the UI language is Arabic, an Arabic reader is reading the source
/// directly, so the transliteration (a Latin pronunciation aid) and the
/// English translation are redundant clutter — hide them. Every other locale
/// keeps them, since the translation is the whole point for a non-Arabic
/// reader. Pure Dart so it can be unit-tested.
bool showLatinReadingAids(Locale locale) => locale.languageCode != 'ar';
