import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_pack_models.freezed.dart';
part 'translation_pack_models.g.dart';

/// One entry from `tool/editions_allowlist.json` — a Quran translation
/// edition the app is allowed to offer for download. Editions not in this
/// list are never shown, regardless of what's available upstream.
@freezed
abstract class TranslationEditionEntry with _$TranslationEditionEntry {
  const factory TranslationEditionEntry({
    required String id,
    required String language,
    required String languageCode,
    required String author,
    required String link,
    String? sha256,
  }) = _TranslationEditionEntry;

  factory TranslationEditionEntry.fromJson(Map<String, dynamic> json) =>
      _$TranslationEditionEntryFromJson(json);
}

/// The parsed contents of `tool/editions_allowlist.json`.
@freezed
abstract class TranslationAllowlist with _$TranslationAllowlist {
  const factory TranslationAllowlist({
    required List<TranslationEditionEntry> editions,
  }) = _TranslationAllowlist;

  factory TranslationAllowlist.fromJson(Map<String, dynamic> json) =>
      _$TranslationAllowlistFromJson(json);
}
