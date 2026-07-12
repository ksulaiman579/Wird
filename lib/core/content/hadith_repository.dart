import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/hadith_model.dart';

class HadithRepository {
  HadithRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<Hadith>? _cache;

  Future<List<Hadith>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString('assets/data/hadith_nawawi.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(Hadith.fromJson)
        .toList();
    _cache = list;
    return list;
  }

  Future<Hadith> loadById(int id) async {
    final all = await loadAll();
    return all.firstWhere((h) => h.id == id);
  }
}

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository();
});
