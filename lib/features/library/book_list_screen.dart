import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/library_download_service.dart';
import '../../core/content/library_repository.dart';
import '../../core/content/models/library_book.dart';
import '../../shared/glass/glass.dart';
import 'knowledge_library_screen.dart' show libraryLanguageProvider;

String _fmtSize(int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
  return '${(bytes / 1024).round()} KB';
}

final _booksProvider =
    FutureProvider.family<
      List<LibraryBook>,
      ({String discipline, String lang, String q})
    >((ref, key) {
      return ref
          .watch(libraryRepositoryProvider)
          .books(
            discipline: key.discipline,
            languageCode: key.lang,
            query: key.q,
          );
    });

/// Book list for one discipline (M24.7): search + rows with title/author/
/// size and a download → read/delete affordance.
class BookListScreen extends ConsumerStatefulWidget {
  const BookListScreen({super.key, required this.discipline});

  final String discipline;

  @override
  ConsumerState<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends ConsumerState<BookListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(libraryLanguageProvider);
    final booksAsync = ref.watch(
      _booksProvider((discipline: widget.discipline, lang: lang, q: _query)),
    );

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(libraryDisciplineLabel(widget.discipline)),
      ),
      contentPadding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: AppLocalizations.of(context).bookSearchHint,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$e'))),
              data: (books) => books.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context).bookNoMatch))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: books.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _BookRow(book: books[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends ConsumerWidget {
  const _BookRow({required this.book});

  final LibraryBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryDownloadServiceProvider);
    final downloaded = ref.watch(_downloadedProvider(book.id)).value ?? false;

    return GlassCard(
      enableBlur: false,
      // Native: open the in-app reader once downloaded. Web: the row tap
      // opens the book in a new tab (same as the action button) instead of
      // being dead (Item A1).
      onTap: kIsWeb
          ? () => _openOnWeb(context, service, book)
          : (downloaded
                ? () => context.push('/knowledge/book/${book.id}')
                : null),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${book.author} · ${_fmtSize(book.sizeBytes)} · ${book.format.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _BookAction(book: book, downloaded: downloaded, service: service),
        ],
      ),
    );
  }
}

/// Web-only: open the book URL in a new tab, surfacing failure (popup
/// blocked, bad URL) in a SnackBar instead of a silent no-op / crash.
Future<void> _openOnWeb(
  BuildContext context,
  LibraryDownloadService service,
  LibraryBook book,
) async {
  final ok = await service.download(book);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Couldn't open the book — your browser may have blocked the new tab.",
        ),
      ),
    );
  }
}

class _BookAction extends ConsumerWidget {
  const _BookAction({
    required this.book,
    required this.downloaded,
    required this.service,
  });

  final LibraryBook book;
  final bool downloaded;
  final LibraryDownloadService service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      // No in-app reader on web — the action opens the PDF in a new tab.
      return IconButton(
        tooltip: AppLocalizations.of(context).commonOpen,
        icon: const Icon(Icons.open_in_new_rounded),
        onPressed: () => _openOnWeb(context, service, book),
      );
    }
    if (downloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context).commonRead,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push('/knowledge/book/${book.id}'),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).commonDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => service.delete(book.id),
          ),
        ],
      );
    }
    // Not downloaded: show live progress if a task is running, else a
    // download button that confirms the size first.
    final progress = ref.watch(_progressProvider(book.id)).value;
    if (progress != null &&
        progress.status == LibraryDownloadStatus.downloading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          value: progress.progress > 0 ? progress.progress : null,
          strokeWidth: 3,
        ),
      );
    }
    return IconButton(
      tooltip: AppLocalizations.of(context).commonDownload,
      icon: const Icon(Icons.download_rounded),
      onPressed: () => _confirmDownload(context, ref),
    );
  }

  Future<void> _confirmDownload(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).bookDownloadConfirmTitle),
        content: Text(
          AppLocalizations.of(context).bookDownloadConfirmBody(
            book.title,
            _fmtSize(book.sizeBytes),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).commonDownload),
          ),
        ],
      ),
    );
    if (ok == true) await service.download(book);
  }
}

final _downloadedProvider = StreamProvider.family<bool, int>((ref, id) {
  return ref.watch(libraryDownloadServiceProvider).watchDownloaded(id);
});

final _progressProvider =
    StreamProvider.family<
      ({LibraryDownloadStatus status, double progress}),
      int
    >((ref, id) {
      return ref.watch(libraryDownloadServiceProvider).watchProgress(id);
    });
