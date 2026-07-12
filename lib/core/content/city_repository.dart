import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/city.dart';

class CityRepository {
  CityRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<City>? _cache;

  Future<List<City>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString('assets/data/cities.json');
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(City.fromJson)
        .toList();
    _cache = list;
    return list;
  }
}

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepository();
});
