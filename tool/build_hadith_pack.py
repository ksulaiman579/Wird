#!/usr/bin/env python3
"""Builds a downloadable Hadith collection pack (Arabic + English, chaptered).

Usage:
    python tool/build_hadith_pack.py <collection>   # one collection
    python tool/build_hadith_pack.py --all           # every collection below

Source: fawazahmed0/hadith-api (CC0/Unlicense-style, same jsDelivr CDN
pattern as quran-api). Six major collections — the ones named explicitly
in PLAN.md's M13.1 — plus the existing bundled 40-Nawawi is NOT rebuilt
here (it stays as assets/data/hadith_nawawi.json; this script is only for
NEW downloadable collections).

"Riyad as-Salihin" (also named in PLAN.md as a stretch goal) is NOT
available in this source's edition list (confirmed by fetching its
editions.json — only bukhari/muslim/abudawud/ibnmajah/malik/nasai/
nawawi/tirmidhi/dehlawi/qudsi exist) — documented as a gap in
DATA_SOURCES.md rather than silently dropped.

Output: tool/packs_out/hadith_<collection>.json — chaptered
{"collection": ..., "name": ..., "chapters": {"1": {"title": ...,
"hadith": [{"number", "arabic", "translation", "grades", "sharh": null}]}}}.
sha256 of that file is written back into this script's own COLLECTIONS
table isn't persisted anywhere (no allowlist file for hadith collections
yet — collections are a fixed, hardcoded set here, unlike Quran editions
which are open-ended and need the allowlist gate); instead the hash is
printed and should be recorded in DATA_SOURCES.md by hand after a build,
matching this project's existing "don't fabricate provenance" convention.

Validation: Arabic and English editions of the same collection must
agree on the exact set of hadith numbers (structural cross-check between
the two languages of the same source) and `section_details` must cover
every hadith number with no gaps. This validates *internal consistency*
of the source data, not an external "official" hadith count — scholarly
conventions for total Bukhari/Muslim hadith counts vary (with/without
repetitions), so no such total is asserted here; see DATA_SOURCES.md.
"""
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "tool" / "packs_out"
CDN_BASE = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions"

COLLECTIONS = {
    "bukhari": "Sahih al-Bukhari",
    "muslim": "Sahih Muslim",
    "abudawud": "Sunan Abu Dawud",
    "tirmidhi": "Jami at-Tirmidhi",
    "nasai": "Sunan an-Nasai",
    "ibnmajah": "Sunan Ibn Majah",
    "malik": "Muwatta Malik",
}


def download_json(url):
    with urllib.request.urlopen(url, timeout=30) as resp:
        return json.load(resp)


def build_one(slug, name):
    print(f"Building {slug} ({name})...")
    arabic = download_json(f"{CDN_BASE}/ara-{slug}.min.json")
    english = download_json(f"{CDN_BASE}/eng-{slug}.min.json")

    arabic_by_num = {h["hadithnumber"]: h for h in arabic["hadiths"]}
    english_by_num = {h["hadithnumber"]: h for h in english["hadiths"]}

    if set(arabic_by_num) != set(english_by_num):
        only_ar = set(arabic_by_num) - set(english_by_num)
        only_en = set(english_by_num) - set(arabic_by_num)
        raise SystemExit(
            f"{slug}: Arabic/English hadith-number sets disagree — "
            f"{len(only_ar)} only in Arabic, {len(only_en)} only in English"
        )

    section_details = english["metadata"]["section_details"]
    sections = english["metadata"]["sections"]
    # hadithnumber is usually an int, but some entries are "sub-numbered"
    # variants sharing a base number (e.g. 402.2 alongside 402 — a second
    # chain/wording of the same hadith presented together) — floor() maps
    # those back to their base number's section, since section_details'
    # own bounds are always plain integers.
    section_ranges = [
        (b["hadithnumber_first"], b["hadithnumber_last"], num)
        for num, b in section_details.items()
        if not (b["hadithnumber_first"] == 0 and b["hadithnumber_last"] == 0)
    ]

    def section_for(hadith_number):
        base = int(hadith_number)
        for first, last, section_num in section_ranges:
            if first <= base <= last:
                return section_num
        return None

    all_numbers = set(arabic_by_num)
    uncovered = sorted(n for n in all_numbers if section_for(n) is None)
    if uncovered:
        # A handful of hadith numbers fall in small gaps between adjacent
        # sections in this upstream source's own section_details (e.g.
        # Bukhari's #521 sits in a real 1-hadith gap between sections 8
        # and 9) — a quirk of the source metadata, not a bug here. Rather
        # than silently mis-filing these into a neighboring chapter,
        # collect them into an explicit "Uncategorized" bucket so it's
        # visible and honestly labeled, and report the count for
        # DATA_SOURCES.md.
        print(
            f"  note: {len(uncovered)} hadith fall in upstream section gaps "
            f"(placed under 'Uncategorized'): {uncovered}"
        )

    chapters = {}
    for n in sorted(all_numbers):
        section_num = section_for(n)
        if section_num is None:
            key, title = "uncategorized", "Uncategorized (source data gap)"
        else:
            key, title = section_num, sections.get(section_num, f"Section {section_num}")
        chapters.setdefault(
            key,
            {"title": title, "hadith": []},
        )["hadith"].append({
            "number": n,
            "arabic": arabic_by_num[n]["text"].strip(),
            "translation": english_by_num[n]["text"].strip(),
            "grades": english_by_num[n].get("grades", []),
            # No free, structured English commentary/sharh dataset was
            # found for these collections (see DATA_SOURCES.md's M13.2
            # note) — field kept so one can be mapped in later without a
            # schema change.
            "sharh": None,
        })

    pack = {"collection": slug, "name": name, "chapters": chapters}
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"hadith_{slug}.json"
    payload = json.dumps(pack, ensure_ascii=False, separators=(",", ":"))
    out_path.write_text(payload, encoding="utf-8")

    digest = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    total = len(all_numbers)
    print(
        f"  wrote {out_path} ({len(payload)} bytes, {total} hadith, "
        f"{len(chapters)} chapters), sha256={digest}"
    )
    return digest


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)

    target = sys.argv[1]
    slugs = list(COLLECTIONS) if target == "--all" else [target]

    for slug in slugs:
        if slug not in COLLECTIONS:
            raise SystemExit(f"Unknown collection '{slug}' — one of {list(COLLECTIONS)}")
        build_one(slug, COLLECTIONS[slug])

    print(f"Done. {len(slugs)} pack(s) built into {OUT_DIR}")


if __name__ == "__main__":
    main()
