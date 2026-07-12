import 'dart:io';

import 'package:flutter/services.dart';

/// Reads assets straight from disk via dart:io, bypassing the platform
/// channel that flutter_test's default asset bundle uses.
///
/// This environment's `testWidgets` platform-channel transport hangs
/// indefinitely (no error, no timeout) on messages roughly above 40-50KB —
/// confirmed by isolated repro: identical reads never hang in a plain
/// `test()` block or via direct `dart:io` File reads, only the
/// channel-based path does, and only inside a pumped `testWidgets` zone.
/// Real app builds (and `flutter test` files that only use plain `test()`,
/// like test/content/repositories_test.dart) are unaffected — this is
/// purely a characteristic of this environment's `testWidgets` harness.
///
/// Use via a Riverpod provider override wherever a widget test needs to
/// render a screen backed by a bundled data file bigger than that
/// threshold (any hadith/dua/adhkar screen, or a Quran surah screen for
/// a surah larger than ~40KB):
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     hadithRepositoryProvider.overrideWithValue(
///       HadithRepository(bundle: FileAssetBundle()),
///     ),
///   ],
///   child: ...,
/// )
/// ```
class FileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}
