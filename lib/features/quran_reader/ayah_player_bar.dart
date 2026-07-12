import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The reader's docked audio player (M22.3) — an emerald bar with gold
/// controls and a progress scrubber, styled after the reference render.
/// Purely presentational: the reader owns playback state and passes it in,
/// so this widget has no dependency on just_audio and is trivially testable.
class AyahPlayerBar extends StatelessWidget {
  const AyahPlayerBar({
    super.key,
    required this.playing,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onPrev,
    required this.onNext,
  });

  final bool playing;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final gold = glass.chromeForeground;
    final total = duration.inMilliseconds;
    final value = total == 0
        ? 0.0
        : (position.inMilliseconds / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: glass.chromeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: gold,
              inactiveTrackColor: gold.withValues(alpha: 0.25),
              thumbColor: gold,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            // Read-only progress for now (seek-within-ayah is a later
            // refinement); the value still animates as the ayah plays.
            child: Slider(value: value, onChanged: (_) {}),
          ),
          Row(
            children: [
              Text(_fmt(position),
                  style: TextStyle(color: gold, fontSize: 12)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                color: gold,
                onPressed: onPrev,
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(playing
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded),
                color: gold,
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                color: gold,
                onPressed: onNext,
              ),
              const Spacer(),
              Text(_fmt(duration),
                  style: TextStyle(color: gold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
