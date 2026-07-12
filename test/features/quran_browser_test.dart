import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show PlayerState;

import 'package:wird/core/audio/ayah_audio_service.dart';
import 'package:wird/features/quran_browser/quran_browser_screen.dart';
import 'package:wird/features/quran_browser/surah_screen.dart';
import 'package:wird/features/session/session_audio_providers.dart';

/// No device/browser in this container to exercise real just_audio
/// playback against — see new_material_flow_test.dart's fake for the same
/// pattern.
class _FakePlayback extends AyahPlayback {
  final controller = StreamController<PlayerState>.broadcast();
  int playAyahCalls = 0;
  int? lastAyahPlayed;

  @override
  Stream<PlayerState> get playerStateStream => controller.stream;

  @override
  Future<void> init() async {}

  @override
  Future<void> playAyah({
    required int surah,
    required int ayah,
    String? localFilePath,
  }) async {
    playAyahCalls++;
    lastAyahPlayed = ayah;
  }

  @override
  Future<void> playGroup({
    required int surah,
    required List<int> ayahs,
    Map<int, String>? localFilePaths,
    int initialIndex = 0,
  }) async {}

  @override
  Future<bool> onPlaythroughCompleted() async => false;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() => controller.close();
}

void main() {
  testWidgets('QuranBrowserScreen lists surahs and filters by search', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialAppWrapper(child: QuranBrowserScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah — The Opener'), findsOneWidget);
    expect(find.text('An-Nas — Mankind'), findsNothing);

    await tester.enterText(find.byType(TextField), 'mankind');
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah — The Opener'), findsNothing);
    expect(find.text('An-Nas — Mankind'), findsOneWidget);
  });

  testWidgets(
      'SurahScreen shows ayahs with transliteration/translation and the '
      'per-ayah play button toggles + calls playAyah', (tester) async {
    // Mounted once (not in a separate test) — mounting SurahScreen twice in
    // this file triggers a pumpAndSettle hang in this environment (a
    // provider-teardown timer from the first mount bleeds into the
    // second's settle loop); one test, one mount, sidesteps it.
    final fakePlayback = _FakePlayback();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionAudioServiceProvider.overrideWithValue(fakePlayback)],
        child: const MaterialAppWrapper(child: SurahScreen(surahNumber: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Bismi'), findsOneWidget);
    expect(find.textContaining('Allah'), findsWidgets);

    final firstPlayButton = find.byIcon(Icons.play_arrow_rounded).first;
    await tester.tap(firstPlayButton);
    await tester.pump();

    expect(fakePlayback.playAyahCalls, 1);
    expect(fakePlayback.lastAyahPlayed, 1);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop_rounded));
    await tester.pump();

    expect(find.byIcon(Icons.stop_rounded), findsNothing);
  });
}

/// Minimal MaterialApp wrapper so screens that rely on Directionality,
/// Theme, etc. render without pulling in the full app shell/router.
class MaterialAppWrapper extends StatelessWidget {
  const MaterialAppWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: child);
  }
}
