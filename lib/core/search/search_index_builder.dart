import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'search_index.dart';

/// Loads the bundled content files and builds the [SearchIndex] off the UI
/// thread (M28.2). Only bundled content for now; downloaded translations
/// and hadith collections can be added the same way later.
Future<SearchIndex> buildSearchIndex({AssetBundle? bundle}) async {
  final b = bundle ?? rootBundle;
  final meta = await b.loadString('assets/data/quran/meta.json');
  final surahs = <String>[
    for (var i = 1; i <= 114; i++)
      await b.loadString(
        'assets/data/quran/surah_${i.toString().padLeft(3, '0')}.json',
      ),
  ];
  final payload = _Payload(
    meta: meta,
    surahs: surahs,
    nawawi: await b.loadString('assets/data/hadith_nawawi.json'),
    hisnul: await b.loadString('assets/data/hisnul_muslim.json'),
    asma: await b.loadString('assets/data/asma_ul_husna.json'),
  );
  return compute(buildIndexFromJson, payload);
}

class _Payload {
  const _Payload({
    required this.meta,
    required this.surahs,
    required this.nawawi,
    required this.hisnul,
    required this.asma,
  });
  final String meta;
  final List<String> surahs;
  final String nawawi;
  final String hisnul;
  final String asma;
}

/// Pure: JSON strings in, index out. Public for tests.
SearchIndex buildIndexFromJson(Object payloadObj) {
  final p = payloadObj as _Payload;
  final docs = <SearchDoc>[];

  final names = <int, String>{};
  for (final s in (jsonDecode(p.meta) as Map<String, dynamic>)['surahs']
      as List<dynamic>) {
    final m = s as Map<String, dynamic>;
    final n = m['number'] as int;
    final translit = m['nameTransliterated'] as String;
    names[n] = translit;
    docs.add(SearchDoc(
      kind: SearchKind.surah,
      route: '/quran/$n',
      title: '$n. $translit — ${m['nameEnglish']}',
      arabic: m['nameArabic'] as String,
    ));
  }

  for (final raw in p.surahs) {
    final s = jsonDecode(raw) as Map<String, dynamic>;
    final n = s['surah'] as int;
    for (final a in s['ayahs'] as List<dynamic>) {
      final m = a as Map<String, dynamic>;
      final ayah = m['ayah'] as int;
      docs.add(SearchDoc(
        kind: SearchKind.ayah,
        route: '/read?surah=$n&ayah=$ayah',
        title: '${names[n] ?? n} $n:$ayah',
        arabic: m['arabic'] as String? ?? '',
        text: m['translation'] as String? ?? '',
        extra: m['transliteration'] as String? ?? '',
      ));
    }
  }

  for (final h in jsonDecode(p.nawawi) as List<dynamic>) {
    final m = h as Map<String, dynamic>;
    docs.add(SearchDoc(
      kind: SearchKind.hadith,
      route: '/hadith/nawawi/${m['id']}',
      title: m['titleEnglish'] as String? ?? '',
      arabic: m['arabic'] as String? ?? '',
      text: m['translation'] as String? ?? '',
    ));
  }

  for (final c in (jsonDecode(p.hisnul) as Map<String, dynamic>)['categories']
      as List<dynamic>) {
    final cat = c as Map<String, dynamic>;
    final catTitle = cat['titleEnglish'] as String? ?? '';
    for (final d in cat['duas'] as List<dynamic>) {
      final m = d as Map<String, dynamic>;
      docs.add(SearchDoc(
        kind: SearchKind.dua,
        route: '/duas/${cat['id']}',
        title: catTitle,
        arabic: m['arabic'] as String? ?? '',
        text: m['translation'] as String? ?? '',
        extra: '${m['transliteration'] ?? ''} ${m['reference'] ?? ''}',
      ));
    }
  }

  for (final n in jsonDecode(p.asma) as List<dynamic>) {
    final m = n as Map<String, dynamic>;
    docs.add(SearchDoc(
      kind: SearchKind.name,
      route: '/asma',
      title: '${m['number']}. ${m['transliteration']}',
      arabic: m['arabic'] as String? ?? '',
      text: m['meaning'] as String? ?? '',
    ));
  }

  return SearchIndex(docs);
}

/// Built once, on first use of search, and kept for the session.
final searchIndexProvider = FutureProvider<SearchIndex>((ref) {
  return buildSearchIndex();
});
