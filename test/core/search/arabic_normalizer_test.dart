import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/search/arabic_normalizer.dart';

void main() {
  test('ta marbuta and ha match', () {
    expect(searchMatches('الفاتحة', 'الفاتحه'), isTrue);
  });

  test('harakat and Quranic marks are ignored', () {
    expect(searchMatches('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', 'بسم الله'),
        isTrue);
    expect(searchMatches('ٱلرَّحۡمَٰنِ', 'الرحمن'), isTrue);
  });

  test('alef forms fold together', () {
    expect(normalizeForSearch('أإآٱ'), normalizeForSearch('اااا'));
  });

  test('alef maqsura and ya match', () {
    expect(searchMatches('موسى', 'موسي'), isTrue);
  });

  test('tatweel is dropped', () {
    expect(normalizeForSearch('اللـــه'), normalizeForSearch('الله'));
  });

  test('Urdu letter forms match the Arabic ones', () {
    expect(searchMatches('کتاب', 'كتاب'), isTrue);
    expect(searchMatches('نبی', 'نبي'), isTrue);
  });

  test('Arabic-Indic digits match ASCII', () {
    expect(normalizeForSearch('٢٥٥'), '255');
  });

  test('Latin is case- and accent-insensitive', () {
    expect(searchMatches('Al-Fātiḥah', 'al-fatihah'), isTrue);
    expect(searchMatches("Mu'awwidhatayn", 'muawwidhatayn'), isTrue);
  });

  test('invisible bidi marks are removed', () {
    expect(normalizeForSearch('\u2068255\u2069'), '255');
  });

  test('empty query matches everything', () {
    expect(searchMatches('anything', '  '), isTrue);
  });
}
