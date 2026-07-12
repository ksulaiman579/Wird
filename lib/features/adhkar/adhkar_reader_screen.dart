import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/content/models/dua_models.dart';
import '../../core/gamification/achievements.dart' show AchievementRule;
import '../../core/l10n/reading_locale.dart';
import '../../core/notifications/notification_plan.dart';
import '../../core/notifications/notification_providers.dart';
import '../../shared/glass/glass.dart';
import '../achievements/achievement_providers.dart';
import 'adhkar_providers.dart';
import '../../core/haptics.dart';

String completedPrefsKey(String period, DateTime day) {
  final dateStr =
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  return 'adhkar_completed_${period}_$dateStr';
}

class AdhkarReaderScreen extends ConsumerStatefulWidget {
  const AdhkarReaderScreen({super.key, required this.period});

  final String period;

  @override
  ConsumerState<AdhkarReaderScreen> createState() =>
      _AdhkarReaderScreenState();
}

class _AdhkarReaderScreenState extends ConsumerState<AdhkarReaderScreen> {
  final PageController _pageController = PageController();
  List<Dhikr> _items = [];
  List<int> _counts = [];
  bool _celebrated = false;
  bool? _alreadyCompletedToday;

  @override
  void initState() {
    super.initState();
    _checkCompletedToday();
  }

  Future<void> _checkCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = completedPrefsKey(widget.period, DateTime.now());
    setState(() => _alreadyCompletedToday = prefs.getBool(key) ?? false);
  }

  Future<void> _markCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = completedPrefsKey(widget.period, DateTime.now());
    await prefs.setBool(key, true);
    if (mounted) {
      setState(() => _alreadyCompletedToday = true);
    }
    _clearOngoingNotificationBestEffort();
  }

  /// M14.4: the ongoing adhkar notification for this period doesn't
  /// auto-dismiss (that's the point — it's a "not done yet today"
  /// marker), so completing it here needs to explicitly clear it.
  void _clearOngoingNotificationBestEffort() {
    if (kIsWeb) return;
    final channel = widget.period == 'morning'
        ? NotificationChannel.adhkarMorning
        : NotificationChannel.adhkarEvening;
    ref
        .read(notificationServiceProvider)
        .cancel(notificationIdFor(channel, 0))
        .catchError((_) {});
  }

  void _onTapDhikr(int index) {
    // Guard against malformed data: a dhikr with repetitions <= 0 would make
    // the card un-tappable (0 >= 0) and wedge the flow — no way to advance
    // past it (Item 1.9). Treat it as a single repetition.
    final repetitions = _items[index].repetitions <= 0
        ? 1
        : _items[index].repetitions;
    if (_counts[index] >= repetitions) return;
    Haptics.tick();
    setState(() => _counts[index]++);

    final done = _counts[index] >= repetitions;
    final allDone = List.generate(
      _items.length,
      (i) => _counts[i] >= _items[i].repetitions,
    ).every((d) => d);

    if (allDone && !_celebrated) {
      _celebrated = true;
      _completeAndCelebrate();
    } else if (done && index < _items.length - 1) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && _pageController.hasClients) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _completeAndCelebrate() async {
    await _markCompletedToday();

    // Best-effort: a failure evaluating achievements (e.g. the DB isn't
    // ready for some reason) must never block the completion celebration
    // itself, which is the important part of finishing today's adhkar.
    var newlyUnlocked = const <AchievementRule>[];
    try {
      newlyUnlocked = await evaluateAndUnlockAchievements(ref);
    } catch (_) {
      // Ignored — see above.
    }

    if (!mounted) return;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showCelebration(newlyUnlocked));
  }

  void _showCelebration(List<AchievementRule> newlyUnlocked) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).adhkarAllDone),
        content: Text(
          newlyUnlocked.isEmpty
              ? 'You have completed your ${widget.period} adhkar for today.'
              : 'You have completed your ${widget.period} adhkar for today.\n\n'
                  'Achievement unlocked: ${newlyUnlocked.map((r) => r.title).join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).commonClose),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setAsync = ref.watch(adhkarSetProvider);
    final title = widget.period == 'evening'
        ? AppLocalizations.of(context).exploreEveningAdhkarTitle
        : AppLocalizations.of(context).exploreMorningAdhkarTitle;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: AppLocalizations.of(context).adhkarMarkCompleted,
            onPressed: () {
              if (!_celebrated) {
                _celebrated = true;
                _completeAndCelebrate();
              }
            },
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      body: setAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load: $error')),
        data: (set) {
          final items = widget.period == 'evening' ? set.evening : set.morning;
          _items = items;
          if (_counts.length != items.length) {
            _counts = List.filled(items.length, 0);
          }

          if (_alreadyCompletedToday == true && !_celebrated) {
            return _AlreadyDoneView(
              period: widget.period,
              onRedo: () => setState(() => _alreadyCompletedToday = false),
            );
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final dhikr = items[index];
              return _DhikrCard(
                dhikr: dhikr,
                count: _counts[index],
                index: index,
                total: items.length,
                onTap: () => _onTapDhikr(index),
              );
            },
          );
        },
      ),
    );
  }
}

class _AlreadyDoneView extends StatelessWidget {
  const _AlreadyDoneView({required this.period, required this.onRedo});

  final String period;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          enableBlur: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text("You've completed today's $period adhkar."),
              const SizedBox(height: 16),
              GlassPill(
                enableBlur: false,
                onTap: onRedo,
                child: Text(AppLocalizations.of(context).adhkarReadAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.dhikr,
    required this.count,
    required this.index,
    required this.total,
    required this.onTap,
  });

  final Dhikr dhikr;
  final int count;
  final int index;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reps = dhikr.repetitions <= 0 ? 1 : dhikr.repetitions;
    final done = count >= reps;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        enableBlur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1} / $total',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    dhikr.arabic,
                    style: const TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: 22,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ),
            // Arabic UI: skip the Latin transliteration + English translation
            // (redundant for an Arabic reader).
            if (showLatinReadingAids(Localizations.localeOf(context))) ...[
              if (dhikr.transliteration != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dhikr.transliteration!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(dhikr.translation),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: GlassProgressRing(
                  progress: count / reps,
                  size: 72,
                  strokeWidth: 6,
                  center: done
                      ? const Icon(Icons.check_rounded, color: Colors.green)
                      : Text(
                          '$count/$reps',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
