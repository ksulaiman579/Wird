import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

/// Shared bookmarking for both the Quran and Hadith readers (M12/M13) —
/// one `bookmarks` row per bookmarked item, keyed by the same
/// `contentKey` convention `SrsItems` already uses (`q:<surah>:<ayah>`,
/// `h:<collection>:<n>`).
class BookmarkService {
  BookmarkService(this._db);

  final AppDatabase _db;

  Stream<bool> watchIsBookmarked(String contentKey) {
    final query = _db.select(_db.bookmarks)
      ..where((t) => t.contentKey.equals(contentKey));
    return query.watchSingleOrNull().map((row) => row != null);
  }

  Stream<List<Bookmark>> watchAll(String contentType) {
    final query = _db.select(_db.bookmarks)
      ..where((t) => t.contentType.equals(contentType))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch();
  }

  Future<void> toggle({
    required String contentType,
    required String contentKey,
  }) async {
    final existing = await (_db.select(_db.bookmarks)
          ..where((t) => t.contentKey.equals(contentKey)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.delete(_db.bookmarks)
            ..where((t) => t.contentKey.equals(contentKey)))
          .go();
      return;
    }

    await _db.into(_db.bookmarks).insert(
          BookmarksCompanion.insert(
            contentType: contentType,
            contentKey: contentKey,
            createdAt: DateTime.now(),
          ),
        );
  }
}

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService(ref.watch(appDatabaseProvider));
});
