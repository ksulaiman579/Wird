import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/theme/app_theme.dart';
import 'package:wird/core/theme/theme_mode_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to system when nothing is stored', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeProvider.future);
    expect(mode, AppThemeMode.system);
  });

  test('setMode persists and updates state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(themeModeProvider.future);
    await container.read(themeModeProvider.notifier).setMode(AppThemeMode.amoled);

    expect(container.read(themeModeProvider).value, AppThemeMode.amoled);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(themeModePrefsKey), 'amoled');
  });

  test('reloads a previously stored mode', () async {
    SharedPreferences.setMockInitialValues({themeModePrefsKey: 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = await container.read(themeModeProvider.future);
    expect(mode, AppThemeMode.dark);
  });
}
