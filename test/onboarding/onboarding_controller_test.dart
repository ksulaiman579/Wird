import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/onboarding/onboarding_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('whole-Quran + hadith plan generates a profile, plan, and items', () async {
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.updateProfile(name: 'Umar', avatarEmoji: '📖');
    controller.updateScope(wantsQuran: true, wantsHadith: true, wantsDuas: false);
    controller.updateQuranSelection(
      selectionType: 'surahs',
      selectedSurahs: [114], // An-Nas: 6 short ayahs, quick to verify
    );
    controller.updateDailyMinutes(10);

    await controller.complete();

    final profile = await db.select(db.userProfiles).getSingle();
    expect(profile.name, 'Umar');
    expect(profile.avatarEmoji, '📖');

    final plan = await db.select(db.userPlans).getSingle();
    expect(plan.scope, 'both');
    expect(plan.quranSelectionType, 'surahs');
    expect(plan.quranSelectionJson, '[114]');
    expect(plan.dailyMinutes, 10);

    final items = await db.select(db.srsItems).get();
    final quranItems = items.where((i) => i.contentType == 'quran').toList();
    final hadithItems = items.where((i) => i.contentType == 'hadith').toList();
    final duaItems = items.where((i) => i.contentType == 'dua').toList();

    expect(quranItems, isNotEmpty);
    expect(hadithItems, hasLength(40)); // the 40 core hadiths, not 41-42
    expect(duaItems, isEmpty);

    // Quran items should come before hadith items in orderIndex, and
    // every item should start fresh with SM-2 defaults.
    final quranMaxOrder =
        quranItems.map((i) => i.orderIndex).reduce((a, b) => a > b ? a : b);
    final hadithMinOrder =
        hadithItems.map((i) => i.orderIndex).reduce((a, b) => a < b ? a : b);
    expect(quranMaxOrder, lessThan(hadithMinOrder));

    for (final item in items) {
      expect(item.status, 'new');
      expect(item.easeFactor, 2.5);
    }

    // An-Nas is 6 short ayahs, 20 words total: ayahs 1-5 reach the 15-word
    // minimum (17 words) before ayah 6 (3 words) starts a fresh group.
    expect(quranItems.map((i) => i.contentKey), ['q:114:1-5', 'q:114:6']);
  });

  test('duas toggle seeds the morning adhkar set', () async {
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.updateScope(wantsQuran: false, wantsHadith: true, wantsDuas: true);

    await controller.complete();

    final items = await db.select(db.srsItems).get();
    final duaItems = items.where((i) => i.contentType == 'dua').toList();
    expect(duaItems, isNotEmpty);
    expect(duaItems.every((i) => i.contentKey.startsWith('d:hm-')), isTrue);
  });

  test('skipping Quran produces no quran items', () async {
    final controller = container.read(onboardingControllerProvider.notifier);
    controller.updateScope(wantsQuran: false, wantsHadith: true);

    await controller.complete();

    final items = await db.select(db.srsItems).get();
    expect(items.where((i) => i.contentType == 'quran'), isEmpty);
  });
}
