import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/app.dart';
import 'package:wird/core/db/database.dart';

void main() {
  testWidgets('App boots to the Today screen with bottom navigation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // A profile must already exist, otherwise the router redirects to
    // onboarding (see test/router_test.dart for that path).
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(name: 'Test', createdAt: DateTime.now()),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const DailyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Quran'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Duas'), findsOneWidget);
    expect(find.text('Al-Manhaj'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    // TodayScreen holds live Drift .watch() stream subscriptions; dispose
    // the widget tree before addTearDown closes the database, or a
    // still-pending stream timer trips flutter_test's leak detector. The
    // cancellation itself schedules a zero-duration Timer, so pump once
    // more to let it actually fire before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
