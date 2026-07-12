import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:wird/l10n/gen/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/ayah_audio_urls.dart' show defaultReciter, reciters;
import '../../core/audio/download_plan.dart';
import '../../core/chunking/ayah_grouper.dart' show parseQuranContentKey;
import '../../core/db/database.dart';
import '../quran_browser/quran_providers.dart';
import '../today/today_providers.dart' show srsItemsStreamProvider;
import 'download_providers.dart';

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  return '${(bytes / (1024 * 1024)).toStringAsFixed(0)} MB';
}

/// Native only — `background_downloader` has no web support. On web this
/// shows a note instead of the download manager (see M4.3/M8's `kIsWeb`
/// gating).
class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  String _scope = 'plan';
  String _reciter = defaultReciter;
  bool _wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).downloadsTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context).downloadsWebNote,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final metaAsync = ref.watch(quranMetaProvider);
    final itemsAsync = ref.watch(srsItemsStreamProvider);
    final statesAsync = ref.watch(downloadStatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).downloadsTitle)),
      body: metaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Failed to load: $error')),
        data: (meta) {
          final ayahCounts = {
            for (final s in meta.surahs) s.number: s.ayahCount,
          };
          final planSurahs = (itemsAsync.value ?? const <SrsItem>[])
              .where((i) => i.contentType == 'quran')
              .map((i) => parseQuranContentKey(i.contentKey)?.surah)
              .whereType<int>()
              .toSet();

          final plan = buildDownloadPlan(
            scope: _scope,
            ayahCountsBySurah: ayahCounts,
            planSurahs: planSurahs,
          );
          final states = statesAsync.value ?? const <DownloadStateData>[];
          final statesBySurah = {for (final s in states) s.surahNumber: s};
          final downloadedCount =
              plan.where((p) => statesBySurah[p.surah]?.status == 'downloaded').length;

          return Column(
            children: [
              _SummaryCard(
                scope: _scope,
                onScopeChanged: (v) => setState(() => _scope = v),
                reciter: _reciter,
                onReciterChanged: (v) => setState(() => _reciter = v),
                wifiOnly: _wifiOnly,
                onWifiOnlyChanged: (v) => setState(() => _wifiOnly = v),
                estimatedBytes: totalEstimatedBytes(plan, _reciter),
                downloadedCount: downloadedCount,
                totalCount: plan.length,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: plan.length,
                  itemBuilder: (context, index) {
                    final surahPlan = plan[index];
                    final surahMeta =
                        meta.surahs.firstWhere((s) => s.number == surahPlan.surah);
                    final state = statesBySurah[surahPlan.surah];
                    final manager = ref.read(audioDownloadManagerProvider);

                    return _SurahDownloadRow(
                      title: surahMeta.nameTransliterated,
                      state: state,
                      onDownload: () => manager.enqueueSurah(
                        surah: surahPlan.surah,
                        ayahs: [
                          for (var a = 1; a <= surahPlan.ayahCount; a++) a,
                        ],
                        reciter: _reciter,
                        wifiOnly: _wifiOnly,
                      ),
                      onPause: () => manager.pauseSurah(surahPlan.surah),
                      onResume: () => manager.resumeSurah(surahPlan.surah),
                      onDelete: () => manager.deleteSurah(surahPlan.surah),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.scope,
    required this.onScopeChanged,
    required this.reciter,
    required this.onReciterChanged,
    required this.wifiOnly,
    required this.onWifiOnlyChanged,
    required this.estimatedBytes,
    required this.downloadedCount,
    required this.totalCount,
  });

  final String scope;
  final ValueChanged<String> onScopeChanged;
  final String reciter;
  final ValueChanged<String> onReciterChanged;
  final bool wifiOnly;
  final ValueChanged<bool> onWifiOnlyChanged;
  final int estimatedBytes;
  final int downloadedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$downloadedCount of $totalCount surahs downloaded'),
            const SizedBox(height: 8),
            Text('Estimated size: ${_formatBytes(estimatedBytes)}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'plan',
                    label: Text(AppLocalizations.of(context).downloadsMyPlan)),
                ButtonSegment(
                    value: 'full',
                    label:
                        Text(AppLocalizations.of(context).downloadsFullQuran)),
              ],
              selected: {scope},
              onSelectionChanged: (s) => onScopeChanged(s.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: reciter,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).readerReciter),
              items: [
                for (final entry in reciters.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (v) {
                if (v != null) onReciterChanged(v);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context).downloadsWifiOnly),
              value: wifiOnly,
              onChanged: onWifiOnlyChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahDownloadRow extends StatelessWidget {
  const _SurahDownloadRow({
    required this.title,
    required this.state,
    required this.onDownload,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final String title;
  final DownloadStateData? state;
  final VoidCallback onDownload;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = state?.status ?? 'notDownloaded';

    return ListTile(
      title: Text(title),
      subtitle: status == 'downloading'
          ? LinearProgressIndicator(value: state?.progress ?? 0)
          : Text(switch (status) {
              'downloaded' => AppLocalizations.of(context).libraryDownloaded,
              'paused' => AppLocalizations.of(context).downloadsPaused,
              'failed' => AppLocalizations.of(context).downloadsFailed,
              _ => AppLocalizations.of(context).libraryNotDownloaded,
            }),
      trailing: switch (status) {
        'downloading' =>
          IconButton(icon: const Icon(Icons.pause_rounded), onPressed: onPause),
        'paused' =>
          IconButton(icon: const Icon(Icons.play_arrow_rounded), onPressed: onResume),
        'downloaded' =>
          IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: onDelete),
        _ => IconButton(icon: const Icon(Icons.download_rounded), onPressed: onDownload),
      },
    );
  }
}
