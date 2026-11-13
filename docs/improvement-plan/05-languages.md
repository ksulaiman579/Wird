# Languages (Phase 5 / M30)

Shipped: en, ar, ur, hi, bn, ml, fil (`core/prefs/app_language_provider.dart:94`). 64 ARB files
exist; 57 aren't offered and are mostly English.

Rule stays: walk every locale on device, one by one. No "done" from spot checks.

## Strings

- All 7 shipped ARBs have all 526 keys. Still English: ar 1, bn 15, hi 15, ml 12, ur 16, fil 31
  (e.g. `prayerFajr`, `commonJuzN`, `qiblaTitle`). Some are fine as loanwords — decide per key.
- Hard-coded English to move into ARB:

| Where | What |
|---|---|
| `core/notifications/notification_plan.dart:80-81,160-206` | all notification titles and bodies |
| `features/tasbih/tasbih_screen.dart:187-296` | 13 strings |
| `core/gamification/achievements.dart:86-151` | achievement titles (check the screen first) |
| `core/audio/ayah_audio_service.dart` (`formatAudioError`) | audio errors |
| `core/content/hadith_pack_repository.dart:24-48` | collection names and descriptions |
| `core/content/library_repository.dart` | 15 discipline names |
| `features/quran_reader/quran_reader_screen.dart:216,524` | now-playing title, "English" chip |
| `router.dart:76-90`, `app.dart:65` | error screen, backup snackbar |
| `features/zakah/zakah_screen.dart:582`, `features/progress/progress_screen.dart:128`, `features/library/epub_reader_screen.dart:77,289,294`, `core/platform/storage_warning.dart:30-47`, `features/downloads/downloads_screen.dart:164-166` | scattered labels |

- Notifications are scheduled from background code, so they need the saved language, not a
  `BuildContext`. Load the ARB for the saved locale when building the plan.
- `announcements.json` is single-language (`core/update/update_signals.dart:13`). Add per-locale text
  with English fallback, like `whats_new.json`.

## Picking the language

- First run defaults to English, ignoring the phone (`app_language_provider.dart:113`). Use the
  phone's language if it's one of the 7.
- Changing the UI language doesn't touch the Quran translation. Offer the matching edition
  (ur `urd_fatehmuhammadja`, bn `ben_abubakrzakaria`, fil `fil_wwwislamhouseco`,
  hi `hin_maulanaazizulha`, ml `mal_abdulhameedmada`).
- `tool/editions_allowlist.json` mixes 2- and 3-letter codes (hin, mal). Add one mapping so hi/ml match.

## Right-to-left

- 3 `EdgeInsets.only(left/right)`: `today_screen.dart:120`, `knowledge_library_screen.dart:75`,
  `ayah_numbered_row.dart:28`.
- 2 asymmetric `fromLTRB`: `epub_reader_screen.dart:240`, `update_ui.dart:108`.
- 10 physical `Alignment`s: `asma_screen.dart:166`, `hadith_list_screen.dart:78`,
  `dua_categories_screen.dart:321`, `onboarding_screen.dart:1495,1619`, `quran_reader_screen.dart:554`,
  `settings_screen.dart:726`, `wird_home_header.dart:45,57`, `achievements_screen.dart:204`.
- 1 `TextAlign.left/right`: `numbered_content_card.dart:80`.
- Switch to the directional versions. `corner_flourishes.dart:27-30` is decorative and symmetric — leave.
- Latin lines inside RTL screens: pinned LTR in the adhkar reader only
  (`adhkar_reader_screen.dart:315-337`). Do the same in the Quran reader (`quran_reader_screen.dart:712-775`),
  dua and hadith readers. Pull it into one shared widget.
- Urdu is RTL too — check it separately from Arabic (Arabic hides the Latin aids, Urdu doesn't).

## Fonts and script

- Bundled: UthmanicHafs (Arabic), Marcellus (Latin headings). Nothing for Urdu, Bengali,
  Devanagari, Malayalam, and no `fontFamilyFallback`.
- On phones the system font covers it, but Urdu falls back to a Naskh face (readable, not what
  Urdu readers expect). On the PWA the fallback is fetched from the network — may fail offline.
- Plan: bundle Noto Nastaliq Urdu for Urdu; for bn/hi/ml add Noto fonts as fallbacks, loaded only
  for that locale on web. Check line height — Nastaliq and Malayalam need more than the default.
- Marcellus has no glyphs for these scripts, so headings silently change font. Set a heading
  fallback per script.

## Numbers and dates

- No `DateFormat` / `NumberFormat` anywhere; dates built by hand (`adhkar_reader_screen.dart:21`,
  `notification_providers.dart:44`). Use `intl` for anything shown to the user.
- Optional Arabic-Indic digits setting for ar/ur (helpers in `core/i18n/bidi.dart` already recognise them).
- Hijri date on Today and for Ramadan features. Offline calculation, with a ±1 day adjust setting.

## Text size

- System text scaling is respected (good) but untested. At 200%: nav labels and hub cards truncate
  (`glass_nav_bar.dart:82`, `maxLines: 1`), fixed-height bars clip.
- `web/index.html:48` has `user-scalable=no` — remove.
- Ties in with M25.H6.

## Content

- Quran translations: all 7 covered by downloadable packs.
- Duas and adhkar: Arabic + English only. Sources for ur/bn/hi/fil already located — M25.J.
- Hadith packs: Arabic + English only (`hadith_pack_repository.dart:141-146`). Other languages need
  vetted sources — open question.
- `dua_title_l10n.json`: en + ar only (M25.J4).
- Search indexing per language: see 04-search.md.

## Housekeeping

- Move the 57 unshipped ARBs out of `lib/l10n/` (to `_archive/` or a `l10n_pending/` folder) so
  they stop being compiled in. Saves ~3 MB of generated code and stops them drifting further.
