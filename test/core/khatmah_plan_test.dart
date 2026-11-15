import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/khatmah/khatmah_plan.dart';

void main() {
  List<(AyahRef, int)> ayahs(List<int> weights) => [
        for (var i = 0; i < weights.length; i++) (AyahRef(1, i + 1), weights[i]),
      ];

  test('covers every ayah once, in order, in the requested days', () {
    final list = ayahs(List.filled(100, 10));
    final plan = splitKhatmah(list, 7);
    expect(plan, hasLength(7));
    expect(plan.first.start, const AyahRef(1, 1));
    expect(plan.last.end, const AyahRef(1, 100));
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].start.ayah, plan[i - 1].end.ayah + 1);
    }
  });

  test('portions are about equal by weight', () {
    final list = ayahs([for (var i = 0; i < 300; i++) 1 + (i % 7) * 5]);
    final plan = splitKhatmah(list, 10);
    final weights = [
      for (final p in plan)
        list
            .where((a) => a.$1.ayah >= p.start.ayah && a.$1.ayah <= p.end.ayah)
            .fold<int>(0, (s, a) => s + a.$2),
    ];
    final avg = weights.reduce((a, b) => a + b) / weights.length;
    for (final w in weights) {
      expect((w - avg).abs() / avg, lessThan(0.15));
    }
  });

  test('more days than ayahs gives one ayah per day', () {
    final plan = splitKhatmah(ayahs([5, 5, 5]), 10);
    expect(plan, hasLength(3));
  });

  test('day number and link round-trip', () {
    final start = DateTime(2027, 2, 18);
    expect(khatmahDayFor(start, 30, DateTime(2027, 2, 18, 23)), 1);
    expect(khatmahDayFor(start, 30, DateTime(2027, 3, 19)), 30);
    expect(khatmahDayFor(start, 30, DateTime(2027, 3, 20)), isNull);
    expect(khatmahDayFor(start, 30, DateTime(2027, 2, 17)), isNull);
    expect(khatmahQuery(start, 30), 'start=2027-02-18&days=30');
    expect(parseKhatmahQuery('2027-02-18', '30'), (start, 30));
    expect(parseKhatmahQuery('nope', '30'), isNull);
    expect(parseKhatmahQuery('2027-02-18', '0'), isNull);
  });
}
