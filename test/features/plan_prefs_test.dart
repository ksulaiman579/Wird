import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/db/database.dart';
import 'package:wird/features/settings/plan_prefs.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await db.into(db.userPlans).insert(
          UserPlansCompanion.insert(
            id: const Value(1),
            scope: 'quran',
            dailyMinutes: 20,
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('setReciter updates the plan\'s reciter field', () async {
    await setReciter(container, 'Alafasy_128kbps');

    final plan = await (db.select(db.userPlans)..where((t) => t.id.equals(1))).getSingle();
    expect(plan.reciter, 'Alafasy_128kbps');
  });
}
