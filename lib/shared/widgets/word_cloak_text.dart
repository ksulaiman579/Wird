import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

/// Splits [text] into words and masks any word whose index is not in
/// [revealedIndices] behind a fixed-size box roughly matching its length —
/// used by the M3.2 progressive-fading and self-test steps so hiding words
/// doesn't collapse the line's layout the way removing them would.
class WordCloakText extends StatefulWidget {
  const WordCloakText({
    super.key,
    required this.text,
    required this.revealedIndices,
    this.style,
    this.textDirection = TextDirection.rtl,
    this.allowTapToReveal = true,
  });

  final String text;
  final Set<int> revealedIndices;
  final TextStyle? style;
  final TextDirection textDirection;
  final bool allowTapToReveal;

  @override
  State<WordCloakText> createState() => _WordCloakTextState();
}

class _WordCloakTextState extends State<WordCloakText> {
  final Set<int> _locallyRevealed = {};

  @override
  void didUpdateWidget(WordCloakText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tap-reveals are ephemeral per stage. Clear them when the text changes
    // (new item) OR when the caller-driven revealed set changes — otherwise
    // words revealed by tapping in an earlier fade stage (e.g. "hint") stay
    // visible after advancing to "fully hidden", so the verse was never
    // fully cloaked (Item 1.6).
    if (oldWidget.text != widget.text ||
        !setEquals(oldWidget.revealedIndices, widget.revealedIndices)) {
      _locallyRevealed.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final words =
        widget.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final effectiveStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final fontSize = effectiveStyle.fontSize ?? 16;

    return Directionality(
      textDirection: widget.textDirection,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < words.length; i++)
            () {
              final revealed = widget.revealedIndices.contains(i) ||
                  _locallyRevealed.contains(i);
              // Cross-fade between the cloak box and the word so tapping to
              // reveal (and re-cloaking on stage change) animates rather than
              // popping (Item 1.5).
              final child = revealed
                  ? Text(words[i], key: ValueKey('w$i'), style: effectiveStyle)
                  : GestureDetector(
                      key: ValueKey('c$i'),
                      onTap: widget.allowTapToReveal
                          ? () => setState(() => _locallyRevealed.add(i))
                          : null,
                      child: Container(
                        width: (words[i].length * fontSize * 0.6)
                            .clamp(24.0, 200.0),
                        height: fontSize * 1.3,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (c, anim) =>
                    FadeTransition(opacity: anim, child: c),
                child: child,
              );
            }(),
        ],
      ),
    );
  }
}

/// The three progressive-fading stages from M3.2: show every word, show
/// only the first word of each line as a scaffold hint, or hide everything
/// for active recall.
enum FadeStage { full, hint, hidden }

/// Word indices to reveal for a given [FadeStage].
Set<int> revealedIndicesFor(FadeStage stage, int wordCount) {
  switch (stage) {
    case FadeStage.full:
      return {for (var i = 0; i < wordCount; i++) i};
    case FadeStage.hint:
      return wordCount == 0 ? {} : {0};
    case FadeStage.hidden:
      return {};
  }
}

int wordCountOf(String text) =>
    text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
