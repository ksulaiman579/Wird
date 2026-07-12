import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('first-boot offline disclaimer shows once, then is dismissed',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: OnboardingScreen()),
      ),
    );
    await tester.pump(); // let the post-frame callback fire
    await tester.pump();

    expect(find.text('Welcome — a quick note'), findsWidgets);
    expect(find.textContaining('fully offline'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Got it'));
    await tester.pumpAndSettle();

    // Dialog dismissed and won't show again (flag persisted).
    expect(find.widgetWithText(FilledButton, 'Got it'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('offline_disclaimer_seen'), isTrue);
  });
}
