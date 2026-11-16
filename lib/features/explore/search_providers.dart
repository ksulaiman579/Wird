import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../core/content/translation_pack_service.dart';
import '../../core/db/database.dart';
import '../../core/prefs/app_language_provider.dart';
import '../../core/search/search_index.dart';
import '../../core/search/search_index_builder.dart';
import '../quran_reader/reader_prefs.dart';

/// Changes whenever a content pack is installed or removed, so the index
/// picks up new downloads.
final _installedPacksProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.contentPacks)
        ..where((t) => t.status.equals('downloaded')))
      .watch()
      .map((rows) => Object.hashAll(
          [for (final r in rows) '${r.editionOrCollection}:${r.installedAt}']));
});

/// Built on first use of search and kept until the language, the chosen
/// translation or the set of downloaded packs changes.
final searchIndexProvider = FutureProvider<SearchIndex>((ref) async {
  final lang = ref.watch(appLanguageProvider).value ?? 'en';
  final prefs = ref.watch(readerPrefsProvider).value;
  await ref.watch(_installedPacksProvider.future);
  final editionId =
      prefs != null && prefs.showExtraTranslation ? prefs.extraEditionId : null;
  final translationPack = editionId == null
      ? null
      : await ref.read(translationPackServiceProvider).rawPack(editionId);
  final hadithPacks =
      await ref.read(hadithPackRepositoryProvider).rawInstalledPacks();
  final l = lookupAppLocalizations(Locale(lang));
  return buildSearchIndex(
    lang: lang,
    translationPack: translationPack,
    hadithPacks: hadithPacks,
    collectionNames: {
      'bukhari': l.hadithNameBukhari,
      'muslim': l.hadithNameMuslim,
      'abudawud': l.hadithNameAbudawud,
      'tirmidhi': l.hadithNameTirmidhi,
      'nasai': l.hadithNameNasai,
      'ibnmajah': l.hadithNameIbnmajah,
      'malik': l.hadithNameMalik,
    },
  );
});
