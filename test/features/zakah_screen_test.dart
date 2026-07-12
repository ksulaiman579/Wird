import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/features/zakah/zakah_screen.dart';

Future<void> _settle(WidgetTester tester) => tester.pumpAndSettle();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: ZakahScreen()));
    await _settle(tester);
  }

  testWidgets('monetary category: enter prices + cash → 2.5% due',
      (tester) async {
    await pump(tester);

    await tester.enterText(
        find.widgetWithText(TextField, 'Gold price / gram'), '80');
    await tester.enterText(
        find.widgetWithText(TextField, 'Silver price / gram'), '1');
    await tester.enterText(
        find.widgetWithText(TextField, 'Cash & savings'), '700');
    await _settle(tester);

    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Monetary Zakah (2.5%)'), findsOneWidget);
    // 700 cash, no liabilities, USD default → $17.50
    expect(find.text(r'$17.50'), findsOneWidget);
  });

  testWidgets('gold nisab basis can push the same wealth below nisab',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('Gold (85g)'));
    await _settle(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Gold price / gram'), '80');
    await tester.enterText(
        find.widgetWithText(TextField, 'Silver price / gram'), '1');
    await tester.enterText(
        find.widgetWithText(TextField, 'Cash & savings'), '700');
    await _settle(tester);

    expect(find.text('Below nisab — nothing due'), findsOneWidget);
  });

  testWidgets('rikaz category shows a 20% line', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Rikaz'));
    await _settle(tester);
    await tester.enterText(
        find.widgetWithText(TextField, 'Value of the find'), '1000');
    await _settle(tester);

    expect(find.text('Rikaz (20%)'), findsOneWidget);
    expect(find.text(r'$200.00'), findsOneWidget);
  });
}
