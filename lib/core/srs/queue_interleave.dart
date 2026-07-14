/// Pure logic for ordering the initial SRS introduction queue across content
/// types. No Flutter/Drift imports — plain Dart so it stays unit-testable
/// (architecture guardrail: SRS logic lives in plain Dart with tests).
library;

/// One item to be seeded into the SRS queue, before an `orderIndex` is
/// assigned. Deliberately storage-agnostic (no Drift companion here).
class SeedItem {
  const SeedItem({
    required this.contentType,
    required this.contentKey,
    required this.wordCount,
  });

  final String contentType;
  final String contentKey;
  final int wordCount;
}

/// Interleave per-content-type queues (e.g. `[quran, hadith, dua]`) so every
/// selected type is represented from the *start* of the introduction order,
/// instead of one type being fully exhausted before the next begins.
///
/// Round-robin: one item from each non-empty queue per cycle, in the order the
/// queues are given (so with `[quran, hadith, dua]` a cycle introduces a Quran
/// portion, then a hadith, then a dua). Each queue keeps its own internal
/// order. Because the hadith/dua lists are short, they finish early and the
/// tail becomes pure Quran — but the learner meets all three from day one,
/// which is the intent. The queue order encodes priority and is easy to tune.
List<SeedItem> interleaveQueues(List<List<SeedItem>> queues) {
  final result = <SeedItem>[];
  final cursors = List<int>.filled(queues.length, 0);
  var advanced = true;
  while (advanced) {
    advanced = false;
    for (var q = 0; q < queues.length; q++) {
      if (cursors[q] < queues[q].length) {
        result.add(queues[q][cursors[q]]);
        cursors[q]++;
        advanced = true;
      }
    }
  }
  return result;
}
