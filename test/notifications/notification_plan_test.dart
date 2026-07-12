import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/adhkar/adhkar_window.dart';
import 'package:wird/core/notifications/notification_plan.dart';

List<DateTime> _daily(DateTime start, int hour, int minute) => [
      for (var i = 0; i < rollingWindowDays; i++)
        DateTime(start.year, start.month, start.day + i, hour, minute),
    ];

void main() {
  test('with only the daily reminder enabled, yields one per remaining day',
      () {
    final now = DateTime(2026, 6, 1, 6); // well before the 20:00 reminder
    final plan = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
    );

    expect(plan.length, rollingWindowDays);
    expect(plan.every((p) => p.channel == NotificationChannel.dailyReminder), true);
    expect(plan.first.scheduledAt, DateTime(2026, 6, 1, 20, 0));
    expect(plan.first.payload, '/');
  });

  test('all three day-based channels enabled yields ~21 pending', () {
    final now = DateTime(2026, 6, 1, 0, 1); // just after midnight
    final plan = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
      adhkarMorningEnabled: true,
      adhkarEveningEnabled: true,
    );

    expect(plan.length, rollingWindowDays * 3);
    expect(
      plan.where((p) => p.channel == NotificationChannel.adhkarMorning).length,
      rollingWindowDays,
    );
  });

  test('adhkar times are offset 30 minutes after fajr/asr', () {
    final now = DateTime(2026, 6, 1, 0, 1);
    final plan = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
      adhkarMorningEnabled: true,
      adhkarEveningEnabled: true,
    );

    final morning = plan.firstWhere((p) => p.channel == NotificationChannel.adhkarMorning);
    final evening = plan.firstWhere((p) => p.channel == NotificationChannel.adhkarEvening);

    expect(morning.scheduledAt, DateTime(2026, 6, 1, 5, 40));
    expect(evening.scheduledAt, DateTime(2026, 6, 1, 16, 10));
    expect(morning.payload, '/adhkar/morning');
    expect(evening.payload, '/adhkar/evening');
  });

  test('already-passed times today are not scheduled, future days still are', () {
    // 21:00 today — today's 20:00 daily reminder and 05:40 adhkar have
    // already passed; tomorrow's have not.
    final now = DateTime(2026, 6, 1, 21, 0);
    final plan = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
      adhkarMorningEnabled: true,
    );

    final dailyReminders =
        plan.where((p) => p.channel == NotificationChannel.dailyReminder);
    expect(dailyReminders.length, rollingWindowDays - 1);
    expect(dailyReminders.any((p) => p.scheduledAt.day == 1), false);
  });

  test(
      'streak-at-risk fires 2h before the daily reminder only if enabled '
      'and today is not yet completed', () {
    final now = DateTime(2026, 6, 1, 10);

    final withoutFlag = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
    );
    expect(
      withoutFlag.any((p) => p.channel == NotificationChannel.streakAtRisk),
      false,
    );

    final enabled = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
      streakAtRiskEnabled: true,
      currentStreak: 34,
    );
    final streakNotif =
        enabled.firstWhere((p) => p.channel == NotificationChannel.streakAtRisk);
    expect(streakNotif.scheduledAt, DateTime(2026, 6, 1, 18, 0));
    expect(streakNotif.body, contains('34-day streak'));

    final alreadyDone = buildNotificationPlan(
      now: now,
      fajrTimes: _daily(now, 5, 10),
      asrTimes: _daily(now, 15, 40),
      dailyReminderHour: 20,
      dailyReminderMinute: 0,
      streakAtRiskEnabled: true,
      todayPortionCompleted: true,
    );
    expect(
      alreadyDone.any((p) => p.channel == NotificationChannel.streakAtRisk),
      false,
    );
  });

  test('notificationIdFor is stable for the same channel and day offset', () {
    expect(
      notificationIdFor(NotificationChannel.adhkarMorning, 3),
      notificationIdFor(NotificationChannel.adhkarMorning, 3),
    );
    expect(
      notificationIdFor(NotificationChannel.adhkarMorning, 3),
      isNot(notificationIdFor(NotificationChannel.adhkarEvening, 3)),
    );
  });

  group('staleAdhkarNotificationId', () {
    test('when it is currently morning, the evening notification is stale', () {
      expect(
        staleAdhkarNotificationId(AdhkarPeriod.morning),
        notificationIdFor(NotificationChannel.adhkarEvening, 0),
      );
    });

    test('when it is currently evening, the morning notification is stale', () {
      expect(
        staleAdhkarNotificationId(AdhkarPeriod.evening),
        notificationIdFor(NotificationChannel.adhkarMorning, 0),
      );
    });
  });
}
