import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';

import 'ayah_audio_urls.dart';

/// Three-tier source selection for one ayah's audio, cheapest/most-offline
/// first: a locally downloaded file (native only — M4.3), a streamed URL
/// cached to disk as it plays (native only — `LockCachingAudioSource` is
/// `dart:io`-based, unavailable on web), or a plain streaming URI (works
/// everywhere, including web).
/// Formats an audio playback error so network disconnection is clearly
/// distinguished from audio source, reciter CDN, or decoder errors (Item 5.3).
String formatAudioError(Object error) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('socketexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('network is unreachable') ||
      msg.contains('no address associated with hostname')) {
    return 'No internet connection available for audio.';
  }
  return 'Unable to play audio. Please check your connection or try another reciter.';
}

AudioSource _sourceFor({
  required String reciter,
  required int surah,
  required int ayah,
  String? localFilePath,
  bool useCache = true,
}) {
  if (!kIsWeb && localFilePath != null) {
    return AudioSource.file(localFilePath);
  }
  final url = ayahAudioUrl(reciter: reciter, surah: surah, ayah: ayah);
  if (kIsWeb || !useCache) {
    return AudioSource.uri(Uri.parse(url));
  }
  // ignore: experimental_member_use
  return LockCachingAudioSource(Uri.parse(url));
}

/// The playback operations the session/browser UI needs. Exists so widget
/// tests can supply a fake instead of a real [AyahAudioService] — this
/// container has no device/browser to exercise actual just_audio playback
/// against, so UI wiring is verified against a fake per CLAUDE.md's
/// device-only-plugin testing guidance.
abstract class AyahPlayback {
  String reciter;
  LoopScope loopScope;
  RepeatCount repeatCount;
  double speed;

  AyahPlayback({
    this.reciter = defaultReciter,
    this.loopScope = LoopScope.single,
    this.repeatCount = RepeatCount.five,
    this.speed = 1.0,
  });

  Future<void> init();
  Future<void> playAyah({
    required int surah,
    required int ayah,
    String? localFilePath,
  });
  Future<void> playGroup({
    required int surah,
    required List<int> ayahs,
    Map<int, String>? localFilePaths,
    int initialIndex = 0,
  });
  Future<bool> onPlaythroughCompleted();
  Stream<PlayerState> get playerStateStream;
  Future<void> stop();
  Future<void> dispose();

  // Reader-player additions (M22.3). Concrete no-op/empty defaults so
  // existing test fakes need no changes; the real service overrides them.

  /// Current position within the playing ayah.
  Stream<Duration> get positionStream => const Stream.empty();

  /// Duration of the playing ayah (null until known).
  Stream<Duration?> get durationStream => const Stream.empty();

  /// Index into the current playlist (the ayah being played), advancing as
  /// the surah plays through — drives the reader's page-follow.
  Stream<int?> get currentIndexStream => const Stream.empty();

  Future<void> pause() async {}
  Future<void> resume() async {}

  /// Switch reciter. The default just updates [reciter] for the next load;
  /// the real service also rebuilds the currently-loaded playlist so a
  /// mid-playback switch takes effect immediately (Item 1.14).
  Future<void> changeReciter(String newReciter) async {
    reciter = newReciter;
  }

  /// Jump to a specific ayah in the current playlist (prev/next/scrub).
  Future<void> seekToIndex(int index) async {}
}

/// Thin just_audio wrapper for verse-by-verse playback: single-ayah or
/// whole-group playlists, configurable loop scope/repeat count, and
/// playback speed. Pure URL/reciter/repeat logic lives in
/// `ayah_audio_urls.dart` so it stays unit-testable without a real player.
class AyahAudioService extends AyahPlayback {
  AyahAudioService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  int _completedPlays = 0;

  // What's currently loaded, so a reciter switch can rebuild the same
  // ayahs from the new reciter's URLs at the current position (Item 1.14).
  int? _loadedSurah;
  List<int>? _loadedAyahs;

  /// Configures the platform audio session for spoken-word playback.
  /// No-op on web, where `audio_session` has nothing to configure.
  @override
  Future<void> init() async {
    if (kIsWeb) return;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Plays a single ayah, looping it up to [repeatCount] times.
  @override
  Future<void> playAyah({
    required int surah,
    required int ayah,
    String? localFilePath,
  }) async {
    _completedPlays = 0;
    _loadedSurah = surah;
    _loadedAyahs = [ayah];
    try {
      await _player.setAudioSource(_sourceFor(
        reciter: reciter,
        surah: surah,
        ayah: ayah,
        localFilePath: localFilePath,
        useCache: true,
      ));
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      if (!kIsWeb && localFilePath == null) {
        await _player.setAudioSource(_sourceFor(
          reciter: reciter,
          surah: surah,
          ayah: ayah,
          localFilePath: localFilePath,
          useCache: false,
        ));
        await _player.setSpeed(speed);
        await _player.play();
      } else {
        rethrow;
      }
    }
  }

  /// Plays a contiguous group of ayahs (an SRS item's ayah-group) as one
  /// playlist. [localFilePaths] maps ayah number to a downloaded file path,
  /// for whichever ayahs in the group have already been downloaded.
  @override
  Future<void> playGroup({
    required int surah,
    required List<int> ayahs,
    Map<int, String>? localFilePaths,
    int initialIndex = 0,
  }) async {
    _completedPlays = 0;
    _loadedSurah = surah;
    _loadedAyahs = List.of(ayahs);
    // Start the playlist directly at [initialIndex] so the player only
    // prepares/buffers the ayah the user actually wants first, instead of
    // loading ayah 1 and then seeking (which doubled the initial latency
    // when opening a surah partway through) — Item 1.16. The remaining
    // ayahs load lazily as playback advances.
    final start = initialIndex.clamp(0, ayahs.isEmpty ? 0 : ayahs.length - 1);
    try {
      await _player.setAudioSources(
        [
          for (final ayah in ayahs)
            _sourceFor(
              reciter: reciter,
              surah: surah,
              ayah: ayah,
              localFilePath: localFilePaths?[ayah],
              useCache: true,
            ),
        ],
        initialIndex: start,
      );
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      if (!kIsWeb && localFilePaths == null) {
        await _player.setAudioSources(
          [
            for (final ayah in ayahs)
              _sourceFor(
                reciter: reciter,
                surah: surah,
                ayah: ayah,
                localFilePath: null,
                useCache: false,
              ),
          ],
          initialIndex: start,
        );
        await _player.setSpeed(speed);
        await _player.play();
      } else {
        rethrow;
      }
    }
  }

  /// Called by the UI when a play-through completes (e.g. on
  /// `ProcessingState.completed`); replays from the start if
  /// [shouldRepeatAgain] says the repeat target hasn't been reached yet,
  /// otherwise leaves playback stopped. Returns whether it replayed.
  @override
  Future<bool> onPlaythroughCompleted() async {
    _completedPlays++;
    if (!shouldRepeatAgain(_completedPlays, repeatCount)) return false;
    await _player.seek(Duration.zero);
    await _player.play();
    return true;
  }

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  /// Switch reciter and, if a playlist is loaded, rebuild it from the new
  /// reciter's URLs at the current ayah/position — resuming playback only
  /// if it was already playing (Item 1.14). Downloaded files are reciter-
  /// specific, so the rebuild streams the new reciter (localFilePaths null).
  @override
  Future<void> changeReciter(String newReciter) async {
    if (newReciter == reciter) return;
    reciter = newReciter;
    final surah = _loadedSurah;
    final ayahs = _loadedAyahs;
    if (surah == null || ayahs == null || ayahs.isEmpty) return;
    final wasPlaying = _player.playing;
    final index = _player.currentIndex ?? 0;
    final position = _player.position;
    await playGroup(surah: surah, ayahs: ayahs, initialIndex: index);
    await _player.seek(position, index: index);
    if (!wasPlaying) await _player.pause();
  }

  /// Seek to the start of playlist item [index] (a specific ayah). The
  /// player keeps playing/paused as it was.
  @override
  Future<void> seekToIndex(int index) => _player.seek(Duration.zero, index: index);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
