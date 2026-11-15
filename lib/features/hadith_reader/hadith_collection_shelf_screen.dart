import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../core/platform/storage_warning.dart';
import '../../shared/glass/glass.dart';
import '../onboarding/onboarding_screen.dart' show hadithCollectionSizeMb;
import '../../core/prefs/app_language_provider.dart';
import 'hadith_l10n.dart';
import 'hadith_reader_providers.dart';

/// The Hadith tab root (M20.3, enhanced in Item 6.6 & 6.7): one unified shelf
/// clubbing the bundled "40 Hadith of an-Nawawi" with canonical collections,
/// featuring actual hadith counts, summarized titles, and expandable pill boxes.
class HadithCollectionShelfScreen extends ConsumerStatefulWidget {
  const HadithCollectionShelfScreen({super.key});

  @override
  ConsumerState<HadithCollectionShelfScreen> createState() =>
      _HadithCollectionShelfScreenState();
}

class _HadithCollectionShelfScreenState
    extends ConsumerState<HadithCollectionShelfScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final q = _searchQuery.trim().toLowerCase();

    final filteredCollections = hadithCollections.entries.where((entry) {
      if (q.isEmpty) return true;
      final desc = hadithCollectionDescriptions[entry.key] ?? '';
      return entry.value.toLowerCase().contains(q) ||
          desc.toLowerCase().contains(q) ||
          hadithCollectionName(context, entry.key).toLowerCase().contains(q) ||
          hadithCollectionDescription(context, entry.key)
              .toLowerCase()
              .contains(q);
    }).toList();

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).hadithCollectionsTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: AppLocalizations.of(context).hadithSearchCollections,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 16),
          if (q.isEmpty ||
              '40 hadith of an-nawawi'.contains(q) ||
              AppLocalizations.of(context)
                  .hadithNawawiTitle
                  .toLowerCase()
                  .contains(q))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                enableBlur: false,
                onTap: () => context.push('/hadith/nawawi'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AccentIconChip(icon: Icons.menu_book_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .hadithNawawiTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _CountPillBadge(
                                    label: AppLocalizations.of(context)
                                        .hadithCount(42),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context).hadithNawawiDesc,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          for (final entry in filteredCollections)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CollectionRow(
                collection: entry.key,
                name: hadithCollectionName(context, entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountPillBadge extends StatelessWidget {
  const _CountPillBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CollectionRow extends ConsumerStatefulWidget {
  const _CollectionRow({required this.collection, required this.name});

  final String collection;
  final String name;

  @override
  ConsumerState<_CollectionRow> createState() => _CollectionRowState();
}

class _CollectionRowState extends ConsumerState<_CollectionRow> {
  bool _expanded = false;

  Future<void> _download(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).hadithDownloadFailed;
    try {
      await ref
          .read(hadithPackRepositoryProvider)
          .downloadAndInstall(widget.collection);
      ref.invalidate(hadithPackLanguagesProvider(widget.collection));
      ref.invalidate(hadithChaptersProvider(widget.collection));
      ref.invalidate(hadithChapterEntriesProvider);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final packAsync =
        ref.watch(hadithPackStatusProvider(widget.collection));
    final status = packAsync.value?.status ?? 'notDownloaded';
    final progress = packAsync.value?.progress ?? 0;
    final count = hadithCollectionCounts[widget.collection];
    final description =
        hadithCollectionDescription(context, widget.collection);
    final lang = ref.watch(appLanguageProvider).value ?? 'en';
    final langs = status == 'downloaded' &&
            hadithExtraLanguages.containsKey(lang)
        ? ref.watch(hadithPackLanguagesProvider(widget.collection)).value
        : null;
    final missingLanguage = langs != null && !langs.contains(lang);

    return GlassCard(
      enableBlur: false,
      onTap: status == 'downloaded'
          ? () => context.push('/hadith/collections/${widget.collection}')
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AccentIconChip(icon: Icons.library_books_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (count != null) ...[
                          const SizedBox(width: 8),
                          _CountPillBadge(
                            label: AppLocalizations.of(context).hadithCount(count),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (status == 'downloading')
                      LinearProgressIndicator(value: progress)
                    else
                      Text(
                        switch (status) {
                          'downloaded' =>
                            AppLocalizations.of(context).hadithStatusDownloaded,
                          'failed' =>
                            AppLocalizations.of(context).hadithStatusFailed,
                          _ => AppLocalizations.of(context)
                              .hadithStatusNotDownloaded,
                        },
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.info_outline_rounded,
                  size: 20,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                tooltip: AppLocalizations.of(context).hadithCollectionDetails,
              ),
              switch (status) {
                'downloaded' => const Icon(Icons.chevron_right_rounded),
                'downloading' => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                _ => IconButton(
                    icon: const Icon(Icons.download_rounded),
                    onPressed: () async {
                      final ok = await confirmStorageBudget(
                        context,
                        estimatedMb:
                            hadithCollectionSizeMb[widget.collection] ?? 10,
                      );
                      if (ok && context.mounted) await _download(context);
                    },
                  ),
              },
            ],
          ),
          if (missingLanguage)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const Icon(Icons.translate_rounded, size: 18),
                label: Text(AppLocalizations.of(context).hadithGetLanguageText(
                  supportedAppLanguages
                      .firstWhere((o) => o.code == lang)
                      .nativeName,
                )),
                onPressed: () => _download(context),
              ),
            ),
          if (_expanded && description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
