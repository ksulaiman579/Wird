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

## Notes
- The emulator boots an old snapshot with an old app build. The app signature differs, so uninstall it, then install `build/app/outputs/flutter-apk/app-x86_64-release.apk`.
- sunnah.com blocks scripts. Read it with in-page `fetch` from the built-in browser on a sunnah.com tab.
- Malik on sunnah.com uses `/malik/<book>/<n>`. Map it from the in-book reference.

## Next, in order
1. Hadith reader: bookmarks list, share card, word search (Arabic with and without marks), deep links, offline, failed download (airplane mode).
2. Library: the EPUB, an Arabic book, a big (50 MB) book, one per language, offline reopen.
5. User journeys and every control on every screen; edge cases; local DB; security; speed; accessibility; final report.

Evidence: `evidence/` (tracked). Screenshots: `_archive/audit-evidence/` (not tracked).
