/// Pure adhkar-window logic (M14.3) — no Flutter import, so it stays
/// unit-testable without a widget harness. Shared by the time-aware Dua
/// home card (M14.2) and the ongoing-notification scheduling (M14.4):
/// both need the same answer to "is it morning-adhkar time or
/// evening-adhkar time right now?"
library;

enum AdhkarPeriod { morning, evening }

/// The morning window runs from Fajr (inclusive) to Asr (exclusive); the
/// evening window is everything else, wrapping past midnight back around
/// to the next day's Fajr. [fajr]/[asr] must fall on the same calendar day
/// as [now] (the caller is expected to look up "today's" prayer times).
///
/// When prayer times aren't available (no location set, or the lookup
/// failed) [fajr]/[asr] are null and a fixed fallback boundary is used —
/// the same 06:00/17:00 convention already used elsewhere in this app for
/// "no location" (see `location_prefs.dart`).
AdhkarPeriod adhkarPeriodFor(
  DateTime now, {
  DateTime? fajr,
  DateTime? asr,
}) {
  final morningStart = fajr ?? DateTime(now.year, now.month, now.day, 6);
  final eveningStart = asr ?? DateTime(now.year, now.month, now.day, 17);

  final inMorningWindow =
      !now.isBefore(morningStart) && now.isBefore(eveningStart);
  return inMorningWindow ? AdhkarPeriod.morning : AdhkarPeriod.evening;
}
