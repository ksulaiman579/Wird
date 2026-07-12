import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/notifications/notification_plan.dart';

List<Map<Salah, DateTime>> _window(DateTime day0) => [
      for (var d = 0; d < rollingWindowDays; d++)
        {
          Salah.fajr: DateTime(day0.year, day0.month, day0.day + d, 5, 0),
          Salah.dhuhr: DateTime(day0.year, day0.month, day0.day + d, 12, 0),
          Salah.asr: DateTime(day0.year, day0.month, day0.day + d, 15, 30),
          Salah.maghrib: DateTime(day0.year, day0.month, day0.day + d, 18, 0),
          Salah.isha: DateTime(day0.year, day0.month, day0.day + d, 19, 30),
        },
    ];

void main() {
  final day0 = DateTime(2026, 7, 10);

  test('adhanNotificationId is stable and collision-free per salah/day', () {
    final ids = <int>{};
    for (final salah in Salah.values) {
      for (var d = 0; d < rollingWindowDays; d++) {
        expect(ids.add(adhanNotificationId(salah, d)), isTrue);
      }
    }
    // Above the other channels' id space (which tops out ~400).
    expect(ids.every((id) => id >= 500), isTrue);
  });

  test('returns nothing when the tone is disabled', () {
    final plan = buildAdhanPlan(
      now: day0,
      prayerTimes: _window(day0),
      enabled: {for (final s in Salah.values) s: true},
      toneEnabled: false,
    );
    expect(plan, isEmpty);
  });

  test('only enabled prayers are scheduled', () {
    // 3 AM, so every prayer today is still in the future.
    final now = DateTime(2026, 7, 10, 3, 0);
    final plan = buildAdhanPlan(
      now: now,
      prayerTimes: _window(day0),
      toneEnabled: true,
      enabled: {
        Salah.fajr: true,
        Salah.dhuhr: false,
        Salah.asr: true,
        Salah.maghrib: false,
        Salah.isha: false,
      },
    );
    // 2 enabled prayers × 7 days.
    expect(plan.length, 2 * rollingWindowDays);
    expect(
      plan.every((p) => p.channel == NotificationChannel.adhan),
      isTrue,
    );
    expect(plan.any((p) => p.title.contains('Fajr')), isTrue);
    expect(plan.any((p) => p.title.contains('Asr')), isTrue);
    expect(plan.any((p) => p.title.contains('Dhuhr')), isFalse);
  });

  test('past times today are skipped', () {
    // After Asr but before Maghrib: today's Fajr/Dhuhr/Asr are past.
    final now = DateTime(2026, 7, 10, 16, 0);
    final plan = buildAdhanPlan(
      now: now,
      prayerTimes: _window(day0),
      toneEnabled: true,
      enabled: {for (final s in Salah.values) s: true},
    );
    // Day 0: only Maghrib + Isha remain (3 skipped). Days 1–6: all 5.
    expect(plan.length, 2 + 5 * (rollingWindowDays - 1));
    // No day-0 Fajr entry.
    expect(
      plan.any((p) => p.id == adhanNotificationId(Salah.fajr, 0)),
      isFalse,
    );
  });
}
