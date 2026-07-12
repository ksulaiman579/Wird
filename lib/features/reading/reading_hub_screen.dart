import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import '../quran_browser/quran_providers.dart';
import '../quran_reader/reader_prefs.dart';

/// The "Quran" tab landing (M23.4, render aeiqio "The Holy Quran") — the
/// renders' hub-page pattern: a Surah Collections section (resume where
/// you left off / open the full index) and a Study section (Hadith
/// collections + the memorization flow). Quran and Hadith still share this
/// bottom-nav slot; their full route subtrees (`/quran`, `/hadith`) are
/// unchanged.
class ReadingHubScreen extends ConsumerWidget {
  const ReadingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readerPrefsProvider).value;
    // Only surface "Continue / Resume" once a real read has been persisted
    // (setLastRead flips hasReadBefore); a fresh install starts at Surah 1
    // by default, so lastSurah alone can't distinguish "never opened" from
    // "left off at Al-Fatiha" (Item 1.10).
    final hasReadBefore = prefs?.hasReadBefore ?? false;
    final surah = prefs?.lastSurah ?? 1;
    final l = AppLocalizations.of(context);
    final surahName = ref
        .watch(quranMetaProvider)
        .maybeWhen(
          data: (meta) => meta.surahs
              .firstWhere((s) => s.number == surah)
              .nameTransliterated,
          orElse: () => 'Surah $surah',
        );

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.quranHubTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            l.readingSurahCollections,
            padding: const EdgeInsets.only(bottom: 12),
          ),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.book,
                title: hasReadBefore
                    ? l.readerContinueReading
                    : l.readerStartReading,
                description: hasReadBefore ? surahName : l.readingBeginFatiha,
                ctaLabel: hasReadBefore ? l.readingResume : l.commonStart,
                onTap: () =>
                    context.push('/read?surah=${hasReadBefore ? surah : 1}'),
                ornamented: true,
              ),
              HubCard(
                glyph: WirdGlyph.scroll,
                title: l.readingSurahIndex,
                description: l.readingBrowseAll,
                ctaLabel: l.readingIndexList,
                onTap: () => context.push('/quran'),
                ornamented: true,
              ),
            ],
          ),
          // Hadith Collections intentionally removed here (Item 1.17) — it
          // already lives in the Explore tab; the Quran hub keeps only the
          // memorization entry point.
          SectionHeader(l.readingMemorization),
          HubCardGrid(
            children: [
              HubCard(
                glyph: WirdGlyph.minaret,
                title: l.readingMemorization,
                description: l.readingMemorizationDesc,
                ctaLabel: l.commonStart,
                onTap: () => context.push('/session'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
