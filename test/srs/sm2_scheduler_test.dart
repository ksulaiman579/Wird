import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/srs/sm2_scheduler.dart';

void main() {
  final day1 = DateTime(2026, 1, 1);

  group('new item → learning progression', () {
    test('Good on a new item enters learning at the +1 day step', () {
      final result = schedule(Sm2State.newItem, Grade.good, day1);

      expect(result.status, ItemStatus.learning);
      expect(result.learningStep, 1);
      expect(result.intervalDays, 1);
      expect(result.dueDate, DateTime(2026, 1, 2));
    });

    test('Again on a new item restarts at the first (same-day) step', () {
      final result = schedule(Sm2State.newItem, Grade.again, day1);

      expect(result.status, ItemStatus.learning);
      expect(result.learningStep, 0);
      expect(result.intervalDays, 0);
      expect(result.dueDate, day1);
    });

    test('full new-item ladder graduates to review at 7 days', () {
      var state = schedule(Sm2State.newItem, Grade.good, day1); // step 0->1
      expect(state.intervalDays, 1);

      state = schedule(state, Grade.good, day1); // step 1->2 (+3 days)
      expect(state.status, ItemStatus.learning);
      expect(state.intervalDays, 3);

      state = schedule(state, Grade.good, day1); // graduates
      expect(state.status, ItemStatus.review);
      expect(state.intervalDays, 7);
      expect(state.repetitions, 0);
      expect(state.dueDate, day1.add(const Duration(days: 7)));
    });

    test('Again mid-ladder sends it back to the first step', () {
      var state = schedule(Sm2State.newItem, Grade.good, day1); // step 1
      state = schedule(state, Grade.again, day1);

      expect(state.status, ItemStatus.learning);
      expect(state.learningStep, 0);
      expect(state.intervalDays, 0);
    });
  });

  group('review phase interval growth', () {
    Sm2State graduated() {
      var state = schedule(Sm2State.newItem, Grade.good, day1);
      state = schedule(state, Grade.good, day1);
      return schedule(state, Grade.good, day1); // now in review, interval 7
    }

    test('Good keeps ease factor the same and grows interval by ~EF', () {
      final before = graduated();
      final after = schedule(before, Grade.good, day1);

      expect(after.status, ItemStatus.review);
      expect(after.easeFactor, closeTo(2.5, 0.0001));
      // 7 * 2.5 * 1.0 = 17.5 -> rounds to 18
      expect(after.intervalDays, 18);
      expect(after.repetitions, 1);
    });

    test('Easy increases ease factor and grows the interval fastest', () {
      final before = graduated();
      final after = schedule(before, Grade.easy, day1);

      expect(after.easeFactor, greaterThan(2.5));
      // 7 * 2.6 * 1.3 = 23.66 -> rounds to 24
      expect(after.intervalDays, 24);
    });

    test('Hard decreases ease factor and grows the interval slowest', () {
      final before = graduated();
      final after = schedule(before, Grade.hard, day1);

      expect(after.easeFactor, lessThan(2.5));
      expect(after.intervalDays, greaterThan(before.intervalDays));
      // Hard's smaller multiplier should still beat plain Good's growth.
      final goodAfter = schedule(before, Grade.good, day1);
      expect(after.intervalDays, lessThan(goodAfter.intervalDays));
    });

    test('interval never shrinks or repeats, even on Hard from a small base',
        () {
      // Force a tiny interval/ease combination where hard*ease*0.8 would
      // otherwise round down to <= the previous interval.
      const tiny = Sm2State(
        status: ItemStatus.review,
        easeFactor: 1.3,
        intervalDays: 1,
      );
      final after = schedule(tiny, Grade.hard, day1);
      expect(after.intervalDays, greaterThanOrEqualTo(tiny.intervalDays + 1));
    });

    test('ease factor never drops below the 1.3 floor', () {
      var state = graduated();
      for (var i = 0; i < 20; i++) {
        state = schedule(state, Grade.hard, day1);
      }
      expect(state.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('interval is clamped at 365 days', () {
      const nearMax = Sm2State(
        status: ItemStatus.review,
        easeFactor: 2.5,
        intervalDays: 300,
      );
      final after = schedule(nearMax, Grade.easy, day1);
      expect(after.intervalDays, 365);
    });
  });

  group('lapses', () {
    Sm2State graduated() {
      var state = schedule(Sm2State.newItem, Grade.good, day1);
      state = schedule(state, Grade.good, day1);
      return schedule(state, Grade.good, day1);
    }

    test('Again during review lapses with a reduced ease factor', () {
      final before = graduated();
      final after = schedule(before, Grade.again, day1);

      expect(after.status, ItemStatus.lapsed);
      expect(after.easeFactor, closeTo(2.3, 0.0001));
      expect(after.intervalDays, 1);
      expect(after.repetitions, 0);
    });

    test('lapsed items climb 1d -> 3d -> back to review', () {
      var state = schedule(graduated(), Grade.again, day1); // lapsed, step 0
      expect(state.intervalDays, 1);

      state = schedule(state, Grade.good, day1); // lapsed, step 1 (3 days)
      expect(state.status, ItemStatus.lapsed);
      expect(state.intervalDays, 3);

      state = schedule(state, Grade.good, day1); // re-graduates
      expect(state.status, ItemStatus.review);
      expect(state.intervalDays, 7);
      // The reduced ease factor from the lapse carries forward.
      expect(state.easeFactor, closeTo(2.3, 0.0001));
    });

    test('Again while lapsed restarts the lapse ladder', () {
      var state = schedule(graduated(), Grade.again, day1);
      state = schedule(state, Grade.good, day1); // step 1
      state = schedule(state, Grade.again, day1); // back to step 0

      expect(state.status, ItemStatus.lapsed);
      expect(state.learningStep, 0);
      expect(state.intervalDays, 1);
    });
  });

  group('Grade.q mapping', () {
    test('matches the documented SM-2 quality scale', () {
      expect(Grade.again.q, 1);
      expect(Grade.hard.q, 3);
      expect(Grade.good.q, 4);
      expect(Grade.easy.q, 5);
    });
  });

  group('DST safety', () {
    // Regression test: grading on the day of (or just before) a DST
    // spring-forward transition must still produce a dueDate at exact
    // midnight of the correct calendar date — `today.add(Duration(days:
    // n))` (the old implementation) lands an hour off midnight once the
    // transition is in between. Passes unconditionally under any
    // timezone, but only exercises the transition under a DST-observing
    // one, e.g. `TZ=America/New_York flutter test test/srs/sm2_scheduler_test.dart`.
    test('dueDate lands exactly at midnight across a DST transition', () {
      final beforeTransition = DateTime(2026, 3, 8); // 2026 US transition day
      final result = schedule(Sm2State.newItem, Grade.good, beforeTransition);

      expect(result.dueDate, DateTime(2026, 3, 9));
      expect(result.dueDate!.hour, 0);
    });
  });
}
