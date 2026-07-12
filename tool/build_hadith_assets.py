#!/usr/bin/env python3
"""Build assets/data/hadith_nawawi.json from source mirrors + curated metadata.

sunnah.com and IslamHouse.com are both unreachable from this environment
(egress-blocked, confirmed via the proxy status endpoint), so this pulls the
Arabic text + narrator attribution and the English translation from two open,
public-domain/permissive mirrors that redistribute Sunnah.com's own hadith
text. See DATA_SOURCES.md for full provenance and how each was verified.

  - Arabic + narrator attribution: github.com/AhmedBaset/hadith-json (ISC)
  - English translation: github.com/fawazahmed0/hadith-api (public domain),
    which is complete and gap-free (AhmedBaset's own English field has
    scraping artifacts — missing words where footnote markup was stripped —
    so it is used only for its Arabic and narrator fields, both verified
    gap-free).

titleEnglish, source, and summary are authored by hand in
tool/hadith_curated.json, written after reading each hadith's actual
(verified) English text in this pipeline — never typed from memory.

Run: python3 tool/build_hadith_assets.py
"""
from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DOWNLOADS = REPO_ROOT / "tool" / "downloads" / "hadith"
OUT_PATH = REPO_ROOT / "assets" / "data" / "hadith_nawawi.json"
CURATED_PATH = REPO_ROOT / "tool" / "hadith_curated.json"

ARABIC_URL = (
    "https://raw.githubusercontent.com/AhmedBaset/hadith-json/"
    "70b83d6d21995bb32f8d7271cd75501be5a922a7/db/by_book/forties/nawawi40.json"
)
ENGLISH_URL = "https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/eng-nawawi.json"

ARABIC_FILE = DOWNLOADS / "nawawi40-arabic.json"
ENGLISH_FILE = DOWNLOADS / "nawawi40-english.json"


def ensure_sources() -> None:
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    for path, url in ((ARABIC_FILE, ARABIC_URL), (ENGLISH_FILE, ENGLISH_URL)):
        if path.exists():
            continue
        print(f"Fetching {url} -> {path} ...")
        with urllib.request.urlopen(url, timeout=30) as resp:
            path.write_bytes(resp.read())


def word_count(text: str) -> int:
    return len([w for w in text.split() if w.strip()])


def build() -> None:
    ensure_sources()
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    arabic_data = json.loads(ARABIC_FILE.read_text(encoding="utf-8"))
    english_data = json.loads(ENGLISH_FILE.read_text(encoding="utf-8"))
    curated = json.loads(CURATED_PATH.read_text(encoding="utf-8"))

    english_by_num = {h["hadithnumber"]: h["text"] for h in english_data["hadiths"]}

    if len(arabic_data["hadiths"]) != 42 or len(english_data["hadiths"]) != 42:
        raise SystemExit(
            f"FAIL: expected 42 hadiths in both sources, got "
            f"{len(arabic_data['hadiths'])} (arabic) / {len(english_data['hadiths'])} (english)"
        )
    if len(curated) != 42:
        raise SystemExit(f"FAIL: expected 42 curated entries, got {len(curated)}")

    records = []
    for h in arabic_data["hadiths"]:
        num = h["idInBook"]
        narrator = h["english"]["narrator"].strip()
        arabic = h["arabic"].strip()
        full_english = english_by_num[num].strip()

        if not full_english.startswith(narrator):
            raise SystemExit(
                f"FAIL: narrator prefix mismatch at hadith {num} — sources drifted, "
                "re-verify alignment before proceeding"
            )
        translation = full_english[len(narrator):].strip()

        meta = curated[str(num)]

        if not (arabic and narrator and translation and meta["titleEnglish"] and meta["summary"]):
            raise SystemExit(f"FAIL: empty field at hadith {num}")

        records.append(
            {
                "id": num,
                "titleEnglish": meta["titleEnglish"],
                "arabic": arabic,
                "translation": translation,
                "narrator": narrator,
                "source": meta["source"],
                "summary": meta["summary"],
                "wordCount": word_count(arabic),
                "core": num <= 40,
            }
        )

    records.sort(key=lambda r: r["id"])
    if [r["id"] for r in records] != list(range(1, 43)):
        raise SystemExit("FAIL: hadith ids are not exactly 1..42")

    OUT_PATH.write_text(
        json.dumps(records, ensure_ascii=False, indent=None, separators=(",", ":")),
        encoding="utf-8",
    )
    print(f"OK: wrote {OUT_PATH.relative_to(REPO_ROOT)} with {len(records)} hadiths.")


if __name__ == "__main__":
    build()
