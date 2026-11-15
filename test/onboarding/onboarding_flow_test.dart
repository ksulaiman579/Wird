import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/content/dua_repository.dart';
import 'package:wird/core/content/hadith_pack_repository.dart';
import 'package:wird/core/content/hadith_repository.dart';
import 'package:wird/core/content/quran_repository.dart';
import 'package:wird/core/content/translation_pack_service.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/onboarding/onboarding_screen.dart';

import '../test_helpers/file_asset_bundle.dart';

/// Fake http client that fails every request — the fire-and-forget pack
/// downloads kicked off by Finish must never block onboarding completion.
class _FailingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value(utf8.encode('down')), 500);
  }
}

// Pre-warmed outside testWidgets pump cycles — see file_asset_bundle.dart.
// The db + translation service are also created/warmed in setUpAll: a raw
// `await` on real file IO INSIDE a testWidgets body deadlocks against the
// fake-async zone (that's what M21.3's first repro attempt hung on).
final _quranRepo = QuranRepository(bundle: FileAssetBundle());
final _hadithRepo = HadithRepository(bundle: FileAssetBundle());
final _duaRepo = DuaRepository(bundle: FileAssetBundle());
late AppDatabase _db;
late TranslationPackService _translationService;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  setUpAll(() async {
    // Whole-Quran onboarding loads meta + all 114 surahs inside complete();
    // warm them all here so the widget-test zone never does big reads.
    final meta = await _quranRepo.loadMeta();
    for (final s in meta.surahs) {
      await _quranRepo.loadSurah(s.number);
    }
    await _hadithRepo.loadAll();
    await _duaRepo.loadAdhkar();

    _db = AppDatabase(NativeDatabase.memory());
    _translationService = TranslationPackService(_db, bundle: FileAssetBundle());
    await _translationService.loadAllowlist();
  });

  tearDownAll(() => _db.close());

  // Pre-mark the M22.6 first-boot disclaimer as seen so its modal doesn't
  // sit over the flow this test drives.
  setUp(() => SharedPreferences.setMockInitialValues(
        {'offline_disclaimer_seen': true},
      ));

  testWidgets(
      'three-step onboarding reaches the home route (M21.3 regression)', (tester) async {
    // Tall viewport so the whole final step (search field, hadith pills,
    // Skip button) is on screen without fighting the nested scrollables.
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;

    final db = _db;
    final translationService = _translationService;

    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const Text('HOME')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          quranRepositoryProvider.overrideWithValue(_quranRepo),
          hadithRepositoryProvider.overrideWithValue(_hadithRepo),
          duaRepositoryProvider.overrideWithValue(_duaRepo),
          translationPackServiceProvider.overrideWithValue(translationService),
          hadithPackRepositoryProvider.overrideWithValue(
            HadithPackRepository(db, client: _FailingClient()),
          ),
        ],
        child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: router),
      ),
    );
    await _settle(tester);

    // Step 0: Language selection before onboarding starts
    expect(find.text('Select language'), findsOneWidget);

    // Language -> What to memorise (whole Quran by default) -> Daily time.
    for (var step = 0; step < 2; step++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await _settle(tester);
    }
    expect(find.text('How much time per day?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.text('HOME').evaluate().isNotEmpty) break;
    }
    expect(find.text('HOME'), findsOneWidget);

    final profiles = await db.select(db.userProfiles).get();
    expect(profiles, hasLength(1));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
