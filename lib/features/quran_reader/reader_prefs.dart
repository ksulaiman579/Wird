import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const readerPrefsKey = 'quran_reader_prefs';

/// Persisted reader options + last-read position (M12.5). `extraEditionId`
/// is null when no additional-language pack is selected/downloaded; the
/// reader falls back to just Arabic/translation/transliteration in that
/// case regardless of this toggle.
class ReaderPrefs {
  const ReaderPrefs({
    this.showTranslation = true,
    this.showTransliteration = true,
    this.showExtraTranslation = false,
    this.extraEditionId,
    this.fontSize = 26,
    this.lastSurah = 1,
    this.lastAyah = 1,
    this.hasReadBefore = false,
    this.autoPlayOnNavigate = true,
    this.mushafMode = false,
    this.showTajweed = false,
  });

  final bool showTranslation;
  final bool showTransliteration;
  final bool showExtraTranslation;
  final String? extraEditionId;
  final double fontSize;
  final int lastSurah;
  final int lastAyah;
  final bool hasReadBefore;

  /// When true, paging to another ayah (by swipe or the nav arrows) plays
  /// that ayah's audio automatically, in whichever direction the user
  /// navigated (M23 feedback). Off by user preference disables this —
  /// paging never starts/changes playback on its own.
  final bool autoPlayOnNavigate;

  /// Classic Mushaf reader mode (continuous Arabic layout across the surah) (Item 5.1).
  final bool mushafMode;

  /// Highlight Tajweed & color-code waqf (stop) marks (Item 5.4).
  final bool showTajweed;

  ReaderPrefs copyWith({
    bool? showTranslation,
    bool? showTransliteration,
    bool? showExtraTranslation,
    // ?? can't distinguish "keep" from "clear" for a nullable field, so
    // clearing goes through [clearExtraEdition] instead (M21.3 bug: the
    // picker's "None" option used to silently no-op through this).
    String? extraEditionId,
    bool clearExtraEdition = false,
    double? fontSize,
    int? lastSurah,
    int? lastAyah,
    bool? hasReadBefore,
    bool? autoPlayOnNavigate,
    bool? mushafMode,
    bool? showTajweed,
  }) {
    return ReaderPrefs(
      showTranslation: showTranslation ?? this.showTranslation,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showExtraTranslation: showExtraTranslation ?? this.showExtraTranslation,
      extraEditionId:
          clearExtraEdition ? null : (extraEditionId ?? this.extraEditionId),
      fontSize: fontSize ?? this.fontSize,
      lastSurah: lastSurah ?? this.lastSurah,
      lastAyah: lastAyah ?? this.lastAyah,
      hasReadBefore: hasReadBefore ?? this.hasReadBefore,
      autoPlayOnNavigate: autoPlayOnNavigate ?? this.autoPlayOnNavigate,
      mushafMode: mushafMode ?? this.mushafMode,
      showTajweed: showTajweed ?? this.showTajweed,
    );
  }

  Map<String, dynamic> toJson() => {
        'showTranslation': showTranslation,
        'showTransliteration': showTransliteration,
        'showExtraTranslation': showExtraTranslation,
        'extraEditionId': extraEditionId,
        'fontSize': fontSize,
        'lastSurah': lastSurah,
        'lastAyah': lastAyah,
        'hasReadBefore': hasReadBefore,
        'autoPlayOnNavigate': autoPlayOnNavigate,
        'mushafMode': mushafMode,
        'showTajweed': showTajweed,
      };

  factory ReaderPrefs.fromJson(Map<String, dynamic> json) {
    return ReaderPrefs(
      showTranslation: json['showTranslation'] as bool? ?? true,
      showTransliteration: json['showTransliteration'] as bool? ?? true,
      showExtraTranslation: json['showExtraTranslation'] as bool? ?? false,
      extraEditionId: json['extraEditionId'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 26,
      lastSurah: json['lastSurah'] as int? ?? 1,
      lastAyah: json['lastAyah'] as int? ?? 1,
      hasReadBefore: json['hasReadBefore'] as bool? ?? false,
      autoPlayOnNavigate: json['autoPlayOnNavigate'] as bool? ?? true,
      mushafMode: json['mushafMode'] as bool? ?? false,
      showTajweed: json['showTajweed'] as bool? ?? false,
    );
  }
}

class ReaderPrefsNotifier extends AsyncNotifier<ReaderPrefs> {
  @override
  Future<ReaderPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(readerPrefsKey);
    if (raw == null) return const ReaderPrefs();
    return ReaderPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updatePrefs(
    ReaderPrefs Function(ReaderPrefs current) updater,
  ) async {
    final next = updater(state.value ?? const ReaderPrefs());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(readerPrefsKey, jsonEncode(next.toJson()));
    state = AsyncData(next);
  }

  Future<void> setLastRead({required int surah, required int ayah}) {
    return updatePrefs(
      (p) => p.copyWith(lastSurah: surah, lastAyah: ayah, hasReadBefore: true),
    );
  }
}

final readerPrefsProvider =
    AsyncNotifierProvider<ReaderPrefsNotifier, ReaderPrefs>(
  ReaderPrefsNotifier.new,
);
