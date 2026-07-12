import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wird/features/reading/reading_hub_screen.dart';

GoRouter _hubRouter() => GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const ReadingHubScreen()),
      GoRoute(path: '/quran', builder: (context, state) => const Text('QURAN')),
      GoRoute(path: '/hadith', builder: (context, state) => const Text('HADITH')),
      GoRoute(path: '/read', builder: (context, state) => const Text('READER')),
      GoRoute(
          path: '/session', builder: (context, state) => const Text('SESSION')),
    ]);

void main() {
  testWidgets('The Holy Quran hub links to the Quran and Hadith subtrees',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final router = _hubRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: router)),
    );
    await tester.pumpAndSettle();

    // First boot (no persisted last-read): the reading card invites a
    // fresh start, not a resume (Item 1.10).
    expect(find.text('Start Reading'), findsOneWidget);
    expect(find.text('Continue Reading'), findsNothing);
    expect(find.text('Surah index'), findsOneWidget);

    // The Surah Index card's gold CTA opens the browser subtree.
    await tester.tap(find.text('Index list'));
    await tester.pumpAndSettle();
    expect(find.text('QURAN'), findsOneWidget);
  });

  testWidgets('shows Continue Reading once a read has been persisted',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'quran_reader_prefs':
          '{"lastSurah":2,"lastAyah":5,"hasReadBefore":true}',
    });
    final router = _hubRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: router)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue Reading'), findsOneWidget);
    expect(find.text('Start Reading'), findsNothing);
  });
}
