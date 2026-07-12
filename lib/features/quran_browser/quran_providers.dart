import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/models/quran_models.dart';
import '../../core/content/quran_repository.dart';

final quranMetaProvider = FutureProvider<QuranMeta>((ref) {
  return ref.watch(quranRepositoryProvider).loadMeta();
});

final surahProvider = FutureProvider.family<Surah, int>((ref, surahNumber) {
  return ref.watch(quranRepositoryProvider).loadSurah(surahNumber);
});
