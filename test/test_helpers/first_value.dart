import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Waits for a provider's first non-loading [AsyncValue] emission.
///
/// `container.read(provider.future)` hangs indefinitely for Stream/Future
/// providers in this test harness when run via a plain `test()` block
/// (confirmed in isolation: identical to a known-good raw Drift
/// `watchSingleOrNull()` call that resolves immediately on its own, and
/// to a `container.listen(..., fireImmediately: true)` call on the exact
/// same provider, which resolves fine) — so this uses `listen` instead.
Future<T> firstValue<T>(ProviderContainer container, dynamic provider) {
  final completer = Completer<T>();
  final subscription = container.listen<AsyncValue<T>>(
    provider,
    (AsyncValue<T>? previous, AsyncValue<T> next) {
      if (completer.isCompleted) return;
      if (next.hasError) {
        completer.completeError(next.error!, next.stackTrace);
      } else if (!next.isLoading) {
        completer.complete(next.value as T);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(subscription.close);
}
