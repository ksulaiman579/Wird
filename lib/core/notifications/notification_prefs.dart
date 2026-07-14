import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_plan.dart';

const notificationPrefsKey = 'notification_prefs';

/// Adhan tone for prayer-time reminders. Only one bundled recording ships
/// (a single CC0 adhan — see DATA_SOURCES.md); labelling one file as
/// several different muezzins/mosques would be dishonest, so the choice is
/// simply between the default notification sound and the bundled adhan.
enum AdhanTone {
  none,
  adhan;

  String get displayName => switch (this) {
        AdhanTone.none => 'Default sound',
        AdhanTone.adhan => 'Adhan (call to prayer)',
      };
}

/// Native-only notification preferences (persisted to shared_preferences).
/// `streakAtRiskEnabled` is a same-channel variant of the daily reminder,
/// not an independent toggle the UI needs to expose separately — it
/// piggybacks on `dailyReminderEnabled` in `notification_plan.dart`.
class NotificationPrefs {
  const NotificationPrefs({
    this.dailyReminderEnabled = true,
    this.dailyReminderHour = 20,
    this.dailyReminderMinute = 0,
    this.adhkarMorningEnabled = true,
    this.adhkarEveningEnabled = true,
    this.streakAtRiskEnabled = false,
    this.adhanTone = AdhanTone.none,
    this.adhanFajr = false,
    this.adhanDhuhr = false,
    this.adhanAsr = false,
    this.adhanMaghrib = false,
    this.adhanIsha = false,
    this.useManualTimes = false,
    this.manualFajrMinutes = 5 * 60,
    this.manualDhuhrMinutes = 12 * 60 + 30,
    this.manualAsrMinutes = 15 * 60 + 45,
    this.manualMaghribMinutes = 18 * 60 + 15,
    this.manualIshaMinutes = 19 * 60 + 45,
  });

  final bool dailyReminderEnabled;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final bool adhkarMorningEnabled;
  final bool adhkarEveningEnabled;
  final bool streakAtRiskEnabled;

  /// Which adhan tone to play for prayer-time reminders.
  final AdhanTone adhanTone;

  /// Per-salah toggles — only relevant when [adhanTone] != [AdhanTone.none].
  final bool adhanFajr;
  final bool adhanDhuhr;
  final bool adhanAsr;
  final bool adhanMaghrib;
  final bool adhanIsha;

  /// When true, prayer times are taken from the [manualFajrMinutes]… fields
  /// (minutes since local midnight) instead of being computed from a
  /// location — so adhan/prayer reminders work with no city set, and the
  /// user can override an inaccurate calculation for their locale.
  final bool useManualTimes;
  final int manualFajrMinutes;
  final int manualDhuhrMinutes;
  final int manualAsrMinutes;
  final int manualMaghribMinutes;
  final int manualIshaMinutes;

  /// The five manual times as minutes-since-midnight, keyed by salah.
  Map<Salah, int> get manualMinutesBySalah => {
        Salah.fajr: manualFajrMinutes,
        Salah.dhuhr: manualDhuhrMinutes,
        Salah.asr: manualAsrMinutes,
        Salah.maghrib: manualMaghribMinutes,
        Salah.isha: manualIshaMinutes,
      };

  NotificationPrefs copyWith({
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? adhkarMorningEnabled,
    bool? adhkarEveningEnabled,
    bool? streakAtRiskEnabled,
    AdhanTone? adhanTone,
    bool? adhanFajr,
    bool? adhanDhuhr,
    bool? adhanAsr,
    bool? adhanMaghrib,
    bool? adhanIsha,
    bool? useManualTimes,
    int? manualFajrMinutes,
    int? manualDhuhrMinutes,
    int? manualAsrMinutes,
    int? manualMaghribMinutes,
    int? manualIshaMinutes,
  }) {
    return NotificationPrefs(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      adhkarMorningEnabled: adhkarMorningEnabled ?? this.adhkarMorningEnabled,
      adhkarEveningEnabled: adhkarEveningEnabled ?? this.adhkarEveningEnabled,
      streakAtRiskEnabled: streakAtRiskEnabled ?? this.streakAtRiskEnabled,
      adhanTone: adhanTone ?? this.adhanTone,
      adhanFajr: adhanFajr ?? this.adhanFajr,
      adhanDhuhr: adhanDhuhr ?? this.adhanDhuhr,
      adhanAsr: adhanAsr ?? this.adhanAsr,
      adhanMaghrib: adhanMaghrib ?? this.adhanMaghrib,
      adhanIsha: adhanIsha ?? this.adhanIsha,
      useManualTimes: useManualTimes ?? this.useManualTimes,
      manualFajrMinutes: manualFajrMinutes ?? this.manualFajrMinutes,
      manualDhuhrMinutes: manualDhuhrMinutes ?? this.manualDhuhrMinutes,
      manualAsrMinutes: manualAsrMinutes ?? this.manualAsrMinutes,
      manualMaghribMinutes: manualMaghribMinutes ?? this.manualMaghribMinutes,
      manualIshaMinutes: manualIshaMinutes ?? this.manualIshaMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyReminderEnabled': dailyReminderEnabled,
        'dailyReminderHour': dailyReminderHour,
        'dailyReminderMinute': dailyReminderMinute,
        'adhkarMorningEnabled': adhkarMorningEnabled,
        'adhkarEveningEnabled': adhkarEveningEnabled,
        'streakAtRiskEnabled': streakAtRiskEnabled,
        'adhanTone': adhanTone.name,
        'adhanFajr': adhanFajr,
        'adhanDhuhr': adhanDhuhr,
        'adhanAsr': adhanAsr,
        'adhanMaghrib': adhanMaghrib,
        'adhanIsha': adhanIsha,
        'useManualTimes': useManualTimes,
        'manualFajrMinutes': manualFajrMinutes,
        'manualDhuhrMinutes': manualDhuhrMinutes,
        'manualAsrMinutes': manualAsrMinutes,
        'manualMaghribMinutes': manualMaghribMinutes,
        'manualIshaMinutes': manualIshaMinutes,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) {
    return NotificationPrefs(
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? true,
      dailyReminderHour: json['dailyReminderHour'] as int? ?? 20,
      dailyReminderMinute: json['dailyReminderMinute'] as int? ?? 0,
      adhkarMorningEnabled: json['adhkarMorningEnabled'] as bool? ?? true,
      adhkarEveningEnabled: json['adhkarEveningEnabled'] as bool? ?? true,
      streakAtRiskEnabled: json['streakAtRiskEnabled'] as bool? ?? false,
      adhanTone: AdhanTone.values.firstWhere(
        (t) => t.name == (json['adhanTone'] as String?),
        orElse: () => AdhanTone.none,
      ),
      adhanFajr: json['adhanFajr'] as bool? ?? false,
      adhanDhuhr: json['adhanDhuhr'] as bool? ?? false,
      adhanAsr: json['adhanAsr'] as bool? ?? false,
      adhanMaghrib: json['adhanMaghrib'] as bool? ?? false,
      adhanIsha: json['adhanIsha'] as bool? ?? false,
      useManualTimes: json['useManualTimes'] as bool? ?? false,
      manualFajrMinutes: json['manualFajrMinutes'] as int? ?? 5 * 60,
      manualDhuhrMinutes: json['manualDhuhrMinutes'] as int? ?? 12 * 60 + 30,
      manualAsrMinutes: json['manualAsrMinutes'] as int? ?? 15 * 60 + 45,
      manualMaghribMinutes:
          json['manualMaghribMinutes'] as int? ?? 18 * 60 + 15,
      manualIshaMinutes: json['manualIshaMinutes'] as int? ?? 19 * 60 + 45,
    );
  }
}

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(notificationPrefsKey);
    if (raw == null) return const NotificationPrefs();
    return NotificationPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updatePrefs(
    NotificationPrefs Function(NotificationPrefs current) updater,
  ) async {
    final next = updater(state.value ?? const NotificationPrefs());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(notificationPrefsKey, jsonEncode(next.toJson()));
    state = AsyncData(next);
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);
