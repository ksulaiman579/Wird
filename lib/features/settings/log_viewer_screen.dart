import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/diagnostics/debug_log.dart';
import '../../shared/glass/glass.dart';

/// On-device log/error viewer (Settings → Diagnostics). Lets a tester read
/// recent logs and captured errors and share them for troubleshooting,
/// without needing a computer or adb.
class LogViewerScreen extends StatelessWidget {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final log = DebugLog.instance;
    return GlassScaffold(
      contentPadding: EdgeInsets.zero,
      appBar: GlassAppBar(
        title: Text(AppLocalizations.of(context).logsTitle),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).commonCopy,
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: log.dump()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).logsCopied),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).commonShare,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () =>
                SharePlus.instance.share(ShareParams(text: log.dump())),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).commonClear,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: log.clear,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: log.revision,
        builder: (context, _) {
          final lines = log.lines;
          if (lines.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context).logsEmpty));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lines.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: SelectableText(
                lines[i],
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
