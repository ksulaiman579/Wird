/// Pure notification scheduling plan: given the next [rollingWindowDays]
/// days' Fajr/Asr times and the user's notification preferences, computes
/// exactly which notifications should be pending. No flutter_local_
/// notifications/Flutter import — plain Dart so it stays unit-testable;
/// `notification_service.dart` is the thin plugin-wrapping layer on top
/// that actually calls `zonedSchedule` for each entry this returns.
library;

import '../adhkar/adhkar_window.dart' show AdhkarPeriod;

const int rollingWindowDays = 7;

/// M14.4: the adhkar notifications are ongoing-style (shown persistently,
/// not auto-dismissed) so they need explicit cancellation once they're
/// stale. If [current] is the morning window, the evening notification
/// from earlier tonight (or vice versa) is stale and should be cancelled.
/// Pure so it's unit-testable; `rescheduleNotifications` (which already
/// runs at app launch and on every settings/location change, per this
/// file's "cancel-all + reschedule" strategy) is the actual caller — there
/// is no background trigger to catch the exact window-boundary moment
/// while the app isn't open, which is a known, accepted limitation.
int staleAdhkarNotificationId(AdhkarPeriod current) {
  final staleChannel = current == AdhkarPeriod.morning
      ? NotificationChannel.adhkarEvening
      : NotificationChannel.adhkarMorning;
  return notificationIdFor(staleChannel, 0);
}

enum NotificationChannel { dailyReminder, adhkarMorning, adhkarEvening, streakAtRisk, adhan }

/// The five daily obligatory prayers, in order. Pure (no adhan_dart
/// import) so the planner stays unit-testable; the service maps its
/// offline calculation onto this enum.
enum Salah {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get label => switch (this) {
        Salah.fajr => 'Fajr',
        Salah.dhuhr => 'Dhuhr',
        Salah.asr => 'Asr',
        Salah.maghrib => 'Maghrib',
        Salah.isha => 'Isha',
      };
}

/// Adhan notifications use a dedicated id block (500+) so they never
/// collide with the [notificationIdFor] scheme (which tops out around 400
/// for the other channels). 5 prayers × 7 days fits in 500..569.
int adhanNotificationId(Salah salah, int dayOffset) =>
    500 + salah.index * 10 + dayOffset;

/// Builds adhan reminders for the rolling window. [prayerTimes] must have
/// exactly [rollingWindowDays] entries (day 0 = today), each a map of all
/// five prayer times for that date. Only prayers whose per-salah toggle is
/// enabled in [enabled] are scheduled, and only if [toneEnabled]. Entries
/// already in the past relative to [now] are skipped.
List<PlannedNotification> buildAdhanPlan({
  required DateTime now,
  required List<Map<Salah, DateTime>> prayerTimes,
  required Map<Salah, bool> enabled,
  bool toneEnabled = false,
}) {
  assert(prayerTimes.length == rollingWindowDays);
  if (!toneEnabled) return const [];

  final plan = <PlannedNotification>[];
  for (var day = 0; day < rollingWindowDays; day++) {
    for (final salah in Salah.values) {
      if (!(enabled[salah] ?? false)) continue;
      final at = prayerTimes[day][salah];
      if (at == null || !at.isAfter(now)) continue;
      plan.add(PlannedNotification(
        id: adhanNotificationId(salah, day),
        channel: NotificationChannel.adhan,
        scheduledAt: at,
        title: '${salah.label} — time to pray',
        body: 'It is time for ${salah.label}. حَيَّ عَلَى الصَّلَاة',
        // Opens the in-app adhan player (tap-to-silence) rather than the
        // home tab — the adhan is played in-app, not as a channel sound.
        payload: '/adhan?salah=${salah.label}',
      ));
    }
  }
  return plan;
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.channel,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final NotificationChannel channel;
  final DateTime scheduledAt;
  final String title;
  final String body;

  /// A router path (`/`, `/adhkar/morning`, `/adhkar/evening`) to
  /// deep-link to when the notification is tapped.
  final String payload;
}

/// Stable notification id for a channel + day offset, so re-scheduling
/// with the same inputs always produces the same ids — `cancel-all then
/// reschedule` (the plan's chosen strategy) doesn't need to diff against
/// previously scheduled ids.
int notificationIdFor(NotificationChannel channel, int dayOffset) =>
    channel.index * 100 + dayOffset;

/// Builds the rolling window of notifications. [fajrTimes]/[asrTimes] must
/// have exactly [rollingWindowDays] entries, day 0 = today. Anything that
/// would already be in the past relative to [now] is left out (the caller
/// reschedules on every launch/settings change, so "already passed today"
/// entries are simply never generated rather than needing cleanup).
///
/// `streakAtRisk` is a same-day-only variant of the daily reminder (per
/// the plan: "daily_reminder ... + streak-at-risk variant", not a separate
/// Android channel) — 2 hours before the daily reminder time, shown only
/// if [todayPortionCompleted] is false at schedule time.
List<PlannedNotification> buildNotificationPlan({
  required DateTime now,
  required List<DateTime> fajrTimes,
  required List<DateTime> asrTimes,
  required int dailyReminderHour,
  required int dailyReminderMinute,
  bool dailyReminderEnabled = true,
  bool adhkarMorningEnabled = false,
  bool adhkarEveningEnabled = false,
  bool streakAtRiskEnabled = false,
  bool todayPortionCompleted = false,
  int currentStreak = 0,
}) {
  assert(fajrTimes.length == rollingWindowDays);
  assert(asrTimes.length == rollingWindowDays);

  final plan = <PlannedNotification>[];
  final today = DateTime(now.year, now.month, now.day);

  for (var day = 0; day < rollingWindowDays; day++) {
    final date = today.add(Duration(days: day));

    if (dailyReminderEnabled) {
      final at = DateTime(
        date.year, date.month, date.day, dailyReminderHour, dailyReminderMinute,
      );
      if (at.isAfter(now)) {
        plan.add(PlannedNotification(
          id: notificationIdFor(NotificationChannel.dailyReminder, day),
          channel: NotificationChannel.dailyReminder,
          scheduledAt: at,
          title: "Today's memorization",
          body: 'Keep your streak going — open Wird for today\'s portion.',
          payload: '/',
        ));
      }
    }

    if (adhkarMorningEnabled) {
      final at = fajrTimes[day].add(const Duration(minutes: 30));
      if (at.isAfter(now)) {
        plan.add(PlannedNotification(
          id: notificationIdFor(NotificationChannel.adhkarMorning, day),
          channel: NotificationChannel.adhkarMorning,
          scheduledAt: at,
          title: 'Morning adhkar',
          body: 'A few minutes of remembrance to start the day.',
          payload: '/adhkar/morning',
        ));
      }
    }

    if (adhkarEveningEnabled) {
      final at = asrTimes[day].add(const Duration(minutes: 30));
      if (at.isAfter(now)) {
        plan.add(PlannedNotification(
          id: notificationIdFor(NotificationChannel.adhkarEvening, day),
          channel: NotificationChannel.adhkarEvening,
          scheduledAt: at,
          title: 'Evening adhkar',
          body: 'A few minutes of remembrance before the day ends.',
          payload: '/adhkar/evening',
        ));
      }
    }
  }

  if (streakAtRiskEnabled && dailyReminderEnabled && !todayPortionCompleted) {
    final at = DateTime(
      today.year, today.month, today.day, dailyReminderHour, dailyReminderMinute,
    ).subtract(const Duration(hours: 2));
    if (at.isAfter(now)) {
      plan.add(PlannedNotification(
        id: notificationIdFor(NotificationChannel.streakAtRisk, 0),
        channel: NotificationChannel.streakAtRisk,
        scheduledAt: at,
        title: 'Streak at risk',
        body: currentStreak > 0
            ? '2 hours left to keep your $currentStreak-day streak.'
            : "Don't forget today's portion.",
        payload: '/',
      ));
    }
  }

  return plan;
}
