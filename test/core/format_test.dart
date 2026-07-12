import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/l10n/format.dart';

const _fsi = '⁨';
const _pdi = '⁩';

void main() {
  group('bidiIsolate', () {
    test('wraps a run in FSI/PDI', () {
      expect(bidiIsolate('7'), '${_fsi}7$_pdi');
    });
    test('empty stays empty', () {
      expect(bidiIsolate(''), '');
    });
  });

  group('bidiMetaRow', () {
    test('joins isolated parts with a middle dot', () {
      final row = bidiMetaRow(['7 ayahs', 'Meccan', 'Juz 1']);
      expect(row, '${bidiIsolate('7 ayahs')} · ${bidiIsolate('Meccan')} · ${bidiIsolate('Juz 1')}');
    });
    test('drops blank parts', () {
      expect(bidiMetaRow(['7 ayahs', '', '  ']), bidiIsolate('7 ayahs'));
    });
    test('each numeric part is isolated so it cannot reorder', () {
      // The bug was the leading count migrating to the end under RTL; every
      // segment being individually isolated prevents that.
      final row = bidiMetaRow(['7 ayahs', 'Juz 1']);
      expect(row.startsWith(_fsi), isTrue);
      expect(row.contains('$_pdi · $_fsi'), isTrue);
    });
  });

  group('bidiSequence', () {
    test('isolates a multi-number label', () {
      expect(bidiSequence([33, 33, 34]), bidiIsolate('33 - 33 - 34'));
    });
  });
}
