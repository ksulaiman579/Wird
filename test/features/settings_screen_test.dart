import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            quranSelectionType: const Value('whole'),
            quranSelectionJson: const Value('[]'),
            dailyMinutes: 20,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  });

  tearDown(() => db.close());

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        routerConfig: GoRouter(
          initialLocation: '/settings',
          routes: [
            GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          ],
        ),
      ),
    );
  }

  // A tall viewport avoids depending on ListView's own virtualization/scroll
  // behavior to get every section built — same rationale as
  // hadith_test.dart's HadithDetailScreen test.
  void useTallViewport(WidgetTester tester) {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets('renders plan, reciter, theme, prayer, backup, and reset sections',
      (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Edit Quran plan'), findsOneWidget);
    expect(find.text('Reciter'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Export my data'), findsOneWidget);
    expect(find.text('Reset Quran'), findsOneWidget);
    expect(find.text('Reset everything'), findsOneWidget);
    expect(find.text('About & data sources'), findsOneWidget);

    // SettingsScreen holds a live Drift .watch() stream subscription
    // (userPlanStreamProvider); dispose the tree before tearDown closes the
    // database, or a still-pending stream-cancellation Timer trips
    // flutter_test's leak detector and hangs the next test — same gotcha
    // documented in router_test.dart.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('double-confirmation is required before a reset actually runs',
      (tester) async {
    useTallViewport(tester);
    await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:1:1-2',
            orderIndex: 0,
            wordCount: 8,
            status: const Value('review'),
          ),
        );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset Quran'));
    await tester.pumpAndSettle();
    expect(find.text('Reset Quran progress?'), findsOneWidget);

    // Cancelling the first dialog must not touch the data.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    final untouched = await db.select(db.srsItems).getSingle();
    expect(untouched.status, 'review');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
