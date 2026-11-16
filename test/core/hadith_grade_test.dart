import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/hadith/hadith_grade.dart';

void main() {
  group('classifyGradeString', () {
    test('sahih variants', () {
      expect(classifyGradeString('Sahih'), HadithAuthenticity.sahih);
      expect(classifyGradeString('Sahih li ghairihi'), HadithAuthenticity.sahih);
      // "Hasan Sahih" (Tirmidhi) resolves to authentic, not weak.
      expect(classifyGradeString('Hasan Sahih'), HadithAuthenticity.sahih);
      expect(classifyGradeString('صحيح'), HadithAuthenticity.sahih);
    });

    test('hasan', () {
      expect(classifyGradeString('Hasan'), HadithAuthenticity.hasan);
      expect(classifyGradeString('حسن'), HadithAuthenticity.hasan);
    });

    test('daif variants take priority over any sahih substring', () {
      expect(classifyGradeString("Da'if"), HadithAuthenticity.daif);
      expect(classifyGradeString('Daif jiddan'), HadithAuthenticity.daif);
      expect(classifyGradeString('weak'), HadithAuthenticity.daif);
      expect(classifyGradeString('Munkar'), HadithAuthenticity.daif);
      expect(classifyGradeString('ضعيف'), HadithAuthenticity.daif);
    });

    test('fabricated', () {
      expect(classifyGradeString('Mawdu'), HadithAuthenticity.mawdu);
      expect(classifyGradeString('Maudu (fabricated)'), HadithAuthenticity.mawdu);
    });

    test('empty / unknown → ungraded', () {
      expect(classifyGradeString(''), HadithAuthenticity.ungraded);
      expect(classifyGradeString('n/a'), HadithAuthenticity.ungraded);
    });
  });

  group('resolveHadithGrade', () {
    test('uses the first grader verdict', () {
      final g = resolveHadithGrade(
        [
          {'name': 'al-Albani', 'grade': "Da'if"},
        ],
        'abudawud',
      );
      expect(g.authenticity, HadithAuthenticity.daif);
      expect(g.grader, 'al-Albani');
      expect(g.rawGrade, "Da'if");
    });

    test('bukhari/muslim with no grade → sahih by the book\'s status', () {
      expect(resolveHadithGrade(const [], 'bukhari').authenticity,
          HadithAuthenticity.sahih);
      expect(resolveHadithGrade(const [], 'muslim').authenticity,
          HadithAuthenticity.sahih);
    });

    test('other collection with no grade → ungraded, never guessed', () {
      expect(resolveHadithGrade(const [], 'abudawud').authenticity,
          HadithAuthenticity.ungraded);
      expect(resolveHadithGrade(const [], 'malik').authenticity,
          HadithAuthenticity.ungraded);
    });

    test('ignores empty grade entries and falls through', () {
      final g = resolveHadithGrade(
        [
          {'name': 'x', 'grade': ''},
        ],
        'tirmidhi',
      );
      expect(g.authenticity, HadithAuthenticity.ungraded);
    });
  });

  group('grader preference (WQA-014/015)', () {
    Map<String, String> g(String name, String grade) =>
        {'name': name, 'grade': grade};

    test('Al-Albani wins even when listed last', () {
      final r = resolveHadithGrade([
        g('Abu Ghuddah', 'Daif'),
        g('Zubair Ali Zai', 'Sahih'),
        g('Al-Albani', 'Sahih'),
      ], 'nasai');
      expect(r.grader, 'Al-Albani');
      expect(r.authenticity, HadithAuthenticity.sahih);
      expect([for (final o in r.others) o.grader], ['Abu Ghuddah']);
    });

    test('Zubair Ali Zai is the fallback when Albani is absent', () {
      final r = resolveHadithGrade([
        g('Ahmad Muhammad Shakir', 'Sahih'),
        g('Zubair Ali Zai', 'Hasan'),
      ], 'tirmidhi');
      expect(r.grader, 'Zubair Ali Zai');
      expect(r.authenticity, HadithAuthenticity.hasan);
      expect(r.others.single.grader, 'Ahmad Muhammad Shakir');
    });

    test('agreeing scholars are not listed as others', () {
      final r = resolveHadithGrade(
          [g('Al-Albani', 'Sahih'), g('Zubair Ali Zai', 'Hasan Sahih')],
          'abudawud');
      expect(r.others, isEmpty);
    });

    test("a '-' placeholder is not a grade", () {
      final r = resolveHadithGrade(
          [g('Abu Ghuddah', '-'), g('Al-Albani', 'Hasan')], 'nasai');
      expect(r.grader, 'Al-Albani');
      expect(r.others, isEmpty);
    });

    test('Shadh counts as weak', () {
      expect(classifyGradeString('Shadh'), HadithAuthenticity.daif);
      expect(classifyGradeString('شاذ'), HadithAuthenticity.daif);
    });
  });

  group('authenticity info', () {
    test('sahih/hasan are not cautionary; others are', () {
      expect(HadithAuthenticity.sahih.isCautionary, false);
      expect(HadithAuthenticity.hasan.isCautionary, false);
      expect(HadithAuthenticity.daif.isCautionary, true);
      expect(HadithAuthenticity.mawdu.isCautionary, true);
      expect(HadithAuthenticity.ungraded.isCautionary, true);
    });

    test('cautionary verdicts carry a non-empty caution', () {
      expect(HadithAuthenticity.daif.caution, isNotEmpty);
      expect(HadithAuthenticity.mawdu.caution, isNotEmpty);
      expect(HadithAuthenticity.ungraded.caution, isNotEmpty);
      expect(HadithAuthenticity.sahih.caution, isEmpty);
    });
  });

  group('collectionAuthenticityNote', () {
    test('sahihs vs sunan differ', () {
      expect(collectionAuthenticityNote('bukhari'), contains('authentic'));
      expect(collectionAuthenticityNote('abudawud'), contains('varying'));
      expect(collectionAuthenticityNote('malik'), contains('Muwa'));
    });
  });
}
