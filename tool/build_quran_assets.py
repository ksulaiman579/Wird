#!/usr/bin/env python3
"""Build assets/data/quran/{meta.json, surah_NNN.json} from source mirrors.

Tanzil.net itself is unreachable from this environment (egress-blocked), so
this pulls from two open mirrors that redistribute the same underlying texts
under permissive licenses. See DATA_SOURCES.md for full provenance.

  - Arabic (Uthmani script) + English transliteration (itself sourced from
    Tanzil's en.transliteration per that repo's README):
    github.com/risan/quran-json (CC BY-SA 4.0)
  - English translation (verified word-for-word Saheeh International, e.g.
    2:255 and 112:1-4 match the standard Saheeh International renderings):
    github.com/risan/quran-json data/editions/en.json
  - Surah metadata (Arabic/transliterated/English names, revelation type,
    ayah counts): same repo, data/chapters/en.json
  - Juz (para) boundaries: github.com/semarketir/quranjson (MIT) — pure
    structural metadata (which ayah starts/ends each juz), universal across
    all Mushaf editions, cross-checked against well-known boundaries
    (e.g. juz 2 starts at 2:142, juz 3 at 2:253).

Run: python3 tool/build_quran_assets.py
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DOWNLOADS = REPO_ROOT / "tool" / "downloads"
QURAN_JSON_DIR = DOWNLOADS / "quran-json"
QURANJSON_JUZ_DIR = DOWNLOADS / "quranjson-juz"
OUT_DIR = REPO_ROOT / "assets" / "data" / "quran"

SOURCES = {
    QURAN_JSON_DIR: "https://github.com/risan/quran-json.git",
    QURANJSON_JUZ_DIR: "https://github.com/semarketir/quranjson.git",
}

# Standalone Quranic diacritic/annotation marks that aren't word characters,
# stripped before counting words (word count drives the chunking planner).
_DIACRITICS = re.compile(
    "[ً-ٟؐ-ؚۖ-ۭࣔ-ࣣ࣡-ࣿ]"
)


def ensure_sources() -> None:
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    for path, url in SOURCES.items():
        if path.exists():
            continue
        print(f"Cloning {url} -> {path} ...")
        subprocess.run(
            ["git", "clone", "--depth", "1", url, str(path)],
            check=True,
        )


def word_count(arabic: str) -> int:
    stripped = _DIACRITICS.sub("", arabic)
    return len([w for w in stripped.split() if w.strip()])


def build_juz_map() -> list[dict]:
    """Aggregate per-surah juz breakdowns into 30 global (surah,ayah) spans."""
    juz_acc: dict[int, dict] = {}
    for surah_num in range(1, 115):
        data = json.loads(
            (QURANJSON_JUZ_DIR / "source" / "surah" / f"surah_{surah_num}.json").read_text()
        )
        for entry in data["juz"]:
            juz_index = int(entry["index"])
            start_ayah = int(entry["verse"]["start"].removeprefix("verse_"))
            end_ayah = int(entry["verse"]["end"].removeprefix("verse_"))
            if juz_index not in juz_acc:
                juz_acc[juz_index] = {
                    "juz": juz_index,
                    "start": {"surah": surah_num, "ayah": start_ayah},
                }
            juz_acc[juz_index]["end"] = {"surah": surah_num, "ayah": end_ayah}

    juz_map = [juz_acc[i] for i in sorted(juz_acc)]
    if [j["juz"] for j in juz_map] != list(range(1, 31)):
        raise SystemExit(f"FAIL: juz map does not cover exactly 1..30: {sorted(juz_acc)}")
    return juz_map


def enforce_juz_partition(juz_map: list[dict], ayah_counts: dict[int, int]) -> None:
    """The 30 juz must partition the Quran contiguously: juz N+1 starts at
    the ayah immediately after juz N's end. The upstream per-surah files
    are not internally consistent here (found in M21.3: surah 10's file
    claims juz 12 starts at 10:1, overlapping juz 11's 9:93-11:5 span —
    which made whole-Quran plans emit surahs 10 and 11:1-5 twice and blow
    srs_items' UNIQUE constraint at onboarding). Rather than trusting each
    surah file's local claim, repair each juz's start from the previous
    juz's end — derived from the dataset's own boundaries, not typed from
    memory — and log every repair loudly."""
    if (juz_map[0]["start"]["surah"], juz_map[0]["start"]["ayah"]) != (1, 1):
        raise SystemExit("FAIL: juz 1 does not start at 1:1")

    for prev, cur in zip(juz_map, juz_map[1:]):
        end_s, end_a = prev["end"]["surah"], prev["end"]["ayah"]
        if end_a < ayah_counts[end_s]:
            expected = {"surah": end_s, "ayah": end_a + 1}
        else:
            expected = {"surah": end_s + 1, "ayah": 1}
        if cur["start"] != expected:
            print(
                f"  REPAIR: juz {cur['juz']} claimed start "
                f"{cur['start']['surah']}:{cur['start']['ayah']}, "
                f"contiguity demands {expected['surah']}:{expected['ayah']}"
            )
            cur["start"] = expected

    last = juz_map[-1]["end"]
    if (last["surah"], last["ayah"]) != (114, ayah_counts[114]):
        raise SystemExit("FAIL: juz 30 does not end at 114:last")


def juz_for_ayah(juz_map: list[dict], surah: int, ayah: int) -> int:
    for j in juz_map:
        start, end = j["start"], j["end"]
        after_start = (surah, ayah) >= (start["surah"], start["ayah"])
        before_end = (surah, ayah) <= (end["surah"], end["ayah"])
        if after_start and before_end:
            return j["juz"]
    raise SystemExit(f"FAIL: no juz found for {surah}:{ayah}")


def build() -> None:
    ensure_sources()
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    chapters_meta = json.loads(
        (QURAN_JSON_DIR / "data" / "chapters" / "en.json").read_text()
    )
    translations = json.loads(
        (QURAN_JSON_DIR / "data" / "editions" / "en.json").read_text()
    )
    juz_map = build_juz_map()
    enforce_juz_partition(
        juz_map,
        {c["id"]: c["total_verses"] for c in chapters_meta},
    )

    surah_metas = []
    total_ayahs = 0

    for chapter in chapters_meta:
        surah_num = chapter["id"]
        chapter_file = json.loads(
            (QURAN_JSON_DIR / "dist" / "chapters" / f"{surah_num}.json").read_text()
        )
        surah_translations = {t["verse"]: t["text"] for t in translations[str(surah_num)]}

        if len(chapter_file["verses"]) != chapter["total_verses"]:
            raise SystemExit(
                f"FAIL: surah {surah_num} verse count mismatch: "
                f"{len(chapter_file['verses'])} != {chapter['total_verses']}"
            )

        ayahs = []
        for verse in chapter_file["verses"]:
            ayah_num = verse["id"]
            arabic = verse["text"].strip()
            transliteration = verse["transliteration"].strip()
            translation = surah_translations.get(ayah_num, "").strip()

            if not arabic or not transliteration or not translation:
                raise SystemExit(
                    f"FAIL: empty field at surah {surah_num} ayah {ayah_num}"
                )

            ayahs.append(
                {
                    "ayah": ayah_num,
                    "arabic": arabic,
                    "translation": translation,
                    "transliteration": transliteration,
                    "juz": juz_for_ayah(juz_map, surah_num, ayah_num),
                    "wordCount": word_count(arabic),
                }
            )

        total_ayahs += len(ayahs)

        surah_json = {"surah": surah_num, "ayahs": ayahs}
        out_path = OUT_DIR / f"surah_{surah_num:03d}.json"
        out_path.write_text(
            json.dumps(surah_json, ensure_ascii=False, indent=None, separators=(",", ":")),
            encoding="utf-8",
        )

        surah_metas.append(
            {
                "number": surah_num,
                "nameArabic": chapter["name"],
                "nameTransliterated": chapter["transliteration"],
                "nameEnglish": chapter["translation"],
                "ayahCount": chapter["total_verses"],
                "revelationType": chapter["type"],
                "startJuz": ayahs[0]["juz"],
            }
        )

    if total_ayahs != 6236:
        raise SystemExit(f"FAIL: expected 6236 total ayahs, got {total_ayahs}")
    if len(surah_metas) != 114:
        raise SystemExit(f"FAIL: expected 114 surahs, got {len(surah_metas)}")

    meta = {"surahs": surah_metas, "juzMap": juz_map}
    (OUT_DIR / "meta.json").write_text(
        json.dumps(meta, ensure_ascii=False, indent=None, separators=(",", ":")),
        encoding="utf-8",
    )

    print(f"OK: wrote meta.json + {len(surah_metas)} surah files, {total_ayahs} ayahs total.")


if __name__ == "__main__":
    build()
