import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/achievements/achievement_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  Future<void> insertQuranItem(String contentKey, {String status = 'review'}) {
    return db.into(db.srsItems).insert(
          SrsItemsCompanion.insert(
            contentType: 'quran',
            contentKey: contentKey,
            orderIndex: 0,
            wordCount: 5,
            status: Value(status),
          ),
        );
  }

  test(
      'fully memorizing surah 1 unlocks first_ayah and first_surah, and a '
      'second evaluation with no new state unlocks nothing further',
      () async {
    // Al-Fatihah is 7 ayahs.
    await insertQuranItem('q:1:1-7');

    final firstPass = await evaluateAndUnlockAchievements(container);
    final firstIds = firstPass.map((r) => r.id).toSet();
    expect(firstIds.contains('first_ayah'), true);
    expect(firstIds.contains('first_surah'), true);

    final persisted = await db.select(db.achievements).get();
    expect(
      persisted.map((a) => a.achievementId).toSet().containsAll(firstIds),
      true,
    );

    final secondPass = await evaluateAndUnlockAchievements(container);
    expect(secondPass, isEmpty);
  });

  test('hadith milestone unlocks once 10 hadiths are memorized', () async {
    for (var i = 1; i <= 10; i++) {
      await db.into(db.srsItems).insert(
            SrsItemsCompanion.insert(
              contentType: 'hadith',
              contentKey: 'h:$i',
              orderIndex: i,
              wordCount: 5,
              status: const Value('review'),
            ),
          );
    }

    final unlocked = await evaluateAndUnlockAchievements(container);
    expect(unlocked.map((r) => r.id).contains('hadith_10'), true);
  });
}
