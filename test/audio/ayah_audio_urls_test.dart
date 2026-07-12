import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/audio/ayah_audio_urls.dart';

void main() {
  test('ayahAudioUrl builds the everyayah.com path with zero-padded numbers',
      () {
    expect(
      ayahAudioUrl(reciter: 'Husary_128kbps', surah: 2, ayah: 5),
      'https://everyayah.com/data/Husary_128kbps/002005.mp3',
    );
    expect(
      ayahAudioUrl(reciter: 'Alafasy_128kbps', surah: 114, ayah: 6),
      'https://everyayah.com/data/Alafasy_128kbps/114006.mp3',
    );
  });

  test('ayahAudioFileName matches the trailing segment of the URL', () {
    final fileName = ayahAudioFileName(surah: 18, ayah: 10);
    expect(fileName, '018010.mp3');
    expect(
      ayahAudioUrl(reciter: defaultReciter, surah: 18, ayah: 10),
      endsWith(fileName),
    );
  });

  test('defaultReciter is Husary and is present in the reciters map', () {
    expect(defaultReciter, 'Husary_128kbps');
    expect(reciters.containsKey(defaultReciter), true);
    // Expanded catalogue (M23.8) — everyayah.com folder names, each
    // verified to serve a complete 6236-ayah set.
    expect(reciters.length, 18);
  });

  test('every reciter key is a non-empty everyayah folder with a label', () {
    for (final entry in reciters.entries) {
      expect(entry.key, isNotEmpty);
      expect(entry.key.contains(' '), isFalse); // folder names have no spaces
      expect(entry.value, isNotEmpty);
    }
  });

  test('RepeatCount.times maps to the expected finite counts, null for infinite',
      () {
    expect(RepeatCount.three.times, 3);
    expect(RepeatCount.five.times, 5);
    expect(RepeatCount.ten.times, 10);
    expect(RepeatCount.infinite.times, isNull);
  });

  test('shouldRepeatAgain stops once the finite target is reached', () {
    expect(shouldRepeatAgain(0, RepeatCount.three), true);
    expect(shouldRepeatAgain(2, RepeatCount.three), true);
    expect(shouldRepeatAgain(3, RepeatCount.three), false);
    expect(shouldRepeatAgain(4, RepeatCount.three), false);
  });

  test('shouldRepeatAgain never stops for infinite', () {
    expect(shouldRepeatAgain(0, RepeatCount.infinite), true);
    expect(shouldRepeatAgain(1000, RepeatCount.infinite), true);
  });

  test('playbackSpeeds span 0.5x–2.0x and include normal speed', () {
    expect(playbackSpeeds, [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]);
    expect(playbackSpeeds.contains(1.0), true);
  });
}
