import 'package:drift/drift.dart' show Value;

import '../../core/db/database.dart';

/// Small, directly-testable plan field writers for Settings — pulled out
/// of the widget so they don't need a pumped widget test to exercise.
/// `ref` is `dynamic` for the same reason as `applyQuranPlanEdit`.
Future<void> setReciter(dynamic ref, String reciter) async {
  final AppDatabase db = ref.read(appDatabaseProvider);
  await (db.update(db.userPlans)..where((t) => t.id.equals(1)))
      .write(UserPlansCompanion(reciter: Value(reciter)));
}
