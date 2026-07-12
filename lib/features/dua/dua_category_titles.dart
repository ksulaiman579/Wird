import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/dua_repository.dart';
import '../../core/content/models/dua_models.dart';

/// Localized display title for a Hisnul Muslim category (chapter **header**
/// only) in the active locale, falling back to the bundled English title.
/// The dua Arabic text and translations are never localized here — only the
/// category label. Titles come from `assets/data/dua_title_l10n.json`, loaded
/// by [DuaRepository] alongside the categories.
String duaCategoryTitleFor(
  BuildContext context,
  WidgetRef ref,
  DuaCategory category,
) =>
    duaCategoryTitleById(context, ref, category.id, category.titleEnglish);

/// Id + explicit fallback variant, for call sites (e.g. an app-bar) that only
/// have the id and English title before the full record is in scope.
String duaCategoryTitleById(
  BuildContext context,
  WidgetRef ref,
  String categoryId,
  String fallback,
) =>
    ref.read(duaRepositoryProvider).localizedTitle(
          categoryId,
          Localizations.localeOf(context).languageCode,
          fallback,
        );
