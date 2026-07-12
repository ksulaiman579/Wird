import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/geolocation_service.dart';
import '../../core/notifications/location_prefs.dart';
import 'city_picker.dart';

/// Reused by onboarding's notifications step and Settings — shows the
/// currently selected location (or the "using fixed 06:00/17:00 times"
/// fallback message) with buttons to auto-detect the device location or
/// open [showCityPicker].
class LocationSection extends ConsumerStatefulWidget {
  const LocationSection({super.key});

  @override
  ConsumerState<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<LocationSection> {
  bool _detecting = false;

  Future<void> _detect() async {
    setState(() => _detecting = true);
    try {
      final location = await ref.read(geolocationServiceProvider).detect();
      await ref.read(locationProvider.notifier).setLocation(location);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location set to ${location.name}.')),
        );
      }
    } on GeolocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).locationCouldNotDetect),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).locationTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        locationAsync.when(
          loading: () => Text(AppLocalizations.of(context).locationLoading),
          error: (error, stack) => Text('Failed to load: $error'),
          data: (location) => Text(
            location == null
                ? AppLocalizations.of(context).locationNoCity
                : '${location.name}${location.countryCode != null ? '' : ' (custom coordinates)'}',
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              icon: _detecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_detecting ? AppLocalizations.of(context).locationDetecting : AppLocalizations.of(context).locationUseMyLocation),
              onPressed: _detecting ? null : _detect,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.location_on_outlined),
              label: Text(AppLocalizations.of(context).locationChooseCity),
              onPressed: _detecting
                  ? null
                  : () async {
                      final result = await showCityPicker(context);
                      if (result != null) {
                        await ref
                            .read(locationProvider.notifier)
                            .setLocation(result);
                      }
                    },
            ),
          ],
        ),
      ],
    );
  }
}
