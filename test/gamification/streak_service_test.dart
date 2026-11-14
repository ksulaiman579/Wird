import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/gamification/streak_service.dart';

DateTime _day(int offsetFromEpoch) =>
    DateTime(2026, 1, 1).add(Duration(days: offsetFromEpoch));

void main() {
  test('first-ever completion starts the streak at 1', () {
    final result = applyCompletion(StreakState.empty, _day(0));

    expect(result.currentStreak, 1);
    expect(result.longestStreak, 1);
    expect(result.freezeTokens, 0);
    expect(result.lastCompletedDay, _day(0));
  });

  test('same-day repeat is a no-op', () {
    final first = applyCompletion(StreakState.empty, _day(0));
    final repeat = applyCompletion(first, _day(0));

    expect(repeat.currentStreak, first.currentStreak);
    expect(repeat.lastCompletedDay, first.lastCompletedDay);
  });

  test('consecutive days increment the streak', () {
    var state = applyCompletion(StreakState.empty, _day(0));
    state = applyCompletion(state, _day(1));
    state = applyCompletion(state, _day(2));

    expect(state.currentStreak, 3);
    expect(state.longestStreak, 3);
  });

  test('a one-day gap with a banked freeze token continues the streak', () {
    var state = const StreakState(
      currentStreak: 5,
      longestStreak: 5,
      freezeTokens: 1,
      lastCompletedDay: null,
    ).copyWith(lastCompletedDay: _day(0));

    // Skip day 1 entirely, complete again on day 2 (gap of 2 calendar
    // days = one full missed day).
    state = applyCompletion(state, _day(2));

    expect(state.currentStreak, 6);
    expect(state.freezeTokens, 0, reason: 'the freeze token was consumed');
    expect(state.lastCompletedDay, _day(2));
  });

  test('a one-day gap with no banked freeze token resets the streak', () {
    var state = const StreakState(
      currentStreak: 5,
      longestStreak: 5,
      freezeTokens: 0,
    ).copyWith(lastCompletedDay: _day(0));

    state = applyCompletion(state, _day(2));

    expect(state.currentStreak, 1);
    expect(state.longestStreak, 5, reason: 'longest streak is never lowered');
  });

  test('a multi-day gap always resets the streak, even with a token banked',
      () {
    var state = const StreakState(
      currentStreak: 5,
      longestStreak: 5,
      freezeTokens: 2,
    ).copyWith(lastCompletedDay: _day(0));

    state = applyCompletion(state, _day(5));

    expect(state.currentStreak, 1);
    expect(state.freezeTokens, 2,
        reason: 'a freeze token only covers a single missed day');
  });

  test('earns a freeze token every 7-day milestone, banked up to 2', () {
    var state = StreakState.empty;
    for (var i = 0; i < 7; i++) {
      state = applyCompletion(state, _day(i));
    }

    expect(state.currentStreak, 7);
    expect(state.freezeTokens, 1);

    for (var i = 7; i < 14; i++) {
      state = applyCompletion(state, _day(i));
    }
    expect(state.currentStreak, 14);
    expect(state.freezeTokens, 2);

    // Would earn a 3rd token at day 21, but banking is capped at 2.
    for (var i = 14; i < 21; i++) {
      state = applyCompletion(state, _day(i));
    }
    expect(state.currentStreak, 21);
    expect(state.freezeTokens, 2);
  });

  // Regression test: completing on two *consecutive calendar days* that
  // straddle a DST spring-forward transition must still count as a 1-day
  // gap. Confirmed this was broken before daysBetweenCalendarDates existed
  // (`.difference(...).inDays` gave 0 for this exact date pair under
  // TZ=America/New_York, wrongly resetting the streak) — this assertion
  // passes unconditionally under any timezone, but only actually exercises
  // the transition when run under one that observes it, e.g.
  // `TZ=America/New_York flutter test test/gamification/streak_service_test.dart`.
  test('a gap across a DST spring-forward transition still counts as one day',
      () {
    var state = applyCompletion(StreakState.empty, DateTime(2026, 3, 8));
    state = applyCompletion(state, DateTime(2026, 3, 9));

    expect(state.currentStreak, 2,
        reason: 'consecutive calendar days must not be treated as a gap');
  });

  group('liveStreak', () {
    const s = StreakState(currentStreak: 9, freezeTokens: 0);
    test('alive if last done today or yesterday', () {
      final last = DateTime(2026, 1, 10);
      final st = s.copyWith(lastCompletedDay: last);
      expect(liveStreak(st, DateTime(2026, 1, 10, 22)), 9);
      expect(liveStreak(st, DateTime(2026, 1, 11, 22)), 9);
    });
    test('broken after a missed day with no freeze token', () {
      final st = s.copyWith(lastCompletedDay: DateTime(2026, 1, 10));
      expect(liveStreak(st, DateTime(2026, 1, 12)), 0);
    });
    test('a freeze token keeps a one-day gap alive', () {
      final st = s.copyWith(
          lastCompletedDay: DateTime(2026, 1, 10), freezeTokens: 1);
      expect(liveStreak(st, DateTime(2026, 1, 12)), 9);
      expect(liveStreak(st, DateTime(2026, 1, 13)), 0);
    });
    test('never completed shows 0', () {
      expect(liveStreak(StreakState.empty, DateTime(2026, 1, 1)), 0);
    });
  });

  test('a clock set back does not reset the streak', () {
    final st = StreakState(
        currentStreak: 5, longestStreak: 5,
        lastCompletedDay: DateTime(2026, 1, 10));
    final result = applyCompletion(st, DateTime(2026, 1, 8));
    expect(result.currentStreak, 5);
    expect(result.lastCompletedDay, DateTime(2026, 1, 10));
  });
}
