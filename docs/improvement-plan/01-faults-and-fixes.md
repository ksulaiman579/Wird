# Faults and fixes (Phase 1 / M26)

Paths are under `lib/` unless they start with `android/`, `ios/`, `web/`, `test/` or `tool/`.
(device) = confirm on the emulator before and after the fix.

## A. Broken features

### A1. Android scheduled notifications likely never fire (device)
- `core/notifications/notification_service.dart:129` uses `zonedSchedule`.
- `android/app/src/main/AndroidManifest.xml:20-66` has no `ScheduledNotificationReceiver` or
  `ScheduledNotificationBootReceiver`. The plugin's own manifest only adds permissions.
- Hits reminders, adhkar and adhan. Comes before M25.D1–D4 (exact alarms, full-screen intent,
  battery) — those still apply.
- Fix: declare both receivers; add `RECEIVE_BOOT_COMPLETED` handling per the plugin README.
- Also: a tap that cold-starts the app is dropped. `getNotificationAppLaunchDetails` is never called
  (`app.dart:76-78` only handles taps while running). A full-screen adhan launch lands on Today.

### A2. Downloaded audio is never played
- `AyahAudioService.playAyah/playGroup` accept `localFilePath(s)`; no caller passes them:
  `features/quran_reader/quran_reader_screen.dart:155,180,618`,
  `features/quran_browser/surah_screen.dart:56`, `features/session/new_material_flow.dart:93`.
- Onboarding still queues every ayah MP3 for the plan (`features/onboarding/onboarding_screen.dart:229-250`).
- Fix: resolve the local file inside `core/audio/ayah_audio_service.dart` (one lookup by
  reciter/surah/ayah), so callers don't change.

### A3. Two listeners on one single-listener stream
- `core/audio/audio_download_manager.dart:41` and `core/content/library_download_service.dart:50`
  both call `FileDownloader().updates.listen`. background_downloader's stream is not broadcast.
- Fix: one shared listener that routes updates by task group.

### A4. Surah download controls and status
- `resumeSurah`/`deleteSurah` read `FileDownloader().database.allRecords(...)`
  (`audio_download_manager.dart:133,146`) but `trackTasks()` is never called → no records.
  Resume does nothing; delete leaves files and marks the surah not downloaded.
- Each ayah update overwrites the whole surah's status (`:47-86`): "downloaded" after one ayah,
  failures masked, progress jumps 0→1 per ayah. Read-then-write in `_upsert` isn't serialised.
- `enqueueSurah` awaits one platform call per ayah (`:105-118`) — 6,236 for a full Quran.
- `quality` label wrong for 192/40 kbps reciters (`:99`).
- Fix: call `trackTasks()`, keep a done/total count per surah, batch enqueue (`enqueueAll`),
  throttle DB writes, delete from disk by folder.

### A5. Session goes stale; double grading
- `features/session/session_controller.dart:308` — the provider is never invalidated. Reopening
  `/session` after finishing shows the old celebration; next day (app kept in memory) runs
  yesterday's queue. Crossing midnight writes to a `daily_sessions` row that may not exist
  (`:226-242`) → done counts and streak lost.
- No guard on `gradeCurrent`: double tap grades twice.
- Editing the plan mid-session leaves `ReviewLogs` for deleted items (foreign keys are off).
- Fix: key the controller by day, invalidate on finish and on plan edit, add an in-flight guard.

### A6. Pack re-download wipes the installed copy
- `_upsertStatus(..., 'downloading')` writes `data: null` on conflict
  (`core/content/hadith_pack_repository.dart:136,362`, `core/content/translation_pack_service.dart:225`).
  A failed retry leaves the pack unusable.
- A row stuck in `downloading` (app killed) spins forever (`features/downloads/library_screen.dart:195`).
- sha256 is computed from what was downloaded, not checked against the pinned value.
- Fix: write status only, swap data after validation; reset stuck rows at startup; compare to the
  allowlist hash.

### A7. Backup and restore
- Backup skips Bookmarks, TasbihSessions, ContentPacks, LibraryDownloads
  (`core/backup/backup_service.dart:41-63`); `backupSchemaVersion` still 1 (`:15`).
- Restore copies `downloadState` to a phone that doesn't have the files.
- `prefs.clear()` runs before the restore loop (`:153`) — a bad value leaves prefs half wiped.
- Providers and notifications aren't refreshed after restore.
- "Back up then reset" resets even if the share sheet is dismissed
  (`features/settings/settings_screen.dart:143-144`).
- Ties in with M25.H4.

### A8. Streaks, adhkar, reminders
- Streak shown never decays: `features/today/today_screen.dart:147,553,594`,
  `features/progress/progress_providers.dart:145` show `currentStreak` without checking
  `lastCompletedDay`.
- "Streak at risk" fires after the portion is done — session completion never reschedules.
- Adhkar completion keyed by calendar date (`features/adhkar/adhkar_reader_screen.dart:56`): evening
  adhkar after midnight marks tomorrow's as done. The Dua-tab card never refreshes
  (`features/dua/dua_categories_screen.dart:22-31`). Cancel only targets day 0 (`adhkar_reader_screen.dart:74`).
- `core/gamification/streak_service.dart:72-80`: clock set back resets the streak to 1.
- `features/quran_reader/reading_streak.dart:35`: can save a streak of 1 over the stored one if
  called before the provider loads (unverified).

### A9. Adhan time ≠ shown time
- Adhan always uses Muslim World League + Shafi offline (`core/notifications/prayer_times_service.dart:93`
  via `notification_providers.dart:102`); shown times use AlAdhan with the country/user method.
- AlAdhan times parsed as device-local (`prayer_times_service.dart:147-157`) — wrong when the chosen
  city is in another timezone.
- Fix: one calculation path and one method for both.

### A10. Audio lifecycle
- `NewMaterialFlow` and `SurahScreen` don't stop playback on dispose (`new_material_flow.dart:53-56`).
- Reader stops playback on dispose (`quran_reader_screen.dart:105-106`), so the global mini-player
  effectively never shows.
- `playAyah`/`playGroup` catch everything, including the interruption from a newer load, and retry
  with old arguments (`ayah_audio_service.dart:150-164,202-222`).
- `changeReciter` starts before pausing (`:270-272`).
- `AyahAudioService.init()` (`:121-128`) is never called → audio session never configured.
- Adhan screen uses its own player and doesn't pause recitation.

### A11. APK self-update is unchecked
- `core/update/app_update_service.dart:80-100`: no HTTP status, size or hash check, no timeout. A 404
  page could be handed to the installer.
- Fix: sha256 in `update.json`, verify before install.

## B. Crashes and edge cases

- Route builders `int.parse` (`router.dart:150,228,245`) — `/quran/abc` throws.
- `features/session/session_content_provider.dart:63,131` — `!` on a content key / dua that may no
  longer exist.
- `notification_providers.dart:83-84` assumes manual prayer times exist.
- `hadith_pack_repository.dart:324-326` assumes Arabic and English entries line up.
- `main.dart:43-51` — if `Supabase.initialize` throws, the app stays on the splash (goes away with
  the Supabase removal in Phase 2).
- `adhkar_reader_screen.dart:51` — `setState` without `mounted`.
- `features/quran_reader/reader_prefs.dart:121-128` — concurrent updates overwrite each other.
- No timeouts: AlAdhan (`prayer_times_service.dart:179`), hadith packs (`hadith_pack_repository.dart:240`),
  translation packs (`translation_pack_service.dart:126`), library fallback
  (`library_download_service.dart:179`).
- 34 `catch (_)` blocks; 32 places show raw `'$e'` to users.
- Ogg adhan on iOS (asset and notification sound, `notification_service.dart:164`) probably
  unsupported (device).
- iOS `Info.plist` has no location usage text though `geolocator` is used.

## C. Dates

- `core/notifications/notification_plan.dart:149`, `notification_providers.dart:76` —
  `add(Duration(days:))`; a fall-back week schedules one date twice and drops the 7th.
- `features/achievements/achievement_providers.dart:44-52`, `features/today/today_providers.dart:74` —
  same pattern.
- SM-2 due dates stored as local midnight; off by a day after a timezone change
  (`session_controller.dart:127`, `today_providers.dart:155`).
- Timezone set once at init (`notification_service.dart:51-53`); an unknown zone id throws, is
  swallowed (`app.dart:85`), and nothing gets scheduled.
- The day-key helper is copied 7 times (`sm2_scheduler.dart:81`, `streak_service.dart:41`,
  `ease_back_prefs.dart:8`, `notification_providers.dart:39-46`, `today_providers.dart:123-130`,
  `session_controller.dart:83-90`, `progress_providers.dart:55-61`). Use `core/calendar_math.dart`.

## D. Structure

- `lib/core` → `lib/features`: clean.
- `lib/shared` imports features (`shared/widgets/app_shell.dart:7-8`, `global_mini_player.dart:9-10`).
- Circular: session ↔ quran_reader, adhkar ↔ achievements. `hadith_reader` uses a provider defined
  in `onboarding_screen.dart:93`.
- Big files: `onboarding_screen.dart` 1631, `quran_reader_screen.dart` 951, `settings_screen.dart` 816,
  `today_screen.dart` 648, `zakah_screen.dart` 611.
- Logic in widgets: prefs in `adhkar_reader_screen.dart:49-58`, `dua_categories_screen.dart:29`,
  `app_shell.dart:42`; DB + audio queueing in `onboarding_screen.dart:229-270`; a `FutureBuilder`
  future created in `build` (`features/library/book_reader_screen.dart:31`).
- `rescheduleNotifications(dynamic ref)` and `computeAchievementStats(dynamic ref)` are untyped.
- Duplicates: `_isBookmarkedProvider` ×3, player-state listening ×4, `Color(0xFFF8F0D8)` ×4, two
  adhan players.
- No `autoDispose` anywhere; date-based providers computed once and never refreshed.
- Split the big screens only when touching them for another fix. No refactor for its own sake.

## E. Database

- No migration tests, no schema snapshots. Add `drift_dev schema dump` snapshots + a migration test.
- No `beforeOpen` → `PRAGMA foreign_keys` off.
- No declared indexes (see 02-performance.md).

## F. Tests and CI

- 97 test files, mostly pure logic and widgets. DST tests only bite under a DST timezone; CI runs UTC.
- Nothing for: `audio_download_manager`, `notification_service`, `app_update_service`,
  `background_update_check`, adhan, global search, readers, session/today screens, migrations.
- `.github/workflows/build-apk.yml` only builds a debug APK. Add `flutter analyze` and `flutter test`.

## G. Dependencies

- Unused: `cupertino_icons`, `riverpod_annotation` + `riverpod_generator`, direct `sqlite3`.
- `supabase_flutter` used only for `initialize` — remove (Phase 2).
- Loose pins: `file_picker` beta range, `freezed` dev, `intl: any`.
