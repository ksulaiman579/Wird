import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/library_download_service.dart';

void main() {
  test('libraryStatusFor maps downloader statuses to app statuses', () {
    expect(libraryStatusFor(TaskStatus.running),
        LibraryDownloadStatus.downloading);
    expect(libraryStatusFor(TaskStatus.enqueued),
        LibraryDownloadStatus.downloading);
    expect(libraryStatusFor(TaskStatus.paused), LibraryDownloadStatus.paused);
    expect(libraryStatusFor(TaskStatus.failed), LibraryDownloadStatus.failed);
    expect(libraryStatusFor(TaskStatus.notFound), LibraryDownloadStatus.failed);
    expect(libraryStatusFor(TaskStatus.canceled),
        LibraryDownloadStatus.notDownloaded);
    expect(libraryStatusFor(TaskStatus.complete),
        LibraryDownloadStatus.downloaded);
  });

  test('taskId is stable and namespaced per book', () {
    expect(LibraryDownloadService.taskIdFor(42), 'library-42');
  });

  test('fileNameFor uses the format extension correctly', () {
    expect(LibraryDownloadService.fileNameFor(42), '42.pdf');
    expect(LibraryDownloadService.fileNameFor(42, 'epub'), '42.epub');
  });
}
