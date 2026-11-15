import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../shared/share/share_card.dart';
import '../../core/content/bookmark_service.dart';
import '../../core/content/hadith_pack_repository.dart';
import '../../core/hadith/hadith_grade.dart';
import '../../core/l10n/reading_locale.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/font_size_chips.dart';
import '../../shared/ui/verse_roundel.dart';
import '../../core/prefs/app_language_provider.dart';
import 'hadith_l10n.dart';
import 'hadith_reader_providers.dart';
import '../../core/search/arabic_normalizer.dart';

final _isBookmarkedProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, contentKey) {
  return ref.watch(bookmarkServiceProvider).watchIsBookmarked(contentKey);
});

/// Chapter detail — lists every hadith in the chapter, reusing the
/// arabic/translation card layout from `HadithDetailScreen` (M13) with
/// bookmarking keyed `h:<collection>:<n>`. Carries a search field (by real
/// hadith number or translation keyword), porting the Nawawi treatment to
/// every collection (Item 1.19).
class HadithChapterDetailScreen extends ConsumerStatefulWidget {
  const HadithChapterDetailScreen({
    super.key,
    required this.collection,
    required this.chapterNumber,
  });

  final String collection;
  final String chapterNumber;

  @override
  ConsumerState<HadithChapterDetailScreen> createState() =>
      _HadithChapterDetailScreenState();
}

class _HadithChapterDetailScreenState
    extends ConsumerState<HadithChapterDetailScreen> {
  String _query = '';
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(
      hadithChapterEntriesProvider((widget.collection, widget.chapterNumber)),
    );
    final title = hadithCollectionName(context, widget.collection);
    final lang = ref.watch(appLanguageProvider).value ?? 'en';
    final q = _query.trim().toLowerCase();

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(title)),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (allEntries) {
          // Some collections (e.g. Sahih Muslim's introduction) carry entries
          // with no Arabic and no translation — skip them so the reader never
          // shows blank cards.
          final entries = allEntries
              .where((e) =>
                  e.arabic.trim().isNotEmpty || e.translation.trim().isNotEmpty)
              .toList();
          // Match by exact hadith number or a translation-text substring.
          final filtered = q.isEmpty
              ? entries
              : entries
                  .where((e) =>
                      e.numberLabel == q ||
                      searchMatches(e.translationFor(lang), q) ||
                      searchMatches(e.translation, q) ||
                      searchMatches(e.arabic, q))
                  .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: AppLocalizations.of(context).hadithSearchHint,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              // A±/A− text sizing for the whole chapter — the same reading
              // control the Nawawi reader offers, so every collection reads
              // consistently.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FontSizeChips(
                    onIncrease: () =>
                        setState(() => _scale = (_scale + 0.1).clamp(0.8, 1.8)),
                    onDecrease: () =>
                        setState(() => _scale = (_scale - 0.1).clamp(0.8, 1.8)),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context).hadithNoMatch))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // No vetted hadith translation in this language
                            // (Hindi, Malayalam, Filipino — or Urdu/Bengali
                            // packs downloaded before that text existed).
                            final englishOnly = lang != 'en' &&
                                lang != 'ar' &&
                                !entries.any(
                                    (e) => e.translations.containsKey(lang));
                            return Column(
                              children: [
                                _CollectionNote(
                                    note: _collectionNote(
                                        context, widget.collection)),
                                if (englishOnly)
                                  _CollectionNote(
                                      note: AppLocalizations.of(context)
                                          .hadithEnglishOnlyNote),
                              ],
                            );
                          }
                          return _HadithEntryCard(
                              collection: widget.collection,
                              chapterNumber: widget.chapterNumber,
                              language: lang,
                              entry: filtered[index - 1],
                              scale: _scale);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Localized collection note. [collectionAuthenticityNote] (core) stays the
/// English source of truth and is unit-tested; this maps each collection to
/// its ARB string so the note translates with the locale.
String _collectionNote(BuildContext context, String collection) {
  final l = AppLocalizations.of(context);
  switch (collection) {
    case 'bukhari':
    case 'muslim':
      return l.hadithNoteSahihayn;
    case 'malik':
      return l.hadithNoteMuwatta;
    case 'abudawud':
    case 'tirmidhi':
    case 'nasai':
    case 'ibnmajah':
      return l.hadithNoteSunan;
    default:
      return l.hadithNoteGeneric;
  }
}

/// One hadith in a chapter. Collapsed by default — roundel number, grade
/// badge, bookmark, and a 2-line Arabic/translation preview — and expands on
/// tap to the full text + grade caution. This mirrors the Nawawi reader's
/// "tap to read" feel and keeps long collections (Bukhari chapters) from
/// rendering as one enormous scroll (user request).
const _rtl = {'ar', 'ur'};

class _HadithEntryCard extends ConsumerStatefulWidget {
  const _HadithEntryCard({
    required this.collection,
    required this.entry,
    required this.chapterNumber,
    required this.language,
    this.scale = 1.0,
  });

  final String collection;
  final String chapterNumber;
  final String language;
  final HadithEntry entry;
  final double scale;

  @override
  ConsumerState<_HadithEntryCard> createState() => _HadithEntryCardState();
}

class _HadithEntryCardState extends ConsumerState<_HadithEntryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final collection = widget.collection;
    final entry = widget.entry;
    final contentKey = 'h:$collection:${entry.number}';
    final isBookmarkedAsync = ref.watch(_isBookmarkedProvider(contentKey));
    final grade = resolveHadithGrade(entry.grades, collection);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        enableBlur: false,
        onTap: () => setState(() => _expanded = !_expanded),
        // Cream "mushaf page" card in light mode (M21.5).
        fillColor: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFF8F0D8)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Verse-roundel star for the hadith number — the same
                // ornamental signature the Nawawi cards use, so every
                // collection reads consistently (D10).
                VerseRoundel(
                    number: entry.number.toInt(),
                    label: entry.numberLabel,
                    size: 34),
                const SizedBox(width: 8),
                GradeBadge(grade: grade),
                const Spacer(),
                ShareCardButton(
                  passage: () => SharePassage(
                    arabic: entry.arabic,
                    translation: entry.translationFor(widget.language),
                    translationRtl: _rtl.contains(widget.language) &&
                        entry.translations.containsKey(widget.language),
                    reference:
                        '${hadithCollectionName(context, collection)} ${entry.numberLabel}',
                    route:
                        '/hadith/collections/$collection/${widget.chapterNumber}',
                  ),
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context).commonBookmark,
                  icon: Icon(
                    isBookmarkedAsync.value == true
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                  ),
                  onPressed: () => ref.read(bookmarkServiceProvider).toggle(
                        contentType: 'hadith',
                        contentKey: contentKey,
                      ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
              ],
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                entry.arabic,
                maxLines: _expanded ? null : 2,
                overflow:
                    _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 24 * widget.scale,
                  height: 2.0,
                ),
              ),
            ),
            // English translation hidden when the UI is Arabic (user request).
            if (showLatinReadingAids(Localizations.localeOf(context))) ...[
              const SizedBox(height: 8),
              Text(
                entry.translationFor(widget.language),
                textDirection: _rtl.contains(widget.language)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                maxLines: _expanded ? null : 2,
                overflow:
                    _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:
                      (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
                          widget.scale,
                  height: 1.5,
                ),
              ),
            ],
            if (_expanded) _GradeCaution(grade: grade),
          ],
        ),
      ),
    );
  }
}

/// Colour-coded authenticity badge (green ṣaḥīḥ/ḥasan, amber ungraded, red
/// ḍaʿīf/mawḍūʿ). Shows the grader's own words on long-press-free tooltip.
class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade});

  final HadithGrade grade;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (grade.authenticity) {
      HadithAuthenticity.sahih => (const Color(0xFF2E7D32), Colors.white),
      HadithAuthenticity.hasan => (const Color(0xFF558B2F), Colors.white),
      HadithAuthenticity.daif => (const Color(0xFFC62828), Colors.white),
      HadithAuthenticity.mawdu => (const Color(0xFF8E0000), Colors.white),
      // Darker gold: white on #9E7B00 was ~4:1 at 12px (needs 4.5).
      HadithAuthenticity.ungraded => (const Color(0xFF7A5F00), Colors.white),
    };
    final name = gradeLabel(context, grade.authenticity);
    final label =
        grade.rawGrade == null ? name : '$name · ${grade.rawGrade}';
    return Tooltip(
      message: grade.grader == null ? label : '$label (${grade.grader})',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          name,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GradeCaution extends StatelessWidget {
  const _GradeCaution({required this.grade});
  final HadithGrade grade;

  @override
  Widget build(BuildContext context) {
    if (!grade.authenticity.isCautionary) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFC62828)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              gradeCaution(context, grade.authenticity),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionNote extends StatelessWidget {
  const _CollectionNote({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_outlined, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(note, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
