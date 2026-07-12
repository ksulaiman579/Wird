import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'storage_estimate.dart';

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
      title: Text('Download ~${estimatedMb.toStringAsFixed(0)} MB?'),
      content: Text(
        usageMb == null || quotaMb == null
            ? 'This browser tab stores downloads in its own local storage, '
                'which the browser can evict under storage pressure.'
            : 'This browser tab is already using '
                '${usageMb.toStringAsFixed(0)} MB of its '
                '${quotaMb.toStringAsFixed(0)} MB storage quota. Browsers '
                'can evict this storage under pressure — continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Download'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
