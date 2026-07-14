import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/audio/ayah_audio_service.dart' show formatAudioError;
import '../../core/l10n/reading_locale.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/verse_roundel.dart';
import '../session/session_audio_providers.dart';
import 'mark_memorized_controller.dart';
import 'quran_providers.dart';

class SurahScreen extends ConsumerStatefulWidget {
  const SurahScreen({super.key, required this.surahNumber});

  final int surahNumber;

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen> {
  int? _playingAyah;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void dispose() {
    _playerStateSub?.cancel();
    super.dispose();
  }

  Future<void> _togglePlay(int ayah) async {
    final playback = ref.read(sessionAudioServiceProvider);

    if (_playingAyah == ayah) {
      await playback.stop();
      _playerStateSub?.cancel();
      if (mounted) setState(() => _playingAyah = null);
      return;
    }

    setState(() => _playingAyah = ayah);

    _playerStateSub?.cancel();
    _playerStateSub = playback.playerStateStream.listen((state) {
      if (state.processingState != ProcessingState.completed) return;
      if (!mounted) return;
      setState(() => _playingAyah = null);
    });

    try {
      await playback.playAyah(surah: widget.surahNumber, ayah: ayah);
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingAyah = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formatAudioError(e))),
      );
    }
  }

  Future<void> _markMemorized() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.quranMarkMemorized),
        content: Text(l.quranMarkMemorizedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.quranMarkMemorizedConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await markQuranMemorized(
      ref,
      selectionType: 'surahs',
      selectionIds: [widget.surahNumber],
      now: DateTime.now(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.quranMarkedForRevision)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahProvider(widget.surahNumber));
    final metaAsync = ref.watch(quranMetaProvider);

    final title = metaAsync.maybeWhen(
      data: (meta) => meta.surahs
          .firstWhere((s) => s.number == widget.surahNumber)
          .nameTransliterated,
      orElse: () => 'Surah ${widget.surahNumber}',
    );

    return GlassScaffold(
      contentPadding: EdgeInsets.zero,
      appBar: GlassAppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_rounded),
            tooltip: AppLocalizations.of(context).quranMarkMemorized,
            onPressed: _markMemorized,
          ),
          // Surah Index is a browse list + route only (Item 1.15): all
          // layout/display options live in the reader's options sheet, so
          // this view has no per-view toggles — it always shows Arabic,
          // transliteration and translation, and opens the full reader.
          IconButton(
            icon: const Icon(Icons.auto_stories_rounded),
            tooltip: AppLocalizations.of(context).surahOpenInReader,
            onPressed: () =>
                context.push('/read?surah=${widget.surahNumber}&ayah=1'),
          ),
        ],
      ),
      body: surahAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (surah) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surah.ayahs.length,
          itemBuilder: (context, index) {
            final ayah = surah.ayahs[index];
            final showAids =
                showLatinReadingAids(Localizations.localeOf(context));
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                enableBlur: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Verse-roundel star — same ornamental number marker
                        // as the memorization reader and hadith cards.
                        VerseRoundel(number: ayah.ayah, size: 34),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context).commonJuzN(ayah.juz),
                            style: Theme.of(context).textTheme.bodySmall),
                        const Spacer(),
                        IconButton(
                          icon: Icon(_playingAyah == ayah.ayah
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded),
                          onPressed: () => _togglePlay(ayah.ayah),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        ayah.arabic,
                        style: const TextStyle(
                          fontFamily: 'UthmanicHafs',
                          fontSize: 26,
                          height: 2.0,
                        ),
                      ),
                    ),
                    // Latin transliteration + English translation are hidden
                    // when the UI language is Arabic (user request).
                    if (showAids) ...[
                      const SizedBox(height: 8),
                      Text(
                        ayah.transliteration,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Text(ayah.translation),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
