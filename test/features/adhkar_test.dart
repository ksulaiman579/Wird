import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/content/dua_repository.dart';
import 'package:wird/core/content/models/dua_models.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/adhkar/adhkar_reader_screen.dart';
import 'package:wird/shared/glass/glass.dart';

import '../test_helpers/file_asset_bundle.dart';

const _tinyDua1 = Dua(
  id: 'test-1',
  arabic: 'اختبار واحد',
  transliteration: 'Ikhtibar wahid',
  translation: 'Test one',
  reference: 'Test',
  repetitions: 1,
  wordCount: 2,
);

const _tinyDua2 = Dua(
  id: 'test-2',
  arabic: 'اختبار اثنان',
  translation: 'Test two',
  reference: 'Test',
  repetitions: 2,
  wordCount: 2,
);

class _FakeDuaRepository extends DuaRepository {
  @override
  Future<AdhkarSet> loadAdhkar() async {
    return const AdhkarSet(morning: [_tinyDua1, _tinyDua2], evening: []);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('with real bundled data', () {
    final repository = DuaRepository(bundle: FileAssetBundle());
    setUpAll(() => repository.loadAdhkar());

    testWidgets('shows the first morning dhikr', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [duaRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: AdhkarReaderScreen(period: 'morning'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Morning adhkar'), findsOneWidget);
      expect(find.textContaining('Ever-Living'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);
    });
  });

  group('with a small synthetic set', () {
    testWidgets('tapping increments count and completes the day', (
      tester,
    ) async {
      // Completing the day now also evaluates achievements, which reads
      // the DB — must override appDatabaseProvider with an in-memory DB
      // here, or it hangs on the real path_provider-backed one.
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            duaRepositoryProvider.overrideWithValue(_FakeDuaRepository()),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: AdhkarReaderScreen(period: 'morning'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First dhikr needs 1 tap.
      expect(find.text('0/1'), findsOneWidget);
      await tester.tap(find.byType(GlassProgressRing));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Auto-advances to the second dhikr after delay.
      await tester.pumpAndSettle();

      expect(find.text('0/2'), findsOneWidget);
      await tester.tap(find.byType(GlassProgressRing));
      await tester.pumpAndSettle();
      expect(find.text('1/2'), findsOneWidget);

      await tester.tap(find.byType(GlassProgressRing));
      await tester.pumpAndSettle();

      // All items now done — celebration dialog should appear.
      expect(find.text('All done! 🎉'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      final key = completedPrefsKey('morning', DateTime.now());
      expect(prefs.getBool(key), isTrue);
    });

    testWidgets('shows the already-done view on a later visit today', (
      tester,
    ) async {
      final key = completedPrefsKey('morning', DateTime.now());
      SharedPreferences.setMockInitialValues({key: true});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            duaRepositoryProvider.overrideWithValue(_FakeDuaRepository()),
          ],
          child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
            home: AdhkarReaderScreen(period: 'morning'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("completed today's morning adhkar"),
          findsOneWidget);

      await tester.tap(find.text('Read again'));
      await tester.pumpAndSettle();

      expect(find.text('0/1'), findsOneWidget);
    });
  });
}
