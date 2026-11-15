import 'package:flutter/widgets.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../core/hadith/hadith_grade.dart';

/// Collection name in the app's language (English source names stay in
/// `hadithCollections` for search and sharing fallbacks).
String hadithCollectionName(BuildContext context, String collection) {
  final l = AppLocalizations.of(context);
  return switch (collection) {
    'bukhari' => l.hadithNameBukhari,
    'muslim' => l.hadithNameMuslim,
    'abudawud' => l.hadithNameAbudawud,
    'tirmidhi' => l.hadithNameTirmidhi,
    'nasai' => l.hadithNameNasai,
    'ibnmajah' => l.hadithNameIbnmajah,
    'malik' => l.hadithNameMalik,
    _ => hadithCollections[collection] ?? collection,
  };
}

String hadithCollectionDescription(BuildContext context, String collection) {
  final l = AppLocalizations.of(context);
  return switch (collection) {
    'bukhari' => l.hadithDescBukhari,
    'muslim' => l.hadithDescMuslim,
    'abudawud' => l.hadithDescAbudawud,
    'tirmidhi' => l.hadithDescTirmidhi,
    'nasai' => l.hadithDescNasai,
    'ibnmajah' => l.hadithDescIbnmajah,
    'malik' => l.hadithDescMalik,
    _ => hadithCollectionDescriptions[collection] ?? '',
  };
}

String gradeLabel(BuildContext context, HadithAuthenticity a) {
  final l = AppLocalizations.of(context);
  return switch (a) {
    HadithAuthenticity.sahih => l.gradeSahih,
    HadithAuthenticity.hasan => l.gradeHasan,
    HadithAuthenticity.daif => l.gradeDaif,
    HadithAuthenticity.mawdu => l.gradeMawdu,
    HadithAuthenticity.ungraded => l.gradeUngraded,
  };
}

String gradeCaution(BuildContext context, HadithAuthenticity a) {
  final l = AppLocalizations.of(context);
  return switch (a) {
    HadithAuthenticity.daif => l.gradeCautionDaif,
    HadithAuthenticity.mawdu => l.gradeCautionMawdu,
    HadithAuthenticity.ungraded => l.gradeCautionUngraded,
    _ => '',
  };
}

/// Chapter title: the source's English book name, or the localized label
/// for the catch-all chapter.
String hadithChapterTitle(BuildContext context, HadithChapter chapter) =>
    chapter.number == hadithUncategorizedKey
        ? AppLocalizations.of(context).hadithOtherNarrations
        : chapter.title;
