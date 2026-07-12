import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/audio/audio_download_manager.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/downloads/download_providers.dart';
import 'package:wird/features/downloads/downloads_screen.dart';

class _FakeDownloads implements AudioDownloads {
  final enqueued = <(int surah, List<int> ayahs, String reciter, bool wifiOnly)>[];

  @override
  Future<void> enqueueSurah({
    required int surah,
    required List<int> ayahs,
    required String reciter,
    required bool wifiOnly,
  }) async {
    enqueued.add((surah, ayahs, reciter, wifiOnly));
  }

  @override
  Future<void> pauseSurah(int surah) async {}

  @override
  Future<void> resumeSurah(int surah) async {}

  @override
  Future<void> deleteSurah(int surah) async {}
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late _FakeDownloads fakeDownloads;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fakeDownloads = _FakeDownloads();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        audioDownloadManagerProvider.overrideWithValue(fakeDownloads),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  testWidgets(
      'defaults to "My plan" scope, lists only plan surahs, and enqueues on tap',
      (tester) async {
    await db.into(db.srsItems).insert(SrsItemsCompanion.insert(
          contentType: 'quran',
          contentKey: 'q:1:1-7',
          orderIndex: 0,
          wordCount: 29,
        ));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: DownloadsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('0 of 1 surahs downloaded'), findsOneWidget);
    expect(find.text('Al-Fatihah'), findsOneWidget);
    expect(find.text('An-Nas'), findsNothing);

    await tester.tap(find.byIcon(Icons.download_rounded));
    await tester.pump();

    expect(fakeDownloads.enqueued, hasLength(1));
    final call = fakeDownloads.enqueued.single;
    expect(call.$1, 1);
    expect(call.$2, [1, 2, 3, 4, 5, 6, 7]);
    expect(call.$4, true); // wifiOnly defaults to true

    await tester.tap(find.text('Full Quran'));
    await tester.pumpAndSettle();

    expect(find.textContaining('of 114 surahs downloaded'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
