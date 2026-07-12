import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/exercises/micro_exercises.dart';

void main() {
  group('exerciseSeedFor', () {
    test('is deterministic for the same contentKey and day', () {
      final a = exerciseSeedFor('q:1:1-2', DateTime(2026, 7, 5, 9, 30));
      final b = exerciseSeedFor('q:1:1-2', DateTime(2026, 7, 5, 23, 59));
      expect(a, b);
    });

    test('varies with the day', () {
      final a = exerciseSeedFor('q:1:1-2', DateTime(2026, 7, 5));
      final b = exerciseSeedFor('q:1:1-2', DateTime(2026, 7, 6));
      expect(a, isNot(b));
    });

    test('varies with the contentKey', () {
      final a = exerciseSeedFor('q:1:1-2', DateTime(2026, 7, 5));
      final b = exerciseSeedFor('q:2:1-2', DateTime(2026, 7, 5));
      expect(a, isNot(b));
    });
  });

  group('pickExerciseKind', () {
    test('is deterministic for the same seed', () {
      expect(
        pickExerciseKind(42, multiAyah: true),
        pickExerciseKind(42, multiAyah: true),
      );
    });

    test('never returns orderAyahs when multiAyah is false', () {
      for (var seed = 0; seed < 200; seed++) {
        expect(
          pickExerciseKind(seed, multiAyah: false),
          isNot(MicroExerciseKind.orderAyahs),
        );
      }
    });

    test('returns null (skip) for some seeds and a real kind for others', () {
      final results = [for (var s = 0; s < 200; s++) pickExerciseKind(s, multiAyah: true)];
      expect(results.any((k) => k == null), true);
      expect(results.any((k) => k != null), true);
    });
  });

  group('buildNextWordTapExercise', () {
    const arabic = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    final pool = wordsOf('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ مَالِكِ يَوْمِ الدِّينِ');

    test('choices always contain the correct word exactly once', () {
      final exercise = buildNextWordTapExercise(
        arabicText: arabic,
        distractorPool: pool,
        seed: 7,
      )!;
      expect(exercise.choices, hasLength(3));
      expect(exercise.choices.where((c) => c == exercise.correctWord), hasLength(1));
      expect(exercise.promptWords, isNotEmpty);
    });

    test('is deterministic for the same seed', () {
      final a = buildNextWordTapExercise(arabicText: arabic, distractorPool: pool, seed: 3)!;
      final b = buildNextWordTapExercise(arabicText: arabic, distractorPool: pool, seed: 3)!;
      expect(a.correctWord, b.correctWord);
      expect(a.choices, b.choices);
    });

    test('returns null when the ayah has fewer than 2 words', () {
      expect(
        buildNextWordTapExercise(arabicText: 'وَاحِدَة', distractorPool: pool, seed: 1),
        isNull,
      );
    });

    test('returns null when the distractor pool is too small', () {
      expect(
        buildNextWordTapExercise(arabicText: arabic, distractorPool: const ['كَلِمَة'], seed: 1),
        isNull,
      );
    });
  });

  group('buildFillBlankExercise', () {
    const arabic = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    final pool = wordsOf('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ مَالِكِ يَوْمِ الدِّينِ');

    test('choices always contain the correct word exactly once', () {
      final exercise = buildFillBlankExercise(
        arabicText: arabic,
        distractorPool: pool,
        seed: 5,
      )!;
      expect(exercise.choices, hasLength(3));
      expect(exercise.choices.where((c) => c == exercise.correctWord), hasLength(1));
      expect(exercise.words[exercise.blankIndex], exercise.correctWord);
    });

    test('is deterministic for the same seed', () {
      final a = buildFillBlankExercise(arabicText: arabic, distractorPool: pool, seed: 9)!;
      final b = buildFillBlankExercise(arabicText: arabic, distractorPool: pool, seed: 9)!;
      expect(a.blankIndex, b.blankIndex);
      expect(a.choices, b.choices);
    });

    test('returns null when the distractor pool is too small', () {
      expect(
        buildFillBlankExercise(arabicText: arabic, distractorPool: const [], seed: 1),
        isNull,
      );
    });
  });

  group('buildFirstLetterExercise', () {
    test('scaffoldHints has one first-letter entry per word', () {
      final exercise = buildFirstLetterExercise(
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      )!;
      expect(exercise.scaffoldHints, hasLength(exercise.words.length));
      for (var i = 0; i < exercise.words.length; i++) {
        expect(exercise.scaffoldHints[i], exercise.words[i].substring(0, 1));
      }
    });

    test('returns null for empty text', () {
      expect(buildFirstLetterExercise(arabicText: '   '), isNull);
    });
  });

  group('buildOrderAyahsExercise', () {
    const ayahs = ['ayah one', 'ayah two', 'ayah three', 'ayah four'];

    test('shuffled order differs from the original', () {
      final exercise = buildOrderAyahsExercise(ayahs: ayahs, seed: 11)!;
      expect(exercise.shuffledAyahs, isNot(ayahs));
      expect(exercise.shuffledAyahs.toSet(), ayahs.toSet());
    });

    test('isCorrectOrder accepts the original order and rejects a shuffle', () {
      final exercise = buildOrderAyahsExercise(ayahs: ayahs, seed: 11)!;
      expect(exercise.isCorrectOrder(exercise.originalAyahs), true);
      expect(exercise.isCorrectOrder(exercise.shuffledAyahs), false);
    });

    test('returns null for fewer than 2 ayahs', () {
      expect(buildOrderAyahsExercise(ayahs: const ['only one'], seed: 1), isNull);
    });
  });
}
