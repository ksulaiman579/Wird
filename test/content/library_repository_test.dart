import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/library_repository.dart';

import '../test_helpers/file_asset_bundle.dart';

void main() {
  final repo = LibraryRepository(bundle: FileAssetBundle());

  test('loadAll parses the bundled catalogue (~2040 books, valid fields)',
      () async {
    final all = await repo.loadAll();
    expect(all.length, greaterThan(1900));
    for (final b in all.take(50)) {
      expect(b.url, startsWith('https://'));
      expect(b.url.toLowerCase(), endsWith('.pdf'));
      expect(b.sizeBytes, greaterThan(0));
      expect(b.sizeBytes, lessThanOrEqualTo(50 * 1024 * 1024));
      expect(libraryDisciplines.any((d) => d.slug == b.discipline), isTrue);
    }
  });

  test('books() filters by discipline + language and by query', () async {
    final aqEn = await repo.books(discipline: 'aqeedah', languageCode: 'en');
    expect(aqEn, isNotEmpty);
    expect(aqEn.every((b) => b.discipline == 'aqeedah' && b.languageCode == 'en'),
        isTrue);
    // sorted by title
    final titles = aqEn.map((b) => b.title).toList();
    final sorted = [...titles]..sort();
    expect(titles, sorted);

    // a query narrows the set to a subset
    final tawhid = await repo.books(
        discipline: 'aqeedah', languageCode: 'en', query: 'tawhid');
    expect(tawhid.length, lessThan(aqEn.length));
    expect(
      tawhid.every((b) =>
          b.title.toLowerCase().contains('tawhid') ||
          b.author.toLowerCase().contains('tawhid')),
      isTrue,
    );
  });

  test('disciplineCounts covers only the queried language', () async {
    final counts = await repo.disciplineCounts('en');
    expect(counts['aqeedah'], greaterThan(0));
    final all = await repo.loadAll();
    final enCount = all.where((b) => b.languageCode == 'en').length;
    expect(counts.values.fold<int>(0, (s, v) => s + v), enCount);
  });

  test('byId returns the matching book or null', () async {
    final all = await repo.loadAll();
    final first = all.first;
    expect((await repo.byId(first.id))?.id, first.id);
    expect(await repo.byId(-1), isNull);
  });
}
