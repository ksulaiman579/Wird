import 'package:drift/drift.dart';

/// Local profile — purely on-device, no accounts.
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get avatarEmoji => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Singleton row (id always 1) describing the user's memorization plan.
class UserPlans extends Table {
  IntColumn get id => integer()();
  TextColumn get scope => text()(); // quran | hadith | both
  TextColumn get quranSelectionType => text().nullable()(); // surahs | juz | whole
  TextColumn get quranSelectionJson => text().nullable()();
  TextColumn get direction =>
      text().withDefault(const Constant('normal'))(); // normal | reversed
  IntColumn get dailyMinutes => integer()();
  TextColumn get reciter =>
      text().withDefault(const Constant('Husary_128kbps'))();
  IntColumn get weeklyGoal => integer().withDefault(const Constant(7))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per memorizable unit (ayah-group, hadith, or dua). Generated
/// eagerly at onboarding, ordered by [orderIndex] per the chosen direction.
class SrsItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentType => text()(); // quran | hadith | dua
  TextColumn get contentKey =>
      text().unique()(); // q:2:1-5 / h:nawawi:1 / d:hm-1
  IntColumn get orderIndex => integer()();
  IntColumn get wordCount => integer()();
  TextColumn get status =>
      text().withDefault(const Constant('new'))(); // new|learning|review|lapsed
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  // Index into sm2_scheduler's learning-step ladder while status is
  // learning/lapsed; meaningless (ignored) once status reaches review.
  IntColumn get learningStep => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get introducedAt => dateTime().nullable()();
}

/// Per-review audit trail — stats, accuracy, and algorithm tuning.
class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(SrsItems, #id)();
  DateTimeColumn get reviewedAt => dateTime()();
  IntColumn get grade => integer()(); // 0-5, mapped from Again/Hard/Good/Easy
  IntColumn get intervalBefore => integer()();
  IntColumn get intervalAfter => integer()();
}

/// One row per calendar day — powers the Today screen, streaks, and heatmap.
class DailySessions extends Table {
  TextColumn get day => text()(); // YYYY-MM-DD
  IntColumn get newItemsPlanned => integer()();
  IntColumn get newItemsDone => integer().withDefault(const Constant(0))();
  IntColumn get reviewsPlanned => integer()();
  IntColumn get reviewsDone => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {day};
}

class Achievements extends Table {
  TextColumn get achievementId => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {achievementId};
}

/// Singleton row (id always 1).
class StreakState extends Table {
  IntColumn get id => integer()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  IntColumn get freezeTokens => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDay => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DuaSelections extends Table {
  TextColumn get duaId => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {duaId};
}

/// Per-surah audio download status.
class DownloadState extends Table {
  IntColumn get surahNumber => integer()();
  TextColumn get status =>
      text().withDefault(const Constant('notDownloaded'))(); // notDownloaded|downloading|paused|downloaded|failed
  TextColumn get quality => text().nullable()(); // 64kbps | 128kbps
  TextColumn get reciter => text().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {surahNumber};
}

/// Downloadable content packs — additional Quran translations (v2 M12) and
/// Hadith collections (v2 M13). One row per pack; [editionOrCollection] is
/// the allowlisted edition id (translations) or collection slug (hadith).
class ContentPacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // translation | hadithCollection
  TextColumn get languageOrCollection => text()(); // e.g. "fr" or "bukhari"
  TextColumn get editionOrCollection => text()(); // e.g. "fra_muhammadhamidul" or "bukhari"
  TextColumn get status =>
      text().withDefault(const Constant('notDownloaded'))(); // notDownloaded|downloading|downloaded|failed
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  TextColumn get sha256 => text().nullable()();
  DateTimeColumn get installedAt => dateTime().nullable()();
  // The downloaded pack's raw JSON, stored directly in the database rather
  // than a platform-specific file/OPFS path — Drift already persists to
  // SQLite (native) / IndexedDB (web) transparently on both platforms, so
  // this sidesteps needing separate native-file and web-CacheStorage
  // storage code for what's a single ~1MB text blob per pack.
  TextColumn get data => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {type, editionOrCollection},
      ];
}

/// A user-saved bookmark into either the Quran or Hadith reader (v2 M12).
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contentType => text()(); // quran | hadith
  TextColumn get contentKey => text().unique()(); // e.g. q:2:255 or h:bukhari:1
  DateTimeColumn get createdAt => dateTime()();
}

/// One row per downloaded Knowledge Library book (M24.4). Tracks what's
/// on disk; the catalogue metadata itself lives in the bundled
/// `assets/data/knowledge_library.json`, so only the download bookkeeping
/// is persisted here. Unlike ContentPacks (which stores the pack JSON in
/// the DB), the PDF bytes live as a file on disk — `path` points to it.
class LibraryDownloads extends Table {
  TextColumn get bookId => text()(); // catalogue book id (stringified)
  TextColumn get path => text()(); // on-disk PDF path (native)
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// One row per completed Tasbih session (M15.3) — kept deliberately
/// separate from `SrsItems`/`ReviewLogs`/`StreakState`: this is a simple
/// counter history, not part of the SM-2 memorization/streak system.
class TasbihSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get presetLabel => text()(); // e.g. "33-33-34", "100", "Custom"
  IntColumn get targetCount => integer()();
  IntColumn get completedCount => integer()();
  DateTimeColumn get completedAt => dateTime()();
}
