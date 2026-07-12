import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/features/session/celebration_screen.dart';

void main() {
  testWidgets('shows the streak count and calls onContinue when tapped',
      (tester) async {
    var continued = false;

    await tester.pumpWidget(MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
      home: CelebrationScreen(
        streakCount: 12,
        onContinue: () => continued = true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('12-day streak'), findsOneWidget);
    expect(find.textContaining('complete'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();

    expect(continued, true);
  });
}
