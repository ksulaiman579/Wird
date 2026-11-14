import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/db/database.dart';

import '../generated_migrations/schema.dart';

// Schema snapshots live in drift_schemas/. After bumping schemaVersion:
//   dart run drift_dev schema dump lib/core/db/database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
// then add a `runMigrationAndValidate` test from the previous version.
// Versions 1–6 predate snapshots and can't be reconstructed.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the live schema matches the v7 snapshot', () async {
    final schema = await verifier.schemaAt(7);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 7);
    await db.close();
  });

  test('foreign keys are on: a log for a missing item is rejected', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await expectLater(
      db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
            itemId: 999,
            reviewedAt: DateTime(2026, 1, 1),
            grade: 4,
            intervalBefore: 1,
            intervalAfter: 3,
          )),
      throwsA(isA<SqliteException>()),
    );
  });
}
