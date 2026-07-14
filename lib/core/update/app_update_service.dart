import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// The app is self-distributed (not via a store), so it updates itself: it
/// checks a small JSON manifest published on the GitHub "latest release", and
/// if a newer build exists, downloads that release's APK and hands it to the
/// system installer. Android only — the PWA already auto-updates via its
/// service worker, and iOS can't sideload.
///
/// To publish an update: bump `version` in pubspec (e.g. 1.1.1+2), build the
/// APK, and create a GitHub release whose assets are `wird.apk` and an
/// `update.json` like:
///   { "versionCode": 2, "versionName": "1.1.1",
///     "notes": "What's new…",
///     "apkUrl": "https://github.com/ksulaiman579/Wird/releases/latest/download/wird.apk" }
const _manifestUrl =
    'https://github.com/ksulaiman579/Wird/releases/latest/download/update.json';

class UpdateInfo {
  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.notes,
    required this.apkUrl,
  });

  final String versionName;
  final int versionCode;
  final String notes;
  final String apkUrl;
}

class AppUpdateService {
  AppUpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get supportsInAppUpdate =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Returns update details if the latest published build is newer than the
  /// installed one, else null (also null off-Android, on network error, or if
  /// the manifest is missing/malformed — a failed check must never surface as
  /// an error to the user).
  Future<UpdateInfo?> checkForUpdate() async {
    if (!supportsInAppUpdate) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      final current = int.tryParse(info.buildNumber) ?? 0;
      final resp = await _client
          .get(Uri.parse(_manifestUrl))
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final latest = (json['versionCode'] as num?)?.toInt();
      final apkUrl = json['apkUrl'] as String?;
      if (latest == null || apkUrl == null || latest <= current) return null;
      return UpdateInfo(
        versionName: json['versionName'] as String? ?? '',
        versionCode: latest,
        notes: json['notes'] as String? ?? '',
        apkUrl: apkUrl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK to a temp file (reporting 0..1 progress) and opens it
  /// with the system package installer. The user then confirms the install
  /// (and, first time, grants "install unknown apps").
  Future<void> downloadAndInstall(
    String apkUrl, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wird-update.apk');
    final resp = await _client.send(http.Request('GET', Uri.parse(apkUrl)));
    final total = resp.contentLength ?? 0;
    var received = 0;
    final sink = file.openWrite();
    await for (final chunk in resp.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) onProgress?.call(received / total);
    }
    await sink.close();
    await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
  }
}

final appUpdateServiceProvider =
    Provider<AppUpdateService>((ref) => AppUpdateService());

/// One-shot update check (cached for the session). Watch it to show a banner;
/// `ref.refresh` it for a manual "check now".
final updateCheckProvider =
    FutureProvider<UpdateInfo?>((ref) => ref.watch(appUpdateServiceProvider).checkForUpdate());
