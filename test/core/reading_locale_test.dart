import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/l10n/reading_locale.dart';

void main() {
  test('Latin reading aids are hidden only for Arabic', () {
    expect(showLatinReadingAids(const Locale('ar')), isFalse);
    expect(showLatinReadingAids(const Locale('en')), isTrue);
    expect(showLatinReadingAids(const Locale('ur')), isTrue);
    expect(showLatinReadingAids(const Locale('fr')), isTrue);
  });
}
