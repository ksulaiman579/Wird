import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/library_download_service.dart';
import '../../core/content/library_repository.dart';
import '../../shared/glass/glass.dart';
import 'epub_reader_screen.dart';

/// In-app PDF and EPUB reader for a downloaded Knowledge Library book (M24.6 / Item 1.21).
/// Native-only — on web the library opens the book in a new tab instead, so
/// this screen is never routed to there. Resolves the book (for its title and format)
/// from the catalogue and the on-disk path from the download service; a
/// not-actually-downloaded book (e.g. a stale deep link) shows a short
/// message rather than a blank viewer.
class BookReaderScreen extends ConsumerWidget {
  const BookReaderScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(libraryDownloadServiceProvider);
    final bookAsync = ref.watch(_bookProvider(bookId));
    final book = bookAsync.value;
    final title = book?.title ?? AppLocalizations.of(context).bookReaderTitle;

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      contentPadding: EdgeInsets.zero,
      body: FutureBuilder<String?>(
        future: service.downloadedPath(bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final path = snapshot.data;
          if (path == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "This book isn't downloaded. Download it from the library "
                  'first, then open it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (book?.format == 'epub' || path.toLowerCase().endsWith('.epub')) {
            return EpubReaderScreen(
              bookId: bookId,
              title: title,
              path: path,
            );
          }
          return PdfViewer.file(
            path,
            params: PdfViewerParams(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        },
      ),
    );
  }
}

final _bookProvider = FutureProvider.family((ref, int id) {
  return ref.watch(libraryRepositoryProvider).byId(id);
});
