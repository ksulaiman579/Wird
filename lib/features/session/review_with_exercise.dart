import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/exercises/micro_exercises.dart';
import '../../core/srs/sm2_scheduler.dart' show Grade;
import 'micro_exercise_card.dart';
import 'review_flow.dart';
import 'session_content_provider.dart';

/// Wraps [ReviewFlow] with an optional Duolingo-style micro-exercise (M6.4)
/// shown first for Quran review items — [pickExerciseKind] deterministically
/// decides whether one appears at all, and if so which of the four kinds,
/// per item + calendar day. Hadith/dua items and items an exercise couldn't
/// be built for skip straight to the normal reveal/grade flow.
class ReviewWithExercise extends ConsumerStatefulWidget {
  ReviewWithExercise({
    super.key,
    required this.item,
    required this.onGraded,
    DateTime? now,
  }) : now = now ?? DateTime.now();

  final SrsItem item;
  final void Function(Grade grade) onGraded;
  final DateTime now;

  @override
  ConsumerState<ReviewWithExercise> createState() =>
      _ReviewWithExerciseState();
}

class _ReviewWithExerciseState extends ConsumerState<ReviewWithExercise> {
  bool _exerciseDone = false;

  @override
  Widget build(BuildContext context) {
    if (widget.item.contentType != 'quran' || _exerciseDone) {
      return ReviewFlow(item: widget.item, onGraded: widget.onGraded);
    }

    final contentAsync = ref.watch(sessionItemContentProvider(
      (widget.item.contentType, widget.item.contentKey),
    ));

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => ReviewFlow(item: widget.item, onGraded: widget.onGraded),
      data: (content) {
        final seed = exerciseSeedFor(widget.item.contentKey, widget.now);
        final kind = pickExerciseKind(
          seed,
          multiAyah: content.arabicSegments.length > 1,
        );
        if (kind == null) {
          return ReviewFlow(item: widget.item, onGraded: widget.onGraded);
        }
        return MicroExerciseCard(
          kind: kind,
          content: content,
          seed: seed,
          onDone: () => setState(() => _exerciseDone = true),
        );
      },
    );
  }
}
