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
}
