import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/features/asma/asma_screen.dart';

void main() {
  test('bundled asma_ul_husna.json has all 99 names with non-empty fields', () {
    final raw =
        File('assets/data/asma_ul_husna.json').readAsStringSync();
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    expect(list.length, 99);
    for (var i = 0; i < list.length; i++) {
      final n = AsmaName.fromJson(list[i]);
      expect(n.number, i + 1);
      expect(n.arabic.trim(), isNotEmpty);
      expect(n.transliteration.trim(), isNotEmpty);
      expect(n.meaning.trim(), isNotEmpty);
      expect(n.explanation.trim(), isNotEmpty);
    }
  });

  testWidgets('AsmaScreen lists names and filters by search', (tester) async {
    const names = [
      AsmaName(
        number: 1,
        arabic: 'الرحمن',
        transliteration: 'Ar-Rahman',
        meaning: 'The Most Gracious',
        explanation: 'All-encompassing mercy.',
      ),
      AsmaName(
        number: 2,
        arabic: 'الرحيم',
        transliteration: 'Ar-Rahim',
        meaning: 'The Most Merciful',
        explanation: 'Special mercy for the believers.',
      ),
      AsmaName(
        number: 3,
        arabic: 'الملك',
        transliteration: 'Al-Malik',
        meaning: 'The King',
        explanation: 'Absolute sovereign.',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          asmaNamesProvider.overrideWith((ref) async => names),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: AsmaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ar-Rahman'), findsOneWidget);
    expect(find.text('Al-Malik'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'king');
    await tester.pumpAndSettle();

    expect(find.text('Al-Malik'), findsOneWidget);
    expect(find.text('Ar-Rahman'), findsNothing);
  });
}
