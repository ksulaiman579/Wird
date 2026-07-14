import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/update/app_update_service.dart';

/// Shows the update details; on confirm, downloads the APK (with a progress
/// dialog) and hands it to the system installer.
Future<void> promptAndInstallUpdate(
  BuildContext context,
  WidgetRef ref,
  UpdateInfo info,
) async {
  final l = AppLocalizations.of(context);
  final proceed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.updateAvailableTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.updateAvailableBanner(info.versionName)),
          if (info.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(info.notes,
                style: Theme.of(dialogContext).textTheme.bodySmall),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l.updateLater),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l.updateNow),
        ),
      ],
    ),
  );
  if (proceed != true || !context.mounted) return;

  final progress = ValueNotifier<double>(0);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (progressContext) => AlertDialog(
      content: Row(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (_, v, _) => SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(value: v > 0 ? v : null),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(l.updateDownloading)),
        ],
      ),
    ),
  );
  try {
    await ref.read(appUpdateServiceProvider).downloadAndInstall(
          info.apkUrl,
          onProgress: (p) => progress.value = p,
        );
  } catch (_) {
    // swallow — the installer either launched or the download failed; either
    // way we just close the progress dialog below.
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    progress.dispose();
  }
}

/// A dismissible "update available" banner (shown on the home screen). Renders
/// nothing off-Android, while checking, or when already up to date.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final info = ref.watch(updateCheckProvider).value;
    if (info == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              Icon(Icons.system_update_rounded, color: scheme.onSecondaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.updateAvailableBanner(info.versionName),
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
              TextButton(
                onPressed: () => promptAndInstallUpdate(context, ref, info),
                child: Text(l.updateNow),
              ),
              IconButton(
                tooltip: l.updateLater,
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _dismissed = true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
