import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/adhkar/adhkar_window.dart';

import '../../core/content/dua_repository.dart';
import '../../core/content/models/dua_models.dart';

final adhkarSetProvider = FutureProvider<AdhkarSet>((ref) {
  return ref.watch(duaRepositoryProvider).loadAdhkar();
});

/// Whether [period]'s adhkar are done for the current adhkar day. The
/// reader invalidates this on completion so the Duas-tab card updates.
final adhkarCompletedTodayProvider =
    FutureProvider.family<bool, String>((ref, period) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(
        adhkarCompletedKey(period, adhkarDayFor(period, DateTime.now())),
      ) ??
      false;
});
