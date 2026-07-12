import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import '../../shared/glass/glass.dart';
import 'dua_category_titles.dart';
import 'dua_group_titles.dart';
import 'dua_providers.dart';
import 'dua_theme_groups.dart';

/// Lists the Hisnul Muslim categories belonging to one theme group (M20.4).
class DuaGroupScreen extends ConsumerWidget {
  const DuaGroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = duaThemeGroupById(groupId);
    final categoriesAsync = ref.watch(duaCategoriesProvider);

    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(group == null
            ? AppLocalizations.of(context).duasTitle
            : duaGroupTitle(context, group.id)),
      ),
      contentPadding: EdgeInsets.zero,
      body: group == null
          ? Center(child: Text(AppLocalizations.of(context).duaUnknownGroup))
          : categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Failed to load: $error')),
              data: (hisnulMuslim) {
                final byId = {
                  for (final c in hisnulMuslim.categories) c.id: c,
                };
                final categories = [
                  for (final id in group.categoryIds)
                    if (byId[id] != null) byId[id]!,
                ];
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        enableBlur: false,
                        onTap: () => context.push('/duas/${category.id}'),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    duaCategoryTitleFor(context, ref, category),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)
                                        .duasDuaCount(category.duas.length),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
