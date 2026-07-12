import '../cloud/cloud_config.dart';

/// Content-delivery source resolution (Item 1.27): when a Supabase project is
/// configured (`--dart-define` keys), the app pulls Quran translation packs
/// and hadith packs from the public `content` Storage bucket **first**, and
/// falls back to the existing upstream CDN if Supabase is unconfigured,
/// missing the file, or unreachable. Read-only, anonymous, no user data.
///
/// Files hosted on Supabase are byte-identical mirrors of the upstream CDN
/// files (same shape the parsers already expect), so this only rewrites the
/// host — no format change. Bucket layout:
///   `content/quran-packs/{upstream-filename}.json`
///   `content/hadith-packs/ara-{collection}.min.json` (and `eng-…`)
class ContentSource {
  const ContentSource._();

  /// Public base for the `content` bucket, or null when Supabase isn't
  /// configured (callers then use their CDN URL directly).
  static String? get _bucketBase => CloudConfig.isConfigured
      ? '${CloudConfig.supabaseUrl}/storage/v1/object/public/content'
      : null;

  /// Ordered URLs to try for a content object: the Supabase mirror first
  /// (when configured), then the given CDN fallback(s) in order. Never empty
  /// — [cdnFallback] is always the last resort.
  static List<String> candidates({
    required String bucketPath,
    required String cdnFallback,
  }) {
    final base = _bucketBase;
    return [
      if (base != null) '$base/$bucketPath',
      cdnFallback,
    ];
  }
}
