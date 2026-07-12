import 'package:drift/drift.dart';

import '../db/database.dart';

/// Which track (or everything) [ResetService.reset] wipes progress for.
enum ResetScope { quran, hadith, dua, full }

/// Resets memorization progress back to a fresh start — per the plan,
/// this resets SRS state (not the plan/profile itself): every affected
/// `srs_items` row goes back to `new` and its `review_logs` are deleted.
/// [ResetScope.full] additionally clears the cross-track aggregates
/// (`daily_sessions`, `achievements`, `streak_state`) and dua selections,
/// since those have no meaningful per-track scope. The caller is
/// responsible for writing an automatic backup first (via
/// [BackupService.exportViaShare]) — this service only wipes.
class ResetService {
  ResetService(this.db);

  final AppDatabase db;

  Future<void> reset(ResetScope scope) async {
    await db.transaction(() async {
      final contentType = switch (scope) {
        ResetScope.quran => 'quran',
        ResetScope.hadith => 'hadith',
        ResetScope.dua => 'dua',
        ResetScope.full => null,
      };
      await _resetItems(contentType);

      if (scope == ResetScope.dua || scope == ResetScope.full) {
        await db.delete(db.duaSelections).go();
      }
      if (scope == ResetScope.full) {
        await db.delete(db.dailySessions).go();
        await db.delete(db.achievements).go();
        await db.delete(db.streakState).go();
      }
    });
  }

  /// Deletes review logs for, then resets to `new`, every srs_items row —
  /// scoped to [contentType] if given, or every row for a full reset.
  Future<void> _resetItems(String? contentType) async {
    var itemsQuery = db.select(db.srsItems);
    if (contentType != null) {
      itemsQuery = itemsQuery..where((t) => t.contentType.equals(contentType));
    }
    final ids = (await itemsQuery.get()).map((i) => i.id).toList();
    if (ids.isNotEmpty) {
      await (db.delete(db.reviewLogs)..where((t) => t.itemId.isIn(ids))).go();
    }

    var update = db.update(db.srsItems);
    if (contentType != null) {
      update = update..where((t) => t.contentType.equals(contentType));
    }
    await update.write(
      const SrsItemsCompanion(
        status: Value('new'),
        easeFactor: Value(2.5),
        intervalDays: Value(0),
        repetitions: Value(0),
        learningStep: Value(0),
        dueDate: Value(null),
        introducedAt: Value(null),
      ),
    );
  }
}
