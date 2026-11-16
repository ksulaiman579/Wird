# Inventory (2026-11-16)

From `lib/router.dart`, `lib/features/*` (27 modules) and `lib/core/*`.

**Platforms:** Android APK (per-ABI, self-update), PWA on Vercel. iOS project exists but is not shipped.

**Backend/API/accounts:** none. There are no user roles. Phase 5 and 6 items about auth, server DB and APIs don't apply. What stands in for them: the local Drift DB, downloaded packs, and the outside static sources.

**Outside services:**
- jsDelivr: hadith-api, quran-api.
- Supabase public bucket: tried first for packs; the project is paused.
- IslamHouse: Library files.
- GitHub releases: APK updates.
- Vercel: PWA, share links, assetlinks.
- Sentry: opt-in, no DSN yet.
- Device: geolocation and geocoding (prayer times, qibla).

**Routes:**
- `/`
- `/onboarding`
- `/session`
- `/reading`
- `/quran`, `/quran/:surah`
- `/read`
- `/hadith`, `/hadith/nawawi`, `/hadith/nawawi/:id`, `/hadith/collections/:collection`, `/hadith/collections/:collection/:chapter`
- `/explore`
- `/duas`, `/duas/group/:groupId`, `/duas/:categoryId`
- `/adhkar/:period`
- `/more`
- `/progress`, `/achievements`
- `/downloads`, `/library`
- `/search`
- `/knowledge`, `/knowledge/:discipline`, `/knowledge/book/:id`
- `/adhan`, `/asma`, `/qibla`, `/zakah`, `/khatmah`, `/tasbih`, `/almanhaj`
- `/settings`, `/settings/edit-plan`, `/settings/about`, `/settings/logs`, `/settings/data-sources`

**Not routed (dialogs/background):**
- announcements and what's new
- update prompt
- celebration
- notifications: reminders, adhan, streak
- home widget
- backup and restore
- share sheet

**Partial or hidden:**
- Background audio: not built.
- Meaning search and read-along: not built.
- Crash-report switch: hidden until a DSN exists.
- Supabase cloud code: dormant.
- Donations (`core/donations.dart`): to check.

Feature-level status lives in `02-coverage-matrix.csv`.
