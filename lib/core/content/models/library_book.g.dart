// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LibraryBook _$LibraryBookFromJson(Map<String, dynamic> json) => _LibraryBook(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['author'] as String,
  discipline: json['discipline'] as String,
  languageCode: json['languageCode'] as String,
  url: json['url'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  format: json['format'] as String? ?? 'pdf',
);

Map<String, dynamic> _$LibraryBookToJson(_LibraryBook instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'discipline': instance.discipline,
      'languageCode': instance.languageCode,
      'url': instance.url,
      'sizeBytes': instance.sizeBytes,
      'format': instance.format,
    };
