import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'ayah_audio_urls.dart';

String? _docsPath;

/// Same layout the download manager writes:
/// `<app documents>/quran_audio/<reciter>/<SSS><AAA>.mp3`.
/// background_downloader only moves a file there once it's complete, so an
/// existing, non-empty file is safe to play.
Future<String?> findLocalAyahFile({
  required String reciter,
  required int surah,
  required int ayah,
}) async {
  try {
    _docsPath ??= (await getApplicationDocumentsDirectory()).path;
    final file = File(
      '$_docsPath/quran_audio/$reciter/${ayahAudioFileName(surah: surah, ayah: ayah)}',
    );
    if (await file.exists() && await file.length() > 0) return file.path;
  } catch (_) {
    // No documents dir (e.g. under `flutter test`) — just stream.
  }
  return null;
}

/// Deletes every `<SSS>*.mp3` for [surah] under each reciter's folder.
Future<void> deleteLocalSurahFiles({
  required int surah,
  required Iterable<String> reciters,
}) async {
  final prefix = surah.toString().padLeft(3, '0');
  try {
    _docsPath ??= (await getApplicationDocumentsDirectory()).path;
  } catch (_) {
    return;
  }
  for (final reciter in reciters) {
    final dir = Directory('$_docsPath/quran_audio/$reciter');
    if (!await dir.exists()) continue;
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      if (f is File && name.startsWith(prefix) && name.endsWith('.mp3') &&
          name.length == 10) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }
  }
}
