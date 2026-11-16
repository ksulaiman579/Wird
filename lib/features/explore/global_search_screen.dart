import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/search/search_index.dart';
import 'search_providers.dart';
import '../../core/theme/app_theme.dart' show quranTextStyle;
import '../../shared/glass/glass.dart';

/// Search across the bundled content (M28.3): ayah Arabic, translation and
/// transliteration, surah names, the Nawawi hadith, Hisnul Muslim duas and
/// the 99 Names. Arabic is matched without diacritics and with common
/// spelling variants folded (see arabic_normalizer.dart); "2:255" jumps to
/// that ayah. Shows sourced text only — nothing is generated.
/// Any Arabic-script letter (Arabic, Urdu).
final _rtlScript = RegExp('[؀-ۿ]');

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

enum _Filter { all, quran, hadith, duas, names }

extension on _Filter {
  Set<SearchKind>? get kinds => switch (this) {
        _Filter.all => null,
        _Filter.quran => {SearchKind.surah, SearchKind.ayah},
        _Filter.hadith => {SearchKind.hadith},
        _Filter.duas => {SearchKind.dua},
        _Filter.names => {SearchKind.name},
      };
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery.trim();
  _Filter _filter = _Filter.all;
  Timer? _debounce;

  // A new /search?q= link while search is open reuses this state; take its
  // word instead of keeping the old one (audit WQA-033).
  @override
  void didUpdateWidget(GlobalSearchScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialQuery != old.initialQuery) {
      _controller.text = widget.initialQuery;
      _query = widget.initialQuery.trim();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    // Wait for a short pause in typing instead of searching every keystroke.
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final indexAsync = ref.watch(searchIndexProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(l.searchTitle)),
      contentPadding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: widget.initialQuery.isEmpty,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l.searchHintAll,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: _onChanged,
              onSubmitted: (v) => setState(() => _query = v.trim()),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
              children: [
                for (final f in _Filter.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(switch (f) {
                        _Filter.all => l.commonAll,
                        _Filter.quran => l.navQuran,
                        _Filter.hadith => l.navHadith,
                        _Filter.duas => l.navDuas,
                        _Filter.names => l.searchNames,
                      }),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(child: Text(l.searchTypePrompt))
                : indexAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(l.searchNoResults)),
                    data: (index) {
                      final hits = index.search(_query, kinds: _filter.kinds);
                      if (hits.isEmpty) {
                        return Center(child: Text(l.searchNoResults));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: hits.length,
                        itemBuilder: (context, i) =>
                            _ResultCard(doc: hits[i].doc),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.doc});

  final SearchDoc doc;

  IconData get _icon => switch (doc.kind) {
        SearchKind.surah => Icons.menu_book_rounded,
        SearchKind.ayah => Icons.format_quote_rounded,
        SearchKind.hadith => Icons.auto_stories_rounded,
        SearchKind.dua => Icons.volunteer_activism_rounded,
        SearchKind.name => Icons.star_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      enableBlur: false,
      onTap: () => context.push(doc.route),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_icon, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doc.title,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (doc.arabic.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              doc.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: quranTextStyle.copyWith(
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
          if (doc.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              doc.text,
              // Urdu/Arabic translations read right-to-left; English stays
              // left-to-right even in an RTL UI.
              textDirection: _rtlScript.hasMatch(doc.text)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
