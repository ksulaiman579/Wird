import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/glass/glass.dart';
import '../../shared/ui/ui.dart';
import '../dua/dua_providers.dart';
import '../quran_browser/quran_providers.dart';

/// Lightweight global search across content already held in memory — surah
/// names/numbers and Hisnul-Muslim dua-category titles (M23.4). Hadith
/// full-text search is a heavier, index-backed feature deferred to a later
/// task; this covers the two catalogues that are cheap to scan in-process.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );
  late String _query = widget.initialQuery.trim().toLowerCase();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(quranMetaProvider);
    final duasAsync = ref.watch(duaCategoriesProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).searchTitle)),
      contentPadding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: widget.initialQuery.isEmpty,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: AppLocalizations.of(context).searchHint,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(child: Text(AppLocalizations.of(context).searchTypePrompt))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      ..._surahResults(metaAsync),
                      ..._duaResults(duasAsync),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _surahResults(AsyncValue<dynamic> metaAsync) {
    final meta = metaAsync.value;
    if (meta == null) return const [];
    final matches = meta.surahs.where((s) {
      return s.nameTransliterated.toLowerCase().contains(_query) ||
          s.nameEnglish.toLowerCase().contains(_query) ||
          s.number.toString() == _query;
    }).toList();
    if (matches.isEmpty) return const [];
    return [
      _ResultHeader(AppLocalizations.of(context).searchSurahs),
      for (final s in matches)
        GlassCard(
          enableBlur: false,
          onTap: () => context.push('/quran/${s.number}'),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              CircleAvatar(radius: 16, child: Text('${s.number}')),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${s.nameTransliterated} · ${s.nameEnglish}'),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
    ];
  }

  List<Widget> _duaResults(AsyncValue<dynamic> duasAsync) {
    final hisnul = duasAsync.value;
    if (hisnul == null) return const [];
    final matches = hisnul.categories.where((c) {
      return c.titleEnglish.toLowerCase().contains(_query);
    }).toList();
    if (matches.isEmpty) return const [];
    return [
      _ResultHeader(AppLocalizations.of(context).duasTitle),
      for (final c in matches)
        GlassCard(
          enableBlur: false,
          onTap: () => context.push('/duas/${c.id}'),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const WirdIcon(WirdGlyph.palms, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(c.titleEnglish)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
    ];
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
