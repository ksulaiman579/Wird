import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/core/srs/sm2_scheduler.dart';
import 'package:wird/features/session/review_flow.dart';

const _fatihahItem = SrsItem(
  id: 1,
  contentType: 'quran',
  contentKey: 'q:1:1-2',
  orderIndex: 0,
  wordCount: 8,
  status: 'review',
  easeFactor: 2.5,
  intervalDays: 7,
  repetitions: 1,
  learningStep: 0,
);

void main() {
  testWidgets('hides the text until Reveal, then grades via onGraded',
      (tester) async {
    Grade? gradedWith;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(
            body: ReviewFlow(
              item: _fatihahItem,
              onGraded: (grade) => gradedWith = grade,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1-2'), findsOneWidget);
    expect(find.textContaining('Recall it from memory'), findsOneWidget);
    expect(find.text('Good'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Reveal'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Recall it from memory'), findsNothing);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(gradedWith, Grade.easy);
  });
}
