import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/hadith_pack_repository.dart';
import 'package:wird/core/content/translation_pack_service.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/downloads/library_screen.dart';

import '../test_helpers/file_asset_bundle.dart';

void main() {
  testWidgets(
      'Library screen lists audio, all translation editions, and all '
      'hadith collections', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          translationPackServiceProvider.overrideWithValue(
            TranslationPackService(db, bundle: FileAssetBundle()),
          ),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: LibraryScreen()),
      ),
    );
    // A GlassScaffold animation never fully settles, so pump a fixed
    // number of frames instead of pumpAndSettle (which times out).
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Quran audio'), findsOneWidget);
    expect(find.text('Recitation audio downloads'), findsOneWidget);
    expect(find.text('Quran translations'), findsOneWidget);
    expect(find.text('Hadith collections'), findsOneWidget);

    for (final name in hadithCollections.values) {
      await tester.scrollUntilVisible(
        find.text(name),
        300,
        // .first: the search TextField contributes its own Scrollable.
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(name), findsOneWidget);
      expect(find.textContaining('Not downloaded (~'), findsWidgets);
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
