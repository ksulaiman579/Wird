import 'dart:convert';

import 'package:http/http.dart' as http;

/// The same manifest the in-app updater reads (GitHub "latest release").
const updateManifestUrl =
    'https://github.com/ksulaiman579/Wird/releases/latest/download/update.json';

/// A tiny broadcast file the maintainer can edit to announce anything to all
/// users — no backend, just a JSON committed to the repo. Shape:
///   { "id": 1, "title": "…", "body": "…" }
/// Bump `id` to send a new one; `id: 0` (or missing) means "no announcement".
const announcementsUrl =
    'https://raw.githubusercontent.com/ksulaiman579/Wird/main/announcements.json';

class UpdateSignal {
  const UpdateSignal({
    required this.versionCode,
    required this.versionName,
    required this.notes,
  });
  final int versionCode;
  final String versionName;
  final String notes;
}

class Announcement {
  const Announcement({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;
}

/// Notify about an update only when the published build is newer than what's
/// installed AND newer than what we last told this user about (so the same
/// update never notifies twice).
bool shouldNotifyUpdate({
  required int installedCode,
  required int latestCode,
  required int lastNotifiedCode,
}) =>
    latestCode > installedCode && latestCode > lastNotifiedCode;

/// Notify about an announcement only when it's newer than the last one this
/// user saw (and not the sentinel `0`).
bool shouldNotifyAnnouncement({
  required int latestId,
  required int lastSeenId,
}) =>
    latestId > 0 && latestId > lastSeenId;

Future<UpdateSignal?> fetchUpdateSignal(http.Client client) async {
  try {
    final r = await client
        .get(Uri.parse(updateManifestUrl))
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final code = (j['versionCode'] as num?)?.toInt();
    if (code == null) return null;
    return UpdateSignal(
      versionCode: code,
      versionName: j['versionName'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
    );
  } catch (_) {
    return null;
  }
}

Future<Announcement?> fetchAnnouncement(http.Client client) async {
  try {
    final r = await client
        .get(Uri.parse(announcementsUrl))
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body) as Map<String, dynamic>;
    final id = (j['id'] as num?)?.toInt();
    if (id == null) return null;
    return Announcement(
      id: id,
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
    );
  } catch (_) {
    return null;
  }
}

/// Shared shared_preferences keys (used by both the background task and the
/// foreground announcement dialog so the two never double-fire).
const prefLastNotifiedUpdateCode = 'update_last_notified_code';
const prefLastSeenAnnouncementId = 'announcement_last_seen_id';
