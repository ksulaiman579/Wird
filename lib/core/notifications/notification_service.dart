import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_plan.dart';

const dailyReminderChannelId = 'daily_reminder';
const adhkarMorningChannelId = 'adhkar_morning';
const adhkarEveningChannelId = 'adhkar_evening';
const adhanChannelId = 'adhan_reminder';

/// Android raw-resource name (android/app/src/main/res/raw/adhan.ogg) used
/// as the adhan channel's notification sound. Bundled CC0 recording — see
/// DATA_SOURCES.md.
const adhanSoundResource = 'adhan';

/// `streakAtRisk` is a same-channel variant of the daily reminder (per
/// the plan), not a separate Android channel.
String channelIdFor(NotificationChannel channel) => switch (channel) {
      NotificationChannel.dailyReminder ||
      NotificationChannel.streakAtRisk =>
        dailyReminderChannelId,
      NotificationChannel.adhkarMorning => adhkarMorningChannelId,
      NotificationChannel.adhkarEvening => adhkarEveningChannelId,
      NotificationChannel.adhan => adhanChannelId,
    };

/// Native only — `flutter_local_notifications` has no meaningful web
/// support; the plan gates this whole feature behind `kIsWeb == false` at
/// the call sites. Untested at runtime in this container (no device to
/// exercise real scheduling/permission requests against) — see
/// `notification_plan.dart`'s pure logic for what's actually verified.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Called with a notification's `payload` (a router path) when the user
  /// taps it — wire this to `router.go(payload)` at app start.
  void Function(String payload)? onSelectPayload;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onSelectPayload?.call(payload);
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      for (final channel in const [
        AndroidNotificationChannel(
          dailyReminderChannelId,
          'Daily reminder',
          description: 'Your daily memorization reminder.',
        ),
        // Low importance + no sound/vibration (M14.4): these are ongoing
        // "haven't done this yet today" markers, not attention-grabbing
        // alerts — the equivalent of a persistent to-do, not a ping.
        AndroidNotificationChannel(
          adhkarMorningChannelId,
          'Morning adhkar',
          description: 'A silent reminder while morning adhkar is unread.',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
        AndroidNotificationChannel(
          adhkarEveningChannelId,
          'Evening adhkar',
          description: 'A silent reminder while evening adhkar is unread.',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
        // High importance + the bundled adhan as the channel sound: this
        // is an attention-grabbing prayer-time call, not a passive marker.
        AndroidNotificationChannel(
          adhanChannelId,
          'Adhan (prayer times)',
          description: 'Plays the adhan at your selected prayer times.',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound(adhanSoundResource),
        ),
      ]) {
        await android.createNotificationChannel(channel);
      }
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Cancels everything pending and schedules [plan] fresh — simpler than
  /// diffing against what's already scheduled, per the plan's chosen
  /// "cancel-all + reschedule on every launch/settings change" strategy.
  /// Uses `inexactAllowWhileIdle` (no exact-alarm permission needed) since
  /// these are ±minutes reminders, not time-critical alarms.
  Future<void> reschedule(List<PlannedNotification> plan) async {
    await _plugin.cancelAll();
    for (final notification in plan) {
      final channelId = channelIdFor(notification.channel);
      final isAdhkar = notification.channel == NotificationChannel.adhkarMorning ||
          notification.channel == NotificationChannel.adhkarEvening;
      final isAdhan = notification.channel == NotificationChannel.adhan;
      await _plugin.zonedSchedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: tz.TZDateTime.from(notification.scheduledAt, tz.local),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            importance: isAdhan
                ? Importance.high
                : isAdhkar
                    ? Importance.low
                    : Importance.defaultImportance,
            priority: isAdhan
                ? Priority.high
                : isAdhkar
                    ? Priority.low
                    : Priority.defaultPriority,
            playSound: !isAdhkar,
            sound: isAdhan
                ? const RawResourceAndroidNotificationSound(adhanSoundResource)
                : null,
            enableVibration: !isAdhkar,
            // Ongoing/non-dismissible (M14.4): cleared explicitly, either
            // when the user completes that period's adhkar or the next
            // reschedule finds the window has moved on — never by the
            // user swiping it away, which would defeat the "haven't done
            // this yet" purpose.
            ongoing: isAdhkar,
            autoCancel: !isAdhkar,
          ),
          iOS: DarwinNotificationDetails(
            sound: isAdhan ? 'adhan.ogg' : null,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notification.payload,
      );
    }
  }

  /// Cancels one pending/shown notification by id — used to clear an
  /// adhkar notification once its period is completed or stale (M14.4).
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
