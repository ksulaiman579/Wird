import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/adhkar/adhkar_window.dart';

void main() {
  group('adhkarPeriodFor with real prayer times', () {
    final fajr = DateTime(2026, 3, 5, 5, 20);
    final asr = DateTime(2026, 3, 5, 15, 45);

    test('exactly at fajr is morning', () {
      expect(adhkarPeriodFor(fajr, fajr: fajr, asr: asr), AdhkarPeriod.morning);
    });

    test('between fajr and asr is morning', () {
      final at = DateTime(2026, 3, 5, 10);
      expect(adhkarPeriodFor(at, fajr: fajr, asr: asr), AdhkarPeriod.morning);
    });

    test('exactly at asr is evening', () {
      expect(adhkarPeriodFor(asr, fajr: fajr, asr: asr), AdhkarPeriod.evening);
    });

    test('after asr, before midnight is evening', () {
      final at = DateTime(2026, 3, 5, 22);
      expect(adhkarPeriodFor(at, fajr: fajr, asr: asr), AdhkarPeriod.evening);
    });

    test('before fajr (past midnight) is evening', () {
      final at = DateTime(2026, 3, 5, 2);
      expect(adhkarPeriodFor(at, fajr: fajr, asr: asr), AdhkarPeriod.evening);
    });
  });

  group('adhkarPeriodFor fallback (no prayer times)', () {
    test('06:00 falls in the morning window', () {
      final at = DateTime(2026, 3, 5, 6);
      expect(adhkarPeriodFor(at), AdhkarPeriod.morning);
    });

    test('16:59 is still morning, 17:00 flips to evening', () {
      expect(adhkarPeriodFor(DateTime(2026, 3, 5, 16, 59)),
          AdhkarPeriod.morning);
      expect(
          adhkarPeriodFor(DateTime(2026, 3, 5, 17)), AdhkarPeriod.evening);
    });

    test('05:59 is still evening (before the morning window opens)', () {
      expect(
          adhkarPeriodFor(DateTime(2026, 3, 5, 5, 59)), AdhkarPeriod.evening);
    });
  });

  group('adhkarDayFor', () {
    test('evening adhkar after midnight belongs to the evening before', () {
      expect(adhkarDayFor('evening', DateTime(2026, 3, 1, 0, 30)),
          DateTime(2026, 2, 28));
    });
    test('evening adhkar in the evening belongs to that day', () {
      expect(adhkarDayFor('evening', DateTime(2026, 3, 1, 20)),
          DateTime(2026, 3, 1));
    });
    test('morning adhkar always belongs to the clock day', () {
      expect(adhkarDayFor('morning', DateTime(2026, 3, 1, 5)),
          DateTime(2026, 3, 1));
    });
    test('key format is stable for existing saved prefs', () {
      expect(adhkarCompletedKey('morning', DateTime(2026, 1, 5)),
          'adhkar_completed_morning_2026-01-05');
    });
  });
}
