import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/gamification/progress_stats.dart';

void main() {
  group('reviewAccuracy', () {
    test('returns null with no reviews yet', () {
      expect(reviewAccuracy(totalReviews: 0, againCount: 0), isNull);
    });

    test('is the fraction of non-Again reviews', () {
      expect(reviewAccuracy(totalReviews: 10, againCount: 2), 0.8);
      expect(reviewAccuracy(totalReviews: 4, againCount: 4), 0.0);
      expect(reviewAccuracy(totalReviews: 5, againCount: 0), 1.0);
    });
  });

  group('estimateCompletionDate', () {
    final now = DateTime(2026, 6, 1);

    test('null when nothing remains', () {
      expect(
        estimateCompletionDate(
          now: now,
          itemsRemaining: 0,
          itemsIntroducedSoFar: 10,
          daysSincePlanStarted: 5,
        ),
        isNull,
      );
    });

    test('null when there is no pace data yet', () {
      expect(
        estimateCompletionDate(
          now: now,
          itemsRemaining: 50,
          itemsIntroducedSoFar: 0,
          daysSincePlanStarted: 5,
        ),
        isNull,
      );
      expect(
        estimateCompletionDate(
          now: now,
          itemsRemaining: 50,
          itemsIntroducedSoFar: 10,
          daysSincePlanStarted: 0,
        ),
        isNull,
      );
    });

    test('projects forward from the observed items-per-day pace', () {
      // 10 items in 5 days = 2/day; 50 remaining -> 25 more days.
      final result = estimateCompletionDate(
        now: now,
        itemsRemaining: 50,
        itemsIntroducedSoFar: 10,
        daysSincePlanStarted: 5,
      );
      expect(result, now.add(const Duration(days: 25)));
    });

    test('rounds partial days up', () {
      // 3 items in 2 days = 1.5/day; 4 remaining -> ceil(2.666) = 3 days.
      final result = estimateCompletionDate(
        now: now,
        itemsRemaining: 4,
        itemsIntroducedSoFar: 3,
        daysSincePlanStarted: 2,
      );
      expect(result, now.add(const Duration(days: 3)));
    });
  });
}
