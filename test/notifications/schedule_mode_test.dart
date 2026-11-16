import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/notifications/notification_plan.dart';
import 'package:wird/core/notifications/notification_service.dart';

// Audit WQA-024: the adhan was inexact and could fire up to an hour late.
void main() {
  test('adhan is exact when Android allows exact alarms', () {
    expect(scheduleModeFor(NotificationChannel.adhan, exactAllowed: true),
        AndroidScheduleMode.exactAllowWhileIdle);
  });

  test('adhan falls back to inexact without the permission', () {
    expect(scheduleModeFor(NotificationChannel.adhan, exactAllowed: false),
        AndroidScheduleMode.inexactAllowWhileIdle);
  });

  test('other reminders stay inexact', () {
    for (final c in NotificationChannel.values) {
      if (c == NotificationChannel.adhan) continue;
      expect(scheduleModeFor(c, exactAllowed: true),
          AndroidScheduleMode.inexactAllowWhileIdle,
          reason: '$c');
    }
  });
}
