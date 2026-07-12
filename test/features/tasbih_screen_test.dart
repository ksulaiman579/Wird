import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/tasbih/tasbih_screen.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('100 preset counts taps and records a session on completion',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: TasbihScreen()),
      ),
    );
    await _settle(tester);

    await tester.tap(find.text('100'));
    await _settle(tester);

    expect(find.text('0 / 100'), findsOneWidget);
    await tester.tap(find.text('Tap anywhere'));
    await _settle(tester);
    expect(find.text('1 / 100'), findsOneWidget);

    for (var i = 0; i < 99; i++) {
      await tester.tap(find.byType(GestureDetector).first);
    }
    await _settle(tester);

    expect(find.textContaining('Complete — 100 / 100'), findsOneWidget);

    final sessions = await db.select(db.tasbihSessions).get();
    expect(sessions.single.completedCount, 100);
    expect(sessions.single.presetLabel, '100');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('classic preset auto-advances through its three stages',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: TasbihScreen()),
      ),
    );
    await _settle(tester);

    await tester.tap(find.textContaining('33 - 33 - 34'));
    await _settle(tester);

    expect(find.text('SubhanAllah'), findsOneWidget);
    for (var i = 0; i < 33; i++) {
      await tester.tap(find.byType(GestureDetector).first);
    }
    await _settle(tester);

    expect(find.text('Alhamdulillah'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
