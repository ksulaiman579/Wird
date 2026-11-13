# Wird improvement plan — summary

Audit date: 2026-11-13. Read-only audit of `lib/`, `android/`, `ios/`, `web/`, `tool/`, `test/`.
Nothing was run on a device, so anything marked (device) still needs checking on the emulator.

## Decisions (Waleed, 2026-11-13)

- Read-along speech recognition runs on the phone. No server.
- Search shows sourced passages only. No AI-written answers.
- Fix what's broken first, then search, then read-along.
- Distribution stays APK + PWA. No stores for now.

## Phases

| Phase | What | Detail | TASKS.md |
|---|---|---|---|
| 1 | Repair broken features | [01-faults-and-fixes.md](01-faults-and-fixes.md) | M26 |
| 2 | Speed and app size | [02-performance.md](02-performance.md) | M27 |
| 3 | Search (keyword, then by meaning) | [04-search.md](04-search.md) | M28 |
| 4 | Read-along | [03-read-along.md](03-read-along.md) | M29 |
| 5 | Languages | [05-languages.md](05-languages.md) | M30 |
| 6 | Usability, features, growth, cost | [06-ux-growth-cost.md](06-ux-growth-cost.md) | M31 |

M25 stays as is. Where a new item overlaps an M25 item it points to it instead of repeating it
(adhan D1–D6, widgets H1, global search H3, onboarding H5, accessibility H6, recite-along I5,
localized duas J).

## Worst findings

1. Android scheduled notifications probably never fire — the manifest doesn't declare the plugin's
   receivers. Sits on top of the M25.D exact-alarm cause. (device)
2. Downloaded recitation audio is never played. Every play streams again.
3. Surah download pause / resume / delete do nothing, and the status shown is wrong.
4. Two download services listen to the same single-listener stream — whichever starts second throws.
5. The Quran reader rebuilds the whole screen on every audio position tick (up to ~60/s).
6. Picking a downloaded translation decodes the whole 1–2 MB pack for every ayah.
7. Supabase is started before the first frame and never used.
8. No search over ayah text at all, and no Arabic normalisation anywhere.
9. Notifications, tasbih and a few other screens are English-only in all 7 languages.
10. No screen-reader labels anywhere in the app.

## Main trade-offs

- **On-phone speech**: free, private, offline. Costs a 40–80 MB optional download, weaker on old
  phones, not on the PWA in v1, and it won't judge tajweed or vowel marks.
- **Passages-only search**: nothing can be made up. No "ask a question, get an answer" experience.
- **No vector database**: ~15k passages is small enough to compare directly on the phone. Simpler,
  nothing to host. Would need revisiting only if the corpus grows 20× or more.
- **APK + PWA only**: no store fees or review, full control. Growth depends on share links and the
  web app; iPhone users only get the PWA (so no read-along for them in v1).
- **Removing Supabase**: faster start, smaller app. Loses nothing today (content is fetched over
  plain HTTP, the bucket still works as a mirror).

## Open questions

1. Usage numbers: none exist today. Add opt-in anonymous crash reports and an active-user count, or
   stay at zero tracking?
2. Read-along trial needs ~30 min of real recitation from different voices. Can you collect it?
3. Download sizes: speech model ≤ 80 MB, search model ≤ 40 MB. OK for your users?
4. Optional donation / sadaqah link later, or strictly none?
5. Non-English hadith: sources for ur/hi/bn/ml/fil? (Duas are already covered by M25.J.)
6. iOS: the project isn't release-ready (no location permission text, no background audio). Park
   iOS-only fixes until you decide on the App Store?

## Not verified

Real frame times and startup time; built APK/web sizes; whether notifications fire on a device;
Ogg adhan on iOS; whether the bundled `sqlite3.wasm` includes FTS5 and matches the current Drift;
whether CanvasKit is served locally in the PWA build; contrast ratios (hand-calculated).
