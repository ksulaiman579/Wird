import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/update/update_signals.dart';

/// Foreground counterpart to the background poll: on app open, fetches the
/// announcements file and shows it once as a dialog if it's newer than the
/// last one this user saw. This is how PWA users (who can't run a background
/// isolate) receive announcements. Shares [prefLastSeenAnnouncementId] with
/// the background task so the two never double-show the same announcement.
Future<void> maybeShowAnnouncement(BuildContext context) async {
  final client = http.Client();
  final ann = await fetchAnnouncement(client);
  client.close();
  if (ann == null) return;

  final prefs = await SharedPreferences.getInstance();
  final lastSeen = prefs.getInt(prefLastSeenAnnouncementId) ?? 0;
  if (!shouldNotifyAnnouncement(latestId: ann.id, lastSeenId: lastSeen)) return;
  await prefs.setInt(prefLastSeenAnnouncementId, ann.id);

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(ann.title.isEmpty ? 'Wird' : ann.title),
      content: SingleChildScrollView(child: Text(ann.body)),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).commonDone),
        ),
      ],
    ),
  );
}
