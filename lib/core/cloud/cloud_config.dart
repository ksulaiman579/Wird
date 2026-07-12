/// Supabase configuration for Wird's **content delivery only** (Item 1.27).
///
/// There is NO account, auth, or user data in the cloud (accounts are
/// offline-only — Item 1.26). Supabase hosts a single PUBLIC, read-only
/// Storage bucket (`content`) mirroring the Quran-translation and hadith
/// packs; the app fetches those anonymously, and falls back to the upstream
/// CDN if Supabase is unconfigured or unreachable (see `ContentSource`). No
/// realtime, no polling, no writes from the client — so registered-user
/// count is irrelevant and load is just occasional static-file reads.
///
/// Ships DISABLED: [isConfigured] is false until the project URL +
/// publishable key are injected via --dart-define, in which case the app
/// simply keeps using the CDN.
class CloudConfig {
  CloudConfig._();

  /// Wird's Supabase project URL — injected at build time via --dart-define,
  /// never hardcoded.
  static const String supabaseUrl = String.fromEnvironment(
    'WIRD_SUPABASE_URL',
    defaultValue: '',
  );

  /// Wird's Supabase **publishable** (public client) key — safe to ship in a
  /// client; all row access is gated by RLS server-side. Injected via
  /// --dart-define. The SECRET key is never used or embedded anywhere.
  static const String supabasePublishableKey = String.fromEnvironment(
    'WIRD_SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
