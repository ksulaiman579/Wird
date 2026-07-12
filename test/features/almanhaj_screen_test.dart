import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/features/almanhaj/almanhaj_screen.dart';

void main() {
  testWidgets(
      'shows the coming-soon hero (no sign-in) and the support section',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: AlManhajScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Al-Manhaj'), findsWidgets);
    expect(find.textContaining('coming soon'), findsWidgets);

    // Accounts are offline-only (Item 1.26): no sign-in affordance at all.
    expect(find.textContaining('Sign in'), findsNothing);

    expect(find.text('Support this project'), findsOneWidget);
    expect(find.text('PayPal'), findsOneWidget);
    expect(find.text('Buy Me a Coffee'), findsOneWidget);
  });
}
