import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' show PlayerState, ProcessingState;

import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/db/database.dart';
import '../../core/l10n/reading_locale.dart';
import '../../core/srs/sm2_scheduler.dart' show Grade;
import '../../core/theme/app_theme.dart';
import '../../shared/glass/glass.dart';
import '../../shared/widgets/word_cloak_text.dart';
import '../../shared/widgets/ayah_numbered_row.dart';
import '../../core/audio/ayah_audio_service.dart' show formatAudioError;
import 'session_audio_providers.dart';
import 'session_content_provider.dart';

enum _Step { listen, meaning, fadeFull, fadeHint, fadeHidden, chainRecall, selfTest }

const int defaultRepeatTarget = 5;

/// The Talqeen/Takrar flow for a Sabaq (new-lesson) item: listen & repeat,
/// read the meaning once, progressively fade the Arabic from full text to
/// fully hidden, a chain-recall pass for multi-ayah groups, then a hidden
/// self-test that grades the item via [onGraded].
class NewMaterialFlow extends ConsumerStatefulWidget {
  const NewMaterialFlow({
    super.key,
    required this.item,
    required this.onGraded,
  });

  final SrsItem item;
  final void Function(Grade grade) onGraded;

  @override
  ConsumerState<NewMaterialFlow> createState() => _NewMaterialFlowState();
}

class _NewMaterialFlowState extends ConsumerState<NewMaterialFlow> {
  int _stepIndex = 0;
  int _repeatCount = 0;
  bool _selfTestRevealed = false;
  List<bool> _chainRevealed = const [];

  bool _isPlayingAudio = false;
  String? _audioError;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void dispose() {
    _playerStateSub?.cancel();
    super.dispose();
  }

  /// Audio only exists for Quran ayah-groups (everyayah.com) — hadith/dua
  /// items keep the manual tap-counter, per M4.1's scope.
  bool get _hasAudio => widget.item.contentType == 'quran';

  Future<void> _toggleListenAudio() async {
    final quranRef = parseQuranContentKey(widget.item.contentKey);
    if (quranRef == null) return;

    final playback = ref.read(sessionAudioServiceProvider);

    if (_isPlayingAudio) {
      await playback.stop();
      _playerStateSub?.cancel();
      if (mounted) setState(() => _isPlayingAudio = false);
      return;
    }

    setState(() {
      _isPlayingAudio = true;
      _audioError = null;
    });

    _playerStateSub?.cancel();
    _playerStateSub = playback.playerStateStream.listen((state) async {
      if (state.processingState != ProcessingState.completed) return;
      final repeated = await playback.onPlaythroughCompleted();
      if (!mounted) return;
      setState(() {
        _repeatCount = (_repeatCount + 1).clamp(0, defaultRepeatTarget);
        if (!repeated) _isPlayingAudio = false;
      });
    });

    try {
      await playback.playGroup(surah: quranRef.surah, ayahs: quranRef.ayahs);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = false;
        _audioError = formatAudioError(e);
      });
    }
  }

  List<_Step> _stepsFor(SessionItemContent content) {
    final steps = [
      _Step.listen,
      _Step.meaning,
      _Step.fadeFull,
      _Step.fadeHint,
      _Step.fadeHidden,
    ];
    if (content.arabicSegments.length > 1) steps.add(_Step.chainRecall);
    steps.add(_Step.selfTest);
    return steps;
  }

  void _next(int stepCount) {
    setState(() {
      if (_stepIndex < stepCount - 1) _stepIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(sessionItemContentProvider(
      (widget.item.contentType, widget.item.contentKey),
    ));

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
          child:
              Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
      data: (content) {
        final steps = _stepsFor(content);
        final step = steps[_stepIndex.clamp(0, steps.length - 1)];
        if (_chainRevealed.length != content.arabicSegments.length - 1) {
          _chainRevealed =
              List.filled(content.arabicSegments.length - 1, false);
        }

        final currentStep = _stepIndex.clamp(0, steps.length - 1) + 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(content.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                      // Where you are in the memorization ladder (Item 1.7).
                      Text(
                          AppLocalizations.of(context)
                              .sessionStepOf(currentStep, steps.length),
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentStep / steps.length,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildStep(context, step, content, steps.length),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(
    BuildContext context,
    _Step step,
    SessionItemContent content,
    int stepCount,
  ) {
    switch (step) {
      case _Step.listen:
        return _ListenStep(
          content: content,
          repeatCount: _repeatCount,
          onRepeat: () => setState(() {
            if (_repeatCount < defaultRepeatTarget) _repeatCount++;
          }),
          // M22.4: Continue is always enabled — someone reciting from
          // memory shouldn't be forced through 5 listens first. The repeat
          // counter is now a guide, not a gate.
          onContinue: () => _next(stepCount),
          hasAudio: _hasAudio,
          isPlayingAudio: _isPlayingAudio,
          audioError: _audioError,
          onToggleAudio: _toggleListenAudio,
        );
      case _Step.meaning:
        return _MeaningStep(
          content: content,
          onContinue: () => _next(stepCount),
        );
      case _Step.fadeFull:
        return _FadeStep(
          content: content,
          stage: FadeStage.full,
          label: AppLocalizations.of(context).flowReadOnceMore,
          onContinue: () => _next(stepCount),
        );
      case _Step.fadeHint:
        return _FadeStep(
          content: content,
          stage: FadeStage.hint,
          label: AppLocalizations.of(context).flowFirstWord,
          onContinue: () => _next(stepCount),
        );
      case _Step.fadeHidden:
        return _FadeStep(
          content: content,
          stage: FadeStage.hidden,
          label: AppLocalizations.of(context).flowFullyHidden,
          onContinue: () => _next(stepCount),
        );
      case _Step.chainRecall:
        return _ChainRecallStep(
          content: content,
          revealed: _chainRevealed,
          onToggle: (i) => setState(() => _chainRevealed[i] = !_chainRevealed[i]),
          onContinue: () => _next(stepCount),
        );
      case _Step.selfTest:
        return _SelfTestStep(
          content: content,
          revealed: _selfTestRevealed,
          onReveal: () => setState(() => _selfTestRevealed = true),
          onGraded: widget.onGraded,
        );
    }
  }
}

class _ListenStep extends StatefulWidget {
  const _ListenStep({
    required this.content,
    required this.repeatCount,
    required this.onRepeat,
    required this.onContinue,
    required this.hasAudio,
    required this.isPlayingAudio,
    required this.audioError,
    required this.onToggleAudio,
  });

  final SessionItemContent content;
  final int repeatCount;
  final VoidCallback onRepeat;
  final VoidCallback? onContinue;
  final bool hasAudio;
  final bool isPlayingAudio;
  final String? audioError;
  final VoidCallback onToggleAudio;

  @override
  State<_ListenStep> createState() => _ListenStepState();
}

class _ListenStepState extends State<_ListenStep> {
  bool _showTranslation = false;
  bool _showTransliteration = false;

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final hasTranslit = content.transliterationSegments
        .any((t) => t.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.hasAudio
              ? AppLocalizations.of(context).flowListenRepeatAudio
              : AppLocalizations.of(context).flowListenRepeatText,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        // Translation / transliteration toggles (M22.4) — same options the
        // reader offers, so memorizing looks and reads like reading.
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: Text(AppLocalizations.of(context).readerTranslation),
              selected: _showTranslation,
              onSelected: (v) => setState(() => _showTranslation = v),
            ),
            if (hasTranslit)
              FilterChip(
                label: Text(AppLocalizations.of(context).readerTransliteration),
                selected: _showTransliteration,
                onSelected: (v) => setState(() => _showTransliteration = v),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < content.arabicSegments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(content.arabicSegments[i], style: quranTextStyle),
                ),
                if (_showTransliteration &&
                    showLatinReadingAids(Localizations.localeOf(context)) &&
                    i < content.transliterationSegments.length &&
                    content.transliterationSegments[i].trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(content.transliterationSegments[i],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic)),
                ],
                if (_showTranslation &&
                    showLatinReadingAids(Localizations.localeOf(context)) &&
                    i < content.translationSegments.length) ...[
                  const SizedBox(height: 4),
                  Text(content.translationSegments[i]),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
            AppLocalizations.of(context)
                .flowRepeatedCount(widget.repeatCount, defaultRepeatTarget),
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        if (widget.hasAudio)
          OutlinedButton.icon(
            onPressed: widget.onToggleAudio,
            icon: Icon(widget.isPlayingAudio
                ? Icons.stop_rounded
                : Icons.play_arrow_rounded),
            label: Text(widget.isPlayingAudio
                ? AppLocalizations.of(context).commonStop
                : AppLocalizations.of(context).flowPlayRecitation),
          )
        else
          OutlinedButton.icon(
            onPressed: widget.onRepeat,
            icon: const Icon(Icons.replay_rounded),
            label: Text(AppLocalizations.of(context).flowTapAfterRepeat),
          ),
        if (widget.audioError != null) ...[
          const SizedBox(height: 8),
          Text(widget.audioError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(onPressed: widget.onContinue, child: Text(AppLocalizations.of(context).commonContinue)),
      ],
    );
  }
}

class _MeaningStep extends StatelessWidget {
  const _MeaningStep({required this.content, required this.onContinue});

  final SessionItemContent content;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context).flowMeaning,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final translation in content.translationSegments)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(translation),
          ),
        if (content.meaningNote != null) ...[
          const SizedBox(height: 8),
          Text(content.meaningNote!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 16),
        FilledButton(onPressed: onContinue, child: Text(AppLocalizations.of(context).commonContinue)),
      ],
    );
  }
}

class _FadeStep extends StatelessWidget {
  const _FadeStep({
    required this.content,
    required this.stage,
    required this.label,
    required this.onContinue,
  });

  final SessionItemContent content;
  final FadeStage stage;
  final String label;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        for (var i = 0; i < content.arabicSegments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AyahNumberedRow(
              ayahNumber: i < content.ayahNumbers.length
                  ? content.ayahNumbers[i]
                  : null,
              child: WordCloakText(
                text: content.arabicSegments[i],
                revealedIndices: revealedIndicesFor(
                    stage, wordCountOf(content.arabicSegments[i])),
                style: quranTextStyle,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(onPressed: onContinue, child: Text(AppLocalizations.of(context).commonContinue)),
      ],
    );
  }
}

class _ChainRecallStep extends StatelessWidget {
  const _ChainRecallStep({
    required this.content,
    required this.revealed,
    required this.onToggle,
    required this.onContinue,
  });

  final SessionItemContent content;
  final List<bool> revealed;
  final void Function(int index) onToggle;
  final VoidCallback onContinue;

  String _lastWords(String text, int count) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    return words.length <= count ? text : words.sublist(words.length - count).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final segments = content.arabicSegments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).flowChainRecall,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        for (var i = 1; i < segments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              enableBlur: false,
              onTap: () => onToggle(i - 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      '… ${_lastWords(segments[i - 1], 3)}',
                      style: quranTextStyle.copyWith(
                          fontSize: 20, color: Theme.of(context).hintColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: AyahNumberedRow(
                      ayahNumber: i < content.ayahNumbers.length
                          ? content.ayahNumbers[i]
                          : null,
                      child: revealed[i - 1]
                          ? Text(segments[i], style: quranTextStyle)
                          : WordCloakText(
                              text: segments[i],
                              revealedIndices: const {},
                              style: quranTextStyle,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(onPressed: onContinue, child: Text(AppLocalizations.of(context).commonContinue)),
      ],
    );
  }
}

class _SelfTestStep extends StatelessWidget {
  const _SelfTestStep({
    required this.content,
    required this.revealed,
    required this.onReveal,
    required this.onGraded,
  });

  final SessionItemContent content;
  final bool revealed;
  final VoidCallback onReveal;
  final void Function(Grade grade) onGraded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context).flowSelfTest,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        for (var i = 0; i < content.arabicSegments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AyahNumberedRow(
              ayahNumber: i < content.ayahNumbers.length
                  ? content.ayahNumbers[i]
                  : null,
              child: revealed
                  ? Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(content.arabicSegments[i], style: quranTextStyle),
                    )
                  : WordCloakText(
                      text: content.arabicSegments[i],
                      revealedIndices: const {},
                      style: quranTextStyle,
                    ),
            ),
          ),
        const SizedBox(height: 8),
        if (!revealed)
          FilledButton(
              onPressed: onReveal,
              child: Text(AppLocalizations.of(context).flowReveal))
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onGraded(Grade.again),
                  child: Text(AppLocalizations.of(context).flowNeedsWork),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => onGraded(Grade.good),
                  child: Text(AppLocalizations.of(context).flowGotIt),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
