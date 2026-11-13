import 'package:background_downloader/background_downloader.dart';
import 'package:wird/core/audio/audio_download_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SurahDownloadTally', () {
    test('one finished ayah does not mark the surah downloaded', () {
      final t = SurahDownloadTally(3)
        ..statuses['a'] = TaskStatus.complete
        ..statuses['b'] = TaskStatus.running
        ..progress['b'] = 0.5;
      expect(t.status, 'downloading');
      expect(t.fraction, closeTo(0.5, 1e-9)); // (1 + 0.5 + 0) / 3
    });

    test('all finished → downloaded at 100%', () {
      final t = SurahDownloadTally(2)
        ..statuses['a'] = TaskStatus.complete
        ..statuses['b'] = TaskStatus.complete;
      expect(t.status, 'downloaded');
      expect(t.fraction, 1.0);
    });

    test('a failure is not masked by a later success', () {
      final t = SurahDownloadTally(2)
        ..statuses['a'] = TaskStatus.failed
        ..statuses['b'] = TaskStatus.complete;
      expect(t.status, 'failed');
    });

    test('paused when nothing is still running', () {
      final t = SurahDownloadTally(2)
        ..statuses['a'] = TaskStatus.paused
        ..statuses['b'] = TaskStatus.complete;
      expect(t.status, 'paused');
    });

    test('all canceled → not downloaded', () {
      final t = SurahDownloadTally(1)..statuses['a'] = TaskStatus.canceled;
      expect(t.status, 'notDownloaded');
    });
  });

  test('qualityForReciter reads the bitrate from the reciter id', () {
    expect(qualityForReciter('Husary_128kbps'), '128kbps');
    expect(qualityForReciter('Abdul_Basit_Murattal_192kbps'), '192kbps');
    expect(qualityForReciter('Minshawy_Murattal_40kbps'), '40kbps');
    expect(qualityForReciter('Unknown'), isNull);
  });
}
