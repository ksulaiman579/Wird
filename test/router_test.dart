import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/router.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('redirects to onboarding when there is no local profile', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: Consumer(
          builder: (context, ref, _) =>
              MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: ref.watch(routerProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Onboarding now opens on the language-picker step (added for the
    // pre-onboarding language selection); the welcome step follows it.
    expect(find.text('Select language'), findsOneWidget);
  });

  testWidgets('stays on Today when a profile already exists', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(name: 'Test', createdAt: DateTime.now()),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: Consumer(
          builder: (context, ref, _) =>
              MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: ref.watch(routerProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Welcome to Wird'), findsNothing);

    // TodayScreen holds live Drift .watch() stream subscriptions; dispose
    // the widget tree (and with it, Riverpod's ProviderScope + those
    // subscriptions) before addTearDown closes the database, or a
    // still-pending stream timer trips flutter_test's leak detector. The
    // cancellation itself schedules a zero-duration Timer, so pump once
    // more to let it actually fire before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
