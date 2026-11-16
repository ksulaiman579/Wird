# Audit handover

Source of truth: `03-bug-register.csv` and `02-coverage-matrix.csv`. Rule: log only. Waleed approves fixes.

## Done
- 2026-11-16 s1: workspace, inventory, baseline (analyze 0 errors, 671 tests), hadith script check of 7 books.
- 2026-11-16 s2:
  - sunnah.com sample: 230 read; 159+1 of 162 comparable match. Muslim uses different numbering. Malik blocked by link style.
  - Quran check passed.
  - Library: all 2,041 links checked (4 dead, authors missing).
  - Emulator: fresh install, Urdu onboarding, Muslim download and reader.
  - Bugs now WQA-001 to 013.

- 2026-11-16 s3:
  - Malik sample: 29 of 30 match.
  - Grades: 110 compared (WQA-014, WQA-015).
  - Chapter overlaps confirmed: 700 Tirmidhi and 437 Ibn Majah hadith filed under the wrong book (WQA-004, High).
  - Emulator: reader search, bookmark and text size; Urdu glyph box (WQA-016); library Urdu PDF opens fine; library language default (WQA-017).

- 2026-11-16 s4:
  - Hadith reader search and bookmarks: no bookmark list anywhere (WQA-018).
  - Global search is English-only (WQA-019).
  - Bad links (WQA-020).
  - English string (WQA-021).
  - Security first pass: 07-security.md (WQA-022, WQA-023).
  - Public release is still 1.2.1; last night's work is not released.

- 2026-11-16 s5:
  - Share works.
  - Offline works.
  - Backup has tests.
  - Adhan and reminders can be up to 1h late (WQA-024, High).
  - Urdu translation not installed after onboarding (WQA-025).
  - Ayah counter is reversed in RTL (WQA-026).

- 2026-11-16 s6:
  - Public web app is DOWN (WQA-027, Critical, needs Waleed in Vercel).
  - Links are ignored while Settings is open (WQA-028).
  - English leftovers in tools screens (WQA-029).
  - Audio plays; play/pause icon after the end is suspect (WQA-030).

## Notes
- If the emulator system share sheet hangs ("IntentResolver isn't responding"), run `adb shell am force-stop com.android.intentresolver`.
- The emulator boots an old snapshot with an old app build. The app signature differs, so uninstall it, then install `build/app/outputs/flutter-apk/app-x86_64-release.apk`.
- sunnah.com blocks scripts. Read it with in-page `fetch` from the built-in browser on a sunnah.com tab.
- Malik on sunnah.com uses `/malik/<book>/<n>`. Map it from the in-book reference.

## Next, in order
1. Settings: toggle each switch; khatmah plan run; zakah calc; tasbih count; widget.
2. Arabic word search + PWA once WQA-027 is fixed.
3. Library: the EPUB, an Arabic book, a big (50 MB) book, one per language, offline reopen.
5. User journeys and every control on every screen; edge cases; local DB; security; speed; accessibility; final report.

Evidence: `evidence/` (tracked). Screenshots: `_archive/audit-evidence/` (not tracked).
