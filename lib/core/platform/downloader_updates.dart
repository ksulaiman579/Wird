import 'package:background_downloader/background_downloader.dart';

/// background_downloader's `FileDownloader().updates` is a single-listener
/// stream, but both the audio download manager and the library download
/// service need it — the second `listen` threw "Stream has already been
/// listened to" (M26.3). Everyone listens here instead and filters by
/// task group / id. Created on first use; native only.
final Stream<TaskUpdate> downloaderUpdates =
    FileDownloader().updates.asBroadcastStream();
