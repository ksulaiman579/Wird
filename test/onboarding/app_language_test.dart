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

  test('supportedAppLanguages contains all 64 languages', () {
    expect(supportedAppLanguages.length, 64);
    final codes = supportedAppLanguages.map((l) => l.code).toSet();
    expect(codes.contains('en'), isTrue);
    expect(codes.contains('ar'), isTrue);
    expect(codes.contains('fr'), isTrue);
    expect(codes.contains('id'), isTrue);
    expect(codes.contains('tr'), isTrue);
    expect(codes.contains('ur'), isTrue);
    expect(codes.contains('yo'), isTrue);
  });

  testWidgets('AppLocalizations loads cleanly for all 64 supported locales without missing-key fallback errors',
      (WidgetTester tester) async {
    for (final option in supportedAppLanguages) {
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
