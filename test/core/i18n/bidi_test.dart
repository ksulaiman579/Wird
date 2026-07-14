import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/i18n/bidi.dart';

void main() {
  group('Bidi.isolate', () {
    test('wraps a value in FSI…PDI', () {
      expect(Bidi.isolate(7), '${Bidi.fsi}7${Bidi.pdi}');
    });
  });

  group('Bidi.isolateNumbers', () {
    test('isolates a plain number', () {
      expect(Bidi.isolateNumbers('7 min'), '${Bidi.fsi}7${Bidi.pdi} min');
    });

    test('keeps a leading ~ attached to the number inside one isolate', () {
      // The bug: "~7" rendered as "7~" in RTL. The ~ must be inside the isolate.
      expect(Bidi.isolateNumbers('~7 min'), '${Bidi.fsi}~7${Bidi.pdi} min');
    });

    test('keeps a fraction like 0/7 as a single ordered run', () {
      expect(Bidi.isolateNumbers('0/7 this week'),
          '${Bidi.fsi}0/7${Bidi.pdi} this week');
    });

    test('isolates each number in a multi-number breakdown', () {
      final out = Bidi.isolateNumbers('1 new · 0 reviews · ~7 min');
      expect(out, '${Bidi.fsi}1${Bidi.pdi} new · ${Bidi.fsi}0${Bidi.pdi} '
          'reviews · ${Bidi.fsi}~7${Bidi.pdi} min');
    });

    test('handles Arabic-Indic digits', () {
      expect(Bidi.isolateNumbers('٧ دقيقة'), '${Bidi.fsi}٧${Bidi.pdi} دقيقة');
    });

    test('leaves text without numbers untouched', () {
      expect(Bidi.isolateNumbers('no digits here'), 'no digits here');
    });

    test('does not reverse digit order (digits stay in place)', () {
      final out = Bidi.isolateNumbers('541');
      expect(out.replaceAll(Bidi.fsi, '').replaceAll(Bidi.pdi, ''), '541');
    });
  });
}
