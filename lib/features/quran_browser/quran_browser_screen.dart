import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/format.dart';
import '../../core/content/models/quran_models.dart';
import '../../shared/glass/glass.dart';
import 'mark_memorized_controller.dart';
import 'quran_providers.dart';

class QuranBrowserScreen extends ConsumerStatefulWidget {
  const QuranBrowserScreen({super.key});

  @override
  ConsumerState<QuranBrowserScreen> createState() =>
      _QuranBrowserScreenState();
}

class _QuranBrowserScreenState extends ConsumerState<QuranBrowserScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(quranMetaProvider);

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(AppLocalizations.of(context).quranTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_rounded),
            tooltip: AppLocalizations.of(context).quranMarkJuzMemorized,
            onPressed: _markJuzMemorized,
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      body: metaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (meta) {
          final filtered = _filterSurahs(meta.surahs, _query);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: AppLocalizations.of(context).quranSearchHint,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        enableBlur: false,
                        onTap: () => context.push('/quran/${surah.number}'),
                        child: Row(
                          children: [
                            CircleAvatar(child: Text('${surah.number}')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${surah.nameTransliterated} — ${surah.nameEnglish}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    // bidiMetaRow (Item B) keeps each part in
                                    // order under RTL instead of scattering
                                    // the numbers ("ayahs · meccan · Juz 1 7").
                                    bidiMetaRow([
                                      AppLocalizations.of(context)
                                          .quranAyahsCount(surah.ayahCount),
                                      surah.revelationType == 'meccan'
                                          ? AppLocalizations.of(context).quranMeccan
                                          : AppLocalizations.of(context).quranMedinan,
                                      AppLocalizations.of(context)
                                          .commonJuzN(surah.startJuz),
                                    ]),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                surah.nameArabic,
                                style: const TextStyle(
                                  fontFamily: 'UthmanicHafs',
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _markJuzMemorized() async {
    final l = AppLocalizations.of(context);
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (_) => const _JuzPickerDialog(),
    );
    if (selected == null || selected.isEmpty || !mounted) return;

    await markQuranMemorized(
      ref,
      selectionType: 'juz',
      selectionIds: selected.toList()..sort(),
      now: DateTime.now(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.quranMarkedForRevision)),
    );
  }

  List<SurahMeta> _filterSurahs(List<SurahMeta> surahs, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return surahs;

    final asNumber = int.tryParse(trimmed);
    return surahs.where((s) {
      if (asNumber != null) return s.number == asNumber;
      return s.nameEnglish.toLowerCase().contains(trimmed) ||
          s.nameTransliterated.toLowerCase().contains(trimmed) ||
          s.nameArabic.contains(trimmed);
    }).toList();
  }
}

/// Multi-select juz picker for marking whole juz as already memorized (U1).
/// Returns the chosen juz numbers, or null on cancel.
class _JuzPickerDialog extends StatefulWidget {
  const _JuzPickerDialog();

  @override
  State<_JuzPickerDialog> createState() => _JuzPickerDialogState();
}

class _JuzPickerDialogState extends State<_JuzPickerDialog> {
  final _selected = <int>{};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.quranMarkJuzMemorized),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var n = 1; n <= 30; n++)
                FilterChip(
                  label: Text(l.commonJuzN(n)),
                  selected: _selected.contains(n),
                  onSelected: (v) => setState(
                      () => v ? _selected.add(n) : _selected.remove(n)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: Text(l.quranMarkMemorizedConfirm),
        ),
      ],
    );
  }
}
