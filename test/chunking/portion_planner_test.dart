import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/chunking/portion_planner.dart';

PlannableItem _review(String key, int words, DateTime due) => PlannableItem(
      contentKey: key,
      orderIndex: 0,
      wordCount: words,
      dueDate: due,
    );

PlannableItem _newItem(String key, int order, int words) => PlannableItem(
      contentKey: key,
      orderIndex: order,
      wordCount: words,
    );

void main() {
  final today = DateTime(2026, 1, 10);

  test('always takes at least one new item if any are available', () {
    // 1 usable minute after overhead -> new word budget = 0 * 3 = 0 words,
    // yet a single new item must still be taken.
    final portion = planDailyPortion(
      dueItems: const [],
      availableNewItems: [_newItem('q:1:1', 0, 500)],
      dailyMinutes: 2,
    );

    expect(portion.newItems, hasLength(1));
    expect(portion.newItems.single.contentKey, 'q:1:1');
  });

  test('takes no items when the budget is entirely overhead', () {
    final portion = planDailyPortion(
      dueItems: [_review('q:1:1', 10, today)],
      availableNewItems: [_newItem('q:1:2', 0, 10)],
      dailyMinutes: 1, // == sessionOverheadMinutes, nothing usable left
    );

    expect(portion.reviewItems, isEmpty);
    expect(portion.newItems, isEmpty);
  });

  test('orders reviews most-overdue-first', () {
    final portion = planDailyPortion(
      dueItems: [
        _review('late', 10, DateTime(2026, 1, 5)),
        _review('early', 10, DateTime(2026, 1, 9)),
        _review('latest', 10, DateTime(2026, 1, 1)),
      ],
      availableNewItems: const [],
      dailyMinutes: 30,
    );

    expect(
      portion.reviewItems.map((i) => i.contentKey),
      ['latest', 'late', 'early'],
    );
  });

  test('caps reviews at roughly 50% of the usable budget', () {
    // 21 usable minutes (22 - 1 overhead) * 0.5 * REVIEW_WPM(20) = 210 words.
    final dueItems = List.generate(
      10,
      (i) => _review('r$i', 30, today), // 300 words total, well over budget
    );

    final portion = planDailyPortion(
      dueItems: dueItems,
      availableNewItems: const [],
      dailyMinutes: 22,
    );

    final totalWords =
        portion.reviewItems.fold<int>(0, (sum, i) => sum + i.wordCount);
    expect(totalWords, lessThanOrEqualTo(210));
    expect(portion.reviewItems.length, lessThan(dueItems.length));
  });

  test('spends the remainder of the budget on new items after reviews', () {
    // 21 usable minutes: reviews take a small slice, the rest goes to new.
    final portion = planDailyPortion(
      dueItems: [_review('r1', 20, today)], // 1 minute of review time
      availableNewItems: [
        _newItem('n1', 0, 15),
        _newItem('n2', 1, 15),
        _newItem('n3', 2, 15),
      ],
      dailyMinutes: 22,
    );

    expect(portion.reviewItems, hasLength(1));
    // 20 usable minutes remain for new material at NEW_WPM(3) = 60 words,
    // easily fitting all three 15-word items in orderIndex order.
    expect(
      portion.newItems.map((i) => i.contentKey),
      ['n1', 'n2', 'n3'],
    );
  });

  test('stops adding new items once the word budget is exceeded', () {
    final portion = planDailyPortion(
      dueItems: const [],
      availableNewItems: [
        _newItem('n1', 0, 10),
        _newItem('n2', 1, 10),
        _newItem('n3', 2, 10),
        _newItem('n4', 3, 10),
      ],
      dailyMinutes: 6, // 5 usable min * 3 wpm = 15 words
    );

    // n1 (10 words) fits; n1+n2 (20) would exceed the 15-word budget, so
    // n2 onward are left for tomorrow.
    expect(portion.newItems.map((i) => i.contentKey), ['n1']);
  });

  test('estimateDaysToComplete gives a rough day count', () {
    // 9 usable minutes * 3 wpm = 27 words/day; 270 words -> 10 days.
    expect(estimateDaysToComplete(270, 10), 10);
  });

  test('estimateDaysToComplete returns null when the budget is too small',
      () {
    expect(estimateDaysToComplete(1000, 1), isNull);
  });

  test('reviewsPlanned and newItemsPlanned reflect the selected counts', () {
    final portion = planDailyPortion(
      dueItems: [_review('r1', 10, today)],
      availableNewItems: [_newItem('n1', 0, 10)],
      dailyMinutes: 30,
    );

    expect(portion.reviewsPlanned, portion.reviewItems.length);
    expect(portion.newItemsPlanned, portion.newItems.length);
  });

  test('newBudgetMultiplier halves how many new items fit, leaving reviews '
      'untouched (ease-back mode)', () {
    final newItems = [
      for (var i = 0; i < 10; i++) _newItem('n$i', i, 30), // 30 words each
    ];
    final dueItems = [_review('r1', 10, today)];

    final normal = planDailyPortion(
      dueItems: dueItems,
      availableNewItems: newItems,
      dailyMinutes: 30,
    );
    final easedBack = planDailyPortion(
      dueItems: dueItems,
      availableNewItems: newItems,
      dailyMinutes: 30,
      newBudgetMultiplier: 0.5,
    );

    expect(easedBack.newItems.length, lessThan(normal.newItems.length));
    expect(easedBack.reviewItems.length, normal.reviewItems.length,
        reason: 'ease-back only halves the new-material budget');
  });

  group('humanizeDuration', () {
    test('short spans stay in days', () {
      expect(humanizeDuration(0), 'less than a day');
      expect(humanizeDuration(1), '1 day');
      expect(humanizeDuration(9), '9 days');
    });
    test('two weeks to two months → weeks', () {
      expect(humanizeDuration(14), '2 weeks');
      expect(humanizeDuration(21), '3 weeks');
    });
    test('under a year → months', () {
      expect(humanizeDuration(60), 'about 2 months');
      expect(humanizeDuration(180), 'about 6 months');
    });
    test('the whole-Quran-at-10-min case reads in years, not raw days', () {
      final s = humanizeDuration(2868);
      expect(s, isNot(contains('2868')));
      expect(s, contains('years'));
    });
    test('exact years drop the months clause', () {
      expect(humanizeDuration(365), 'about 1 year');
      expect(humanizeDuration(730), 'about 2 years');
    });
  });
}
