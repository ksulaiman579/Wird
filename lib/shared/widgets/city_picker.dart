import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/city_repository.dart';
import '../../core/content/models/city.dart';
import '../../core/notifications/location_prefs.dart';

/// Opens a full-screen searchable city picker (with a manual lat/lng
/// fallback) and returns the chosen [SelectedLocation], or null if the
/// user backed out without choosing one.
Future<SelectedLocation?> showCityPicker(BuildContext context) {
  return Navigator.of(context).push<SelectedLocation>(
    MaterialPageRoute(builder: (_) => const _CityPickerScreen()),
  );
}

class _CityPickerScreen extends ConsumerStatefulWidget {
  const _CityPickerScreen();

  @override
  ConsumerState<_CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<_CityPickerScreen> {
  String _query = '';

  Future<void> _enterManually() async {
    final result = await showDialog<SelectedLocation>(
      context: context,
      builder: (context) => const _ManualCoordinatesDialog(),
    );
    if (result != null && mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(_citiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).citySearchHint,
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: citiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load: $error')),
        data: (cities) {
          final query = _query.trim().toLowerCase();
          final matches = query.isEmpty
              ? cities
              : cities
                  .where((c) =>
                      c.name.toLowerCase().contains(query) ||
                      c.country.toLowerCase().contains(query))
                  .toList();

          return ListView.builder(
            itemCount: matches.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.edit_location_alt_rounded),
                  title: Text(AppLocalizations.of(context).cityCoordManually),
                  onTap: _enterManually,
                );
              }
              final city = matches[index - 1];
              return ListTile(
                title: Text(city.name),
                subtitle: Text(city.country),
                onTap: () => Navigator.of(context).pop(SelectedLocation(
                  name: city.name,
                  countryCode: city.countryCode,
                  lat: city.lat,
                  lng: city.lng,
                )),
              );
            },
          );
        },
      ),
    );
  }
}

final _citiesProvider = FutureProvider<List<City>>((ref) {
  return ref.read(cityRepositoryProvider).loadAll();
});

class _ManualCoordinatesDialog extends StatefulWidget {
  const _ManualCoordinatesDialog();

  @override
  State<_ManualCoordinatesDialog> createState() =>
      _ManualCoordinatesDialogState();
}

class _ManualCoordinatesDialogState extends State<_ManualCoordinatesDialog> {
  final _nameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.cityEnterCoords),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l.cityLabelOptional),
          ),
          TextField(
            controller: _latController,
            decoration: InputDecoration(labelText: l.cityLatitude),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          TextField(
            controller: _lngController,
            decoration: InputDecoration(labelText: l.cityLongitude),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final lat = double.tryParse(_latController.text);
            final lng = double.tryParse(_lngController.text);
            if (lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
              return;
            }
            final name = _nameController.text.trim();
            Navigator.of(context).pop(SelectedLocation(
              name: name.isEmpty ? l.cityCustomLocation : name,
              lat: lat,
              lng: lng,
            ));
          },
          child: Text(l.cityUseCoords),
        ),
      ],
    );
  }
}
