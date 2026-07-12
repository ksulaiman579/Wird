import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../core/content/models/translation_pack_models.dart';
import '../../core/content/translation_pack_service.dart';
import '../../core/db/database.dart';
import '../../core/platform/storage_estimate.dart';
import '../../core/platform/storage_warning.dart';
import '../../shared/glass/glass.dart';
import '../onboarding/onboarding_screen.dart' show hadithCollectionSizeMb;

/// A single Quran translation pack is small (roughly this many MB) — no
/// per-edition size is tracked upstream, so this flat estimate is used
/// only to decide whether the M13.8 storage-budget dialog is worth
/// showing at all (it isn't, for a pack this size, unless the browser's
/// quota is already nearly exhausted).
const _translationPackSizeMb = 2.0;

final _translationAllowlistProvider =
    FutureProvider<TranslationAllowlist>((ref) {
  return ref.watch(translationPackServiceProvider).loadAllowlist();
});

final _translationPackStatusProvider =
    StreamProvider.family<ContentPack?, String>((ref, editionId) {
  return ref.watch(translationPackServiceProvider).watchPack(editionId);
});

final _hadithPackStatusProvider =
    StreamProvider.family<ContentPack?, String>((ref, collection) {
  return ref.watch(hadithPackRepositoryProvider).watchPack(collection);
});

/// Library screen (M13.7) — one place to add/remove every downloadable
/// content pack: Quran translation editions, Hadith collections, and
/// Quran recitation audio (the existing `DownloadsScreen`, linked rather
/// than re-embedded — it's a stateful native-only download manager with
/// its own scope/reciter controls that would be risky to inline here).
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Best-effort, web-only (a no-op on native, see storage_estimate.dart)
    // — asks the browser not to evict this origin's storage now that the
    // user has reached the screen where multi-MB downloads happen (M13.8).
    requestPersistentStorage();
  }

  @override
  Widget build(BuildContext context) {
    final allowlistAsync = ref.watch(_translationAllowlistProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).libraryTitle)),
      contentPadding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppLocalizations.of(context).libraryQuranAudio,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          GlassCard(
            enableBlur: false,
            onTap: () => context.push('/downloads'),
            child: Row(
              children: [
                const AccentIconChip(icon: Icons.graphic_eq_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).libraryRecitationDownloads,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).libraryQuranTranslations,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).librarySearchLanguages,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          ),
          const SizedBox(height: 8),
          allowlistAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text('Failed to load: $error'),
            data: (allowlist) {
              final editions = allowlist.editions
                  .where((e) =>
                      _query.isEmpty ||
                      e.language.toLowerCase().contains(_query) ||
                      e.author.toLowerCase().contains(_query))
                  .toList()
                ..sort((a, b) => a.language.compareTo(b.language));
              return Column(
                children: [
                  for (final edition in editions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TranslationPackRow(edition: edition),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).libraryHadithCollections,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final entry in hadithCollections.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HadithPackRow(collection: entry.key, name: entry.value),
            ),
        ],
      ),
    );
  }
}

class _TranslationPackRow extends ConsumerWidget {
  const _TranslationPackRow({required this.edition});

  final TranslationEditionEntry edition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(_translationPackStatusProvider(edition.id));
    final status = packAsync.value?.status ?? 'notDownloaded';
    final progress = packAsync.value?.progress ?? 0;

    return GlassCard(
      enableBlur: false,
      child: Row(
        children: [
          const AccentIconChip(icon: Icons.translate_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${edition.language} — ${edition.author}',
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (status == 'downloading')
                  LinearProgressIndicator(value: progress)
                else
                  Text(
                    switch (status) {
                      'downloaded' =>
                        AppLocalizations.of(context).libraryDownloaded,
                      'failed' =>
                        AppLocalizations.of(context).libraryDownloadFailed,
                      _ => AppLocalizations.of(context).libraryNotDownloaded,
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          switch (status) {
            'downloaded' => IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => ref
                    .read(translationPackServiceProvider)
                    .removePack(edition.id),
              ),
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
                    estimatedMb: _translationPackSizeMb,
                  );
                  if (ok) {
                    await ref
                        .read(translationPackServiceProvider)
                        .downloadAndInstall(edition);
                  }
                },
              ),
          },
        ],
      ),
    );
  }
}

class _HadithPackRow extends ConsumerWidget {
  const _HadithPackRow({required this.collection, required this.name});

  final String collection;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(_hadithPackStatusProvider(collection));
    final status = packAsync.value?.status ?? 'notDownloaded';
    final progress = packAsync.value?.progress ?? 0;
    final sizeMb = hadithCollectionSizeMb[collection];

    return GlassCard(
      enableBlur: false,
      child: Row(
        children: [
          const AccentIconChip(icon: Icons.library_books_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (status == 'downloading')
                  LinearProgressIndicator(value: progress)
                else
                  Text(
                    switch (status) {
                      'downloaded' => 'Downloaded',
                      'failed' => 'Download failed — tap to retry',
                      _ => sizeMb == null
                          ? 'Not downloaded'
                          : 'Not downloaded (~${sizeMb.toStringAsFixed(0)} MB)',
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          switch (status) {
            'downloaded' => IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => ref
                    .read(hadithPackRepositoryProvider)
                    .removePack(collection),
              ),
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
                    estimatedMb: sizeMb ?? 10,
                  );
                  if (ok) {
                    await ref
                        .read(hadithPackRepositoryProvider)
                        .downloadAndInstall(collection);
                  }
                },
              ),
          },
        ],
      ),
    );
  }
}
