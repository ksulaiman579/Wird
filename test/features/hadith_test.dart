import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/hadith_repository.dart';
import 'package:wird/features/hadith/hadith_detail_screen.dart';
import 'package:wird/features/hadith/hadith_list_screen.dart';

import '../test_helpers/file_asset_bundle.dart';

// Pre-warmed outside of any `testWidgets` pump cycle (see
// test/test_helpers/file_asset_bundle.dart for why: this environment's
// `testWidgets` zone never lets a real disk read above ~40-50KB complete,
// no matter how it's pumped). Once `loadAll()` has populated the
// repository's internal cache here, calling it again inside a widget test
// resolves on a single microtask with no further I/O.
final _repository = HadithRepository(bundle: FileAssetBundle());

final _overrides = [hadithRepositoryProvider.overrideWithValue(_repository)];

void main() {
  setUpAll(() => _repository.loadAll());

  testWidgets('HadithListScreen lists hadith and filters by search', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: HadithListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // First card renders (NumberedContentCard, M23.6).
    expect(find.text('Actions Are Judged by Intentions'), findsOneWidget);
    // All / Bookmarked filter chips present.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Bookmarked'), findsOneWidget);

    // Searching narrows to the matching hadith — confirms the list holds
    // the later ones without depending on scroll/viewport mechanics.
    await tester.enterText(find.byType(TextField), 'Vastness');
    await tester.pumpAndSettle();
    expect(find.text("The Vastness of Allah's Forgiveness"), findsOneWidget);
    expect(find.text('Actions Are Judged by Intentions'), findsNothing);
  });

  testWidgets('HadithDetailScreen shows Arabic, translation, and summary', (
    tester,
  ) async {
    // A tall, wide viewport avoids depending on scroll order/cache-extent
    // behavior to get the whole (short, fixed-length) content list built.
    // devicePixelRatio must be reset too — otherwise the default 3.0 ratio
    // leaves a narrow *logical* width, wrapping the RTL Arabic block into
    // many lines and pushing everything after it past the cache extent.
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: HadithDetailScreen(hadithId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Actions Are Judged by Intentions'), findsOneWidget);
    expect(find.textContaining('niyyah'), findsWidgets);
    expect(find.text('Understand'), findsOneWidget);
  });
}
