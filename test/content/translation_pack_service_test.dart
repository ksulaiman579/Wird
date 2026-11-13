import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:wird/core/content/models/translation_pack_models.dart';
import 'package:wird/core/content/translation_pack_service.dart';
import 'package:wird/core/db/database.dart';

import '../test_helpers/file_asset_bundle.dart';

/// A minimal fake `http.Client` that returns pre-canned responses per URL
/// — no real network access needed for these tests.
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

/// Builds a raw upstream-shaped edition JSON body: 6,236 ayahs across
/// surahs 1-114, with a tiny distinguishing translation string per ayah so
/// a specific lookup can be asserted against.
String _fakeUpstreamBody() {
  // Real per-surah ayah counts aren't needed here — just a partition of
  // 6,236 into 114 non-empty, contiguous-from-1 groups.
  final counts = List<int>.filled(114, 1);
  var remaining = 6236 - 114;
  for (var i = 0; i < 113 && remaining > 0; i++) {
    final take = remaining < 55 ? remaining : 55;
    counts[i] += take;
    remaining -= take;
  }
  counts[113] += remaining;

  final ayahs = <Map<String, dynamic>>[];
  for (var surah = 1; surah <= 114; surah++) {
    for (var verse = 1; verse <= counts[surah - 1]; verse++) {
      ayahs.add({
        'chapter': surah,
        'verse': verse,
        'text': 'fake $surah:$verse',
      });
    }
  }
  return jsonEncode({'quran': ayahs});
}

void main() {
  late AppDatabase db;
  const entry = TranslationEditionEntry(
    id: 'fra_muhammadhamidul',
    language: 'French',
    languageCode: 'fr',
    author: 'Muhammad Hamidullah',
    link: 'https://example.test/fra-muhammadhamidul.json',
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('loadAllowlist reads the real allowlist asset', () async {
    final service = TranslationPackService(db, bundle: FileAssetBundle());
    final allowlist = await service.loadAllowlist();

    // 46 original + 10 M24.1 (institutional) editions. The 8 M24.2 academic/
    // orientalist editions were removed after a Salaf/Ahlus-Sunnah screening
    // (non-Muslim orientalist or Asad-based translators — failed the app's
    // institutional-provenance bar).
    expect(allowlist.editions.length, 56);
    expect(
      allowlist.editions.any((e) => e.id == 'fra_muhammadhamidul'),
      isTrue,
    );
    // A batch-1 addition is present and sha256-pinned.
    final thai = allowlist.editions.firstWhere((e) => e.id == 'tha_kingfahadquranc');
    expect(thai.sha256?.length, 64);
  });

  test('downloadAndInstall validates, stores, and makes ayahs readable',
      () async {
    final client = _FakeClient({
      entry.link: http.Response(_fakeUpstreamBody(), 200),
    });
    final service = TranslationPackService(db, client: client);

    await service.downloadAndInstall(entry);

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'downloaded');
    expect(row.progress, 1.0);
    expect(row.data, isNotNull);

    final translation = await service.extraTranslationFor(
      editionId: entry.id,
      surah: 2,
      ayah: 1,
    );
    expect(translation, 'fake 2:1');
  });

  test('installedEditionIds lists only downloaded editions', () async {
    final client = _FakeClient({
      entry.link: http.Response(_fakeUpstreamBody(), 200),
    });
    final service = TranslationPackService(db, client: client);

    expect(await service.installedEditionIds(), isEmpty);
    await service.downloadAndInstall(entry);
    expect(await service.installedEditionIds(), {entry.id});
  });

  test('extraTranslationFor returns null when nothing is downloaded yet',
      () async {
    final service = TranslationPackService(db, client: _FakeClient({}));
    final translation = await service.extraTranslationFor(
      editionId: entry.id,
      surah: 1,
      ayah: 1,
    );
    expect(translation, isNull);
  });

  test('downloadAndInstall marks the pack failed on a malformed response',
      () async {
    final client = _FakeClient({
      entry.link: http.Response(jsonEncode({'quran': <dynamic>[]}), 200),
    });
    final service = TranslationPackService(db, client: client);

    await expectLater(
      () => service.downloadAndInstall(entry),
      throwsA(isA<TranslationPackValidationError>()),
    );

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'failed');
  });

  test('a failed re-download keeps the installed copy usable', () async {
    await TranslationPackService(db, client: _FakeClient({
      entry.link: http.Response(_fakeUpstreamBody(), 200),
    })).downloadAndInstall(entry);

    final failing = TranslationPackService(db, client: _FakeClient({
      entry.link: http.Response(jsonEncode({'quran': <dynamic>[]}), 200),
    }));
    await expectLater(
      () => failing.downloadAndInstall(entry),
      throwsA(isA<TranslationPackValidationError>()),
    );

    final row = await db.select(db.contentPacks).getSingle();
    expect(row.status, 'downloaded');
    expect(row.data, isNotNull);
    expect(
      await failing.extraTranslationFor(editionId: entry.id, surah: 2, ayah: 1),
      'fake 2:1',
    );
  });

  test('a pack left mid-download is reset when the database reopens',
      () async {
    final dir = await Directory.systemTemp.createTemp('wird_db_');
    final file = File('${dir.path}/t.sqlite');
    addTearDown(() => dir.delete(recursive: true));

    final first = AppDatabase(NativeDatabase(file));
    await first.customStatement(
      "INSERT INTO content_packs (type, language_or_collection, "
      "edition_or_collection, status, progress, data) VALUES "
      "('translation', 'fr', 'empty', 'downloading', 0.3, NULL), "
      "('translation', 'fr', 'kept', 'downloading', 0.3, '{}')",
    );
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    final rows = {
      for (final r in await second.select(second.contentPacks).get())
        r.editionOrCollection: r.status,
    };
    await second.close();
    expect(rows, {'empty': 'failed', 'kept': 'downloaded'});
  });

  test('removePack deletes the row', () async {
    final client = _FakeClient({
      entry.link: http.Response(_fakeUpstreamBody(), 200),
    });
    final service = TranslationPackService(db, client: client);
    await service.downloadAndInstall(entry);

    await service.removePack(entry.id);

    final rows = await db.select(db.contentPacks).get();
    expect(rows, isEmpty);
  });
}
