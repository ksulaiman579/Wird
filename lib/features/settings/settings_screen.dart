import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/audio/ayah_audio_urls.dart' show reciters;
import '../../core/backup/backup_service.dart';
import '../../core/backup/reset_service.dart';
import '../../core/db/database.dart';
import '../../core/prefs/app_language_provider.dart';
import '../../core/update/app_update_service.dart';
import '../update/update_ui.dart';
import '../../core/notifications/notification_prefs.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/notifications/prayer_method_prefs.dart';
import '../../core/notifications/prayer_times_service.dart' show PrayerTimeSource, calculationMethodNames;
import '../../core/theme/app_theme.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/palette_provider.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../shared/glass/glass.dart';
import '../../shared/widgets/location_section.dart';
import '../today/today_providers.dart' show userPlanStreamProvider;
import 'plan_prefs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// Plays the bundled adhan asset so the user can hear it before enabling
/// prayer reminders. Shows a persistent "Stop" SnackBar action so the
/// preview is tap-to-silenceable (U9); the player is disposed on stop, on
/// completion, or when the SnackBar is dismissed.
Future<void> _previewAdhan(BuildContext context) async {
  final player = AudioPlayer();
  final messenger = ScaffoldMessenger.of(context);
  var disposed = false;
  Future<void> stop() async {
    if (disposed) return;
    disposed = true;
    await player.stop();
    await player.dispose();
  }

  player.playerStateStream.listen((s) {
    if (s.processingState == ProcessingState.completed) {
      messenger.hideCurrentSnackBar();
      stop();
    }
  });
  try {
    await player.setAsset('assets/audio/adhan.ogg');
    await player.play();
    if (!context.mounted) {
      await stop();
      return;
    }
    final l = AppLocalizations.of(context);
    messenger
        .showSnackBar(
          SnackBar(
            content: Text(l.settingsPlayingAdhan),
            duration: const Duration(minutes: 5),
            action: SnackBarAction(label: l.commonStop, onPressed: stop),
          ),
        )
        .closed
        .then((_) => stop());
  } catch (e) {
    await stop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsPreviewError('$e'))),
      );
    }
  }
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _exporting = false;
  bool _resetting = false;

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await BackupService(db).exportViaShare();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).settingsExportError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx).commonContinue),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _confirmAndReset(ResetScope scope, String label) async {
    final l = AppLocalizations.of(context);
    final firstOk = await _confirm(
      l.settingsResetTitle(label),
      l.settingsResetFirstBody(label),
    );
    if (!firstOk || !mounted) return;

    final secondOk = await _confirm(
      l.settingsResetSure,
      l.settingsResetBody(label),
    );
    if (!secondOk || !mounted) return;

    setState(() => _resetting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await BackupService(db).exportViaShare();
      await ResetService(db).reset(scope);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).settingsResetDone(label))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).settingsResetError('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  Future<void> _rescheduleBestEffort() async {
    try {
      await rescheduleNotifications(ref);
    } catch (_) {
      // Best-effort — see app.dart's _initNotifications for the rationale.
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(userPlanStreamProvider);
    final plan = planAsync.value;

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).settingsTitle)),
      body: ListView(
        children: [
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsLanguage,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const _LanguagePicker(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _UpdateTile(),
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsPlan, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (plan != null &&
                    (plan.scope == 'quran' || plan.scope == 'both'))
                  OutlinedButton(
                    onPressed: () => context.push('/settings/edit-plan'),
                    child: Text(AppLocalizations.of(context).planEditTitle),
                  )
                else
                  Text(
                    AppLocalizations.of(context).settingsNoQuranSelection,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).readerReciter, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (plan != null)
                  DropdownButton<String>(
                    value: plan.reciter,
                    isExpanded: true,
                    items: [
                      for (final entry in reciters.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => v == null ? null : setReciter(ref, v),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsTheme, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const _ThemeModePicker(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context).settingsColour, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const _PalettePicker(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsPrayerTimes, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const LocationSection(),
                const SizedBox(height: 8),
                const _PrayerMethodPicker(),
                const _PrayerSourceIndicator(),
              ],
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 16),
            GlassCard(
              enableBlur: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).settingsNotifications, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _NotificationsSection(onChanged: _rescheduleBestEffort),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            GlassCard(
              enableBlur: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).settingsNotifications, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).settingsWebNotifNote),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsBackup, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: _exporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: Text(AppLocalizations.of(context).settingsExportData),
                  onPressed: _exporting ? null : _exportData,
                ),
                // Cloud backup & account removed (Item 1.26): Wird is
                // offline-only. Backups are local export/import only.
                // Last automatic local backup (Item 1.27b).
                if (!kIsWeb)
                  FutureBuilder<DateTime?>(
                    future: BackupService(ref.read(appDatabaseProvider))
                        .lastLocalBackupAt(),
                    builder: (context, snap) {
                      final last = snap.data;
                      final text = last == null
                          ? AppLocalizations.of(context).settingsBackupsMonthly
                          : AppLocalizations.of(context).backupLastAuto(
                              '${last.year.toString().padLeft(4, '0')}-'
                              '${last.month.toString().padLeft(2, '0')}-'
                              '${last.day.toString().padLeft(2, '0')}');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(text,
                            style: Theme.of(context).textTheme.bodySmall),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            enableBlur: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).settingsResetProgress, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (scope, label) in [
                      (ResetScope.quran, AppLocalizations.of(context).quranTitle),
                      (ResetScope.hadith, AppLocalizations.of(context).navHadith),
                      (ResetScope.dua, AppLocalizations.of(context).duasTitle),
                    ])
                      OutlinedButton(
                        onPressed:
                            _resetting ? null : () => _confirmAndReset(scope, label),
                        child: Text(AppLocalizations.of(context).settingsResetChip(label)),
                      ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: _resetting
                          ? null
                          : () => _confirmAndReset(
                              ResetScope.full, AppLocalizations.of(context).commonAll),
                      child: Text(AppLocalizations.of(context).settingsResetEverything),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/settings/about'),
            child: Text(AppLocalizations.of(context).settingsAboutDataSources),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => context.push('/settings/logs'),
            icon: const Icon(Icons.bug_report_outlined, size: 18),
            label: Text(AppLocalizations.of(context).logsTitle),
          ),
        ],
      ),
    );
  }
}

/// "Check for updates" — Android-only (the PWA auto-updates). Re-runs the
/// update check and either offers the update or confirms up-to-date.
class _UpdateTile extends ConsumerStatefulWidget {
  const _UpdateTile();

  @override
  ConsumerState<_UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends ConsumerState<_UpdateTile> {
  bool _checking = false;

  @override
  Widget build(BuildContext context) {
    if (!ref.read(appUpdateServiceProvider).supportsInAppUpdate) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        enableBlur: false,
        onTap: _checking ? null : _check,
        child: Row(
          children: [
            const Icon(Icons.system_update_rounded),
            const SizedBox(width: 12),
            Expanded(
                child: Text(_checking ? l.updateChecking : l.updateCheck)),
            if (_checking)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final info = await ref.refresh(updateCheckProvider.future);
    if (!mounted) return;
    setState(() => _checking = false);
    if (info != null) {
      await promptAndInstallUpdate(context, ref, info);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).updateUpToDate)),
      );
    }
  }
}

/// UI-language switcher — changes the app's display language on the spot
/// (app.dart watches appLanguageProvider and updates MaterialApp.locale).
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider).value ?? 'en';
    return DropdownButton<String>(
      value: current,
      isExpanded: true,
      items: [
        for (final lang in supportedAppLanguages)
          DropdownMenuItem(
            value: lang.code,
            child: Text('${lang.flagEmoji}  ${lang.nativeName}',
                overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (code) {
        if (code != null) {
          ref.read(appLanguageProvider.notifier).setLanguage(code);
        }
      },
    );
  }
}

class _ThemeModePicker extends ConsumerWidget {
  const _ThemeModePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? AppThemeMode.system;

    return Wrap(
      spacing: 8,
      children: AppThemeMode.values.map((m) {
        final l = AppLocalizations.of(context);
        final label = switch (m) {
          AppThemeMode.system => l.themeSystem,
          AppThemeMode.light => l.themeLight,
          AppThemeMode.dark => l.themeDark,
          AppThemeMode.amoled => l.themeAmoled,
        };
        return ChoiceChip(
          label: Text(label),
          selected: mode == m,
          onSelected: (_) => ref.read(themeModeProvider.notifier).setMode(m),
        );
      }).toList(),
    );
  }
}

/// Curated emerald/gold palette swatches (M22.2). Each chip shows the
/// palette's emerald + gold as a split circle so the choice is visible.
class _PalettePicker extends ConsumerWidget {
  const _PalettePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(paletteProvider).value ?? defaultPalette;

    return Column(
      children: wirdPalettes.map((p) {
        final selected = p.id == current.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => ref.read(paletteProvider.notifier).setPalette(p),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    _SwatchDot(emerald: p.chromeLight, gold: p.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.name,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({required this.emerald, required this.gold});
  final Color emerald;
  final Color gold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: ClipOval(
        child: Row(
          children: [
            Expanded(child: ColoredBox(color: emerald)),
            Expanded(child: ColoredBox(color: gold)),
          ],
        ),
      ),
    );
  }
}

class _PrayerMethodPicker extends ConsumerWidget {
  const _PrayerMethodPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(prayerMethodOverrideProvider).value;

    return DropdownButton<int?>(
      value: override,
      isExpanded: true,
      hint: Text(AppLocalizations.of(context).settingsPrayerMethodAuto),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(AppLocalizations.of(context).settingsPrayerMethodAuto, overflow: TextOverflow.ellipsis),
        ),
        for (final entry in calculationMethodNames.entries)
          DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) async {
        await ref.read(prayerMethodOverrideProvider.notifier).setOverride(v);
        try {
          await rescheduleNotifications(ref);
        } catch (_) {
          // Best-effort — see app.dart's _initNotifications for the rationale.
        }
      },
    );
  }
}

class _PrayerSourceIndicator extends ConsumerWidget {
  const _PrayerSourceIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(prayerTimesPreviewProvider);
    final preview = previewAsync.value;

    if (preview == null) return const SizedBox.shrink();

    final sourceLabel = preview.source == PrayerTimeSource.online
        ? AppLocalizations.of(context).settingsPrayerMethodOnline
        : AppLocalizations.of(context).settingsPrayerMethodOffline;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        AppLocalizations.of(context).settingsSource(sourceLabel),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection({required this.onChanged});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    final prefs = prefsAsync.value ?? const NotificationPrefs();
    final notifier = ref.read(notificationPrefsProvider.notifier);

    Future<void> update(NotificationPrefs Function(NotificationPrefs) fn) async {
      await notifier.updatePrefs(fn);
      onChanged();
    }

    return Column(
      children: [
        SwitchListTile(
          title: Text(AppLocalizations.of(context).settingsDailyReminder),
          subtitle: Text(TimeOfDay(
            hour: prefs.dailyReminderHour,
            minute: prefs.dailyReminderMinute,
          ).format(context)),
          value: prefs.dailyReminderEnabled,
          onChanged: (v) => update((p) => p.copyWith(dailyReminderEnabled: v)),
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
              await update((p) => p.copyWith(
                    dailyReminderHour: picked.hour,
                    dailyReminderMinute: picked.minute,
                  ));
            }
          },
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).settingsMorningReminder),
          subtitle: Text(AppLocalizations.of(context).settingsMorningReminderDesc),
          value: prefs.adhkarMorningEnabled,
          onChanged: (v) => update((p) => p.copyWith(adhkarMorningEnabled: v)),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).settingsEveningReminder),
          subtitle: Text(AppLocalizations.of(context).settingsEveningReminderDesc),
          value: prefs.adhkarEveningEnabled,
          onChanged: (v) => update((p) => p.copyWith(adhkarEveningEnabled: v)),
        ),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).settingsStreakReminder),
          subtitle: Text(AppLocalizations.of(context).settingsStreakReminderDesc),
          value: prefs.streakAtRiskEnabled,
          onChanged: (v) => update((p) => p.copyWith(streakAtRiskEnabled: v)),
        ),
        const Divider(),
        ListTile(
          title: Text(AppLocalizations.of(context).settingsAdhanTone),
          subtitle: Text(prefs.adhanTone.displayName),
          trailing: const Icon(Icons.arrow_drop_down_rounded),
          onTap: () async {
            final picked = await showDialog<AdhanTone>(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: Text(AppLocalizations.of(ctx).settingsChooseAdhanTone),
                children: [
                  for (final tone in AdhanTone.values)
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(ctx).pop(tone),
                      child: Text(tone.displayName),
                    ),
                ],
              ),
            );
            if (picked != null) {
              await update((p) => p.copyWith(adhanTone: picked));
            }
          },
        ),
        if (prefs.adhanTone == AdhanTone.adhan)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(AppLocalizations.of(context).settingsPreviewAdhan),
                onPressed: () => _previewAdhan(context),
              ),
            ),
          ),
        if (prefs.adhanTone != AdhanTone.none) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              AppLocalizations.of(context).settingsRemindAdhanFor,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).prayerFajr),
            dense: true,
            value: prefs.adhanFajr,
            onChanged: (v) => update((p) => p.copyWith(adhanFajr: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).prayerDhuhr),
            dense: true,
            value: prefs.adhanDhuhr,
            onChanged: (v) => update((p) => p.copyWith(adhanDhuhr: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).prayerAsr),
            dense: true,
            value: prefs.adhanAsr,
            onChanged: (v) => update((p) => p.copyWith(adhanAsr: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).prayerMaghrib),
            dense: true,
            value: prefs.adhanMaghrib,
            onChanged: (v) => update((p) => p.copyWith(adhanMaghrib: v)),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).prayerIsha),
            dense: true,
            value: prefs.adhanIsha,
            onChanged: (v) => update((p) => p.copyWith(adhanIsha: v)),
          ),
        ],
        const Divider(),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).settingsUseManualTimes),
          value: prefs.useManualTimes,
          onChanged: (v) => update((p) => p.copyWith(useManualTimes: v)),
        ),
        if (prefs.useManualTimes)
          for (final row in <(String, int, NotificationPrefs Function(NotificationPrefs, int))>[
            (AppLocalizations.of(context).prayerFajr, prefs.manualFajrMinutes,
                (p, m) => p.copyWith(manualFajrMinutes: m)),
            (AppLocalizations.of(context).prayerDhuhr, prefs.manualDhuhrMinutes,
                (p, m) => p.copyWith(manualDhuhrMinutes: m)),
            (AppLocalizations.of(context).prayerAsr, prefs.manualAsrMinutes,
                (p, m) => p.copyWith(manualAsrMinutes: m)),
            (AppLocalizations.of(context).prayerMaghrib, prefs.manualMaghribMinutes,
                (p, m) => p.copyWith(manualMaghribMinutes: m)),
            (AppLocalizations.of(context).prayerIsha, prefs.manualIshaMinutes,
                (p, m) => p.copyWith(manualIshaMinutes: m)),
          ])
            ListTile(
              dense: true,
              title: Text(row.$1),
              trailing: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay(hour: row.$2 ~/ 60, minute: row.$2 % 60),
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay(hour: row.$2 ~/ 60, minute: row.$2 % 60),
                );
                if (picked != null) {
                  await update((p) =>
                      row.$3(p, picked.hour * 60 + picked.minute));
                }
              },
            ),
      ],
    );
  }
}
