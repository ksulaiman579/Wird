import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart' show Value;

import '../db/database.dart';
import '../platform/downloader_updates.dart';
import 'ayah_audio_urls.dart';
import 'local_ayah_file_io.dart';

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
/// Per-surah roll-up of its per-ayah tasks. Each ayah is its own task, so
/// the surah's status/progress must be computed over all of them — one
/// ayah's update must never stand for the whole surah (M26.4).
class SurahDownloadTally {
  SurahDownloadTally(this.total);

  /// Ayahs in this download (excludes ones already on disk at enqueue).
  int total;
  final statuses = <String, TaskStatus>{};
  final progress = <String, double>{};

  String get status {
    final s = statuses.values;
    final done = s.where((x) => x == TaskStatus.complete).length;
    if (total > 0 && done >= total) return 'downloaded';
    if (s.any((x) => x == TaskStatus.running || x == TaskStatus.enqueued ||
        x == TaskStatus.waitingToRetry)) {
      return 'downloading';
    }
    if (s.any((x) => x == TaskStatus.paused)) return 'paused';
    if (s.any((x) => x == TaskStatus.failed || x == TaskStatus.notFound)) {
      return 'failed';
    }
    if (s.isNotEmpty && s.every((x) => x == TaskStatus.canceled)) {
      return 'notDownloaded';
    }
    return 'downloading';
  }

  double get fraction {
    if (total <= 0) return 1.0;
    var sum = 0.0;
    for (final e in statuses.entries) {
      sum += e.value == TaskStatus.complete
          ? 1.0
          : (progress[e.key] ?? 0.0).clamp(0.0, 1.0);
    }
    return (sum / total).clamp(0.0, 1.0);
  }
}

/// `Husary_128kbps` → `128kbps`; null if the reciter id carries no bitrate.
String? qualityForReciter(String reciter) =>
    RegExp(r'(\d+)kbps').firstMatch(reciter)?.group(0);

class AudioDownloadManager implements AudioDownloads {
  AudioDownloadManager(this._db) {
    _sub = downloaderUpdates.listen(_onUpdate);
    // Persist task records so pause/resume/delete can find the tasks again
    // (they were never tracked, so those actions did nothing).
    unawaited(FileDownloader().trackTasks().catchError((_) => FileDownloader()));
  }

  final AppDatabase _db;
  late final StreamSubscription<TaskUpdate> _sub;
  final _tallies = <int, SurahDownloadTally>{};
  final _lastWritten = <int, (String, double)>{};

  /// DB writes run one at a time so concurrent ayah updates can't overwrite
  /// each other's read-then-write.
  Future<void> _queue = Future.value();
  Future<void> _serial(Future<void> Function() job) =>
      _queue = _queue.then((_) => job()).catchError((_) {});

  void _onUpdate(TaskUpdate update) {
    final surah = _surahFromGroup(update.task.group);
    if (surah == null) return;
    _serial(() async {
      final tally = await _tallyFor(surah);
      final id = update.task.taskId;
      switch (update) {
        case TaskStatusUpdate():
          tally.statuses[id] = update.status;
          if (update.status == TaskStatus.complete) tally.progress[id] = 1.0;
        case TaskProgressUpdate():
          if (update.progress >= 0) tally.progress[id] = update.progress;
          tally.statuses.putIfAbsent(id, () => TaskStatus.running);
      }
      if (tally.total < tally.statuses.length) {
        tally.total = tally.statuses.length;
      }
      await _writeTally(surah, tally);
    });
  }

  /// After an app restart the in-memory tally is gone — rebuild it once from
  /// the downloader's own records.
  Future<SurahDownloadTally> _tallyFor(int surah) async {
    final existing = _tallies[surah];
    if (existing != null) return existing;
    final tally = SurahDownloadTally(0);
    try {
      final records =
          await FileDownloader().database.allRecords(group: _groupFor(surah));
      for (final r in records) {
        tally.statuses[r.taskId] = r.status;
        tally.progress[r.taskId] = r.progress;
      }
      tally.total = records.length;
    } catch (_) {}
    return _tallies[surah] = tally;
  }

  /// Only touch the DB when the status changes or progress moves ≥2%, so a
  /// whole-Quran download doesn't fire thousands of writes per second.
  Future<void> _writeTally(int surah, SurahDownloadTally tally) async {
    final status = tally.status;
    final fraction = tally.fraction;
    final last = _lastWritten[surah];
    if (last != null &&
        last.$1 == status &&
        (fraction - last.$2).abs() < 0.02 &&
        fraction < 1.0) {
      return;
    }
    _lastWritten[surah] = (status, fraction);
    await _upsert(surah, status: status, progress: fraction);
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
    // Ayahs already on disk (e.g. from an earlier partial download) are
    // skipped rather than fetched again.
    final missing = <int>[];
    for (final ayah in ayahs) {
      final local =
          await findLocalAyahFile(reciter: reciter, surah: surah, ayah: ayah);
      if (local == null) missing.add(ayah);
    }

    await _serial(() async {
      _tallies[surah] = SurahDownloadTally(missing.length);
      _lastWritten.remove(surah);
      await _db.into(_db.downloadState).insertOnConflictUpdate(
            DownloadStateCompanion.insert(
              surahNumber: Value(surah),
              status: Value(missing.isEmpty ? 'downloaded' : 'downloading'),
              quality: Value(qualityForReciter(reciter)),
              reciter: Value(reciter),
              progress: Value(missing.isEmpty ? 1.0 : 0.0),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
    if (missing.isEmpty) return;

    // One platform call for the whole surah instead of one per ayah.
    await FileDownloader().enqueueAll([
      for (final ayah in missing)
        DownloadTask(
          taskId: '$reciter-${ayahAudioFileName(surah: surah, ayah: ayah)}',
          url: ayahAudioUrl(reciter: reciter, surah: surah, ayah: ayah),
          filename: ayahAudioFileName(surah: surah, ayah: ayah),
          directory: 'quran_audio/$reciter',
          baseDirectory: BaseDirectory.applicationDocuments,
          group: _groupFor(surah),
          requiresWiFi: wifiOnly,
          retries: 3,
          allowPause: true,
        ),
    ]);
  }

  @override
  Future<void> pauseSurah(int surah) async {
    final tasks = await FileDownloader().allTasks(group: _groupFor(surah));
    for (final task in tasks) {
      if (task is DownloadTask) await FileDownloader().pause(task);
    }
    await _serial(() => _upsert(surah, status: 'paused'));
  }

  @override
  Future<void> resumeSurah(int surah) async {
    final records =
        await FileDownloader().database.allRecords(group: _groupFor(surah));
    var resumed = false;
    for (final record in records) {
      if (record.status == TaskStatus.paused && record.task is DownloadTask) {
        resumed = await FileDownloader().resume(record.task as DownloadTask) ||
            resumed;
      }
    }
    if (resumed) await _serial(() => _upsert(surah, status: 'downloading'));
  }

  @override
  Future<void> deleteSurah(int surah) async {
    final group = _groupFor(surah);
    final records = await FileDownloader().database.allRecords(group: group);
    await FileDownloader().cancelTasksWithIds(records.map((r) => r.taskId));
    await FileDownloader().database.deleteRecordsWithIds(
          records.map((r) => r.taskId),
        );

    // Delete by folder, not by task record: files from before tracking was
    // turned on have no record but are still on disk.
    final row = await (_db.select(_db.downloadState)
          ..where((t) => t.surahNumber.equals(surah)))
        .getSingleOrNull();
    final reciters = <String>{
      if (row?.reciter != null) row!.reciter!,
      for (final r in records) r.task.directory.split('/').last,
    };
    await deleteLocalSurahFiles(surah: surah, reciters: reciters);

    await _serial(() async {
      _tallies.remove(surah);
      _lastWritten.remove(surah);
      await _upsert(surah, status: 'notDownloaded', progress: 0.0);
    });
  }

  Future<void> dispose() => _sub.cancel();
}
