import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/library_repository.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';

/// Currently-selected library language (defaults to English). A simple
/// app-wide selection so the hub and the book list agree without threading
/// it through every route. (Riverpod 3 has no StateProvider — a small
/// Notifier, same pattern as NowPlayingNotifier.)
class LibraryLanguageNotifier extends Notifier<String> {
  @override
  String build() => 'en';
  void set(String code) => state = code;
}

final libraryLanguageProvider =
    NotifierProvider<LibraryLanguageNotifier, String>(
      LibraryLanguageNotifier.new,
    );

final _disciplineCountsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, lang) {
      return ref.watch(libraryRepositoryProvider).disciplineCounts(lang);
    });

/// Knowledge Library hub (M24.7, render language of the M23 hub pages): a
/// language chip row + a grid of discipline cards (with live book counts),
/// each opening the book list for that discipline. Books are published by
/// IslamHouse and downloaded on demand.
class KnowledgeLibraryScreen extends ConsumerWidget {
  const KnowledgeLibraryScreen({super.key});

  static WirdGlyph _glyphFor(String slug) => switch (slug) {
    'aqeedah' => WirdGlyph.minaret,
    'tafsir' => WirdGlyph.book,
    'hadith' => WirdGlyph.scroll,
    'fiqh' => WirdGlyph.scale,
    'seerah' => WirdGlyph.compass,
    'arabic' => WirdGlyph.book,
    _ => WirdGlyph.scroll,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(libraryLanguageProvider);
    final countsAsync = ref.watch(_disciplineCountsProvider(lang));

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).knowledgeLibraryTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context).knowledgePublishedBy,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final l in libraryLanguages)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l.label),
                      selected: l.code == lang,
                      onSelected: (_) => ref
                          .read(libraryLanguageProvider.notifier)
                          .set(l.code),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          countsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Failed to load: $e'),
            data: (counts) {
              final available = libraryDisciplines
                  .where((d) => (counts[d.slug] ?? 0) > 0)
                  .toList();
              if (available.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(AppLocalizations.of(context).knowledgeNoBooks),
                  ),
                );
              }
              return HubCardGrid(
                children: [
                  for (final d in available)
                    HubCard(
                      glyph: _glyphFor(d.slug),
                      title: d.label,
                      description: AppLocalizations.of(context)
                          .knowledgeBooksCount(counts[d.slug] ?? 0),
                      ctaLabel: AppLocalizations.of(context).commonBrowse,
                      onTap: () => context.push('/knowledge/${d.slug}'),
                      ornamented: true,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
