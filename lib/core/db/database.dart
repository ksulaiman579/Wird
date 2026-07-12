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
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
