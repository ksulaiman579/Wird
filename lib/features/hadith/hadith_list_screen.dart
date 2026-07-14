import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/bookmark_service.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import 'hadith_providers.dart';

/// Which subset of the collection the list is showing.
enum _HadithFilter { all, bookmarked }

/// The 40 Hadith of an-Nawawi list (M23.6, render mtcfku): a cream search
/// field, All/Bookmarked filter chips, and one [NumberedContentCard] per
/// hadith (gold ordinal, title, translation teaser, an Arabic line, the
/// source as a reference line, share + bookmark actions). No per-hadith
/// audio exists for this collection, so the card's play button is hidden.
class HadithListScreen extends ConsumerStatefulWidget {
  const HadithListScreen({super.key});

  @override
  ConsumerState<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends ConsumerState<HadithListScreen> {
  String _query = '';
  _HadithFilter _filter = _HadithFilter.all;

  String _keyFor(int id) => 'h:nawawi:$id';

  @override
  Widget build(BuildContext context) {
    final hadithsAsync = ref.watch(hadithListProvider);
    final bookmarksAsync = ref.watch(_hadithBookmarksProvider);
    final bookmarkedKeys = {
      for (final b in bookmarksAsync.value ?? const []) b.contentKey,
    };

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).hadithNawawiTitle)),
      contentPadding: EdgeInsets.zero,
      body: hadithsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (hadiths) {
          final q = _query.trim().toLowerCase();
          final filtered = hadiths.where((h) {
            if (_filter == _HadithFilter.bookmarked &&
                !bookmarkedKeys.contains(_keyFor(h.id))) {
              return false;
            }
            if (q.isEmpty) return true;
            return h.titleEnglish.toLowerCase().contains(q) ||
                h.translation.toLowerCase().contains(q) ||
                h.id.toString() == q;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: AppLocalizations.of(context).hadithListSearch,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChipRow<_HadithFilter>(
                    options: const [
                      _HadithFilter.all,
                      _HadithFilter.bookmarked,
                    ],
                    selected: _filter,
                    labelOf: (f) =>
                        f == _HadithFilter.all
                            ? AppLocalizations.of(context).commonAll
                            : AppLocalizations.of(context).commonBookmarked,
                    onChanged: (f) => setState(() => _filter = f),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context).hadithListNoMatch))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final h = filtered[index];
                          final key = _keyFor(h.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NumberedContentCard(
                              number: h.id,
                              title: h.titleEnglish,
                              teaser: h.translation,
                              arabic: h.arabic,
                              citations: {h.source: null},
                              bookmarked: bookmarkedKeys.contains(key),
                              onBookmark: () => ref
                                  .read(bookmarkServiceProvider)
                                  .toggle(
                                    contentType: 'hadith',
                                    contentKey: key,
                                  ),
                              onTap: () =>
                                  context.push('/hadith/nawawi/${h.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final _hadithBookmarksProvider = StreamProvider((ref) {
  return ref.watch(bookmarkServiceProvider).watchAll('hadith');
});
