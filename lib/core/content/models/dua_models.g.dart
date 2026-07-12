// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dua_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Dua _$DuaFromJson(Map<String, dynamic> json) => _Dua(
  id: json['id'] as String,
  arabic: json['arabic'] as String,
  transliteration: json['transliteration'] as String?,
  translation: json['translation'] as String,
  reference: json['reference'] as String,
  repetitions: (json['repetitions'] as num).toInt(),
  wordCount: (json['wordCount'] as num).toInt(),
);

Map<String, dynamic> _$DuaToJson(_Dua instance) => <String, dynamic>{
  'id': instance.id,
  'arabic': instance.arabic,
  'transliteration': instance.transliteration,
  'translation': instance.translation,
  'reference': instance.reference,
  'repetitions': instance.repetitions,
  'wordCount': instance.wordCount,
};

_DuaCategory _$DuaCategoryFromJson(Map<String, dynamic> json) => _DuaCategory(
  id: json['id'] as String,
  titleEnglish: json['titleEnglish'] as String,
  order: (json['order'] as num).toInt(),
  duas: (json['duas'] as List<dynamic>)
      .map((e) => Dua.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DuaCategoryToJson(_DuaCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titleEnglish': instance.titleEnglish,
      'order': instance.order,
      'duas': instance.duas,
    };

_HisnulMuslim _$HisnulMuslimFromJson(Map<String, dynamic> json) =>
    _HisnulMuslim(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => DuaCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HisnulMuslimToJson(_HisnulMuslim instance) =>
    <String, dynamic>{'categories': instance.categories};

_AdhkarSet _$AdhkarSetFromJson(Map<String, dynamic> json) => _AdhkarSet(
  morning: (json['morning'] as List<dynamic>)
      .map((e) => Dua.fromJson(e as Map<String, dynamic>))
      .toList(),
  evening: (json['evening'] as List<dynamic>)
      .map((e) => Dua.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AdhkarSetToJson(_AdhkarSet instance) =>
    <String, dynamic>{'morning': instance.morning, 'evening': instance.evening};
