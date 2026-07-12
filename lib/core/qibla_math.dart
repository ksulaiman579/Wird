/// Pure Qibla bearing math (M15.1) — no Flutter import, unit-tested
/// directly. `lib/features/qibla/` is the presentation layer on top.
library;

import 'dart:math' as math;

const double kaabaLatitude = 21.4225;
const double kaabaLongitude = 39.8262;

double _toRadians(double degrees) => degrees * math.pi / 180;
double _toDegrees(double radians) => radians * 180 / math.pi;

/// Initial great-circle bearing from ([latitude], [longitude]) to the
/// Kaaba, in degrees clockwise from true north, normalized to [0, 360).
double qiblaBearing({required double latitude, required double longitude}) {
  final phi1 = _toRadians(latitude);
  final phi2 = _toRadians(kaabaLatitude);
  final deltaLambda = _toRadians(kaabaLongitude - longitude);

  final y = math.sin(deltaLambda) * math.cos(phi2);
  final x = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

  final theta = math.atan2(y, x);
  return (_toDegrees(theta) + 360) % 360;
}
