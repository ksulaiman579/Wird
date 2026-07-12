import 'package:freezed_annotation/freezed_annotation.dart';

part 'dua_models.freezed.dart';
part 'dua_models.g.dart';

@freezed
abstract class Dua with _$Dua {
  const factory Dua({
    required String id,
    required String arabic,
    String? transliteration,
    required String translation,
    required String reference,
    required int repetitions,
    required int wordCount,
  }) = _Dua;

  factory Dua.fromJson(Map<String, dynamic> json) => _$DuaFromJson(json);
}

/// A dhikr (morning/evening remembrance) has the exact same shape as a
/// [Dua] in the bundled data — the Adhkar reader and the Dua browser just
/// present the same underlying items differently.
typedef Dhikr = Dua;

@freezed
abstract class DuaCategory with _$DuaCategory {
  const factory DuaCategory({
    required String id,
    required String titleEnglish,
    required int order,
    required List<Dua> duas,
  }) = _DuaCategory;

  factory DuaCategory.fromJson(Map<String, dynamic> json) =>
      _$DuaCategoryFromJson(json);
}

@freezed
abstract class HisnulMuslim with _$HisnulMuslim {
  const factory HisnulMuslim({
    required List<DuaCategory> categories,
  }) = _HisnulMuslim;

  factory HisnulMuslim.fromJson(Map<String, dynamic> json) =>
      _$HisnulMuslimFromJson(json);
}

@freezed
abstract class AdhkarSet with _$AdhkarSet {
  const factory AdhkarSet({
    required List<Dhikr> morning,
    required List<Dhikr> evening,
  }) = _AdhkarSet;

  factory AdhkarSet.fromJson(Map<String, dynamic> json) =>
      _$AdhkarSetFromJson(json);
}
