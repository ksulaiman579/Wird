import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/bookmark_service.dart';
import '../../core/content/hadith_pack_repository.dart';
import '../../core/db/database.dart';
import '../../core/l10n/format.dart';
import '../../shared/glass/glass.dart';
import '../hadith_reader/hadith_l10n.dart';

/// Every bookmarked ayah and hadith in one list (audit WQA-018 — they
/// could be saved from the readers but were listed nowhere).
final _allBookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  final service = ref.watch(bookmarkServiceProvider);
  return service.watchAll('quran').asyncMap((quran) async =>
      [...quran, ...await service.watchAll('hadith').first]);
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_allBookmarksProvider);
    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.bookmarksTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.commonFailedToLoad('$e'))),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l.bookmarksEmpty, textAlign: TextAlign.center),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [for (final b in items) _BookmarkTile(bookmark: b)],
              ),
      ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.bookmark});
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final parts = bookmark.contentKey.split(':');
    final isQuran = parts.first == 'q';
    final String title;
    if (isQuran) {
      title = '${l.navQuran} ${bidiIsolate('${parts[1]}:${parts[2]}')}';
    } else {
      title =
          '${hadithCollectionName(context, parts[1])} ${bidiIsolate(parts[2])}';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        enableBlur: false,
        onTap: () => _open(context, ref, parts),
        child: Row(
          children: [
            Icon(isQuran ? Icons.menu_book_rounded : Icons.auto_stories_rounded,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleSmall)),
            IconButton(
              tooltip: l.commonBookmark,
              icon: const Icon(Icons.bookmark_remove_outlined),
              onPressed: () => ref.read(bookmarkServiceProvider).toggle(
                    contentType: bookmark.contentType,
                    contentKey: bookmark.contentKey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(
      BuildContext context, WidgetRef ref, List<String> parts) async {
    if (parts.first == 'q') {
      context.push('/read?surah=${parts[1]}&ayah=${parts[2]}');
      return;
    }
    final collection = parts[1];
    if (collection == 'nawawi') {
      context.push('/hadith/nawawi/${parts[2]}');
      return;
    }
    final number = num.tryParse(parts[2]);
    final chapter = number == null
        ? null
        : await ref
            .read(hadithPackRepositoryProvider)
            .chapterOf(collection, number);
    if (!context.mounted) return;
    context.push(chapter == null
        ? '/hadith/collections/$collection'
        : '/hadith/collections/$collection/$chapter');
  }
}
