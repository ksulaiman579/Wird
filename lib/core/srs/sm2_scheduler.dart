/// Pure SM-2-variant spaced repetition scheduler. No Flutter imports —
/// plain Dart so it stays trivially unit-testable and reusable outside
/// the widget tree (see IMPLEMENTATION_PLAN.md's SRS design section).
library;

import '../calendar_math.dart';

/// Self-graded recall quality, mapped to the classic SM-2 "q" scale.
enum Grade { again, hard, good, easy }

extension GradeQ on Grade {
  /// The SM-2 quality value used in the ease-factor formula and logged
  /// verbatim to `review_logs.grade`.
  int get q => switch (this) {
        Grade.again => 1,
        Grade.hard => 3,
        Grade.good => 4,
        Grade.easy => 5,
      };
}

/// Where an item sits in the memorization lifecycle. Maps directly onto
/// the traditional hifz tiers: [learning] is Sabqi (recent revision),
/// [review] is Manzil (long-term revision).
enum ItemStatus { newItem, learning, review, lapsed }

const double _startingEaseFactor = 2.5;
const double _minEaseFactor = 1.3;
const int _maxIntervalDays = 365;
const int _graduateIntervalDays = 7;

/// Days-until-next-review for each step of the learning ladder. A brand
/// new item starts at step 0 (due later the same day it's introduced —
/// the actual same-session recall check happens in the M3 session flow,
/// before this scheduler is ever called); a lapsed item skips straight to
/// the 1-day step, since it was already memorized once before.
const List<int> _newLearningSteps = [0, 1, 3];
const List<int> _lapseLearningSteps = [1, 3];

class Sm2State {
  const Sm2State({
    required this.status,
    this.easeFactor = _startingEaseFactor,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.dueDate,
    this.learningStep = 0,
  });

  final ItemStatus status;
  final double easeFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime? dueDate;

  /// Index into [_newLearningSteps]/[_lapseLearningSteps] while
  /// [status] is [ItemStatus.learning] or [ItemStatus.lapsed].
  final int learningStep;

  static const Sm2State newItem = Sm2State(status: ItemStatus.newItem);

  Sm2State copyWith({
    ItemStatus? status,
    double? easeFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? dueDate,
    int? learningStep,
  }) {
    return Sm2State(
      status: status ?? this.status,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      dueDate: dueDate ?? this.dueDate,
      learningStep: learningStep ?? this.learningStep,
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Advances [current] by one grading event, returning the new state.
/// [now] should be the moment of grading — only its calendar date is used.
Sm2State schedule(Sm2State current, Grade grade, DateTime now) {
  final today = _dateOnly(now);

  switch (current.status) {
    case ItemStatus.newItem:
      return _scheduleLearning(
        current.copyWith(status: ItemStatus.learning, learningStep: 0),
        grade,
        today,
        _newLearningSteps,
      );
    case ItemStatus.learning:
      return _scheduleLearning(current, grade, today, _newLearningSteps);
    case ItemStatus.lapsed:
      return _scheduleLearning(current, grade, today, _lapseLearningSteps);
    case ItemStatus.review:
      return _scheduleReview(current, grade, today);
  }
}

Sm2State _scheduleLearning(
  Sm2State current,
  Grade grade,
  DateTime today,
  List<int> steps,
) {
  if (grade == Grade.again) {
    return current.copyWith(
      learningStep: 0,
      intervalDays: steps[0],
      dueDate: addCalendarDays(today, steps[0]),
    );
  }

  final nextStep = current.learningStep + 1;
  if (nextStep >= steps.length) {
    return current.copyWith(
      status: ItemStatus.review,
      intervalDays: _graduateIntervalDays,
      repetitions: 0,
      dueDate: addCalendarDays(today, _graduateIntervalDays),
    );
  }

  return current.copyWith(
    learningStep: nextStep,
    intervalDays: steps[nextStep],
    dueDate: addCalendarDays(today, steps[nextStep]),
  );
}

Sm2State _scheduleReview(Sm2State current, Grade grade, DateTime today) {
  if (grade == Grade.again) {
    final newEase = (current.easeFactor - 0.20).clamp(
      _minEaseFactor,
      double.infinity,
    );
    final interval = _lapseLearningSteps[0];
    return current.copyWith(
      status: ItemStatus.lapsed,
      easeFactor: newEase,
      learningStep: 0,
      intervalDays: interval,
      repetitions: 0,
      dueDate: addCalendarDays(today, interval),
    );
  }

  final q = grade.q;
  final easeDelta = 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02);
  final newEase =
      (current.easeFactor + easeDelta).clamp(_minEaseFactor, double.infinity);

  final gradeModifier = switch (grade) {
    Grade.hard => 0.8,
    Grade.good => 1.0,
    Grade.easy => 1.3,
    Grade.again => throw StateError('unreachable'),
  };

  final rawInterval = (current.intervalDays * newEase * gradeModifier).round();
  final interval = rawInterval
      .clamp(current.intervalDays + 1, _maxIntervalDays)
      .toInt();

  return current.copyWith(
    status: ItemStatus.review,
    easeFactor: newEase,
    intervalDays: interval,
    repetitions: current.repetitions + 1,
    dueDate: addCalendarDays(today, interval),
  );
}
