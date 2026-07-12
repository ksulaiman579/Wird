import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A circular progress indicator styled for the glass theme: a gold ring
/// over a translucent track, with an optional centered label (e.g. a tasbih
/// count or a streak percentage).
///
/// This widget does not blur — it's meant to sit on top of a [GlassCard] or
/// an already-blurred background, not to create its own blurred region.
class GlassProgressRing extends StatelessWidget {
  const GlassProgressRing({
    super.key,
    required this.progress,
    this.size = 96,
    this.strokeWidth = 8,
    this.center,
  });

  /// 0.0–1.0. Values outside that range are clamped.
  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glass = theme.extension<GlassTheme>() ?? GlassTheme.light;
    final clamped = progress.clamp(0.0, 1.0);

    // Isolated in its own layer (M23.13): the ring's paint (and any
    // animated progress) shouldn't invalidate the surrounding card/list.
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: glass.borderColor,
            ),
            // Animate-in / animate-to the target value (M23.14) so the ring
            // sweeps to its position instead of snapping.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                color: theme.colorScheme.secondary,
                backgroundColor: Colors.transparent,
              ),
            ),
            ?center,
          ],
        ),
      ),
    );
  }
}
