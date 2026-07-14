import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/audio/ayah_audio_urls.dart' show defaultReciter;
import '../../core/backup/backup_service.dart';
import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/chunking/portion_planner.dart';
import '../../core/content/hadith_pack_repository.dart';
import '../../core/content/models/translation_pack_models.dart';
import '../../core/content/translation_pack_service.dart';
import '../../core/db/database.dart';
import '../../core/notifications/notification_prefs.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/prefs/app_language_provider.dart';
import '../../shared/glass/glass.dart';
import '../../shared/widgets/location_section.dart';
import '../downloads/download_providers.dart';
import '../quran_browser/quran_providers.dart';
import '../quran_reader/reader_prefs.dart';
import 'onboarding_controller.dart';
import 'onboarding_state.dart';

const _juzCount = 30;
const _surahCount = 114;
const _dailyMinutePresets = [5, 10, 15, 20, 30, 45, 60, 90, 120];

String _formatMinutesLabel(AppLocalizations l, int minutes) {
  if (minutes >= 60) {
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return l.durationHr(hrs);
    return l.durationHrMin(hrs, mins);
  }
  return l.durationMin(minutes);
}

/// Localized mirror of [humanizeDuration] (which stays the English source of
/// truth + unit test) for the onboarding pace estimate. Same buckets, but the
/// units resolve per locale and order correctly under RTL.
String _humanizeDurationLocalized(AppLocalizations l, int days) {
  if (days <= 0) return l.durationLessThanDay;
  if (days < 14) return l.durationDaysValue(days);
  if (days < 60) return l.durationWeeksValue((days / 7).round());
  if (days < 365) {
    final months = (days / 30.44).round();
    return l.durationAboutMonth(months <= 1 ? 1 : months);
  }
  final years = days ~/ 365;
  final remDays = days - years * 365;
  final months = (remDays / 30.44).round();
  final y = l.durationYearsValue(years);
  if (months <= 0) return l.durationAbout(y);
  return l.durationAboutTwo(y, l.durationMonthsValue(months));
}

/// Approximate combined Arabic+English download size per collection —
/// measured directly against the upstream CDN (M13.6), not fetched live
/// at onboarding time (that would mean a network round trip just to show
/// a number). Close enough for a "here's roughly how much this costs"
/// warning; the real transferred size is confirmed once downloaded.
const hadithCollectionSizeMb = <String, double>{
  'bukhari': 13.6,
  'muslim': 11.7,
  'abudawud': 9.7,
  'tirmidhi': 8.7,
  'nasai': 9.3,
  'ibnmajah': 7.2,
  'malik': 3.4,
};

/// Onboarding-only, session-scoped — which downloadable Hadith collections
/// the user picked on the final step (M13.6). Not persisted: once
/// onboarding completes and the downloads are kicked off, this selection
/// has done its job (further add/remove happens from the Library screen
/// per M13.7).
class SelectedHadithCollectionsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String collection) {
    final next = {...state};
    if (!next.add(collection)) next.remove(collection);
    state = next;
  }
}

final selectedHadithCollectionsProvider =
    NotifierProvider<SelectedHadithCollectionsNotifier, Set<String>>(
  SelectedHadithCollectionsNotifier.new,
);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _pageIndex = 0;
  bool _completing = false;

  static const _stepCount = 8;

  static const _disclaimerSeenKey = 'offline_disclaimer_seen';

  @override
  void initState() {
    super.initState();
    // First-boot disclaimer (M22.6): make it explicit that Wird is
    // offline-first and any Al-Manhaj sign-in is optional + one-time.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDisclaimer());
  }

  Future<void> _maybeShowDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_disclaimerSeenKey) ?? false) return;
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).obDisclaimerTitle),
        content: Text(AppLocalizations.of(context).obDisclaimerBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).commonGotIt),
          ),
        ],
      ),
    );
    await prefs.setBool(_disclaimerSeenKey, true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _completing = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
      await _rescheduleNotificationsBestEffort();
      _downloadSelectedLanguagePackBestEffort();
      _downloadSelectedHadithCollectionsBestEffort();
      if (mounted) context.go('/');
    } catch (e) {
      // M21.3: complete() failing used to leave the user silently stuck on
      // the final step (the juz-overlap data bug aborted its transaction
      // with no visible feedback). Surface it — and still rethrow so the
      // error isn't swallowed from logs/crash reporting.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).obFinishError('$e'))),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  /// Best-effort — a notification-scheduling failure (e.g. permission
  /// denied, or no plugin available at all in this test container) must
  /// never block onboarding from completing.
  Future<void> _rescheduleNotificationsBestEffort() async {
    try {
      await rescheduleNotifications(ref);
    } catch (_) {
      // See app.dart's _initNotifications for the same rationale.
    }
  }

  /// Fire-and-forget: if the user picked an additional-language edition
  /// on the final step, kick off its download in the background. Never
  /// awaited — a slow/failed download must not delay finishing onboarding
  /// (the Library screen lets the user retry later either way, per M13.7).
  void _downloadSelectedLanguagePackBestEffort() {
    final editionId = ref.read(readerPrefsProvider).value?.extraEditionId;
    if (editionId == null) return;

    unawaited(() async {
      try {
        final allowlist =
            await ref.read(translationPackServiceProvider).loadAllowlist();
        final matches = allowlist.editions.where((e) => e.id == editionId);
        if (matches.isEmpty) return;
        final entry = matches.first;
        await ref.read(translationPackServiceProvider).downloadAndInstall(entry);
      } catch (_) {
        // Best-effort — see above.
      }
    }());
  }

  /// Fire-and-forget, same rationale as the language-pack download: a
  /// slow/failed collection download must never block finishing
  /// onboarding. Runs each selected collection's download concurrently.
  void _downloadSelectedHadithCollectionsBestEffort() {
    final selected = ref.read(selectedHadithCollectionsProvider);
    final repo = ref.read(hadithPackRepositoryProvider);
    for (final collection in selected) {
      unawaited(repo.downloadAndInstall(collection).catchError((_) {}));
    }
  }

  /// Completes onboarding, then enqueues every Quran surah the freshly
  /// generated plan touches for offline download (native only — this step
  /// shows a simplified "not available on web" version there instead).
  Future<void> _finishAndDownload() async {
    setState(() => _completing = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();

      final db = ref.read(appDatabaseProvider);
      final items = await db.select(db.srsItems).get();
      final surahs = items
          .where((i) => i.contentType == 'quran')
          .map((i) => parseQuranContentKey(i.contentKey)?.surah)
          .whereType<int>()
          .toSet();

      if (surahs.isNotEmpty) {
        final meta = await ref.read(quranMetaProvider.future);
        final manager = ref.read(audioDownloadManagerProvider);
        for (final surahNumber in surahs) {
          final ayahCount = meta.surahs
              .firstWhere((s) => s.number == surahNumber)
              .ayahCount;
          await manager.enqueueSurah(
            surah: surahNumber,
            ayahs: [for (var a = 1; a <= ayahCount; a++) a],
            reciter: defaultReciter,
            wifiOnly: true,
          );
        }
      }

      await _rescheduleNotificationsBestEffort();
      _downloadSelectedLanguagePackBestEffort();
      _downloadSelectedHadithCollectionsBestEffort();
      if (mounted) context.go('/');
    } catch (e) {
      // Same surfacing as _finish — see the M21.3 note there.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).obFinishError('$e'))),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);

    return PopScope(
      canPop: _pageIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _pageIndex > 0 && !_completing) {
          _goTo(_pageIndex - 1);
        }
      },
      child: GlassScaffold(
        contentPadding: EdgeInsets.zero,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (_pageIndex > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: AppLocalizations.of(context).commonBack,
                      onPressed:
                          _completing ? null : () => _goTo(_pageIndex - 1),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (_pageIndex + 1) / _stepCount,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  _LanguageStep(onNext: () => _goTo(1)),
                  _WelcomeStep(onNext: () => _goTo(2)),
                  _ProfileStep(state: state, onNext: () => _goTo(3)),
                  _ScopeStep(state: state, onNext: () => _goTo(4)),
                  _QuranSelectionStep(state: state, onNext: () => _goTo(5)),
                  _DailyMinutesStep(state: state, onNext: () => _goTo(6)),
                  _NotificationsStep(onNext: () => _goTo(7)),
                  _DownloadOfferStep(
                    wantsHadith: state.wantsHadith,
                    completing: _completing,
                    onSkip: _finish,
                    onDownloadAndFinish: _finishAndDownload,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.children,
    required this.onNext,
    this.nextLabel,
    this.nextEnabled = true,
    this.busy = false,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback? onNext;
  final String? nextLabel;
  final bool nextEnabled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          // Flexible (not Expanded) so a short step's card hugs its content
          // instead of stretching to fill the screen with empty space —
          // long steps (pickers, lists) still get up to the available
          // height and scroll internally as before.
          Flexible(
            child: SingleChildScrollView(
              child: GlassCard(
                enableBlur: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (nextEnabled && !busy) ? onNext : null,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(nextLabel ?? AppLocalizations.of(context).commonNext),
            ),
          ),
          // Item D7: the final step writes the whole plan (6,236 rows on a
          // whole-Quran plan) which can take several seconds — a bare spinner
          // reads as frozen, so name what's happening.
          if (busy) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).obPreparingPlan,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCode = ref.watch(appLanguageProvider).value ?? 'en';

    return _StepScaffold(
      title: AppLocalizations.of(context).obLanguageTitle,
      onNext: onNext,
      children: [
        Text(AppLocalizations.of(context).obLanguageSubtitle),
        const SizedBox(height: 12),
        ...supportedAppLanguages.map((lang) {
          final isSelected = lang.code == currentCode;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ref.read(appLanguageProvider.notifier).setLanguage(lang.code);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      lang.flagEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.nativeName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                          Text(
                            lang.englishName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: AppLocalizations.of(context).obWelcomeTitle,
      onNext: onNext,
      children: [
        const Center(
          child: Image(
            image: AssetImage('assets/icon/logo_display.png'),
            width: 160,
            height: 160,
          ),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).obWelcomeBody),
      ],
    );
  }
}

class _ProfileStep extends ConsumerStatefulWidget {
  const _ProfileStep({required this.state, required this.onNext});

  final OnboardingFormState state;
  final VoidCallback onNext;

  @override
  ConsumerState<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends ConsumerState<_ProfileStep> {
  static const _emojiChoices = ['🕌', '📖', '🌙', '⭐', '🌿', '🕊️'];

  bool _restoring = false;

  Future<void> _restoreFromBackup() async {
    setState(() => _restoring = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final restored = await BackupService(db).importViaFilePicker();
      if (restored && mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).obRestoreFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return _StepScaffold(
      title: AppLocalizations.of(context).obNameTitle,
      onNext: widget.onNext,
      children: [
        TextField(
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context).obName),
          onChanged: (value) => controller.updateProfile(name: value),
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context).obPickIcon),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _emojiChoices.map((emoji) {
            return ChoiceChip(
              label: Text(emoji, style: const TextStyle(fontSize: 20)),
              selected: widget.state.avatarEmoji == emoji,
              onSelected: (_) => controller.updateProfile(avatarEmoji: emoji),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _restoring ? null : _restoreFromBackup,
          child: _restoring
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context).obRestoreBackup),
        ),
      ],
    );
  }
}

class _ScopeStep extends ConsumerWidget {
  const _ScopeStep({required this.state, required this.onNext});

  final OnboardingFormState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(onboardingControllerProvider.notifier);

    return _StepScaffold(
      title: AppLocalizations.of(context).obScopeTitle,
      onNext: onNext,
      nextEnabled: state.hasValidScope,
      children: [
        CheckboxListTile(
          title: Text(AppLocalizations.of(context).quranTitle),
          value: state.wantsQuran,
          onChanged: (v) => controller.updateScope(wantsQuran: v),
        ),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context).obScopeHadith),
          value: state.wantsHadith,
          onChanged: (v) => controller.updateScope(wantsHadith: v),
        ),
        const Divider(),
        CheckboxListTile(
          title: Text(AppLocalizations.of(context).obScopeAlsoDuas),
          subtitle: Text(AppLocalizations.of(context).obScopeAlsoDuasDesc),
          value: state.wantsDuas,
          onChanged: (v) => controller.updateScope(wantsDuas: v),
        ),
        if (!state.hasValidScope)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context).obScopeChooseOne,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class _QuranSelectionStep extends ConsumerWidget {
  const _QuranSelectionStep({required this.state, required this.onNext});

  final OnboardingFormState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.wantsQuran) {
      return _StepScaffold(
        title: AppLocalizations.of(context).obQuranSelTitle,
        onNext: onNext,
        children: [Text(AppLocalizations.of(context).obQuranSkip)],
      );
    }

    final controller = ref.read(onboardingControllerProvider.notifier);
    final l = AppLocalizations.of(context);

    return _StepScaffold(
      title: l.obQuranHowMuch,
      onNext: onNext,
      nextEnabled: state.hasValidQuranSelection,
      children: [
        RadioGroup<String>(
          groupValue: state.quranSelectionType,
          onChanged: (v) => controller.updateQuranSelection(selectionType: v),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text(l.planWholeQuran),
                value: 'whole',
              ),
              RadioListTile<String>(
                title: Text(l.planSpecificJuz),
                value: 'juz',
              ),
              RadioListTile<String>(
                title: Text(l.planSpecificSurahs),
                value: 'surahs',
              ),
            ],
          ),
        ),
        if (state.quranSelectionType == 'juz')
          _JuzPickerTrigger(
            selected: state.selectedJuz,
            onChanged: (ids) => controller.updateQuranSelection(selectedJuz: ids),
          ),
        if (state.quranSelectionType == 'surahs')
          _SurahPickerTrigger(
            selected: state.selectedSurahs,
            onChanged: (ids) =>
                controller.updateQuranSelection(selectedSurahs: ids),
          ),
        // Reversed order applies to surahs too (U2) — the explanatory note is
        // juz/whole-specific, so show it only there, but offer the toggle for
        // every multi-item selection.
        const SizedBox(height: 16),
        if (state.quranSelectionType != 'surahs')
          Text(
            l.obReversedNote,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        RadioGroup<String>(
          groupValue: state.direction,
          onChanged: (v) => controller.updateQuranSelection(direction: v),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text(l.planNormalOrder),
                value: 'normal',
              ),
              RadioListTile<String>(
                title: Text(l.planReversedOrder),
                value: 'reversed',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JuzPickerTrigger extends StatelessWidget {
  const _JuzPickerTrigger({
    required this.selected,
    required this.onChanged,
  });

  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await showDialog<List<int>>(
              context: context,
              builder: (context) => _JuzPickerDialog(initialSelected: selected),
            );
            if (result != null) onChanged(result);
          },
          icon: const Icon(Icons.list_alt),
          label: Text(
            selected.isEmpty
                ? AppLocalizations.of(context).obSelectJuz
                : AppLocalizations.of(context).obSelectedJuz(selected.length),
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected.map((j) {
              return InputChip(
                label: Text(AppLocalizations.of(context).commonJuzN(j)),
                onDeleted: () {
                  final next = [...selected]..remove(j);
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _JuzPickerDialog extends StatefulWidget {
  const _JuzPickerDialog({required this.initialSelected});

  final List<int> initialSelected;

  @override
  State<_JuzPickerDialog> createState() => _JuzPickerDialogState();
}

class _JuzPickerDialogState extends State<_JuzPickerDialog> {
  late final Set<int> _selected = {...widget.initialSelected};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).obSelectJuzTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == _juzCount) {
                        _selected.clear();
                      } else {
                        _selected.addAll(List.generate(_juzCount, (i) => i + 1));
                      }
                    }),
                    child: Text(_selected.length == _juzCount
                        ? AppLocalizations.of(context).commonClearAll
                        : AppLocalizations.of(context).commonSelectAll),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _juzCount,
                itemBuilder: (context, index) {
                  final juzNumber = index + 1;
                  final isChecked = _selected.contains(juzNumber);
                  return CheckboxListTile(
                    value: isChecked,
                    title: Text(AppLocalizations.of(context).commonJuzN(juzNumber)),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selected.add(juzNumber);
                        } else {
                          _selected.remove(juzNumber);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected.toList()..sort()),
                    child: Text(AppLocalizations.of(context).obDoneCount(_selected.length)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahPickerTrigger extends StatelessWidget {
  const _SurahPickerTrigger({
    required this.selected,
    required this.onChanged,
  });

  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await showDialog<List<int>>(
              context: context,
              builder: (context) => _SurahPickerDialog(initialSelected: selected),
            );
            if (result != null) onChanged(result);
          },
          icon: const Icon(Icons.menu_book),
          label: Text(
            selected.isEmpty
                ? AppLocalizations.of(context).obSelectSurahs
                : AppLocalizations.of(context).obSelectedSurahs(selected.length),
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected.map((s) {
              return InputChip(
                label: Text(AppLocalizations.of(context).commonSurahN(s)),
                onDeleted: () {
                  final next = [...selected]..remove(s);
                  onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _SurahPickerDialog extends ConsumerStatefulWidget {
  const _SurahPickerDialog({required this.initialSelected});

  final List<int> initialSelected;

  @override
  ConsumerState<_SurahPickerDialog> createState() => _SurahPickerDialogState();
}

class _SurahPickerDialogState extends ConsumerState<_SurahPickerDialog> {
  late final Set<int> _selected = {...widget.initialSelected};
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(quranMetaProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 560, maxWidth: 420),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).obSelectSurahsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == _surahCount) {
                        _selected.clear();
                      } else {
                        _selected.addAll(List.generate(_surahCount, (i) => i + 1));
                      }
                    }),
                    child: Text(_selected.length == _surahCount
                        ? AppLocalizations.of(context).commonClearAll
                        : AppLocalizations.of(context).commonSelectAll),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).obSearchSurah,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: metaAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(
                    child: Text(AppLocalizations.of(context).obErrorSurahs('$e'))),
                data: (meta) {
                  final filtered = meta.surahs.where((s) {
                    if (_search.isEmpty) return true;
                    return s.number.toString().contains(_search) ||
                        s.nameTransliterated.toLowerCase().contains(_search) ||
                        s.nameArabic.contains(_search);
                  }).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final surah = filtered[index];
                      final isChecked = _selected.contains(surah.number);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text('${surah.number}. ${surah.nameTransliterated}'),
                        subtitle: Text(surah.nameArabic),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selected.add(surah.number);
                            } else {
                              _selected.remove(surah.number);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selected.toList()..sort()),
                    child: Text(AppLocalizations.of(context).obDoneCount(_selected.length)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyMinutesStep extends ConsumerStatefulWidget {
  const _DailyMinutesStep({required this.state, required this.onNext});

  final OnboardingFormState state;
  final VoidCallback onNext;

  @override
  ConsumerState<_DailyMinutesStep> createState() => _DailyMinutesStepState();
}

class _DailyMinutesStepState extends ConsumerState<_DailyMinutesStep> {
  int? _estimatedDays;

  @override
  void initState() {
    super.initState();
    _loadEstimate();
  }

  Future<void> _loadEstimate() async {
    if (!widget.state.wantsQuran) return;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final totalWords = await controller.quranWordCountForSelection();
    if (mounted) {
      setState(() {
        _estimatedDays =
            estimateDaysToComplete(totalWords, widget.state.dailyMinutes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final l = AppLocalizations.of(context);

    return _StepScaffold(
      title: l.obTimeTitle,
      onNext: widget.onNext,
      children: [
        Center(
          child: Text(
            _formatMinutesLabel(l, widget.state.dailyMinutes),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: widget.state.dailyMinutes.clamp(5, 120).toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          label: _formatMinutesLabel(l, widget.state.dailyMinutes),
          onChanged: (val) {
            controller.updateDailyMinutes(val.round());
            _loadEstimate();
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dailyMinutePresets.map((minutes) {
            return ChoiceChip(
              label: Text(_formatMinutesLabel(l, minutes)),
              selected: widget.state.dailyMinutes == minutes,
              onSelected: (_) {
                controller.updateDailyMinutes(minutes);
                _loadEstimate();
              },
            );
          }).toList(),
        ),
        if (_estimatedDays != null) ...[
          const SizedBox(height: 16),
          Text(
            l.obPaceEstimate(_humanizeDurationLocalized(l, _estimatedDays!)),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _NotificationsStep extends ConsumerWidget {
  const _NotificationsStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    final prefs = prefsAsync.value ?? const NotificationPrefs();

    return _StepScaffold(
      title: AppLocalizations.of(context).obConsistentTitle,
      onNext: onNext,
      children: [
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              AppLocalizations.of(context).obNotifWeb,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else ...[
          SwitchListTile(
            title: Text(AppLocalizations.of(context).settingsDailyReminder),
            subtitle: Text(TimeOfDay(
              hour: prefs.dailyReminderHour,
              minute: prefs.dailyReminderMinute,
            ).format(context)),
            value: prefs.dailyReminderEnabled,
            onChanged: (v) => ref
                .read(notificationPrefsProvider.notifier)
                .updatePrefs((p) => p.copyWith(dailyReminderEnabled: v)),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).settingsReminderTime),
            trailing: const Icon(Icons.access_time_rounded),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: prefs.dailyReminderHour,
                  minute: prefs.dailyReminderMinute,
                ),
              );
              if (picked != null) {
                await ref.read(notificationPrefsProvider.notifier).updatePrefs(
                      (p) => p.copyWith(
                        dailyReminderHour: picked.hour,
                        dailyReminderMinute: picked.minute,
                      ),
                    );
              }
            },
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).settingsMorningReminder),
            subtitle: Text(AppLocalizations.of(context).obMorningReminderDesc),
            value: prefs.adhkarMorningEnabled,
            onChanged: (v) => ref
                .read(notificationPrefsProvider.notifier)
                .updatePrefs((p) => p.copyWith(adhkarMorningEnabled: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).settingsEveningReminder),
            subtitle: Text(AppLocalizations.of(context).obEveningReminderDesc),
            value: prefs.adhkarEveningEnabled,
            onChanged: (v) => ref
                .read(notificationPrefsProvider.notifier)
                .updatePrefs((p) => p.copyWith(adhkarEveningEnabled: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).settingsStreakReminder),
            subtitle: Text(AppLocalizations.of(context).settingsStreakReminderDesc),
            value: prefs.streakAtRiskEnabled,
            onChanged: (v) => ref
                .read(notificationPrefsProvider.notifier)
                .updatePrefs((p) => p.copyWith(streakAtRiskEnabled: v)),
          ),
          // Surface the adhan feature (5H/6A) at onboarding for
          // discoverability; per-salah tuning + tone preview stay in
          // Settings (Item 1.24). Toggling on enables the adhan for all
          // five prayers, off silences it.
          SwitchListTile(
            title: Text(AppLocalizations.of(context).obPrayerAdhan),
            subtitle: Text(AppLocalizations.of(context).obPrayerAdhanDesc),
            value: prefs.adhanTone == AdhanTone.adhan,
            onChanged: (v) => ref
                .read(notificationPrefsProvider.notifier)
                .updatePrefs((p) => p.copyWith(
                      adhanTone: v ? AdhanTone.adhan : AdhanTone.none,
                      adhanFajr: v,
                      adhanDhuhr: v,
                      adhanAsr: v,
                      adhanMaghrib: v,
                      adhanIsha: v,
                    )),
          ),
        ],
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: LocationSection(),
        ),
      ],
    );
  }
}

/// Native only — `background_downloader` has no web support, so the web
/// build shows a simplified message with just a Continue button instead of
/// the real download offer.
class _DownloadOfferStep extends StatelessWidget {
  const _DownloadOfferStep({
    required this.wantsHadith,
    required this.completing,
    required this.onSkip,
    required this.onDownloadAndFinish,
  });

  final bool wantsHadith;
  final bool completing;
  final VoidCallback onSkip;
  final VoidCallback onDownloadAndFinish;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _StepScaffold(
        title: AppLocalizations.of(context).obAllSet,
        nextLabel: AppLocalizations.of(context).commonFinish,
        busy: completing,
        onNext: onSkip,
        children: [
          Text(AppLocalizations.of(context).obWebAudioNote),
          const SizedBox(height: 16),
          const _LanguagePackPicker(),
          if (wantsHadith) ...[
            const SizedBox(height: 16),
            const _HadithCollectionPicker(),
          ],
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).obDownloadTitle,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).obDownloadDesc),
                  const SizedBox(height: 16),
                  const _LanguagePackPicker(),
                  if (wantsHadith) ...[
                    const SizedBox(height: 16),
                    const _HadithCollectionPicker(),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: completing ? null : onDownloadAndFinish,
              child: completing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context).obDownloadNow),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: completing ? null : onSkip,
              child: Text(AppLocalizations.of(context).obSkipForNow),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets the user pick ONE additional Quran translation language from the
/// vetted allowlist (M12.1, expanded to ~46 languages in M21.4) to
/// download in the background — entirely optional, skippable, and
/// resumable later from the Library screen (M13.7), so this never blocks
/// finishing onboarding. Rendered as a searchable, scrollable list
/// (chips stopped scaling past ~10 languages); "None" stays pinned on top.
class _LanguagePackPicker extends ConsumerWidget {
  const _LanguagePackPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowlistAsync = ref.watch(_editionsAllowlistProvider);
    final selectedId = ref.watch(readerPrefsProvider).value?.extraEditionId;

    return allowlistAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (allowlist) {
        String selectedLabel = AppLocalizations.of(context).commonNone;
        if (selectedId != null) {
          final found = allowlist.editions
              .where((e) => e.id == selectedId)
              .firstOrNull;
          if (found != null) {
            selectedLabel = found.language;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).obAddlTranslation,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).obAddlTranslationDesc),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _TranslationPickerDialog(
                    allowlist: allowlist,
                    initialSelectedId: selectedId,
                  ),
                );
              },
              icon: const Icon(Icons.translate),
              label: Text(AppLocalizations.of(context).obSelectTranslation(selectedLabel)),
            ),
          ],
        );
      },
    );
  }
}

class _TranslationPickerDialog extends ConsumerStatefulWidget {
  const _TranslationPickerDialog({
    required this.allowlist,
    required this.initialSelectedId,
  });

  final TranslationAllowlist allowlist;
  final String? initialSelectedId;

  @override
  ConsumerState<_TranslationPickerDialog> createState() =>
      _TranslationPickerDialogState();
}

class _TranslationPickerDialogState
    extends ConsumerState<_TranslationPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(readerPrefsProvider).value?.extraEditionId;
    final notifier = ref.read(readerPrefsProvider.notifier);

    final editions = widget.allowlist.editions
        .where((e) =>
            _query.isEmpty ||
            e.language.toLowerCase().contains(_query) ||
            e.author.toLowerCase().contains(_query))
        .toList()
      ..sort((a, b) => a.language.compareTo(b.language));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).obSelectTranslationTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).librarySearchLanguages,
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: editions.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(AppLocalizations.of(context).commonNone),
                      value: selectedId == null,
                      onChanged: (_) => notifier.updatePrefs(
                          (p) => p.copyWith(clearExtraEdition: true)),
                    );
                  }
                  final edition = editions[index - 1];
                  return CheckboxListTile(
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(edition.language),
                    subtitle: Text(
                      edition.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: selectedId == edition.id,
                    onChanged: (_) => notifier.updatePrefs(
                      (p) => p.copyWith(extraEditionId: edition.id),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).commonDone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _editionsAllowlistProvider =
    FutureProvider<TranslationAllowlist>((ref) {
  return ref.watch(translationPackServiceProvider).loadAllowlist();
});

/// Lets the user pick any number of the six downloadable Hadith
/// collections (M13.6) — shown with an approximate size, only when the
/// scope step (M13.4's earlier screen) selected Hadith. Entirely optional
/// and skippable; unselected collections stay reachable later from the
/// Hadith tab's shelf (M20.3) or the Library screen (M13.7).
class _HadithCollectionPicker extends ConsumerWidget {
  const _HadithCollectionPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedHadithCollectionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).obHadithCollections,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context).obHadithCollectionsDesc),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const _HadithCollectionPickerDialog(),
            );
          },
          icon: const Icon(Icons.library_books),
          label: Text(AppLocalizations.of(context).obSelectHadith(selected.length)),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selected.map((key) {
              return InputChip(
                label: Text(hadithCollections[key] ?? key),
                onDeleted: () => ref
                    .read(selectedHadithCollectionsProvider.notifier)
                    .toggle(key),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _HadithCollectionPickerDialog extends ConsumerWidget {
  const _HadithCollectionPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedHadithCollectionsProvider);
    final notifier = ref.read(selectedHadithCollectionsProvider.notifier);
    final entries = hadithCollections.entries.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).obSelectHadithTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isChecked = selected.contains(entry.key);
                  final sizeMb =
                      hadithCollectionSizeMb[entry.key]!.toStringAsFixed(0);

                  return CheckboxListTile(
                    value: isChecked,
                    title: Text(entry.value),
                    subtitle: Text('~$sizeMb MB'),
                    onChanged: (_) => notifier.toggle(entry.key),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).commonDone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
