import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'palette.dart';

/// Available theme modes. `amoled` is a dark variant with a pure-black
/// background for OLED screens; distinct from Flutter's [ThemeMode] which
/// only knows light/dark/system.
enum AppThemeMode { system, light, dark, amoled }

/// Glassmorphism design tokens, threaded through [ThemeData.extensions] so
/// every glass widget (`lib/shared/glass/`) reads the same blur/fill/border
/// values instead of hardcoding them per-screen.
///
/// AMOLED gets its own instance with `blurSigma: 0` and a near-opaque fill:
/// blurring over a pure-black background has nothing to refract (it's
/// visually indistinguishable from a flat fill) and still costs a full-frame
/// backdrop pass on every device, so glass widgets must branch on
/// [blurSigma] and skip [BackdropFilter] entirely when it's zero.
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.blurSigma,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.cardRadius,
    required this.backgroundGradient,
    required this.chromeColor,
    required this.chromeForeground,
    required this.cardShadow,
  });

  /// Gaussian blur sigma for [BackdropFilter]. Zero means "skip the filter
  /// and use [fillColor] as a flat background" (the AMOLED case).
  final double blurSigma;

  /// Translucent (or, for AMOLED, near-opaque) fill painted over the blur.
  final Color fillColor;

  /// Hairline border color for glass surfaces — low-alpha gold or white.
  final Color borderColor;

  final double borderWidth;

  /// Corner radius for [GlassCard]-style containers. Pillbox components
  /// (`GlassPill`, `GlassNavBar`) use a [StadiumBorder] instead, independent
  /// of this value.
  final double cardRadius;

  /// Full-bleed scaffold background gradient that gives the blur something
  /// to refract. AMOLED intentionally stays flat black (no gradient) —
  /// see the class doc.
  final List<Color> backgroundGradient;

  /// App-bar / bottom-nav chrome fill — the deep-emerald band from the
  /// M21.5 "Royal Emerald" renders, distinct from card [fillColor].
  final Color chromeColor;

  /// Title/icon/label color on [chromeColor]. #E3C05C gold: 5.6:1 on the
  /// emerald chrome (WCAG AA needs 4.5:1; the brand gold #C9A227 only
  /// reaches 4.1:1, so it's reserved for accents on light surfaces).
  final Color chromeForeground;

  /// Soft drop shadow under floating cards — the depth that separates the
  /// M21 renders' white cards from the cream page. Empty on dark/AMOLED,
  /// where a shadow reads as muddy against a dark background.
  final List<BoxShadow> cardShadow;

  // M21.5 "Royal Emerald" (per inspiration/ renders): warm cream page,
  // pure-white floating cards, deep-emerald chrome with gold foreground.
  // (Supersedes M20.1's mint pastel, which the renders moved away from.)
  static const light = GlassTheme(
    blurSigma: 16,
    fillColor: Color(0xFFFFFFFF), // pure white card
    borderColor: Color(0x33C9A227), // soft gold hairline @ 20%
    borderWidth: 1,
    cardRadius: 28,
    backgroundGradient: [
      Color(0xFFF3ECD9), // warm cream
      Color(0xFFFBF7EC), // lighter ivory
    ],
    chromeColor: Color(0xFF0B4D36), // deep emerald
    chromeForeground: Color(0xFFE3C05C), // light gold
    cardShadow: [
      BoxShadow(
        color: Color(0x14000000), // black @ 8%
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0A000000), // black @ 4%
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
  );

  static const dark = GlassTheme(
    blurSigma: 16,
    fillColor: Color(0x1FFFFFFF), // white @ 12%
    borderColor: Color(0x40C9A227), // gold @ 25%
    borderWidth: 1,
    cardRadius: 28,
    backgroundGradient: [
      Color(0xFF23352B), // green slate
      Color(0xFF182720), // deeper green slate
    ],
    chromeColor: Color(0xFF0A3D2C), // deep emerald, a step darker
    chromeForeground: Color(0xFFE3C05C),
    cardShadow: [], // shadows read as mud on a dark background
  );

  static const amoled = GlassTheme(
    blurSigma: 0,
    fillColor: Color(0xFF121212), // near-opaque dark card, no blur
    borderColor: Color(0x30C9A227), // gold @ 19%, subtler on pure black
    borderWidth: 1,
    cardRadius: 28,
    backgroundGradient: [Colors.black, Colors.black],
    chromeColor: Color(0xFF0A0A0A), // near-black chrome, no green glow
    chromeForeground: Color(0xFFE3C05C),
    cardShadow: [],
  );

  /// Build the light/dark/amoled glass tokens from a chosen [WirdPalette]
  /// (M22.2). The const `light`/`dark`/`amoled` above stay as the Classic
  /// palette — used as the `?? GlassTheme.light` fallback in glass widgets
  /// and by older tests.
  static GlassTheme lightFor(WirdPalette p) => GlassTheme(
        blurSigma: 16,
        fillColor: p.cardLight,
        borderColor: p.gold.withValues(alpha: 0.14),
        borderWidth: 1,
        cardRadius: 28,
        backgroundGradient: p.lightGradient,
        chromeColor: p.chromeLight,
        chromeForeground: p.chromeForeground,
        cardShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      );

  static GlassTheme darkFor(WirdPalette p) => GlassTheme(
        blurSigma: 16,
        fillColor: const Color(0x1FFFFFFF),
        borderColor: p.gold.withValues(alpha: 0.25),
        borderWidth: 1,
        cardRadius: 28,
        backgroundGradient: p.darkGradient,
        chromeColor: p.chromeDark,
        chromeForeground: p.chromeForeground,
        cardShadow: const [],
      );

  static GlassTheme amoledFor(WirdPalette p) => GlassTheme(
        blurSigma: 0,
        fillColor: const Color(0xFF121212),
        borderColor: p.gold.withValues(alpha: 0.19),
        borderWidth: 1,
        cardRadius: 28,
        backgroundGradient: const [Colors.black, Colors.black],
        chromeColor: const Color(0xFF0A0A0A),
        chromeForeground: p.chromeForeground,
        cardShadow: const [],
      );

  @override
  GlassTheme copyWith({
    double? blurSigma,
    Color? fillColor,
    Color? borderColor,
    double? borderWidth,
    double? cardRadius,
    List<Color>? backgroundGradient,
    Color? chromeColor,
    Color? chromeForeground,
    List<BoxShadow>? cardShadow,
  }) {
    return GlassTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      cardRadius: cardRadius ?? this.cardRadius,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      chromeColor: chromeColor ?? this.chromeColor,
      chromeForeground: chromeForeground ?? this.chromeForeground,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  GlassTheme lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      fillColor: Color.lerp(fillColor, other.fillColor, t) ?? fillColor,
      borderColor:
          Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      borderWidth:
          lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      backgroundGradient: t < 0.5 ? backgroundGradient : other.backgroundGradient,
      chromeColor:
          Color.lerp(chromeColor, other.chromeColor, t) ?? chromeColor,
      chromeForeground:
          Color.lerp(chromeForeground, other.chromeForeground, t) ??
              chromeForeground,
      cardShadow:
          BoxShadow.lerpList(cardShadow, other.cardShadow, t) ?? cardShadow,
    );
  }
}

/// Text style for Quran Arabic text: the bundled Uthmani font, generous
/// line height for diacritics, right-to-left by default via directionality
/// set at the widget level (not here).
const quranTextStyle = TextStyle(
  fontFamily: 'UthmanicHafs',
  fontSize: 28,
  height: 2.2,
);

class AppTheme {
  AppTheme._();

  static ThemeData light([WirdPalette palette = defaultPalette]) =>
      _build(Brightness.light, palette)
          .copyWith(extensions: [GlassTheme.lightFor(palette)]);

  static ThemeData dark([WirdPalette palette = defaultPalette]) =>
      _build(Brightness.dark, palette)
          .copyWith(extensions: [GlassTheme.darkFor(palette)]);

  static ThemeData amoled([WirdPalette palette = defaultPalette]) =>
      _build(Brightness.dark, palette).copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: _build(Brightness.dark, palette).colorScheme.copyWith(
              surface: Colors.black,
            ),
        extensions: [GlassTheme.amoledFor(palette)],
      );

  static ThemeData _build(Brightness brightness, WirdPalette palette) {
    // `ColorScheme.fromSeed`'s auto-generated `onSecondary` (white) fails
    // WCAG contrast against gold in light mode (2.4:1, needs 4.5:1) — gold
    // is too light a tone for white text. Black passes in both modes
    // (verified 7.6:1 light / 8.7:1 dark), so it's overridden explicitly
    // rather than trusted to the algorithm. `onSecondaryContainer`/
    // `secondaryContainer` are left alone — those already pass (~7.2:1).
    // Gold is meant for icon/badge tinting and container-style
    // backgrounds (paired with `onSecondaryContainer`); avoid using
    // `colorScheme.secondary` directly as small text color on `surface` —
    // that specific pairing fails contrast (2.3:1) in light mode.
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: brightness,
      secondary: palette.gold,
    ).copyWith(
      onSecondary: Colors.black,
      surface: brightness == Brightness.light
          ? palette.lightSurface
          : palette.darkSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );

    // M21.7: a bolder, more deliberate type scale — the flat default
    // weights read as "dull". Headlines/titles get weight + tighter
    // tracking so screen headers ("My Progress", "Sahih Bukhari") carry
    // the presence they have in the reference renders.
    final display = brightness == Brightness.light
        ? palette.chromeLight // emerald headings on cream
        : scheme.onSurface;
    // Marcellus (SIL OFL) is a refined classical-serif display face —
    // it gives headings the elegant, "carved" feel of the reference
    // renders that flat Roboto weights can't. Display/headline/title
    // roles only; body stays the system face for legibility.
    final textTheme = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontFamily: 'Marcellus',
        color: display,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'Marcellus',
        color: display,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontFamily: 'Marcellus',
        letterSpacing: -0.2,
        color: display,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Marcellus',
        color: display,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: display,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      // Gold pill buttons with dark text — the render's primary CTA
      // ("Resume", "Get the App"). Palette gold + black text passes AA.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.gold,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  static ThemeMode flutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }
}
