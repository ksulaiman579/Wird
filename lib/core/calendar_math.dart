/// DST-safe calendar-day arithmetic. No Flutter import — plain Dart.
///
/// `DateTime` operates on absolute time under the hood: `.add(Duration(...))`
/// and `.difference(...).inDays` both convert through
/// microsecondsSinceEpoch, so a calculation that crosses a DST transition
/// (in any timezone that observes one) is off by the transition's offset
/// change. Concretely, comparing two *local* midnights that straddle a
/// spring-forward transition yields a 23-hour gap, not 24 — enough to make
/// `.inDays` round down to 0 for what should be a 1-day gap. Confirmed with
/// `TZ=America/New_York`: `DateTime(2026,3,8) → DateTime(2026,3,9)` (the day
/// after that year's transition) gives `.inDays == 0`.
///
/// The fix: do calendar-day arithmetic on the (year, month, day) triple via
/// [DateTime.utc], never on local wall-clock instants. UTC has no DST, so
/// this is immune to the transition entirely — and since both this file's
/// functions only ever consume/produce (year, month, day) components (never
/// persisting a UTC instant anywhere), it has no effect on how dates are
/// stored or displayed elsewhere in the app.
library;

/// The number of calendar days from [a] to [b] (positive if [b] is later),
/// based on their (year, month, day) components only — the time-of-day on
/// either is ignored.
int daysBetweenCalendarDates(DateTime a, DateTime b) {
  final aUtc = DateTime.utc(a.year, a.month, a.day);
  final bUtc = DateTime.utc(b.year, b.month, b.day);
  return bUtc.difference(aUtc).inDays;
}

/// [date] plus [days] calendar days, landing exactly at local midnight of
/// the target date — unlike `date.add(Duration(days: days))`, which can
/// drift an hour off midnight across a DST transition (see this library's
/// doc comment).
DateTime addCalendarDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}
