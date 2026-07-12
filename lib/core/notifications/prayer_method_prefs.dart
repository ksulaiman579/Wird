import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const prayerMethodOverridePrefsKey = 'prayer_method_override';

/// Null means "auto" — [calculationMethodFor]'s country-based mapping (or
/// the Muslim World League default). A non-null value overrides that,
/// per Settings' manual method picker (M7.3).
class PrayerMethodOverrideNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prayerMethodOverridePrefsKey);
  }

  Future<void> setOverride(int? method) async {
    final prefs = await SharedPreferences.getInstance();
    if (method == null) {
      await prefs.remove(prayerMethodOverridePrefsKey);
    } else {
      await prefs.setInt(prayerMethodOverridePrefsKey, method);
    }
    state = AsyncData(method);
  }
}

final prayerMethodOverrideProvider =
    AsyncNotifierProvider<PrayerMethodOverrideNotifier, int?>(
  PrayerMethodOverrideNotifier.new,
);
