import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/hadith_repository.dart';
import '../../core/content/models/hadith_model.dart';

final hadithListProvider = FutureProvider<List<Hadith>>((ref) {
  return ref.watch(hadithRepositoryProvider).loadAll();
});

final hadithByIdProvider = FutureProvider.family<Hadith, int>((ref, id) {
  return ref.watch(hadithRepositoryProvider).loadById(id);
});

/// Extra-language Nawawi texts: id -> {lang: text} (Bengali, from the
/// same source as the English; built by tool/build_nawawi_translations.py).
final nawawiTranslationsProvider =
    FutureProvider<Map<String, Map<String, String>>>((ref) async {
  return _loadLangMap('assets/data/hadith_nawawi_tr.json');
});

/// Nawawi chapter titles per app language: id -> {lang: title}.
final nawawiTitlesProvider =
    FutureProvider<Map<String, Map<String, String>>>((ref) async {
  return _loadLangMap('assets/data/hadith_nawawi_titles.json');
});

Future<Map<String, Map<String, String>>> _loadLangMap(String path) async {
  try {
    final raw = jsonDecode(await rootBundle.loadString(path))
        as Map<String, dynamic>;
    return {
      for (final e in raw.entries)
        e.key: {
          for (final t in (e.value as Map<String, dynamic>).entries)
            t.key: t.value as String,
        },
    };
  } catch (_) {
    return const {};
  }
}
