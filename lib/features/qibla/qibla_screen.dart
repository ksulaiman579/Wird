import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/notifications/location_prefs.dart';
import '../../core/qibla_math.dart';
import '../../shared/glass/glass.dart';
import '../../shared/widgets/location_section.dart';

/// Qibla compass (M15.1). Native: a magnetometer-driven compass rose that
/// rotates the Qibla arrow relative to the phone's live heading. Web:
/// `DeviceOrientationEvent` support is unreliable across browsers, so it
/// shows a static bearing instead (the number + "X° from North" dial,
/// no live rotation) — this is a deliberate simplification, not a bug.
/// Both modes need a location (city-level, via [locationProvider]) to
/// compute the bearing; a disclaimer names the city used, since it's not
/// GPS-precise.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).qiblaTitle)),
      body: locationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
        data: (location) {
          if (location == null) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).qiblaSetCity),
                  const SizedBox(height: 16),
                  const LocationSection(),
                ],
              ),
            );
          }

          final bearing = qiblaBearing(
            latitude: location.lat,
            longitude: location.lng,
          );

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: kIsWeb
                      ? _StaticBearingDial(bearing: bearing)
                      : _LiveCompass(bearing: bearing),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context).qiblaBasedOn(location.name),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaticBearingDial extends StatelessWidget {
  const _StaticBearingDial({required this.bearing});

  final double bearing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompassRose(rotationDegrees: bearing),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context).qiblaFromNorth(bearing.round()),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

/// Native compass: rotates the arrow by `bearing - heading` so it always
/// points at the Kaaba regardless of which way the phone faces, using the
/// device magnetometer for `heading`. Falls back to the static dial if the
/// sensor stream errors (e.g. no magnetometer, permission denied).
class _LiveCompass extends StatefulWidget {
  const _LiveCompass({required this.bearing});

  final double bearing;

  @override
  State<_LiveCompass> createState() => _LiveCompassState();
}

class _LiveCompassState extends State<_LiveCompass> {
  StreamSubscription<MagnetometerEvent>? _sub;
  double? _heading;
  bool _sensorFailed = false;

  @override
  void initState() {
    super.initState();
    _sub = magnetometerEventStream().listen(
      (event) {
        // Simplified flat-plane heading — no tilt compensation. Good
        // enough for "roughly which way to face", not surveying-grade.
        final headingRad = math.atan2(event.y, event.x);
        final heading = (90 - headingRad * 180 / math.pi + 360) % 360;
        if (mounted) setState(() => _heading = heading);
      },
      onError: (_) {
        if (mounted) setState(() => _sensorFailed = true);
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sensorFailed) return _StaticBearingDial(bearing: widget.bearing);
    if (_heading == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).qiblaReadingCompass),
        ],
      );
    }

    final relativeBearing = (widget.bearing - _heading! + 360) % 360;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CompassRose(rotationDegrees: relativeBearing),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)
              .qiblaFacing(_heading!.round(), widget.bearing.round()),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CompassRose extends StatelessWidget {
  const _CompassRose({required this.rotationDegrees});

  final double rotationDegrees;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant, width: 2),
            ),
          ),
          Positioned(
            top: 8,
            child: Text(AppLocalizations.of(context).qiblaNorth),
          ),
          AnimatedRotation(
            turns: rotationDegrees / 360,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.navigation_rounded,
              size: 96,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
