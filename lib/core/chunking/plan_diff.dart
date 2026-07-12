/// Pure diff between a freshly re-generated Quran item list and the
/// `srs_items` rows currently on disk, keyed by `contentKey` — so editing
/// the plan's selection/direction never loses SM-2 progress on items that
/// still belong to the plan. No Flutter/DB import.
library;

class PlanItem {
  const PlanItem({
    required this.contentKey,
    required this.orderIndex,
    required this.wordCount,
  });

  final String contentKey;
  final int orderIndex;
  final int wordCount;
}

class PlanDiff {
  const PlanDiff({
    required this.toAdd,
    required this.toReorder,
    required this.toRemoveContentKeys,
  });

  /// Items in the new plan that don't exist yet — inserted fresh as `new`.
  final List<PlanItem> toAdd;

  /// Items that exist in both the old and new plan — only `orderIndex`/
  /// `wordCount` need updating (chunking can shift slightly); SM-2 state
  /// (status, easeFactor, dueDate, ...) is left untouched.
  final List<PlanItem> toReorder;

  /// contentKeys no longer in the new plan — removed, along with their
  /// review_logs.
  final List<String> toRemoveContentKeys;
}

PlanDiff diffPlan({
  required Iterable<String> existingContentKeys,
  required List<PlanItem> newItems,
}) {
  final existingSet = existingContentKeys.toSet();
  final newKeys = newItems.map((i) => i.contentKey).toSet();

  return PlanDiff(
    toAdd: newItems.where((i) => !existingSet.contains(i.contentKey)).toList(),
    toReorder:
        newItems.where((i) => existingSet.contains(i.contentKey)).toList(),
    toRemoveContentKeys:
        existingSet.where((k) => !newKeys.contains(k)).toList(),
  );
}
