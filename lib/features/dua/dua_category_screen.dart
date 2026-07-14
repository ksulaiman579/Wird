import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/models/dua_models.dart';
import '../../core/l10n/reading_locale.dart';
import '../../shared/glass/glass.dart';
import '../../shared/ui/verse_roundel.dart';
import 'dua_category_titles.dart';
import 'dua_providers.dart';

class DuaCategoryScreen extends ConsumerWidget {
  const DuaCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(duaCategoryProvider(categoryId));

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          categoryAsync.value == null
              ? AppLocalizations.of(context).duasTitle
              : duaCategoryTitleFor(context, ref, categoryAsync.value!),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      body: categoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (category) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: category.duas.length,
          itemBuilder: (context, index) => _DuaCard(
            dua: category.duas[index],
            number: index + 1,
          ),
        ),
      ),
    );
  }
}

/// A single dua, using the same collapse/expand + verse-roundel treatment as
/// the hadith cards (user request) so the readers read consistently. Collapsed
/// shows the roundel number + a 3-line Arabic preview; tapping expands to the
/// full Arabic plus — for non-Arabic UI locales — the transliteration and
/// translation, then the reference. When the UI is Arabic those Latin aids are
/// hidden ([showLatinReadingAids]).
class _DuaCard extends StatefulWidget {
  const _DuaCard({required this.dua, required this.number});

  final Dua dua;
  final int number;

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final theme = Theme.of(context);
    final showAids = showLatinReadingAids(Localizations.localeOf(context));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        enableBlur: false,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VerseRoundel(number: widget.number, size: 34),
                const Spacer(),
                if (dua.repetitions > 1)
                  Chip(label: Text('×${dua.repetitions}')),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                dua.arabic,
                maxLines: _expanded ? null : 3,
                overflow:
                    _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 22,
                  height: 1.8,
                ),
              ),
            ),
            if (_expanded) ...[
              if (showAids && dua.transliteration != null) ...[
                const SizedBox(height: 8),
                Text(
                  dua.transliteration!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
              if (showAids) ...[
                const SizedBox(height: 8),
                Text(dua.translation),
              ],
              const SizedBox(height: 8),
              Text(
                dua.reference,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
