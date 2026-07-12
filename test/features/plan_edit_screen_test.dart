import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/settings/plan_edit_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            quranSelectionType: const Value('surahs'),
            quranSelectionJson: const Value('[1]'),
            dailyMinutes: 20,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  });

  tearDown(() => db.close());

  testWidgets('loads the current plan and saves an edited daily-minutes value',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: PlanEditScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Surah 1'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '20 min'), findsOneWidget);

    await tester.ensureVisible(find.text('30 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1))).getSingle();
    expect(plan.dailyMinutes, 30);
  });
}
