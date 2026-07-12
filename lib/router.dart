import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/db/database.dart';
import 'features/achievements/achievements_screen.dart';
import 'features/asma/asma_screen.dart';
import 'features/almanhaj/almanhaj_screen.dart';
import 'features/adhkar/adhkar_reader_screen.dart';
import 'features/downloads/downloads_screen.dart';
import 'features/downloads/library_screen.dart';
import 'features/dua/dua_categories_screen.dart';
import 'features/explore/explore_hub_screen.dart';
import 'features/explore/global_search_screen.dart';
import 'features/library/book_list_screen.dart';
import 'features/library/book_reader_screen.dart';
import 'features/library/knowledge_library_screen.dart';
import 'features/dua/dua_category_screen.dart';
import 'features/dua/dua_group_screen.dart';
import 'features/hadith/hadith_detail_screen.dart';
import 'features/hadith/hadith_list_screen.dart';
import 'features/hadith_reader/hadith_chapter_detail_screen.dart';
import 'features/hadith_reader/hadith_chapter_list_screen.dart';
import 'features/hadith_reader/hadith_collection_shelf_screen.dart';
import 'features/more/more_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/quran_browser/quran_browser_screen.dart';
import 'features/quran_browser/surah_screen.dart';
import 'features/qibla/qibla_screen.dart';
import 'features/quran_reader/quran_reader_screen.dart';
import 'features/reading/reading_hub_screen.dart';
import 'features/tasbih/tasbih_screen.dart';
import 'features/zakah/zakah_screen.dart';
import 'features/session/session_screen.dart';
import 'features/settings/about_screen.dart';
import 'features/settings/log_viewer_screen.dart';
import 'features/settings/data_sources_screen.dart';
import 'features/settings/plan_edit_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/today/today_screen.dart';
import 'shared/widgets/app_shell.dart';

/// Router is Riverpod-provided (rather than a bare top-level constant) so
/// its redirect logic can read the database: no local profile yet always
/// forces `/onboarding`; having one keeps the user out of it.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final db = ref.read(appDatabaseProvider);
      final hasProfile = (await db.select(db.userProfiles).get()).isNotEmpty;
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!hasProfile && !isOnboarding) return '/onboarding';
      if (hasProfile && isOnboarding) return '/';
      return null;
    },
    // Friendly not-found screen (Item A5) — never surface the raw
    // GoException text to the user.
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                "This page doesn't exist",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'The link may be old or mistyped.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/session',
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: '/read',
        builder: (context, state) {
          final surahParam = state.uri.queryParameters['surah'];
          final ayahParam = state.uri.queryParameters['ayah'];
          return QuranReaderScreen(
            initialSurah: int.tryParse(surahParam ?? ''),
            initialAyah: int.tryParse(ayahParam ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/adhkar/:period',
        builder: (context, state) =>
            AdhkarReaderScreen(period: state.pathParameters['period']!),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => GlobalSearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: '/knowledge',
        builder: (context, state) => const KnowledgeLibraryScreen(),
        routes: [
          GoRoute(
            path: 'book/:id',
            builder: (context, state) => BookReaderScreen(
              bookId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: ':discipline',
            builder: (context, state) =>
                BookListScreen(discipline: state.pathParameters['discipline']!),
          ),
        ],
      ),
      GoRoute(path: '/asma', builder: (context, state) => const AsmaScreen()),
      GoRoute(path: '/qibla', builder: (context, state) => const QiblaScreen()),
      GoRoute(path: '/zakah', builder: (context, state) => const ZakahScreen()),
      GoRoute(
        path: '/tasbih',
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/edit-plan',
        builder: (context, state) => const PlanEditScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings/logs',
        builder: (context, state) => const LogViewerScreen(),
      ),
      GoRoute(
        path: '/settings/data-sources',
        builder: (context, state) => const DataSourcesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          // "Read" tab (M16.2): Quran + Hadith share one bottom-nav slot
          // now — both route subtrees are unchanged (`/quran`, `/hadith`),
          // just grouped into a single branch with a hub landing screen.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reading',
                builder: (context, state) => const ReadingHubScreen(),
              ),
              GoRoute(
                path: '/quran',
                builder: (context, state) => const QuranBrowserScreen(),
                routes: [
                  GoRoute(
                    path: ':surah',
                    builder: (context, state) => SurahScreen(
                      surahNumber: int.parse(state.pathParameters['surah']!),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/hadith',
                builder: (context, state) =>
                    const HadithCollectionShelfScreen(),
                routes: [
                  GoRoute(
                    path: 'nawawi',
                    builder: (context, state) => const HadithListScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => HadithDetailScreen(
                          hadithId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'collections/:collection',
                    builder: (context, state) => HadithChapterListScreen(
                      collection: state.pathParameters['collection']!,
                    ),
                    routes: [
                      GoRoute(
                        path: ':chapter',
                        builder: (context, state) => HadithChapterDetailScreen(
                          collection: state.pathParameters['collection']!,
                          chapterNumber: state.pathParameters['chapter']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // "Explore" tab (M23.2): the renders' hub-page pattern for tools
          // that don't have their own bottom-nav slot (Hadith collections,
          // Qibla, Zakah, Tasbih). Positioned between Quran and Duas so
          // the nav order reads Home/Quran/Explore/Duas/More at rest, with
          // Al-Manhaj — the last branch below — reachable by swiping.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/duas',
                builder: (context, state) => const DuaCategoriesScreen(),
                routes: [
                  GoRoute(
                    path: 'group/:groupId',
                    builder: (context, state) => DuaGroupScreen(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':categoryId',
                    builder: (context, state) => DuaCategoryScreen(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
          // Kept last (M23 nav decision): not one of the 5 tabs visible at
          // rest (Home/Quran/Explore/Duas/More) — reached by pressing and
          // swiping the nav bar, plus a Home card / More entry.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/almanhaj',
                builder: (context, state) => const AlManhajScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
