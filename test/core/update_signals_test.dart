import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/update/update_signals.dart';

void main() {
  group('shouldNotifyUpdate', () {
    test('fires when a newer build is published and not yet notified', () {
      expect(
        shouldNotifyUpdate(installedCode: 1, latestCode: 2, lastNotifiedCode: 0),
        isTrue,
      );
    });
    test('does not fire when already on the latest', () {
      expect(
        shouldNotifyUpdate(installedCode: 2, latestCode: 2, lastNotifiedCode: 0),
        isFalse,
      );
    });
    test('does not re-fire for an update already notified', () {
      expect(
        shouldNotifyUpdate(installedCode: 1, latestCode: 2, lastNotifiedCode: 2),
        isFalse,
      );
    });
    test('does not fire on a downgrade manifest', () {
      expect(
        shouldNotifyUpdate(installedCode: 3, latestCode: 2, lastNotifiedCode: 0),
        isFalse,
      );
    });
  });

  group('shouldNotifyAnnouncement', () {
    test('fires for a newer announcement id', () {
      expect(shouldNotifyAnnouncement(latestId: 3, lastSeenId: 2), isTrue);
    });
    test('does not fire for the sentinel 0 (no announcement)', () {
      expect(shouldNotifyAnnouncement(latestId: 0, lastSeenId: 0), isFalse);
    });
    test('does not re-fire an announcement already seen', () {
      expect(shouldNotifyAnnouncement(latestId: 2, lastSeenId: 2), isFalse);
      expect(shouldNotifyAnnouncement(latestId: 1, lastSeenId: 2), isFalse);
    });
  });
}
