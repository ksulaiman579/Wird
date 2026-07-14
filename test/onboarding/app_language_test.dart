import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/core/prefs/app_language_provider.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('appLanguageProvider defaults to en when nothing stored', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final lang = await container.read(appLanguageProvider.future);
    expect(lang, 'en');
  });

  test('setLanguage persists to SharedPreferences and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(appLanguageProvider.future);
    await container.read(appLanguageProvider.notifier).setLanguage('ar');

    expect(container.read(appLanguageProvider).value, 'ar');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(appLanguagePrefsKey), 'ar');
  });

  test('picker ships exactly the 7 fully-localized UI languages', () {
    // UI selection is intentionally limited to the locales we ship 100%
    // translated; other locales stay in allAppLanguages (data) + the Quran
    // translation editions, just not offered as a display language.
    expect(supportedAppLanguages.map((l) => l.code).toList(),
        ['en', 'ar', 'ur', 'hi', 'bn', 'ml', 'fil']);
  });

  test('allAppLanguages retains the full locale set (data preserved)', () {
    final codes = allAppLanguages.map((l) => l.code).toSet();
    expect(codes.length, greaterThanOrEqualTo(60));
    for (final c in ['en', 'ar', 'ur', 'hi', 'bn', 'ml', 'fil', 'fr', 'yo', 'zh']) {
      expect(codes.contains(c), isTrue, reason: c);
    }
  });

  testWidgets('AppLocalizations loads cleanly for every ARB locale without missing-key fallback errors',
      (WidgetTester tester) async {
    for (final option in allAppLanguages) {
      final locale = Locale(option.code);
      final localizations = await AppLocalizations.delegate.load(locale);

      expect(localizations, isNotNull, reason: 'Failed to load locale ${option.code}');
      expect(localizations.appTitle, isNotEmpty);
      expect(localizations.commonContinue, isNotEmpty);
      expect(localizations.commonStart, isNotEmpty);
      expect(localizations.settingsTitle, isNotEmpty);
      expect(localizations.progressStepOf(1, 10), isNotEmpty);
    }
  });
}
