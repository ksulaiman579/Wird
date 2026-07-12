import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/library_book.dart';

const _catalogueAsset = 'assets/data/knowledge_library.json';

/// The 8 curated disciplines, in display order, with their in-app labels.
/// Slugs match `tool/build_islamhouse_catalogue.py` and the route params.
const libraryDisciplines = <({String slug, String label})>[
  (slug: 'aqeedah', label: 'Aqeedah (Creed)'),
  (slug: 'tafsir', label: 'Tafsir'),
  (slug: 'hadith', label: 'Hadith'),
  (slug: 'fiqh', label: 'Fiqh (Jurisprudence)'),
  (slug: 'seerah', label: 'Seerah (Biography)'),
  (slug: 'adab', label: 'Manners & Ethics'),
  (slug: 'dawah', label: "Da'wah"),
  (slug: 'arabic', label: 'Arabic Language'),
];

String libraryDisciplineLabel(String slug) => libraryDisciplines
    .firstWhere((d) => d.slug == slug, orElse: () => (slug: slug, label: slug))
    .label;

/// The 7 catalogue languages, in display order.
const libraryLanguages = <({String code, String label})>[
  (code: 'en', label: 'English'),
  (code: 'ar', label: 'Arabic'),
  (code: 'ur', label: 'Urdu'),
  (code: 'bn', label: 'Bangla'),
  (code: 'hi', label: 'Hindi'),
  (code: 'ml', label: 'Malayalam'),
  (code: 'tl', label: 'Tagalog'),
];

/// Loads + queries the bundled Knowledge Library catalogue (M24.4). Pure
/// read-only metadata access; downloads/on-disk state live in
/// `LibraryDownloadService`.
class LibraryRepository {
  LibraryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<LibraryBook>? _cache;

  Future<List<LibraryBook>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await _bundle.loadString(_catalogueAsset);
    final list = (jsonDecode(raw) as List)
        .map((e) => LibraryBook.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  /// Books in [discipline] and [languageCode], optionally filtered by a
  /// case-insensitive [query] over title/author. Sorted by title.
  Future<List<LibraryBook>> books({
    required String discipline,
    required String languageCode,
    String query = '',
  }) async {
    final all = await loadAll();
    final q = query.trim().toLowerCase();
    final out = all.where((b) {
      if (b.discipline != discipline) return false;
      if (b.languageCode != languageCode) return false;
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    return out;
  }

  /// How many books exist per discipline for [languageCode] — drives the
  /// hub's category-card counts.
  Future<Map<String, int>> disciplineCounts(String languageCode) async {
    final all = await loadAll();
    final counts = <String, int>{};
    for (final b in all) {
      if (b.languageCode == languageCode) {
        counts[b.discipline] = (counts[b.discipline] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<LibraryBook?> byId(int id) async {
    final all = await loadAll();
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}

final libraryRepositoryProvider =
    Provider<LibraryRepository>((ref) => LibraryRepository());
