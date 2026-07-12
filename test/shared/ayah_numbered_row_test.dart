import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/shared/widgets/ayah_numbered_row.dart';

void main() {
  testWidgets('AyahNumberedRow displays ayah number badge when provided',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(
          body: AyahNumberedRow(
            ayahNumber: 7,
            child: Text('Arabic Text'),
          ),
        ),
      ),
    );

    expect(find.text('﴿7﴾'), findsOneWidget);
    expect(find.text('Arabic Text'), findsOneWidget);
  });

  testWidgets('AyahNumberedRow renders child directly when ayahNumber is null',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(
          body: AyahNumberedRow(
            ayahNumber: null,
            child: Text('No Ayah Badge'),
          ),
        ),
      ),
    );

    expect(find.text('No Ayah Badge'), findsOneWidget);
  });
}
