import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_models.freezed.dart';
part 'quran_models.g.dart';

@freezed
abstract class SurahMeta with _$SurahMeta {
  const factory SurahMeta({
    required int number,
    required String nameArabic,
    required String nameTransliterated,
    required String nameEnglish,
    required int ayahCount,
    required String revelationType,
    required int startJuz,
  }) = _SurahMeta;

  factory SurahMeta.fromJson(Map<String, dynamic> json) =>
      _$SurahMetaFromJson(json);
}

@freezed
abstract class AyahRef with _$AyahRef {
  const factory AyahRef({required int surah, required int ayah}) = _AyahRef;

  factory AyahRef.fromJson(Map<String, dynamic> json) =>
      _$AyahRefFromJson(json);
}

@freezed
abstract class JuzSpan with _$JuzSpan {
  const factory JuzSpan({
    required int juz,
    required AyahRef start,
    required AyahRef end,
  }) = _JuzSpan;

  factory JuzSpan.fromJson(Map<String, dynamic> json) =>
      _$JuzSpanFromJson(json);
}

@freezed
abstract class QuranMeta with _$QuranMeta {
  const factory QuranMeta({
    required List<SurahMeta> surahs,
    required List<JuzSpan> juzMap,
  }) = _QuranMeta;

  factory QuranMeta.fromJson(Map<String, dynamic> json) =>
      _$QuranMetaFromJson(json);
}

@freezed
abstract class Ayah with _$Ayah {
  const factory Ayah({
    required int ayah,
    required String arabic,
    required String translation,
    required String transliteration,
    required int juz,
    required int wordCount,
  }) = _Ayah;

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
}

@freezed
abstract class Surah with _$Surah {
  const factory Surah({
    required int surah,
    required List<Ayah> ayahs,
  }) = _Surah;

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
}
