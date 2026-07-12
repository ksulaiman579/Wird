import 'package:flutter_test/flutter_test.dart';

import 'package:wird/features/onboarding/onboarding_state.dart';

void main() {
  test('scope derives from the two track toggles', () {
    expect(
      const OnboardingFormState(wantsQuran: true, wantsHadith: true).scope,
      'both',
    );
    expect(
      const OnboardingFormState(wantsQuran: true, wantsHadith: false).scope,
      'quran',
    );
    expect(
      const OnboardingFormState(wantsQuran: false, wantsHadith: true).scope,
      'hadith',
    );
  });

  test('hasValidScope requires at least one track', () {
    expect(
      const OnboardingFormState(wantsQuran: false, wantsHadith: false)
          .hasValidScope,
      isFalse,
    );
    expect(
      const OnboardingFormState(wantsQuran: true, wantsHadith: false)
          .hasValidScope,
      isTrue,
    );
  });

  test('hasValidQuranSelection is always true for "whole"', () {
    const state = OnboardingFormState(quranSelectionType: 'whole');
    expect(state.hasValidQuranSelection, isTrue);
  });

  test('hasValidQuranSelection requires a non-empty pick for juz/surahs', () {
    const empty = OnboardingFormState(quranSelectionType: 'juz');
    expect(empty.hasValidQuranSelection, isFalse);

    final withJuz = empty.copyWith(selectedJuz: [1, 2]);
    expect(withJuz.hasValidQuranSelection, isTrue);
  });

  test('hasValidQuranSelection is vacuously true when Quran is not wanted',
      () {
    const state = OnboardingFormState(
      wantsQuran: false,
      quranSelectionType: 'juz',
    );
    expect(state.hasValidQuranSelection, isTrue);
  });

  test('quranSelectionIds picks the list matching the selection type', () {
    final surahs = const OnboardingFormState(quranSelectionType: 'surahs')
        .copyWith(selectedSurahs: [1, 2], selectedJuz: [9, 9, 9]);
    expect(surahs.quranSelectionIds, [1, 2]);

    final juz = const OnboardingFormState(quranSelectionType: 'juz')
        .copyWith(selectedSurahs: [9, 9, 9], selectedJuz: [1, 2]);
    expect(juz.quranSelectionIds, [1, 2]);
  });

  test('copyWith only changes the given fields', () {
    const original = OnboardingFormState(name: 'A', dailyMinutes: 10);
    final updated = original.copyWith(dailyMinutes: 20);

    expect(updated.name, 'A');
    expect(updated.dailyMinutes, 20);
  });
}
