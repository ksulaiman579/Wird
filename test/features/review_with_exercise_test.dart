import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/hadith_repository.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/session/review_with_exercise.dart';

import '../test_helpers/file_asset_bundle.dart';

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

const _hadithItem = SrsItem(
  id: 2,
  contentType: 'hadith',
  contentKey: 'h:nawawi:1',
  orderIndex: 0,
  wordCount: 20,
  status: 'review',
  easeFactor: 2.5,
  intervalDays: 7,
  repetitions: 1,
  learningStep: 0,
);

// Pre-warmed outside of any `testWidgets` pump cycle — see
// test/test_helpers/file_asset_bundle.dart: this environment's
// `testWidgets` zone never lets a real disk read above ~40-50KB complete.
final _hadithRepository = HadithRepository(bundle: FileAssetBundle());

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        hadithRepositoryProvider.overrideWithValue(_hadithRepository),
      ],
      child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: child)),
    ),
  );
}

void main() {
  setUpAll(() => _hadithRepository.loadAll());

  testWidgets('skips the exercise for non-quran items', (tester) async {
    await _pump(
      tester,
      ReviewWithExercise(item: _hadithItem, onGraded: (_) {}),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Recall it from memory'), findsOneWidget);
  });

  // Regression note: this environment's pumpAndSettle hangs indefinitely if
  // a quran review item mounts in its own separate testWidgets block right
  // after another one in the same file (same category of gotcha as M4.2's
  // SurahScreen double-mount hang — root cause never fully identified).
  // Both quran cases are merged into one testWidgets block as a pragmatic
  // fix, matching that precedent.
  testWidgets(
      'skips the exercise on a skip day; shows+resolves the first-letter '
      'exercise on another day', (tester) async {
    await _pump(
      tester,
      ReviewWithExercise(
        item: _fatihahItem,
        onGraded: (_) {},
        now: DateTime(2026, 1, 2),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Recall it from memory'), findsOneWidget);

    await _pump(
      tester,
      ReviewWithExercise(
        item: _fatihahItem,
        onGraded: (_) {},
        now: DateTime(2026, 1, 6),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recall the ayah from these first letters'), findsOneWidget);
    expect(find.textContaining('Recall it from memory'), findsNothing);

    await tester.tap(find.text('Show full text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Recall it from memory'), findsOneWidget);
  });
}
