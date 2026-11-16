# Hadith sample vs sunnah.com (2026-11-16)

**How this was done:** 230 hadith pages were read in a browser from `sunnah.com/<book>:<n>`. sunnah.com blocks scripts (403), so a browser had to be used. The sample numbers are in `sample_numbers.json`: 30 spread across each book, plus the overlap numbers. For each hadith, the first 6 Arabic words were compared with the same number in the app's source (fawazahmed0, read live from jsDelivr), with marks removed. Book/chapter number and grade were also compared.

| Book | Sample | Same text at same number | Notes |
|---|---|---|---|
| Bukhari | 30 | 30 | — |
| Abu Dawud | 30 | 30 | — |
| Nasai | 30 | 30 | — |
| Tirmidhi | 38 | 37 | 2735: different opening. Its first 6 words also appear at app 2535, but a shared chain opening could explain that. Unverified. |
| Ibn Majah | 34 | 32 + 1 near | 2528: different, unverified. 2477: same first 3 words. |
| Muslim | 38 | 0 | Numbering difference. See below. |
| Malik | 30 | — | Blocked. sunnah.com links Malik by book/hadith, not by number. |

**Muslim numbering.** sunnah.com uses Fuad ʿAbd al-Bāqī's numbers, which run to about 3,033 (with a/b sub-letters). The app's source numbers each narration on its own, giving 7,360. So the same hadith carries different numbers:
- The Jibrīl hadith is "Muslim 8" on sunnah.com and in most citations.
- In the app it is **93**. This was confirmed on the emulator.

This is a numbering difference, not a text error. Users who look up a cited number will land on the wrong hadith (WQA-013).

**Book numbers.** Tirmidhi and Ibn Majah sometimes show a book index that is 1 to 4 off from sunnah.com's book index. The two sources split the books differently, so this is an edition difference: the hadith text and number match.

**Grades.** Not compared. sunnah.com's grade field didn't come through the page reader. Still to do.

**Verdict.** No confirmed text errors: 159 exact + 1 near of 162 comparable; 2 unverified. The Muslim numbering and the Malik check still need follow-up.

## Session 3 additions (2026-11-16)

**Malik.** sunnah.com book pages were matched against the app's chapter for each sampled hadith. 29 of 30 were found in the same book. 1363 was not found in book 31 (unverified).

**Grades (110 of 132 compared so far).**
- Same category as Darussalam: 83.
- No grade on sunnah.com: 9.
- Different: 18. Most are Sahih vs Hasan between scholars, which is a difference of opinion.
- Weak vs sound flips: Nasai 947 and 2273, Ibn Majah 579, Tirmidhi 2654 and 2735. See WQA-014.
- Nasai 2841 is graded "Shadh" and shows as Ungraded (WQA-015).

**Chapter overlaps (WQA-004).** Confirmed with the sample:
- Tirmidhi 2158, 2298, 2606, 2654, 3370 and Ibn Majah 2090, 2172, 2316, 2436 all sit in a different book on sunnah.com than in the app.
- In every case, the narrowest matching range in the source gives sunnah.com's book.
