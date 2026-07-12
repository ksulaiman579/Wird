import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/dua_models.dart';

class DuaRepository {
  DuaRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  HisnulMuslim? _hisnulMuslim;
  AdhkarSet? _adhkar;
  // category-id -> locale -> localized title (chapter headers only).
  Map<String, Map<String, String>>? _titles;

  Future<HisnulMuslim> loadCategories() async {
    final cached = _hisnulMuslim;
    if (cached != null) return cached;

    final raw = await _bundle.loadString('assets/data/hisnul_muslim.json');
    final result =
        HisnulMuslim.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _hisnulMuslim = result;
    await _loadTitles();
    return result;
  }

  Future<void> _loadTitles() async {
    if (_titles != null) return;
    try {
      final raw = await _bundle.loadString('assets/data/dua_title_l10n.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _titles = {
        for (final e in decoded.entries)
          e.key: {
            for (final t in (e.value as Map<String, dynamic>).entries)
              t.key: t.value as String,
          },
      };
    } catch (_) {
      // Missing/malformed title map is non-fatal — callers fall back to
      // the English titleEnglish.
      _titles = {};
    }
  }

  /// Localized display title for [categoryId] in [localeCode] (chapter header
  /// only), falling back to the bundled English title, then [fallback]. Safe
  /// to call synchronously after [loadCategories] has completed.
  String localizedTitle(String categoryId, String localeCode, String fallback) {
    final byLocale = _titles?[categoryId];
    if (byLocale == null) return fallback;
    return byLocale[localeCode] ?? byLocale['en'] ?? fallback;
  }

  Future<DuaCategory> loadCategory(String categoryId) async {
    final all = await loadCategories();
    return all.categories.firstWhere((c) => c.id == categoryId);
  }

  Future<AdhkarSet> loadAdhkar() async {
    final cached = _adhkar;
    if (cached != null) return cached;

    final raw =
        await _bundle.loadString('assets/data/adhkar_morning_evening.json');
    final result = AdhkarSet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _adhkar = result;
    return result;
  }
}

final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  return DuaRepository();
});
