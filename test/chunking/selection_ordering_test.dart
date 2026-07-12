import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/models/quran_models.dart';
import 'package:wird/core/chunking/selection_ordering.dart';

/// Two 10-ayah surahs split across 3 juz, with a juz boundary that falls
/// in the middle of surah 1 (juz1/juz2) and another in the middle of
/// surah 2 (juz2/juz3) — enough to exercise multi-surah juz spans, merge
/// behavior at boundaries, and reversal, without needing the real 30-juz
/// dataset.
const _meta = QuranMeta(
  surahs: [
    SurahMeta(
      number: 1,
      nameArabic: 'ا',
      nameTransliterated: 'One',
      nameEnglish: 'One',
      ayahCount: 10,
      revelationType: 'meccan',
      startJuz: 1,
    ),
    SurahMeta(
      number: 2,
      nameArabic: 'ب',
      nameTransliterated: 'Two',
      nameEnglish: 'Two',
      ayahCount: 10,
      revelationType: 'medinan',
      startJuz: 1,
    ),
  ],
  juzMap: [
    JuzSpan(
      juz: 1,
      start: AyahRef(surah: 1, ayah: 1),
      end: AyahRef(surah: 1, ayah: 6),
    ),
    JuzSpan(
      juz: 2,
      start: AyahRef(surah: 1, ayah: 7),
      end: AyahRef(surah: 2, ayah: 3),
    ),
    JuzSpan(
      juz: 3,
      start: AyahRef(surah: 2, ayah: 4),
      end: AyahRef(surah: 2, ayah: 10),
    ),
  ],
);

void main() {
  group('orderSelection — surahs', () {
    test('always ascends by surah number regardless of direction', () {
      final normal = orderSelection(
        meta: _meta,
        selectionType: 'surahs',
        selectionIds: [2, 1],
        direction: 'normal',
      );
      final reversed = orderSelection(
        meta: _meta,
        selectionType: 'surahs',
        selectionIds: [2, 1],
        direction: 'reversed',
      );

      for (final slices in [normal, reversed]) {
        expect(slices.map((s) => s.surah), [1, 2]);
        expect(slices[0].startAyah, 1);
        expect(slices[0].endAyah, 10);
      }
    });
  });

  group('orderSelection — juz, normal direction', () {
    test('merges across juz boundaries within the same surah', () {
      final slices = orderSelection(
        meta: _meta,
        selectionType: 'juz',
        selectionIds: [1, 2, 3],
        direction: 'normal',
      );

      // The three juz cover exactly the whole of both surahs, so after
      // merging the juz1/juz2 seam (mid-surah-1) and the juz2/juz3 seam
      // (mid-surah-2), this should collapse to "whole surah 1, whole
      // surah 2" — the same as if surahs had been selected directly.
      expect(slices.length, 2);
      expect(slices[0].surah, 1);
      expect(slices[0].startAyah, 1);
      expect(slices[0].endAyah, 10);
      expect(slices[1].surah, 2);
      expect(slices[1].startAyah, 1);
      expect(slices[1].endAyah, 10);
    });

    test('does not merge across a gap in a non-contiguous selection', () {
      final slices = orderSelection(
        meta: _meta,
        selectionType: 'juz',
        selectionIds: [1, 3], // deliberately skip juz 2
        direction: 'normal',
      );

      expect(slices.length, 2);
      expect(slices[0], isA<SurahSlice>());
      expect(slices[0].surah, 1);
      expect(slices[0].startAyah, 1);
      expect(slices[0].endAyah, 6);
      expect(slices[1].surah, 2);
      expect(slices[1].startAyah, 4);
      expect(slices[1].endAyah, 10);
    });
  });

  group('orderSelection — juz, reversed direction', () {
    test('visits surah 2 before surah 1 (reverse mushaf order)', () {
      final slices = orderSelection(
        meta: _meta,
        selectionType: 'juz',
        selectionIds: [1, 2, 3],
        direction: 'reversed',
      );

      expect(slices.length, 2);
      expect(slices[0].surah, 2);
      expect(slices[1].surah, 1);
    });

    test('ayahs stay in normal ascending order within each surah', () {
      final slices = orderSelection(
        meta: _meta,
        selectionType: 'juz',
        selectionIds: [1, 2, 3],
        direction: 'reversed',
      );

      for (final slice in slices) {
        expect(slice.startAyah, lessThan(slice.endAyah));
      }
      // Full reversed selection still merges to whole-surah spans, same
      // ayah ranges as the normal-direction case — only surah order flips.
      expect(slices[0].startAyah, 1);
      expect(slices[0].endAyah, 10);
      expect(slices[1].startAyah, 1);
      expect(slices[1].endAyah, 10);
    });
  });
}
