# Hadith verification

Source: fawazahmed0 hadith-api via jsDelivr (`@1/editions`). Checked 2026-11-16 by
`tool/audit/hadith_audit.py` (read-only). Full numbers: `evidence/hadith_audit.md` / `.json`.

## Script results

- **Counts:** all 7 books match the app's declared counts after dropping entries empty in both languages.
- **Gaps in numbering:** these are the empty upstream placeholders, which the app drops on purpose. Muslim 201, Nasai 86, Tirmidhi 67, Malik 29, Bukhari 9, Ibn Majah 3, Abu Dawud 2.
- **No duplicate numbers** in any file. **No numbers** are found in only one of Arabic or English.
- **One side empty:**
  - Malik: 11 with no English (WQA-002).
  - Tirmidhi and Ibn Majah: 2 each with no Arabic (WQA-003).
- **Repeated English text under different numbers:** Bukhari 302, Muslim 192, Nasai 65. These look like an edition difference: Bukhari and Muslim repeat narrations through different chains. Not filed as errors; the sample check will confirm.
- **No grade:**
  - Bukhari and Muslim: all hadith. This is expected; the app labels them authentic by book.
  - Tirmidhi 36, Nasai 7, Ibn Majah 2: these show as "Ungraded", which is correct per the never-guess rule.
- **Overlapping chapter ranges:** Muslim 4, Tirmidhi 4, Ibn Majah 2 (WQA-004, under investigation).
- **Bukhari:** 6 hadith fall outside every chapter range and show under "Other narrations".
- **Urdu:**
  - No Urdu file for Muslim (404) (WQA-001).
  - Gaps elsewhere: Nasai 1809, Bukhari 564, Malik 254 (WQA-005).
- **Bengali:** small gaps, between 4 and 89 per book.

## Sample vs sunnah.com

Not started. Plan: about 30 per book, spread across the book plus the overlap numbers. For each, compare number, book/chapter, the Arabic opening words and the grade. Classify every difference as one of:

- confirmed error
- edition difference
- numbering difference
- translation difference
- unverified

No text will be changed.
