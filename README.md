# Wird — Quran, Hadith & Dua Memorization

**Wird** (وِرْد) — one's fixed daily portion of Quran, dhikr, or worship.
That's exactly what this app helps you build and keep: a Flutter app for
memorizing the Quran, the 40 Hadith of an-Nawawi (plus six major hadith
collections, downloadable on demand), and daily duas from Hisnul Muslim — at
your own pace, fully offline.

Who it's for: anyone building or maintaining a daily memorization habit —
students, parents teaching their kids, or someone who just wants a
distraction-free way to keep up their Quran/hadith/dhikr. No account, no ads,
no server — your progress lives on your device (or in your browser, for the
PWA), with export/import for backup and carrying over between devices.

## Features

- **Spaced-repetition memorization** (Sabaq/Sabqi/Manzil, built on
  traditional hifz pedagogy) for Quran ayahs, hadith, and duas, with streaks
  and achievements to keep the habit going.
- **Paged Quran reader** — one ayah per page, downloadable extra
  translations, per-ayah bookmarking, exact last-read position.
- **Hadith shelf** — 40 Hadith of an-Nawawi bundled in the app; Sahih
  al-Bukhari, Sahih Muslim, Abu Dawud, Tirmidhi, an-Nasai, and Ibn Majah
  downloadable individually.
- **Duas tab** — a time-aware Daily Adhkar card (knows whether it's morning
  or evening) plus the ~130 Hisnul Muslim categories grouped by circumstance,
  with search.
- **Interactive tools** — Qibla compass, a Zakah calculator (silver/gold
  nisab), and a Tasbih counter with presets.
- **Local prayer-time reminders** and silent, ongoing-style adhkar
  notifications that clear themselves once you've read that period's adhkar.
- **Al-Manhaj — coming soon.** Al-Manhaj is a structured Islamic-studies
  platform this app will integrate with once it launches — a "Sign in with
  Al-Manhaj" option will appear in the app's Al-Manhaj tab to sync
  structured courses alongside your memorization plan here. Wird itself
  stays fully usable without an account either way.

## Screenshots

_(placeholder — add screenshots of Today, the Quran reader, the Hadith
shelf, and the Duas tab here before a public release)_

## Built with Claude

This app was built with [Claude Code](https://claude.com/claude-code),
Anthropic's agentic coding CLI, working autonomously through a task queue
(see `CLAUDE.md` and `TASKS.md`). This doesn't affect F-Droid eligibility —
F-Droid's requirements are FOSS licensing and source-buildability; it has no
policy against AI-assisted code, disclosed or not.

## Installing the app

### Progressive Web App (PWA) — any device with a modern browser

The PWA is the same codebase built for web, hosted for free on Vercel (see
[Deploying to Vercel](#deploying-to-vercel) below). Once deployed, open the
site in a browser:

- **Android / desktop Chrome or Edge:** the browser offers an "Install app"
  prompt (or use the browser menu → "Install Wird…"). It then runs as a
  standalone app with its own icon, no browser chrome.
- **iPhone / iPad (Safari):** iOS doesn't support the standard PWA install
  prompt, but the same "installed app" experience is one tap away:
  1. Open the site in **Safari** (not Chrome — iOS only supports this via
     Safari).
  2. Tap the **Share** button (square with an arrow pointing up).
  3. Scroll down and tap **"Add to Home Screen."**
  4. Tap **"Add"** in the top-right corner.

  The app icon then appears on the home screen like any other app, launches
  full-screen (no Safari address bar), and works offline after the first
  load — text content (Quran, Hadith, duas) is cached locally, so browsing
  and reviewing continues to work without a connection. Recitation audio
  streams online-only on the web build (installing the Android app gives you
  downloadable offline audio instead — see below). The web build also warns
  before large pack downloads if the browser's storage quota is close to
  full, and asks the browser not to evict its storage.

### Android (direct APK / F-Droid)

Not yet published — see `RELEASE.md` for the signed-APK build steps and the
F-Droid submission process (the build recipe draft lives at
`metadata/io.github.ksulaiman579.wird.yml`). Once released, a signed APK
will be attached to GitHub Releases for direct sideloading, and the app
will also be installable from F-Droid.

## Support this project

Wird has no account, no ads, and no server — it stays free. If it has been
useful to you, you can support development from the app's **Al-Manhaj tab**,
or here:

[![PayPal](https://img.shields.io/badge/Donate-PayPal-00457C?logo=paypal&logoColor=white)](https://paypal.me/REPLACE_ME)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?logo=buymeacoffee&logoColor=black)](https://paypal.me/REPLACE_ME)

(Both badges link to the same PayPal page — only a PayPal account exists.
Placeholder URL — see `lib/core/donations.dart`.)

## License

Wird is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License, version 3 (GPL-3.0), as published
by the Free Software Foundation. See the `LICENSE` file for the full text.

## Data sources summary

Every piece of bundled or downloadable content is traced back to its source
in `DATA_SOURCES.md` (also viewable in-app: Settings → About), including the
exact repos/commits used, validation performed, and license for each. In
short: Quran text/translation/transliteration and hadith text come from
verified open-source mirrors of Tanzil.net and hadith-api projects
(cross-checked against a second independent corpus where possible); Hisnul
Muslim duas from a verified IslamHouse-sourced mirror; recitation audio
streamed from everyayah.com; prayer times from the AlAdhan API with an
offline fallback; and a small bundled city list for prayer-time location.

## Credits & Acknowledgements

Every upstream provider Wird bundles or downloads content from — see
`DATA_SOURCES.md` for exactly how each is used, and the in-app About screen
for the same list with tappable links:

- [fawazahmed0 / quran-api & hadith-api](https://github.com/fawazahmed0/quran-api) — additional Quran translation packs, the Nawawi English translation, and the six downloadable hadith collections.
- [risan / quran-json](https://github.com/risan/quran-json) — bundled Quran Arabic text, English translation, and transliteration (CC BY-SA 4.0).
- [semarketir / quranjson](https://github.com/semarketir/quranjson) — juz boundary metadata (MIT).
- [AhmedBaset / hadith-json](https://github.com/AhmedBaset/hadith-json) — 40 Hadith of an-Nawawi Arabic text and narrator attribution (ISC).
- [AbdelrahmanEid / Hadith-Data-Sets](https://github.com/AbdelrahmanEid/Hadith-Data-Sets) — independent Nine Books Arabic corpus, used to cross-check the bundled hadith text.
- [wafaaelmaandy / Hisn-Muslim-Json](https://github.com/wafaaelmaandy/Hisn-Muslim-Json) — Hisnul Muslim & daily adhkar text.
- [Tanzil.net](https://tanzil.net) — the original Quran text/translation project the bundled Uthmani encoding and transliteration are ultimately sourced from.
- [IslamHouse](https://islamhouse.com) — original publisher of Hisnul Muslim (Fortress of the Muslim).
- [everyayah.com](https://everyayah.com) — per-ayah recitation audio (reciters: Husary, Alafasy, Abdul Basit).
- [AlAdhan API](https://aladhan.com/prayer-times-api) / [adhan_dart](https://pub.dev/packages/adhan_dart) — prayer-time calculation.
- [dr5hn / countries-states-cities-database](https://github.com/dr5hn/countries-states-cities-database) — city list for prayer-time location (ODbL).
- [KFGQPC Uthmanic Hafs font](https://github.com/mustafa0x/qpc-fonts) — the Quran display font.

## Development

This is a standard Flutter project. See `CLAUDE.md` for the autonomous-agent
task loop this repo was built with, and `tool/setup_env.sh` to provision the
Flutter SDK in a fresh environment.

```sh
bash tool/setup_env.sh   # installs Flutter to /opt/flutter if missing, runs pub get
flutter analyze
flutter test
flutter build web --release   # PWA build
```

Drift's web support needs `web/sqlite3.wasm` and `web/drift_worker.js`,
regenerated via `bash tool/build_drift_web_assets.sh` if the `drift` package
version changes (see that script's comments for why these aren't fetched
from drift's own docs/releases here).

## Deploying to Vercel

The PWA build (`flutter build web --release`) is a static site, deployable
anywhere — this repo is set up for Vercel specifically:

- `vercel.json` points Vercel at `tool/vercel_build.sh` as the build command
  and `build/web` as the output directory, with an SPA rewrite so
  `go_router`'s client-side paths (e.g. `/quran/2`, `/settings`) resolve to
  `index.html` on a direct load or refresh instead of 404ing.
- `tool/vercel_build.sh` downloads the exact pinned Flutter SDK version
  itself before building — Vercel's build image has no Flutter runtime.
  Bump the version pin there (and in this README) together with any
  intentional Flutter upgrade.

One-time setup (done once, by whoever owns the Vercel account — not
something this repo's automation does on its own):

1. Create a [Vercel](https://vercel.com) account if you don't have one.
2. From the Vercel dashboard, **Add New… → Project**, then import this
   GitHub repository.
3. Vercel auto-detects `vercel.json` and uses its `buildCommand`/
   `outputDirectory` — no other configuration is needed. Leave the
   framework preset as "Other."
4. Deploy. Every push to the production branch redeploys automatically
   from then on; pull requests get their own preview deployments.

Current pinned Flutter version: **3.44.4 (stable)**.
