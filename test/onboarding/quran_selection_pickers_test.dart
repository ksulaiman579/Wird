import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/content/quran_repository.dart';
import 'package:wird/features/onboarding/onboarding_screen.dart';

import '../test_helpers/file_asset_bundle.dart';

void main() {
  late QuranRepository quranRepo;

  setUpAll(() async {
    quranRepo = QuranRepository(bundle: FileAssetBundle());
    await quranRepo.loadMeta();
  });

  testWidgets('Juz modal picker opens and updates selectedJuz', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranRepositoryProvider.overrideWithValue(quranRepo),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(
            body: OnboardingScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: Language -> Step 1: Welcome -> Step 2: Profile -> Step 3: Scope -> Step 4: QuranSelection
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }

    // Now on Quran selection step
    expect(find.text('How much of the Quran?'), findsOneWidget);

    // Tap Specific juz (para)
    await tester.tap(find.text('Specific juz (para)'));
    await tester.pumpAndSettle();

    expect(find.text('Select juz (para)…'), findsOneWidget);

    // Tap button to open dialog
    await tester.tap(find.text('Select juz (para)…'));
    await tester.pumpAndSettle();

    expect(find.text('Juz 1'), findsOneWidget);

    // Check Juz 1
    await tester.tap(find.text('Juz 1'));
    await tester.pumpAndSettle();

    // Tap Done
    await tester.tap(find.textContaining('Done (1)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Selected juz (1/30)'), findsOneWidget);
  });

  testWidgets('Surah modal picker opens and updates selectedSurahs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          quranRepositoryProvider.overrideWithValue(quranRepo),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(
            body: OnboardingScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Step 0: Language -> Step 1: Welcome -> Step 2: Profile -> Step 3: Scope -> Step 4: QuranSelection
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }

    // Tap Specific surahs
    await tester.tap(find.text('Specific surahs'));
    await tester.pumpAndSettle();

    expect(find.text('Select surahs…'), findsOneWidget);

    // Tap button to open dialog
    await tester.tap(find.text('Select surahs…'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1. Al-Fatiha'), findsOneWidget);

    // Check Surah 1
    await tester.tap(find.textContaining('1. Al-Fatiha'));
    await tester.pumpAndSettle();

    // Tap Done
    await tester.tap(find.textContaining('Done (1)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Selected surahs (1/114)'), findsOneWidget);
  });
}
