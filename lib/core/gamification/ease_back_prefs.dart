import 'package:shared_preferences/shared_preferences.dart';

import '../calendar_math.dart';
import 'ease_back.dart';

const easeBackUntilPrefsKey = 'ease_back_until';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Checks whether ease-back should be active today: reuses an
/// already-active 2-day window from a previous check, or persists a fresh
/// one (today + tomorrow) if [shouldTriggerEaseBack] says a new 3+ day gap
/// just happened.
Future<bool> isEaseBackActiveToday({
  required DateTime? lastCompletedDay,
  required DateTime now,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final today = _dateOnly(now);

  final storedIso = prefs.getString(easeBackUntilPrefsKey);
  if (storedIso != null) {
    final storedUntil = DateTime.parse(storedIso);
    if (!today.isAfter(storedUntil)) return true;
  }

  if (shouldTriggerEaseBack(lastCompletedDay: lastCompletedDay, today: today)) {
    await prefs.setString(
      easeBackUntilPrefsKey,
      addCalendarDays(today, 1).toIso8601String(),
    );
    return true;
  }

  return false;
}
