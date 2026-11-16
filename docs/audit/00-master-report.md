# Wird audit: master report

**Status:** in progress (2 sessions, 2026-11-16). **Readiness:** not assessed yet.

## So far

**Code health:** 0 analyze errors, 671 tests pass. One beta package is in the release and 25 packages are behind.

**Quran:** structure and text check out against an independent edition, ayah by ayah.

**Hadith:**
- Counts are right in all 7 books.
- 159 of 162 sampled hadith (Bukhari, Abu Dawud, Nasai, Tirmidhi, Ibn Majah) have the same text at the same number as sunnah.com, 1 near-match, 2 unverified. Muslim (38) uses other numbering; Malik (30) not yet compared.
- Problems:
  - Arabic commas show as ring marks in every hadith (WQA-009).
  - Sahih Muslim numbers aren't the ones people quote (WQA-013).
  - 15 hadith have a blank English or Arabic line.
  - Urdu falls back to English with no note.
  - Possible wrong-chapter placement where chapter ranges overlap.

**Knowledge Library:**
- 4 dead download links (WQA-008).
- Almost every book lists "IslamHouse" as the author, so different scholars' works of the same name can't be told apart (WQA-007).

**First run:**
- Urdu wording is wrong in places (WQA-010).
- 3 popups appear before the user picks a language (WQA-012).

**Biggest so far:** 700 Tirmidhi and 437 Ibn Majah hadith sit under the wrong book, and whole books (Faith, Knowledge, Supplication...) are missing from the chapter list (WQA-004). The grade badge picks a scholar by source order, so weak/sound can flip against Darussalam (WQA-014).

**Also:** no screen lists bookmarks (WQA-018). Search ignores downloaded Urdu and hadith (WQA-019). The live update file has no checksum (WQA-022). The public release is still 1.2.1.

**Web app is down (Critical):** wird-alpha.vercel.app returns 404, so web users, share links and Android app links are all broken (WQA-027). Builds still succeed; the public address is no longer attached.

**Prayer times:** the adhan and all reminders are scheduled as "inexact", so Android may fire them up to an hour late (WQA-024).

**Bugs:** 30 logged, none fixed. Fixes wait for Waleed.

## Coverage

40 features tracked:

| Status | Count |
|---|---|
| Passed | 4 |
| Failed | 5 |
| In progress | 2 |
| Blocked | 2 |
| Not started | 27 |
