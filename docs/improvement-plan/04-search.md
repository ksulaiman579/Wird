# Search (Phase 3 / M28)

Covers M25.H3 (global search). Decision: passages only, no AI-written answers. Everything on the phone.

## Today

- Every search is a plain substring check on data already in memory, re-run on each keystroke.
- Ayah text isn't searchable at all. Hadith full text is "deferred"
  (`features/explore/global_search_screen.dart:12-15`).
- No Arabic normalisation: "الفاتحه" doesn't find "الفاتحة" (`features/quran_browser/quran_browser_screen.dart:146-157`).
- No ranking, no highlight, no debounce. Queries only hit English fields whatever the UI language.
- The one good piece: the dua synonym map in `core/content/dua_search.dart:10-60` (tested). Keep it.

## 3a. Keyword search (also works on the PWA)

**Normaliser** — `lib/core/search/arabic_normalizer.dart`, pure Dart, unit-tested:
- strip tashkeel, Quranic marks and tatweel
- fold أ إ آ ٱ → ا, ى → ي, ة → ه, ؤ ئ → ء forms
- same function used when building the index and on the query

**Index** — one Drift FTS5 table:

```
search_index(kind, ref, lang, text)      -- text is normalised
  kind: ayah | translation | translit | hadith | dua | name
  ref:  route to open, e.g. /read?surah=2&ayah=255
```

- Filled in a background isolate on first run from the bundled JSON, and updated when a
  translation or hadith pack is installed or removed.
- Check the bundled `web/sqlite3.wasm` has FTS5. If not, rebuild it with
  `tool/build_drift_web_assets.sh`.
- Schema bump + migration test.

**Query**
- 250 ms debounce. Prefix match on the last word.
- Rank with FTS5 `bm25`; exact phrase first; surah-name and number matches pinned to the top.
- Highlight matched words with `snippet()`.
- Filter chips: Quran / Hadith / Duas / All. Results grouped by kind.
- Dua synonyms from `dua_search.dart` expand the query before it hits the index.

**Screen**
- One search screen replaces `global_search_screen.dart`. Tapping a result opens the exact ayah,
  hadith or dua.
- The small in-screen filters (surah list, 99 Names, hadith chapter) keep their simple filter but
  run the normaliser first.

## 3b. Search by meaning (optional download, native first)

No vector database. At this size a plain list of vectors compared one by one is faster than any
database would be.

**Built once on a PC** — `tool/build_search_vectors.py`:
- Unit of text:
  - one ayah; very short ayahs are embedded with the ayah before and after for context
  - one hadith; long ones split into ~200-word parts with a small overlap
  - one dua
- Text embedded: Arabic + English translation together, with a multilingual model, so a query in
  any of the 7 languages lands near the right passage.
- Output: one file of int8 vectors + a list of refs. ~15k passages × 384 ≈ 6 MB.
- Validation in the script: counts match (6,236 ayahs), no empty vectors. Shipped through the
  existing pack path with a pinned sha256.

**On the phone**
- The same model turns the query into a vector (ONNX runtime, in an isolate).
- Compare against all vectors (a few ms), take the top 50.
- Merge with the keyword results by rank position (each list votes; passages in both rise).
- If the model isn't downloaded, search is keyword-only and says so with a "better search" download prompt.

**Model trial (go / no-go)**
- ≤ ~40 MB, under ~150 ms per query on a mid-range phone.
- Test set: ~100 questions across en/ar/ur/hi/bn/ml/fil with the passages a person would expect.
  Pass mark: the expected passage in the top 5 for most of them, per language.
- Try a small multilingual sentence model, and a lookup-table style model (much smaller and faster,
  somewhat less accurate). Pick on the test set. Check versions and licences at trial time.

**PWA**: keyword only in v1.

## Why no generated answers

Wrong religious statements are the one failure this app can't afford, and a hosted model would cost
money per question. Showing the source text with its reference avoids both.

## Per-language notes

- Arabic: normaliser above.
- Urdu: fold Arabic/Urdu letter variants (ک/ك, ی/ي, ہ/ه) in the same normaliser.
- Hindi, Bengali, Malayalam: FTS5's default tokeniser splits on spaces, which is fine; add NFC
  normalising so composed/decomposed forms match.
- Filipino, English: lower-case, strip accents (built in).
- A translation is only searchable once its pack is installed. Meaning search covers the gap, since
  it matches across languages.

## Tests

- Normaliser unit tests (Arabic and Urdu cases).
- A fixed list of queries with expected top results per language, run in `flutter test`.
- Index build test: row counts per kind.
