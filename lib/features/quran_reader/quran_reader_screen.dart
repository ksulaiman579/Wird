import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/audio/ayah_audio_service.dart' show AyahPlayback, formatAudioError;
import '../../core/audio/ayah_audio_urls.dart' show reciters;
import '../../core/content/bookmark_service.dart';
import '../../core/content/models/quran_models.dart';
import '../../core/content/translation_pack_service.dart';
import '../../core/l10n/reading_locale.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import '../quran_browser/quran_providers.dart';
import '../session/now_playing_provider.dart';
import '../session/session_audio_providers.dart';
import '../settings/plan_prefs.dart';
import 'ayah_player_bar.dart';
import 'reader_prefs.dart';
import 'tajweed_formatter.dart';

/// Ayah-level extra-translation lookup — a small family provider so each
/// ayah card can independently await its own row without the whole
/// screen re-fetching on scroll.
final _extraTranslationProvider =
    FutureProvider.family<String?, (String editionId, int surah, int ayah)>((
      ref,
      key,
    ) {
      final (editionId, surah, ayah) = key;
      return ref
          .watch(translationPackServiceProvider)
          .extraTranslationFor(editionId: editionId, surah: surah, ayah: ayah);
    });

/// Paged Quran reader (M20.2) — one ayah per page with an `n/total`
/// indicator and round back/next arrows, per the reference design. Crossing
/// the last ayah flows straight into the next surah (and swiping back from
/// ayah 1 lands on the previous surah's last ayah) so a finished surah
/// never bounces the user back to the list. Remembers the exact ayah via
/// `readerPrefsProvider` and keeps M12.5's bookmarking + options sheet.
class QuranReaderScreen extends ConsumerStatefulWidget {
  const QuranReaderScreen({super.key, this.initialSurah, this.initialAyah});

  final int? initialSurah;
  final int? initialAyah;

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  int? _surah;
  int _ayah = 1;
  PageController? _pageController;

  // M22.3 bottom-player state.
  bool _playing = false;
  bool _loaded = false; // playlist for the current surah has been set
  int _audioIndex =
      0; // index the audio last reported, to break page↔audio echo
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  // Captured in initState — reading a provider in dispose() is unsafe in
  // Riverpod (the BuildContext is already deactivated).
  late final AyahPlayback _playback;
  late final NowPlayingNotifier _nowPlaying;

  @override
  void initState() {
    super.initState();
    _playback = ref.read(sessionAudioServiceProvider);
    _nowPlaying = ref.read(nowPlayingMetaProvider.notifier);
  }

  @override
  void dispose() {
    _indexSub?.cancel();
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _playback.stop();
    _nowPlaying.clear();
    _pageController?.dispose();
    super.dispose();
  }

  void _ensureAudioSubscriptions() {
    if (_indexSub != null) return;
    final playback = _playback;
    _indexSub = playback.currentIndexStream.listen((i) {
      if (i == null || !mounted) return;
      _audioIndex = i;
      // Follow the playing verse: drives the n/total counter and, in
      // Mushaf mode (no PageView), the highlighted verse (Item 1.11).
      setState(() => _ayah = i + 1);
      if (_pageController?.hasClients ?? false) {
        _pageController!.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      _publishNowPlaying(ayah: i + 1);
    });
    _stateSub = playback.playerStateStream.listen((s) {
      if (!mounted) return;
      final playing =
          s.playing && s.processingState != ProcessingState.completed;
      if (playing != _playing) setState(() => _playing = playing);
    });
    _posSub = playback.positionStream.listen((p) {
      if (mounted) setState(() => _pos = p);
    });
    _durSub = playback.durationStream.listen((d) {
      if (mounted && d != null) setState(() => _dur = d);
    });
  }

  Future<void> _togglePlay(int total) async {
    final playback = _playback;
    _ensureAudioSubscriptions();
    if (_playing) {
      await playback.pause();
      return;
    }
    if (_loaded) {
      await playback.resume();
      return;
    }
    try {
      await playback.playGroup(
        surah: _surah!,
        ayahs: [for (var a = 1; a <= total; a++) a],
        initialIndex: _ayah - 1,
      );
      _loaded = true;
      _audioIndex = _ayah - 1;
      _publishNowPlaying();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(formatAudioError(e))),
        );
      }
    }
  }

  /// Auto-play-on-navigate (M23 feedback): loads the surah's playlist if
  /// it isn't already, then seeks to and plays [index] — called whenever
  /// the user pages to another ayah (swipe or nav arrows) with the
  /// preference enabled, in either direction.
  Future<void> _autoPlayAyah(int index, int total) async {
    _ensureAudioSubscriptions();
    if (!_loaded) {
      try {
        await _playback.playGroup(
          surah: _surah!,
          ayahs: [for (var a = 1; a <= total; a++) a],
          initialIndex: index,
        );
        _loaded = true;
        _audioIndex = index;
        _publishNowPlaying(ayah: index + 1);
        return;
      } catch (_) {
        return; // offline/no network — silently skip autoplay
      }
    }
    _audioIndex = index;
    await _playback.seekToIndex(index);
    await _playback.resume();
    _publishNowPlaying(ayah: index + 1);
  }

  void _stopAudio() {
    _playback.stop();
    _loaded = false;
    if (_playing && mounted) setState(() => _playing = false);
    _nowPlaying.clear();
  }

  /// Publishes the current track to the app-wide [GlobalMiniPlayer] (M23.2)
  /// so playback stays visible while the user browses other tabs.
  /// [ayah] defaults to the reader's own `_ayah` field; the audio-index
  /// listener passes the freshly-reported index so the title tracks
  /// playback rather than the page the user may have scrolled to.
  void _publishNowPlaying({int? ayah}) {
    final surah = _surah;
    if (surah == null) return;
    _nowPlaying.show(
      NowPlayingMeta(
        title: 'Surah $surah · Ayah ${ayah ?? _ayah}',
        onPrev: (ayah ?? _ayah) > 1
            ? () => _pageController?.previousPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              )
            : null,
        onNext: () => _pageController?.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void _recordLastRead() {
    ref
        .read(readerPrefsProvider.notifier)
        .setLastRead(surah: _surah!, ayah: _ayah);
  }

  /// Jump to another surah, rebuilding the controller so the PageView
  /// starts at [ayah] (1-based; -1 means "last ayah", resolved after the
  /// surah loads via the itemCount clamp below).
  void _goToSurah(int surah, {int ayah = 1}) {
    _stopAudio(); // playlist is per-surah; don't carry it across boundaries
    setState(() {
      _surah = surah.clamp(1, 114);
      _ayah = ayah;
      _pageController?.dispose();
      _pageController = null;
    });
    if (ayah >= 1) _recordLastRead();
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(readerPrefsProvider);

    return prefsAsync.when(
      loading: () =>
          const GlassScaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => GlassScaffold(body: Center(child: Text('$e'))),
      data: (prefs) {
        final surahNumber = _surah ?? widget.initialSurah ?? prefs.lastSurah;
        if (_surah == null) {
          _surah = surahNumber;
          _ayah =
              widget.initialAyah ??
              (widget.initialSurah == null ? prefs.lastAyah : 1);
        }

        final surahAsync = ref.watch(surahProvider(surahNumber));
        final metaAsync = ref.watch(quranMetaProvider);
        final meta = metaAsync.value?.surahs
            .where((s) => s.number == surahNumber)
            .firstOrNull;
        final arabicName = meta?.nameArabic;
        final englishName = meta?.nameTransliterated ?? 'Surah $surahNumber';

        return GlassScaffold(
          appBar: GlassAppBar(
            centerTitle: true,
            title: _ReaderTitle(
              arabicName: arabicName,
              englishName: englishName,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _showOptionsSheet(context, prefs),
              ),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          body: surahAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Failed to load: $e')),
            data: (surah) {
              final total = surah.ayahs.length;
              // -1 sentinel from a back-crossing resolves to the last ayah
              // once we know this surah's length.
              if (_ayah < 1 || _ayah > total) _ayah = total;
              final controller = _pageController ??= PageController(
                initialPage: _ayah - 1,
              );

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '$_ayah / $total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: prefs.mushafMode
                        ? _MushafContinuousPage(
                            surah: surah,
                            prefs: prefs,
                            activeAyah: _ayah,
                            onAyahTap: (ayahNum) {
                              setState(() => _ayah = ayahNum);
                              _recordLastRead();
                            },
                          )
                        : PageView.builder(
                            controller: controller,
                            itemCount: total,
                            onPageChanged: (index) {
                              setState(() => _ayah = index + 1);
                              _recordLastRead();
                              if (index == _audioIndex) return;
                              if (prefs.autoPlayOnNavigate) {
                                _autoPlayAyah(index, total);
                              } else if (_loaded) {
                                _audioIndex = index;
                                _playback.seekToIndex(index);
                              }
                            },
                            itemBuilder: (context, index) {
                              final ayah = surah.ayahs[index];
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight - 32,
                                      ),
                                      child: Center(
                                        child: _AyahCard(
                                          surah: surahNumber,
                                          ayah: ayah.ayah,
                                          arabic: ayah.arabic,
                                          translation: ayah.translation,
                                          transliteration: ayah.transliteration,
                                          prefs: prefs,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  AyahPlayerBar(
                    playing: _playing,
                    position: _pos,
                    duration: _dur,
                    onPlayPause: () => _togglePlay(total),
                    onPrev: _ayah > 1
                        ? () {
                            if (prefs.mushafMode) {
                              setState(() => _ayah = _ayah - 1);
                              _recordLastRead();
                            } else {
                              controller.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          }
                        : null,
                    onNext: _ayah < total
                        ? () {
                            if (prefs.mushafMode) {
                              setState(() => _ayah = _ayah + 1);
                              _recordLastRead();
                            } else {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          }
                        : null,
                  ),
                  // Classic Mushaf keeps only the page + audio player; the
                  // round nav arrows are dropped there (Item 1.11).
                  if (!prefs.mushafMode)
                    _ReaderNavBar(
                    onPrev: () {
                      if (_ayah > 1) {
                        if (prefs.mushafMode) {
                          setState(() => _ayah = _ayah - 1);
                          _recordLastRead();
                        } else {
                          controller.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      } else if (surahNumber > 1) {
                        _goToSurah(surahNumber - 1, ayah: -1);
                      }
                    },
                    onNext: () {
                      if (_ayah < total) {
                        if (prefs.mushafMode) {
                          setState(() => _ayah = _ayah + 1);
                          _recordLastRead();
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        }
                      } else if (surahNumber < 114) {
                        _goToSurah(surahNumber + 1);
                      }
                    },
                    canGoPrev: _ayah > 1 || surahNumber > 1,
                    canGoNext: _ayah < total || surahNumber < 114,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Item A2: switching translation language used to set the edition even
  /// when its pack wasn't downloaded — the reader silently kept showing
  /// English. Now the selection only sticks if the pack is installed;
  /// otherwise the user gets a SnackBar with a jump to the Library.
  Future<void> _selectExtraEdition(
    BuildContext context,
    String editionId,
    String languageName,
  ) async {
    final installed =
        await ref.read(translationPackServiceProvider).isInstalled(editionId);
    if (!context.mounted) return;
    if (installed) {
      ref.read(readerPrefsProvider.notifier).updatePrefs(
            (p) => p.copyWith(
              showExtraTranslation: true,
              extraEditionId: editionId,
            ),
          );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).readerLangNotDownloaded(languageName),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context).libraryTitle,
          onPressed: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            this.context.push('/library');
          },
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, ReaderPrefs prefs) {
    final notifier = ref.read(readerPrefsProvider.notifier);
    showGlassSheet<void>(
      context: context,
      // The reciter picker + auto-play toggle (M23 feedback) pushed this
      // sheet past the default (unscrolled, height-capped) bottom-sheet
      // size — scroll-controlled + wrapped in a SingleChildScrollView so
      // it grows with content instead of overflowing.
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final currentPrefs = ref.watch(readerPrefsProvider).value ?? prefs;
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).readerOptions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context).readerMushafMode),
                      subtitle:
                          Text(AppLocalizations.of(context).readerMushafModeDesc),
                      value: currentPrefs.mushafMode,
                      onChanged: (v) {
                        notifier.updatePrefs((p) => p.copyWith(mushafMode: v));
                      },
                    ),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context).readerTajweed),
                      subtitle:
                          Text(AppLocalizations.of(context).readerTajweedDesc),
                      value: currentPrefs.showTajweed,
                      onChanged: (v) {
                        notifier.updatePrefs((p) => p.copyWith(showTajweed: v));
                      },
                    ),
                    SwitchListTile(
                      title: Text(AppLocalizations.of(context).readerTranslation),
                      value: currentPrefs.showTranslation,
                      onChanged: (v) {
                        notifier.updatePrefs((p) => p.copyWith(showTranslation: v));
                      },
                    ),
                    SwitchListTile(
                      title:
                          Text(AppLocalizations.of(context).readerTransliteration),
                      value: currentPrefs.showTransliteration,
                      onChanged: (v) {
                        notifier.updatePrefs(
                          (p) => p.copyWith(showTransliteration: v),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).readerTranslationLanguage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('English'),
                          selected: !currentPrefs.showExtraTranslation ||
                              currentPrefs.extraEditionId == null,
                          onSelected: (_) => notifier.updatePrefs(
                            (p) => p.copyWith(
                              showTranslation: true,
                              showExtraTranslation: false,
                              clearExtraEdition: true,
                            ),
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('French'),
                          selected: currentPrefs.showExtraTranslation &&
                              currentPrefs.extraEditionId ==
                                  'fra_muhammadhamidul',
                          onSelected: (_) => _selectExtraEdition(
                            context,
                            'fra_muhammadhamidul',
                            'French',
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Urdu'),
                          selected: currentPrefs.showExtraTranslation &&
                              currentPrefs.extraEditionId ==
                                  'urd_abulaalamaududi',
                          onSelected: (_) => _selectExtraEdition(
                            context,
                            'urd_abulaalamaududi',
                            'Urdu',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label:
                            Text(AppLocalizations.of(context).readerMoreTranslations),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/library');
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).readerFontSize,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Slider(
                      value: currentPrefs.fontSize,
                      min: 18,
                      max: 40,
                      divisions: 11,
                      label: currentPrefs.fontSize.round().toString(),
                      onChanged: (v) {
                        notifier.updatePrefs((p) => p.copyWith(fontSize: v));
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).readerReciter,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _playback.reciter,
                            items: [
                              for (final entry in reciters.entries)
                                DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              // changeReciter sets `reciter` synchronously,
                              // then rebuilds any active playlist so the
                              // switch is heard immediately (Item 1.14).
                              _playback.changeReciter(v);
                              setSheetState(() {});
                              setReciter(ref, v);
                            },
                          ),
                        ),
                        // Sample-play the current reciter (Al-Fatiha 1) so the
                        // choice can be heard before committing to a download.
                        IconButton(
                          tooltip: AppLocalizations.of(context).readerPlaySample,
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          onPressed: () {
                            _ensureAudioSubscriptions();
                            _loaded = false; // sample isn't the surah playlist
                            _playback.playAyah(surah: 1, ayah: 1);
                          },
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title:
                          Text(AppLocalizations.of(context).readerAutoPlaySwipe),
                      subtitle: Text(
                        AppLocalizations.of(context).readerAutoPlaySwipeDesc,
                      ),
                      value: currentPrefs.autoPlayOnNavigate,
                      onChanged: (v) {
                        notifier.updatePrefs(
                          (p) => p.copyWith(autoPlayOnNavigate: v),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AyahCard extends ConsumerWidget {
  const _AyahCard({
    required this.surah,
    required this.ayah,
    required this.arabic,
    required this.translation,
    required this.transliteration,
    required this.prefs,
  });

  final int surah;
  final int ayah;
  final String arabic;
  final String translation;
  final String transliteration;
  final ReaderPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentKey = 'q:$surah:$ayah';
    final isBookmarkedAsync = ref.watch(_isBookmarkedProvider(contentKey));
    // Hide the Latin transliteration + English translation when the UI is
    // Arabic (user request) — on top of the user's own show/hide toggles.
    final showAids = showLatinReadingAids(Localizations.localeOf(context));

    return GlassCard(
      enableBlur: false,
      // Cream "mushaf page" card in light mode (M21.5 renders); the
      // theme's default fill in dark mode.
      fillColor: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFF8F0D8)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VerseRoundel(number: ayah),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isBookmarkedAsync.value == true
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                ),
                onPressed: () => ref
                    .read(bookmarkServiceProvider)
                    .toggle(contentType: 'quran', contentKey: contentKey),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TajweedTextFormatter.format(
                arabic,
                fontSize: prefs.fontSize,
                enabled: prefs.showTajweed,
                height: 2.0,
              ),
            ),
          ),
          if (prefs.showTransliteration && showAids) ...[
            const SizedBox(height: 12),
            Text(
              transliteration,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (prefs.showTranslation && showAids) ...[
            const SizedBox(height: 12),
            // Bold "Translation:" lead-in, per the render's labelled block.
            // When a non-default edition is selected, switch the primary
            // translation to that edition's text (falling back to the
            // bundled English until the pack loads) rather than merely
            // appending it below — Item 1.12.
            Builder(
              builder: (context) {
                final editionId = prefs.showExtraTranslation
                    ? prefs.extraEditionId
                    : null;
                if (editionId == null) {
                  return _translationLine(context, translation);
                }
                final extraAsync = ref.watch(
                  _extraTranslationProvider((editionId, surah, ayah)),
                );
                return _translationLine(
                  context,
                  extraAsync.maybeWhen(
                    data: (text) => (text == null || text.isEmpty)
                        ? translation
                        : text,
                    orElse: () => translation,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// The labelled "Translation: …" line shared by the default and
/// selected-edition translation display (Item 1.12).
Widget _translationLine(BuildContext context, String text) {
  return RichText(
    text: TextSpan(
      style: Theme.of(context).textTheme.bodyLarge,
      children: [
        TextSpan(
          text: '${AppLocalizations.of(context).readerTranslationLabel} ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        TextSpan(text: text),
      ],
    ),
  );
}

final _isBookmarkedProvider = StreamProvider.family<bool, String>((
  ref,
  contentKey,
) {
  return ref.watch(bookmarkServiceProvider).watchIsBookmarked(contentKey);
});

/// The reader's centered chrome title (M23.5, render k67eji): the surah's
/// Arabic calligraphic name over its English transliteration, joined by a
/// short gold underline accent.
class _ReaderTitle extends StatelessWidget {
  const _ReaderTitle({required this.arabicName, required this.englishName});

  final String? arabicName;
  final String englishName;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final gold = glass.chromeForeground;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          arabicName ?? englishName,
          style: TextStyle(
            fontFamily: arabicName != null ? 'UthmanicHafs' : null,
            fontSize: 20,
            color: gold,
          ),
        ),
        const SizedBox(height: 2),
        Container(width: 28, height: 2, color: gold.withValues(alpha: 0.7)),
        const SizedBox(height: 2),
        Text(
          englishName,
          style: TextStyle(fontSize: 11, color: gold.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}

/// Round back/next arrow buttons per the reference design.
class _ReaderNavBar extends StatelessWidget {
  const _ReaderNavBar({
    required this.onPrev,
    required this.onNext,
    required this.canGoPrev,
    required this.canGoNext,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool canGoPrev;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundArrowButton(
            icon: Icons.arrow_back_rounded,
            onTap: canGoPrev ? onPrev : null,
            background: scheme.surfaceContainerHighest,
            foreground: scheme.onSurface,
          ),
          _RoundArrowButton(
            icon: Icons.arrow_forward_rounded,
            onTap: canGoNext ? onNext : null,
            background: scheme.primary,
            foreground: scheme.onPrimary,
          ),
        ],
      ),
    );
  }
}

class _RoundArrowButton extends StatelessWidget {
  const _RoundArrowButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? background.withValues(alpha: 0.4) : background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: foreground),
        ),
      ),
    );
  }
}

class _MushafContinuousPage extends StatelessWidget {
  const _MushafContinuousPage({
    required this.surah,
    required this.prefs,
    required this.activeAyah,
    required this.onAyahTap,
  });

  final Surah surah;
  final ReaderPrefs prefs;
  final int activeAyah;
  final ValueChanged<int> onAyahTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        enableBlur: false,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF8F0D8)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TextSpan(
                children: [
                  for (final a in surah.ayahs) ...[
                    TajweedTextFormatter.format(
                      '${a.arabic} ',
                      fontSize: prefs.fontSize,
                      baseColor: a.ayah == activeAyah
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      enabled: prefs.showTajweed,
                      height: 2.2,
                    ),
                    TextSpan(
                      text: '﴿${a.ayah}﴾ ',
                      style: TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: prefs.fontSize * 0.8,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    );
  }
}

