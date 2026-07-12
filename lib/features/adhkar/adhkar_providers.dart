import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/dua_repository.dart';
import '../../core/content/models/dua_models.dart';

final adhkarSetProvider = FutureProvider<AdhkarSet>((ref) {
  return ref.watch(duaRepositoryProvider).loadAdhkar();
});
