import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/chunking/portion_planner.dart';
import '../../core/db/database.dart';
import '../../core/gamification/ease_back.dart';
import '../../core/gamification/ease_back_prefs.dart';

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.userProfiles).watchSingleOrNull();
});

final userPlanStreamProvider = StreamProvider<UserPlan?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.userPlans).watchSingleOrNull();
});

final srsItemsStreamProvider = StreamProvider<List<SrsItem>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.srsItems).watch();
});

final streakStateStreamProvider = StreamProvider<StreakStateData?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.streakState).watchSingleOrNull();
});

final dailySessionsStreamProvider = StreamProvider<List<DailySession>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.dailySessions).watch();
});

/// Whether ease-back mode (halved new-material budget after a 3+ day gap)
/// is active today, per `core/gamification/ease_back.dart`'s rule. Watches
/// [streakStateStreamProvider] so it re-checks whenever the streak changes
/// (e.g. right after finally completing a comeback session).
final easeBackActiveProvider = FutureProvider<bool>((ref) async {
  final streak = await ref.watch(streakStateStreamProvider.future);
  return isEaseBackActiveToday(
    lastCompletedDay: streak?.lastCompletedDay,
    now: DateTime.now(),
  );
});

/// Sessions completed since the most recent Monday, against the plan's
/// weekly goal — for the Today screen's week-goal ring.
class WeeklyGoalProgress {
  const WeeklyGoalProgress({required this.completed, required this.goal});

  final int completed;
  final int goal;

  static const empty = WeeklyGoalProgress(completed: 0, goal: 7);
}

final weeklyGoalProvider = Provider<AsyncValue<WeeklyGoalProgress>>((ref) {
  final planAsync = ref.watch(userPlanStreamProvider);
  final sessionsAsync = ref.watch(dailySessionsStreamProvider);

  if (planAsync.isLoading || sessionsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (planAsync.hasError) {
    return AsyncValue.error(planAsync.error!, planAsync.stackTrace!);
  }
  if (sessionsAsync.hasError) {
    return AsyncValue.error(sessionsAsync.error!, sessionsAsync.stackTrace!);
  }

  final plan = planAsync.value;
  if (plan == null) return const AsyncValue.data(WeeklyGoalProgress.empty);

  final today = _dateOnly(DateTime.now());
  final mostRecentMonday = today.subtract(Duration(days: (today.weekday - 1) % 7));

  final sessions = sessionsAsync.value ?? const <DailySession>[];
  final completedThisWeek = sessions.where((s) {
    if (!s.completed) return false;
    final parts = s.day.split('-');
    if (parts.length != 3) return false;
    final day = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return !day.isBefore(mostRecentMonday) && !day.isAfter(today);
  }).length;

  return AsyncValue.data(WeeklyGoalProgress(
    completed: completedThisWeek,
    goal: plan.weeklyGoal,
  ));
});

/// Today's Sabaq (new)/Sabqi (recently-learning or lapsed)/Manzil
/// (long-term review) breakdown, plus a rough total-minutes estimate.
class TodayBreakdown {
  const TodayBreakdown({
    required this.sabaqCount,
    required this.sabqiCount,
    required this.manzilCount,
    required this.estimatedMinutes,
    required this.easeBackActive,
  });

  final int sabaqCount;
  final int sabqiCount;
  final int manzilCount;
  final int estimatedMinutes;
  final bool easeBackActive;

  int get totalCount => sabaqCount + sabqiCount + manzilCount;

  static const empty = TodayBreakdown(
    sabaqCount: 0,
    sabqiCount: 0,
    manzilCount: 0,
    estimatedMinutes: 0,
    easeBackActive: false,
  );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dayKeyFor(DateTime d) {
  final dt = _dateOnly(d);
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

final todayBreakdownProvider = Provider<AsyncValue<TodayBreakdown>>((ref) {
  final planAsync = ref.watch(userPlanStreamProvider);
  final itemsAsync = ref.watch(srsItemsStreamProvider);
  final easeBackAsync = ref.watch(easeBackActiveProvider);

  if (planAsync.isLoading || itemsAsync.isLoading || easeBackAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (planAsync.hasError) {
    return AsyncValue.error(planAsync.error!, planAsync.stackTrace!);
  }
  if (itemsAsync.hasError) {
    return AsyncValue.error(itemsAsync.error!, itemsAsync.stackTrace!);
  }

  final plan = planAsync.value;
  final items = itemsAsync.value ?? const <SrsItem>[];
  final easeBackActive = easeBackAsync.value ?? false;
  if (plan == null) return const AsyncValue.data(TodayBreakdown.empty);

  final today = _dateOnly(DateTime.now());

  final dueRows = items.where(
    (i) => i.status != 'new' && i.dueDate != null && !i.dueDate!.isAfter(today),
  );
  final newRows = items.where((i) => i.status == 'new').toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

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

  final selectedKeys = portion.reviewItems.map((i) => i.contentKey).toSet();
  final selectedRows = dueRows.where((i) => selectedKeys.contains(i.contentKey));
  final sabqiCount =
      selectedRows.where((i) => i.status == 'learning' || i.status == 'lapsed').length;
  final manzilCount = selectedRows.where((i) => i.status == 'review').length;

  final reviewWords =
      portion.reviewItems.fold<int>(0, (sum, i) => sum + i.wordCount);
  final newWords = portion.newItems.fold<int>(0, (sum, i) => sum + i.wordCount);
  final estimatedMinutes = (sessionOverheadMinutes +
          reviewWords / reviewWpm +
          newWords / newWpm)
      .ceil();

  return AsyncValue.data(TodayBreakdown(
    sabaqCount: portion.newItemsPlanned,
    sabqiCount: sabqiCount,
    manzilCount: manzilCount,
    estimatedMinutes: estimatedMinutes,
    easeBackActive: easeBackActive,
  ));
});

/// Writes today's `daily_sessions` row (planned counts) the first time
/// it's computed each day; never overwrites an existing row, so adding
/// more material later the same day doesn't retroactively change what
/// was "planned" for a session already in progress.
final ensureDailySessionProvider = FutureProvider<void>((ref) async {
  final breakdown = ref.watch(todayBreakdownProvider);
  if (!breakdown.hasValue) return;

  final db = ref.watch(appDatabaseProvider);
  final dayKey = dayKeyFor(DateTime.now());

  final existing = await (db.select(db.dailySessions)
        ..where((t) => t.day.equals(dayKey)))
      .getSingleOrNull();
  if (existing != null) return;

  await db.into(db.dailySessions).insert(
        DailySessionsCompanion.insert(
          day: dayKey,
          newItemsPlanned: breakdown.value!.sabaqCount,
          reviewsPlanned: breakdown.value!.sabqiCount + breakdown.value!.manzilCount,
        ),
      );
});
