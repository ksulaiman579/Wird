import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/shared/glass/parchment_painter.dart';

void main() {
  testWidgets('ParchmentPainter renders without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(
          body: CustomPaint(
            painter: ParchmentPainter(),
            child: SizedBox(width: 400, height: 800),
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
  });
}
