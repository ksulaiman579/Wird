import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/content/dua_search.dart';
import 'package:wird/core/content/models/dua_models.dart';

Dua _dua(String translation, {String reference = ''}) => Dua(
      id: 'd',
      arabic: 'x',
      translation: translation,
      reference: reference,
      repetitions: 1,
      wordCount: 1,
    );

DuaCategory _cat(String title, {List<Dua>? duas}) => DuaCategory(
      id: title,
      titleEnglish: title,
      order: 0,
      duas: duas ?? const [],
    );

void main() {
  group('duaSearchMatches', () {
    final istikhara = _cat(
      "Istikharah (seeking Allah's Counsel)",
      duas: [_dua('O Allah, guide me to the good in this matter.')],
    );
    final worry = _cat('Invocations in times of worry and grief');
    final rain = _cat('Some invocations for rain');
    final all = [istikhara, worry, rain];

    test('empty query returns everything', () {
      expect(duaSearchMatches(all, ''), all);
      expect(duaSearchMatches(all, '   '), all);
    });

    test('plain title substring still matches', () {
      expect(duaSearchMatches(all, 'rain'), [rain]);
    });

    test('synonym "guidance" finds Istikharah despite "Counsel" title', () {
      expect(duaSearchMatches(all, 'guidance'), [istikhara]);
    });

    test('matches inside dua translation text', () {
      // "guide" appears only in the dua body, not the title.
      expect(duaCategoryMatches(istikhara, 'guide'), isTrue);
    });

    test('synonym "anxiety" finds worry/grief category', () {
      expect(duaSearchMatches(all, 'anxiety'), [worry]);
    });

    test('is case-insensitive and trims', () {
      expect(duaSearchMatches(all, '  RAIN '), [rain]);
    });

    test('non-matching query returns empty', () {
      expect(duaSearchMatches(all, 'zzznope'), isEmpty);
    });
  });
}
