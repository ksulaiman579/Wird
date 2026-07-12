/// Pure progress-screen math: review accuracy and a pace-based completion
/// estimate. No Flutter/DB import — `features/progress/progress_providers.dart`
/// assembles the DB-backed snapshot and calls into this.
library;

/// Fraction (0.0-1.0) of graded reviews that weren't "Again" (SM-2 q=1) —
/// a simple, understandable accuracy figure for the progress screen.
/// Returns null if there's no review history yet.
double? reviewAccuracy({required int totalReviews, required int againCount}) {
  if (totalReviews == 0) return null;
  return (totalReviews - againCount) / totalReviews;
}

/// Rough estimated completion date from real pace: [itemsRemaining]
/// divided by the actual introduced-items-per-day rate seen so far.
/// Returns null if there's no pace data yet (nothing introduced) or
/// nothing left to introduce.
DateTime? estimateCompletionDate({
  required DateTime now,
  required int itemsRemaining,
  required int itemsIntroducedSoFar,
  required int daysSincePlanStarted,
}) {
  if (itemsRemaining <= 0) return null;
  if (itemsIntroducedSoFar <= 0 || daysSincePlanStarted <= 0) return null;

  final itemsPerDay = itemsIntroducedSoFar / daysSincePlanStarted;
  if (itemsPerDay <= 0) return null;

  final daysRemaining = (itemsRemaining / itemsPerDay).ceil();
  return now.add(Duration(days: daysRemaining));
}
