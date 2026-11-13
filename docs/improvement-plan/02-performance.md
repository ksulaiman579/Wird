# Performance (Phase 2 / M27)

No profiling was run. Measure each item before and after on the emulator (DevTools frame chart,
"highlight repaints", startup trace) and keep the numbers in the commit message.

## Frame rate

| # | Problem | Where | Fix |
|---|---|---|---|
| 1 | Reader calls `setState` on every position/duration tick (16–200 ms). Rebuilds scaffold, PageView, player bar; in Mushaf mode the whole surah `Text.rich` plus a tajweed scan of every character | `features/quran_reader/quran_reader_screen.dart:135-140,907-947`, `tajweed_formatter.dart:67-100` | Position/duration into a small `StreamBuilder` inside the player bar. Cache formatted spans per ayah. |
| 2 | Mushaf mode is one `Text.rich` in a `SingleChildScrollView` — no culling | `quran_reader_screen.dart:892-950` | Lazy list of ayah blocks (or chunks of ~10 ayahs). |
| 3 | Blur on every card in grids and lists (11 on Explore, one per Nawawi row) | `shared/ui/glass_card.dart:58-66`, `hub_card.dart:36`, `numbered_content_card.dart:49` | `enableBlur: false` for cards in lists/grids. Keep for sheets and one hero surface. |
| 4 | Page turn writes prefs and replaces state; reader, Today and Reading hub all watch the whole object | `features/quran_reader/reader_prefs.dart:121-136`, `today_screen.dart:39`, `reading_hub_screen.dart:23` | `.select(...)`; save last-read with a ~1 s delay. |
| 5 | Parchment background draws ~460 circles and repaints with its child | `shared/ui/glass_scaffold.dart:61-64` | `RepaintBoundary`, or paint once to a picture. |
| 6 | Today watches the whole `srs_items` table | `features/today/today_providers.dart:18-21,132-201` | Query only due/new items and counts. |
| 7 | Hub grids `shrinkWrap` inside a list; locked achievements use `Opacity` | `hub_card.dart:95-104`, `features/achievements/achievements_screen.dart:59,206` | Slivers; colour alpha instead of `Opacity`. |
| 8 | Android has no high-refresh request | `android/.../MainActivity` | Set preferred display mode (or `flutter_displaymode`). iOS flag already in `Info.plist:5-6`. |

## Data and memory

| # | Problem | Where | Fix |
|---|---|---|---|
| 9 | Downloaded translation: full pack read + `jsonDecode` per ayah, on the UI thread | `core/content/translation_pack_service.dart:178-194` | Decode once and cache (like `_decodedCache` for hadith). Later: one row per surah. |
| 10 | No `compute()` anywhere. Pack downloads decode, regroup, encode and hash on the UI thread; plan creation decodes up to 114 surah files in a row | `translation_pack_service.dart:141-150`, `hadith_pack_repository.dart:140-155,249`, `onboarding_controller.dart:63-72,124-135` | Move to `compute()` / `Isolate.run`. |
| 11 | Library screen: ~63 tiles, each with a stream that selects the multi-MB `data` column | `features/downloads/library_screen.dart:30-38,71-160`, `translation_pack_service.dart:75-80` | One stream of status columns only; `ListView.builder`. |
| 12 | Download progress: SELECT + upsert per event per ayah | `core/audio/audio_download_manager.dart:46-85` | Throttle; write on state change only. |
| 13 | No indexes; whole-table reads of `review_logs`, `srs_items` | `core/db/tables.dart`, `progress_providers.dart:67-72`, `achievement_providers.dart:74,134` | Index `srs_items(status, due_date)`, `review_logs(item_id)`; aggregate in SQL. |
| 14 | No `autoDispose`; per-ayah family providers and caches live forever; hadith collections cached decoded (tens of MB) | repo-wide | `autoDispose` on per-ayah/per-chapter families; small LRU for decoded packs and surahs. |
| 15 | Audio cache has no size limit | just_audio temp cache | Cap and trim on start. |

## Startup

- `main.dart:45-52`: `Supabase.initialize` awaited before `runApp`, never used after. Remove the package.
- `core/notifications/notification_service.dart:51`: timezone database loaded synchronously inside
  `DailyApp.initState`, before the first frame. Move after first frame.
- Notification reschedule (7 days, cancel all, re-add) and the 12 h alarm registration run on every
  launch (`notification_providers.dart:60-150`, `background_update_check.dart:103-112`). Skip when
  nothing changed.
- Theme, palette and language load after the first frame (`app.dart:95-98`) → dark-mode or Arabic
  users can see a light English frame. Read prefs once before `runApp`.
- `router.dart:51-53`: DB query on every navigation. Cache "has profile" in a provider.

## App size

- `android/app/build.gradle.kts:63-64`: minify and resource shrinking off. Turn on.
- One fat APK. Build per-ABI, list them in `update.json`, updater picks by device ABI
  (`core/update/app_update_service.dart:23`).
- `adhan.ogg` (1.2 MB) shipped twice — asset and `res/raw`. The raw copy looks unused
  (`notification_service.dart:22`). Confirm against M25.D before deleting.
- 64 locales generated (3.1 MB of Dart) for 7 shipped. Move the other 57 ARBs out of `lib/l10n/`.
- `pdfrx` adds ~5.3 MB of web assets for the knowledge library only. Consider loading it on demand on web.
- `logo_display.png` is 445 KB at 512 px, shown at 160 dp — add `cacheWidth` or a smaller file.
- Add `--split-debug-info` and `--obfuscate` to the release build.

## PWA

- `web/pwa_cache_worker.js:33-45,89-103`: shell is network-first, so every online launch waits for
  `main.dart.js`. Serve from cache, refresh in background, prompt to reload.
- Precaches both `canvaskit/` and `canvaskit/chromium/` (`:51-65`). Check the build uses local
  CanvasKit (`--no-web-resources-cdn`), otherwise offline start depends on the browser cache.
- `web/sqlite3.wasm` and `drift_worker.js` are from an older build — confirm they match Drift 2.34.

## Audio

- Background playback isn't set up on either platform: no foreground service on Android, no
  `UIBackgroundModes` audio on iOS, no lock-screen controls. Add `just_audio_background`.
- Per-ayah MP3s leave small gaps between ayahs. Acceptable for now; full-surah files with timing data
  would fix it and also give word highlighting during playback (see 03-read-along.md).

## Order

1, 9, Supabase removal, 3, 4 first — biggest gain for least risk. Then startup, then size, then the rest.
