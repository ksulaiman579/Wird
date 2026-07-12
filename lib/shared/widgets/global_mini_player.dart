import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;

import '../../core/audio/ayah_audio_service.dart' show AyahPlayback;
import '../../core/theme/app_theme.dart';
import '../../features/session/now_playing_provider.dart';
import '../../features/session/session_audio_providers.dart';

/// The renders' docked mini-player (M23.2 design spec): an emerald panel
/// with a centered track-title pill, gold circular play/pause + skip, and
/// a thin gold progress line — sitting directly above the bottom nav on
/// every tab while [nowPlayingMetaProvider] is non-null. Renders nothing
/// (and costs nothing) once playback stops and the owning screen clears it.
class GlobalMiniPlayer extends ConsumerStatefulWidget {
  const GlobalMiniPlayer({super.key});

  @override
  ConsumerState<GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends ConsumerState<GlobalMiniPlayer> {
  bool _playing = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  AyahPlayback? _subscribedTo;

  void _subscribe(AyahPlayback playback) {
    if (identical(_subscribedTo, playback)) return;
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _subscribedTo = playback;
    _stateSub = playback.playerStateStream.listen((s) {
      final playing = s.playing && s.processingState != ProcessingState.completed;
      if (mounted && playing != _playing) setState(() => _playing = playing);
    });
    _posSub = playback.positionStream.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _durSub = playback.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _dur = d);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = ref.watch(nowPlayingMetaProvider);
    if (meta == null) return const SizedBox.shrink();

    final playback = ref.watch(sessionAudioServiceProvider);
    _subscribe(playback);

    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final gold = glass.chromeForeground;
    final totalMs = _dur.inMilliseconds;
    final progress = totalMs == 0 ? 0.0 : (_pos.inMilliseconds / totalMs).clamp(0.0, 1.0);

    return Material(
      color: glass.chromeColor,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (meta.onPrev != null)
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: gold,
                      onPressed: meta.onPrev,
                    ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        meta.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: gold, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton.filled(
                    icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    style: IconButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                    onPressed: () => _playing ? playback.pause() : playback.resume(),
                  ),
                  if (meta.onNext != null)
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      color: gold,
                      onPressed: meta.onNext,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  color: gold,
                  backgroundColor: gold.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
