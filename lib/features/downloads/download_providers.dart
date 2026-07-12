import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_download_manager.dart';
import '../../core/db/database.dart';

final downloadStatesProvider = StreamProvider<List<DownloadStateData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.downloadState).watch();
});

/// Native-only — `background_downloader` has no web support. `/downloads`
/// never reads this provider on web (see `DownloadsScreen`'s `kIsWeb`
/// early return), so this is never constructed there.
final audioDownloadManagerProvider = Provider<AudioDownloads>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final manager = AudioDownloadManager(db);
  ref.onDispose(manager.dispose);
  return manager;
});
