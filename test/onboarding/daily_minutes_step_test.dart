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

  testWidgets('Daily minutes step displays slider and presets up to 120 min (2 hr)', (tester) async {
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

    // Step 0: Language -> Step 1: Welcome -> Step 2: Profile -> Step 3: Scope -> Step 4: QuranSelection -> Step 5: DailyMinutes
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('How much time per day?'), findsOneWidget);
    expect(find.text('10 min'), findsWidgets); // Default 10 min

    // Tap preset 60 min (1 hr)
    await tester.tap(find.widgetWithText(ChoiceChip, '1 hr'));
    await tester.pumpAndSettle();

    expect(find.text('1 hr'), findsWidgets);

    // Tap preset 120 min (2 hr)
    await tester.tap(find.widgetWithText(ChoiceChip, '2 hr'));
    await tester.pumpAndSettle();

    expect(find.text('2 hr'), findsWidgets);
  });
}
