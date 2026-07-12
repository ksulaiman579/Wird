import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../db/database.dart';
import 'models/library_book.dart';

/// App-facing state of a book download.
enum LibraryDownloadStatus { notDownloaded, downloading, paused, downloaded, failed }

/// Maps a background_downloader [TaskStatus] to the app's own status (pure,
/// unit-tested). `complete` is deliberately *not* mapped here — completion
/// is the DB row's job (the file is on disk), so a still-running task and a
/// finished-but-recorded one never disagree.
LibraryDownloadStatus libraryStatusFor(TaskStatus s) => switch (s) {
      TaskStatus.running || TaskStatus.enqueued || TaskStatus.waitingToRetry =>
        LibraryDownloadStatus.downloading,
      TaskStatus.paused => LibraryDownloadStatus.paused,
      TaskStatus.failed || TaskStatus.notFound => LibraryDownloadStatus.failed,
      TaskStatus.canceled => LibraryDownloadStatus.notDownloaded,
      TaskStatus.complete => LibraryDownloadStatus.downloaded,
    };

/// Downloads Knowledge Library books (M24.5). On native, uses
/// `background_downloader` (resumable, survives app backgrounding) to pull
/// the IslamHouse PDF into the app-documents `library/` dir and records the
/// completed file in the `LibraryDownloads` table. On web — where there's
/// no persistent app-documents filesystem to render from — it falls back to
/// opening the PDF URL in a new tab.
class LibraryDownloadService {
  LibraryDownloadService(this._db) {
    _listenToDownloader();
  }

  final AppDatabase _db;
  final _progressController =
      StreamController<({int bookId, LibraryDownloadStatus status, double progress})>.broadcast();
  final _cachedProgress = <int, ({LibraryDownloadStatus status, double progress})>{};

  void _listenToDownloader() {
    // background_downloader's task stream is a native API — on web the
    // service only ever opens URLs in a new tab, so don't touch it there
    // (constructing/listening can null-crash in the web plugin, Item A1).
    if (kIsWeb) return;
    FileDownloader().updates.listen((u) {
      final taskId = u.task.taskId;
      if (!taskId.startsWith('library-')) return;
      final idStr = taskId.substring('library-'.length);
      final bookId = int.tryParse(idStr);
      if (bookId == null) return;

      if (u is TaskStatusUpdate) {
        final status = libraryStatusFor(u.status);
        final progress = u.status == TaskStatus.complete
            ? 1.0
            : (_cachedProgress[bookId]?.progress ?? 0.0);
        _emit(bookId, status, progress);
      } else if (u is TaskProgressUpdate) {
        _emit(bookId, LibraryDownloadStatus.downloading, u.progress.clamp(0.0, 1.0));
      }
    });
  }

  void _emit(int bookId, LibraryDownloadStatus status, double progress) {
    final update = (status: status, progress: progress);
    _cachedProgress[bookId] = update;
    if (!_progressController.isClosed) {
      _progressController.add((bookId: bookId, status: status, progress: progress));
    }
  }

  static String taskIdFor(int bookId) => 'library-$bookId';
  static String fileNameFor(int bookId, [String format = 'pdf']) =>
      '$bookId.$format';

  bool get supportsInAppDownload => !kIsWeb;

  /// Live progress (0..1) + status for one book, merged from cached state and
  /// active progress stream updates.
  Stream<({LibraryDownloadStatus status, double progress})> watchProgress(
    int bookId,
  ) async* {
    if (_cachedProgress.containsKey(bookId)) {
      yield _cachedProgress[bookId]!;
    }
    yield* _progressController.stream
        .where((e) => e.bookId == bookId)
        .map((e) => (status: e.status, progress: e.progress));
  }

  /// Whether this book already has a completed download on disk.
  Stream<bool> watchDownloaded(int bookId) {
    final q = _db.select(_db.libraryDownloads)
      ..where((t) => t.bookId.equals(bookId.toString()));
    return q.watch().map((rows) => rows.isNotEmpty);
  }

  /// Start (or, on web, open) a book download.
  ///
  /// Returns false when the web new-tab open failed (popup blocked etc.) so
  /// the caller can surface feedback instead of failing silently (Item A1).
  Future<bool> download(LibraryBook book) async {
    if (kIsWeb) {
      try {
        // platformDefault → a plain new tab on web; externalApplication can
        // null-crash in some url_launcher web paths.
        return await launchUrl(
          Uri.parse(book.url),
          mode: LaunchMode.platformDefault,
        );
      } catch (_) {
        return false;
      }
    }
    _emit(book.id, LibraryDownloadStatus.downloading, 0.05);

    final task = DownloadTask(
      taskId: taskIdFor(book.id),
      url: book.url,
      filename: fileNameFor(book.id, book.format),
      directory: 'library',
      baseDirectory: BaseDirectory.applicationDocuments,
      group: 'library',
      retries: 3,
      allowPause: true,
      updates: Updates.statusAndProgress,
    );

    final path = await task.filePath();

    try {
      final result = await FileDownloader().download(
        task,
        onProgress: (p) => _emit(book.id, LibraryDownloadStatus.downloading, p.clamp(0.0, 1.0)),
      );
      if (result.status == TaskStatus.complete) {
        await _recordComplete(book, path);
        return true;
      }
    } catch (_) {
      // Fall back to direct HTTP streaming
    }

    try {
      final success = await _downloadViaHttp(book, path);
      if (success) {
        await _recordComplete(book, path);
        return true;
      } else {
        _emit(book.id, LibraryDownloadStatus.failed, 0.0);
      }
    } catch (_) {
      _emit(book.id, LibraryDownloadStatus.failed, 0.0);
    }
    return false;
  }

  Future<void> _recordComplete(LibraryBook book, String path) async {
    await _db.into(_db.libraryDownloads).insertOnConflictUpdate(
          LibraryDownloadsCompanion.insert(
            bookId: book.id.toString(),
            path: path,
            sizeBytes: book.sizeBytes,
            downloadedAt: DateTime.now(),
          ),
        );
    _emit(book.id, LibraryDownloadStatus.downloaded, 1.0);
  }

  Future<bool> _downloadViaHttp(LibraryBook book, String targetPath) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(book.url));
      final response = await client.send(request);
      if (response.statusCode != 200) return false;

      final file = File(targetPath);
      await file.parent.create(recursive: true);
      final sink = file.openWrite();

      final totalBytes = response.contentLength ?? book.sizeBytes;
      var receivedBytes = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _emit(book.id, LibraryDownloadStatus.downloading, (receivedBytes / totalBytes).clamp(0.0, 1.0));
        }
      }
      await sink.flush();
      await sink.close();
      return true;
    } finally {
      client.close();
    }
  }

  Future<void> pause(int bookId) async {
    final task = await FileDownloader().taskForId(taskIdFor(bookId));
    if (task is DownloadTask) await FileDownloader().pause(task);
  }

  Future<void> resume(int bookId) async {
    final task = await FileDownloader().taskForId(taskIdFor(bookId));
    if (task is DownloadTask) await FileDownloader().resume(task);
  }

  Future<void> cancel(int bookId) async {
    await FileDownloader().cancelTasksWithIds([taskIdFor(bookId)]);
    _emit(bookId, LibraryDownloadStatus.notDownloaded, 0.0);
  }

  /// Delete the downloaded file + its DB row.
  Future<void> delete(int bookId) async {
    final rows = await (_db.select(_db.libraryDownloads)
          ..where((t) => t.bookId.equals(bookId.toString())))
        .get();
    for (final row in rows) {
      final f = File(row.path);
      if (await f.exists()) await f.delete();
    }
    await (_db.delete(_db.libraryDownloads)
          ..where((t) => t.bookId.equals(bookId.toString())))
        .go();
    _emit(bookId, LibraryDownloadStatus.notDownloaded, 0.0);
  }

  /// On-disk path of a completed download, or null.
  Future<String?> downloadedPath(int bookId) async {
    final row = await (_db.select(_db.libraryDownloads)
          ..where((t) => t.bookId.equals(bookId.toString())))
        .getSingleOrNull();
    return row?.path;
  }

  void dispose() {
    _progressController.close();
  }
}

final libraryDownloadServiceProvider = Provider<LibraryDownloadService>(
  (ref) => LibraryDownloadService(ref.watch(appDatabaseProvider)),
);
