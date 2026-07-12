import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';

final tasbihSessionsProvider = StreamProvider<List<TasbihSession>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.tasbihSessions)
    ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
    ..limit(20);
  return query.watch();
});

Future<void> recordTasbihSession(
  AppDatabase db, {
  required String presetLabel,
  required int targetCount,
  required int completedCount,
}) {
  return db.into(db.tasbihSessions).insert(
        TasbihSessionsCompanion.insert(
          presetLabel: presetLabel,
          targetCount: targetCount,
          completedCount: completedCount,
          completedAt: DateTime.now(),
        ),
      );
}
