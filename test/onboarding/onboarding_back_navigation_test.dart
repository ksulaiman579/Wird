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

  testWidgets('Back button navigates to previous onboarding screen', (tester) async {
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

    // Step 0: Language step - back button should not be present
    expect(find.byTooltip('Back'), findsNothing);

    // Tap Next to go to Step 1: Welcome step
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);

    // Tap Back button to return to Step 0: Language step
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Select language'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
  });
}
