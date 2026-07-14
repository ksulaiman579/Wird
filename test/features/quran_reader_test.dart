import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show PlayerState;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/audio/ayah_audio_service.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/core/i18n/bidi.dart';
import 'package:wird/core/theme/app_theme.dart';
import 'package:wird/features/quran_reader/ayah_player_bar.dart';
import 'package:wird/features/quran_reader/quran_reader_screen.dart';
import 'package:wird/features/session/session_audio_providers.dart';

/// Controllable fake — the reader's player subscribes to these streams;
/// the abstract's concrete stream defaults are overridden here so a test
/// can drive index/state without any real audio.
class _FakePlayback extends AyahPlayback {
  final indexCtrl = StreamController<int?>.broadcast();
  final stateCtrl = StreamController<PlayerState>.broadcast();
  int seekedTo = -1;
  int groupInitialIndex = -1;

  @override
  Future<void> init() async {}
  @override
  Future<void> playAyah(
      {required int surah, required int ayah, String? localFilePath}) async {}
  @override
  Future<void> playGroup(
      {required int surah,
      required List<int> ayahs,
      Map<int, String>? localFilePaths,
      int initialIndex = 0}) async {
    groupInitialIndex = initialIndex;
  }
  @override
  Future<bool> onPlaythroughCompleted() async => false;
  @override
  Stream<PlayerState> get playerStateStream => stateCtrl.stream;
  @override
  Stream<int?> get currentIndexStream => indexCtrl.stream;
  @override
  Future<void> seekToIndex(int index) async => seekedTo = index;
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Regression note: mounting QuranReaderScreen a second time in its own
  // separate testWidgets block hangs pumpAndSettle in this environment —
  // same category of gotcha as about_screen_test.dart's AboutScreen
  // double-mount and M4.2's SurahScreen double-mount. All reader
  // assertions live in one block as a pragmatic workaround.
  testWidgets(
      'paged reader shows one ayah per page, crosses the surah boundary, and '
      "exposes the options sheet's reciter picker + auto-play toggle",
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakePlayback();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sessionAudioServiceProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: QuranReaderScreen(initialSurah: 113)),
      ),
    );
    await tester.pumpAndSettle();

    // The n/total counter is wrapped in bidi isolates so it doesn't reorder
    // in RTL locales (Item A1), so match the isolated form.
    expect(find.text('Al-Falaq'), findsOneWidget);
    expect(find.text(Bidi.isolateNumbers('1 / 5')), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
    }
    expect(find.text(Bidi.isolateNumbers('5 / 5')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();
    expect(find.text('An-Nas'), findsOneWidget);
    expect(find.text(Bidi.isolateNumbers('1 / 6')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Al-Falaq'), findsOneWidget);
    expect(find.text(Bidi.isolateNumbers('5 / 5')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Reciter'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Auto-play on swipe'), findsOneWidget);

    final toggle = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Auto-play on swipe'),
    );
    expect(toggle.value, isTrue); // defaults on

    final initialSlider = tester.widget<Slider>(find.byType(Slider).last);
    expect(initialSlider.value, 26.0);
    expect(initialSlider.label, '26');

    await tester.drag(find.byType(Slider).last, const Offset(60, 0));
    await tester.pumpAndSettle();

    final updatedSlider = tester.widget<Slider>(find.byType(Slider).last);
    expect(updatedSlider.value, greaterThan(26.0));
    expect(updatedSlider.label, updatedSlider.value.round().toString());

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('AyahPlayerBar renders transport controls and fires callbacks',
      (tester) async {
    var played = 0, prev = 0, next = 0;
    await tester.pumpWidget(
      MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
        theme: AppTheme.light(),
        home: Scaffold(
          body: AyahPlayerBar(
            playing: false,
            position: const Duration(seconds: 5),
            duration: const Duration(seconds: 30),
            onPlayPause: () => played++,
            onPrev: () => prev++,
            onNext: () => next++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('0:05'), findsOneWidget); // position
    expect(find.text('0:30'), findsOneWidget); // duration

    await tester.tap(find.byIcon(Icons.play_circle_fill_rounded));
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));
    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.pump();

    expect(played, 1);
    expect(prev, 1);
    expect(next, 1);
  });
}
