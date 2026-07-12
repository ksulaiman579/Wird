import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/audio/download_plan.dart';

void main() {
  final allSurahs = {1: 7, 2: 286, 114: 6};

  test('scope "plan" only includes the plan\'s surahs', () {
    final plan = buildDownloadPlan(
      scope: 'plan',
      ayahCountsBySurah: allSurahs,
      planSurahs: {1, 114},
    );

    expect(plan.map((p) => p.surah), [1, 114]);
    expect(plan.firstWhere((p) => p.surah == 1).ayahCount, 7);
  });

  test('scope "full" includes every surah, sorted ascending', () {
    final plan = buildDownloadPlan(scope: 'full', ayahCountsBySurah: allSurahs);

    expect(plan.map((p) => p.surah), [1, 2, 114]);
  });

  test('averageBytesPerAyah is smaller for a 64kbps reciter than 128kbps', () {
    final at64 = averageBytesPerAyah('Abdul_Basit_Murattal_64kbps');
    final at128 = averageBytesPerAyah('Husary_128kbps');

    expect(at64, lessThan(at128));
    expect(at64, greaterThan(0));
  });

  test('estimatedBytes scales with ayah count', () {
    const single = SurahDownloadPlan(surah: 1, ayahCount: 1);
    const double_ = SurahDownloadPlan(surah: 1, ayahCount: 2);

    expect(
      double_.estimatedBytes('Husary_128kbps'),
      single.estimatedBytes('Husary_128kbps') * 2,
    );
  });

  test('totalEstimatedBytes sums every surah in the plan', () {
    final plan = buildDownloadPlan(scope: 'full', ayahCountsBySurah: allSurahs);
    final total = totalEstimatedBytes(plan, 'Husary_128kbps');
    final manualSum =
        plan.fold<int>(0, (sum, p) => sum + p.estimatedBytes('Husary_128kbps'));

    expect(total, manualSum);
    expect(total, greaterThan(0));
  });
}
