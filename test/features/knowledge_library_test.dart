import 'package:wird/l10n/gen/app_localizations.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/content/library_repository.dart';
import 'package:wird/features/library/knowledge_library_screen.dart';
import 'package:wird/shared/ui/ui.dart';

/// Reads assets from disk AND decodes strings inline. The default
/// CachingAssetBundle.loadString offloads large (>50KB) payloads to a
/// `compute()` isolate, which hangs inside this environment's `testWidgets`
/// zone — and the knowledge catalogue is ~540KB. Overriding loadString to
/// decode on the main isolate sidesteps that.
class _DirectBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return utf8.decode(await File(key).readAsBytes());
  }
}

void main() {
  final repo = LibraryRepository(bundle: _DirectBundle());

  // Pre-warm the catalogue cache outside any testWidgets pump cycle (same
  // approach as hadith_test) — once loadAll() has populated the repo's
  // in-memory cache, disciplineCounts()/books() resolve on a single
  // microtask inside the widget test with no further disk I/O.
  setUpAll(() => repo.loadAll());

  testWidgets('hub shows discipline cards with real book counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [libraryRepositoryProvider.overrideWithValue(repo)],
        // The hub itself only needs the repository; the book list (which
        // pulls in the DB + downloader plugin) is exercised on-device, not
        // here — same plugin-boundary rule as the audio/download screens.
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: KnowledgeLibraryScreen()),
      ),
    );
    // Bounded pump loop rather than pumpAndSettle (the parchment/glass
    // chrome + async catalogue load never reach a fully-idle frame in this
    // environment) — pump until the discipline cards have loaded.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Aqeedah (Creed)').evaluate().isNotEmpty) break;
    }

    expect(find.text('Knowledge Library'), findsWidgets);
    // English (default) has Aqeedah books; the card + a "<n> books" count.
    expect(find.text('Aqeedah (Creed)'), findsOneWidget);
    expect(find.textContaining('books'), findsWidgets);
    expect(find.byType(HubCard), findsWidgets);

    // Language chips are present and English is selected by default.
    expect(find.widgetWithText(ChoiceChip, 'English'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Arabic'), findsOneWidget);
  });
}
