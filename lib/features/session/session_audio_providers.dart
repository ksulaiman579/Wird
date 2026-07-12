import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/ayah_audio_service.dart';
import '../today/today_providers.dart' show userPlanStreamProvider;

/// The playback service used by the session's Listen step and the Quran
/// browser's per-ayah play buttons. Not created until first read, so
/// widgets/tests that never trigger playback never touch the real
/// just_audio plugin (which has no device/browser to run against in this
/// container). Widget tests override this with a fake [AyahPlayback].
///
/// Keeps [AyahPlayback.reciter] in sync with the plan's chosen reciter
/// (Settings, M7.3) so a change there applies to the very next playback.
final sessionAudioServiceProvider = Provider<AyahPlayback>((ref) {
  final service = AyahAudioService();
  ref.onDispose(service.dispose);

  ref.listen(userPlanStreamProvider, (previous, next) {
    final reciter = next.value?.reciter;
    if (reciter != null) service.reciter = reciter;
  }, fireImmediately: true);

  return service;
});
