/// Pure hadith-authenticity classification — no Flutter import, unit-tested
/// directly. This is the content-integrity core of the Hadith collections
/// feature (M23.11): it turns the raw upstream `grades` list into a single,
/// honestly-labelled authenticity verdict so that a weak (ḍaʿīf) or
/// fabricated (mawḍūʿ) narration is NEVER presented to the user as if it
/// were authentic.
///
/// Vetting model (mirrors the Al-Manhaj curriculum's approach):
/// - Every hadith carries a visible grade badge; grades are taken from the
///   source's own graders (e.g. al-Albānī, Salīm al-Hilālī), not invented.
/// - Where the source provides no grade, we say so ("ungraded") rather than
///   guessing — the "Do Not Guess" rule.
/// - Ṣaḥīḥ al-Bukhārī and Ṣaḥīḥ Muslim are treated as authentic by the
///   agreed status of the two Ṣaḥīḥs when no per-hadith grade is attached.
library;

enum HadithAuthenticity {
  sahih,
  hasan,
  daif,
  mawdu,
  ungraded,
}

extension HadithAuthenticityInfo on HadithAuthenticity {
  /// Short display label for the badge.
  String get label => switch (this) {
        HadithAuthenticity.sahih => 'Ṣaḥīḥ',
        HadithAuthenticity.hasan => 'Ḥasan',
        HadithAuthenticity.daif => 'Ḍaʿīf',
        HadithAuthenticity.mawdu => 'Mawḍūʿ',
        HadithAuthenticity.ungraded => 'Ungraded',
      };

  /// Whether this verdict should be shown with a caution (weak, fabricated
  /// or unverified) — the UI uses this to warn the reader.
  bool get isCautionary => switch (this) {
        HadithAuthenticity.sahih || HadithAuthenticity.hasan => false,
        _ => true,
      };

  /// A one-line reader caution for cautionary verdicts; empty otherwise.
  String get caution => switch (this) {
        HadithAuthenticity.daif =>
          'Weak narration — do not rely on it for rulings or creed.',
        HadithAuthenticity.mawdu =>
          'Reported as fabricated — not to be attributed to the Prophet ﷺ.',
        HadithAuthenticity.ungraded =>
          'No authenticity grade available in the source — verify before acting on it.',
        _ => '',
      };
}

/// The two Ṣaḥīḥs, accepted as authentic by the agreed status of the books
/// themselves when the source attaches no explicit per-hadith grade.
const _sahihCollections = {'bukhari', 'muslim'};

/// Classifies one grade string (grader's verdict) into a category. Checks
/// the most-cautious markers first so that e.g. "Daʿīf jiddan" and
/// "Hasan Sahih" resolve correctly.
HadithAuthenticity classifyGradeString(String raw) {
  final g = raw.toLowerCase();
  if (g.isEmpty) return HadithAuthenticity.ungraded;
  if (g.contains('maudu') ||
      g.contains('mawdu') ||
      g.contains('fabricat') ||
      g.contains('موضوع')) {
    return HadithAuthenticity.mawdu;
  }
  if (g.contains('munkar') || g.contains('batil') || g.contains('باطل')) {
    return HadithAuthenticity.daif;
  }
  if (g.contains("da'if") ||
      g.contains('daif') ||
      g.contains('daeef') ||
      g.contains('weak') ||
      g.contains('ضعيف')) {
    return HadithAuthenticity.daif;
  }
  // "Sahih" (incl. "Hasan Sahih", "Sahih li ghairihi") counts as authentic
  // grade so long as no weakening marker matched above.
  if (g.contains('sahih') || g.contains('صحيح') || g.contains('authentic')) {
    return HadithAuthenticity.sahih;
  }
  if (g.contains('hasan') || g.contains('حسن') || g.contains('good')) {
    return HadithAuthenticity.hasan;
  }
  return HadithAuthenticity.ungraded;
}

/// The verdict shown for a hadith: its category plus the grader's own words
/// (for transparency) where available.
class HadithGrade {
  const HadithGrade(this.authenticity, {this.rawGrade, this.grader});

  final HadithAuthenticity authenticity;

  /// The grader's verbatim verdict (e.g. "Sahih li ghairihi"), if any.
  final String? rawGrade;

  /// The grader's name (e.g. "al-Albani"), if the source names one.
  final String? grader;
}

/// Resolves the authenticity verdict for a hadith from its `grades` list
/// (each entry a `{name, grade}` map, as delivered by the upstream source)
/// and the collection it belongs to.
///
/// Takes the first grader's verdict as the representative grade (the source
/// lists the primary verifier first). Falls back to the collection's agreed
/// status for the two Ṣaḥīḥs, else "ungraded" — never guessed.
HadithGrade resolveHadithGrade(List<dynamic> grades, String collection) {
  for (final entry in grades) {
    if (entry is Map) {
      final gradeText = (entry['grade'] as String?)?.trim() ?? '';
      if (gradeText.isNotEmpty) {
        return HadithGrade(
          classifyGradeString(gradeText),
          rawGrade: gradeText,
          grader: (entry['name'] as String?)?.trim(),
        );
      }
    } else if (entry is String && entry.trim().isNotEmpty) {
      return HadithGrade(classifyGradeString(entry),
          rawGrade: entry.trim());
    }
  }
  if (_sahihCollections.contains(collection)) {
    return const HadithGrade(HadithAuthenticity.sahih);
  }
  return const HadithGrade(HadithAuthenticity.ungraded);
}

/// Grade for a Nawawi-forty hadith, derived from its stated source line
/// (e.g. "Bukhari & Muslim", "Muslim", "Tirmidhi"). The Forty carry no
/// per-hadith grader verdicts; per the Do-Not-Guess rule we only mark
/// ṣaḥīḥ what the two Ṣaḥīḥs carry by their agreed status, otherwise we
/// defer to any grade words present in the source text, else "ungraded".
HadithGrade nawawiGradeFromSource(String source) {
  final s = source.toLowerCase();
  if (s.contains('bukhari') || s.contains('muslim')) {
    return const HadithGrade(HadithAuthenticity.sahih);
  }
  final classified = classifyGradeString(source);
  return HadithGrade(
    classified,
    rawGrade: classified == HadithAuthenticity.ungraded ? null : source,
  );
}

/// A short, neutral note on the overall status of each collection, shown as
/// a header so the reader understands the collection's authenticity context.
String collectionAuthenticityNote(String collection) {
  switch (collection) {
    case 'bukhari':
    case 'muslim':
      return 'One of the two most authentic books after the Qur\'an. Its '
          'hadith are accepted as authentic (ṣaḥīḥ).';
    case 'malik':
      return 'The Muwaṭṭaʾ of Imām Mālik — one of the earliest collections. '
          'Grades shown are from the noted verifier.';
    case 'abudawud':
    case 'tirmidhi':
    case 'nasai':
    case 'ibnmajah':
      return 'A Sunan collection containing hadith of varying authenticity. '
          'Each hadith shows its grade — verify weak (ḍaʿīf) narrations '
          'before relying on them.';
    default:
      return 'Each hadith shows its authenticity grade where the source '
          'provides one.';
  }
}
