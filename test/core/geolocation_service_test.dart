import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/notifications/geolocation_service.dart';

void main() {
  group('formatLocationName', () {
    test('uses locality and country when available', () {
      expect(
        formatLocationName(
          locality: 'Manama',
          administrativeArea: 'Capital',
          country: 'Bahrain',
          lat: 26.2,
          lng: 50.6,
        ),
        'Manama, Bahrain',
      );
    });

    test('falls back to administrative area when locality is empty', () {
      expect(
        formatLocationName(
          locality: '',
          administrativeArea: 'Riyadh Province',
          country: 'Saudi Arabia',
          lat: 24.7,
          lng: 46.7,
        ),
        'Riyadh Province, Saudi Arabia',
      );
    });

    test('omits missing pieces', () {
      expect(
        formatLocationName(
          locality: 'Cairo',
          administrativeArea: null,
          country: null,
          lat: 30.0,
          lng: 31.2,
        ),
        'Cairo',
      );
    });

    test('falls back to coordinates when nothing is usable', () {
      expect(
        formatLocationName(
          locality: null,
          administrativeArea: null,
          country: null,
          lat: 12.345,
          lng: -6.789,
        ),
        'My location (12.35, -6.79)',
      );
    });
  });
}
