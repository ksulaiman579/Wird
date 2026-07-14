import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/settings/plan_edit_controller.dart';

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

  Future<void> seedQuranPlan() async {
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            quranSelectionType: const Value('surahs'),
            quranSelectionJson: const Value('[1]'),
            direction: const Value('normal'),
            dailyMinutes: 20,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
    await applyQuranPlanEdit(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      direction: 'normal',
      dailyMinutes: 20,
    );
  }

  List<String> types(List<SrsItem> items) =>
      items.map((i) => i.contentType).toSet().toList()..sort();

  test('enabling hadith + dua adds and interleaves both tracks', () async {
    await seedQuranPlan();

    await applyContentPlanEdit(container, wantsHadith: true, wantsDua: true);

    final items = await db.select(db.srsItems).get();
    expect(types(items), ['dua', 'hadith', 'quran']);
    // Interleaved from the front: the second new item is not Quran (a hadith
    // or dua slots in right after the first Quran portion).
    final byOrder = items..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    expect(byOrder.first.contentType, 'quran');
    expect(byOrder[1].contentType, isNot('quran'));
    // Newly added tracks are fresh.
    expect(
      items.where((i) => i.contentType != 'quran').every((i) => i.status == 'new'),
      isTrue,
    );
    // Scope reflects hadith inclusion.
    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1)))
        .getSingle();
    expect(plan.scope, 'both');
  });

  test('disabling hadith removes its items and review logs, keeps quran',
      () async {
    await seedQuranPlan();
    await applyContentPlanEdit(container, wantsHadith: true, wantsDua: false);

    final hadith = (await db.select(db.srsItems).get())
        .firstWhere((i) => i.contentType == 'hadith');
    await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
          itemId: hadith.id,
          reviewedAt: DateTime(2026, 1, 5),
          grade: 4,
          intervalBefore: 1,
          intervalAfter: 3,
        ));

    await applyContentPlanEdit(container, wantsHadith: false, wantsDua: false);

    final items = await db.select(db.srsItems).get();
    expect(items.any((i) => i.contentType == 'hadith'), isFalse);
    expect(items.any((i) => i.contentType == 'quran'), isTrue);
    expect(await db.select(db.reviewLogs).get(), isEmpty);
    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1)))
        .getSingle();
    expect(plan.scope, 'quran');
  });

  test('re-toggling preserves SM-2 progress on kept hadith items', () async {
    await seedQuranPlan();
    await applyContentPlanEdit(container, wantsHadith: true, wantsDua: false);

    final hadith = (await db.select(db.srsItems).get())
        .firstWhere((i) => i.contentType == 'hadith');
    await (db.update(db.srsItems)..where((t) => t.id.equals(hadith.id)))
        .write(const SrsItemsCompanion(
      status: Value('review'),
      easeFactor: Value(2.9),
      intervalDays: Value(12),
      repetitions: Value(3),
    ));

    // Enable dua too; hadith stays on and must keep its progress.
    await applyContentPlanEdit(container, wantsHadith: true, wantsDua: true);

    final survivor = (await db.select(db.srsItems).get())
        .firstWhere((i) => i.contentKey == hadith.contentKey);
    expect(survivor.status, 'review');
    expect(survivor.easeFactor, 2.9);
    expect(survivor.intervalDays, 12);
    expect(survivor.repetitions, 3);
  });
}
