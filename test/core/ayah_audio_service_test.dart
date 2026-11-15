import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/audio/ayah_audio_service.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  group('formatAudioError', () {
    test('distinguishes offline / socket exception as No internet error', () {
      expect(
        formatAudioError('SocketException: Failed host lookup: everyayah.com', en),
        'No internet connection available for audio.',
      );
      expect(
        formatAudioError('Network is unreachable', en),
        'No internet connection available for audio.',
      );
    });

    test('formats audio source or decoder errors appropriately', () {
      expect(
        formatAudioError('PlayerException: 404 Not Found', en),
        'Unable to play audio. Please check your connection or try another reciter.',
      );
      expect(
        formatAudioError(Exception('Codec error'), en),
        'Unable to play audio. Please check your connection or try another reciter.',
      );
    });

    test('uses the app language', () {
      expect(formatAudioError('Network is unreachable', ar), ar.audioErrorOffline);
      expect(ar.audioErrorOffline, isNot(en.audioErrorOffline));
    });
  });
}
