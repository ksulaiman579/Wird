/// Assembles a day's memorization portion from due reviews + not-yet-
/// introduced new items, sized to the user's daily time budget. Pure Dart
/// — persisting the result to `daily_sessions` is the caller's job (the
/// Today screen / session controller in M2.5+), once the Drift database
/// is available to write to.
library;

/// Minimal, DB-agnostic view of an SRS item needed for planning.
class PlannableItem {
  const PlannableItem({
    required this.contentKey,
    required this.orderIndex,
    required this.wordCount,
    this.dueDate,
  });

  final String contentKey;
  final int orderIndex;
  final int wordCount;

  /// Only set for review-phase items (learning/review/lapsed); null for
  /// items still in `new` status.
  final DateTime? dueDate;
}

class DailyPortion {
  const DailyPortion({required this.reviewItems, required this.newItems});

  final List<PlannableItem> reviewItems;
  final List<PlannableItem> newItems;

  int get reviewsPlanned => reviewItems.length;
  int get newItemsPlanned => newItems.length;
}

const double newWpm = 3.0;
const double reviewWpm = 20.0;
const double sessionOverheadMinutes = 1.0;
const double reviewBudgetShare = 0.5;

/// [dueItems] should already be filtered to items whose `dueDate` is on or
/// before today; they are re-sorted here most-overdue-first (earliest due
/// date first). [availableNewItems] should be `status == new`, ordered by
/// `orderIndex` ascending. Items that don't fit today's budget are simply
/// left out — due reviews naturally carry over to the next day since their
/// `dueDate` doesn't change until they're graded, and new items stay
/// available for tomorrow since `orderIndex` order is stable.
/// [newBudgetMultiplier] scales just the new-material word budget (not
/// reviews) — used for ease-back mode's "halve new-material budget for 2
/// days after a 3+ day gap" rule (see `core/gamification/ease_back.dart`).
/// Defaults to 1.0 (no change).
DailyPortion planDailyPortion({
  required List<PlannableItem> dueItems,
  required List<PlannableItem> availableNewItems,
  required int dailyMinutes,
  double newBudgetMultiplier = 1.0,
}) {
  final usableMinutes = dailyMinutes - sessionOverheadMinutes;
  if (usableMinutes <= 0) {
    return const DailyPortion(reviewItems: [], newItems: []);
  }

  final sortedDue = [...dueItems]..sort((a, b) {
      final aDue = a.dueDate ?? DateTime(0);
      final bDue = b.dueDate ?? DateTime(0);
      return aDue.compareTo(bDue);
    });

  final reviewWordBudget = usableMinutes * reviewBudgetShare * reviewWpm;
  final selectedReviews = <PlannableItem>[];
  var reviewWordsUsed = 0;
  for (final item in sortedDue) {
    if (reviewWordsUsed + item.wordCount > reviewWordBudget &&
        selectedReviews.isNotEmpty) {
      break;
    }
    selectedReviews.add(item);
    reviewWordsUsed += item.wordCount;
    if (reviewWordsUsed >= reviewWordBudget) break;
  }

  final reviewMinutesUsed = reviewWordsUsed / reviewWpm;
  final newMinutesBudget = usableMinutes - reviewMinutesUsed;
  final newWordBudget = newMinutesBudget * newWpm * newBudgetMultiplier;

  final selectedNew = <PlannableItem>[];
  var newWordsUsed = 0;
  for (final item in availableNewItems) {
    final wouldExceed = newWordsUsed + item.wordCount > newWordBudget;
    // Always take at least one new item if any are available, even if a
    // single (long) item alone would exceed the nominal budget.
    if (wouldExceed && selectedNew.isNotEmpty) break;
    selectedNew.add(item);
    newWordsUsed += item.wordCount;
    if (newWordsUsed >= newWordBudget) break;
  }

  return DailyPortion(reviewItems: selectedReviews, newItems: selectedNew);
}

/// Rough, motivational estimate of how many days it would take to
/// introduce [totalWords] worth of new material at [dailyMinutes] a day,
/// ignoring review load (which starts light and grows gradually, so this
/// is optimistic — shown during onboarding before any real pace data
/// exists). Returns null if the budget is too small to make progress.
int? estimateDaysToComplete(int totalWords, int dailyMinutes) {
  final usableMinutes = dailyMinutes - sessionOverheadMinutes;
  if (usableMinutes <= 0) return null;

  final wordsPerDay = usableMinutes * newWpm;
  if (wordsPerDay <= 0) return null;

  return (totalWords / wordsPerDay).ceil();
}

/// Renders a day count as a friendly human span — a bare "2868 days" is
/// hard to picture, so long spans are expressed in years/months/weeks.
/// Pure and unit-tested; used by onboarding's pace estimate.
String humanizeDuration(int days) {
  if (days <= 0) return 'less than a day';
  if (days == 1) return '1 day';
  if (days < 14) return '$days days';
  if (days < 60) {
    final weeks = (days / 7).round();
    return '$weeks weeks';
  }
  if (days < 365) {
    final months = (days / 30.44).round();
    return months <= 1 ? 'about a month' : 'about $months months';
  }
  final years = days ~/ 365;
  final remDays = days - years * 365;
  final months = (remDays / 30.44).round();
  final y = years == 1 ? '1 year' : '$years years';
  if (months <= 0) return 'about $y';
  final m = months == 1 ? '1 month' : '$months months';
  return 'about $y, $m';
}
