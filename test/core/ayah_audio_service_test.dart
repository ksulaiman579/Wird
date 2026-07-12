import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/audio/ayah_audio_service.dart';

void main() {
  group('formatAudioError', () {
    test('distinguishes offline / socket exception as No internet error', () {
      expect(
        formatAudioError('SocketException: Failed host lookup: everyayah.com'),
        'No internet connection available for audio.',
      );
      expect(
        formatAudioError('Network is unreachable'),
        'No internet connection available for audio.',
      );
    });

    test('formats audio source or decoder errors appropriately', () {
      expect(
        formatAudioError('PlayerException: 404 Not Found'),
        'Unable to play audio. Please check your connection or try another reciter.',
      );
      expect(
        formatAudioError(Exception('Codec error')),
        'Unable to play audio. Please check your connection or try another reciter.',
      );
    });
  });
}
