import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const locationPrefsKey = 'selected_location';

/// The user's chosen location for prayer-time calculation — either a
/// picked city ([countryCode] set) or manually entered coordinates
/// ([countryCode] null). No location stored means "not set"; callers
/// (Today/Adhkar, M5.3's notification scheduling) fall back to fixed
/// 06:00/17:00 reminder times in that case, per the plan.
class SelectedLocation {
  const SelectedLocation({
    required this.name,
    required this.lat,
    required this.lng,
    this.countryCode,
  });

  final String name;
  final String? countryCode;
  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
        'name': name,
        'countryCode': countryCode,
        'lat': lat,
        'lng': lng,
      };

  factory SelectedLocation.fromJson(Map<String, dynamic> json) =>
      SelectedLocation(
        name: json['name'] as String,
        countryCode: json['countryCode'] as String?,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class LocationNotifier extends AsyncNotifier<SelectedLocation?> {
  @override
  Future<SelectedLocation?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(locationPrefsKey);
    if (raw == null) return null;
    return SelectedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> setLocation(SelectedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(locationPrefsKey, jsonEncode(location.toJson()));
    state = AsyncData(location);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(locationPrefsKey);
    state = const AsyncData(null);
  }
}

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, SelectedLocation?>(
  LocationNotifier.new,
);
