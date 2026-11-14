import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
///     "apkUrl": "https://github.com/ksulaiman579/Wird/releases/latest/download/wird.apk",
///     "sha256": "(hex sha256 of wird.apk)" }
/// `sha256` is optional for old manifests, but when present the download is
/// refused unless it matches.
const _manifestUrl =
    'https://github.com/ksulaiman579/Wird/releases/latest/download/update.json';

class UpdateInfo {
  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.notes,
    required this.apkUrl,
    this.sha256,
  });

  final String versionName;
  final int versionCode;
  final String notes;
  final String apkUrl;

  /// Expected hex sha256 of the APK, if the manifest gives one.
  final String? sha256;
}

class UpdateDownloadException implements Exception {
  UpdateDownloadException(this.message);
  final String message;
  @override
  String toString() => message;
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
        sha256: (json['sha256'] as String?)?.toLowerCase(),
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
    String? expectedSha256,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wird-update.apk');
    final resp = await _client
        .send(http.Request('GET', Uri.parse(apkUrl)))
        .timeout(const Duration(seconds: 30));
    // An error page must never reach the installer as an "APK" (M26.11).
    if (resp.statusCode != 200) {
      throw UpdateDownloadException('Download failed (HTTP ${resp.statusCode})');
    }
    final total = resp.contentLength ?? 0;
    var received = 0;
    final digestSink = _DigestSink();
    final hasher = sha256.startChunkedConversion(digestSink);
    final sink = file.openWrite();
    try {
      // A stalled connection fails instead of hanging forever.
      await for (final chunk
          in resp.stream.timeout(const Duration(seconds: 30))) {
        sink.add(chunk);
        hasher.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }
    hasher.close();

    final problem = verifyApkDownload(
      received: received,
      expectedLength: total,
      firstBytes: await file.openRead(0, 2).first.catchError((_) => <int>[]),
      actualSha256: digestSink.value.toString(),
      expectedSha256: expectedSha256,
    );
    if (problem != null) {
      try {
        await file.delete();
      } catch (_) {}
      throw UpdateDownloadException(problem);
    }
    await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
  }
}

/// Checks a finished APK download. Returns a reason it's unusable, or null.
/// Pure so it can be unit-tested without a network.
String? verifyApkDownload({
  required int received,
  required int expectedLength,
  required List<int> firstBytes,
  required String actualSha256,
  String? expectedSha256,
}) {
  if (received == 0) return 'Download was empty';
  if (expectedLength > 0 && received != expectedLength) {
    return 'Download was incomplete';
  }
  // An APK is a zip file: it starts with "PK".
  if (firstBytes.length < 2 || firstBytes[0] != 0x50 || firstBytes[1] != 0x4B) {
    return 'Downloaded file is not an APK';
  }
  if (expectedSha256 != null &&
      expectedSha256.isNotEmpty &&
      actualSha256.toLowerCase() != expectedSha256.toLowerCase()) {
    return 'Downloaded file failed its integrity check';
  }
  return null;
}

class _DigestSink implements Sink<Digest> {
  late Digest value;
  @override
  void add(Digest data) => value = data;
  @override
  void close() {}
}

final appUpdateServiceProvider =
    Provider<AppUpdateService>((ref) => AppUpdateService());

/// One-shot update check (cached for the session). Watch it to show a banner;
/// `ref.refresh` it for a manual "check now".
final updateCheckProvider =
    FutureProvider<UpdateInfo?>((ref) => ref.watch(appUpdateServiceProvider).checkForUpdate());
