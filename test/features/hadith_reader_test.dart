import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:wird/core/content/hadith_pack_repository.dart';
import 'package:wird/core/db/database.dart';
import 'package:wird/features/hadith_reader/hadith_chapter_detail_screen.dart';
import 'package:wird/features/hadith_reader/hadith_chapter_list_screen.dart';
import 'package:wird/features/hadith_reader/hadith_collection_shelf_screen.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this._responses);
  final Map<String, http.Response> _responses;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = _responses[request.url.toString()];
    if (response == null) {
      throw Exception('No fake response registered for ${request.url}');
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
    );
  }
}

String _fakeEditionBody(String textPrefix) {
  return jsonEncode({
    'metadata': {
      'sections': {'0': '', '1': 'Chapter One'},
      'section_details': {
        '0': {
          'hadithnumber_first': 0,
          'hadithnumber_last': 0,
          'arabicnumber_first': 0,
          'arabicnumber_last': 0,
        },
        '1': {
          'hadithnumber_first': 1,
          'hadithnumber_last': 2,
          'arabicnumber_first': 1,
          'arabicnumber_last': 2,
        },
      },
    },
    'hadiths': [
      for (var n = 1; n <= 2; n++)
        {
          'hadithnumber': n,
          'arabicnumber': n,
          'text': '$textPrefix $n',
          'grades': <dynamic>[],
          'reference': {'book': 1, 'hadith': n},
        },
    ],
  });
}

void main() {
  late AppDatabase db;
  const arabicUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/ara-bukhari.min.json';
  const englishUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/eng-bukhari.min.json';

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('shelf lists all six collections, not-downloaded by default',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: HadithCollectionShelfScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('40 Hadith of an-Nawawi'), findsOneWidget);
    for (final name in hadithCollections.values) {
      await tester.scrollUntilVisible(
        find.text(name),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(name), findsOneWidget);
    }

    // Let Drift's stream-query timers dispose before the test ends (same
    // pattern as downloads_screen_test.dart).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('chapter list shows chapters once a pack is downloaded',
      (tester) async {
    final client = _FakeClient({
      arabicUrl: http.Response(_fakeEditionBody('arabic'), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    await HadithPackRepository(db, client: client).downloadAndInstall('bukhari');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: HadithChapterListScreen(collection: 'bukhari'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chapter One'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('chapter detail shows arabic + translation and a bookmark toggle',
      (tester) async {
    final client = _FakeClient({
      arabicUrl: http.Response(_fakeEditionBody('arabic'), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    await HadithPackRepository(db, client: client).downloadAndInstall('bukhari');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
          home: HadithChapterDetailScreen(
            collection: 'bukhari',
            chapterNumber: '1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('english'), findsWidgets);
    expect(find.byIcon(Icons.bookmark_outline_rounded), findsWidgets);

    await tester.tap(find.byIcon(Icons.bookmark_outline_rounded).first);
    await tester.pumpAndSettle();

    final bookmarks = await db.select(db.bookmarks).get();
    expect(bookmarks.single.contentKey, 'h:bukhari:1');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('chapter detail cards collapse and expand on tap',
      (tester) async {
    final client = _FakeClient({
      arabicUrl: http.Response(_fakeEditionBody('arabic'), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    await HadithPackRepository(db, client: client).downloadAndInstall('bukhari');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales,
          home: HadithChapterDetailScreen(
            collection: 'bukhari',
            chapterNumber: '1',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Collapsed by default: every card shows the down chevron, none up.
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsWidgets);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsNothing);

    // Tapping a card expands it (down chevron flips to up).
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
