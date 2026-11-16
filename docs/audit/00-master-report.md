# Wird audit: final report (2026-11-16)

This covers 8 audit rounds in one day, on the Android emulator (release build), the web app, and the source code and data. Detail is in `03-bug-register.csv` (WQA-001 to 037) and `02-coverage-matrix.csv`.

## 1. Summary

The app is solid. Code checks are clean, all 671 tests pass, offline use works, the Quran text matches an independent edition, and startup is fast.

The serious problems are in the hadith data and in prayer-time timing, not in the app's structure:
- **Hadith in the wrong book.** 1,137 hadith in Tirmidhi and Ibn Majah sit under the wrong book, and whole books (Faith, Knowledge, Supplication, Fitan…) never appear (WQA-004).
- **Grade badge.** It shows whichever scholar happens to be listed first, so weak and sound can flip compared with Darussalam (WQA-014).
- **Adhan timing.** The adhan and all reminders may fire up to an hour late (WQA-024).
- **Web app outage.** The web app and every share link were down. Waleed fixed this the same day, and the fix is verified (WQA-027).

**Readiness: ready for internal testing.** It isn't ready for a wider release until the three High items above are fixed. The public release (1.2.1) predates last night's work.

## 2. What was inventoried

40+ screens and routes, every outside service, and all bundled data. See `01-inventory.md`. There's no backend, no accounts and no server database, so the server, API and login checks don't apply.

## 3. Coverage

45 features tracked:

| Status | Count |
|---|---|
| Passed | 13 |
| Failed | 14 |
| In progress | 5 |
| Blocked | 3 |
| Not started | 10 |

"Failed" means at least one confirmed issue; most of the feature still works.

Blocked:
- iOS, Safari and Firefox: not available on this machine.
- Home-screen widget: placing one needs manual launcher steps.
- Crash reports: no Sentry key yet.

## 4. Hadith reader

See `05-hadith-verification.md` and `evidence/hadith_sample.md`.

**Counts:** correct in all 7 books.

**Text check:** 159 exact matches plus 1 near match out of 162 sampled against sunnah.com. Malik: 29 of 30.

**Problems:**
- 1,137 hadith in the wrong book (WQA-004).
- The grade badge picks a scholar by source order (WQA-014).
- "Shadh" shows as Ungraded (WQA-015).
- Muslim numbers aren't the ones people usually cite (WQA-013).
- 15 hadith have a blank Arabic or English line (WQA-002, WQA-003).
- Arabic commas show as ring marks (WQA-009).
- Urdu falls back to English with no note (WQA-005).
- The Urdu honorific mark shows as an empty box (WQA-016).

**Reader features:**
- Passed: search by number and by word, Arabic search with and without vowel marks, offline reading, failed-download retry.
- No list of bookmarks anywhere (WQA-018).

## 5. Knowledge Library (IslamHouse)

All 2,041 links were checked:
- 4 are dead (WQA-008).
- 1,983 books list "IslamHouse" as the author instead of the real author (WQA-007).
- The library opens on English books whatever the app language (WQA-017).

Downloading and opening a PDF works.

## 6. Bug register

37 entries:

| Severity / status | Count |
|---|---|
| Critical, verified fixed | 1 |
| High, open | 3 |
| Medium, open or investigating | 14 |
| Medium, fixed by Waleed | 1 |
| Low | 17 |
| Closed, not a bug | 1 |

## 7. Security and privacy

See `07-security.md`.

**Passed:** no secrets in the repo, no plain-HTTP connections, and the book reader can't run scripts.

**Problems:**
- The live update file has no checksum (WQA-022).
- The app asks for precise location when approximate is enough (WQA-023).

## 8. Speed

See `08-performance.md`.
- Android cold start: 2.3–2.8 s. Memory: 140 MB. APK: 42 MB.
- Web first load: 5.3 MB in about 1.5 s.
- Web offline cache likely misses the script fonts (WQA-032).

## 9. UI, UX and accessibility

See `09-ux-accessibility.md`.
- Buttons without screen-reader names, and small tap areas (WQA-034).
- Large text cuts off some labels (WQA-035).
- The ayah counter reads backwards in RTL (WQA-026).
- First run stacks 3 popups (WQA-012).
- Links are ignored while Settings is open (WQA-028).
- Bad links show raw errors (WQA-020).

## 10. Technical

- One beta package ships in the release, and 25 packages are behind (WQA-006).
- Supabase had lapsed; Waleed restored it, and the free plan may pause it again (WQA-031).
- The Urdu translation isn't installed after onboarding (WQA-025).
- Global search covers only English built-in content (WQA-019).

## 11. Content integrity

**Quran:** 6,236/6,236 ayahs pass. The only differences are 3 known Uthmani spellings.

**Hadith:** see section 4.

**Duas:**
- No per-dua hadith references, and the source has no licence (WQA-036).
- The source's double brackets show around the Arabic.
- The evening adhkar have their own wording and are correct.

**Translation and wording:**
- Urdu wording is poor in places (WQA-010).
- English is left in the Urdu app in several spots (WQA-011, 021, 029).

## 12. Action plan

**P0, now:**
1. WQA-004: put hadith under the right book (narrowest matching range).
2. WQA-024: exact alarms for the adhan.
3. WQA-014: decide which grader to show (Waleed's call).

**P1:**
- WQA-025: Urdu translation after onboarding
- WQA-009: commas showing as ring marks
- WQA-018: bookmarks list
- WQA-028: links ignored on Settings
- WQA-008: dead library links
- WQA-015: Shadh grade
- WQA-022: update checksum
- WQA-019: search in the app's language
- WQA-032: web offline fonts

**P2:**
- WQA-007: library authors
- WQA-013: Muslim citation numbers
- WQA-034: accessibility labels and tap size
- WQA-036: dua references
- WQA-010: Urdu review
- WQA-005, 002, 003: missing-text notes
- WQA-006: packages

**P3:** the rest of the Low items.

## 13. Regression plan

See `11-regression-plan.md`.

## 14. Readiness

**Ready for internal testing.** Move to beta once the P0 list is fixed and re-verified on the emulator.

The audit scripts in `tool/audit/` can be re-run after every release:
- `hadith_audit.py`
- `quran_audit.py`
- `library_links.py`
