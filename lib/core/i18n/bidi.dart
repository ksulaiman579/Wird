/// Bidirectional-text helpers.
///
/// In a right-to-left paragraph (Arabic, Urdu, …), a run of digits or a
/// number decorated with neutral symbols like `~`, `/`, `%` can be reordered
/// by the Unicode bidi algorithm relative to the surrounding text — e.g.
/// "~7 min" rendering as "7~ دقيقة", or "0/7" flipping. Per the Apple HIG
/// "Right to left" guidance, the digits within a number must never reorder;
/// only the order of a *sequence* may flip.
///
/// The fix is to wrap each number-like run in Unicode isolate characters
/// (First Strong Isolate … Pop Directional Isolate) so it renders as a single
/// self-contained run. In a left-to-right context this is a visual no-op, so
/// the same call is safe in every locale.
///
/// Pure Dart, no Flutter imports — keep it that way so it stays unit-testable.
class Bidi {
  Bidi._();

  /// First Strong Isolate (U+2068).
  static final String fsi = String.fromCharCode(0x2068);

  /// Pop Directional Isolate (U+2069).
  static final String pdi = String.fromCharCode(0x2069);

  /// Wrap [value] in an isolate so it doesn't reorder with neighbouring text.
  static String isolate(Object value) => '$fsi$value$pdi';

  /// Matches a number-like run: an optional leading neutral symbol, then digits
  /// (Western, Arabic-Indic, or Extended Arabic-Indic) with internal
  /// separators such as `. , : / - ~ %` and the Arabic decimal/thousands marks.
  static final RegExp _numberRun = RegExp(
    r'[~%]?[0-9٠-٩۰-۹]+'
    r'(?:[.,:/٫٬~%–—-]*[0-9٠-٩۰-۹]+)*'
    r'%?',
  );

  /// Isolate every number-like run inside [text] so numbers keep their internal
  /// order and stay attached to their symbols regardless of paragraph direction.
  static String isolateNumbers(String text) =>
      text.replaceAllMapped(_numberRun, (m) => isolate(m[0]!));
}
