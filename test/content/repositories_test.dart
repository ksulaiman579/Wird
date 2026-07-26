import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/city_repository.dart';
import 'package:wird/core/content/dua_repository.dart';
import 'package:wird/core/content/hadith_repository.dart';
import 'package:wird/core/content/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranRepository', () {
    final repo = QuranRepository();

    test('loads meta with 114 surahs and 30 juz', () async {
      final meta = await repo.loadMeta();
      expect(meta.surahs.length, 114);
      expect(meta.juzMap.length, 30);
      expect(meta.surahs.first.nameTransliterated, 'Al-Fatihah');
    });

    test('loads surah 1 with 7 ayahs', () async {
      final surah = await repo.loadSurah(1);
      expect(surah.ayahs.length, 7);
      expect(surah.ayahs.first.arabic, isNotEmpty);
      expect(surah.ayahs.first.translation, isNotEmpty);
    });

    test('caches surah on repeated load', () async {
      final a = await repo.loadSurah(2);
      final b = await repo.loadSurah(2);
      expect(identical(a, b), isTrue);
    });
  });

  group('HadithRepository', () {
    final repo = HadithRepository();

    test('loads all 42 hadiths', () async {
      final all = await repo.loadAll();
      expect(all.length, 42);
      expect(all.first.id, 1);
      expect(all.first.core, isTrue);
    });

    test('loads hadith by id', () async {
      final h = await repo.loadById(1);
      expect(h.titleEnglish, isNotEmpty);
      expect(h.arabic, isNotEmpty);
    });
  });

  group('DuaRepository', () {
    final repo = DuaRepository();

    test('loads dua categories', () async {
      final result = await repo.loadCategories();
      expect(result.categories, isNotEmpty);
      expect(result.categories.first.duas, isNotEmpty);
    });

    test('loads morning and evening adhkar', () async {
      final adhkar = await repo.loadAdhkar();
      expect(adhkar.morning, isNotEmpty);
      expect(adhkar.evening, isNotEmpty);
    });

    // M25.A: the two lists are NOT interchangeable. Most duas are said in both
    // periods (the evening one swapping asbaha->amsa wording), but a few carry a
    // period-exclusive rubric in the source and must appear in exactly one list.
    // Regression guard: the knowledge/rizq/deeds dua (hm-95) is morning-only and
    // was wrongly showing up in the evening list.
    test('period-exclusive adhkar appear in exactly one list', () async {
      final adhkar = await repo.loadAdhkar();
      final morningIds = adhkar.morning.map((d) => d.id).toSet();
      final eveningIds = adhkar.evening.map((d) => d.id).toSet();

      for (final id in const ['hm-93', 'hm-94', 'hm-95']) {
        expect(morningIds, contains(id), reason: '$id is morning-only');
        expect(eveningIds, isNot(contains(id)), reason: '$id must not be evening');
      }
      expect(eveningIds, contains('hm-97'), reason: 'hm-97 is evening-only');
      expect(morningIds, isNot(contains('hm-97')),
          reason: 'hm-97 must not be morning');
    });

    // The asbaha/amsa split must not leak across periods.
    test('morning uses asbaha wording and evening uses amsa wording', () async {
      final adhkar = await repo.loadAdhkar();
      for (final d in adhkar.morning) {
        expect(d.arabic, isNot(contains('أَمْسَيْنَا وَأَمْسَى')));
        expect(d.arabic, isNot(contains('أَمْسَيْتُ')));
      }
      for (final d in adhkar.evening) {
        expect(d.arabic, isNot(contains('أَصْبَحْنَا وَأَصْبَحَ')));
        expect(d.arabic, isNot(contains('أَصْبَحْتُ')));
      }
      // The signature pair actually flipped.
      expect(
        adhkar.morning.firstWhere((d) => d.id == 'hm-77').arabic,
        contains('أَصْبَحْنَا وَأَصْبَحَ'),
      );
      expect(
        adhkar.evening.firstWhere((d) => d.id == 'hm-77').arabic,
        contains('أَمْسَيْنَا وَأَمْسَى'),
      );
    });

    // No "say this in the morning / that in the evening" instructions should
    // survive in either list — each list shows one clean form.
    test('no cross-period instruction notes remain', () async {
      final adhkar = await repo.loadAdhkar();
      for (final d in [...adhkar.morning, ...adhkar.evening]) {
        final blob = '${d.arabic} ${d.translation} ${d.transliteration ?? ''}';
        for (final marker in const [
          'إذا أصبحَ',
          'إذا أمسى',
          'وإذا',
          'In the evening',
          'For the evening',
          'Note:',
          'instead of',
        ]) {
          expect(blob, isNot(contains(marker)),
              reason: '${d.id} still carries "$marker"');
        }
      }
    });
  });

  group('CityRepository', () {
    final repo = CityRepository();

    test('loads at least 150 cities with valid coordinates', () async {
      final cities = await repo.loadAll();
      expect(cities.length, greaterThanOrEqualTo(150));
      for (final city in cities) {
        expect(city.lat, inClosedOpenRange(-90, 90.001));
        expect(city.lng, inClosedOpenRange(-180, 180.001));
      }
      expect(cities.any((c) => c.name == 'Riyadh'), isTrue);
    });

    test('caches the list on repeated load', () async {
      final a = await repo.loadAll();
      final b = await repo.loadAll();
      expect(identical(a, b), isTrue);
    });
  });
}
