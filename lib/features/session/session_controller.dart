import 'dart:async' show unawaited;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_providers.dart'
    show rescheduleNotifications;

import '../../core/chunking/portion_planner.dart';
import '../../core/db/database.dart';
import '../../core/gamification/achievements.dart' show AchievementRule;
import '../../core/gamification/ease_back.dart';
import '../../core/gamification/ease_back_prefs.dart';
import '../../core/gamification/streak_service.dart' as streak;
import '../../core/srs/sm2_scheduler.dart' as sm2;
import '../achievements/achievement_providers.dart' show evaluateAndUnlockAchievements;
import '../../core/calendar_math.dart';

/// Whether a queue entry is today's new lesson (Sabaq) or a due
/// revision (Sabqi/Manzil) — drives which UI flow (M3.2 vs M3.3) handles it.
enum SessionItemPhase { newItem, review }

class SessionQueueEntry {
  const SessionQueueEntry({required this.srsItem, required this.phase});

  final SrsItem srsItem;
  final SessionItemPhase phase;
}

/// A snapshot of today's portion, taken once when the session starts.
/// Grading advances [currentIndex] but never re-plans the queue — the
/// same one-shot-per-day semantics as [DailyPortion] itself.
class SessionState {
  const SessionState({
    required this.queue,
    required this.currentIndex,
    required this.newItemsDone,
    required this.reviewsDone,
    this.justCompletedStreak,
    this.newlyUnlockedAchievements = const [],
  });

  final List<SessionQueueEntry> queue;
  final int currentIndex;
  final int newItemsDone;
  final int reviewsDone;

  /// Set only on the grading call that first finishes today's portion —
  /// the resulting streak count, for the celebration screen. Null on every
  /// other state (including a same-day repeat, since streak_service's
  /// `applyCompletion` is itself idempotent for that case).
  final int? justCompletedStreak;

  /// Set only on the grading call that first finishes today's portion —
  /// any achievements newly unlocked by that completion, for a
  /// celebration snackbar. Empty on every other state.
  final List<AchievementRule> newlyUnlockedAchievements;

  static const empty = SessionState(
    queue: [],
    currentIndex: 0,
    newItemsDone: 0,
    reviewsDone: 0,
  );

  int get totalCount => queue.length;
  bool get isComplete => currentIndex >= queue.length;
  SessionQueueEntry? get current => isComplete ? null : queue[currentIndex];

  SessionState copyWith({
    int? currentIndex,
    int? newItemsDone,
    int? reviewsDone,
    int? justCompletedStreak,
    List<AchievementRule>? newlyUnlockedAchievements,
  }) {
    return SessionState(
      queue: queue,
      currentIndex: currentIndex ?? this.currentIndex,
      newItemsDone: newItemsDone ?? this.newItemsDone,
      reviewsDone: reviewsDone ?? this.reviewsDone,
      justCompletedStreak: justCompletedStreak ?? this.justCompletedStreak,
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
    );
  }
}



sm2.ItemStatus _statusFromDb(String status) => switch (status) {
      'new' => sm2.ItemStatus.newItem,
      'learning' => sm2.ItemStatus.learning,
      'review' => sm2.ItemStatus.review,
      'lapsed' => sm2.ItemStatus.lapsed,
      _ => throw ArgumentError('unknown srs_items.status: $status'),
    };

String _statusToDb(sm2.ItemStatus status) => switch (status) {
      sm2.ItemStatus.newItem => 'new',
      sm2.ItemStatus.learning => 'learning',
      sm2.ItemStatus.review => 'review',
      sm2.ItemStatus.lapsed => 'lapsed',
    };

/// Builds today's queue (due reviews, most-overdue-first, then new items in
/// plan order — same selection [planDailyPortion] already uses for the
/// Today screen's breakdown), applies grades via the pure SM-2 scheduler,
/// and persists the result to `srs_items` + `review_logs` + today's
/// `daily_sessions` done-counts.
class SessionController extends AsyncNotifier<SessionState> {
  /// The day this queue was planned for. Grades are counted against this
  /// day's `daily_sessions` row even if the session runs past midnight —
  /// the next day's row may not exist yet, and the counts were silently
  /// lost (M26.5).
  late String _sessionDayKey;

  /// Blocks a second grade while the first is still writing (double tap
  /// used to grade the same item twice).
  bool _grading = false;

  @override
  Future<SessionState> build() async {
    final db = ref.read(appDatabaseProvider);
    _sessionDayKey = dayKeyFor(DateTime.now());
    _grading = false;

    final plan = await db.select(db.userPlans).getSingleOrNull();
    if (plan == null) return SessionState.empty;

    final allItems = await db.select(db.srsItems).get();
    final today = dateOnly(DateTime.now());

    final dueRows = allItems
        .where((i) =>
            i.status != 'new' &&
            i.dueDate != null &&
            !i.dueDate!.isAfter(today))
        .toList();
    final newRows = allItems.where((i) => i.status == 'new').toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final streakRow = await db.select(db.streakState).getSingleOrNull();
    final easeBackActive = await isEaseBackActiveToday(
      lastCompletedDay: streakRow?.lastCompletedDay,
      now: DateTime.now(),
    );

    final portion = planDailyPortion(
      dueItems: dueRows
          .map((i) => PlannableItem(
                contentKey: i.contentKey,
                orderIndex: i.orderIndex,
                wordCount: i.wordCount,
                dueDate: i.dueDate,
              ))
          .toList(),
      availableNewItems: newRows
          .map((i) => PlannableItem(
                contentKey: i.contentKey,
                orderIndex: i.orderIndex,
                wordCount: i.wordCount,
              ))
          .toList(),
      dailyMinutes: plan.dailyMinutes,
      newBudgetMultiplier: newBudgetMultiplierFor(easeBackActive: easeBackActive),
    );

    final byKey = {for (final i in allItems) i.contentKey: i};
    final queue = [
      for (final planned in portion.reviewItems)
        SessionQueueEntry(
          srsItem: byKey[planned.contentKey]!,
          phase: SessionItemPhase.review,
        ),
      for (final planned in portion.newItems)
        SessionQueueEntry(
          srsItem: byKey[planned.contentKey]!,
          phase: SessionItemPhase.newItem,
        ),
    ];

    return SessionState(
      queue: queue,
      currentIndex: 0,
      newItemsDone: 0,
      reviewsDone: 0,
    );
  }

  Future<void> gradeCurrent(sm2.Grade grade) async {
    if (_grading) return;
    final current = state.value?.current;
    if (current == null) return;
    _grading = true;
    try {
      await _grade(current, grade);
    } finally {
      _grading = false;
    }
  }

  Future<void> _grade(SessionQueueEntry current, sm2.Grade grade) async {

    final db = ref.read(appDatabaseProvider);
    final item = current.srsItem;
    final now = DateTime.now();

    final before = sm2.Sm2State(
      status: _statusFromDb(item.status),
      easeFactor: item.easeFactor,
      intervalDays: item.intervalDays,
      repetitions: item.repetitions,
      dueDate: item.dueDate,
      learningStep: item.learningStep,
    );
    final after = sm2.schedule(before, grade, now);

    final s = state.value!;
    final willComplete = s.currentIndex + 1 >= s.totalCount;
    int? finalStreak;

    await db.transaction(() async {
      await (db.update(db.srsItems)..where((t) => t.id.equals(item.id))).write(
        SrsItemsCompanion(
          status: Value(_statusToDb(after.status)),
          easeFactor: Value(after.easeFactor),
          intervalDays: Value(after.intervalDays),
          repetitions: Value(after.repetitions),
          learningStep: Value(after.learningStep),
          dueDate: Value(after.dueDate),
          introducedAt:
              item.introducedAt == null ? Value(now) : const Value.absent(),
        ),
      );

      if (current.phase == SessionItemPhase.review) {
        await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
              itemId: item.id,
              reviewedAt: now,
              grade: grade.q,
              intervalBefore: item.intervalDays,
              intervalAfter: after.intervalDays,
            ));
      }

      final dayKey = _sessionDayKey;
      final session = await (db.select(db.dailySessions)
            ..where((t) => t.day.equals(dayKey)))
          .getSingleOrNull();
      if (session != null) {
        await (db.update(db.dailySessions)..where((t) => t.day.equals(dayKey)))
            .write(DailySessionsCompanion(
          newItemsDone: Value(session.newItemsDone +
              (current.phase == SessionItemPhase.newItem ? 1 : 0)),
          reviewsDone: Value(session.reviewsDone +
              (current.phase == SessionItemPhase.review ? 1 : 0)),
        ));

        if (willComplete && !session.completed) {
          finalStreak = await _completeToday(db, dayKey, now);
        }
      }
    });

    var newlyUnlocked = const <AchievementRule>[];
    if (finalStreak != null) {
      // Only evaluate on the grading that actually completed today's
      // portion — same trigger point as the streak update above. A crude
      // (documented) stand-in for real Fajr/Isha-based Early Bird/Night
      // Owl detection, which would need prayer-time data threaded into
      // this controller — see TASKS.md.
      newlyUnlocked = await evaluateAndUnlockAchievements(
        ref,
        earlyBirdSession: now.hour < 5,
        nightOwlSession: now.hour >= 22,
      );
      // Today is done: re-plan notifications so tonight's "streak at risk"
      // reminder is dropped (it was only computed at schedule time).
      if (!kIsWeb) {
        unawaited(rescheduleNotifications(ref).catchError((_) {}));
      }
    }

    state = AsyncValue.data(s.copyWith(
      currentIndex: s.currentIndex + 1,
      newItemsDone:
          s.newItemsDone + (current.phase == SessionItemPhase.newItem ? 1 : 0),
      reviewsDone:
          s.reviewsDone + (current.phase == SessionItemPhase.review ? 1 : 0),
      justCompletedStreak: finalStreak,
      newlyUnlockedAchievements: newlyUnlocked,
    ));
  }

  /// Marks today's `daily_sessions` row completed and applies the pure
  /// [streak.applyCompletion] to `streak_state`, returning the resulting
  /// streak count for the celebration screen. Caller has already checked
  /// the session exists and isn't already completed today.
  Future<int> _completeToday(
    AppDatabase db,
    String dayKey,
    DateTime now,
  ) async {
    await (db.update(db.dailySessions)..where((t) => t.day.equals(dayKey)))
        .write(const DailySessionsCompanion(completed: Value(true)));

    final existing = await db.select(db.streakState).getSingleOrNull();
    final current = existing == null
        ? streak.StreakState.empty
        : streak.StreakState(
            currentStreak: existing.currentStreak,
            longestStreak: existing.longestStreak,
            freezeTokens: existing.freezeTokens,
            lastCompletedDay: existing.lastCompletedDay,
          );

    final updated = streak.applyCompletion(current, now);

    await db.into(db.streakState).insertOnConflictUpdate(
          StreakStateCompanion.insert(
            id: const Value(1),
            currentStreak: Value(updated.currentStreak),
            longestStreak: Value(updated.longestStreak),
            freezeTokens: Value(updated.freezeTokens),
            lastCompletedDay: Value(updated.lastCompletedDay),
          ),
        );

    return updated.currentStreak;
  }
}

/// autoDispose: the queue is a snapshot of one day's portion. Keeping it
/// alive forever meant reopening /session showed the old celebration, the
/// next day (app still in memory) re-ran yesterday's queue, and a plan edit
/// left the session grading deleted items (M26.5). Only the session screen
/// watches this, so it's rebuilt fresh every time that screen opens.
final sessionControllerProvider =
    AsyncNotifierProvider.autoDispose<SessionController, SessionState>(
        SessionController.new);
