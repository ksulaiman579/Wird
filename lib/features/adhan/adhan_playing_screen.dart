import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../shared/glass/glass.dart';

/// Full-screen adhan player opened when an adhan notification fires (U9).
/// The adhan plays through an in-app [AudioPlayer] — rather than as the
/// notification's channel sound — so the user can silence it with a single
/// tap (the whole screen, or the Stop button). Auto-stops and pops when the
/// recording finishes.
class AdhanPlayingScreen extends StatefulWidget {
  const AdhanPlayingScreen({super.key, this.salahLabel});

  /// Optional prayer name to show (e.g. "Fajr"); the notification payload
  /// carries it so the screen can name the prayer being called.
  final String? salahLabel;

  @override
  State<AdhanPlayingScreen> createState() => _AdhanPlayingScreenState();
}

class _AdhanPlayingScreenState extends State<AdhanPlayingScreen> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _sub = _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) _stopAndClose();
    });
    try {
      await _player.setAsset('assets/audio/adhan.ogg');
      await _player.play();
    } catch (_) {
      // If audio can't load, don't strand the user on a silent screen.
      if (mounted) _stopAndClose();
    }
  }

  Future<void> _stopAndClose() async {
    await _sub?.cancel();
    _sub = null;
    await _player.stop();
    if (!mounted) return;
    // Opened via router.go from a notification (stack replaced), so there is
    // usually nothing to pop — fall back to Home in that case.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Tapping anywhere silences — the primary "tap to silence" gesture.
    return GlassScaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _stopAndClose,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mosque_rounded, size: 96, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                widget.salahLabel == null
                    ? l.adhanCallTitle
                    : l.adhanCallFor(widget.salahLabel!),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.adhanTapToSilence,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GlassPill(
                enableBlur: false,
                onTap: _stopAndClose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stop_rounded),
                      const SizedBox(width: 8),
                      Text(l.commonStop),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
