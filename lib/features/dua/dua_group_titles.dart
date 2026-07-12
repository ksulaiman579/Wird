import 'package:flutter/widgets.dart';

import 'package:wird/l10n/gen/app_localizations.dart';

/// Resolves a dua circumstance-group id (from [duaThemeGroups]) to its
/// localized display title. The group definitions stay pure data (no Flutter
/// imports) in dua_theme_groups.dart; this maps their ids onto the ARB keys
/// so the titles translate. Unknown ids fall back to the Duas tab title.
String duaGroupTitle(BuildContext context, String id) {
  final l = AppLocalizations.of(context);
  switch (id) {
    case 'daily-routine':
      return l.duaGroupDailyRoutine;
    case 'prayer':
      return l.duaGroupPrayer;
    case 'morning-evening-sleep':
      return l.duaGroupMorningEveningSleep;
    case 'distress-protection':
      return l.duaGroupDistressProtection;
    case 'food-social-family':
      return l.duaGroupFoodSocialFamily;
    case 'illness-death':
      return l.duaGroupIllnessDeath;
    case 'travel-hajj':
      return l.duaGroupTravelHajj;
    case 'remembrance-nature':
      return l.duaGroupRemembranceNature;
    default:
      return l.duasTitle;
  }
}
