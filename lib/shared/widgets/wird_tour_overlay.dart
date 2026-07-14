import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

/// The one-time "what's where" orientation shown the first time the app
/// shell mounts — a short carousel covering the mini-player and the Explore
/// hub. Shown once via a prefs flag in [AppShell]; never repeats. (The old
/// step 1 explained a swipe-to-reveal 6th nav tab, which was removed; the
/// five-tab bar is self-explanatory, so that step is gone — its now-obsolete
/// tourStep1* strings are intentionally left unused in the ARBs.)
Future<void> showWirdTourOverlay(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _WirdTourDialog(),
  );
}

class _TourStep {
  const _TourStep(this.title, this.body);
  final String title;
  final String body;
}

List<_TourStep> _tourSteps(AppLocalizations l) => [
      _TourStep(l.tourStep2Title, l.tourStep2Body),
      _TourStep(l.tourStep3Title, l.tourStep3Body),
    ];

class _WirdTourDialog extends StatefulWidget {
  const _WirdTourDialog();

  @override
  State<_WirdTourDialog> createState() => _WirdTourDialogState();
}

class _WirdTourDialogState extends State<_WirdTourDialog> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = _tourSteps(l);
    final step = steps[_index];
    final isLast = _index == steps.length - 1;

    // The pager row lives in `content` (bounded to the dialog width) rather
    // than `actions` — actions sit in an OverflowBar that gives children
    // unbounded width, which made a full-width spaceBetween Row overflow on
    // narrow (phone-width) viewports.
    return AlertDialog(
      title: Text(step.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.body),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: i == _index
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              FilledButton(
                onPressed: () {
                  if (isLast) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _index++);
                  }
                },
                child: Text(isLast ? l.commonGotIt : l.commonNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
