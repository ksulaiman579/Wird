import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appLanguagePrefsKey = 'app_language_code';

class AppLanguageOption {
  const AppLanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flagEmoji,
  });

  final String code;
  final String nativeName;
  final String englishName;
  final String flagEmoji;
}

/// Every locale we have an ARB for (data only). The picker offers a subset —
/// see [shipLocaleCodes]/[supportedAppLanguages] — so languages can be re-added
/// as they reach 100% translation without re-entering their metadata.
const allAppLanguages = <AppLanguageOption>[
  AppLanguageOption(code: 'en', nativeName: 'English', englishName: 'English', flagEmoji: '🇬🇧'),
  AppLanguageOption(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', flagEmoji: '🇸🇦'),
  AppLanguageOption(code: 'fr', nativeName: 'Français', englishName: 'French', flagEmoji: '🇫🇷'),
  AppLanguageOption(code: 'id', nativeName: 'Bahasa Indonesia', englishName: 'Indonesian', flagEmoji: '🇮🇩'),
  AppLanguageOption(code: 'tr', nativeName: 'Türkçe', englishName: 'Turkish', flagEmoji: '🇹🇷'),
  AppLanguageOption(code: 'ur', nativeName: 'اردو', englishName: 'Urdu', flagEmoji: '🇵🇰'),
  AppLanguageOption(code: 'de', nativeName: 'Deutsch', englishName: 'German', flagEmoji: '🇩🇪'),
  AppLanguageOption(code: 'es', nativeName: 'Español', englishName: 'Spanish', flagEmoji: '🇪🇸'),
  AppLanguageOption(code: 'ms', nativeName: 'Bahasa Melayu', englishName: 'Malay', flagEmoji: '🇲🇾'),
  AppLanguageOption(code: 'ru', nativeName: 'Русский', englishName: 'Russian', flagEmoji: '🇷🇺'),
  AppLanguageOption(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', flagEmoji: '🇧🇩'),
  AppLanguageOption(code: 'fa', nativeName: 'فارسی', englishName: 'Persian', flagEmoji: '🇮🇷'),
  AppLanguageOption(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'pt', nativeName: 'Português', englishName: 'Portuguese', flagEmoji: '🇵🇹'),
  AppLanguageOption(code: 'it', nativeName: 'Italiano', englishName: 'Italian', flagEmoji: '🇮🇹'),
  AppLanguageOption(code: 'nl', nativeName: 'Nederlands', englishName: 'Dutch', flagEmoji: '🇳🇱'),
  AppLanguageOption(code: 'sw', nativeName: 'Kiswahili', englishName: 'Swahili', flagEmoji: '🇰🇪'),
  AppLanguageOption(code: 'ha', nativeName: 'Hausa', englishName: 'Hausa', flagEmoji: '🇳🇬'),
  AppLanguageOption(code: 'so', nativeName: 'Soomaali', englishName: 'Somali', flagEmoji: '🇸🇴'),
  AppLanguageOption(code: 'ps', nativeName: 'پښتو', englishName: 'Pashto', flagEmoji: '🇦🇫'),
  AppLanguageOption(code: 'ku', nativeName: 'Kurdî', englishName: 'Kurdish (Kurmanji)', flagEmoji: '🇹🇷'),
  AppLanguageOption(code: 'ckb', nativeName: 'کوردیی ناوەندی', englishName: 'Central Kurdish (Sorani)', flagEmoji: '🇮🇶'),
  AppLanguageOption(code: 'uz', nativeName: 'Oʻzbekcha', englishName: 'Uzbek', flagEmoji: '🇺🇿'),
  AppLanguageOption(code: 'kk', nativeName: 'Қазақша', englishName: 'Kazakh', flagEmoji: '🇰🇿'),
  AppLanguageOption(code: 'ky', nativeName: 'Кыргызча', englishName: 'Kyrgyz', flagEmoji: '🇰🇬'),
  AppLanguageOption(code: 'tg', nativeName: 'Тоҷикӣ', englishName: 'Tajik', flagEmoji: '🇹🇯'),
  AppLanguageOption(code: 'tk', nativeName: 'Türkmençe', englishName: 'Turkmen', flagEmoji: '🇹🇲'),
  AppLanguageOption(code: 'az', nativeName: 'Azərbaycan dili', englishName: 'Azerbaijani', flagEmoji: '🇦🇿'),
  AppLanguageOption(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'ml', nativeName: 'മലയാളം', englishName: 'Malayalam', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'kn', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'gu', nativeName: 'ગુજરાતી', englishName: 'Gujarati', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'mr', nativeName: 'मराठी', englishName: 'Marathi', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'pa', nativeName: 'ਪੰਜਾਬੀ', englishName: 'Punjabi', flagEmoji: '🇮🇳'),
  AppLanguageOption(code: 'si', nativeName: 'සිංහල', englishName: 'Sinhala', flagEmoji: '🇱🇰'),
  AppLanguageOption(code: 'th', nativeName: 'ไทย', englishName: 'Thai', flagEmoji: '🇹🇭'),
  AppLanguageOption(code: 'vi', nativeName: 'Tiếng Việt', englishName: 'Vietnamese', flagEmoji: '🇻🇳'),
  AppLanguageOption(code: 'zh', nativeName: '中文', englishName: 'Chinese (Simplified)', flagEmoji: '🇨🇳'),
  AppLanguageOption(code: 'ja', nativeName: '日本語', englishName: 'Japanese', flagEmoji: '🇯🇵'),
  AppLanguageOption(code: 'ko', nativeName: '한국어', englishName: 'Korean', flagEmoji: '🇰🇷'),
  AppLanguageOption(code: 'fil', nativeName: 'Filipino', englishName: 'Filipino', flagEmoji: '🇵🇭'),
  AppLanguageOption(code: 'my', nativeName: 'မြန်မာ', englishName: 'Burmese', flagEmoji: '🇲🇲'),
  AppLanguageOption(code: 'km', nativeName: 'ខ្មែរ', englishName: 'Khmer', flagEmoji: '🇰🇭'),
  AppLanguageOption(code: 'am', nativeName: 'አማርኛ', englishName: 'Amharic', flagEmoji: '🇪🇹'),
  AppLanguageOption(code: 'pl', nativeName: 'Polski', englishName: 'Polish', flagEmoji: '🇵🇱'),
  AppLanguageOption(code: 'uk', nativeName: 'Українська', englishName: 'Ukrainian', flagEmoji: '🇺🇦'),
  AppLanguageOption(code: 'ro', nativeName: 'Română', englishName: 'Romanian', flagEmoji: '🇷🇴'),
  AppLanguageOption(code: 'sq', nativeName: 'Shqip', englishName: 'Albanian', flagEmoji: '🇦🇱'),
  AppLanguageOption(code: 'bs', nativeName: 'Bosanski', englishName: 'Bosnian', flagEmoji: '🇧🇦'),
  AppLanguageOption(code: 'sr', nativeName: 'Српски', englishName: 'Serbian', flagEmoji: '🇷🇸'),
  AppLanguageOption(code: 'sv', nativeName: 'Svenska', englishName: 'Swedish', flagEmoji: '🇸🇪'),
  AppLanguageOption(code: 'nb', nativeName: 'Norsk bokmål', englishName: 'Norwegian Bokmål', flagEmoji: '🇳🇴'),
  AppLanguageOption(code: 'da', nativeName: 'Dansk', englishName: 'Danish', flagEmoji: '🇩🇰'),
  AppLanguageOption(code: 'fi', nativeName: 'Suomi', englishName: 'Finnish', flagEmoji: '🇫🇮'),
  AppLanguageOption(code: 'el', nativeName: 'Ελληνικά', englishName: 'Greek', flagEmoji: '🇬🇷'),
  AppLanguageOption(code: 'cs', nativeName: 'Čeština', englishName: 'Czech', flagEmoji: '🇨🇿'),
  AppLanguageOption(code: 'hu', nativeName: 'Magyar', englishName: 'Hungarian', flagEmoji: '🇭🇺'),
  AppLanguageOption(code: 'bg', nativeName: 'Български', englishName: 'Bulgarian', flagEmoji: '🇧🇬'),
  AppLanguageOption(code: 'ne', nativeName: 'नेपाली', englishName: 'Nepali', flagEmoji: '🇳🇵'),
  AppLanguageOption(code: 'dv', nativeName: 'ދިވެހި', englishName: 'Dhivehi', flagEmoji: '🇲🇻'),
  AppLanguageOption(code: 'ug', nativeName: 'ئۇيغۇرچە', englishName: 'Uyghur', flagEmoji: '🇨🇳'),
  AppLanguageOption(code: 'sd', nativeName: 'سنڌي', englishName: 'Sindhi', flagEmoji: '🇵🇰'),
  AppLanguageOption(code: 'yo', nativeName: 'Yorùbá', englishName: 'Yoruba', flagEmoji: '🇳🇬'),
];

/// UI display languages we currently ship fully localized. Only these appear in
/// the language picker. The 64 Quran *translation* editions are a separate
/// download system and are unaffected by this list. Add a code here (and finish
/// its translation) to offer another UI language.
const shipLocaleCodes = <String>['en', 'ar', 'ur', 'hi', 'bn', 'ml', 'fil'];

/// The picker's languages: [allAppLanguages] filtered to [shipLocaleCodes],
/// in that order.
final supportedAppLanguages = <AppLanguageOption>[
  for (final code in shipLocaleCodes)
    allAppLanguages.firstWhere((l) => l.code == code),
];

/// Persists the user's chosen UI language code to shared_preferences.
class AppLanguageNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(appLanguagePrefsKey);
    if (stored != null &&
        supportedAppLanguages.any((lang) => lang.code == stored)) {
      return stored;
    }
    return 'en';
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLanguagePrefsKey, code);
    state = AsyncData(code);
  }
}

final appLanguageProvider =
    AsyncNotifierProvider<AppLanguageNotifier, String>(
  AppLanguageNotifier.new,
);
