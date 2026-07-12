import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/models/quran_models.dart';
import 'package:wird/core/chunking/ayah_grouper.dart';

Ayah _ayah(int number, int wordCount) => Ayah(
      ayah: number,
      arabic: 'x' * wordCount,
      translation: 'x',
      transliteration: 'x',
      juz: 1,
      wordCount: wordCount,
    );

void main() {
  test('groups short ayahs together up to ~max words', () {
    // 5 words each: 5,10,15,20 (>=15, stop),25(new group) -> groups of
    // [1,2,3] (5+5+5=15) then [4] (5, next would be 20>... wait compute.
    final ayahs = [1, 2, 3, 4, 5].map((n) => _ayah(n, 5)).toList();
    final groups = groupAyahs(1, ayahs);

    // Greedy: start ayah1 (5 words) < min(15) -> add ayah2 (10) < min -> add
    // ayah3 (15) >= min -> stop. Group1 = ayahs 1-3, 15 words.
    // Then ayah4 (5) < min -> add ayah5 (10) >= min -> stop. Group2 = 4-5, 10 words.
    expect(groups.length, 2);
    expect(groups[0].startAyah, 1);
    expect(groups[0].endAyah, 3);
    expect(groups[0].wordCount, 15);
    expect(groups[1].startAyah, 4);
    expect(groups[1].endAyah, 5);
    expect(groups[1].wordCount, 10);
  });

  test('never splits a single ayah, even when it exceeds the max', () {
    final ayahs = [_ayah(1, 3), _ayah(2, 40), _ayah(3, 3)];
    final groups = groupAyahs(1, ayahs);

    // Ayah 2 alone is already over max; it must not be merged with
    // neighbors, and neighbors must not be forced into it either.
    final oversized = groups.firstWhere((g) => g.startAyah == 2);
    expect(oversized.endAyah, 2);
    expect(oversized.wordCount, 40);
  });

  test('stops adding once the sum would exceed max, even if under min', () {
    // 20 words then a 10-word ayah: 20+10=30 > max(25), so they must not
    // be combined even though 20 < min(15)... wait 20 >= min already.
    // Use a case genuinely under min: 10 words, then 20 words (10+20=30>25).
    final ayahs = [_ayah(1, 10), _ayah(2, 20)];
    final groups = groupAyahs(1, ayahs);

    expect(groups.length, 2);
    expect(groups[0].wordCount, 10);
    expect(groups[1].wordCount, 20);
  });

  test('contentKey formats single vs multi-ayah groups correctly', () {
    final single = groupAyahs(2, [_ayah(5, 40)]).single;
    expect(single.contentKey, 'q:2:5');

    final multi = groupAyahs(3, [_ayah(1, 5), _ayah(2, 5), _ayah(3, 5)]).single;
    expect(multi.contentKey, 'q:3:1-3');
  });

  test('covers every ayah exactly once with no gaps', () {
    final ayahs = List.generate(20, (i) => _ayah(i + 1, (i % 5) + 2));
    final groups = groupAyahs(1, ayahs);

    var expectedNext = 1;
    for (final g in groups) {
      expect(g.startAyah, expectedNext);
      expect(g.endAyah, greaterThanOrEqualTo(g.startAyah));
      expectedNext = g.endAyah + 1;
    }
    expect(expectedNext, 21);
  });
}
