import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/notifications/location_prefs.dart';

import '../test_helpers/first_value.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('defaults to null (no location set)', () async {
    final result = await firstValue<SelectedLocation?>(container, locationProvider);
    expect(result, isNull);
  });

  test('setLocation persists and updates state', () async {
    await firstValue<SelectedLocation?>(container, locationProvider);

    await container.read(locationProvider.notifier).setLocation(
          const SelectedLocation(
            name: 'Riyadh',
            countryCode: 'SA',
            lat: 24.68773,
            lng: 46.72185,
          ),
        );

    final current = container.read(locationProvider).value;
    expect(current?.name, 'Riyadh');
    expect(current?.countryCode, 'SA');
  });

  test('reloads a previously stored location from a fresh container', () async {
    await container.read(locationProvider.notifier).setLocation(
          const SelectedLocation(
            name: 'Custom location',
            lat: 1.5,
            lng: 2.5,
          ),
        );

    final freshContainer = ProviderContainer();
    final reloaded =
        await firstValue<SelectedLocation?>(freshContainer, locationProvider);
    freshContainer.dispose();

    expect(reloaded?.name, 'Custom location');
    expect(reloaded?.countryCode, isNull);
    expect(reloaded?.lat, 1.5);
  });

  test('clear removes the stored location', () async {
    await container.read(locationProvider.notifier).setLocation(
          const SelectedLocation(name: 'Riyadh', lat: 24.68773, lng: 46.72185),
        );
    await container.read(locationProvider.notifier).clear();

    expect(container.read(locationProvider).value, isNull);
  });
}
