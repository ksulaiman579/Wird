import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';


import '../../shared/glass/glass.dart';
import '../../core/haptics.dart';

/// Shown once today's portion is fully completed — a brief celebration
/// (scale-in animation + haptic) with the updated streak count.
class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({
    super.key,
    required this.streakCount,
    required this.onContinue,
  });

  final int streakCount;
  final VoidCallback onContinue;

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    Haptics.success();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    return GlassScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: scale,
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 96,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _controller,
              child: Text(
                AppLocalizations.of(context).celebrationPortionComplete,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _controller,
              child: Text(
                AppLocalizations.of(context).celebrationStreak(widget.streakCount),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: widget.onContinue,
              child: Text(AppLocalizations.of(context).commonContinue),
            ),
          ],
        ),
      ),
    );
  }
}
