import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

/// A date in the app's language, e.g. "16 Nov 2026" / "١٦ نوفمبر ٢٠٢٦".
String formatDateLocalized(BuildContext context, DateTime d) {
  final tag = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat.yMMMd(tag).format(d);
  } catch (_) {
    return DateFormat.yMMMd('en').format(d);
  }
}

/// Hijri (Umm al-Qura) date in the app's language, shifted by [offsetDays]
/// to match local moon sighting.
String formatHijri(BuildContext context, DateTime d, {int offsetDays = 0}) {
  final l = AppLocalizations.of(context);
  final h = HijriCalendar.fromDate(d.add(Duration(days: offsetDays)));
  final months = [
    l.hijriMonth1, l.hijriMonth2, l.hijriMonth3, l.hijriMonth4,
    l.hijriMonth5, l.hijriMonth6, l.hijriMonth7, l.hijriMonth8,
    l.hijriMonth9, l.hijriMonth10, l.hijriMonth11, l.hijriMonth12,
  ];
  final tag = Localizations.localeOf(context).toLanguageTag();
  String n(int v) {
    try {
      return NumberFormat.decimalPattern(tag).format(v).replaceAll(',', '');
    } catch (_) {
      return '$v';
    }
  }

  return l.hijriDate(n(h.hDay), months[h.hMonth - 1], n(h.hYear));
}

/// Hijri date preferences: shown on Today, and a ±2 day adjustment.
class HijriPrefs {
  const HijriPrefs({this.show = true, this.offset = 0});
  final bool show;
  final int offset;
}

class HijriPrefsNotifier extends AsyncNotifier<HijriPrefs> {
  static const _showKey = 'hijri_show';
  static const _offsetKey = 'hijri_offset';

  @override
  Future<HijriPrefs> build() async {
    final p = await SharedPreferences.getInstance();
    return HijriPrefs(
      show: p.getBool(_showKey) ?? true,
      offset: p.getInt(_offsetKey) ?? 0,
    );
  }

  Future<void> setShow(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_showKey, v);
    state = AsyncData(HijriPrefs(show: v, offset: state.value?.offset ?? 0));
  }

  Future<void> setOffset(int v) async {
    final o = v.clamp(-2, 2);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_offsetKey, o);
    state = AsyncData(HijriPrefs(show: state.value?.show ?? true, offset: o));
  }
}

final hijriPrefsProvider =
    AsyncNotifierProvider<HijriPrefsNotifier, HijriPrefs>(HijriPrefsNotifier.new);
