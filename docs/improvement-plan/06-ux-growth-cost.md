# Usability, features, growth, cost (Phase 6 / M31)

Decision: APK + PWA only for now. Free, no ads.

## Friction today

- **Onboarding is 8 steps** (`features/onboarding/onboarding_screen.dart:110,316-328`). Swiping skips
  steps without checks; the name field loses its text when you page back; finish handlers rethrow
  after the snackbar (`:180,:268`). Target 3 steps — language, what to memorise, minutes a day.
  Notifications, location and downloads get asked the first time they're needed. (M25.H5)
- **Onboarding downloads audio that's never used** — fixed by Phase 1 A2, but also make the download
  offer honest about size before starting.
- **No screen-reader support.** No labels anywhere. Worst: tasbih counter
  (`features/tasbih/tasbih_screen.dart:326`), hidden-word boxes (`shared/widgets/word_cloak_text.dart:67-84`),
  icon-only buttons, citation links under 48 dp (`reference_line.dart:24`). (M25.H6)
- **Contrast**: flame icon on cream (`today_screen.dart:206,568`, ~2.1:1); white on gold badge
  (`hadith_chapter_detail_screen.dart:285`, ~4.0:1 at 12 px).
- **Raw error text** shown to users in 32 places. One helper that maps to a short friendly line
  plus "Try again".
- **Mini-player never shows** outside the reader (Phase 1 A10). No lock-screen controls, playback
  stops in the background (Phase 2).
- **Streak number is wrong after missed days** (Phase 1 A8) — hurts trust in the one number people
  check daily.
- **Search can't find an ayah** (Phase 3).
- **No way to move phones safely** — backup misses bookmarks and tasbih (Phase 1 A7, M25.H4).
- **Web**: pinch-zoom disabled (`web/index.html:48`).

## Features worth adding

In order of value for the effort. All work offline and cost nothing to run.

1. **Share as image card** — ayah, hadith or dua on the emerald/gold design, with reference and a
   short link. Today sharing is text only and ayahs can't be shared at all
   (`hadith_detail_screen.dart:182-186`). Render a widget to PNG, share with `share_plus`.
2. **Links that open the right place** — PWA URLs already work (`vercel.json`). Add Android app
   links (`assetlinks.json` on the Vercel site + intent filter) so the link opens the app when
   installed, the PWA when not.
3. **Home-screen widget** — today's portion and streak; ayah of the day; next prayer. (M25.H1)
4. **Hijri date + Ramadan mode** — khatmah plan over 29/30 days, daily reading target, a shareable
   end-of-Ramadan recap.
5. **Plan links** — a memorisation or reading plan encoded in a link. A teacher or parent shares it,
   the student imports it. No accounts.
6. **Weekly recap card** — ayahs memorised, days kept, pages read. Shareable.
7. **Unified last-read / bookmarks / history** across Quran, hadith, dua. (M25.H2)
8. **Word-by-word meaning** from a vetted source — helps memorising and gives read-along better hints.
9. **Read-along** (Phase 4) and **search by meaning** (Phase 3b) — the two headline features.

Not recommended now: accounts, cloud sync, leaderboards, chat. Each needs a server, moderation or both.

## Growth without stores, ads or tracking

- **Every share carries a way back.** Card → link → the exact ayah in the PWA → "Install" banner
  (Android: APK; iPhone: add to home screen).
- **A proper landing page** on the Vercel site in all 7 languages, with link previews (title,
  image) per language. There's little competition for good Quran-memorisation pages in Urdu,
  Bengali, Hindi, Malayalam and Filipino.
- **Teachers and halaqas** — plan links make Wird something a teacher hands to a class. One teacher
  brings many students.
- **Ramadan** — the yearly spike. Have the khatmah plan and recap card ready a month before.
- **Trust as the pitch** — "Free forever. No ads. No tracking. Works offline." on the landing page,
  in About, and on share cards. Publish the data sources page (already in the app).
- **Ask for the share at good moments** — after a streak milestone or finishing a surah. Once, never
  nagging.
- **APK friction** — sideloading puts people off. The landing page needs a clear 3-step install
  guide per language, and the update check must be trustworthy (Phase 1 A11). If growth matters more
  later, the Play Store is the biggest single lever; nothing here blocks adding it.

## Retention

- Reminders that actually fire (Phase 1 A1) and say something specific in the user's language
  ("5 ayahs due today", not a generic nudge).
- Streak freeze already exists — surface it when a day is missed instead of silently using it.
- Ease-back after a break already exists (`easeBackActiveProvider`) — add a friendly "welcome back,
  lighter day today" card.
- Weak-spot review from read-along mistakes.

## Cost

| Thing | Where it runs | Cost |
|---|---|---|
| Speech recognition | on the phone | none |
| Search, keyword and by meaning | on the phone | none |
| Models, vector packs, translation and hadith packs | static files — GitHub releases, jsDelivr, Supabase public bucket as mirror | free tiers |
| PWA + landing page | Vercel | free tier |
| Recitation audio | everyayah.com | free; third-party dependency |
| Prayer times | calculated offline; AlAdhan optional | free |

- Watch: Vercel and Supabase free-tier bandwidth if the PWA takes off. Large files (models, packs)
  should stay on GitHub releases / jsDelivr, not Vercel.
- everyayah.com is a single point of failure for audio. Keep a mirror list in `ayah_audio_urls.dart`
  and fall back.
- If a server feature is ever wanted (e.g. server speech for weak phones), fund it separately
  (donation or sponsor) and keep it optional so the app never depends on it.

## Measuring without tracking

No analytics today. Options, lightest first — needs Waleed's call (see 00-summary.md):
- GitHub release download counts and Vercel's built-in page counts (already available, no app change).
- An in-app "send feedback" that opens email with the debug log attached (log viewer exists).
- Opt-in anonymous crash reports.
