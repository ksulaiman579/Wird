import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_book.freezed.dart';
part 'library_book.g.dart';

/// One entry from the bundled Knowledge Library catalogue
/// (`assets/data/knowledge_library.json`, built by
/// `tool/build_islamhouse_catalogue.py` — M24.3). Metadata only; the PDF
/// itself is pulled from [url] (IslamHouse CDN) on demand.
@freezed
abstract class LibraryBook with _$LibraryBook {
  const factory LibraryBook({
    required int id,
    required String title,
    required String author,
    required String discipline, // slug: aqeedah|hadith|tafsir|fiqh|seerah|dawah|adab|arabic
    required String languageCode,
    required String url,
    required int sizeBytes,
    @Default('pdf') String format, // 'pdf' | 'epub'
  }) = _LibraryBook;

  factory LibraryBook.fromJson(Map<String, dynamic> json) =>
      _$LibraryBookFromJson(json);
}
