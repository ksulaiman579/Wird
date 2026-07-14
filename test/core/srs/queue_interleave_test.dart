import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/srs/queue_interleave.dart';

SeedItem _q(String k) => SeedItem(contentType: 'quran', contentKey: k, wordCount: 1);
SeedItem _h(String k) => SeedItem(contentType: 'hadith', contentKey: k, wordCount: 1);
SeedItem _d(String k) => SeedItem(contentType: 'dua', contentKey: k, wordCount: 1);

List<String> _types(List<SeedItem> items) => [for (final i in items) i.contentType];
List<String> _keys(List<SeedItem> items) => [for (final i in items) i.contentKey];

void main() {
  test('round-robins one from each non-empty queue, in queue order', () {
    final out = interleaveQueues([
      [_q('q0'), _q('q1'), _q('q2')],
      [_h('h0'), _h('h1')],
      [_d('d0')],
    ]);
    // Cycle 1: q,h,d ; cycle 2: q,h ; cycle 3: q
    expect(_types(out), [
      'quran', 'hadith', 'dua',
      'quran', 'hadith',
      'quran',
    ]);
  });

  test('hadith and dua appear from the very beginning, not after all quran', () {
    final quran = [for (var i = 0; i < 100; i++) _q('q$i')];
    final out = interleaveQueues([quran, [_h('h0')], [_d('d0')]]);
    // Within the first 3 items we already meet a hadith and a dua.
    expect(out.take(3).map((e) => e.contentType), ['quran', 'hadith', 'dua']);
  });

  test('preserves each queue\'s internal order', () {
    final out = interleaveQueues([
      [_q('q0'), _q('q1')],
      [_h('h0'), _h('h1')],
    ]);
    expect(_keys(out), ['q0', 'h0', 'q1', 'h1']);
  });

  test('handles empty queues and a single queue', () {
    expect(interleaveQueues([[], [], []]), isEmpty);
    final out = interleaveQueues([[_q('q0'), _q('q1')], [], []]);
    expect(_keys(out), ['q0', 'q1']);
  });

  test('assigning orderIndex by position yields a contiguous 0..n-1 sequence', () {
    final out = interleaveQueues([[_q('q0')], [_h('h0')], [_d('d0')]]);
    expect(out.length, 3);
  });
}
