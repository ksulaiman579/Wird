import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/notifications/prayer_method_prefs.dart';

import '../test_helpers/first_value.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('defaults to null (auto)', () async {
    final result = await firstValue<int?>(container, prayerMethodOverrideProvider);
    expect(result, isNull);
  });

  test('setOverride persists and updates state', () async {
    await firstValue<int?>(container, prayerMethodOverrideProvider);
    await container.read(prayerMethodOverrideProvider.notifier).setOverride(4);

    expect(container.read(prayerMethodOverrideProvider).value, 4);
  });

  test('reloads a previously stored override from a fresh container', () async {
    await container.read(prayerMethodOverrideProvider.notifier).setOverride(13);

    final freshContainer = ProviderContainer();
    final reloaded = await firstValue<int?>(freshContainer, prayerMethodOverrideProvider);
    freshContainer.dispose();

    expect(reloaded, 13);
  });

  test('setOverride(null) clears back to auto', () async {
    await container.read(prayerMethodOverrideProvider.notifier).setOverride(4);
    await container.read(prayerMethodOverrideProvider.notifier).setOverride(null);

    expect(container.read(prayerMethodOverrideProvider).value, isNull);
  });
}
