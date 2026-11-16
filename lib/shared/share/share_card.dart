import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wird/l10n/gen/app_localizations.dart';
import '../ui/arabic_prose_text.dart';

/// Public web app — shared links open the exact passage there (and, on
/// Android with the app installed, in the app via app links).
const wirdWebBase = 'https://wird-alpha.vercel.app';

/// Full link for an in-app route such as `/read?surah=2&ayah=255`.
String wirdLink(String route) => '$wirdWebBase$route';

/// What one share card shows.
class SharePassage {
  const SharePassage({
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.route,
    this.translationRtl = false,
  });

  final String arabic;
  final String translation;
  final String reference;
  final String route;
  final bool translationRtl;

  String get asText => [
        arabic,
        if (translation.isNotEmpty) translation,
        '— $reference',
        wirdLink(route),
      ].join('\n\n');
}

/// Opens a preview of the card with "Share image" and "Share text".
Future<void> showShareSheet(BuildContext context, SharePassage passage) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ShareSheet(passage: passage),
  );
}

/// A small share button for card headers.
class ShareCardButton extends StatelessWidget {
  const ShareCardButton({super.key, required this.passage});

  final SharePassage Function() passage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).commonShare,
      icon: const Icon(Icons.share_outlined),
      onPressed: () => showShareSheet(context, passage()),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.passage});
  final SharePassage passage;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _shareImage() async {
    setState(() => _busy = true);
    try {
      final render = _boundary.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (bytes == null) throw StateError('no image');
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes.buffer.asUint8List(),
              mimeType: 'image/png', name: 'wird.png'),
        ],
        text: wirdLink(widget.passage.route),
      ));
    } catch (_) {
      // Some browsers can't share files — fall back to text.
      await _shareText();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() =>
      SharePlus.instance.share(ShareParams(text: widget.passage.asText));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _boundary,
              child: ShareCard(passage: widget.passage),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _shareImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(l.shareAsImage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _shareText,
                    icon: const Icon(Icons.notes_rounded),
                    label: Text(l.shareAsText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The card itself — fixed light colours (emerald + gold on cream) so it
/// looks the same whatever theme the sender uses.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.passage});

  final SharePassage passage;

  static const _cream = Color(0xFFF8F0D8);
  static const _emerald = Color(0xFF244C3A);
  static const _gold = Color(0xFFB08A2E);
  static const _ink = Color(0xFF2B2A26);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ArabicProseText(
            passage.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 24,
              height: 1.9,
              color: _ink,
            ),
          ),
          if (passage.translation.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              passage.translation,
              textAlign: TextAlign.center,
              textDirection: passage.translationRtl
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: const TextStyle(fontSize: 15, height: 1.5, color: _ink),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            passage.reference,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _emerald,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: _gold, height: 1, thickness: 0.8),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const Image(
                  image: AssetImage('assets/icon/logo_display.png'),
                  width: 22,
                  height: 22,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Wird · wird-alpha.vercel.app',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 12,
                  color: _emerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
