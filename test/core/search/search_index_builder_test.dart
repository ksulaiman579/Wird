import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/search/search_index.dart';
import 'package:wird/core/search/search_index_builder.dart';

import '../../test_helpers/file_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SearchIndex index;
  setUpAll(() async {
    index = await buildSearchIndex(bundle: FileAssetBundle());
  });

  test('indexes every ayah and surah', () {
    int count(SearchKind k) => index.docs.where((d) => d.kind == k).length;
    expect(count(SearchKind.ayah), 6236);
    expect(count(SearchKind.surah), 114);
    expect(count(SearchKind.hadith), 42);
    expect(count(SearchKind.name), 99);
    expect(count(SearchKind.dua), greaterThan(200));
  });

  // Fixed queries with the expected top result (per-language list, 28.4).
  final expectations = <String, String>{
    'الله لا اله الا هو الحي القيوم': '/read?surah=2&ayah=255',
    'الفاتحه': '/quran/1',
    'قل هو الله احد': '/read?surah=112&ayah=1',
    'ikhlas': '/quran/112',
    'intentions': '/hadith/nawawi/1',
    'ar-rahman': '/quran/55',
    '2:255': '/read?surah=2&ayah=255',
  };

  for (final e in expectations.entries) {
    test('"${e.key}" → ${e.value}', () {
      final hits = index.search(e.key);
      expect(hits, isNotEmpty);
      expect(hits.take(3).map((h) => h.doc.route), contains(e.value));
    });
  }

  test('a search over everything is fast', () {
    final sw = Stopwatch()..start();
    for (var i = 0; i < 10; i++) {
      index.search('mercy');
    }
    // Generous bound for slow CI machines; typically a few ms per query.
    expect(sw.elapsedMilliseconds / 10, lessThan(200));
  });
}
