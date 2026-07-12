import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart' show Value;

import '../db/database.dart';
import 'ayah_audio_urls.dart';

/// Download operations the `/downloads` screen needs. Exists so widget
/// tests can supply a fake — this container has no device to exercise
/// real `background_downloader` tasks against.
abstract class AudioDownloads {
  Future<void> enqueueSurah({
    required int surah,
    required List<int> ayahs,
    required String reciter,
    required bool wifiOnly,
  });
  Future<void> pauseSurah(int surah);
  Future<void> resumeSurah(int surah);
  Future<void> deleteSurah(int surah);
}

String _groupFor(int surah) => 'surah-$surah';

int? _surahFromGroup(String group) {
  if (!group.startsWith('surah-')) return null;
  return int.tryParse(group.substring('surah-'.length));
}

/// Native-only (see M8's `kIsWeb` gating at the call sites — this class
/// itself has no web guard, since `background_downloader` simply doesn't
/// support the web platform). Wraps `background_downloader`'s
/// [FileDownloader], one [DownloadTask] per ayah batched under a per-surah
/// group, and mirrors task status/progress into the `download_state`
/// table so the UI only ever needs to watch the DB, never the downloader
/// directly.
class AudioDownloadManager implements AudioDownloads {
  AudioDownloadManager(this._db) {
    _sub = FileDownloader().updates.listen(_onUpdate);
  }

  final AppDatabase _db;
  late final StreamSubscription<TaskUpdate> _sub;

  Future<void> _onUpdate(TaskUpdate update) async {
    final surah = _surahFromGroup(update.task.group);
    if (surah == null) return;

    switch (update) {
      case TaskStatusUpdate():
        final status = switch (update.status) {
          TaskStatus.complete => 'downloaded',
          TaskStatus.running || TaskStatus.enqueued => 'downloading',
          TaskStatus.paused => 'paused',
          TaskStatus.canceled => 'notDownloaded',
          TaskStatus.failed || TaskStatus.notFound => 'failed',
          _ => null,
        };
        if (status != null) await _upsert(surah, status: status);
      case TaskProgressUpdate():
        if (update.progress >= 0) await _upsert(surah, progress: update.progress);
    }
  }

  Future<void> _upsert(int surah, {String? status, double? progress}) async {
    final existing = await (_db.select(_db.downloadState)
          ..where((t) => t.surahNumber.equals(surah)))
        .getSingleOrNull();

    await _db.into(_db.downloadState).insertOnConflictUpdate(
          DownloadStateCompanion(
            surahNumber: Value(surah),
            status: Value(status ?? existing?.status ?? 'notDownloaded'),
            quality: existing?.quality == null
                ? const Value.absent()
                : Value(existing!.quality),
            reciter: existing?.reciter == null
                ? const Value.absent()
                : Value(existing!.reciter),
            progress: Value(progress ?? existing?.progress ?? 0.0),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> enqueueSurah({
    required int surah,
    required List<int> ayahs,
    required String reciter,
    required bool wifiOnly,
  }) async {
    await _db.into(_db.downloadState).insertOnConflictUpdate(
          DownloadStateCompanion.insert(
            surahNumber: Value(surah),
            status: const Value('downloading'),
            quality: Value(reciter.contains('64kbps') ? '64kbps' : '128kbps'),
            reciter: Value(reciter),
            progress: const Value(0.0),
            updatedAt: Value(DateTime.now()),
          ),
        );

    for (final ayah in ayahs) {
      final fileName = ayahAudioFileName(surah: surah, ayah: ayah);
      await FileDownloader().enqueue(DownloadTask(
        taskId: '$reciter-$fileName',
        url: ayahAudioUrl(reciter: reciter, surah: surah, ayah: ayah),
        filename: fileName,
        directory: 'quran_audio/$reciter',
        baseDirectory: BaseDirectory.applicationDocuments,
        group: _groupFor(surah),
        requiresWiFi: wifiOnly,
        retries: 3,
        allowPause: true,
      ));
    }
  }

  @override
  Future<void> pauseSurah(int surah) async {
    final tasks = await FileDownloader().allTasks(group: _groupFor(surah));
    for (final task in tasks) {
      if (task is DownloadTask) await FileDownloader().pause(task);
    }
    await _upsert(surah, status: 'paused');
  }

  @override
  Future<void> resumeSurah(int surah) async {
    final records =
        await FileDownloader().database.allRecords(group: _groupFor(surah));
    for (final record in records) {
      if (record.status == TaskStatus.paused && record.task is DownloadTask) {
        await FileDownloader().resume(record.task as DownloadTask);
      }
    }
    await _upsert(surah, status: 'downloading');
  }

  @override
  Future<void> deleteSurah(int surah) async {
    final group = _groupFor(surah);
    final records = await FileDownloader().database.allRecords(group: group);

    for (final record in records) {
      try {
        final path = await record.task.filePath();
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort — a missing file is not an error for a delete.
      }
    }

    await FileDownloader().cancelTasksWithIds(
      records.map((r) => r.taskId),
    );
    await FileDownloader().database.deleteRecordsWithIds(
          records.map((r) => r.taskId),
        );
    await _upsert(surah, status: 'notDownloaded', progress: 0.0);
  }

  Future<void> dispose() => _sub.cancel();
}
