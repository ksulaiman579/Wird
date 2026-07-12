import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/hadith/hadith_grade.dart';
import 'package:wird/features/hadith/hadith_detail_screen.dart';

void main() {
  group('narratorLine (Item A3 — no doubled prefix)', () {
    test('prefixes a plain narrator name', () {
      expect(narratorLine('Abu Hurayrah (ra)'), 'Narrated by Abu Hurayrah (ra)');
    });

    test('does NOT prefix when the text already narrates', () {
      const s = "It is narrated on the authority of Amirul Mu'minin, Abu Hafs";
      expect(narratorLine(s), s);
    });

    test('does not double "Narrated by"', () {
      expect(narratorLine('Narrated by Umar'), 'Narrated by Umar');
    });

    test('trims whitespace', () {
      expect(narratorLine('  Aisha  '), 'Narrated by Aisha');
    });
  });

  group('nawawiGradeFromSource (Item A4)', () {
    test('two Sahihs → Sahih', () {
      expect(nawawiGradeFromSource('Bukhari & Muslim').authenticity,
          HadithAuthenticity.sahih);
      expect(nawawiGradeFromSource('Muslim').authenticity,
          HadithAuthenticity.sahih);
    });

    test('grade words in source are honoured', () {
      expect(nawawiGradeFromSource('Tirmidhi — hasan').authenticity,
          HadithAuthenticity.hasan);
    });

    test('unknown/plain source → ungraded, not guessed', () {
      expect(nawawiGradeFromSource('Recorded by an-Nawawi').authenticity,
          HadithAuthenticity.ungraded);
    });
  });
}
