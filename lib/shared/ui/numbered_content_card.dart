import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import 'font_size_chips.dart';
import 'reference_line.dart';
import 'verse_roundel.dart';

/// The hadith/dua list-card pattern (M23 design spec): a big gold ordinal,
/// bold title, a 2-line translation teaser, an optional single Arabic
/// line, a [ReferenceLine], and a row of secondary actions (share,
/// bookmark, font size). [onPlay] is omitted entirely when no audio exists
/// for this item — the design spec calls for hiding it rather than
/// disabling it.
class NumberedContentCard extends StatelessWidget {
  const NumberedContentCard({
    super.key,
    required this.number,
    required this.title,
    required this.teaser,
    this.arabic,
    this.citations = const {},
    this.onTap,
    this.onShare,
    this.onBookmark,
    this.bookmarked = false,
    this.onPlay,
    this.onFontIncrease,
    this.onFontDecrease,
  });

  final int number;
  final String title;
  final String teaser;
  final String? arabic;
  final Map<String, VoidCallback?> citations;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final bool bookmarked;
  final VoidCallback? onPlay;
  final VoidCallback? onFontIncrease;
  final VoidCallback? onFontDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;

    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The Quran verse-roundel star carries the app's ornamental
              // signature onto hadith cards too (D10), replacing the plain
              // gold ordinal.
              VerseRoundel(number: number, size: 40, color: gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(teaser, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              if (onFontIncrease != null && onFontDecrease != null)
                FontSizeChips(onIncrease: onFontIncrease!, onDecrease: onFontDecrease!),
            ],
          ),
          if (arabic != null) ...[
            const SizedBox(height: 12),
            Text(
              arabic!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 20),
            ),
          ],
          if (citations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ReferenceLine(citations: citations),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onShare != null)
                IconButton(onPressed: onShare, icon: const Icon(Icons.share_outlined), tooltip: 'Share'),
              if (onBookmark != null)
                IconButton(
                  onPressed: onBookmark,
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                  tooltip: 'Bookmark',
                ),
              if (onPlay != null)
                IconButton.filled(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                  style: IconButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
                  tooltip: 'Play',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
