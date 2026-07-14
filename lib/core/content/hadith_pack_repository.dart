import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../db/database.dart';
import 'content_source.dart';

const _cdnBase = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

/// The major collections this app offers as downloadable packs — a fixed,
/// hardcoded set (unlike Quran translations, which are open-ended and gated
/// by `tool/editions_allowlist.json`). All are drawn from the graded
/// fawazahmed0/hadith-api source: each hadith carries the source's own
/// grader verdicts, which the reader surfaces as a visible authenticity
/// badge (M23.11 vetting). "Riyad as-Salihin" isn't in this source's
/// edition list at all (confirmed — see DATA_SOURCES.md). Musnad Ahmad and
/// Sunan ad-Dārimī are deliberately NOT offered: the only local corpus for
/// them (Resources CSVs) is Arabic-only and ungraded, so shipping them
/// would present narrations of unknown authenticity — a violation of the
/// "do not guess a grade" rule; they await a graded source.
const hadithCollections = <String, String>{
  'bukhari': 'Sahih al-Bukhari',
  'muslim': 'Sahih Muslim',
  'abudawud': 'Sunan Abu Dawud',
  'tirmidhi': 'Jami at-Tirmidhi',
  'nasai': 'Sunan an-Nasai',
  'ibnmajah': 'Sunan Ibn Majah',
  'malik': 'Muwatta Malik',
};

const hadithCollectionDescriptions = <String, String>{
  'bukhari':
      'The most authentic book after the Quran, compiled by Imam Muhammad al-Bukhari.',
  'muslim':
      'The second most authentic Hadith collection, compiled by Imam Muslim ibn al-Hajjaj.',
  'abudawud':
      'Focuses primarily on legal Hadiths (Fiqh rulings), compiled by Abu Dawud as-Sijistani.',
  'tirmidhi':
      'Known for classifying Hadith grades (Sahih, Hasan, Da\'if), compiled by Imam at-Tirmidhi.',
  'nasai':
      'Known for stringent conditions for Hadith authenticity, compiled by Imam an-Nasa\'i.',
  'ibnmajah':
      'The sixth canonical Hadith collection, compiled by Ibn Majah al-Qazwini.',
  'malik':
      'One of the earliest legal and Hadith compilations by Imam Malik ibn Anas.',
};

const hadithCollectionCounts = <String, int>{
  'bukhari': 7563,
  'muslim': 3033,
  'abudawud': 5274,
  'tirmidhi': 3956,
  'nasai': 5760,
  'ibnmajah': 4341,
  'malik': 1858,
};

class HadithPackValidationError implements Exception {
  HadithPackValidationError(this.message);
  final String message;

  @override
  String toString() => 'HadithPackValidationError: $message';
}

class HadithChapter {
  const HadithChapter({required this.number, required this.title, required this.count});
  final String number;
  final String title;
  final int count;
}

class HadithEntry {
  const HadithEntry({
    required this.number,
    required this.arabic,
    required this.translation,
    required this.grades,
    required this.sharh,
  });
  final num number;
  final String arabic;
  final String translation;
  final List<dynamic> grades;
  final String? sharh;
}

/// Downloads, validates, and stores a Hadith collection pack — same
/// approach as `TranslationPackService`: fetch the raw upstream Arabic +
/// English editions directly, re-validate their structural agreement
/// client-side, and store the processed result as JSON text in
/// `ContentPacks.data` (works identically native+web via Drift).
///
/// **Lazy-loading note:** the whole collection's JSON is stored as one
/// blob per pack (same as translation packs) rather than one row per
/// chapter — `ContentPacks` is keyed one row per pack, and a schema
/// change to normalize further wasn't worth it for what's still a single
/// few-MB text value SQLite handles natively. "Chapter-level lazy
/// loading" is implemented at the decode layer instead: the raw JSON is
/// only decoded once, on first chapter access, and the decoded chapters
/// map is cached — never decoded per-hadith, and never decoded at all
/// for a collection the user hasn't opened yet.
class HadithPackRepository {
  HadithPackRepository(this._db, {http.Client? client})
      : _client = client ?? http.Client();

  final AppDatabase _db;
  final http.Client _client;

  final Map<String, Map<String, dynamic>> _decodedCache = {};

  Stream<ContentPack?> watchPack(String collection) {
    final query = _db.select(_db.contentPacks)
      ..where((t) =>
          t.type.equals('hadithCollection') &
          t.editionOrCollection.equals(collection));
    return query.watchSingleOrNull();
  }

  Future<ContentPack?> _packRow(String collection) {
    return (_db.select(_db.contentPacks)
          ..where((t) =>
              t.type.equals('hadithCollection') &
              t.editionOrCollection.equals(collection)))
        .getSingleOrNull();
  }

  Future<void> downloadAndInstall(String collection) async {
    final name = hadithCollections[collection];
    if (name == null) {
      throw HadithPackValidationError('Unknown collection "$collection"');
    }
    await _upsertStatus(collection, status: 'downloading', progress: 0);

    try {
      // Supabase content bucket first, jsdelivr as fallback (Item 1.27).
      final arabic = await _fetchJson(ContentSource.candidates(
        bucketPath: 'hadith-packs/ara-$collection.min.json',
        cdnFallback: '$_cdnBase/ara-$collection.min.json',
      ));
      final english = await _fetchJson(ContentSource.candidates(
        bucketPath: 'hadith-packs/eng-$collection.min.json',
        cdnFallback: '$_cdnBase/eng-$collection.min.json',
      ));
      final chapters = _validateAndGroup(arabic, english, collection);

      final pack = jsonEncode({
        'collection': collection,
        'name': name,
        'chapters': chapters,
      });
      final digest = sha256.convert(utf8.encode(pack)).toString();

      await _upsertStatus(
        collection,
        status: 'downloaded',
        progress: 1,
        data: pack,
        sha256: digest,
        installedAt: DateTime.now(),
      );
      _decodedCache.remove(collection);
    } catch (_) {
      await _upsertStatus(collection, status: 'failed', progress: 0);
      rethrow;
    }
  }

  Future<void> removePack(String collection) async {
    await (_db.delete(_db.contentPacks)
          ..where((t) =>
              t.type.equals('hadithCollection') &
              t.editionOrCollection.equals(collection)))
        .go();
    _decodedCache.remove(collection);
  }

  Future<Map<String, dynamic>?> _decodedChapters(String collection) async {
    final cached = _decodedCache[collection];
    if (cached != null) return cached;

    final row = await _packRow(collection);
    if (row == null || row.status != 'downloaded' || row.data == null) {
      return null;
    }
    final decoded = jsonDecode(row.data!) as Map<String, dynamic>;
    final chapters = decoded['chapters'] as Map<String, dynamic>;
    _decodedCache[collection] = chapters;
    return chapters;
  }

  Future<List<HadithChapter>> chaptersFor(String collection) async {
    final chapters = await _decodedChapters(collection);
    if (chapters == null) return const [];

    final result = <HadithChapter>[];
    for (final entry in chapters.entries) {
      final value = entry.value as Map<String, dynamic>;
      final hadithList = value['hadith'] as List<dynamic>;
      result.add(HadithChapter(
        number: entry.key,
        title: value['title'] as String,
        count: hadithList.length,
      ));
    }
    return result;
  }

  Future<List<HadithEntry>> hadithInChapter(
    String collection,
    String chapterNumber,
  ) async {
    final chapters = await _decodedChapters(collection);
    final chapter = chapters?[chapterNumber] as Map<String, dynamic>?;
    if (chapter == null) return const [];

    final hadithList = chapter['hadith'] as List<dynamic>;
    return [
      for (final h in hadithList)
        HadithEntry(
          number: (h as Map<String, dynamic>)['number'] as num,
          arabic: h['arabic'] as String,
          translation: h['translation'] as String,
          grades: h['grades'] as List<dynamic>,
          sharh: h['sharh'] as String?,
        ),
    ];
  }

  /// Fetches the first [urls] candidate that returns 200 (Supabase mirror
  /// then CDN fallback — Item 1.27). Only the final candidate's failure
  /// propagates; earlier failures fall through to the next URL.
  Future<Map<String, dynamic>> _fetchJson(List<String> urls) async {
    for (var i = 0; i < urls.length; i++) {
      final isLast = i == urls.length - 1;
      try {
        final response = await _client.get(Uri.parse(urls[i]));
        if (response.statusCode != 200) {
          if (isLast) {
            throw HadithPackValidationError(
              'Download failed for ${urls[i]} (HTTP ${response.statusCode})',
            );
          }
          continue;
        }
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        if (isLast) rethrow;
      }
    }
    throw HadithPackValidationError('No content source available');
  }

  Map<String, dynamic> _validateAndGroup(
    Map<String, dynamic> arabic,
    Map<String, dynamic> english,
    String collection,
  ) {
    final arabicHadiths = arabic['hadiths'] as List<dynamic>;
    final englishHadiths = english['hadiths'] as List<dynamic>;

    final arabicByNum = <num, Map<String, dynamic>>{
      for (final h in arabicHadiths)
        (h as Map<String, dynamic>)['hadithnumber'] as num: h,
    };
    final englishByNum = <num, Map<String, dynamic>>{
      for (final h in englishHadiths)
        (h as Map<String, dynamic>)['hadithnumber'] as num: h,
    };

    if (!_sameNumberSet(arabicByNum.keys, englishByNum.keys)) {
      throw HadithPackValidationError(
        '$collection: Arabic/English hadith-number sets disagree',
      );
    }

    final metadata = english['metadata'] as Map<String, dynamic>;
    final sectionDetails = metadata['section_details'] as Map<String, dynamic>;
    final sections = metadata['sections'] as Map<String, dynamic>;

    final sectionRanges = <(int, int, String)>[];
    for (final entry in sectionDetails.entries) {
      final bounds = entry.value as Map<String, dynamic>;
      // Upstream metadata occasionally stores a bound as a float (e.g.
      // Tirmidhi's last section ends at 3956.x); `as int` would throw and
      // fail the whole download, so coerce via num. (U4)
      final first = (bounds['hadithnumber_first'] as num).toInt();
      final last = (bounds['hadithnumber_last'] as num).toInt();
      if (first == 0 && last == 0) continue;
      sectionRanges.add((first, last, entry.key));
    }

    String? sectionFor(num hadithNumber) {
      final base = hadithNumber.toInt();
      for (final (first, last, sectionNum) in sectionRanges) {
        if (base >= first && base <= last) return sectionNum;
      }
      return null;
    }

    final chapters = <String, Map<String, dynamic>>{};
    final sortedNumbers = arabicByNum.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    for (final n in sortedNumbers) {
      final sectionNum = sectionFor(n);
      final String key;
      final String title;
      if (sectionNum == null) {
        key = 'uncategorized';
        title = 'Uncategorized (source data gap)';
      } else {
        key = sectionNum;
        title = sections[sectionNum] as String? ?? 'Section $sectionNum';
      }
      final chapter = chapters.putIfAbsent(
        key,
        () => {'title': title, 'hadith': <Map<String, dynamic>>[]},
      );
      (chapter['hadith'] as List<Map<String, dynamic>>).add({
        'number': n,
        'arabic': (arabicByNum[n]!['text'] as String).trim(),
        'translation': (englishByNum[n]!['text'] as String).trim(),
        'grades': englishByNum[n]!['grades'] ?? const [],
        'sharh': null,
      });
    }
    return chapters;
  }

  bool _sameNumberSet(Iterable<num> a, Iterable<num> b) {
    final setA = a.toSet();
    final setB = b.toSet();
    return setA.length == setB.length && setA.every(setB.contains);
  }

  Future<void> _upsertStatus(
    String collection, {
    required String status,
    required double progress,
    String? data,
    String? sha256,
    DateTime? installedAt,
  }) async {
    await _db.into(_db.contentPacks).insert(
          ContentPacksCompanion.insert(
            type: 'hadithCollection',
            languageOrCollection: collection,
            editionOrCollection: collection,
            status: Value(status),
            progress: Value(progress),
            data: Value(data),
            sha256: Value(sha256),
            installedAt: Value(installedAt),
          ),
          onConflict: DoUpdate(
            (old) => ContentPacksCompanion.custom(
              status: Constant(status),
              progress: Constant(progress),
              data: data == null ? const Constant(null) : Constant(data),
              sha256: sha256 == null ? const Constant(null) : Constant(sha256),
              installedAt: installedAt == null
                  ? const Constant(null)
                  : Constant(installedAt),
            ),
            target: [_db.contentPacks.type, _db.contentPacks.editionOrCollection],
          ),
        );
  }
}

final hadithPackRepositoryProvider = Provider<HadithPackRepository>((ref) {
  return HadithPackRepository(ref.watch(appDatabaseProvider));
});
