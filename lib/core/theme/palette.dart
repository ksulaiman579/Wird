import 'package:flutter/material.dart';

/// A curated emerald+gold colour scheme the user can pick in Settings
/// (M22.2). Every preset stays within the app's emerald/gold identity and
/// is WCAG-AA checked (see test/theme/app_theme_contrast_test.dart, which
/// iterates all palettes x modes). This is the small set of hue anchors
/// the rest of the theme (`app_theme.dart`) is built from.
class WirdPalette {
  const WirdPalette({
    required this.id,
    required this.name,
    required this.seed,
    required this.gold,
    required this.chromeLight,
    required this.chromeDark,
    required this.chromeForeground,
    required this.lightGradient,
    required this.darkGradient,
    required this.lightSurface,
    required this.darkSurface,
    required this.cardLight,
  });

  final String id;
  final String name;

  /// Emerald seed for `ColorScheme.fromSeed`.
  final Color seed;

  /// Gold accent — used for FilledButtons (with black text) and accents.
  final Color gold;

  /// App-bar / nav chrome band, light and dark modes.
  final Color chromeLight;
  final Color chromeDark;

  /// Title/icon colour on the chrome band (AA on both chrome shades).
  final Color chromeForeground;

  final List<Color> lightGradient;
  final List<Color> darkGradient;
  final Color lightSurface;
  final Color darkSurface;

  /// Card fill in light mode — a warm parchment (the reference renders'
  /// cards are parchment, a touch lighter than the page, not pure white).
  final Color cardLight;
}

// Classic = sampled directly from the reference renders (M22.8): medium
// emerald-teal chrome, muted brass-gold, warm cream page, parchment cards.
const _classic = WirdPalette(
  id: 'classic',
  name: 'Classic Emerald & Gold',
  seed: Color(0xFF1E6B4F),
  gold: Color(0xFFC9A961),
  chromeLight: Color(0xFF244C3A),
  chromeDark: Color(0xFF1C3D2E),
  chromeForeground: Color(0xFFE6D8A8),
  lightGradient: [Color(0xFFE8DFCB), Color(0xFFEFE7D4)],
  darkGradient: [Color(0xFF23352B), Color(0xFF182720)],
  lightSurface: Color(0xFFEBE2CF),
  darkSurface: Color(0xFF23352B),
  cardLight: Color(0xFFF4EDDB),
);

const _forest = WirdPalette(
  id: 'forest',
  name: 'Deep Forest & Brass',
  seed: Color(0xFF0B3D2E),
  gold: Color(0xFFB9975A),
  chromeLight: Color(0xFF1B4032),
  chromeDark: Color(0xFF12301F),
  chromeForeground: Color(0xFFDECB94),
  lightGradient: [Color(0xFFE7E0CE), Color(0xFFF0EAD8)],
  darkGradient: [Color(0xFF1D2C24), Color(0xFF13201A)],
  lightSurface: Color(0xFFEAE3D0),
  darkSurface: Color(0xFF1D2C24),
  cardLight: Color(0xFFF2ECDA),
);

const _jade = WirdPalette(
  id: 'jade',
  name: 'Jade & Champagne',
  seed: Color(0xFF1A7A5E),
  gold: Color(0xFFCBB679),
  chromeLight: Color(0xFF216B52),
  chromeDark: Color(0xFF124B39),
  chromeForeground: Color(0xFFEDDCA8),
  lightGradient: [Color(0xFFE9EFDF), Color(0xFFF2F6EA)],
  darkGradient: [Color(0xFF203A30), Color(0xFF152922)],
  lightSurface: Color(0xFFECF1E2),
  darkSurface: Color(0xFF203A30),
  cardLight: Color(0xFFF5F7EC),
);

// Midnight Emerald: sampled from the "Wird Devotional Hub" React reference
// (M23) — a deeper, more saturated chrome than Classic, paired with a warm
// off-white (not cream) surface. One more mix-and-match option; the mushaf
// reading surface itself stays cream regardless of the active swatch.
const _midnightEmerald = WirdPalette(
  id: 'midnight_emerald',
  name: 'Midnight Emerald',
  seed: Color(0xFF1F3D2F),
  gold: Color(0xFFD4AF6A),
  chromeLight: Color(0xFF1F3D2F),
  chromeDark: Color(0xFF15291F),
  chromeForeground: Color(0xFFEFDDA9),
  lightGradient: [Color(0xFFFAF7F2), Color(0xFFF3EEE3)],
  darkGradient: [Color(0xFF1B2A22), Color(0xFF121D17)],
  lightSurface: Color(0xFFFAF7F2),
  darkSurface: Color(0xFF1B2A22),
  cardLight: Color(0xFFFFFFFF),
);

const _sapphire = WirdPalette(
  id: 'sapphire',
  name: 'Royal Sapphire & Gold',
  seed: Color(0xFF183D5E),
  gold: Color(0xFFC9A961),
  chromeLight: Color(0xFF1E405C),
  chromeDark: Color(0xFF12283A),
  chromeForeground: Color(0xFFF2E6BF),
  lightGradient: [Color(0xFFE3EAF2), Color(0xFFEDF2F7)],
  darkGradient: [Color(0xFF192A3A), Color(0xFF111C26)],
  lightSurface: Color(0xFFE8EFF7),
  darkSurface: Color(0xFF192A3A),
  cardLight: Color(0xFFF4F8FA),
);

const _ruby = WirdPalette(
  id: 'ruby',
  name: 'Ottoman Ruby & Rose Gold',
  seed: Color(0xFF5E1E2C),
  gold: Color(0xFFC9A961),
  chromeLight: Color(0xFF5C2230),
  chromeDark: Color(0xFF3B151E),
  chromeForeground: Color(0xFFF5E4D8),
  lightGradient: [Color(0xFFF2E6E8), Color(0xFFF7ECEE)],
  darkGradient: [Color(0xFF381B22), Color(0xFF241115)],
  lightSurface: Color(0xFFF5EAEB),
  darkSurface: Color(0xFF381B22),
  cardLight: Color(0xFFFAF3F4),
);

const wirdPalettes = <WirdPalette>[
  _classic,
  _forest,
  _jade,
  _midnightEmerald,
  _sapphire,
  _ruby,
];
const defaultPalette = _classic;

WirdPalette paletteById(String? id) =>
    wirdPalettes.firstWhere((p) => p.id == id, orElse: () => defaultPalette);

