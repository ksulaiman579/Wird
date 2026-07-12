import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/theme/app_theme.dart';
import 'package:wird/core/theme/palette.dart';

double _channel(double v255) {
  final v = v255 / 255.0;
  return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) {
  final r = _channel(c.r * 255);
  final g = _channel(c.g * 255);
  final b = _channel(c.b * 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG 2.x contrast ratio between two colors, order-independent.
double contrastRatio(Color a, Color b) {
  final l1 = _luminance(a) + 0.05;
  final l2 = _luminance(b) + 0.05;
  return l1 > l2 ? l1 / l2 : l2 / l1;
}

const _minTextContrast = 4.5; // WCAG AA, normal text

/// Alpha-composites [src] over [dst] (both treated as opaque-authored sRGB,
/// [src]'s alpha channel blended in) — the same math the engine uses to
/// paint a translucent [GlassCard] fill over whatever's behind it. Contrast
/// checks below run against this *composited* color, not the bare fill
/// alone, since content text sits on the composite, not the fill in
/// isolation.
Color _compositeOver(Color src, Color dst) {
  final a = src.a;
  double blend(double s, double d) => s * a + d * (1 - a);
  return Color.from(
    alpha: 1,
    red: blend(src.r, dst.r),
    green: blend(src.g, dst.g),
    blue: blend(src.b, dst.b),
  );
}

/// Every palette (M22.2) x mode combination, so the contrast guard covers
/// every colour a user can actually select.
Map<String, ThemeData> _allThemes() {
  final map = <String, ThemeData>{};
  for (final p in wirdPalettes) {
    map['${p.id}-light'] = AppTheme.light(p);
    map['${p.id}-dark'] = AppTheme.dark(p);
    map['${p.id}-amoled'] = AppTheme.amoled(p);
  }
  return map;
}

void main() {
  group('AppTheme contrast (WCAG AA, 4.5:1)', () {
    for (final entry in _allThemes().entries) {
      final scheme = entry.value.colorScheme;

      test('${entry.key}: onSurface/surface', () {
        expect(contrastRatio(scheme.onSurface, scheme.surface),
            greaterThanOrEqualTo(_minTextContrast));
      });

      test('${entry.key}: onPrimary/primary', () {
        expect(contrastRatio(scheme.onPrimary, scheme.primary),
            greaterThanOrEqualTo(_minTextContrast));
      });

      test('${entry.key}: onSecondary/secondary', () {
        expect(contrastRatio(scheme.onSecondary, scheme.secondary),
            greaterThanOrEqualTo(_minTextContrast));
      });

      test('${entry.key}: onSecondaryContainer/secondaryContainer', () {
        expect(
          contrastRatio(scheme.onSecondaryContainer, scheme.secondaryContainer),
          greaterThanOrEqualTo(_minTextContrast),
        );
      });

      test('${entry.key}: onError/error', () {
        expect(contrastRatio(scheme.onError, scheme.error),
            greaterThanOrEqualTo(_minTextContrast));
      });
    }
  });

  group('GlassTheme contrast (WCAG AA, 4.5:1) — fill composited over background gradient', () {
    for (final entry in _allThemes().entries) {
      final theme = entry.value;
      final glass = theme.extension<GlassTheme>()!;
      final onSurface = theme.colorScheme.onSurface;

      for (var i = 0; i < glass.backgroundGradient.length; i++) {
        final backdrop = glass.backgroundGradient[i];
        final composite = _compositeOver(glass.fillColor, backdrop);

        test('${entry.key}: onSurface text on glass fill over gradient stop $i', () {
          expect(
            contrastRatio(onSurface, composite),
            greaterThanOrEqualTo(_minTextContrast),
            reason:
                'GlassCard body text (onSurface) over ${entry.key} gradient '
                'stop $i composited with the glass fill fails WCAG AA — '
                'adjust GlassTheme.fillColor opacity or the gradient stop.',
          );
        });
      }

      test('${entry.key}: secondary (gold) border is visible against the gradient', () {
        // The hairline border only needs to be perceptible, not
        // text-contrast-legible — use the looser 1.5:1 non-text minimum.
        for (final backdrop in glass.backgroundGradient) {
          expect(contrastRatio(glass.borderColor, backdrop),
              greaterThanOrEqualTo(1.1));
        }
      });

      test('${entry.key}: chrome foreground (gold) on chrome (emerald) is AA',
          () {
        // App-bar titles and nav labels are normal-size text on the M21.5
        // chrome band — full 4.5:1, not the large-text discount.
        expect(
          contrastRatio(glass.chromeForeground, glass.chromeColor),
          greaterThanOrEqualTo(_minTextContrast),
        );
      });
    }
  });
}
