/// Curated circumstance-theme grouping of the 130 Hisnul Muslim categories
/// (M20.4) — pure data, no Flutter imports, unit-tested for full coverage
/// in test/features/dua_theme_groups_test.dart. Category ids are the
/// `hm-cat-<n>` ids from assets/data/hisnul_muslim.json (n runs 1–131
/// with 74 absent upstream).
library;

class DuaThemeGroup {
  const DuaThemeGroup({
    required this.id,
    required this.title,
    required this.categoryIds,
  });

  final String id;
  final String title;
  final List<String> categoryIds;
}

List<String> _ids(List<int> numbers) =>
    [for (final n in numbers) 'hm-cat-$n'];

List<int> _range(int first, int last) =>
    [for (var n = first; n <= last; n++) n];

final duaThemeGroups = <DuaThemeGroup>[
  DuaThemeGroup(
    id: 'daily-routine',
    title: 'Daily routine',
    categoryIds: _ids(_range(1, 11)),
  ),
  DuaThemeGroup(
    id: 'prayer',
    title: 'Prayer & the mosque',
    categoryIds: _ids([..._range(12, 26), 32, 33, 42]),
  ),
  DuaThemeGroup(
    id: 'morning-evening-sleep',
    title: 'Morning, evening & sleep',
    categoryIds: _ids(_range(27, 31)),
  ),
  DuaThemeGroup(
    id: 'distress-protection',
    title: 'Distress & protection',
    categoryIds: _ids([
      ..._range(34, 41),
      ..._range(43, 46),
      82, 88, 92, 94, 122, 124, 125, 126, 128,
    ]),
  ),
  DuaThemeGroup(
    id: 'food-social-family',
    title: 'Food, family & social life',
    categoryIds: _ids([
      47, 48,
      ..._range(68, 73),
      ..._range(75, 81),
      ..._range(83, 87),
      ..._range(89, 91),
      93, 106, 108, 109,
      ..._range(112, 114),
      123, 127,
    ]),
  ),
  DuaThemeGroup(
    id: 'illness-death',
    title: 'Illness & bereavement',
    categoryIds: _ids(_range(49, 60)),
  ),
  DuaThemeGroup(
    id: 'travel-hajj',
    title: 'Travel, Hajj & Umrah',
    categoryIds: _ids([..._range(95, 105), ..._range(115, 121)]),
  ),
  DuaThemeGroup(
    id: 'remembrance-nature',
    title: 'Remembrance & nature',
    categoryIds: _ids([..._range(61, 67), 107, 110, 111, 129, 130, 131]),
  ),
];

DuaThemeGroup? duaThemeGroupById(String id) {
  for (final group in duaThemeGroups) {
    if (group.id == id) return group;
  }
  return null;
}

/// A curated shortlist of the most-reached-for daily duas, surfaced as an
/// "Essential" featured shelf on the Duas tab (M22.5) so the ~130
/// categories don't hide behind theme groups. Ordered by everyday
/// frequency, not book order.
const essentialDuaCategoryIds = <String>[
  'hm-cat-1', // waking up
  'hm-cat-10', // leaving home
  'hm-cat-11', // entering home
  'hm-cat-25', // after the prayer
  'hm-cat-28', // before sleeping
  'hm-cat-34', // worry & grief
  'hm-cat-49', // visiting the sick
  'hm-cat-129', // repentance & forgiveness
];
