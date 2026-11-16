# Security and privacy (2026-11-16)

Non-destructive. Covers only our own app and repo.

## Passed
- **Secrets:** no secrets committed. No keystore, key.properties or .env in git. The Supabase key is passed in at build time and is a publishable key.
- **Network:** no plain-HTTP URLs in app code, and no cleartext flag in the manifest.
- **EPUB reader:** strips HTML to plain text, so no scripts and no WebView.
- **Accounts and data:** there are no accounts and no server database. Progress stays on the phone. Crash reports are opt-in and off until a DSN exists.

## Findings
- **WQA-022:** the live update manifest has no sha256, so the APK hash check is skipped. Android's signature check still blocks a tampered APK from installing over the app.
- **WQA-023:** the app asks for fine location. Coarse is enough.
- **WQA-020:** bad deep links show raw errors. No crash and no injection seen. Odd characters in `/search?q=` are handled.

## Not yet checked
- What leaves the phone: full list of outside hosts called.
- The backup file contents.
- Dependency security advisories.
