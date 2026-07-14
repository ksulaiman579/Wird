import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/notifications/notification_plan.dart';
import 'package:wird/core/notifications/notification_prefs.dart';

void main() {
  group('NotificationPrefs manual times (U9)', () {
    test('defaults: manual times off with sensible seed times', () {
      const p = NotificationPrefs();
      expect(p.useManualTimes, isFalse);
      expect(p.manualFajrMinutes, 5 * 60);
      expect(p.manualIshaMinutes, 19 * 60 + 45);
      expect(p.manualMinutesBySalah[Salah.dhuhr], 12 * 60 + 30);
      expect(p.manualMinutesBySalah.length, 5);
    });

    test('round-trips the manual-time fields through json', () {
      const p = NotificationPrefs(
        useManualTimes: true,
        manualFajrMinutes: 300,
        manualDhuhrMinutes: 760,
        manualAsrMinutes: 950,
        manualMaghribMinutes: 1100,
        manualIshaMinutes: 1200,
      );
      final restored = NotificationPrefs.fromJson(p.toJson());
      expect(restored.useManualTimes, isTrue);
      expect(restored.manualFajrMinutes, 300);
      expect(restored.manualMaghribMinutes, 1100);
      expect(restored.manualMinutesBySalah[Salah.isha], 1200);
    });

    test('copyWith updates a single manual time', () {
      const p = NotificationPrefs();
      final next = p.copyWith(useManualTimes: true, manualAsrMinutes: 999);
      expect(next.useManualTimes, isTrue);
      expect(next.manualAsrMinutes, 999);
      // Others untouched.
      expect(next.manualFajrMinutes, p.manualFajrMinutes);
    });

    test('legacy json without manual fields falls back to defaults', () {
      final restored = NotificationPrefs.fromJson({
        'dailyReminderEnabled': true,
        'adhanTone': 'adhan',
      });
      expect(restored.useManualTimes, isFalse);
      expect(restored.manualDhuhrMinutes, 12 * 60 + 30);
    });
  });
}
