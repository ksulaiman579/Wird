import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/notifications/location_prefs.dart';
import 'package:wird/features/qibla/qibla_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('prompts to set a location when none is chosen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: QiblaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set your city to calculate the Qibla direction — the '
        'same location used for prayer times.'), findsOneWidget);
  });

  testWidgets('shows the bearing and city disclaimer once a location is set',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(locationProvider.notifier).setLocation(
          const SelectedLocation(
            name: 'London',
            countryCode: 'GB',
            lat: 51.5074,
            lng: -0.1278,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: QiblaScreen()),
      ),
    );
    // AnimatedRotation/GlassScaffold never fully settle — pump a fixed
    // number of frames instead of pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.textContaining('Based on London'), findsOneWidget);
    // Web test target (flutter test runs on the VM, kIsWeb is false, but
    // the magnetometer stream never emits in this headless container —
    // the screen should show its "reading compass" loading state rather
    // than hang or throw).
    expect(find.textContaining('Reading compass'), findsOneWidget);
  });
}
