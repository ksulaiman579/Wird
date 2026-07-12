import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wird/features/settings/about_screen.dart';
import 'package:wird/features/settings/data_sources_screen.dart';

void main() {
  testWidgets(
      'About screen is essentials-only: manhaj statement, license, '
      'collapsed credits, and a link to full data sources', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/settings/data-sources',
        builder: (context, state) => const DataSourcesScreen(),
      ),
    ]);
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Our foundation'), findsOneWidget);
    expect(find.textContaining("Ahlus Sunnah wal Jama'ah"), findsOneWidget);
    expect(find.textContaining('Salaf'), findsOneWidget);
    expect(find.text('License'), findsOneWidget);
    expect(find.textContaining('GNU General Public License'), findsOneWidget);
    // Support/donations moved to the Al-Manhaj tab (M16.1).
    expect(find.text('Support this project'), findsNothing);

    // Credits are collapsed by default — the full DATA_SOURCES.md dump no
    // longer lives inline here either (moved to DataSourcesScreen).
    expect(find.text('Credits & acknowledgements'), findsOneWidget);
    expect(find.text('fawazahmed0 / quran-api & hadith-api'), findsNothing);
    expect(find.textContaining('## Quran text'), findsNothing);

    await tester.tap(find.text('Credits & acknowledgements'));
    await tester.pumpAndSettle();
    expect(find.text('fawazahmed0 / quran-api & hadith-api'), findsOneWidget);
    expect(find.text('Tanzil.net'), findsOneWidget);

    await tester.ensureVisible(find.text('Data sources & full licenses'));
    await tester.tap(find.text('Data sources & full licenses'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Data Sources & Provenance'), findsOneWidget);
    expect(find.textContaining('## Quran text'), findsOneWidget);
  });
}
