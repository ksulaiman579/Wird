import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show InsertMode;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database.dart';

/// Bumped whenever the exported shape changes in a way that needs explicit
/// migration on import; [restoreFromJson] refuses anything newer than this.
const backupSchemaVersion = 1;

class BackupSchemaException implements Exception {
  BackupSchemaException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Export/import/reset of everything that makes up a user's progress:
/// every `AppDatabase` table plus the handful of `shared_preferences` keys
/// this app writes (theme, notification prefs, cached location, etc).
///
/// Split into a testable core ([buildBackupJson]/[restoreFromJson], DB +
/// prefs only) and thin plugin wrappers ([exportViaShare]/
/// [importViaFilePicker]) that this container can't exercise directly —
/// same pattern as the audio/download/notification services.
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  Future<Map<String, dynamic>> buildBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = {for (final key in prefs.getKeys()) key: prefs.get(key)};

    return {
      'schemaVersion': backupSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'userProfiles':
          (await db.select(db.userProfiles).get()).map((r) => r.toJson()).toList(),
      'userPlans':
          (await db.select(db.userPlans).get()).map((r) => r.toJson()).toList(),
      'srsItems':
          (await db.select(db.srsItems).get()).map((r) => r.toJson()).toList(),
      'reviewLogs':
          (await db.select(db.reviewLogs).get()).map((r) => r.toJson()).toList(),
      'dailySessions':
          (await db.select(db.dailySessions).get()).map((r) => r.toJson()).toList(),
      'achievements':
          (await db.select(db.achievements).get()).map((r) => r.toJson()).toList(),
      'streakState':
          (await db.select(db.streakState).get()).map((r) => r.toJson()).toList(),
      'duaSelections':
          (await db.select(db.duaSelections).get()).map((r) => r.toJson()).toList(),
      'downloadState':
          (await db.select(db.downloadState).get()).map((r) => r.toJson()).toList(),
      'settings': settings,
    };
  }

  Future<String> buildBackupFileName() async {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return 'daily_backup_$date.daily.json';
  }

  /// Wipes every table this app writes to and every mirrored preference,
  /// then repopulates from [json] — in FK-safe order (review_logs
  /// references srs_items, so it's deleted first and inserted last).
  Future<void> restoreFromJson(Map<String, dynamic> json) async {
    final version = json['schemaVersion'];
    if (version is! int || version > backupSchemaVersion) {
      throw BackupSchemaException(
        'Unsupported backup schema version: $version',
      );
    }

    await db.transaction(() async {
      await db.delete(db.reviewLogs).go();
      await db.delete(db.srsItems).go();
      await db.delete(db.dailySessions).go();
      await db.delete(db.achievements).go();
      await db.delete(db.streakState).go();
      await db.delete(db.duaSelections).go();
      await db.delete(db.downloadState).go();
      await db.delete(db.userPlans).go();
      await db.delete(db.userProfiles).go();

      for (final row in _list(json, 'userProfiles')) {
        await db.into(db.userProfiles).insert(
              UserProfile.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'userPlans')) {
        await db.into(db.userPlans).insert(
              UserPlan.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'srsItems')) {
        await db.into(db.srsItems).insert(
              SrsItem.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'reviewLogs')) {
        await db.into(db.reviewLogs).insert(
              ReviewLog.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'dailySessions')) {
        await db.into(db.dailySessions).insert(
              DailySession.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'achievements')) {
        await db.into(db.achievements).insert(
              Achievement.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'streakState')) {
        await db.into(db.streakState).insert(
              StreakStateData.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'duaSelections')) {
        await db.into(db.duaSelections).insert(
              DuaSelection.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
      for (final row in _list(json, 'downloadState')) {
        await db.into(db.downloadState).insert(
              DownloadStateData.fromJson(row),
              mode: InsertMode.insertOrReplace,
            );
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final settings = json['settings'];
    if (settings is Map) {
      for (final entry in settings.entries) {
        final key = entry.key as String;
        final value = entry.value;
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, value.cast<String>());
        }
      }
    }
  }

  /// Builds the backup, then hands it to the system share sheet (native) —
  /// which on web falls back to a browser download, per share_plus.
  Future<void> exportViaShare() async {
    final json = await buildBackupJson();
    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(json));
    final fileName = await buildBackupFileName();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: fileName, mimeType: 'application/json')],
        fileNameOverrides: [fileName],
      ),
    );
  }

  /// Opens the file picker for a `.daily.json` backup and restores it.
  /// Returns false if the user cancelled the picker.
  Future<bool> importViaFilePicker() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final file = result?.files.singleOrNull;
    if (file == null) return false;

    final bytes = await file.readAsBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    await restoreFromJson(json);
    return true;
  }

  // ---- Automated monthly local backups (Item 1.27b) ----

  static const _lastBackupPrefKey = 'last_local_backup_at';
  static const _backupIntervalDays = 30;
  static const _keepBackups = 3;

  /// When the last automatic local backup was written, or null if never.
  Future<DateTime?> lastLocalBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastBackupPrefKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// Writes a timestamped backup into the app-documents `wird_backups/`
  /// folder, keeping only the newest [_keepBackups], and records the time.
  /// No-op on web (no app-documents dir); returns the file path or null.
  Future<String?> writeLocalBackup() async {
    if (kIsWeb) return null;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/wird_backups');
    if (!await dir.exists()) await dir.create(recursive: true);

    final json = await buildBackupJson();
    final bytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(json));
    final file = File('${dir.path}/${await buildBackupFileName()}');
    await file.writeAsBytes(bytes);

    // Rotate: keep the newest [_keepBackups] by filename (dates sort
    // lexically), delete the rest.
    final backups = (await dir.list().toList())
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in backups.skip(_keepBackups)) {
      try {
        await old.delete();
      } catch (_) {
        // Best-effort cleanup — a locked/removed file must not fail backup.
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupPrefKey, DateTime.now().toIso8601String());
    return file.path;
  }

  /// Launch-time guard: writes a local backup if none exists or the last
  /// was more than [_backupIntervalDays] ago. Returns true if it wrote one.
  /// Never throws — backup must never block or crash startup.
  Future<bool> maybeRunMonthlyBackup() async {
    if (kIsWeb) return false;
    try {
      final last = await lastLocalBackupAt();
      if (last != null &&
          DateTime.now().difference(last).inDays < _backupIntervalDays) {
        return false;
      }
      return (await writeLocalBackup()) != null;
    } catch (_) {
      return false;
    }
  }
}

List<Map<String, dynamic>> _list(Map<String, dynamic> json, String key) {
  return (json[key] as List? ?? const []).cast<Map<String, dynamic>>();
}
