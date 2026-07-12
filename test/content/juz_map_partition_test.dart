import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// M21.3 regression: the bundled juz map once had juz 12 starting at 10:1
/// while juz 11 ran 9:93-11:5 — an overlap that made whole-Quran plans
/// generate duplicate srs_items content keys and abort onboarding. The 30
/// juz must partition the Quran contiguously; this guards the shipped
/// asset itself (the build script enforces the same invariant at build
/// time — enforce_juz_partition in tool/build_quran_assets.py).
void main() {
  test('bundled juzMap partitions the Quran contiguously', () {
    final meta = jsonDecode(
            File('assets/data/quran/meta.json').readAsStringSync())
        as Map<String, dynamic>;
    final counts = {
      for (final s in meta['surahs'] as List)
        (s as Map)['number'] as int: s['ayahCount'] as int,
    };
    final juzMap = (meta['juzMap'] as List).cast<Map<String, dynamic>>();

    expect(juzMap, hasLength(30));
    expect(juzMap.first['start'], {'surah': 1, 'ayah': 1});

    for (var i = 1; i < juzMap.length; i++) {
      final prevEnd = juzMap[i - 1]['end'] as Map<String, dynamic>;
      final endSurah = prevEnd['surah'] as int;
      final endAyah = prevEnd['ayah'] as int;
      final expected = endAyah < counts[endSurah]!
          ? {'surah': endSurah, 'ayah': endAyah + 1}
          : {'surah': endSurah + 1, 'ayah': 1};
      expect(juzMap[i]['start'], expected,
          reason: 'juz ${juzMap[i]['juz']} must start right after '
              'juz ${juzMap[i - 1]['juz']} ends');
    }

    final lastEnd = juzMap.last['end'] as Map<String, dynamic>;
    expect(lastEnd, {'surah': 114, 'ayah': counts[114]});
  });
}
