import 'package:flutter_test/flutter_test.dart';
import 'package:wird/core/search/search_index.dart';

void main() {
  final index = SearchIndex([
    SearchDoc(
      kind: SearchKind.surah,
      route: '/quran/1',
      title: 'Al-Fatihah — The Opener',
      arabic: 'الفاتحة',
    ),
    SearchDoc(
      kind: SearchKind.ayah,
      route: '/read?surah=2&ayah=255',
      title: 'Al-Baqarah 2:255',
      arabic: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَيُّ ٱلۡقَيُّومُ',
      text: 'Allah - there is no deity except Him, the Ever-Living',
    ),
    SearchDoc(
      kind: SearchKind.ayah,
      route: '/read?surah=1&ayah=1',
      title: 'Al-Fatihah 1:1',
      arabic: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
      text: 'In the name of Allah, the Entirely Merciful',
    ),
    SearchDoc(
      kind: SearchKind.hadith,
      route: '/hadith/nawawi/1',
      title: 'Actions Are Judged by Intentions',
      text: 'Actions are but by intentions',
    ),
  ]);

  test('plain Arabic finds Uthmani text', () {
    final hits = index.search('الحي القيوم');
    expect(hits.first.doc.route, '/read?surah=2&ayah=255');
  });

  test('ta marbuta spelling finds the surah', () {
    expect(index.search('الفاتحه').first.doc.route, '/quran/1');
  });

  test('a surah:ayah reference jumps to that ayah', () {
    final hits = index.search('2:255');
    expect(hits, hasLength(1));
    expect(hits.single.doc.route, '/read?surah=2&ayah=255');
  });

  test('translation words match, case-insensitive', () {
    expect(
      index.search('ever-living').map((h) => h.doc.route),
      contains('/read?surah=2&ayah=255'),
    );
  });

  test('title matches outrank body matches', () {
    final hits = index.search('intentions');
    expect(hits.first.doc.kind, SearchKind.hadith);
  });

  test('kind filter limits results', () {
    final hits = index.search('allah', kinds: {SearchKind.hadith});
    expect(hits, isEmpty);
  });

  test('empty query gives nothing', () {
    expect(index.search('   '), isEmpty);
  });
}
