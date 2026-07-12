import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Describes what the [GlobalMiniPlayer] should show while the shared
/// [sessionAudioServiceProvider] instance is playing. Whichever screen
/// starts a sustained playthrough (currently the Quran reader) sets this;
/// clearing it (setting the provider back to null) hides the mini-player
/// even if the underlying player hasn't fully torn down yet.
class NowPlayingMeta {
  const NowPlayingMeta({required this.title, this.onNext, this.onPrev});

  final String title;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;
}

/// Riverpod 3's `Notifier` replaces the legacy `StateProvider` this codebase
/// otherwise doesn't use (see `ThemeModeNotifier` for the same pattern).
class NowPlayingNotifier extends Notifier<NowPlayingMeta?> {
  @override
  NowPlayingMeta? build() => null;

  void show(NowPlayingMeta meta) => state = meta;
  void clear() => state = null;
}

final nowPlayingMetaProvider =
    NotifierProvider<NowPlayingNotifier, NowPlayingMeta?>(NowPlayingNotifier.new);
