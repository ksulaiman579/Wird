import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../core/db/database.dart';

final hadithPackStatusProvider =
    StreamProvider.family<ContentPack?, String>((ref, collection) {
  return ref.watch(hadithPackRepositoryProvider).watchPack(collection);
});

final hadithChaptersProvider =
    FutureProvider.family<List<HadithChapter>, String>((ref, collection) {
  return ref.watch(hadithPackRepositoryProvider).chaptersFor(collection);
});

final hadithChapterEntriesProvider = FutureProvider.family<List<HadithEntry>,
    (String collection, String chapterNumber)>((ref, key) {
  final (collection, chapterNumber) = key;
  return ref
      .watch(hadithPackRepositoryProvider)
      .hadithInChapter(collection, chapterNumber);
});
