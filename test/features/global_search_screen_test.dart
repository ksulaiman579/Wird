import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/search/search_index.dart';
import 'package:wird/core/search/search_index_builder.dart';
import 'package:wird/features/explore/global_search_screen.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

void main() {
  final index = SearchIndex([
    SearchDoc(
      kind: SearchKind.ayah,
      route: '/read?surah=2&ayah=255',
      title: 'Al-Baqarah 2:255',
      arabic: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُ',
      text: 'Allah - there is no deity except Him, the Ever-Living',
    ),
    SearchDoc(
      kind: SearchKind.hadith,
      route: '/hadith/nawawi/1',
      title: 'Actions Are Judged by Intentions',
    ),
  ]);

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [searchIndexProvider.overrideWith((ref) async => index)],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GlobalSearchScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Arabic typed without diacritics finds the ayah', (t) async {
    await pump(t);
    await t.enterText(find.byType(TextField), 'الحي القيوم');
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    expect(find.text('Al-Baqarah 2:255'), findsOneWidget);
    expect(find.text('Actions Are Judged by Intentions'), findsNothing);
  });

  testWidgets('the Hadith filter hides Quran results', (t) async {
    await pump(t);
    await t.enterText(find.byType(TextField), 'a');
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.widgetWithText(ChoiceChip, 'Hadith'));
    await t.pumpAndSettle();
    expect(find.text('Al-Baqarah 2:255'), findsNothing);
    expect(find.text('Actions Are Judged by Intentions'), findsOneWidget);
  });

  testWidgets('no match shows a message', (t) async {
    await pump(t);
    await t.enterText(find.byType(TextField), 'zzzzzz');
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    expect(find.text('No results'), findsOneWidget);
  });
}
