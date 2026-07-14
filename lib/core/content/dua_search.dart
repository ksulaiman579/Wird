import 'models/dua_models.dart';

/// Intent synonyms so a plain-language search finds a category whose title
/// uses scholarly wording. e.g. "guidance"/"decision" -> Istikharah, which
/// is titled "seeking Allah's Counsel". Keys and values are all lowercase.
///
/// Each entry maps a word the user is likely to type to extra terms that
/// appear in the relevant category title or dua text. Kept deliberately
/// small — the primary recall comes from searching the dua translations
/// themselves (see [duaSearchMatches]).
const Map<String, List<String>> _duaSynonyms = {
  'guidance': ['counsel', 'istikhar', 'guide', 'decision'],
  'decision': ['counsel', 'istikhar', 'guide'],
  'choose': ['counsel', 'istikhar'],
  'anxiety': ['worry', 'grief', 'distress', 'anguish'],
  'stress': ['worry', 'grief', 'distress'],
  'sad': ['grief', 'worry', 'sorrow'],
  'depression': ['grief', 'worry', 'distress'],
  'debt': ['loan', 'setting of a debt'],
  'money': ['debt', 'sustenance', 'provision'],
  'sick': ['illness', 'pain', 'ill'],
  'sickness': ['illness', 'pain'],
  'sleep': ['bed', 'lying down'],
  'forgive': ['repentance', 'forgiveness', 'pardon'],
  'protection': ['refuge', 'evil', 'shelter'],
  'travel': ['journey', 'traveller', 'traveler', 'traveling'],
};

String _norm(String s) => s.toLowerCase().trim();

/// Whether [category] matches the free-text [query]. Matches when the query
/// (or one of its synonym expansions) appears in the category title, in any
/// of its duas' translations, or in a dua reference. This makes plain
/// searches like "guidance" surface Istikharah even though the title says
/// "Counsel", because the dua text itself mentions guidance.
bool duaCategoryMatches(DuaCategory category, String query) {
  final q = _norm(query);
  if (q.isEmpty) return true;

  final terms = <String>{q, ..._duaSynonyms[q] ?? const []};

  final title = category.titleEnglish.toLowerCase();
  for (final t in terms) {
    if (title.contains(t)) return true;
  }
  for (final dua in category.duas) {
    final hay = '${dua.translation} ${dua.reference}'.toLowerCase();
    for (final t in terms) {
      if (hay.contains(t)) return true;
    }
  }
  return false;
}

/// Filter [categories] to those matching [query], preserving input order.
List<DuaCategory> duaSearchMatches(
  Iterable<DuaCategory> categories,
  String query,
) =>
    categories.where((c) => duaCategoryMatches(c, query)).toList();
