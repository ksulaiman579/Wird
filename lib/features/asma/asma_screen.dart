import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/glass/glass.dart';

/// One of the 99 Names of Allah (Asma ul-Husna). The Arabic, transliteration
/// and short meaning are canonical; [explanation] is bundled commentary
/// pending scholarly sign-off (see DATA_SOURCES.md).
class AsmaName {
  const AsmaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.explanation,
  });

  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String explanation;

  factory AsmaName.fromJson(Map<String, dynamic> json) => AsmaName(
        number: json['number'] as int,
        arabic: json['arabic'] as String,
        transliteration: json['transliteration'] as String,
        meaning: json['meaning'] as String,
        explanation: json['explanation'] as String,
      );
}

/// Loads and caches the bundled 99-names list.
final asmaNamesProvider = FutureProvider<List<AsmaName>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/asma_ul_husna.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => AsmaName.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
});

class AsmaScreen extends ConsumerStatefulWidget {
  const AsmaScreen({super.key});

  @override
  ConsumerState<AsmaScreen> createState() => _AsmaScreenState();
}

class _AsmaScreenState extends ConsumerState<AsmaScreen> {
  String _query = '';

  bool _matches(AsmaName n, String q) {
    if (q.isEmpty) return true;
    final lower = q.toLowerCase();
    return n.transliteration.toLowerCase().contains(lower) ||
        n.meaning.toLowerCase().contains(lower) ||
        n.arabic.contains(q) ||
        n.number.toString() == q;
  }

  @override
  Widget build(BuildContext context) {
    final namesAsync = ref.watch(asmaNamesProvider);

    return GlassScaffold(
      appBar: GlassAppBar(title: Text(AppLocalizations.of(context).namesOfAllahTitle)),
      contentPadding: EdgeInsets.zero,
      body: namesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load: $e')),
        data: (names) {
          final filtered =
              names.where((n) => _matches(n, _query)).toList(growable: false);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: AppLocalizations.of(context).asmaSearchHint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context).asmaNoMatch))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) =>
                            _AsmaCard(name: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AsmaCard extends StatelessWidget {
  const _AsmaCard({required this.name});

  final AsmaName name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        enableBlur: false,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 4),
            leading: CircleAvatar(
              backgroundColor: gold.withValues(alpha: 0.15),
              child: Text(
                '${name.number}',
                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.transliteration,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(name.meaning, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 26,
                  ),
                ),
              ],
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
