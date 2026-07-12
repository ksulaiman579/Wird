/// Pure Duolingo-style micro-exercise generation — no Flutter/DB import.
/// Every builder is deterministic given its [seed], so
/// [exerciseSeedFor]'s (contentKey, day) pairing means the same item shows
/// the same exercise instance for the rest of that day (no reshuffling on
/// rebuild) while still varying from one day to the next.
library;

import 'dart:math';

List<String> wordsOf(String arabic) =>
    arabic.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

/// Derives a deterministic seed from an item's content key and the
/// calendar day (year/month/day only — time-of-day doesn't matter).
///
/// Deliberately not `Object.hash`/`String.hashCode`: Dart randomizes the
/// string hash seed per VM instance, so those would pick a different
/// exercise every time the app restarts even for the same item on the same
/// day. FNV-1a below is a fixed, portable algorithm with no such seed.
int exerciseSeedFor(String contentKey, DateTime day) {
  final input = '$contentKey|${day.year}-${day.month}-${day.day}';
  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

enum MicroExerciseKind { nextWordTap, fillBlank, firstLetter, orderAyahs }

/// Deterministically picks which kind of exercise to show for [seed], or
/// null to skip the exercise entirely this time (shown roughly 1 in 4
/// review items, per the plan's "mixed into sessions" — not every single
/// one). [multiAyah] excludes [MicroExerciseKind.orderAyahs] when there's
/// only one ayah to order.
MicroExerciseKind? pickExerciseKind(int seed, {required bool multiAyah}) {
  final kinds = multiAyah
      ? MicroExerciseKind.values
      : MicroExerciseKind.values
          .where((k) => k != MicroExerciseKind.orderAyahs)
          .toList();
  // One extra "skip" slot per real kind, i.e. exercises appear roughly half
  // the time a review item is eligible for one.
  final slot = seed.abs() % (kinds.length * 2);
  if (slot >= kinds.length) return null;
  return kinds[slot];
}

List<String> _buildChoices({
  required String correctWord,
  required List<String> distractorPool,
  required Random random,
}) {
  final candidates =
      distractorPool.where((w) => w != correctWord).toSet().toList()
        ..shuffle(random);
  if (candidates.length < 2) return const [];
  final choices = [correctWord, candidates[0], candidates[1]];
  choices.shuffle(random);
  return choices;
}

class NextWordTapExercise {
  const NextWordTapExercise({
    required this.promptWords,
    required this.correctWord,
    required this.choices,
  });

  /// The words leading up to (but not including) the word to guess.
  final List<String> promptWords;
  final String correctWord;

  /// 3 shuffled choices, always containing [correctWord] exactly once.
  final List<String> choices;
}

/// Null if the ayah has fewer than 2 words, or [distractorPool] can't
/// supply 2 words distinct from the correct answer.
NextWordTapExercise? buildNextWordTapExercise({
  required String arabicText,
  required List<String> distractorPool,
  required int seed,
}) {
  final words = wordsOf(arabicText);
  if (words.length < 2) return null;

  final random = Random(seed);
  final targetIndex = 1 + random.nextInt(words.length - 1);
  final correctWord = words[targetIndex];

  final choices = _buildChoices(
    correctWord: correctWord,
    distractorPool: distractorPool,
    random: random,
  );
  if (choices.isEmpty) return null;

  return NextWordTapExercise(
    promptWords: words.sublist(0, targetIndex),
    correctWord: correctWord,
    choices: choices,
  );
}

class FillBlankExercise {
  const FillBlankExercise({
    required this.words,
    required this.blankIndex,
    required this.choices,
  });

  /// The full ayah, word by word — the caller renders [blankIndex] as a
  /// blank rather than the actual word.
  final List<String> words;
  final int blankIndex;
  String get correctWord => words[blankIndex];

  /// 3 shuffled choices, always containing [correctWord] exactly once.
  final List<String> choices;
}

/// Null if the ayah has no words, or [distractorPool] can't supply 2 words
/// distinct from the correct answer.
FillBlankExercise? buildFillBlankExercise({
  required String arabicText,
  required List<String> distractorPool,
  required int seed,
}) {
  final words = wordsOf(arabicText);
  if (words.isEmpty) return null;

  final random = Random(seed);
  final blankIndex = random.nextInt(words.length);
  final choices = _buildChoices(
    correctWord: words[blankIndex],
    distractorPool: distractorPool,
    random: random,
  );
  if (choices.isEmpty) return null;

  return FillBlankExercise(
    words: words,
    blankIndex: blankIndex,
    choices: choices,
  );
}

class FirstLetterExercise {
  const FirstLetterExercise({required this.words});

  final List<String> words;

  /// One scaffold token per word — its first character, so the user reads
  /// a skeleton of the ayah rather than the full text (active recall).
  List<String> get scaffoldHints => [for (final w in words) w.substring(0, 1)];
}

/// Null if the ayah has no words.
FirstLetterExercise? buildFirstLetterExercise({required String arabicText}) {
  final words = wordsOf(arabicText);
  if (words.isEmpty) return null;
  return FirstLetterExercise(words: words);
}

class OrderAyahsExercise {
  const OrderAyahsExercise({
    required this.originalAyahs,
    required this.shuffledAyahs,
  });

  final List<String> originalAyahs;
  final List<String> shuffledAyahs;

  bool isCorrectOrder(List<String> attempt) {
    if (attempt.length != originalAyahs.length) return false;
    for (var i = 0; i < attempt.length; i++) {
      if (attempt[i] != originalAyahs[i]) return false;
    }
    return true;
  }
}

/// Null if there are fewer than 2 ayahs to order.
OrderAyahsExercise? buildOrderAyahsExercise({
  required List<String> ayahs,
  required int seed,
}) {
  if (ayahs.length < 2) return null;

  final random = Random(seed);
  final shuffled = List<String>.from(ayahs);
  var attempts = 0;
  // Re-shuffle if we happen to land on the original order, so the exercise
  // is never trivially already-solved — bounded in case every ayah is
  // identical text, which would make a different order unreachable.
  do {
    shuffled.shuffle(random);
    attempts++;
  } while (_listEquals(shuffled, ayahs) && attempts < 10);

  return OrderAyahsExercise(originalAyahs: ayahs, shuffledAyahs: shuffled);
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
