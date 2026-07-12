import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// C4 gate (committed regression guard). The pre-audit failure mode was that
/// screens showed raw English while the locale was Arabic — an English
/// fallback leaking through because a string was never localized. Arabic is
/// authored 100% (the reference non-English locale), so for a curated
/// sentinel set spanning every major screen its value must be present and
/// must NOT equal the English source. If a future edit re-hardcodes a string
/// or drops the Arabic translation, one of these fails loudly.
///
/// (Full 63/63 coverage is enforced separately by tool/audit_translations.py
/// once the remaining locales are filled; this test guards the en↔ar spine
/// that ships today.)
void main() {
  Map<String, dynamic> loadArb(String lang) => jsonDecode(
        File('lib/l10n/app_$lang.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  test('Arabic has no English fallback for sentinel screen keys', () {
    final en = loadArb('en');
    final ar = loadArb('ar');

    // Representative keys across onboarding, home, hubs, reader, hadith,
    // duas, tools, settings, search — the surfaces the audit found leaking.
    const sentinel = <String>[
      'obPreparingPlan',
      'todayMyProgress',
      'todayKeyInsights',
      'exploreTitle',
      'moreYourJourney',
      'quranHubTitle',
      'duasByCircumstance',
      'duaGroupDailyRoutine',
      'duaGroupPrayer',
      'duaGroupIllnessDeath',
      'hadithNawawiTitle',
      'zakahTitle',
      'namesOfAllahTitle',
      'knowledgeLibraryTitle',
      'achievementsTitle',
      'settingsTitle',
      'searchTitle',
      'locationTitle',
    ];

    final missing = <String>[];
    final untranslated = <String>[];
    for (final key in sentinel) {
      final arValue = ar[key];
      if (arValue == null) {
        missing.add(key);
      } else if (arValue == en[key]) {
        untranslated.add(key);
      }
    }

    expect(missing, isEmpty, reason: 'Missing from app_ar.arb: $missing');
    expect(untranslated, isEmpty,
        reason: 'English fallback leaking in Arabic: $untranslated');
  });
}
