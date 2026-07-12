/// Form state collected across the onboarding steps. Kept Flutter-free so
/// the scope/validation logic is trivially testable.
class OnboardingFormState {
  const OnboardingFormState({
    this.name = '',
    this.avatarEmoji = '🕌',
    this.wantsQuran = true,
    this.wantsHadith = true,
    this.wantsDuas = false,
    this.quranSelectionType = 'whole',
    this.selectedJuz = const [],
    this.selectedSurahs = const [],
    this.direction = 'normal',
    this.dailyMinutes = 10,
  });

  final String name;
  final String avatarEmoji;
  final bool wantsQuran;
  final bool wantsHadith;
  final bool wantsDuas;

  /// whole | juz | surahs — only meaningful when [wantsQuran] is true.
  final String quranSelectionType;
  final List<int> selectedJuz;
  final List<int> selectedSurahs;

  /// normal | reversed — offered for juz/whole selections only.
  final String direction;
  final int dailyMinutes;

  /// quran | hadith | both, derived from the two track toggles. At least
  /// one of [wantsQuran]/[wantsHadith] must be true to reach this step.
  String get scope {
    if (wantsQuran && wantsHadith) return 'both';
    if (wantsQuran) return 'quran';
    return 'hadith';
  }

  bool get hasValidScope => wantsQuran || wantsHadith;

  List<int> get quranSelectionIds =>
      quranSelectionType == 'surahs' ? selectedSurahs : selectedJuz;

  bool get hasValidQuranSelection {
    if (!wantsQuran) return true;
    if (quranSelectionType == 'whole') return true;
    return quranSelectionIds.isNotEmpty;
  }

  OnboardingFormState copyWith({
    String? name,
    String? avatarEmoji,
    bool? wantsQuran,
    bool? wantsHadith,
    bool? wantsDuas,
    String? quranSelectionType,
    List<int>? selectedJuz,
    List<int>? selectedSurahs,
    String? direction,
    int? dailyMinutes,
  }) {
    return OnboardingFormState(
      name: name ?? this.name,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      wantsQuran: wantsQuran ?? this.wantsQuran,
      wantsHadith: wantsHadith ?? this.wantsHadith,
      wantsDuas: wantsDuas ?? this.wantsDuas,
      quranSelectionType: quranSelectionType ?? this.quranSelectionType,
      selectedJuz: selectedJuz ?? this.selectedJuz,
      selectedSurahs: selectedSurahs ?? this.selectedSurahs,
      direction: direction ?? this.direction,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    );
  }
}
