import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/progress/progress_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('shows streak/day stats and per-surah coverage bars', (
    tester,
  ) async {
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            dailyMinutes: 30,
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        );
    await db.into(db.streakState).insert(
          StreakStateCompanion.insert(
            id: const Value(1),
            currentStreak: const Value(3),
            longestStreak: const Value(8),
          ),
        );
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: 'completed-day',
            newItemsPlanned: 1,
            reviewsPlanned: 0,
            completed: const Value(true),
          ),
        );
    // Al-Fatihah is 7 ayahs — memorizing ayahs 1-5 gives a partial bar.
    await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:1:1-5',
            orderIndex: 0,
            wordCount: 20,
            status: const Value('review'),
            introducedAt: Value(DateTime.now()),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget); // current streak
    expect(find.text('8'), findsOneWidget); // longest streak
    expect(find.text('1'), findsOneWidget); // days consistent total
    expect(find.text('5'), findsOneWidget); // ayahs memorized

    // The overall Quran bar shows up front; the per-surah bars are collapsed
    // under it until the "Quran" tile is expanded (Item 1.22).
    expect(find.text('Quran'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsNothing);

    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('71%'), findsOneWidget); // 5/7 rounded
  });
}
