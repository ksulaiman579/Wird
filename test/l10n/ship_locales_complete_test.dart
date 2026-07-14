import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the "ship locales are fully localized" invariant (the plan's
/// definition-of-done for localization). Fails if any shipped locale has a
/// user-facing English string that isn't in [allowVerbatim] — so a newly added
/// English key can't silently ship untranslated.
///
/// This is a regression FLOOR, not a quality check; the real quality gate is
/// the mandatory every-menu/every-locale walkthrough. Borderline entries in
/// the allowlist (e.g. quranMedinan) are flagged for that walkthrough.
void main() {
  // en is the template; ar+the 5 are the shipped display languages.
  const shipLocales = ['ar', 'ur', 'hi', 'bn', 'ml', 'fil'];

  // Intentionally identical to English: brand/Islamic proper nouns,
  // transliterations, pure-placeholder strings, and Tagalog loanwords.
  const allowVerbatim = <String>{
    'achievementProgress', 'alManhajTitle', 'appTitle', 'commonExplore',
    'commonJuzN', 'commonMinutesShort', 'commonSurahN', 'commonSurahWord',
    'durationHr', 'durationHrMin', 'durationMin', 'hadithCollectionNawawi',
    'hadithNumbered', 'navAlManhaj', 'navHadith', 'prayerAsr', 'prayerDhuhr',
    'prayerFajr', 'prayerIsha', 'prayerMaghrib', 'progressDuas',
    'progressHadith', 'qiblaTitle', 'quranMedinan', 'tasbihTitle',
    'themeAmoled', 'todayGreeting', 'todayGreetingNamed', 'zakahCatRikaz',
    'zakahRikazDue', 'zakahShort',
  };

  final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final enStr = <String, String>{
    for (final e in en.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
  final hasWords = RegExp(r'[A-Za-z]{3,}'); // skip pure-symbol/number strings

  for (final loc in shipLocales) {
    test('$loc: every user-facing string is translated (or intentionally verbatim)', () {
      final d = jsonDecode(File('lib/l10n/app_$loc.arb').readAsStringSync())
          as Map<String, dynamic>;
      final untranslated = <String>[];
      enStr.forEach((k, v) {
        if (allowVerbatim.contains(k)) return;
        if (hasWords.hasMatch(v) && d[k] == v) untranslated.add(k);
      });
      expect(untranslated, isEmpty,
          reason: '$loc still English for: $untranslated');
    });
  }
}
