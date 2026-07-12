/// RTL-safe text composition helpers (Item B / audit §5.5).
///
/// The app repeatedly garbles number+label strings under RTL because they
/// are built by manual concatenation (`'$count ayahs'`, `'$hrs hr $mins min'`,
/// `'33 - 33 - 34'`). When such a run sits inside a right-to-left line, the
/// bidi algorithm reorders the pieces — "7 ayahs · Meccan · Juz 1" collapses
/// to "ayahs · Meccan · Juz 1 7".
///
/// The real fix for most strings is to make them ICU-placeholder ARB keys
/// (`{count} ayahs`), which gen_l10n orders correctly per locale. These
/// helpers are for the residue: composite rows and multi-number labels that
/// can't become a single key. Pure Dart, no Flutter import, unit-tested.
library;

/// FIRST STRONG ISOLATE (U+2068) — opens a directional isolate whose
/// direction is taken from its first strong character. Written as an escape
/// because the literal char is invisible (analyzer warns on it).
const _fsi = '⁨';

/// POP DIRECTIONAL ISOLATE (U+2069) — closes the most recent isolate.
const _pdi = '⁩';

/// Wrap [s] in a first-strong bidi isolate so its internal order is fixed
/// regardless of the surrounding paragraph direction. Empty stays empty.
String bidiIsolate(String s) => s.isEmpty ? s : '$_fsi$s$_pdi';

/// Join metadata parts with a middle-dot separator, isolating each part so a
/// row like "7 ayahs · Meccan · Juz 1" keeps its order under RTL instead of
/// scattering the numbers. Blank parts are dropped.
String bidiMetaRow(Iterable<String> parts) => parts
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty)
    .map(bidiIsolate)
    .join(' · ');

/// Isolate a numeric sequence label (e.g. a tasbih "33 - 33 - 34" preset) so
/// the segments don't reverse under RTL.
String bidiSequence(Iterable<int> counts, {String separator = ' - '}) =>
    bidiIsolate(counts.join(separator));
