import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'storage_estimate.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

/// Before a multi-MB pack download on the PWA (M13.8): browsers can evict
/// IndexedDB/OPFS storage under pressure, and mobile Safari in particular
/// caps origin storage tightly, so a user downloading several hadith
/// collections could silently lose data later. Shows how much of the
/// origin's storage quota is already used and asks for confirmation.
/// Native builds have their own filesystem with no such quota dialog, and
/// non-web callers never hit the browser API at all — this always
/// resolves `true` immediately there.
Future<bool> confirmStorageBudget(
  BuildContext context, {
  required double estimatedMb,
  double warnAboveMb = 3,
}) async {
  if (!kIsWeb || estimatedMb < warnAboveMb) return true;

  final estimate = await estimateStorage();
  if (!context.mounted) return false;

  final usageMb = estimate == null ? null : estimate.usageBytes / 1e6;
  final quotaMb = estimate == null ? null : estimate.quotaBytes / 1e6;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).storageTitle(estimatedMb.toStringAsFixed(0))),
      content: Text(
        usageMb == null || quotaMb == null
            ? AppLocalizations.of(context).storageBodyUnknown
            : AppLocalizations.of(context).storageBody(
                usageMb.toStringAsFixed(0),
                quotaMb.toStringAsFixed(0),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context).commonDownload),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
