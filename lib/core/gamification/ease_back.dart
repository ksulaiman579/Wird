/// Pure ease-back decision logic — no Flutter/DB import.
/// `ease_back_prefs.dart` persists the resulting 2-day window.
library;

import '../calendar_math.dart';

/// Whether resuming today after [lastCompletedDay] should trigger a fresh
/// ease-back window: a gap of 3+ full missed days, i.e. today is at least
/// 4 calendar days after the last completed session (completed Monday,
/// missed Tue/Wed/Thu, returns Friday = a 4-day gap = 3 days missed).
/// `null` (never completed a session) never triggers it — there's no
/// streak to ease back into.
bool shouldTriggerEaseBack({
  required DateTime? lastCompletedDay,
  required DateTime today,
}) {
  if (lastCompletedDay == null) return false;
  final gapDays = daysBetweenCalendarDates(lastCompletedDay, today);
  return gapDays >= 4;
}

/// The new-material word-budget multiplier for a day, per the plan's
/// "halve new-material budget for 2 days" ease-back rule.
double newBudgetMultiplierFor({required bool easeBackActive}) =>
    easeBackActive ? 0.5 : 1.0;
