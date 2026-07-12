import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/qibla_math.dart';

void main() {
  group('qiblaBearing', () {
    test('due south of the Kaaba (same longitude) points due north', () {
      final bearing = qiblaBearing(latitude: 0, longitude: kaabaLongitude);
      expect(bearing, closeTo(0, 0.001));
    });

    test('due north of the Kaaba (same longitude) points due south', () {
      final bearing = qiblaBearing(latitude: 40, longitude: kaabaLongitude);
      expect(bearing, closeTo(180, 0.001));
    });

    test('London', () {
      final bearing = qiblaBearing(latitude: 51.5074, longitude: -0.1278);
      expect(bearing, closeTo(118.987, 0.01));
    });

    test('New York', () {
      final bearing = qiblaBearing(latitude: 40.7128, longitude: -74.0060);
      expect(bearing, closeTo(58.482, 0.01));
    });

    test('Jakarta', () {
      final bearing = qiblaBearing(latitude: -6.2088, longitude: 106.8456);
      expect(bearing, closeTo(295.152, 0.01));
    });

    test('Sydney', () {
      final bearing = qiblaBearing(latitude: -33.8688, longitude: 151.2093);
      expect(bearing, closeTo(277.5, 0.01));
    });

    test('result is always normalized to [0, 360)', () {
      final bearing = qiblaBearing(latitude: -33.8688, longitude: 151.2093);
      expect(bearing, greaterThanOrEqualTo(0));
      expect(bearing, lessThan(360));
    });
  });
}
