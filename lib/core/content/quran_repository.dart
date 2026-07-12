import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/quran_models.dart';

/// Loads the Quran meta (surah list + juz map) eagerly, and individual
/// surahs lazily on first access, caching each in memory once loaded.
class QuranRepository {
  QuranRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  QuranMeta? _meta;
  final Map<int, Surah> _surahCache = {};

  Future<QuranMeta> loadMeta() async {
    final cached = _meta;
    if (cached != null) return cached;

    final raw = await _bundle.loadString('assets/data/quran/meta.json');
    final meta = QuranMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _meta = meta;
    return meta;
  }

  Future<Surah> loadSurah(int surahNumber) async {
    final cached = _surahCache[surahNumber];
    if (cached != null) return cached;

    final padded = surahNumber.toString().padLeft(3, '0');
    final raw = await _bundle.loadString('assets/data/quran/surah_$padded.json');
    final surah = Surah.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _surahCache[surahNumber] = surah;
    return surah;
  }
}

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});
