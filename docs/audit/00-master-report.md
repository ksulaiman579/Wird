# Wird audit: master report

**Status:** in progress (session 1, 2026-11-16). **Readiness:** not assessed yet. That needs the device passes done first.

## So far

- Code health:
  - analyze: 0 errors, 12 minor notes.
  - tests: 671 pass.
  - packages: one beta package in the release; 25 packages are behind.
- Hadith data: counts check out for all 7 books. Real issues found:
  - A dead "Get Urdu text" button on Sahih Muslim.
  - Blank English or Arabic lines on 15 hadith.
  - Possible wrong-chapter placement where the source's chapter ranges overlap.
  - Urdu silently falls back to English for many Nasai, Bukhari and Malik hadith.
- Bugs logged: 6 (WQA-001 to 006). None fixed. Fixes wait for Waleed.

## Coverage

39 features tracked. Passed: 3. Failed: 1. In progress: 2. Blocked: 2. Not started: 31.
