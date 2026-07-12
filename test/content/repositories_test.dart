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
      expect(adhkar.evening.length, adhkar.morning.length);
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
