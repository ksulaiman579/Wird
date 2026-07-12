import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../db/database.dart';
import 'content_source.dart';
import 'models/translation_pack_models.dart';

const _allowlistAssetPath = 'tool/editions_allowlist.json';
const _expectedTotalAyahs = 6236;
const _expectedSurahCount = 114;

/// Thrown when a downloaded edition fails the same structural checks
/// `tool/build_translation_pack.py` applies at build time (ayah count,
/// surah coverage, contiguous verse numbers). Never surfaced as a generic
/// error — callers should show something like "couldn't verify this
/// translation, try again later" rather than a raw exception message.
class TranslationPackValidationError implements Exception {
  TranslationPackValidationError(this.message);
  final String message;

  @override
  String toString() => 'TranslationPackValidationError: $message';
}

/// Downloads, validates, and stores an additional Quran translation pack
/// chosen from the [TranslationAllowlist] — the only editions ever offered.
///
/// Packs are stored as raw JSON directly in the `content_packs` Drift
/// table rather than a platform-specific file/OPFS path, since Drift
/// already persists to SQLite (native) / IndexedDB (web) transparently on
/// both platforms — this avoids maintaining separate native-file and
/// web-storage code for what's a single ~1MB text blob per pack.
///
/// **On the sha256 in `tool/editions_allowlist.json`:** that hash is
/// computed by the Python build script over its own canonical
/// (Python-serialized) output file — a *build-time* provenance pin for
/// packs hosted as GitHub Release assets (once that hosting exists). This
/// service currently fetches the same *raw upstream* CDN JSON directly
/// (no release hosting exists yet), re-validates its structure itself,
/// and stores its own hash of what it actually persisted. The two hashes
/// are deliberately not compared against each other — they're hashes of
/// two different serializations of the same content, not a
/// tamper-detection pair. Content correctness comes from the structural
/// re-validation below, which mirrors the build script's own checks.
class TranslationPackService {
  TranslationPackService(
    this._db, {
    AssetBundle? bundle,
    http.Client? client,
  })  : _bundle = bundle ?? rootBundle,
        _client = client ?? http.Client();

  final AppDatabase _db;
  final AssetBundle _bundle;
  final http.Client _client;

  TranslationAllowlist? _allowlistCache;

  Future<TranslationAllowlist> loadAllowlist() async {
    final cached = _allowlistCache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(_allowlistAssetPath);
    final allowlist =
        TranslationAllowlist.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _allowlistCache = allowlist;
    return allowlist;
  }

  Stream<ContentPack?> watchPack(String editionId) {
    final query = _db.select(_db.contentPacks)
      ..where((t) =>
          t.type.equals('translation') & t.editionOrCollection.equals(editionId));
    return query.watchSingleOrNull();
  }

  /// Whether [editionId] has a completed local download (Item A2 — used to
  /// stop the reader silently selecting a language whose pack isn't on the
  /// device).
  Future<bool> isInstalled(String editionId) async {
    final row = await _packRow(editionId);
    return row?.status == 'downloaded';
  }

  Future<ContentPack?> _packRow(String editionId) {
    return (_db.select(_db.contentPacks)
          ..where((t) =>
              t.type.equals('translation') &
              t.editionOrCollection.equals(editionId)))
        .getSingleOrNull();
  }

  /// Downloads [entry], validates it, and stores it. Overwrites any
  /// previous copy of the same edition (e.g. a retry after a failure).
  Future<void> downloadAndInstall(TranslationEditionEntry entry) async {
    await _upsertStatus(entry, status: 'downloading', progress: 0);

    try {
      // Supabase content bucket first, upstream CDN as fallback (Item 1.27).
      // The bucket file is a byte-identical mirror of entry.link (same shape),
      // named by its upstream basename under quran-packs/.
      final candidates = ContentSource.candidates(
        bucketPath: 'quran-packs/${entry.link.split('/').last}',
        cdnFallback: entry.link,
      );
      http.Response? response;
      for (var i = 0; i < candidates.length; i++) {
        final isLast = i == candidates.length - 1;
        try {
          final r = await _client.get(Uri.parse(candidates[i]));
          if (r.statusCode == 200) {
            response = r;
            break;
          }
          if (isLast) {
            throw TranslationPackValidationError(
              'Download failed (HTTP ${r.statusCode})',
            );
          }
        } catch (_) {
          if (isLast) rethrow;
        }
      }

      final raw = jsonDecode(response!.body) as Map<String, dynamic>;
      final ayahs = raw['quran'] as List<dynamic>;
      final surahs = _validateAndGroup(ayahs, entry.id);

      final pack = jsonEncode({
        'edition': entry.id,
        'language': entry.languageCode,
        'surahs': surahs,
      });
      final digest = sha256.convert(utf8.encode(pack)).toString();

      await _upsertStatus(
        entry,
        status: 'downloaded',
        progress: 1,
        data: pack,
        sha256: digest,
        installedAt: DateTime.now(),
      );
    } catch (_) {
      await _upsertStatus(entry, status: 'failed', progress: 0);
      rethrow;
    }
  }

  Future<void> removePack(String editionId) async {
    await (_db.delete(_db.contentPacks)
          ..where((t) =>
              t.type.equals('translation') &
              t.editionOrCollection.equals(editionId)))
        .go();
  }

  /// Looks up the translation for one ayah from an already-downloaded
  /// pack. Returns `null` if the pack isn't downloaded (never throws for
  /// that — callers should just fall back to not showing the extra
  /// translation).
  Future<String?> extraTranslationFor({
    required String editionId,
    required int surah,
    required int ayah,
  }) async {
    final row = await _packRow(editionId);
    if (row == null || row.status != 'downloaded' || row.data == null) {
      return null;
    }

    final decoded = jsonDecode(row.data!) as Map<String, dynamic>;
    final surahList = decoded['surahs'][surah.toString()] as List<dynamic>?;
    if (surahList == null || ayah < 1 || ayah > surahList.length) return null;

    final entry = surahList[ayah - 1] as Map<String, dynamic>;
    return entry['translation'] as String?;
  }

  Future<void> _upsertStatus(
    TranslationEditionEntry entry, {
    required String status,
    required double progress,
    String? data,
    String? sha256,
    DateTime? installedAt,
  }) async {
    // insertOnConflictUpdate alone resolves conflicts against the
    // PRIMARY KEY (autoincrement `id`) — useless here since a fresh
    // insert always gets a brand-new id, never colliding on it. The row
    // this method actually wants to update-or-create is identified by
    // the (type, editionOrCollection) unique key instead, so the
    // conflict target must be given explicitly.
    await _db.into(_db.contentPacks).insert(
          ContentPacksCompanion.insert(
            type: 'translation',
            languageOrCollection: entry.languageCode,
            editionOrCollection: entry.id,
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

  Map<String, List<Map<String, dynamic>>> _validateAndGroup(
    List<dynamic> rawAyahs,
    String editionId,
  ) {
    final bySurah = <int, List<Map<String, dynamic>>>{};
    for (final item in rawAyahs) {
      final map = item as Map<String, dynamic>;
      bySurah.putIfAbsent(map['chapter'] as int, () => []).add(map);
    }

    if (rawAyahs.length != _expectedTotalAyahs) {
      throw TranslationPackValidationError(
        '$editionId: expected $_expectedTotalAyahs ayahs, got ${rawAyahs.length}',
      );
    }
    if (!_isExactSurahRange(bySurah.keys)) {
      throw TranslationPackValidationError(
        '$editionId: surah coverage mismatch',
      );
    }

    final result = <String, List<Map<String, dynamic>>>{};
    for (final entry in bySurah.entries) {
      final items = [...entry.value]
        ..sort((a, b) => (a['verse'] as int).compareTo(b['verse'] as int));
      for (var i = 0; i < items.length; i++) {
        if (items[i]['verse'] != i + 1) {
          throw TranslationPackValidationError(
            '$editionId: surah ${entry.key} has non-contiguous verse numbers',
          );
        }
      }
      result[entry.key.toString()] = [
        for (final item in items)
          {
            'ayah': item['verse'],
            'translation': (item['text'] as String).trim(),
          },
      ];
    }
    return result;
  }

  bool _isExactSurahRange(Iterable<int> surahNumbers) {
    final set = surahNumbers.toSet();
    if (set.length != _expectedSurahCount) return false;
    for (var i = 1; i <= _expectedSurahCount; i++) {
      if (!set.contains(i)) return false;
    }
    return true;
  }
}

final translationPackServiceProvider = Provider<TranslationPackService>((ref) {
  return TranslationPackService(ref.watch(appDatabaseProvider));
});
