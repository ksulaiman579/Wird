import 'dart:io';

import 'package:epub_plus/epub_plus.dart';
import 'package:flutter/material.dart';

import '../../shared/glass/glass.dart';

/// Pure-Dart in-app EPUB reader for Knowledge Library books (Item 1.21).
/// Parses `.epub` files via [epub_plus] and renders chapters with clean typography
/// and chapter navigation.
class EpubReaderScreen extends StatefulWidget {
  const EpubReaderScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.path,
  });

  final int bookId;
  final String title;
  final String path;

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late Future<EpubBook> _bookFuture;
  int _currentChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _bookFuture = _loadBook();
  }

  Future<EpubBook> _loadBook() async {
    final file = File(widget.path);
    final bytes = await file.readAsBytes();
    return EpubReader.readBook(bytes);
  }

  List<EpubChapter> _flattenChapters(List<EpubChapter> chapters) {
    final out = <EpubChapter>[];
    for (final c in chapters) {
      out.add(c);
      if (c.subChapters.isNotEmpty) {
        out.addAll(_flattenChapters(c.subChapters));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EpubBook>(
      future: _bookFuture,
      builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load EPUB: ${snapshot.error ?? "Unknown error"}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final book = snapshot.data!;
          final chapters = _flattenChapters(book.chapters);
          if (chapters.isEmpty) {
            return const Center(child: Text('This book has no chapters.'));
          }

          final idx = _currentChapterIndex.clamp(0, chapters.length - 1);
          final chapter = chapters[idx];
          final blocks = _parseHtmlToBlocks(chapter.htmlContent ?? '');

          return Column(
            children: [
              _ChapterHeader(
                title: chapter.title ?? 'Chapter ${idx + 1}',
                index: idx,
                total: chapters.length,
                onSelectChapter: () => _showChapterList(context, chapters),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: blocks.length + 1,
                  itemBuilder: (context, i) {
                    if (i == blocks.length) {
                      return _ChapterNavFooter(
                        index: idx,
                        total: chapters.length,
                        onPrev: idx > 0
                            ? () => setState(() => _currentChapterIndex = idx - 1)
                            : null,
                        onNext: idx < chapters.length - 1
                            ? () => setState(() => _currentChapterIndex = idx + 1)
                            : null,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _renderBlock(context, blocks[i]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
  }

  void _showChapterList(BuildContext context, List<EpubChapter> chapters) {
    showGlassSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chapters',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: chapters.length,
                  itemBuilder: (context, i) {
                    final selected = i == _currentChapterIndex;
                    return ListTile(
                      title: Text(
                        chapters[i].title ?? 'Chapter ${i + 1}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selected,
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() => _currentChapterIndex = i);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _renderBlock(BuildContext context, _TextContentBlock block) {
    final style = block.isHeading
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6);

    return SelectableText(block.text, style: style);
  }

  List<_TextContentBlock> _parseHtmlToBlocks(String html) {
    // Remove scripts and styles
    var text = html.replaceAll(
      RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false),
      '',
    );

    // Split around block-level tags
    final rawBlocks = text.split(
      RegExp(r'</?(p|div|h[1-6]|li|br|tr)[^>]*>', caseSensitive: false),
    );

    final out = <_TextContentBlock>[];
    for (var b in rawBlocks) {
      final isHeading = RegExp(
        r'<h[1-3][^>]*>',
        caseSensitive: false,
      ).hasMatch(b);
      final stripped = _decodeHtmlEntities(b.replaceAll(RegExp(r'<[^>]*>'), '').trim());
      if (stripped.isNotEmpty) {
        out.add(_TextContentBlock(text: stripped, isHeading: isHeading));
      }
    }
    return out;
  }

  String _decodeHtmlEntities(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _TextContentBlock {
  const _TextContentBlock({required this.text, required this.isHeading});
  final String text;
  final bool isHeading;
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.title,
    required this.index,
    required this.total,
    required this.onSelectChapter,
  });

  final String title;
  final int index;
  final int total;
  final VoidCallback onSelectChapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${index + 1}/$total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            tooltip: 'Table of Contents',
            icon: const Icon(Icons.list_rounded),
            onPressed: onSelectChapter,
          ),
        ],
      ),
    );
  }
}

class _ChapterNavFooter extends StatelessWidget {
  const _ChapterNavFooter({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Previous'),
          ),
          OutlinedButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
