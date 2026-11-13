# Read-along: recite and follow (Phase 4 / M29)

Covers M25.I5 ("mistake tracking, recite-along pacing"). Decision: recognition runs on the phone.

## What exists today

- Playback only: `just_audio`, per-ayah files, ayah-level highlight
  (`features/quran_reader/quran_reader_screen.dart:114-128`).
- No microphone package or permission. No word timing data. No word-by-word data — words come from
  splitting on spaces (`shared/widgets/word_cloak_text.dart:47`, `core/exercises/micro_exercises.dart:10`).
- Hide-and-reveal words: `word_cloak_text.dart`. Review grading into SM-2: `features/session/review_flow.dart`,
  `core/srs/sm2_scheduler.dart`. Only one grade per review is stored (`core/db/tables.dart:51-58`).

## Scope for v1

- Android and iOS builds. Not the PWA.
- The user starts from a known ayah (from the reader, a review, or new material).
- Follows word by word, flags skipped / wrong / extra words and long pauses.
- Does **not** judge tajweed or vowel marks. Say so in the app.

## Step 0 — trial before building (go / no-go)

Small throwaway app or test harness. Pass marks:

- Runs at least 2× faster than real time on a mid-range Android phone.
- Word accuracy good enough to follow on ~30 min of real recitation: men, women, children, non-Arab
  accents, phone-quality microphones.
- Model licence allows free redistribution.
- Model file ≤ ~80 MB after quantising.

Candidates to try: a Quran-tuned Whisper tiny/base through `sherpa_onnx` (ONNX runtime, has voice
activity detection and Flutter bindings), and whisper.cpp as a fallback. Check current versions and
licences at trial time — don't rely on this note.

If nothing passes: fall back to "self-check" mode (user taps along) and revisit later.

## How it fits together

```
microphone ──► 16 kHz audio ──► voice detection ──► speech model (background isolate)
                                                         │ words heard, refreshed ~every 0.7 s
                                                         ▼
                              expected words ──► follower (pure Dart) ──► position + mistakes
                                                         │
                                         ValueNotifier ──┴──► highlight / reveal on screen
```

### Microphone
- `record` package, PCM stream at 16 kHz mono.
- Add `RECORD_AUDIO` (Android) and `NSMicrophoneUsageDescription` (iOS). Ask only when the user
  first opens read-along, with a one-line reason. Audio is never saved or sent anywhere.
- Pause recitation playback while listening (audio session already has a speech config in
  `core/audio/ayah_audio_service.dart:121-128`, currently never initialised — fixed in Phase 1).

### Recognition
- Runs in its own isolate so the screen never stalls.
- Whisper-type models work on chunks, not a live stream. To feel live: keep a rolling window of the
  last few seconds, re-run it every ~0.7 s, and only trust words that stayed the same across two runs.
- Voice detection drops silence so the model isn't run on nothing (saves battery).
- Model is an optional download through the existing pack path (`core/content/content_source.dart`),
  hosted as a GitHub release asset, sha256 checked.

### Text to match against
- The model writes plain modern spelling without marks; the app shows Uthmani script. They don't
  compare directly.
- New `tool/build_recitation_words.py`: takes Tanzil's plain-spelling text and the Uthmani text we
  already bundle, maps them word for word per ayah, and validates counts (6,236 ayahs; every Uthmani
  word mapped). Record the source in `DATA_SOURCES.md`. Nothing typed by hand.
- Output: per-surah word list `[uthmaniIndex, normalisedWord]`, shipped as an asset or small pack.
- Normalising uses the same `core/search/arabic_normalizer.dart` as search (Phase 3).

### Follower (new `lib/core/recitation/`, pure Dart, unit-tested)
- Input: expected words for the current ayah plus the next two; the latest words heard.
- Lines the two up with a forgiving match (small spelling differences allowed, since the model
  mishears).
- Output: current word index, plus events — `skipped`, `wrong`, `extra`, `stuck` (pause over ~4 s).
- Only moves forward on confident matches. A repeat (going back a few words) is allowed and not
  counted as a mistake.
- "Where am I?": if the first few words don't match the expected place, look them up in the
  Phase 3 search index and offer to jump.

### Mistakes and scheduling
- New Drift table `recitation_mistakes(id, contentKey, wordIndex, type, createdAt)` (schema v8, with
  a migration test).
- After a pass, suggest the review grade from the mistakes (none → Good, a stuck or two → Hard,
  several wrong/skipped → Again). The user can change it. Feeds the existing SM-2 unchanged.
- Words missed more than once get shown as weak spots on the next review.

### Screen
- One `ValueNotifier<int>` for the word index; only the active ayah listens.
- Two modes: text visible (highlight moves), and text hidden (reuse `word_cloak_text.dart`; words
  appear as they're recited — the memorisation test).
- Wrong word: brief red underline. Stuck: offer the first letter, then the word.
- Entry points: reader menu, review flow (`review_flow.dart`), new material self-test step
  (`new_material_flow.dart:21`).

## Later

- Word highlight during reciter playback: needs word timing files per reciter (vetted source, as a
  download). Same screen code as above.
- PWA: possible with a WebAssembly build of the model; heavy on phones' browsers. Park.
- Tajweed feedback: needs a different kind of model. Out of scope.

## Risks

- Accuracy on children and strong accents — the trial is there to find out early.
- Battery and heat on long sessions — voice detection and a capped session length help.
- Old phones — detect speed on first use; if too slow, offer self-check mode instead.
