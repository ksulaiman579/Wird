import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' show PlayerState;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/core/audio/ayah_audio_service.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/quran_reader/quran_reader_screen.dart';
import 'package:wird/features/session/session_audio_providers.dart';

class _FakePlayback extends AyahPlayback {
  final indexCtrl = StreamController<int?>.broadcast();
  final stateCtrl = StreamController<PlayerState>.broadcast();
  int seekedTo = -1;

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
      int initialIndex = 0}) async {}
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
  testWidgets('QuranReaderScreen renders continuous Mushaf layout when mushafMode is enabled',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'quran_reader_prefs': jsonEncode({'mushafMode': true}),
    });

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fake = _FakePlayback();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          sessionAudioServiceProvider.overrideWithValue(fake),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: QuranReaderScreen(initialSurah: 113),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // In continuous mushaf mode, verse markers should appear in a single rich layout
    expect(find.textContaining('﴿1﴾'), findsOneWidget);
    expect(find.textContaining('﴿2﴾'), findsOneWidget);
  });
}
