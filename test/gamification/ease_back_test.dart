import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/gamification/ease_back.dart';

void main() {
  group('shouldTriggerEaseBack', () {
    test('never triggers if no session has ever been completed', () {
      expect(
        shouldTriggerEaseBack(lastCompletedDay: null, today: DateTime(2026, 6, 5)),
        false,
      );
    });

    test('does not trigger for a 1 or 2-day gap (0-1 days missed)', () {
      final lastCompleted = DateTime(2026, 6, 1);
      expect(
        shouldTriggerEaseBack(lastCompletedDay: lastCompleted, today: DateTime(2026, 6, 2)),
        false,
      );
      expect(
        shouldTriggerEaseBack(lastCompletedDay: lastCompleted, today: DateTime(2026, 6, 3)),
        false,
      );
    });

    test('does not trigger for exactly a 3-day gap (2 days missed)', () {
      expect(
        shouldTriggerEaseBack(
          lastCompletedDay: DateTime(2026, 6, 1),
          today: DateTime(2026, 6, 4),
        ),
        false,
      );
    });

    test('triggers once the gap reaches 4 days (3 days missed)', () {
      expect(
        shouldTriggerEaseBack(
          lastCompletedDay: DateTime(2026, 6, 1),
          today: DateTime(2026, 6, 5),
        ),
        true,
      );
    });

    test('triggers for a much larger gap too', () {
      expect(
        shouldTriggerEaseBack(
          lastCompletedDay: DateTime(2026, 5, 1),
          today: DateTime(2026, 6, 5),
        ),
        true,
      );
    });

    // Regression test: a gap spanning a DST spring-forward transition must
    // still be counted in whole calendar days. E.g. lastCompleted March 5 →
    // today March 9 is a 4-day gap (3 days missed) that crosses the 2026 US
    // transition (March 8) partway through — passes unconditionally under
    // any timezone, but only exercises the transition under a DST-observing
    // one, e.g. `TZ=America/New_York flutter test test/gamification/ease_back_test.dart`.
    test('correctly counts a gap that spans a DST spring-forward transition',
        () {
      expect(
        shouldTriggerEaseBack(
          lastCompletedDay: DateTime(2026, 3, 5),
          today: DateTime(2026, 3, 9),
        ),
        true,
      );
      expect(
        shouldTriggerEaseBack(
          lastCompletedDay: DateTime(2026, 3, 8),
          today: DateTime(2026, 3, 9),
        ),
        false,
        reason: 'a 1-day gap must never trigger, DST or not',
      );
    });
  });

  group('newBudgetMultiplierFor', () {
    test('halves the new-material budget when active', () {
      expect(newBudgetMultiplierFor(easeBackActive: true), 0.5);
    });

    test('leaves the budget unchanged when inactive', () {
      expect(newBudgetMultiplierFor(easeBackActive: false), 1.0);
    });
  });
}
