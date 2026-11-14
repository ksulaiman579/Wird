import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  UserProfiles,
  UserPlans,
  SrsItems,
  ReviewLogs,
  DailySessions,
  Achievements,
  StreakState,
  DuaSelections,
  DownloadState,
  ContentPacks,
  Bookmarks,
  TasbihSessions,
  LibraryDownloads,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: 'daily',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(srsItems, srsItems.learningStep);
          }
          if (from < 3) {
            await m.addColumn(downloadState, downloadState.progress);
          }
          if (from < 4) {
            await m.createTable(contentPacks);
            await m.createTable(bookmarks);
          }
          if (from < 5) {
            // Hadith content keys were bare `h:<n>` (implicitly the Nawawi
            // 42 collection, the only one wired into SRS pre-M13). New
            // collections need `h:<collection>:<n>`, so existing rows are
            // rewritten to `h:nawawi:<n>` to disambiguate.
            await m.database.customStatement(
              "UPDATE srs_items SET content_key = 'h:nawawi:' || substr(content_key, 3) "
              "WHERE content_type = 'hadith' AND content_key NOT LIKE 'h:%:%'",
            );
          }
          if (from < 6) {
            await m.createTable(tasbihSessions);
          }
          if (from < 7) {
            await m.createTable(libraryDownloads);
          }
        },
        beforeOpen: (details) async {
          // Orphan review logs (left by plan edits during a session, before
          // M26.5) would block nothing on their own, but clear them so the
          // foreign-key check below starts from a clean table.
          await customStatement(
            'DELETE FROM review_logs WHERE item_id NOT IN (SELECT id FROM srs_items)',
          );
          // SQLite ships with foreign keys off; turn them on so review_logs
          // can't point at deleted srs_items again (M26.14).
          await customStatement('PRAGMA foreign_keys = ON');
          // A pack download killed mid-way (app closed) left its row in
          // 'downloading' forever — a spinner with no retry. Restore it to
          // what it really is on every open (M26.6).
          await customStatement(
            "UPDATE content_packs SET status = CASE WHEN data IS NOT NULL "
            "THEN 'downloaded' ELSE 'failed' END, progress = CASE WHEN data "
            "IS NOT NULL THEN 1.0 ELSE 0.0 END WHERE status = 'downloading'",
          );
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
