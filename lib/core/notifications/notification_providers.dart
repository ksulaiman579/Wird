import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../adhkar/adhkar_window.dart';
import '../db/database.dart';
import 'location_prefs.dart';
import 'notification_plan.dart';
import 'notification_prefs.dart';
import 'notification_service.dart';
import 'prayer_method_prefs.dart';
import 'prayer_times_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final prayerTimesServiceProvider = Provider<PrayerTimesService>((ref) {
  return PrayerTimesService();
});

/// Today's prayer times for whatever location/method is currently
/// selected — null if no location is set. Drives Settings' "source"
/// indicator (M7.3): whether the last lookup used the online AlAdhan
/// calendar or the offline `adhan_dart` fallback.
final prayerTimesPreviewProvider = FutureProvider<DailyPrayerTimes?>((ref) async {
  final location = await ref.watch(locationProvider.future);
  if (location == null) return null;

  final methodOverride = await ref.watch(prayerMethodOverrideProvider.future);
  return ref.read(prayerTimesServiceProvider).timesFor(
        date: DateTime.now(),
        latitude: location.lat,
        longitude: location.lng,
        countryCode: location.countryCode,
        methodOverride: methodOverride,
      );
});

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _dayKeyFor(DateTime d) {
  final dt = _dateOnly(d);
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

/// Recomputes the rolling notification window and reschedules it — call
/// this at app launch and whenever notification prefs or the selected
/// location change (native only; the plan gates the whole feature behind
/// `kIsWeb == false`, so this is a no-op on web).
///
/// [ref] is `dynamic` because callers pass either a [Ref] (from a
/// provider) or a [WidgetRef] (from a `ConsumerState`) — both expose the
/// same `read`/`read(...future)` calls used below, but neither is a
/// supertype of the other, so no single Riverpod type covers both.
Future<void> rescheduleNotifications(dynamic ref) async {
  if (kIsWeb) return;

  final prefs = await ref.read(notificationPrefsProvider.future);
  final location = await ref.read(locationProvider.future);
  final methodOverride = await ref.read(prayerMethodOverrideProvider.future);
  final db = ref.read(appDatabaseProvider);
  final prayerService = ref.read(prayerTimesServiceProvider);

  final now = DateTime.now();
  final today = _dateOnly(now);

  final fajrTimes = <DateTime>[];
  final asrTimes = <DateTime>[];
  // All-five prayer times per day — only computable with a real location;
  // used for adhan reminders (buildAdhanPlan). Left empty when no city is
  // set, in which case adhan reminders are simply not scheduled.
  final allPrayerTimes = <Map<Salah, DateTime>>[];
  for (var day = 0; day < rollingWindowDays; day++) {
    final date = today.add(Duration(days: day));
    if (prefs.useManualTimes) {
      // Manual times (U9): user-entered minutes-since-midnight, no location
      // needed. Drives both adhkar (Fajr/Asr) and the full adhan set.
      DateTime at(int minutes) => DateTime(
          date.year, date.month, date.day, minutes ~/ 60, minutes % 60);
      final manual = prefs.manualMinutesBySalah;
      fajrTimes.add(at(manual[Salah.fajr]!));
      asrTimes.add(at(manual[Salah.asr]!));
      allPrayerTimes.add({
        for (final entry in manual.entries) entry.key: at(entry.value),
      });
    } else if (location == null) {
      // No city picked — fixed fallback times, per the plan.
      fajrTimes.add(DateTime(date.year, date.month, date.day, 6, 0));
      asrTimes.add(DateTime(date.year, date.month, date.day, 17, 0));
    } else {
      final times = await prayerService.timesFor(
        date: date,
        latitude: location.lat,
        longitude: location.lng,
        countryCode: location.countryCode,
        methodOverride: methodOverride,
      );
      fajrTimes.add(times.fajr);
      asrTimes.add(times.asr);
      allPrayerTimes.add(calculateAllPrayersOffline(
        date: date,
        latitude: location.lat,
        longitude: location.lng,
      ));
    }
  }

  final dayKey = _dayKeyFor(now);
  final session = await (db.select(db.dailySessions)
        ..where((t) => t.day.equals(dayKey)))
      .getSingleOrNull();
  final streakRow = await db.select(db.streakState).getSingleOrNull();

  final plan = buildNotificationPlan(
    now: now,
    fajrTimes: fajrTimes,
    asrTimes: asrTimes,
    dailyReminderHour: prefs.dailyReminderHour,
    dailyReminderMinute: prefs.dailyReminderMinute,
    dailyReminderEnabled: prefs.dailyReminderEnabled,
    adhkarMorningEnabled: prefs.adhkarMorningEnabled,
    adhkarEveningEnabled: prefs.adhkarEveningEnabled,
    streakAtRiskEnabled: prefs.streakAtRiskEnabled,
    todayPortionCompleted: session?.completed ?? false,
    currentStreak: streakRow?.currentStreak ?? 0,
  );

  // Adhan reminders (5H): only when a location is set (real prayer times
  // required) and a tone is selected. Appended to the same plan so the
  // service's cancel-all + reschedule covers them too.
  if ((location != null || prefs.useManualTimes) &&
      allPrayerTimes.length == rollingWindowDays) {
    plan.addAll(buildAdhanPlan(
      now: now,
      prayerTimes: allPrayerTimes,
      toneEnabled: prefs.adhanTone != AdhanTone.none,
      enabled: {
        Salah.fajr: prefs.adhanFajr,
        Salah.dhuhr: prefs.adhanDhuhr,
        Salah.asr: prefs.adhanAsr,
        Salah.maghrib: prefs.adhanMaghrib,
        Salah.isha: prefs.adhanIsha,
      },
    ));
  }

  final service = ref.read(notificationServiceProvider);
  await service.reschedule(plan);

  // M14.4: an ongoing adhkar notification from the window that just
  // ended (e.g. this morning's) doesn't auto-dismiss — clear it now that
  // we know which window is current. Best-effort: only actually catches
  // the transition when the app is opened (or notification prefs/location
  // change) after the boundary, since there's no background trigger for
  // the exact moment it happens.
  final currentPeriod =
      adhkarPeriodFor(now, fajr: fajrTimes.first, asr: asrTimes.first);
  await service.cancel(staleAdhkarNotificationId(currentPeriod));
}
