import '../db/database.dart';
import 'streak_service.dart';

/// [liveStreak] for the stored `streak_state` row — the number to show,
/// not the number last saved.
int liveStreakOf(StreakStateData? row, [DateTime? now]) {
  if (row == null) return 0;
  return liveStreak(
    StreakState(
      currentStreak: row.currentStreak,
      longestStreak: row.longestStreak,
      freezeTokens: row.freezeTokens,
      lastCompletedDay: row.lastCompletedDay,
    ),
    now ?? DateTime.now(),
  );
}
