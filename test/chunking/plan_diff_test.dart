import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/chunking/plan_diff.dart';

PlanItem _item(String key, int order, {int words = 10}) =>
    PlanItem(contentKey: key, orderIndex: order, wordCount: words);

void main() {
  test('identical plans produce no adds or removes, everything reorders', () {
    final diff = diffPlan(
      existingContentKeys: ['q:1:1-2', 'q:1:3-4'],
      newItems: [_item('q:1:1-2', 0), _item('q:1:3-4', 1)],
    );

    expect(diff.toAdd, isEmpty);
    expect(diff.toRemoveContentKeys, isEmpty);
    expect(diff.toReorder.map((i) => i.contentKey), ['q:1:1-2', 'q:1:3-4']);
  });

  test('a shrunken selection removes the dropped items only', () {
    final diff = diffPlan(
      existingContentKeys: ['q:1:1-2', 'q:1:3-4', 'q:2:1-5'],
      newItems: [_item('q:1:1-2', 0), _item('q:1:3-4', 1)],
    );

    expect(diff.toRemoveContentKeys, ['q:2:1-5']);
    expect(diff.toAdd, isEmpty);
    expect(diff.toReorder, hasLength(2));
  });

  test('an expanded selection adds the new items only', () {
    final diff = diffPlan(
      existingContentKeys: ['q:1:1-2'],
      newItems: [_item('q:1:1-2', 0), _item('q:2:1-5', 1)],
    );

    expect(diff.toAdd.map((i) => i.contentKey), ['q:2:1-5']);
    expect(diff.toReorder.map((i) => i.contentKey), ['q:1:1-2']);
    expect(diff.toRemoveContentKeys, isEmpty);
  });

  test('a direction flip keeps every contentKey but changes orderIndex', () {
    final diff = diffPlan(
      existingContentKeys: ['q:1:1-2', 'q:2:1-5'],
      newItems: [_item('q:2:1-5', 0), _item('q:1:1-2', 1)],
    );

    expect(diff.toAdd, isEmpty);
    expect(diff.toRemoveContentKeys, isEmpty);
    final byKey = {for (final i in diff.toReorder) i.contentKey: i.orderIndex};
    expect(byKey['q:2:1-5'], 0);
    expect(byKey['q:1:1-2'], 1);
  });

  test('re-chunked word counts flow through on the reordered items', () {
    final diff = diffPlan(
      existingContentKeys: ['q:1:1-4'],
      newItems: [_item('q:1:1-4', 0, words: 25)],
    );

    expect(diff.toReorder.single.wordCount, 25);
  });
}
