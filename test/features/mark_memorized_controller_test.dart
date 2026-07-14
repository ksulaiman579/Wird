import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/quran_browser/mark_memorized_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime(2026, 3, 1);

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

  test('marking a surah memorized creates long-term review items', () async {
    final count = await markQuranMemorized(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      now: now,
    );

    expect(count, greaterThan(0));
    final items = await db.select(db.srsItems).get();
    expect(items, hasLength(count));
    expect(items.every((i) => i.contentKey.startsWith('q:1:')), isTrue);
    expect(items.every((i) => i.status == 'review'), isTrue);
    expect(items.every((i) => i.intervalDays == kMemorizedIntervalDays), isTrue);
    expect(items.every((i) => i.repetitions == kMemorizedRepetitions), isTrue);
    expect(
      items.every((i) => i.dueDate == now.add(const Duration(days: 7))),
      isTrue,
    );
    expect(items.every((i) => i.introducedAt == now), isTrue);
  });

  test('promotes an existing new item in place instead of duplicating',
      () async {
    // Seed one plan item for a Fatihah portion as a fresh "new" item.
    await markQuranMemorized(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      now: now,
    );
    final marked = await db.select(db.srsItems).get();
    final key = marked.first.contentKey;
    // Reset it to a brand-new item to simulate it already being in the plan.
    await (db.update(db.srsItems)..where((t) => t.contentKey.equals(key)))
        .write(const SrsItemsCompanion(
      status: Value('new'),
      intervalDays: Value(0),
      repetitions: Value(0),
    ));

    final countAgain = await markQuranMemorized(
      container,
      selectionType: 'surahs',
      selectionIds: [1],
      now: now,
    );

    final after = await db.select(db.srsItems).get();
    // No duplicates — same number of rows as portions.
    expect(after, hasLength(countAgain));
    final promoted = after.singleWhere((i) => i.contentKey == key);
    expect(promoted.status, 'review');
    expect(promoted.intervalDays, kMemorizedIntervalDays);
  });

  test('marking an empty selection is a no-op', () async {
    final count = await markQuranMemorized(
      container,
      selectionType: 'surahs',
      selectionIds: const [],
      now: now,
    );
    expect(count, 0);
    expect(await db.select(db.srsItems).get(), isEmpty);
  });
}
