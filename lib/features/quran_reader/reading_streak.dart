import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/gamification/streak_service.dart';

const readingStreakKey = 'quran_reading_streak';

/// The "normal Quran reading" streak — days the user opened and read in the
/// Quran reader — kept deliberately separate from the memorization/SRS streak
/// (`streak_state`). Reuses the pure [applyCompletion] logic; persisted as
/// SharedPreferences JSON so it needs no database migration.
class ReadingStreakNotifier extends AsyncNotifier<StreakState> {
  @override
  Future<StreakState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(readingStreakKey);
    if (raw == null) return StreakState.empty;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final lastMs = j['lastCompletedDay'] as int?;
    return StreakState(
      currentStreak: j['currentStreak'] as int? ?? 0,
      longestStreak: j['longestStreak'] as int? ?? 0,
      freezeTokens: j['freezeTokens'] as int? ?? 0,
      lastCompletedDay:
          lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
  }

  /// Record that the user read the Quran today. Idempotent within a calendar
  /// day (a repeat read the same day is a no-op), so it's safe to call on
  /// every page turn. Pass [now] in tests; defaults to the current date.
  Future<void> recordReadToday([DateTime? now]) async {
    final current = state.value ?? StreakState.empty;
    final updated = applyCompletion(current, now ?? DateTime.now());
    if (identical(updated, current)) return; // same-day repeat → nothing to save
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      readingStreakKey,
      jsonEncode({
        'currentStreak': updated.currentStreak,
        'longestStreak': updated.longestStreak,
        'freezeTokens': updated.freezeTokens,
        'lastCompletedDay': updated.lastCompletedDay?.millisecondsSinceEpoch,
      }),
    );
    state = AsyncData(updated);
  }
}

final readingStreakProvider =
    AsyncNotifierProvider<ReadingStreakNotifier, StreakState>(
  ReadingStreakNotifier.new,
);
