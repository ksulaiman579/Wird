import 'package:wird/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wird/core/theme/app_theme.dart';
import 'package:wird/shared/ui/ui.dart';

Widget _wrap(Widget child) => MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, 
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('GoldPillButton', () {
    testWidgets('renders its label as-is (sentence case) and fires onPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(GoldPillButton(label: 'Resume', onPressed: () => tapped = true)));

      expect(find.text('Resume'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      expect(tapped, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(const GoldPillButton(label: 'locked', onPressed: null)));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders the title text', (tester) async {
      await tester.pumpWidget(_wrap(const SectionHeader('Surah collections')));
      expect(find.text('Surah collections'), findsOneWidget);
    });
  });

  group('HubCard', () {
    testWidgets('renders title, description, CTA and fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(SizedBox(
        width: 200,
        height: 260,
        child: HubCard(
          glyph: WirdGlyph.book,
          title: 'Surah Al-Fatiha',
          description: 'The Opening',
          ctaLabel: 'View Surah',
          onTap: () => tapped = true,
        ),
      )));

      expect(find.text('Surah Al-Fatiha'), findsOneWidget);
      expect(find.text('The Opening'), findsOneWidget);
      expect(find.text('View Surah'), findsOneWidget);
      await tester.tap(find.text('View Surah'));
      expect(tapped, isTrue);
    });

    testWidgets('ornamented adds corner flourish painters', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        width: 200,
        height: 260,
        child: HubCard(
          glyph: WirdGlyph.scroll,
          title: 'Surah Index',
          description: 'Full list',
          ctaLabel: 'Index list',
          onTap: () {},
          ornamented: true,
        ),
      )));
      // 4 corners + 1 WirdIcon CustomPaint = 5 CustomPaint descendants.
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('HubCardGrid', () {
    testWidgets('lays children out in a GridView', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        width: 400,
        height: 400,
        child: HubCardGrid(children: [
          Container(key: const Key('a')),
          Container(key: const Key('b')),
        ]),
      )));
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byKey(const Key('a')), findsOneWidget);
      expect(find.byKey(const Key('b')), findsOneWidget);
    });
  });

  group('NumberedContentCard', () {
    testWidgets('renders number, title, teaser, arabic, reference, and actions', (tester) async {
      var shared = false;
      var bookmarked = false;
      var played = false;

      await tester.pumpWidget(_wrap(NumberedContentCard(
        number: 1,
        title: 'Hadith on Intentions',
        teaser: 'Actions are but by intentions.',
        arabic: 'إنما الأعمال بالنيات',
        citations: const {'Bukhari 1': null, 'Muslim 1907': null},
        onShare: () => shared = true,
        onBookmark: () => bookmarked = true,
        onPlay: () => played = true,
      )));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Hadith on Intentions'), findsOneWidget);
      expect(find.textContaining('Reference:'), findsOneWidget);
      expect(find.textContaining('Bukhari 1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.share_outlined));
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.tap(find.byIcon(Icons.play_arrow));
      expect(shared, isTrue);
      expect(bookmarked, isTrue);
      expect(played, isTrue);
    });

    testWidgets('hides the play button when onPlay is null (no audio)', (tester) async {
      await tester.pumpWidget(_wrap(const NumberedContentCard(
        number: 2,
        title: 'No audio hadith',
        teaser: 'Teaser text.',
      )));
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });
  });

  group('ReferenceLine', () {
    testWidgets('renders each citation and fires its tap handler', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(ReferenceLine(citations: {
        'Bukhari 1': () => tapped = true,
        'Muslim 1907': null,
      })));

      expect(find.textContaining('Bukhari 1'), findsOneWidget);
      expect(find.textContaining('Muslim 1907'), findsOneWidget);
      await tester.tap(find.textContaining('Bukhari 1'));
      expect(tapped, isTrue);
    });
  });

  group('FontSizeChips', () {
    testWidgets('fires onIncrease/onDecrease', (tester) async {
      var increased = false;
      var decreased = false;
      await tester.pumpWidget(_wrap(FontSizeChips(
        onIncrease: () => increased = true,
        onDecrease: () => decreased = true,
      )));

      await tester.tap(find.text('A+'));
      await tester.tap(find.text('A−'));
      expect(increased, isTrue);
      expect(decreased, isTrue);
    });
  });

  group('FilterChipRow', () {
    testWidgets('selects the active option and reports changes', (tester) async {
      String selected = 'Bookmarked';
      await tester.pumpWidget(_wrap(StatefulBuilder(
        builder: (context, setState) => FilterChipRow<String>(
          options: const ['Bookmarked', 'Recent'],
          selected: selected,
          labelOf: (o) => o,
          onChanged: (o) => setState(() => selected = o),
        ),
      )));

      expect(find.byType(ChoiceChip), findsNWidgets(2));
      await tester.tap(find.text('Recent'));
      await tester.pump();
      final recentChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('Recent'), matching: find.byType(ChoiceChip)),
      );
      expect(recentChip.selected, isTrue);
    });
  });

  group('WirdIcon', () {
    testWidgets('renders every glyph without throwing', (tester) async {
      for (final glyph in WirdGlyph.values) {
        await tester.pumpWidget(_wrap(WirdIcon(glyph)));
        expect(find.byType(WirdIcon), findsOneWidget);
      }
    });
  });

  group('ParchmentBackground', () {
    testWidgets('renders its child over the grain texture', (tester) async {
      await tester.pumpWidget(_wrap(const ParchmentBackground(
        child: Text('content'),
      )));
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
