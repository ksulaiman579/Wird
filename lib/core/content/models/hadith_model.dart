import 'package:freezed_annotation/freezed_annotation.dart';

part 'hadith_model.freezed.dart';
part 'hadith_model.g.dart';

@freezed
abstract class Hadith with _$Hadith {
  const factory Hadith({
    required int id,
    required String titleEnglish,
    required String arabic,
    required String translation,
    required String narrator,
    required String source,
    required String summary,
    required int wordCount,
    required bool core,
  }) = _Hadith;

  factory Hadith.fromJson(Map<String, dynamic> json) =>
      _$HadithFromJson(json);
}
