#!/usr/bin/env python3
"""Build assets/data/{hisnul_muslim.json, adhkar_morning_evening.json}.

islamhouse.com and hisnmuslim.com are both unreachable from this environment
(egress-blocked, same policy pattern as tanzil.net/sunnah.com — see
DATA_SOURCES.md), so this pulls from an open mirror of the Hisn al-Muslim
(Fortress of the Muslim) book instead: github.com/wafaaelmaandy/Hisn-Muslim-Json,
which bundles Arabic, English translation (Saheeh-International-style
wording — matches known Ayat al-Kursi renderings), and mostly-transliteration
in one place, with per-dua repetition counts. QA-scanned for encoding
corruption (none found) and missing fields (3 items out of 267 are missing
either their Arabic or English side and are dropped — logged below).

Run: python3 tool/build_dua_assets.py
"""
from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DOWNLOADS = REPO_ROOT / "tool" / "downloads" / "dua"
SOURCE_FILE = DOWNLOADS / "husn_en.json"
SOURCE_URL = (
    "https://raw.githubusercontent.com/wafaaelmaandy/Hisn-Muslim-Json/"
    "master/husn_en.json"
)

DUA_OUT = REPO_ROOT / "assets" / "data" / "hisnul_muslim.json"
ADHKAR_OUT = REPO_ROOT / "assets" / "data" / "adhkar_morning_evening.json"

# The book presents morning and evening remembrance as a single combined
# chapter; a handful of its duas use time-specific wording ("asbahna" =
# "we have reached morning" vs "amsayna" = "we have reached evening") that
# would need swapping for an evening-only variant. Rather than editing the
# sourced wording, the same verified text is reused for both trigger times.
ADHKAR_CHAPTER_ID = 27

# Items whose "transliteration" field is actually a Quran-recitation
# reference note, not a transliteration (the ayah is already fully quoted
# in ARABIC_TEXT) — verified by reading each one, not guessed by regex alone.
NOTE_NOT_TRANSLITERATION_IDS = {75, 100, 101}


def ensure_source() -> None:
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    if SOURCE_FILE.exists():
        return
    print(f"Fetching {SOURCE_URL} -> {SOURCE_FILE} ...")
    with urllib.request.urlopen(SOURCE_URL, timeout=30) as resp:
        SOURCE_FILE.write_bytes(resp.read())


def word_count(arabic: str) -> int:
    return len([w for w in arabic.split() if w.strip()])


def build_dua(item: dict, chapter_title: str) -> dict | None:
    arabic = item.get("ARABIC_TEXT", "").strip()
    translation = item.get("TRANSLATED_TEXT", "").strip()
    if not arabic or not translation:
        print(f"SKIP: dua item {item.get('ID')} missing arabic or translation")
        return None

    transliteration = item.get("LANGUAGE_ARABIC_TRANSLATED_TEXT", "").strip()
    if item["ID"] in NOTE_NOT_TRANSLITERATION_IDS or not transliteration:
        transliteration = None

    return {
        "id": f"hm-{item['ID']}",
        "arabic": arabic,
        "transliteration": transliteration,
        "translation": translation,
        "reference": f"Hisn al-Muslim (Fortress of the Muslim) — {chapter_title}",
        "repetitions": item.get("REPEAT", 1),
        "wordCount": word_count(arabic),
    }


def build() -> None:
    ensure_source()
    DUA_OUT.parent.mkdir(parents=True, exist_ok=True)

    data = json.loads(SOURCE_FILE.read_text(encoding="utf-8-sig"))
    chapters = data["English"]

    if len(chapters) != 132:
        raise SystemExit(f"FAIL: expected 132 chapters, got {len(chapters)}")

    categories = []
    adhkar_items = None

    for chapter in sorted(chapters, key=lambda c: c["ID"]):
        duas = [
            d
            for item in chapter["TEXT"]
            if (d := build_dua(item, chapter["TITLE"])) is not None
        ]
        if not duas:
            print(f"SKIP: chapter {chapter['ID']} ({chapter['TITLE']}) has no usable duas left")
            if chapter["ID"] == ADHKAR_CHAPTER_ID:
                raise SystemExit("FAIL: the adhkar chapter itself ended up empty")
            continue

        categories.append(
            {
                "id": f"hm-cat-{chapter['ID']}",
                "titleEnglish": chapter["TITLE"],
                "order": chapter["ID"],
                "duas": duas,
            }
        )
        if chapter["ID"] == ADHKAR_CHAPTER_ID:
            adhkar_items = duas

    if adhkar_items is None:
        raise SystemExit(f"FAIL: adhkar chapter {ADHKAR_CHAPTER_ID} not found")

    total_duas = sum(len(c["duas"]) for c in categories)

    DUA_OUT.write_text(
        json.dumps({"categories": categories}, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )
    ADHKAR_OUT.write_text(
        json.dumps(
            {"morning": adhkar_items, "evening": adhkar_items},
            ensure_ascii=False,
            separators=(",", ":"),
        ),
        encoding="utf-8",
    )

    print(
        f"OK: wrote {DUA_OUT.relative_to(REPO_ROOT)} "
        f"({len(categories)} categories, {total_duas} duas) and "
        f"{ADHKAR_OUT.relative_to(REPO_ROOT)} ({len(adhkar_items)} items x2)."
    )


if __name__ == "__main__":
    build()
