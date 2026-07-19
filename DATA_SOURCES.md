# Data Sources & Provenance

This file records where every piece of bundled content in the app comes from, so authenticity can always be traced back to its source. Updated as each content-pipeline task lands. Surfaced in-app via Settings → About, alongside a tappable Credits section (`lib/core/credits.dart`, mirrored in `README.md`'s Credits & Acknowledgements — keep all three in sync).

## License summary

Quick-reference table; see each section below for full provenance, verification method, and any caveats. This covers bundled *content* — code dependency licenses are audited separately in M9.1.

| Content | Primary source | License |
|---|---|---|
| Uthmanic Hafs font | KFGQPC (via `mustafa0x/qpc-fonts` mirror) | KFGQPC font license (free use/distribution for Quran display) |
| Quran Arabic, translation, transliteration | `risan/quran-json` | CC BY-SA 4.0 (attribution + share-alike) |
| Quran juz boundaries | `semarketir/quranjson` | MIT |
| 40 Hadith Arabic + narrator | `AhmedBaset/hadith-json` | ISC |
| 40 Hadith English translation | `fawazahmed0/hadith-api` | Public domain / Unlicense |
| 40 Hadith titles, source/grading, summaries | Hand-authored (`tool/hadith_curated.json`) | Original to this project |
| Hisnul Muslim & adhkar | `wafaaelmaandy/Hisn-Muslim-Json` | Source repo unlicensed (no LICENSE file) — traditional public-domain religious text; used as informational reference content, not redistributed standalone |
| Recitation audio | everyayah.com (CDN, streamed/downloaded, never bundled) | Public Qari-authorized recitations; no formal license file at the source |
| Cities (prayer-time location) | `dr5hn/countries-states-cities-database` | ODbL (attribution required — this file serves as that attribution) |
| Adhan notification tone (`assets/audio/adhan.ogg`, `android/.../res/raw/adhan.ogg`) | `File:Beautiful_adhan.ogg` by Adam-synagda, Wikimedia Commons | CC0 1.0 (public-domain dedication) — the single bundled adhan reminder tone |
| 99 Names of Allah (`assets/data/asma_ul_husna.json`) | Azan-MCP project (`src/azan_mcp/data/asma_ul_husna.json`) | MIT. Arabic/transliteration/meaning are canonical; the `explanation` prose is bundled commentary — reviewed as neutral & aqeedah-safe (no tashbih/ta'wil), pending final scholarly sign-off. Note for reviewers: the standard 99-enumeration is a narrator's compilation (Tirmidhi), and the "paired" names (Al-Mudhill, Ad-Darr, Al-Khafid, Al-Mani', Al-Muntaqim) are traditionally cited in pairs. |

## Fonts

- **`assets/fonts/UthmanicHafs.otf`** — KFGQPC Uthmanic Script HAFS (Ver09), by the King Fahd Glorious Qur'an Printing Complex (KFGQPC). This is the standard Unicode-encoded Uthmani-script font designed to pair with Tanzil's Uthmani text encoding (used for the app's Quran display).
  - Source: `github.com/mustafa0x/qpc-fonts` (`various/UthmanicHafs1 Ver09.otf`), a mirror of the official KFGQPC font distribution.
  - License: King Fahd Complex font license (see `http://dm.qurancomplex.gov.sa/copyright-2/`) — free to use/distribute for Quran display; do not resell or claim authorship.
  - Note: the mirror repo also contains the KFGQPC *mushaf* (`QCF_*`/`QCF4_Hafs_*`) glyph-substitution fonts, which map each glyph to a specific word at a specific position on a specific printed Mushaf page — not used here since the app needs reflowable Unicode text, not fixed-page rendering.

## UI display font (M22.1)

- **`assets/fonts/Marcellus-Regular.ttf`** — Marcellus, by Astigmatic (AOETI), a classical Roman-inscription serif used for headings/titles only (body text stays the system font). Source: Google Fonts (`github.com/google/fonts`, `ofl/marcellus`). License: **SIL Open Font License 1.1** — free to bundle and redistribute, including in a GPL-3.0 app (OFL is compatible; the font is not "linked" and keeps its own licence). No Latin-glyph gap for the app's UI copy.

## Quran text

Tanzil.net itself returns a policy-level 403 from this session's egress proxy (confirmed via `curl` and the proxy's own status endpoint — not a transient failure), so per `TASKS.md`'s pre-approved fallback list, the build script (`tool/build_quran_assets.py`) pulls from two open mirrors instead. Both were spot-checked against known-reference verses before use (see the script's own docstring for the verification method):

- **Arabic (Uthmani script) + English transliteration** — `github.com/risan/quran-json` (commit `791a3cf`, CC BY-SA 4.0). The transliteration in this repo is itself sourced from Tanzil's `en.transliteration` per its own README. The Arabic uses Tanzil-style Uthmani Unicode codepoints (the small-high marks in the U+06D6–U+06ED range), matching what the bundled KFGQPC Uthmanic Hafs font is designed to render — not plain/simple Arabic diacritics.
- **English translation** — same repo, `data/editions/en.json`. Verified word-for-word against known Saheeh International renderings (2:255 Ayat al-Kursi and all four ayahs of Al-Ikhlas) before use; not labeled explicitly in the repo's README but the wording is an exact match.
- **Surah metadata** (Arabic/transliterated/English names, revelation type, ayah counts) — same repo, `data/chapters/en.json`.
- **Juz (para) boundaries** — `github.com/semarketir/quranjson` (commit `7ca6f46`, MIT), aggregated per-surah from `source/surah/surah_N.json`'s `juz` field. This is pure structural metadata (which ayah starts/ends each juz) — universal across all Mushaf editions — and was cross-checked against well-known boundaries (juz 1 ends 2:141, juz 2 starts 2:142, juz 30 starts 78:1) before use.
- Both mirrors' total ayah counts were verified at 6,236 before merging; the build script itself re-validates this plus 114 surahs / 30 juz / non-empty fields on every run and fails loudly (non-zero exit) if anything is off.
- **License note:** the Arabic/translation/transliteration data is CC BY-SA 4.0 (attribution + share-alike) via the risan/quran-json mirror; attribute "Quran JSON by Risan" if that dataset is ever redistributed standalone. The juz boundaries are MIT-licensed structural metadata.
- Source repos are cloned into `tool/downloads/` (gitignored, not committed) by the build script on first run; only the processed `assets/data/quran/*.json` output is committed.

### Additional-language translation packs (v2 — M12.1)

Beyond the bundled English translation above, the app lets a user download ONE extra translation of their choice at onboarding (or later from the Library). Only editions listed in `tool/editions_allowlist.json` are ever offered — that file is the single gate; an edition not in it is invisible to the app regardless of what's available upstream. Built by reviewing a local clone of `fawazahmed0/quran-api` (Unlicense; `sources/Quran-api/editions.json` — not committed to this repo, reference-only) for editions whose author/institution is well-established as mainstream Ahlus Sunnah wal-Jama'ah: official state Islamic-affairs bodies (Diyanet, JAKIM), the Saudi King Fahd Quran Printing Complex (directly or via its `quranenc.com`/`qurancomplex.gov.sa` domains), or long-standing tanzil.net-hosted translations with no history of sectarian controversy.

The allowlist currently holds **64 languages, one edition each** (see the M24.1/M24.2 notes below). The original 9 (M12.1: French Hamidullah, German Bubenheim & Elyas, Urdu Fateh Muhammad Jalandhry, Turkish Diyanet İşleri, Indonesian King Fahd Complex, Spanish Islamic Foundation/Montada, Bengali Abu Bakr Zakaria, Russian Elmir Kuliev, Malay Abdullah Muhammad Basmeih) were individually hand-vetted. The 37 added in M21.4 (user request for broader language coverage) were selected **mechanically by source domain**: for every remaining upstream language that has an edition whose declared `source` is `qurancomplex.gov.sa` (King Fahd Complex) or `quranenc.com` (IslamHouse's translation portal), exactly one such edition was taken, preferring qurancomplex over quranenc where both exist — i.e. the institution, not this project, is the vetting authority for those 37. Languages with no edition from either institution remain excluded. All 46 packs were fetched and built by `tool/build_translation_pack.py` from `fawazahmed0/quran-api`'s jsDelivr CDN — each validated at exactly 6,236 ayahs / 114 surahs / contiguous per-surah verse numbers, and sha256-pinned into `editions_allowlist.json`. Built output lives in gitignored `tool/packs_out/` (not committed); re-run the script to reproduce. **This is still not a final scholarly review** — a human/scholar sign-off before public release is recommended; the allowlist file documents each entry's provenance so that review has something concrete to check.

**M24.1 (2026-07-08) added 10 more languages, one native-script edition each** (romanized `-la`/`-lad` transliteration variants were explicitly excluded — only the native-script translation is offered): Thai (King Fahd Glorious Quran Printing Complex), Dhivehi (Office of the President of the Maldives), Amharic (Muhammed Sadiq & Muhammed Sani Habib), Swahili (Ali Muhsin Al-Barwani), Pashto (Abdul Wali Khan), Sindhi (Taj Mehmood Amroti), Tatar (Yakub ibn Nugman), Azerbaijani (Alikhan Musayev), Amazigh/Berber (Ramdane At Mansour), Chinese (Ma Jian). These are institutional or long-standing standard renderings; selection restricted to editions declaring a King Fahd Complex / `quranenc.com` / `tanzil.net` source, one per language, each built + 6,236/114-validated + sha256-pinned like the rest. M24.2 briefly added 8 further languages whose only available translation is an academic/orientalist one (Bulgarian, Czech, Dutch, Italian, Norwegian, Polish, Romanian, Swedish). **These 8 were REMOVED (2026-07-19) after a Salaf/Ahlus-Sunnah screening**: 5 are by non-Muslim orientalists (Nykl/cs, Leemhuis/nl, Berg/no, Bielawski/pl, Grigore/ro), Bernström/sv is based on Muhammad Asad's rationalist/Muʿtazilī-leaning tafsir, and Theophanov/bg + Piccardo/it are Muslim but not from a vetted Ahlus-Sunnah institution (King Fahd Complex / IslamHouse / quranenc). None met the app's institutional-provenance bar, so those languages ship with no bundled additional translation rather than a questionable one. Allowlist is back to 56 editions.

## 40 Hadith of an-Nawawi

sunnah.com and IslamHouse.com are both unreachable from this environment's egress proxy (same policy-level 403 pattern as tanzil.net — confirmed, not transient). `tool/build_hadith_assets.py` sources the underlying text from two open mirrors instead:

- **Arabic text + narrator attribution** — `github.com/AhmedBaset/hadith-json` (pinned to commit `70b83d6d21995bb32f8d7271cd75501be5a922a7`, ISC license), `db/by_book/forties/nawawi40.json`. This repo's own English translation field was found to have scraping artifacts (missing words at points where footnote markup had been stripped, e.g. hadith 6, 8, 9, 34, 36 and others), so it's used **only** for its Arabic and narrator fields — both checked and confirmed gap-free across all 42 entries before use.
- **English translation** — `github.com/fawazahmed0/hadith-api` (version tag `1`, public domain / Unlicense), `editions/eng-nawawi.json`. Confirmed complete and gap-free (zero mid-sentence double-space artifacts across all 42, vs. 18 in the other mirror's English field). Its `text` field bundles the narrator attribution and the hadith proper together (as in the original book); the narrator portion is stripped off using AhmedBaset's own narrator string as a prefix match, verified to align exactly for all 42 hadiths before being used to split the two mirrors' text.
- **titleEnglish, source (Bukhari/Muslim/etc. + hasan/sahih grading), and summary** — hand-authored in `tool/hadith_curated.json`, written after reading each hadith's actual verified English text above (not from memory of the matn). Source/grading attributions were read directly from the bracketed or free-text citations at the end of each hadith's translation (e.g. "[Bukhari & Muslim]", "It was related by at-Tirmidhi, who said it was a hasan hadeeth") rather than recalled. Summaries are neutral, 2-4 sentence explanations aimed at understanding, avoiding sectarian language; hadith 38 (on Allah's nearness to His servant) includes the standard Ahlus Sunnah qualifier that such descriptions are understood in a manner befitting Allah's majesty, without resembling creation (tanzih, not tamthil).
- All 42 hadiths are included (the 40 core + 2 commonly appended in published editions), flagged via `core: true/false` (1-40 are core).
- The build script re-validates 42 hadith count, narrator/text alignment across both mirrors, and non-empty fields on every run.

### Downloadable Hadith collection packs (v2 — M13.1)

Six major collections, downloadable individually (onboarding picker or later from the Library), sourced from `fawazahmed0/hadith-api` (same CDN family as the Nawawi English translation above and the Quran translation packs; CC0/Unlicense-style, no rate limits, no keys). Built and validated for real in this session (`tool/build_hadith_pack.py`, real network access):

| Collection | Hadith | Chapters | sha256 |
|---|---|---|---|
| Sahih al-Bukhari | 7,589 | 98 | `d6e2def0963be1d162f3d76dafcf49737329dd384db94c2909f5a5c0dde99236` |
| Sahih Muslim | 7,563 | 57 | `fb94618f803000b4b0c641b4797ed82652e06129dbae06097cd6d3884226593d` |
| Sunan Abu Dawud | 5,274 | 43 | `ee62e9638f005f24b3cacc1fb08f416719db3948c9f80b3bddfd60d2dad4e8b2` |
| Jami at-Tirmidhi | 3,998 | 43 | `ae194531543fca15f044b0ba5993ea3f4b2e1d8b26bb91ac083d3a394b153051` |
| Sunan an-Nasai | 5,765 | 52 | `b762fbcaf3c9293cc82192bb9c391ab74bb78c1767851ea8022d432faaf147e6` |
| Sunan Ibn Majah | 4,343 | 31 | `00e159077804bde339d2becabd7c4d9ea8c4342622a616b6b9814e6fc1b33fea` |

- Each pack pairs the Arabic edition (`ara-<slug>`, full tashkeel) with the English edition (`eng-<slug>`) from the same source, keyed by the same `hadithnumber` so translations align to the correct hadith.
- **Validation performed:** the Arabic and English editions of each collection were cross-checked to agree on the exact same set of hadith numbers (catches any edition-specific gaps between the two languages), and every hadith number was mapped to a chapter via the source's own `section_details` metadata.
- **Known upstream data quirk, handled transparently, not silently patched:** a small number of hadith numbers per collection fall in gaps between adjacent sections in the source's own `section_details` (e.g. Bukhari's #521 sits in a genuine 1-hadith gap between sections 8 and 9). These are placed in an explicit "Uncategorized (source data gap)" chapter rather than guessed into a neighboring one. Counts: Bukhari 6, Nasai 82 (a larger contiguous block, #3857–3938), all others 0.
- **Spot-check against the local reference corpus:** Bukhari hadith #1's Arabic text was compared word-for-word against `sources/Hadith-Data-Sets-master/All Hadith Books/Sahih Bukhari.csv` (a separate, independently-sourced Arabic corpus of the Nine Books) — exact match (differing only in punctuation marks the CSV omits). That corpus (CSV, Arabic-only, no per-hadith metadata) wasn't used as the primary source since it lacks English translations and chapter/grading structure, but serves as a cross-check corpus per PLAN.md.
- **No externally-asserted "official" hadith count**: scholarly conventions for total Bukhari/Muslim hadith counts vary depending on whether repeated narrations are counted separately — this project validates *internal* consistency (Arabic/English agree, every hadith has a chapter) rather than asserting a specific external total it can't independently verify.
- **Sharh (commentary) gap (M13.2):** no free, structured English commentary dataset was found for any of these six collections — each hadith's `sharh` field is `null`, present only so a mapping can be added later without a schema change. The app ships with the existing 40-Nawawi hand-written summaries only; these six new collections show Arabic + English + grading, no summary.
- **"Riyad as-Salihin" was NOT available** in this source's edition list (confirmed by fetching its `editions.json` directly — only bukhari/muslim/abudawud/ibnmajah/malik/nasai/nawawi/tirmidhi/dehlawi/qudsi exist), despite being named as a stretch goal in PLAN.md. Documented here as a real gap rather than silently dropped; `malik` (Muwatta) and `qudsi`/`dehlawi` (40-hadith collections) ARE available in the same source if a future session wants to add them.
- Built output lives in gitignored `tool/packs_out/` (not committed); re-run `python tool/build_hadith_pack.py --all` to reproduce. No allowlist file exists for hadith collections (unlike Quran translations) since the set of major hadith collections is fixed/well-known rather than open-ended — the six above are hardcoded in the build script itself.

### Hadith authenticity vetting + Muwatta Malik (M23.11)

Applies the same content-integrity discipline the Al-Manhaj curriculum uses for hadith (grade badge, verified source, "do not guess a grade"):

- **Grade classifier** (`lib/core/hadith/hadith_grade.dart`, unit-tested): each hadith's authenticity is resolved from the **source's own grader verdicts** (the `grades` array that `fawazahmed0/hadith-api` ships — e.g. al-Albānī for the Sunan, Salīm al-Hilālī for the Muwaṭṭaʾ), normalised to Ṣaḥīḥ / Ḥasan / Ḍaʿīf / Mawḍūʿ / Ungraded. The reader shows this as a colour-coded badge and, for weak/fabricated/ungraded narrations, an explicit reader caution. **No grade is invented** — Bukhārī/Muslim with no per-hadith grade fall back to authentic by the agreed status of the two Ṣaḥīḥs; every other collection with no grade is labelled "Ungraded", never assumed authentic.
- **Muwaṭṭaʾ Mālik added** (`malik`) — 1,858 hadith, 62 chapters, from the same graded source (sha256 `ed8846a6bfeec6866e586c96d11f5b94063d2a78b4d956d1bcfd33d3ef72309d`; download ~3 MB). Wired into the shelf, Library and onboarding picker like the other six.
- **Musnad Aḥmad and Sunan ad-Dārimī deliberately NOT shipped.** The only local corpus for them (`Resources/Hadith-Data-Sets-master/All Hadith Books/*.csv`) is **Arabic-only, un-numbered and ungraded** — plain text lines with no grader verdicts and no canonical (sunnah.com) numbering. Presenting Musnad Aḥmad (which contains many weak and some fabricated narrations) as flat ungraded text would violate the "do not guess a grade" rule, so it is excluded until a graded, canonically-numbered source is available. This is the honest outcome of applying the vetting bar, not an oversight.
- **Numbering:** collections use the upstream source's own `hadithnumber`, which follows the widely-used online (sunnah.com-family) numbering for these editions; not independently re-verified hadith-by-hadith, so numbering is labelled as the source's rather than asserted canonical.

## Hisnul Muslim & Adhkar

islamhouse.com and hisnmuslim.com are both unreachable from this environment's egress proxy (same policy-level 403 pattern confirmed for every direct Islamic-content domain tried this session). `tool/build_dua_assets.py` sources from an open mirror instead:

- **Source:** `github.com/wafaaelmaandy/Hisn-Muslim-Json`, `husn_en.json` (132 chapters, 267 dua items covering the full Hisn al-Muslim / Fortress of the Muslim book). Fields used: `ARABIC_TEXT` (full tashkeel), `TRANSLATED_TEXT` (English — matches known Saheeh International wording where it overlaps with Qur'anic text, e.g. Ayat al-Kursi), `LANGUAGE_ARABIC_TRANSLATED_TEXT` (transliteration, present for most but not all items), `REPEAT` (repetition count).
- **QA before use:** scanned all 267 items for encoding corruption (none found — the earlier `iotmani/hisnul-muslim` mirror considered for this task had visible mojibake in its English "meaning" field, e.g. "AllahÂ’s name", and was rejected for that reason) and for missing required fields. Three items (133, 185, 267) are missing either their Arabic or English side and are dropped from the output (logged by the build script); this empties chapters 74 and 132, which are also dropped.
- **Transliteration** is nullable in the output schema — about 15% of items have none in the source, and 3 items (75, 100, 101) had a Quran-recitation reference note ("Recite Ayat-Al-Kursiy...") in that field instead of an actual transliteration (the ayah is already fully quoted in Arabic), so those are also set to null rather than mislabeled.
- **Reference field** is `"Hisn al-Muslim (Fortress of the Muslim) — <chapter title>"` rather than a precise hadith citation (e.g. "Bukhari 6312") — the source dataset doesn't carry per-item hadith references, unlike the 40 Hadith Nawawi pipeline which does. This is accurate (every dua really is from that book/chapter) but coarser than the Nawawi hadith citations; a future pass could cross-reference a dataset with exact citations if one is found.
- **Morning/evening adhkar:** the book presents morning and evening remembrance as a single combined chapter (chapter 27, "Words of remembrance for morning and evening", 24 items) rather than two separate lists. A handful of its duas use time-specific wording (e.g. "asbahna" = "we have reached morning" vs. the evening variant "amsayna" = "we have reached evening") that traditionally gets swapped for the evening recitation — rather than editing the sourced wording to produce a synthesized evening variant, `adhkar_morning_evening.json` reuses the exact same 24 verified items for both `morning` and `evening` arrays. This is a known simplification, not a content error; refining it would need a source that explicitly separates the two.
- Chapter 27 appears in both `hisnul_muslim.json` (as a browsable/memorizable category, like any other) and `adhkar_morning_evening.json` (for the dedicated daily-recitation reader) — intentional duplication, not an error.

### Circumstance-theme grouping (v2 — M14.1/M20.4)

The Duas tab clubs the 130 categories into 8 circumstance-theme groups (Daily routine, Prayer & the mosque, Morning/evening & sleep, Distress & protection, Food/family & social life, Illness & bereavement, Travel/Hajj & Umrah, Remembrance & nature) so browsing doesn't mean scrolling a flat 130-item list. This is a **presentation-layer grouping only** — `lib/features/dua/dua_theme_groups.dart`, a plain Dart map from category id to group, not a change to the sourced `hisnul_muslim.json` content itself. A unit test (`test/features/dua_theme_groups_test.dart`) asserts every category id in the JSON lands in exactly one group, so the mapping can't silently drift out of sync as the source data is regenerated.

## Knowledge Library (IslamHouse books — M24.3)

The Knowledge Library offers Islamic books for on-demand download, pulled directly from **IslamHouse.com's CDN** (`d1.islamhouse.com`). **No PDFs are bundled** — the app ships only a metadata catalogue (`assets/data/knowledge_library.json`, ~540 KB) and downloads each file when the user chooses to, verifying nothing beyond the size (the file is the publisher's own, unmodified).

- **Provenance / vetting basis:** every book is published by **IslamHouse.com**, the da'wah-publishing arm of the Saudi Ministry of Islamic Affairs (Rabwah office) — a mainstream Ahlus-Sunnah wal-Jama'ah / Salafi source. That *publisher-level* provenance is the aqeedah basis; the app makes no per-book judgement of its own. Disciplines come from the corpus's own classification.
- **Build:** `tool/build_islamhouse_catalogue.py` reads a local corpus index (`islamhouse_routed_index.json`, produced when the reference corpus was downloaded — not committed) and filters to a shippable set: the 8 curated disciplines (Aqeedah, Hadith, Tafsir, Fiqh, Seerah, Da'wah, Manners & Ethics, Arabic Language — the huge noisy "General" bucket and the "Quran" category are excluded, the latter because translations live in the separate translation-pack pipeline), **PDF-only** (drops ~73 .doc/.chm/.zip the in-app viewer can't render), and **≤50 MB** (drops ~73 files of 150–700 MB that would crash mobile PDF rendering). Deduped by URL. Sizes come from the on-disk corpus file where present, else a ranged GET reading `Content-Range` (IslamHouse's Cloudflare edge rejects HEAD but honours ranged GET). Entries whose size can't be resolved are dropped, not shipped unsized.
- **Result:** **2,040 books** across 7 languages — Arabic 931, English 501, Urdu 215, Bangla 168, Tagalog 102, Hindi 66, Malayalam 57. Per-entry fields: `{id, title, author, discipline, languageCode, url, sizeBytes}`. The build self-validates that every kept URL is https + .pdf + ≤50 MB. Re-run the script to regenerate.
- **Scope note (like the Quran allowlist):** this is IslamHouse's own published corpus filtered by category/format/size, not a hand-audited reading list — a scholar/maintainer pass before public release is still recommended; the discipline classification is IslamHouse's, and a few items may be filed under a broad category.

## Zakah fiqh notes & tables (M23.10)

The Zakah calculator's per-form educational notes (`lib/core/zakah/zakah_notes.dart`) and the livestock/agriculture/rikaz figures encoded in `lib/core/zakah/zakah_calculator.dart` are **condensed summaries of the mainstream Sunni (four-madhhab) fiqh of Zakah**, not scripture text and not novel rulings.

- **Basis:** the standard, non-controversial positions found across the vetted fiqh corpus (`Resources/` fiqh references) and universally reported in classical Zakah chapters — nisab of 85 g gold / 595 g silver; 2.5 % on monetary wealth, trade goods and zakatable investments; ushr of 10 % (rain-fed) / 5 % (costly irrigation) on produce reaching ~653 kg (5 awsuq); the classical camel/cattle/sheep livestock tables; and 20 % (khums) on rikaz with no nisab or hawl.
- **Neutrality:** notes are factual and aqeedah-safe, flag where schools differ (e.g. personal-use jewellery, long-term shares) and explicitly defer individual rulings to a trustworthy scholar. No amount is presented as a fatwa.
- **Currencies** (`lib/core/zakah/currencies.dart`): a bundled ISO-4217 subset — **symbol/name/formatting only**. There is no exchange-rate lookup or currency conversion anywhere; all figures are entered and reported in one chosen currency, offline by design.

## Recitation audio

- Per-ayah recitation streamed (M4.1/M4.2) and, on native builds, downloaded for offline use (M4.3) from everyayah.com. **M23.8 expanded the reciter list from 3 to 18** — Husary (Murattal, default; + Muallim/teaching), Alafasy, Abdul Basit (Murattal 64/192), Minshawi (Murattal + Mujawwad), Sudais, Shuraim, Ajmy, Ghamdi, Hudhaify, Maher Al-Muaiqly, Muhammad Ayyoub, Abu Bakr Ash-Shatri, Nasser Al-Qatami, Yasser Ad-Dossari, Ali Jaber. Each folder was verified against everyayah.com over the network (first/last/scattered ayahs → HTTP 200; everyayah publishes each reciter as a complete 6,236-file set). URL pattern and folder/quality naming come straight from everyayah.com's own per-ayah file layout (`<reciter>/<SSS><AAA>.mp3`); no separate provenance concern beyond the CDN itself being the audio's origin.

## Cities (M5.2 — location for prayer times)

`geolocator` was removed (its Android build links `play-services-location`, which F-Droid forbids) in favor of a bundled, searchable list of cities the user picks from manually — no location permission is ever requested.

- **Source:** `github.com/dr5hn/countries-states-cities-database` (pinned to commit `7d23ecbf6268bd72765266c45a83d3f4f9e8173c`), `json/countries.json` (country → declared capital name) joined against `json/countries+states+cities.json` (city-level lat/lng) by `tool/build_cities_asset.py`.
- **License: ODbL (Open Database License)** — attribution required if this database (or a substantial extract of it) is redistributed; this notice serves as that attribution. Only factual coordinates for ~200 capital cities are extracted, not the source database itself.
- **Coverage:** one capital city per sovereign state/territory in the source (203 of ~250 matched cleanly). A small number of countries' `capital` field didn't match any city entry verbatim (e.g. translated/alternate spellings) and were resolved via a short, manually verified alias table in the build script (e.g. Mexico's capital field says "Ciudad de México" but the matching city entry is named "Mexico City"; Indonesia's capital "Jakarta" only exists as its five constituent districts, so "Jakarta Pusat" (Central Jakarta) is used for coordinates while still displaying "Jakarta"). ~48 minor territories (small islands, uninhabited territories, a few whose capital genuinely isn't in the city list) are skipped rather than guessed — logged by the script on each run. Users in a skipped location use the manual lat/lng entry fallback.
- The 46MB combined dataset is fetched once into `tool/downloads/cities/` (gitignored); only the extracted `assets/data/cities.json` (~200 entries, ~26KB) is committed.

## App logo (v2 — M19)

- **`WIRD.jpg`** (project root; processed into `assets/icon/icon.png`, `icon_foreground.png`, `splash_logo.png`, and `logo_display.png`) — the app icon and splash logo, a gold/emerald circular emblem with the app name in Arabic (وِرْد) and English.
- **Provenance:** confirmed directly with the project maintainer (not independently verifiable from the file itself — it carries no EXIF/metadata) — generated by the maintainer using Google's Gemini/Imagen image-generation tool, and owned by them. Free to redistribute as part of this GPL-3.0 project; not third-party licensed content.
- **Processing:** the source JPEG (2048×2048, opaque, no alpha) was flood-filled from its white background corners to produce a transparent-background version, from which the Android adaptive-icon foreground (66% scale, safe-zone convention), splash logo, and in-app display asset (onboarding welcome step, About screen) were derived. The flat `icon.png` (main launcher icon on platforms without adaptive-icon masking) keeps the original opaque white background.

## Cloud backup (M22.6 — optional, Al-Manhaj Supabase)

Wird is offline-first and account-free. An **optional** Al-Manhaj (Supabase)
sign-in exists solely to back up/restore the local profile to the cloud —
see `lib/core/cloud/cloud_config.dart` for the full architecture note. Key
properties for scale: the app never contacts the cloud during normal use;
only three explicit user actions (sign up, back up, restore) make a
stateless GoTrue/PostgREST call; no realtime, no polling, no auto-sync — so
registered-user count is decoupled from concurrent load. Ships **disabled**
(`CloudConfig.isConfigured == false`) until Al-Manhaj's real project URL +
anon key are supplied (via `--dart-define WIRD_SUPABASE_URL=… WIRD_SUPABASE_ANON_KEY=…`
or by editing the defaults); until then the Al-Manhaj tab shows a
"coming soon" sign-in and no network code runs. A first-boot disclaimer
states the app is offline and any sign-in is optional and one-time.

## Dependency license audit (M9.1 — FOSS compliance)

Daily is licensed GPL-3.0 (see `LICENSE`). Every *direct* Dart/Flutter dependency in `pubspec.yaml`, checked against the license file bundled in its published package, all confirmed permissive and GPL-3.0-compatible (a permissive-licensed dependency can be used by/distributed alongside GPL-3.0 code; nothing here imposes a conflicting copyleft term). No dependency required removal or replacement.

| Package | License |
|---|---|
| `flutter`, `flutter_test` (SDK) | BSD-3-Clause |
| `cupertino_icons` | MIT |
| `flutter_riverpod` | MIT |
| `riverpod_annotation` | MIT |
| `riverpod_generator` | MIT |
| `go_router` | BSD-3-Clause |
| `drift`, `drift_flutter`, `drift_dev` | MIT |
| `shared_preferences` | BSD-3-Clause |
| `just_audio` | MIT |
| `audio_session` | MIT |
| `background_downloader` | BSD-3-Clause |
| `flutter_local_notifications` | BSD-3-Clause |
| `timezone` | BSD-3-Clause |
| `flutter_timezone` | Apache-2.0 (GPL-3.0-compatible per the FSF; note this combination would **not** be valid under GPL-2.0-only) |
| `adhan_dart` | MIT |
| `share_plus` | BSD-3-Clause |
| `http` | BSD-3-Clause |
| `freezed_annotation`, `freezed` | MIT |
| `json_annotation`, `json_serializable` | BSD-3-Clause |
| `file_picker` | MIT |
| `sqlite3_flutter_libs` | MIT |
| `flutter_native_splash` | MIT |
| `flutter_lints` | BSD-3-Clause |
| `build_runner` | BSD-3-Clause |
| `flutter_launcher_icons` (dev-only, not shipped) | MIT |

Method: for each package, resolved the exact installed version from `pubspec.lock`, then read the `LICENSE`/`LICENSE.md` file bundled in that package's own published source (not pub.dev's listing page, which can lag) to classify it — BSD-3-Clause identified by its "Redistributions of source code/binary form... neither the name of the copyright holder..." three-clause text, distinct from the 2-clause or 0-clause BSD variants. `sqlite3_flutter_libs` bundles native SQLite (public domain) binaries; the Dart-side wrapper itself is MIT.
