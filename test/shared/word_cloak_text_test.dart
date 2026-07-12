import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/shared/widgets/word_cloak_text.dart';

void main() {
  testWidgets('WordCloakText tap-to-reveal reveals cloaked word',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        home: Scaffold(
          body: WordCloakText(
            text: 'Bismillah Ar-Rahman Ar-Raheem',
            revealedIndices: {}, // All cloaked
          ),
        ),
      ),
    );

    // Initially no words are visible text
    expect(find.text('Bismillah'), findsNothing);

    // Tap the first cloaked box
    final firstBox = find.byType(Container).first;
    await tester.tap(firstBox);
    await tester.pumpAndSettle();

    // Now first word is revealed
    expect(find.text('Bismillah'), findsOneWidget);
  });

  testWidgets('advancing to a stricter stage re-cloaks tap-revealed words',
      (tester) async {
    // Simulates the fade steps reusing one WordCloakText state: hint stage
    // reveals index 0, the user taps another word, then the stage advances
    // to fully-hidden ({}) — the tapped word must disappear (Item 1.6).
    Widget build(Set<int> revealed) => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(
            body: WordCloakText(
              text: 'Bismillah Ar-Rahman Ar-Raheem',
              revealedIndices: revealed,
            ),
          ),
        );

    await tester.pumpWidget(build(const {0})); // hint: first word shown
    expect(find.text('Bismillah'), findsOneWidget);

    // Tap a still-cloaked box to locally reveal another word.
    await tester.tap(find.byType(Container).first);
    await tester.pumpAndSettle();
    expect(find.text('Ar-Rahman'), findsOneWidget);

    // Advance to fully hidden — no word should remain visible.
    await tester.pumpWidget(build(const {}));
    await tester.pumpAndSettle();
    expect(find.text('Bismillah'), findsNothing);
    expect(find.text('Ar-Rahman'), findsNothing);
    expect(find.text('Ar-Raheem'), findsNothing);
  });
}
