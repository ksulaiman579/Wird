import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
