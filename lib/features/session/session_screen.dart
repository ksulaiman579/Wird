import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/glass/glass.dart';
import 'celebration_screen.dart';
import 'new_material_flow.dart';
import 'review_with_exercise.dart';
import 'session_controller.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(sessionControllerProvider, (previous, next) {
      final newlyUnlocked = next.value?.newlyUnlockedAchievements ?? const [];
      if (newlyUnlocked.isEmpty) return;
      final names = newlyUnlocked.map((r) => r.title).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context).sessionAchievementUnlocked(names))),
      );
    });

    final sessionAsync = ref.watch(sessionControllerProvider);

    return sessionAsync.when(
      loading: () =>
          const GlassScaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => GlassScaffold(
          body: Center(
              child: Text(
                  AppLocalizations.of(context).commonFailedToLoad('$error')))),
      data: (session) {
        final current = session.current;
        if (current == null) {
          final streak = session.justCompletedStreak;
          if (streak != null) {
            return CelebrationScreen(
              streakCount: streak,
              onContinue: () => context.pop(),
            );
          }
          return GlassScaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).sessionNothingToDo),
            ),
          );
        }

        return GlassScaffold(
          appBar: GlassAppBar(title: Text(AppLocalizations.of(context).sessionTitle)),
          body: switch (current.phase) {
            SessionItemPhase.newItem => NewMaterialFlow(
                key: ValueKey(current.srsItem.contentKey),
                item: current.srsItem,
                onGraded: (grade) => ref
                    .read(sessionControllerProvider.notifier)
                    .gradeCurrent(grade),
              ),
            SessionItemPhase.review => ReviewWithExercise(
                key: ValueKey(current.srsItem.contentKey),
                item: current.srsItem,
                onGraded: (grade) => ref
                    .read(sessionControllerProvider.notifier)
                    .gradeCurrent(grade),
              ),
          },
        );
      },
    );
  }
}
