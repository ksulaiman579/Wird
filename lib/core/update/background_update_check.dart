import 'dart:ui' show DartPluginRegistrant;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_signals.dart';

const _alarmId = 42010;
const updatesChannelId = 'app_updates';

/// Background entry point — runs in its own isolate on the periodic alarm, so
/// it must be top-level and annotated. It brings plugins up in the isolate
/// then runs the self-contained check.
@pragma('vm:entry-point')
Future<void> updateCheckCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await runUpdateCheck();
}

/// Fetches the update manifest and the announcements file and fires a local
/// notification for anything new the user hasn't been told about. Fully
/// self-contained (its own http client, prefs, notifications plugin) because
/// it runs in a background isolate with no access to the app's providers.
/// Never throws — a failed check must be silent.
Future<bool> runUpdateCheck() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();
    final installed = int.tryParse(info.buildNumber) ?? 0;
    final client = http.Client();

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      updatesChannelId,
      'App updates & news',
      description: 'New versions and announcements from Wird.',
    ));
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        updatesChannelId,
        'App updates & news',
      ),
    );

    final update = await fetchUpdateSignal(client);
    if (update != null &&
        shouldNotifyUpdate(
          installedCode: installed,
          latestCode: update.versionCode,
          lastNotifiedCode: prefs.getInt(prefLastNotifiedUpdateCode) ?? 0,
        )) {
      await plugin.show(
        id: 9001,
        title: 'Update available',
        body: 'Wird ${update.versionName} is ready — tap to update.',
        notificationDetails: details,
        payload: '/',
      );
      await prefs.setInt(prefLastNotifiedUpdateCode, update.versionCode);
    }

    final ann = await fetchAnnouncement(client);
    if (ann != null &&
        shouldNotifyAnnouncement(
          latestId: ann.id,
          lastSeenId: prefs.getInt(prefLastSeenAnnouncementId) ?? 0,
        )) {
      await plugin.show(
        id: 9002,
        title: ann.title.isEmpty ? 'Wird' : ann.title,
        body: ann.body,
        notificationDetails: details,
        payload: '/',
      );
      await prefs.setInt(prefLastSeenAnnouncementId, ann.id);
    }

    client.close();
    return true;
  } catch (_) {
    return true;
  }
}

/// Registers the ~twice-daily background check (Android only; the PWA can't
/// run background isolates, and iOS can't sideload updates). Registering with
/// the same id replaces any existing schedule, so calling it on every launch
/// is safe/idempotent.
Future<void> registerBackgroundUpdateCheck() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(
    const Duration(hours: 12),
    _alarmId,
    updateCheckCallback,
    rescheduleOnReboot: true,
  );
}
