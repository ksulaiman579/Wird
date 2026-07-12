// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurahMeta _$SurahMetaFromJson(Map<String, dynamic> json) => _SurahMeta(
  number: (json['number'] as num).toInt(),
  nameArabic: json['nameArabic'] as String,
  nameTransliterated: json['nameTransliterated'] as String,
  nameEnglish: json['nameEnglish'] as String,
  ayahCount: (json['ayahCount'] as num).toInt(),
  revelationType: json['revelationType'] as String,
  startJuz: (json['startJuz'] as num).toInt(),
);

Map<String, dynamic> _$SurahMetaToJson(_SurahMeta instance) =>
    <String, dynamic>{
      'number': instance.number,
      'nameArabic': instance.nameArabic,
      'nameTransliterated': instance.nameTransliterated,
      'nameEnglish': instance.nameEnglish,
      'ayahCount': instance.ayahCount,
      'revelationType': instance.revelationType,
      'startJuz': instance.startJuz,
    };

_AyahRef _$AyahRefFromJson(Map<String, dynamic> json) => _AyahRef(
  surah: (json['surah'] as num).toInt(),
  ayah: (json['ayah'] as num).toInt(),
);

Map<String, dynamic> _$AyahRefToJson(_AyahRef instance) => <String, dynamic>{
  'surah': instance.surah,
  'ayah': instance.ayah,
};

_JuzSpan _$JuzSpanFromJson(Map<String, dynamic> json) => _JuzSpan(
  juz: (json['juz'] as num).toInt(),
  start: AyahRef.fromJson(json['start'] as Map<String, dynamic>),
  end: AyahRef.fromJson(json['end'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JuzSpanToJson(_JuzSpan instance) => <String, dynamic>{
  'juz': instance.juz,
  'start': instance.start,
  'end': instance.end,
};

_QuranMeta _$QuranMetaFromJson(Map<String, dynamic> json) => _QuranMeta(
  surahs: (json['surahs'] as List<dynamic>)
      .map((e) => SurahMeta.fromJson(e as Map<String, dynamic>))
      .toList(),
  juzMap: (json['juzMap'] as List<dynamic>)
      .map((e) => JuzSpan.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuranMetaToJson(_QuranMeta instance) =>
    <String, dynamic>{'surahs': instance.surahs, 'juzMap': instance.juzMap};

_Ayah _$AyahFromJson(Map<String, dynamic> json) => _Ayah(
  ayah: (json['ayah'] as num).toInt(),
  arabic: json['arabic'] as String,
  translation: json['translation'] as String,
  transliteration: json['transliteration'] as String,
  juz: (json['juz'] as num).toInt(),
  wordCount: (json['wordCount'] as num).toInt(),
);

Map<String, dynamic> _$AyahToJson(_Ayah instance) => <String, dynamic>{
  'ayah': instance.ayah,
  'arabic': instance.arabic,
  'translation': instance.translation,
  'transliteration': instance.transliteration,
  'juz': instance.juz,
  'wordCount': instance.wordCount,
};

_Surah _$SurahFromJson(Map<String, dynamic> json) => _Surah(
  surah: (json['surah'] as num).toInt(),
  ayahs: (json['ayahs'] as List<dynamic>)
      .map((e) => Ayah.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SurahToJson(_Surah instance) => <String, dynamic>{
  'surah': instance.surah,
  'ayahs': instance.ayahs,
};
