import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'palette.dart';

const palettePrefsKey = 'palette_id';

/// Persists the user's chosen [WirdPalette] id (M22.2), mirroring
/// `theme_mode_provider.dart`.
class PaletteNotifier extends AsyncNotifier<WirdPalette> {
  @override
  Future<WirdPalette> build() async {
    final prefs = await SharedPreferences.getInstance();
    return paletteById(prefs.getString(palettePrefsKey));
  }

  Future<void> setPalette(WirdPalette palette) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(palettePrefsKey, palette.id);
    state = AsyncData(palette);
  }
}

final paletteProvider =
    AsyncNotifierProvider<PaletteNotifier, WirdPalette>(PaletteNotifier.new);
