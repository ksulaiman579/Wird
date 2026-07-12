import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/dua_repository.dart';
import '../../core/content/models/dua_models.dart';

final duaCategoriesProvider = FutureProvider<HisnulMuslim>((ref) {
  return ref.watch(duaRepositoryProvider).loadCategories();
});

final duaCategoryProvider =
    FutureProvider.family<DuaCategory, String>((ref, categoryId) {
  return ref.watch(duaRepositoryProvider).loadCategory(categoryId);
});
