import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/update/app_update_service.dart';

void main() {
  const pk = [0x50, 0x4B];
  const hash = 'abc123';

  String? check({
    int received = 100,
    int expected = 100,
    List<int> first = pk,
    String actual = hash,
    String? want = hash,
  }) =>
      verifyApkDownload(
        received: received,
        expectedLength: expected,
        firstBytes: first,
        actualSha256: actual,
        expectedSha256: want,
      );

  test('a good download passes', () => expect(check(), isNull));
  test('an HTML error page is rejected', () {
    expect(check(first: '<!'.codeUnits), isNotNull);
  });
  test('a short download is rejected', () {
    expect(check(received: 60), isNotNull);
  });
  test('a hash mismatch is rejected', () {
    expect(check(actual: 'different'), isNotNull);
  });
  test('old manifests without a hash still work', () {
    expect(check(want: null, actual: 'anything'), isNull);
  });
  test('an empty download is rejected', () {
    expect(check(received: 0, expected: 0), isNotNull);
  });

  group('pickApkUrl', () {
    final perAbi = {
      'apkUrl': 'fat.apk',
      'sha256': 'fat',
      'apks': {
        'arm64-v8a': {'url': 'arm64.apk', 'sha256': 'a64'},
        'armeabi-v7a': {'url': 'arm.apk', 'sha256': 'a32'},
      },
    };
    test('picks the device ABI build and its hash', () {
      expect(pickApkUrl(perAbi, 'arm64-v8a'), 'arm64.apk');
      expect(pickApkSha256(perAbi, 'arm64-v8a'), 'a64');
    });
    test('falls back to the single APK for a missing ABI', () {
      expect(pickApkUrl(perAbi, 'x86_64'), 'fat.apk');
      expect(pickApkSha256(perAbi, 'x86_64'), 'fat');
    });
    test('reads the ABI from the VM platform string', () {
      expect(abiKeyFromVersion('3.12 (stable) on "android_arm64"'), 'arm64-v8a');
      expect(abiKeyFromVersion('3.12 (stable) on "android_arm"'), 'armeabi-v7a');
      expect(abiKeyFromVersion('3.12 (stable) on "android_x64"'), 'x86_64');
      expect(abiKeyFromVersion('3.12 (stable) on "windows_x64"'), isNull);
    });
    test('old manifests with only apkUrl still work', () {
      expect(pickApkUrl({'apkUrl': 'x.apk'}, 'arm64-v8a'), 'x.apk');
    });
  });
}
