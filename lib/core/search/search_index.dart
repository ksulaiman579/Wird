/// In-memory search over the bundled content (M28.2). Pure Dart.
///
/// ~20k short texts (6,236 ayahs × Arabic/translation/transliteration plus
/// hadith, duas and the 99 Names) — a linear scan of pre-normalised strings
/// takes a few ms, works the same on the PWA, and needs no DB schema.
library;

import 'arabic_normalizer.dart';

enum SearchKind { surah, ayah, hadith, dua, name }

class SearchDoc {
  SearchDoc({
    required this.kind,
    required this.route,
    required this.title,
    this.arabic = '',
    this.text = '',
    this.extra = '',
  })  : normTitle = normalizeForSearch(title),
        normArabic = normalizeForSearch(arabic),
        normText = normalizeForSearch(text),
        normExtra = normalizeForSearch(extra);

  final SearchKind kind;

  /// go_router location to open.
  final String route;

  /// Short label, e.g. "Al-Baqarah 2:255" or a hadith title.
  final String title;
  final String arabic;

  /// Translation / meaning shown under the Arabic.
  final String text;

  /// Searched but not shown (transliteration, reference).
  final String extra;

  final String normTitle;
  final String normArabic;
  final String normText;
  final String normExtra;
}

class SearchHit {
  const SearchHit(this.doc, this.score);
  final SearchDoc doc;
  final double score;
}

class SearchIndex {
  SearchIndex(this.docs);

  final List<SearchDoc> docs;

  static final _ayahRef = RegExp(r'^(\d{1,3})\s*[:.]\s*(\d{1,3})$');

  /// Ranked matches for [query]. A "2:255" query jumps straight to that
  /// ayah. Ranking: title > Arabic > translation > other; whole-word and
  /// start-of-text matches score higher; shorter texts edge out longer ones.
  List<SearchHit> search(
    String query, {
    Set<SearchKind>? kinds,
    int limit = 100,
  }) {
    final q = normalizeForSearch(query);
    if (q.isEmpty) return const [];

    final ref = _ayahRef.firstMatch(q);
    if (ref != null) {
      final route = '/read?surah=${int.parse(ref.group(1)!)}'
          '&ayah=${int.parse(ref.group(2)!)}';
      final exact = docs.where((d) => d.route == route);
      if (exact.isNotEmpty) return [SearchHit(exact.first, 100)];
    }

    final hits = <SearchHit>[];
    for (final d in docs) {
      if (kinds != null && !kinds.contains(d.kind)) continue;
      var score = 0.0;
      score += _fieldScore(d.normTitle, q) * 3;
      score += _fieldScore(d.normArabic, q) * 2;
      score += _fieldScore(d.normText, q) * 1.5;
      score += _fieldScore(d.normExtra, q);
      if (score > 0) {
        // Typing a surah's name almost always means "open that surah".
        if (d.kind == SearchKind.surah) score *= 1.6;
        hits.add(SearchHit(d, score));
      }
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.length > limit ? hits.sublist(0, limit) : hits;
  }

  /// Space, hyphen and punctuation separate words ("al-ikhlas").
  static bool _isBoundary(int c) =>
      c == 0x20 || c == 0x2D || c == 0x2E || c == 0x2C || c == 0x3A ||
      c == 0x2014 || c == 0x28 || c == 0x29 || c == 0x5B || c == 0x5D;

  static double _fieldScore(String field, String q) {
    if (field.isEmpty) return 0;
    final i = field.indexOf(q);
    if (i < 0) return 0;
    var s = 1.0;
    final startsWord = i == 0 || _isBoundary(field.codeUnitAt(i - 1));
    final end = i + q.length;
    final endsWord = end == field.length || _isBoundary(field.codeUnitAt(end));
    if (startsWord) s += 1;
    if (startsWord && endsWord) s += 1;
    if (i == 0) s += 0.5;
    if (field == q) s += 2;
    // Prefer shorter texts slightly, so a short exact phrase wins.
    s += 0.5 / (1 + field.length / 80);
    return s;
  }
}
