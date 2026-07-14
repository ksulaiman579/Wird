import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../core/content/hadith_pack_repository.dart';
import '../../shared/glass/glass.dart';
import 'hadith_reader_providers.dart';

class HadithChapterListScreen extends ConsumerWidget {
  const HadithChapterListScreen({super.key, required this.collection});

  final String collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(hadithChaptersProvider(collection));
    final title = hadithCollections[collection] ?? collection;

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(title)),
      contentPadding: EdgeInsets.zero,
      body: chaptersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(AppLocalizations.of(context).commonFailedToLoad('$error'))),
        data: (chapters) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                enableBlur: false,
                onTap: () => context
                    .push('/hadith/collections/$collection/${chapter.number}'),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chapter.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${chapter.count}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
