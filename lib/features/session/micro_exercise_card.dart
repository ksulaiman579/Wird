import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';


import '../../core/exercises/micro_exercises.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/glass/glass.dart';
import 'session_content_provider.dart';

/// Renders one of the four M6.4 micro-exercises for [kind], falling back to
/// calling [onDone] immediately if the underlying exercise can't be built
/// (e.g. too few words) — the caller should never block a review on this.
class MicroExerciseCard extends StatelessWidget {
  const MicroExerciseCard({
    super.key,
    required this.kind,
    required this.content,
    required this.seed,
    required this.onDone,
  });

  final MicroExerciseKind kind;
  final SessionItemContent content;
  final int seed;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case MicroExerciseKind.nextWordTap:
        final exercise = buildNextWordTapExercise(
          arabicText: content.arabicSegments.first,
          distractorPool: content.distractorWordPool,
          seed: seed,
        );
        return exercise == null
            ? _ImmediateDone(onDone: onDone)
            : _NextWordTapView(exercise: exercise, onDone: onDone);
      case MicroExerciseKind.fillBlank:
        final exercise = buildFillBlankExercise(
          arabicText: content.arabicSegments.first,
          distractorPool: content.distractorWordPool,
          seed: seed,
        );
        return exercise == null
            ? _ImmediateDone(onDone: onDone)
            : _FillBlankView(exercise: exercise, onDone: onDone);
      case MicroExerciseKind.firstLetter:
        final exercise =
            buildFirstLetterExercise(arabicText: content.arabicSegments.first);
        return exercise == null
            ? _ImmediateDone(onDone: onDone)
            : _FirstLetterView(exercise: exercise, onDone: onDone);
      case MicroExerciseKind.orderAyahs:
        final exercise = buildOrderAyahsExercise(
          ayahs: content.arabicSegments,
          seed: seed,
        );
        return exercise == null
            ? _ImmediateDone(onDone: onDone)
            : _OrderAyahsView(exercise: exercise, onDone: onDone);
    }
  }
}

/// Defers calling [onDone] to the next frame — calling it synchronously
/// from a build method would trigger setState during build in the caller.
class _ImmediateDone extends StatefulWidget {
  const _ImmediateDone({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_ImmediateDone> createState() => _ImmediateDoneState();
}

class _ImmediateDoneState extends State<_ImmediateDone> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ExerciseScaffold extends StatelessWidget {
  const _ExerciseScaffold({
    required this.instructions,
    required this.children,
  });

  final String instructions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(instructions, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.text,
    required this.isWrong,
    required this.onPressed,
  });

  final String text;
  final bool isWrong;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: OutlinedButton(
        onPressed: onPressed,
        style: isWrong
            ? OutlinedButton.styleFrom(foregroundColor: Colors.red)
            : null,
        child: Text(text, style: quranTextStyle),
      ),
    );
  }
}

class _NextWordTapView extends StatefulWidget {
  const _NextWordTapView({required this.exercise, required this.onDone});

  final NextWordTapExercise exercise;
  final VoidCallback onDone;

  @override
  State<_NextWordTapView> createState() => _NextWordTapViewState();
}

class _NextWordTapViewState extends State<_NextWordTapView> {
  String? _wrongChoice;

  void _tap(String choice) {
    if (choice == widget.exercise.correctWord) {
      widget.onDone();
    } else {
      setState(() => _wrongChoice = choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return _ExerciseScaffold(
      instructions: AppLocalizations.of(context).sessionTapNextWord,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(exercise.promptWords.join(' '), style: quranTextStyle),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in exercise.choices)
              _ChoiceButton(
                text: choice,
                isWrong: choice == _wrongChoice,
                onPressed: () => _tap(choice),
              ),
          ],
        ),
      ],
    );
  }
}

class _FillBlankView extends StatefulWidget {
  const _FillBlankView({required this.exercise, required this.onDone});

  final FillBlankExercise exercise;
  final VoidCallback onDone;

  @override
  State<_FillBlankView> createState() => _FillBlankViewState();
}

class _FillBlankViewState extends State<_FillBlankView> {
  String? _wrongChoice;

  void _tap(String choice) {
    if (choice == widget.exercise.correctWord) {
      widget.onDone();
    } else {
      setState(() => _wrongChoice = choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final displayWords = [
      for (var i = 0; i < exercise.words.length; i++)
        i == exercise.blankIndex ? '____' : exercise.words[i],
    ];
    return _ExerciseScaffold(
      instructions: AppLocalizations.of(context).sessionFillBlank,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(displayWords.join(' '), style: quranTextStyle),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final choice in exercise.choices)
              _ChoiceButton(
                text: choice,
                isWrong: choice == _wrongChoice,
                onPressed: () => _tap(choice),
              ),
          ],
        ),
      ],
    );
  }
}

class _FirstLetterView extends StatefulWidget {
  const _FirstLetterView({required this.exercise, required this.onDone});

  final FirstLetterExercise exercise;
  final VoidCallback onDone;

  @override
  State<_FirstLetterView> createState() => _FirstLetterViewState();
}

class _FirstLetterViewState extends State<_FirstLetterView> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return _ExerciseScaffold(
      instructions: AppLocalizations.of(context).sessionRecallFirstLetters,
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            _revealed
                ? exercise.words.join(' ')
                : exercise.scaffoldHints.join(' '),
            style: quranTextStyle,
          ),
        ),
        const SizedBox(height: 16),
        if (!_revealed)
          OutlinedButton(
            onPressed: () => setState(() => _revealed = true),
            child: Text(AppLocalizations.of(context).sessionShowFullText),
          )
        else
          FilledButton(onPressed: widget.onDone, child: Text(AppLocalizations.of(context).commonContinue)),
      ],
    );
  }
}

class _OrderAyahsView extends StatefulWidget {
  const _OrderAyahsView({required this.exercise, required this.onDone});

  final OrderAyahsExercise exercise;
  final VoidCallback onDone;

  @override
  State<_OrderAyahsView> createState() => _OrderAyahsViewState();
}

class _OrderAyahsViewState extends State<_OrderAyahsView> {
  late List<int> _order;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.exercise.shuffledAyahs.length, (i) => i);
  }

  void _check() {
    final attempt = [for (final i in _order) widget.exercise.shuffledAyahs[i]];
    if (widget.exercise.isCorrectOrder(attempt)) {
      widget.onDone();
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ExerciseScaffold(
      instructions: AppLocalizations.of(context).sessionDragOrder,
      children: [
        if (_wrong)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(AppLocalizations.of(context).sessionNotQuite,
                style: const TextStyle(color: Colors.red)),
          ),
        SizedBox(
          height: 260,
          child: ReorderableListView(
            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                _wrong = false;
                final item = _order.removeAt(oldIndex);
                _order.insert(newIndex, item);
              });
            },
            children: [
              for (final i in _order)
                Padding(
                  key: ValueKey(i),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GlassCard(
                    enableBlur: false,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        widget.exercise.shuffledAyahs[i],
                        style: quranTextStyle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
            onPressed: _check,
            child: Text(AppLocalizations.of(context).sessionCheckOrder)),
      ],
    );
  }
}
