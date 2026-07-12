import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/backup/backup_service.dart';
import 'package:wird/core/db/database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late BackupService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'ease_back_until': '2026-01-05',
    });
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(name: 'Test User', createdAt: DateTime(2026, 1, 1)),
        );
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            dailyMinutes: 20,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:1:1-2',
            orderIndex: 0,
            wordCount: 8,
            status: const Value('review'),
            dueDate: Value(DateTime(2026, 1, 10)),
          ),
        );
    final itemId = await db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: 'q:1:3-4',
            orderIndex: 1,
            wordCount: 10,
          ),
        );
    await db.into(db.reviewLogs).insert(
          ReviewLogsCompanion.insert(
            itemId: itemId,
            reviewedAt: DateTime(2026, 1, 5),
            grade: 4,
            intervalBefore: 1,
            intervalAfter: 3,
          ),
        );
    await db.into(db.dailySessions).insert(
          DailySessionsCompanion.insert(
            day: '2026-01-05',
            newItemsPlanned: 2,
            reviewsPlanned: 1,
            completed: const Value(true),
          ),
        );
    await db.into(db.achievements).insert(
          AchievementsCompanion.insert(
            achievementId: 'first_ayah',
            unlockedAt: DateTime(2026, 1, 2),
          ),
        );
    await db.into(db.streakState).insert(
          StreakStateCompanion.insert(
            id: const Value(1),
            currentStreak: const Value(3),
            longestStreak: const Value(5),
            freezeTokens: const Value(1),
            lastCompletedDay: Value(DateTime(2026, 1, 5)),
          ),
        );
    await db.into(db.duaSelections).insert(
          DuaSelectionsCompanion.insert(duaId: 'hm-1', addedAt: DateTime(2026, 1, 3)),
        );
    await db.into(db.downloadState).insert(
          DownloadStateCompanion.insert(
            surahNumber: const Value(1),
            status: const Value('downloaded'),
            quality: const Value('128kbps'),
            reciter: const Value('Husary_128kbps'),
            progress: const Value(1.0),
          ),
        );
  });

  tearDown(() => db.close());

  test('export -> wipe -> import restores identical table state', () async {
    final json = await service.buildBackupJson();

    final before = await _snapshot(db);

    // Wipe everything (simulating a fresh install / reset) before restoring.
    await db.delete(db.reviewLogs).go();
    await db.delete(db.srsItems).go();
    await db.delete(db.dailySessions).go();
    await db.delete(db.achievements).go();
    await db.delete(db.streakState).go();
    await db.delete(db.duaSelections).go();
    await db.delete(db.downloadState).go();
    await db.delete(db.userPlans).go();
    await db.delete(db.userProfiles).go();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await service.restoreFromJson(json);

    final after = await _snapshot(db);
    expect(after, before);

    final restoredPrefs = await SharedPreferences.getInstance();
    expect(restoredPrefs.getString('theme_mode'), 'dark');
    expect(restoredPrefs.getString('ease_back_until'), '2026-01-05');
  });

  test('restoreFromJson rejects a newer schema version', () async {
    final json = await service.buildBackupJson();
    json['schemaVersion'] = backupSchemaVersion + 1;

    expect(
      () => service.restoreFromJson(json),
      throwsA(isA<BackupSchemaException>()),
    );
  });
}

Future<Map<String, dynamic>> _snapshot(AppDatabase db) async {
  return {
    'userProfiles': (await db.select(db.userProfiles).get()).map((r) => r.toJson()).toList(),
    'userPlans': (await db.select(db.userPlans).get()).map((r) => r.toJson()).toList(),
    'srsItems': (await db.select(db.srsItems).get()).map((r) => r.toJson()).toList(),
    'reviewLogs': (await db.select(db.reviewLogs).get()).map((r) => r.toJson()).toList(),
    'dailySessions': (await db.select(db.dailySessions).get()).map((r) => r.toJson()).toList(),
    'achievements': (await db.select(db.achievements).get()).map((r) => r.toJson()).toList(),
    'streakState': (await db.select(db.streakState).get()).map((r) => r.toJson()).toList(),
    'duaSelections': (await db.select(db.duaSelections).get()).map((r) => r.toJson()).toList(),
    'downloadState': (await db.select(db.downloadState).get()).map((r) => r.toJson()).toList(),
  };
}
