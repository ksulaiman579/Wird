import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:wird/core/content/hadith_pack_repository.dart';
import 'package:wird/core/db/database.dart';

/// A minimal fake `http.Client` returning pre-canned responses per URL.
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

/// A small fake edition body: 5 hadith across 2 sections, one language.
String _fakeEditionBody(String textPrefix) {
  return jsonEncode({
    'metadata': {
      'sections': {'0': '', '1': 'Chapter One', '2': 'Chapter Two'},
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
        '2': {
          'hadithnumber_first': 3,
          'hadithnumber_last': 5,
          'arabicnumber_first': 3,
          'arabicnumber_last': 5,
        },
      },
    },
    'hadiths': [
      for (var n = 1; n <= 5; n++)
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

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('downloadAndInstall validates, chapters, and stores the pack',
      () async {
    final client = _FakeClient({
      arabicUrl: http.Response(_fakeEditionBody('arabic'), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    final repo = HadithPackRepository(db, client: client);

    await repo.downloadAndInstall('bukhari');

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'downloaded');
    expect(row.type, 'hadithCollection');

    final chapters = await repo.chaptersFor('bukhari');
    expect(chapters.length, 2);
    expect(chapters.firstWhere((c) => c.number == '1').count, 2);
    expect(chapters.firstWhere((c) => c.number == '2').count, 3);

    final hadith = await repo.hadithInChapter('bukhari', '2');
    expect(hadith.length, 3);
    expect(hadith.first.translation, 'english 3');
    expect(hadith.first.arabic, 'arabic 3');
  });

  test('downloadAndInstall marks pack failed when Arabic/English disagree',
      () async {
    final mismatched = jsonDecode(_fakeEditionBody('arabic'))
        as Map<String, dynamic>;
    (mismatched['hadiths'] as List).removeLast();

    final client = _FakeClient({
      arabicUrl: http.Response(jsonEncode(mismatched), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    final repo = HadithPackRepository(db, client: client);

    await expectLater(
      () => repo.downloadAndInstall('bukhari'),
      throwsA(isA<HadithPackValidationError>()),
    );

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'failed');
  });

  test('downloadAndInstall tolerates a float section bound (U4 / Tirmidhi)',
      () async {
    // Upstream Tirmidhi metadata stores the final section's last bound as a
    // float; the old `as int` cast threw and failed the whole download.
    final body = jsonDecode(_fakeEditionBody('arabic')) as Map<String, dynamic>;
    ((body['metadata'] as Map)['section_details'] as Map)['2']
        ['hadithnumber_last'] = 5.0;

    // Both editions carry the same float bound so their number sets agree.
    final englishBody =
        jsonDecode(_fakeEditionBody('english')) as Map<String, dynamic>;
    ((englishBody['metadata'] as Map)['section_details'] as Map)['2']
        ['hadithnumber_last'] = 5.0;
    final client = _FakeClient({
      arabicUrl: http.Response(jsonEncode(body), 200),
      englishUrl: http.Response(jsonEncode(englishBody), 200),
    });
    final repo = HadithPackRepository(db, client: client);

    await repo.downloadAndInstall('bukhari');

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'downloaded');
    final chapters = await repo.chaptersFor('bukhari');
    expect(chapters.firstWhere((c) => c.number == '2').count, 3);
  });

  test('chaptersFor returns empty when nothing is downloaded', () async {
    final repo = HadithPackRepository(db, client: _FakeClient({}));
    final chapters = await repo.chaptersFor('bukhari');
    expect(chapters, isEmpty);
  });

  test('removePack deletes the row', () async {
    final client = _FakeClient({
      arabicUrl: http.Response(_fakeEditionBody('arabic'), 200),
      englishUrl: http.Response(_fakeEditionBody('english'), 200),
    });
    final repo = HadithPackRepository(db, client: client);
    await repo.downloadAndInstall('bukhari');

    await repo.removePack('bukhari');

    final rows = await db.select(db.contentPacks).get();
    expect(rows, isEmpty);
  });
}
