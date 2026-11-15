/// Text folding for search (M28.1). Pure Dart, no Flutter imports.
///
/// Arabic: strips harakat, Quranic annotation marks and tatweel, and folds
/// letter variants people type interchangeably, so "الفاتحه" finds
/// "الفاتحة" and plain typing finds the Uthmani text.
/// Urdu: folds the Urdu forms of kaf/ya/ha onto the Arabic ones.
/// Latin: lower-cased with common accents dropped.
/// The same function must be used on the indexed text and the query.
library;

// Harakat and other combining marks (fathatan..sukun, superscript alef,
// Quranic small high/low marks, end of ayah etc.).
final _marks = RegExp(
  '[ؐ-ًؚ-ٰٟۖ-ۜ۟-۪ۨ-ۭ࣓-ࣿ]',
);
const _tatweel = 'ـ';

const Map<String, String> _fold = {
  // Alef forms → bare alef.
  'آ': 'ا', // آ
  'أ': 'ا', // أ
  'إ': 'ا', // إ
  'ٱ': 'ا', // ٱ alef wasla
  'ٲ': 'ا',
  'ٳ': 'ا',
  // Ya / alef maqsura.
  'ى': 'ي', // ى → ي
  'ی': 'ي', // Urdu/Farsi ی → ي
  'ے': 'ي', // Urdu ے → ي
  // Ta marbuta → ha; Urdu ha forms → ha.
  'ة': 'ه', // ة → ه
  'ہ': 'ه', // ہ
  'ھ': 'ه', // ھ
  'ۃ': 'ه',
  // Hamza carriers → the bare letter.
  'ؤ': 'و', // ؤ → و
  'ئ': 'ي', // ئ → ي
  // Urdu/Farsi kaf → Arabic kaf.
  'ک': 'ك', // ک
  // Small/standalone hamza dropped.
  'ء': '',
  // Arabic-Indic and Eastern digits → ASCII.
  '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
  '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
  '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  // Common Latin accents (transliteration, Filipino).
  'ā': 'a', 'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a',
  'ī': 'i', 'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ū': 'u', 'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'ō': 'o',
  'ñ': 'n', 'ḥ': 'h', 'ṣ': 's', 'ḍ': 'd', 'ṭ': 't', 'ẓ': 'z',
  'ʿ': '', 'ʾ': '', '‘': '', '’': '', "'": '', '`': '',
};

final _spaces = RegExp(r'\s+');
// Bidi isolates/marks and zero-width characters that sneak into copied text.
final _invisible = RegExp('[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]');

/// Folds [text] for matching. Collapses whitespace; keeps word boundaries.
String normalizeForSearch(String text) {
  var s = text.toLowerCase().replaceAll(_invisible, '');
  s = s.replaceAll(_marks, '').replaceAll(_tatweel, '');
  final out = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    out.write(_fold[ch] ?? ch);
  }
  return out.toString().replaceAll(_spaces, ' ').trim();
}

/// Whether [haystack] contains [query] after folding both.
bool searchMatches(String haystack, String query) {
  final q = normalizeForSearch(query);
  if (q.isEmpty) return true;
  return normalizeForSearch(haystack).contains(q);
}
