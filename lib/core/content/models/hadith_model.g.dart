// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hadith _$HadithFromJson(Map<String, dynamic> json) => _Hadith(
  id: (json['id'] as num).toInt(),
  titleEnglish: json['titleEnglish'] as String,
  arabic: json['arabic'] as String,
  translation: json['translation'] as String,
  narrator: json['narrator'] as String,
  source: json['source'] as String,
  summary: json['summary'] as String,
  wordCount: (json['wordCount'] as num).toInt(),
  core: json['core'] as bool,
);

Map<String, dynamic> _$HadithToJson(_Hadith instance) => <String, dynamic>{
  'id': instance.id,
  'titleEnglish': instance.titleEnglish,
  'arabic': instance.arabic,
  'translation': instance.translation,
  'narrator': instance.narrator,
  'source': instance.source,
  'summary': instance.summary,
  'wordCount': instance.wordCount,
  'core': instance.core,
};
