import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/achievements/achievements_screen.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets(
      'AchievementsScreen renders badges with category icons and lock overlays',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: AchievementsScreen()),
      ),
    );
    await _settle(tester);

    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('First Steps'), findsOneWidget);
    // All badges start locked — lock icons should be present.
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    // Category-specific icons should appear (e.g. book for Quran).
    expect(find.byIcon(Icons.menu_book_rounded), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
