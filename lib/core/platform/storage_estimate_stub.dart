/// Non-web fallback (native): the browser Storage API doesn't exist here,
/// and native platforms have their own OS-level storage without a quota
/// warning step, so these are no-ops.
class AppStorageEstimate {
  const AppStorageEstimate({
    required this.usageBytes,
    required this.quotaBytes,
  });

  final int usageBytes;
  final int quotaBytes;
}

Future<AppStorageEstimate?> estimateStorage() async => null;

Future<bool> requestPersistentStorage() async => false;
