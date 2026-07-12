import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/calendar_math.dart';

void main() {
  group('daysBetweenCalendarDates', () {
    test('ordinary consecutive days', () {
      expect(
        daysBetweenCalendarDates(DateTime(2026, 1, 1), DateTime(2026, 1, 2)),
        1,
      );
    });

    test('same day is zero regardless of time-of-day', () {
      expect(
        daysBetweenCalendarDates(
          DateTime(2026, 1, 1, 23, 59),
          DateTime(2026, 1, 1, 0, 1),
        ),
        0,
      );
    });

    test('crosses a month boundary', () {
      expect(
        daysBetweenCalendarDates(DateTime(2026, 1, 31), DateTime(2026, 2, 1)),
        1,
      );
    });

    test('crosses a leap-year February', () {
      // 2028 is a leap year — Feb has 29 days.
      expect(
        daysBetweenCalendarDates(DateTime(2028, 2, 28), DateTime(2028, 2, 29)),
        1,
      );
      expect(
        daysBetweenCalendarDates(DateTime(2028, 2, 29), DateTime(2028, 3, 1)),
        1,
      );
    });

    test('crosses a year boundary', () {
      expect(
        daysBetweenCalendarDates(DateTime(2026, 12, 31), DateTime(2027, 1, 1)),
        1,
      );
    });

    test('a larger gap counts every calendar day, not just full 24h blocks', () {
      expect(
        daysBetweenCalendarDates(DateTime(2026, 1, 1), DateTime(2026, 1, 10)),
        9,
      );
    });

    // Regression test for the actual bug this module exists to fix:
    // DateTime(2026, 3, 8) → DateTime(2026, 3, 9) straddles the 2026 US
    // spring-forward transition (2am on March 8th). Comparing local
    // midnights across it is only a 23-hour gap in absolute time, so the
    // naive `.difference(...).inDays` gives 0 instead of 1 — this test
    // only exercises that path when the suite runs under a DST-observing
    // TZ (this repo's CI/dev container defaults to UTC, which has no DST,
    // so this assertion is a no-op guard there; run with
    // `TZ=America/New_York flutter test test/core/calendar_math_test.dart`
    // to actually exercise the transition).
    test('is immune to a DST spring-forward transition in the local timezone', () {
      final before = DateTime(2026, 3, 8);
      final after = DateTime(2026, 3, 9);
      expect(daysBetweenCalendarDates(before, after), 1);
    });
  });

  group('addCalendarDays', () {
    test('ordinary addition lands at local midnight', () {
      final result = addCalendarDays(DateTime(2026, 1, 1), 5);
      expect(result, DateTime(2026, 1, 6));
      expect(result.hour, 0);
    });

    test('rolls over a month boundary', () {
      expect(addCalendarDays(DateTime(2026, 1, 30), 3), DateTime(2026, 2, 2));
    });

    test('rolls over a leap-year February', () {
      expect(addCalendarDays(DateTime(2028, 2, 28), 2), DateTime(2028, 3, 1));
    });

    test('rolls over a year boundary', () {
      expect(addCalendarDays(DateTime(2026, 12, 30), 5), DateTime(2027, 1, 4));
    });

    // Regression test for the sm2_scheduler dueDate-drift bug: adding a
    // Duration(days: n) to a local DateTime can land off midnight across a
    // DST transition (confirmed under TZ=America/New_York: adding 1 day to
    // 2026-03-08 lands at 01:00, not midnight). addCalendarDays must not.
    test('stays exactly at midnight across a DST spring-forward transition', () {
      final result = addCalendarDays(DateTime(2026, 3, 8), 1);
      expect(result, DateTime(2026, 3, 9));
      expect(result.hour, 0);
    });
  });
}
