import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/bookmark_service.dart';
import '../../core/hadith/hadith_grade.dart';
import '../../core/l10n/reading_locale.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import '../hadith_reader/hadith_chapter_detail_screen.dart' show GradeBadge;
import 'hadith_providers.dart';

/// The narrator field sometimes already contains a full narration formula
/// ("It is narrated on the authority of …"); prefixing "Narrated by" then
/// doubles it (Item A3). Pure + unit-tested.
String narratorLine(String narrator) {
  final t = narrator.trim();
  final lower = t.toLowerCase();
  const formulas = ['it is narrated', 'narrated', 'it was narrated', 'on the authority'];
  for (final f in formulas) {
    if (lower.startsWith(f)) return t;
  }
  return 'Narrated by $t';
}

/// A single Nawawi hadith (M23.6, render iwrqvp): a two-tone title
/// ("Sahih..." gold · "Hadith N" green), A+/A− text-size chips + a
/// bookmark, the narrator line, a large translation, the Arabic text, and
/// the source reference — plus share.
class HadithDetailScreen extends ConsumerStatefulWidget {
  const HadithDetailScreen({super.key, required this.hadithId});

  final int hadithId;

  @override
  ConsumerState<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends ConsumerState<HadithDetailScreen> {
  double _scale = 1.0;

  String get _key => 'h:nawawi:${widget.hadithId}';

  @override
  Widget build(BuildContext context) {
    final hadithAsync = ref.watch(hadithByIdProvider(widget.hadithId));
    final isBookmarked = ref.watch(_isBookmarkedProvider(_key)).value ?? false;
    final theme = Theme.of(context);
    // Arabic UI: the English narrator line + translation are redundant.
    final showAids = showLatinReadingAids(Localizations.localeOf(context));

    return GlassScaffold(
      appBar: GlassAppBar(
        title: RichText(
          text: TextSpan(
            style: theme.appBarTheme.titleTextStyle,
            children: [
              TextSpan(
                text: '${AppLocalizations.of(context).hadithCollectionNawawi} ',
                style: TextStyle(color: theme.colorScheme.secondary),
              ),
              TextSpan(
                text: AppLocalizations.of(context)
                    .hadithNumbered(widget.hadithId),
              ),
            ],
          ),
        ),
      ),
      body: hadithAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (hadith) => ListView(
          children: [
            Text(hadith.titleEnglish, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            // Authenticity badge (Item A4) — same vetting model as the
            // hadith collections reader (M23.11), derived from the source.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GradeBadge(grade: nawawiGradeFromSource(hadith.source)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FontSizeChips(
                  onIncrease: () =>
                      setState(() => _scale = (_scale + 0.1).clamp(0.8, 1.8)),
                  onDecrease: () =>
                      setState(() => _scale = (_scale - 0.1).clamp(0.8, 1.8)),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Share',
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _share(hadith.translation, hadith.source),
                ),
                IconButton(
                  tooltip: 'Bookmark',
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                  ),
                  onPressed: () => ref
                      .read(bookmarkServiceProvider)
                      .toggle(contentType: 'hadith', contentKey: _key),
                ),
              ],
            ),
            if (showAids) ...[
              const SizedBox(height: 8),
              Text(
                narratorLine(hadith.narrator),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            GlassCard(
              enableBlur: false,
              fillColor: theme.brightness == Brightness.light
                  ? const Color(0xFFF8F0D8)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic first, then the translation (Item 1.18).
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      hadith.arabic,
                      style: TextStyle(
                        fontFamily: 'UthmanicHafs',
                        fontSize: 24 * _scale,
                        height: 2.0,
                      ),
                    ),
                  ),
                  if (showAids) ...[
                    const SizedBox(height: 20),
                    Text(
                      hadith.translation,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize:
                            (theme.textTheme.bodyLarge?.fontSize ?? 16) * _scale,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ReferenceLine(citations: {hadith.source: null}),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              enableBlur: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Understand',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(hadith.summary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(String translation, String source) async {
    await SharePlus.instance.share(
      ShareParams(text: '$translation\n\n— $source\n\nvia Wird'),
    );
  }
}

final _isBookmarkedProvider = StreamProvider.family<bool, String>((ref, key) {
  return ref.watch(bookmarkServiceProvider).watchIsBookmarked(key);
});
