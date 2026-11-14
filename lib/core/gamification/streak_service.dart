/// Pure streak/freeze-token logic. No Flutter imports — plain Dart so it
/// stays trivially unit-testable (see IMPLEMENTATION_PLAN.md's gamification
/// section: streak flame + streak-freeze tokens).
library;

import '../calendar_math.dart';

class StreakState {
  const StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezeTokens = 0,
    this.lastCompletedDay,
  });

  final int currentStreak;
  final int longestStreak;
  final int freezeTokens;
  final DateTime? lastCompletedDay;

  static const empty = StreakState();

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? freezeTokens,
    DateTime? lastCompletedDay,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      freezeTokens: freezeTokens ?? this.freezeTokens,
      lastCompletedDay: lastCompletedDay ?? this.lastCompletedDay,
    );
  }
}

const int maxFreezeTokens = 2;
const int freezeTokenEarnIntervalDays = 7;

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Applies one day's portion-completion event to [current], returning the
/// updated streak state.
///
/// - A same-day repeat (completing an already-completed day's portion
///   again) is a no-op — returns [current] unchanged.
/// - A gap of exactly one day (consecutive daily completion) increments
///   the streak.
/// - A gap of exactly two days (one full day missed in between) consumes
///   one banked freeze token, if any, and the streak continues as if
///   uninterrupted; with no token banked, the streak resets to 1.
/// - Any larger gap always resets the streak to 1 — a freeze token only
///   covers a single missed day.
/// - A freeze token is earned every [freezeTokenEarnIntervalDays]-day
///   streak milestone, banked up to [maxFreezeTokens].
StreakState applyCompletion(StreakState current, DateTime completedDay) {
  final today = _dateOnly(completedDay);
  final last =
      current.lastCompletedDay == null ? null : _dateOnly(current.lastCompletedDay!);

  if (last != null && today.isAtSameMomentAs(last)) {
    return current;
  }

  // Clock set back, or travel west over the date line: the stored day is
  // "in the future". Don't reset the streak or move the day backwards.
  if (last != null && daysBetweenCalendarDates(last, today) < 0) {
    return current;
  }

  var freezeTokens = current.freezeTokens;
  int newStreak;

  if (last == null) {
    newStreak = 1;
  } else {
    final gapDays = daysBetweenCalendarDates(last, today);
    if (gapDays == 1) {
      newStreak = current.currentStreak + 1;
    } else if (gapDays == 2 && freezeTokens > 0) {
      freezeTokens -= 1;
      newStreak = current.currentStreak + 1;
    } else {
      newStreak = 1;
    }
  }

  if (newStreak % freezeTokenEarnIntervalDays == 0 &&
      freezeTokens < maxFreezeTokens) {
    freezeTokens += 1;
  }

  return current.copyWith(
    currentStreak: newStreak,
    lastCompletedDay: today,
    longestStreak:
        newStreak > current.longestStreak ? newStreak : current.longestStreak,
    freezeTokens: freezeTokens,
  );
}

/// The streak to *show* on [now]. The stored count only changes when a
/// portion is completed, so after missed days it kept showing the old
/// number (M26.8). Still alive if the last completion was today or
/// yesterday, or the day before yesterday with a freeze token to cover the
/// gap; otherwise it's broken and shows 0.
int liveStreak(StreakState s, DateTime now) {
  final last = s.lastCompletedDay;
  if (last == null) return 0;
  final gap = daysBetweenCalendarDates(_dateOnly(last), _dateOnly(now));
  if (gap <= 1) return s.currentStreak;
  if (gap == 2 && s.freezeTokens > 0) return s.currentStreak;
  return 0;
}
