import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'location_prefs.dart';

/// Raised when device location can't be obtained. [message] is user-facing.
class GeolocationException implements Exception {
  const GeolocationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Builds the display name for a detected location from reverse-geocoding
/// fields, falling back to formatted coordinates when none are usable.
/// Pure so it can be unit-tested without platform channels.
String formatLocationName({
  String? locality,
  String? administrativeArea,
  String? country,
  required double lat,
  required double lng,
}) {
  final city = (locality != null && locality.isNotEmpty)
      ? locality
      : (administrativeArea ?? '');
  final parts = [city, country ?? '']
      .where((s) => s.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'My location (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
  }
  return parts.join(', ');
}

/// Wraps `geolocator` (device GPS + permissions) and `geocoding` (reverse
/// lookup for a country code, so the right prayer-time calculation method
/// is picked). Reverse geocoding is best-effort — on platforms where it's
/// unavailable (e.g. web) the detected coordinates are kept with a
/// coordinate-based name and no country code.
class GeolocationService {
  const GeolocationService();

  /// Requests permission if needed and returns the device's current
  /// location as a [SelectedLocation]. Throws [GeolocationException] with a
  /// user-facing message on any failure.
  Future<SelectedLocation> detect() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const GeolocationException(
        'Location services are turned off. Enable them in your device '
        'settings, then try again.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const GeolocationException(
        'Location permission was denied. You can still pick a city manually.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const GeolocationException(
        'Location permission is permanently denied. Enable it in your app '
        'settings, or pick a city manually.',
      );
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (e) {
      throw const GeolocationException(
        'Could not read your location. Try again, or pick a city manually.',
      );
    }

    return locationFromCoordinates(position.latitude, position.longitude);
  }

  /// Reverse-geocodes [lat]/[lng] into a named [SelectedLocation]. Falls
  /// back to a coordinate-only location if geocoding is unavailable.
  Future<SelectedLocation> locationFromCoordinates(
    double lat,
    double lng,
  ) async {
    String? locality;
    String? administrativeArea;
    String? country;
    String? countryCode;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        locality = p.locality;
        administrativeArea = p.administrativeArea;
        country = p.country;
        countryCode = (p.isoCountryCode != null && p.isoCountryCode!.isNotEmpty)
            ? p.isoCountryCode
            : null;
      }
    } catch (_) {
      // Reverse geocoding unavailable (e.g. web) — keep coordinates only.
    }

    return SelectedLocation(
      name: formatLocationName(
        locality: locality,
        administrativeArea: administrativeArea,
        country: country,
        lat: lat,
        lng: lng,
      ),
      lat: lat,
      lng: lng,
      countryCode: countryCode,
    );
  }
}

final geolocationServiceProvider =
    Provider<GeolocationService>((ref) => const GeolocationService());
