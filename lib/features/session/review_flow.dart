import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/db/database.dart';
import '../../core/l10n/reading_locale.dart';
import '../../core/srs/sm2_scheduler.dart' show Grade;
import '../../core/theme/app_theme.dart';
import 'session_content_provider.dart';
import '../../core/haptics.dart';
import '../quran_reader/reader_prefs.dart';
import '../quran_reader/tajweed_formatter.dart';

/// The Sabqi/Manzil review flow: a prompt (the item's surah:ayah label,
/// hadith title, or dua occasion) with the text hidden, a Reveal button,
/// then Again/Hard/Good/Easy grading — each grade gives haptic feedback,
/// per the plan's "haptic feedback on counters/grades" design guardrail.
class ReviewFlow extends ConsumerStatefulWidget {
  const ReviewFlow({super.key, required this.item, required this.onGraded});

  final SrsItem item;
  final void Function(Grade grade) onGraded;

  @override
  ConsumerState<ReviewFlow> createState() => _ReviewFlowState();
}

class _ReviewFlowState extends ConsumerState<ReviewFlow> {
  bool _revealed = false;

  void _grade(Grade grade) {
    Haptics.impact();
    widget.onGraded(grade);
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
      data: (content) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(content.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _revealed
                    ? _RevealedContent(content: content)
                    : const _HiddenPrompt(),
              ),
            ),
            if (!_revealed)
              FilledButton(
                onPressed: () => setState(() => _revealed = true),
                child: Text(AppLocalizations.of(context).sessionReveal),
              )
            else
              _GradeButtons(onGrade: _grade),
          ],
        ),
      ),
    );
  }
}

class _HiddenPrompt extends StatelessWidget {
  const _HiddenPrompt();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).sessionRecallThenReveal,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _RevealedContent extends ConsumerWidget {
  const _RevealedContent({required this.content});

  final SessionItemContent content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Apply the reader's Tajweed highlighting here too, so the coloring is
    // consistent across surfaces (Item A2). Honors the same `showTajweed`
    // pref, so it's a no-op unless the reader has it enabled. When disabled,
    // format() returns a plain span in the same Uthmani style as before.
    final prefs = ref.watch(readerPrefsProvider).value;
    final showTajweed = prefs?.showTajweed ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < content.arabicSegments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    TajweedTextFormatter.format(
                      content.arabicSegments[i],
                      fontSize: quranTextStyle.fontSize ?? 26,
                      baseColor: quranTextStyle.color,
                      height: quranTextStyle.height ?? 2.0,
                      enabled: showTajweed,
                    ),
                  ),
                ),
                if (showLatinReadingAids(Localizations.localeOf(context))) ...[
                  const SizedBox(height: 8),
                  Text(content.translationSegments[i]),
                ],
              ],
            ),
          ),
        if (content.meaningNote != null)
          Text(
            content.meaningNote!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}

class _GradeButtons extends StatelessWidget {
  const _GradeButtons({required this.onGrade});

  final void Function(Grade grade) onGrade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => onGrade(Grade.again),
            child: Text(AppLocalizations.of(context).gradeAgain),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => onGrade(Grade.hard),
            child: Text(AppLocalizations.of(context).gradeHard),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => onGrade(Grade.good),
            child: Text(AppLocalizations.of(context).gradeGood),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: () => onGrade(Grade.easy),
            child: Text(AppLocalizations.of(context).gradeEasy),
          ),
        ),
      ],
    );
  }
}
