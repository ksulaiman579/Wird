import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/content/dua_repository.dart';
import 'package:wird/features/dua/dua_categories_screen.dart';
import 'package:wird/features/dua/dua_category_screen.dart';
import 'package:wird/features/dua/dua_group_screen.dart';
import 'package:wird/shared/glass/glass.dart';

import '../test_helpers/file_asset_bundle.dart';

// hisnul_muslim.json is 267KB — see test/test_helpers/file_asset_bundle.dart
// for why this must be pre-warmed outside any testWidgets pump cycle.
final _repository = DuaRepository(bundle: FileAssetBundle());

final _overrides = [duaRepositoryProvider.overrideWithValue(_repository)];

void main() {
  setUpAll(() => _repository.loadCategories());
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'DuaCategoriesScreen shows a time-aware Daily Adhkar card and '
      'circumstance groups', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: DuaCategoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily Adhkar'), findsOneWidget);
    // Whichever period is current (depends on wall-clock time), exactly
    // one of the two adhkar cards renders as the primary card.
    final morning = find.text('Morning adhkar');
    final evening = find.text('Evening adhkar');
    expect(morning.evaluate().length + evening.evaluate().length, 1);
    expect(find.text('Daily routine'), findsOneWidget);
    expect(find.byType(GlassCard), findsWidgets);
  });

  testWidgets('DuaCategoriesScreen search flattens matches across groups',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: DuaCategoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'sleep');
    await tester.pumpAndSettle();

    expect(find.text('By circumstance'), findsNothing);
    expect(
      find.text('What to say before sleeping'),
      findsOneWidget,
    );
  });

  testWidgets('DuaGroupScreen lists the group\'s categories', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: DuaGroupScreen(groupId: 'daily-routine'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily routine'), findsOneWidget);
    expect(find.text('supplications for when you wake up'), findsOneWidget);
  });

  testWidgets('DuaCategoryScreen shows dua cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: DuaCategoryScreen(categoryId: 'hm-cat-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('supplications for when you wake up'), findsOneWidget);
    // Cards are collapsed by default now; the translation appears on expand.
    expect(find.textContaining('resurrection'), findsNothing);
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('resurrection'), findsOneWidget);
  });

  // C2 regression: group titles + occasion/dua counts must localize (they
  // were hardcoded English + RTL-garbled "N occasions"/"N duas" concats).
  testWidgets('DuaCategoriesScreen renders localized group titles in Arabic',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ar'),
          home: DuaCategoriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Arabic group title shows; English source must NOT leak through.
    expect(find.text('الروتين اليومي'), findsOneWidget);
    expect(find.text('Daily routine'), findsNothing);
    // The occasion counter is a localized ICU plural — no raw English word.
    expect(find.textContaining('occasions'), findsNothing);
  });

  testWidgets('DuaGroupScreen localizes title and dua count in Arabic',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ar'),
          home: DuaGroupScreen(groupId: 'daily-routine'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الروتين اليومي'), findsWidgets);
    // "N duas" is a localized ICU plural — the English word must not appear.
    expect(find.textContaining('duas'), findsNothing);
  });

  // The 130 Hisnul Muslim category (chapter header) titles localize from
  // assets/data/dua_title_l10n.json; English must not leak in Arabic.
  testWidgets('DuaGroupScreen localizes category titles in Arabic',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ar'),
          home: DuaGroupScreen(groupId: 'daily-routine'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // hm-cat-1 Arabic header shows; the English title must not.
    expect(find.text('أذكار الاستيقاظ من النوم'), findsOneWidget);
    expect(find.text('supplications for when you wake up'), findsNothing);
  });
}
