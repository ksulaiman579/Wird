import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'storage_estimate_stub.dart' show AppStorageEstimate;

export 'storage_estimate_stub.dart' show AppStorageEstimate;

/// Wraps `navigator.storage.estimate()` — how much of the browser's
/// storage quota this origin has used, so the app can warn before a
/// multi-MB pack download (M13.8). Returns null if the API is unsupported
/// (older browsers) rather than throwing.
Future<AppStorageEstimate?> estimateStorage() async {
  final storage = web.window.navigator.storage;
  try {
    final estimate = await storage.estimate().toDart;
    return AppStorageEstimate(
      usageBytes: estimate.usage,
      quotaBytes: estimate.quota,
    );
  } catch (_) {
    return null;
  }
}

/// Wraps `navigator.storage.persist()` — asks the browser not to evict
/// this origin's storage under pressure. Best-effort: the browser may
/// silently deny it (that's normal, not an error condition).
Future<bool> requestPersistentStorage() async {
  final storage = web.window.navigator.storage;
  try {
    final persisted = await storage.persist().toDart;
    return persisted.toDart;
  } catch (_) {
    return false;
  }
}
