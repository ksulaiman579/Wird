import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/hadith_repository.dart';
import '../../core/content/models/hadith_model.dart';

final hadithListProvider = FutureProvider<List<Hadith>>((ref) {
  return ref.watch(hadithRepositoryProvider).loadAll();
});

final hadithByIdProvider = FutureProvider.family<Hadith, int>((ref, id) {
  return ref.watch(hadithRepositoryProvider).loadById(id);
});
