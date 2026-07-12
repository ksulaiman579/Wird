import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;

import 'package:wird/core/audio/ayah_audio_service.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/core/srs/sm2_scheduler.dart';
import 'package:wird/features/session/new_material_flow.dart';
import 'package:wird/features/session/session_audio_providers.dart';

const _fatihahItem = SrsItem(
  id: 1,
  contentType: 'quran',
  contentKey: 'q:1:1-2',
  orderIndex: 0,
  wordCount: 8,
  status: 'new',
  easeFactor: 2.5,
  intervalDays: 0,
  repetitions: 0,
  learningStep: 0,
);

/// This container has no device/browser to exercise real just_audio
/// playback against, so the Listen step's audio wiring is verified against
/// this fake instead — it mimics [AyahAudioService]'s repeat-until-target
/// contract (see `shouldRepeatAgain` in ayah_audio_urls.dart) without
/// touching any platform channel.
class _FakePlayback extends AyahPlayback {
  final controller = StreamController<PlayerState>.broadcast();
  int completedCalls = 0;

  @override
  Stream<PlayerState> get playerStateStream => controller.stream;

  @override
  Future<void> init() async {}

  @override
  Future<void> playAyah({
    required int surah,
    required int ayah,
    String? localFilePath,
  }) async {}

  @override
  Future<void> playGroup({
    required int surah,
    required List<int> ayahs,
    Map<int, String>? localFilePaths,
    int initialIndex = 0,
  }) async {}

  @override
  Future<bool> onPlaythroughCompleted() async {
    completedCalls++;
    return completedCalls < defaultRepeatTarget;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() => controller.close();

  Future<void> emitCompleted(WidgetTester tester) async {
    controller.add(PlayerState(false, ProcessingState.completed));
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  testWidgets(
      'walks listen -> meaning -> fading -> chain recall -> self-test, '
      'grading through onGraded', (tester) async {
    Grade? gradedWith;
    final fakePlayback = _FakePlayback();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionAudioServiceProvider.overrideWithValue(fakePlayback),
        ],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: Scaffold(
            body: NewMaterialFlow(
              item: _fatihahItem,
              onGraded: (grade) => gradedWith = grade,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Listen & repeat (M22.4): Continue is ALWAYS enabled now — a
    // self-reciter can move on without listening 5 times. The repeat
    // counter is just a guide.
    expect(find.textContaining('Repeated 0 of 5'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Play recitation'));
    await tester.pump();
    expect(find.text('Stop'), findsOneWidget);

    // The counter still advances as playthroughs complete, but doesn't gate.
    for (var i = 0; i < 5; i++) {
      await fakePlayback.emitCompleted(tester);
    }
    expect(find.textContaining('Repeated 5 of 5'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Meaning step.
    expect(find.text('Meaning'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Fading: full -> hint -> hidden.
    expect(find.textContaining('Read it once more'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('first word'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fully hidden'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Chain recall (2-ayah group).
    expect(find.textContaining('Chain recall'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    // Self-test: reveal, then grade.
    expect(find.textContaining('Self-test'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reveal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I've got it"));
    await tester.pumpAndSettle();

    expect(gradedWith, Grade.good);
  });
}
