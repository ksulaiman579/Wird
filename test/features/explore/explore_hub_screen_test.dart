import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/features/explore/explore_hub_screen.dart';

void main() {
  testWidgets('ExploreHubScreen renders updated titles, palms icon, and correct section headers',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: ExploreHubScreen(),
      ),
    );

    expect(find.text('Duas & Adhkar'), findsOneWidget);
    expect(find.text('Daily Adhkar'), findsOneWidget);
    expect(find.text('Dua Collections'), findsOneWidget);
    expect(find.text('Supplications by Circumstance'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text("Find the direction to the Ka'bah"), findsOneWidget);
  });
}
