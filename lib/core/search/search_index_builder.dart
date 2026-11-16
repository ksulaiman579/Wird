import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'search_index.dart';

/// Builds the [SearchIndex] off the UI thread (M28.2): the bundled content
/// plus, since audit WQA-019, what the user downloaded — their Quran
/// translation (shown instead of the bundled English, which stays
/// searchable) and every downloaded hadith collection, in their language
/// where the pack has it.
Future<SearchIndex> buildSearchIndex({
  AssetBundle? bundle,
  String lang = 'en',
  String? translationPack,
  Map<String, String> hadithPacks = const {},
  Map<String, String> collectionNames = const {},
}) async {
  final b = bundle ?? rootBundle;
  final meta = await b.loadString('assets/data/quran/meta.json');
  final surahs = <String>[
    for (var i = 1; i <= 114; i++)
      await b.loadString(
        'assets/data/quran/surah_${i.toString().padLeft(3, '0')}.json',
      ),
  ];
  final payload = SearchPayload(
    meta: meta,
    surahs: surahs,
    nawawi: await b.loadString('assets/data/hadith_nawawi.json'),
    hisnul: await b.loadString('assets/data/hisnul_muslim.json'),
    asma: await b.loadString('assets/data/asma_ul_husna.json'),
    lang: lang,
    translationPack: translationPack,
    hadithPacks: hadithPacks,
    collectionNames: collectionNames,
  );
  return compute(buildIndexFromJson, payload);
}

class SearchPayload {
  const SearchPayload({
    required this.meta,
    required this.surahs,
    required this.nawawi,
    required this.hisnul,
    required this.asma,
    this.lang = 'en',
    this.translationPack,
    this.hadithPacks = const {},
    this.collectionNames = const {},
  });
  final String meta;
  final List<String> surahs;
  final String nawawi;
  final String hisnul;
  final String asma;
  final String lang;

  /// Raw JSON of the user's downloaded Quran translation, if any.
  final String? translationPack;

  /// Raw JSON of each downloaded hadith collection, by collection id.
  final Map<String, String> hadithPacks;

  /// Collection id -> name in the app language.
  final Map<String, String> collectionNames;
}

const _arabicScriptUi = {'ar', 'ur'};

/// Pure: JSON strings in, index out. Public for tests.
SearchIndex buildIndexFromJson(Object payloadObj) {
  final p = payloadObj as SearchPayload;
  final docs = <SearchDoc>[];
  final arabicNames = _arabicScriptUi.contains(p.lang);

  // The user's translation, surah -> ayah texts (index = ayah - 1).
  Map<String, dynamic>? translated;
  final raw = p.translationPack;
  if (raw != null) {
    try {
      translated = (jsonDecode(raw) as Map<String, dynamic>)['surahs']
          as Map<String, dynamic>;
    } catch (_) {}
  }

  final names = <int, String>{};
  for (final s in (jsonDecode(p.meta) as Map<String, dynamic>)['surahs']
      as List<dynamic>) {
    final m = s as Map<String, dynamic>;
    final n = m['number'] as int;
    final translit = m['nameTransliterated'] as String;
    final arabic = m['nameArabic'] as String;
    names[n] = arabicNames ? arabic : translit;
    docs.add(SearchDoc(
      kind: SearchKind.surah,
      route: '/quran/$n',
      title: arabicNames ? '$n. $arabic' : '$n. $translit — ${m['nameEnglish']}',
      arabic: arabic,
      extra: '$translit ${m['nameEnglish']}',
    ));
  }

  for (final rawSurah in p.surahs) {
    final s = jsonDecode(rawSurah) as Map<String, dynamic>;
    final n = s['surah'] as int;
    final mine = translated?['$n'] as List<dynamic>?;
    for (final a in s['ayahs'] as List<dynamic>) {
      final m = a as Map<String, dynamic>;
      final ayah = m['ayah'] as int;
      final english = m['translation'] as String? ?? '';
      String? own;
      if (mine != null && ayah <= mine.length) {
        own = (mine[ayah - 1] as Map<String, dynamic>)['translation']
            as String?;
      }
      final hasOwn = own != null && own.trim().isNotEmpty;
      docs.add(SearchDoc(
        kind: SearchKind.ayah,
        route: '/read?surah=$n&ayah=$ayah',
        title: '${names[n] ?? n} $n:$ayah',
        arabic: m['arabic'] as String? ?? '',
        text: hasOwn ? own : english,
        // English stays searchable when the user's language is shown.
        extra: '${m['transliteration'] ?? ''}${hasOwn ? ' $english' : ''}',
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

  // Downloaded collections: Arabic, the app-language text when the pack
  // has it, English always searchable.
  p.hadithPacks.forEach((collection, rawPack) {
    Map<String, dynamic> chapters;
    try {
      chapters = (jsonDecode(rawPack) as Map<String, dynamic>)['chapters']
          as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final name = p.collectionNames[collection] ?? collection;
    chapters.forEach((chapterKey, chapter) {
      for (final h in (chapter as Map<String, dynamic>)['hadith'] as List) {
        final m = h as Map<String, dynamic>;
        final number = m['number'] as num;
        final label =
            number == number.truncate() ? '${number.toInt()}' : '$number';
        final english = m['translation'] as String? ?? '';
        final own = (m['tr'] as Map<String, dynamic>?)?[p.lang] as String?;
        final hasOwn = own != null && own.isNotEmpty;
        docs.add(SearchDoc(
          kind: SearchKind.hadith,
          route: '/hadith/collections/$collection/$chapterKey',
          title: '$name $label',
          arabic: m['arabic'] as String? ?? '',
          text: hasOwn ? own : english,
          extra: hasOwn ? english : '',
        ));
      }
    });
  });

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
