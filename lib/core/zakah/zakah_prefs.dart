import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Zakah screen's last-entered values so the calculator is not
/// a blank slate on every visit. Stored as one JSON blob under a single key
/// — purely a convenience cache, never synced or backed up.
const zakahPrefsKey = 'zakah_last_inputs';

Future<Map<String, dynamic>> loadZakahState() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(zakahPrefsKey);
  if (raw == null || raw.isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : {};
  } catch (_) {
    return {};
  }
}

Future<void> saveZakahState(Map<String, dynamic> state) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(zakahPrefsKey, jsonEncode(state));
}
