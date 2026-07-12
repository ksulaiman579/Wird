// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_pack_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TranslationEditionEntry _$TranslationEditionEntryFromJson(
  Map<String, dynamic> json,
) => _TranslationEditionEntry(
  id: json['id'] as String,
  language: json['language'] as String,
  languageCode: json['languageCode'] as String,
  author: json['author'] as String,
  link: json['link'] as String,
  sha256: json['sha256'] as String?,
);

Map<String, dynamic> _$TranslationEditionEntryToJson(
  _TranslationEditionEntry instance,
) => <String, dynamic>{
  'id': instance.id,
  'language': instance.language,
  'languageCode': instance.languageCode,
  'author': instance.author,
  'link': instance.link,
  'sha256': instance.sha256,
};

_TranslationAllowlist _$TranslationAllowlistFromJson(
  Map<String, dynamic> json,
) => _TranslationAllowlist(
  editions: (json['editions'] as List<dynamic>)
      .map((e) => TranslationEditionEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TranslationAllowlistToJson(
  _TranslationAllowlist instance,
) => <String, dynamic>{'editions': instance.editions};
