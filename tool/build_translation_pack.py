#!/usr/bin/env python3
"""Builds a downloadable Quran translation pack for one allowlisted edition.

Usage:
    python tool/build_translation_pack.py <edition_id>   # one edition
    python tool/build_translation_pack.py --all           # every allowlisted edition

Only editions listed in tool/editions_allowlist.json are ever accepted —
this script is the second half of that gate (the allowlist says which
editions MAY be offered; this script is what actually fetches one).

Output: tool/packs_out/translation_<languageCode>_<edition_id>.json — a
single file, `{"edition": ..., "language": ..., "surahs": {"1": [...],
..., "114": [...]}}`, one list-of-{ayah,translation} per surah. sha256 of
that exact file is computed and written back into
editions_allowlist.json's `sha256` field for the edition, pinning it for
the app's own verify-on-download step (TranslationPackService, M12.3).

Validates: exactly 6,236 ayahs total, exactly surahs 1-114 present, and
each surah's verse numbers are a contiguous, gap-free 1..N run — the same
class of check tool/build_quran_assets.py already does for the bundled
Arabic/English data.
"""
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ALLOWLIST_PATH = ROOT / "tool" / "editions_allowlist.json"
OUT_DIR = ROOT / "tool" / "packs_out"

EXPECTED_TOTAL_AYAHS = 6236
EXPECTED_SURAH_COUNT = 114


def load_allowlist():
    with open(ALLOWLIST_PATH, encoding="utf-8") as f:
        return json.load(f)


def save_allowlist(data):
    with open(ALLOWLIST_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def find_edition(allowlist, edition_id):
    for entry in allowlist["editions"]:
        if entry["id"] == edition_id:
            return entry
    raise SystemExit(
        f"'{edition_id}' is not in tool/editions_allowlist.json — refusing "
        "to build a pack for an edition that hasn't been vetted."
    )


def download_json(url):
    with urllib.request.urlopen(url, timeout=30) as resp:
        return json.load(resp)


def validate_and_group(raw_ayahs, edition_id):
    by_surah = {}
    for item in raw_ayahs:
        by_surah.setdefault(item["chapter"], []).append(item)

    if len(raw_ayahs) != EXPECTED_TOTAL_AYAHS:
        raise SystemExit(
            f"{edition_id}: expected {EXPECTED_TOTAL_AYAHS} ayahs total, "
            f"got {len(raw_ayahs)}"
        )
    if set(by_surah.keys()) != set(range(1, EXPECTED_SURAH_COUNT + 1)):
        missing = set(range(1, EXPECTED_SURAH_COUNT + 1)) - set(by_surah.keys())
        extra = set(by_surah.keys()) - set(range(1, EXPECTED_SURAH_COUNT + 1))
        raise SystemExit(
            f"{edition_id}: surah set mismatch — missing {sorted(missing)}, "
            f"unexpected {sorted(extra)}"
        )

    result = {}
    for surah_num, items in by_surah.items():
        items.sort(key=lambda i: i["verse"])
        verses = [i["verse"] for i in items]
        if verses != list(range(1, len(verses) + 1)):
            raise SystemExit(
                f"{edition_id}: surah {surah_num} has non-contiguous verse "
                f"numbers: {verses[:5]}..."
            )
        result[str(surah_num)] = [
            {"ayah": i["verse"], "translation": i["text"].strip()} for i in items
        ]
    return result


def build_one(entry):
    edition_id = entry["id"]
    print(f"Building {edition_id} ({entry['language']})...")
    raw = download_json(entry["link"])
    ayahs = raw["quran"]
    surahs = validate_and_group(ayahs, edition_id)

    pack = {
        "edition": edition_id,
        "language": entry["languageCode"],
        "surahs": surahs,
    }
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"translation_{entry['languageCode']}_{edition_id}.json"
    payload = json.dumps(pack, ensure_ascii=False, separators=(",", ":"))
    out_path.write_text(payload, encoding="utf-8")

    digest = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    entry["sha256"] = digest
    print(f"  wrote {out_path} ({len(payload)} bytes), sha256={digest}")
    return digest


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)

    allowlist = load_allowlist()
    target = sys.argv[1]

    if target == "--all":
        entries = allowlist["editions"]
    else:
        entries = [find_edition(allowlist, target)]

    for entry in entries:
        build_one(entry)

    save_allowlist(allowlist)
    print(f"Done. {len(entries)} pack(s) built into {OUT_DIR}")
    print("editions_allowlist.json sha256 fields updated — commit that change.")


if __name__ == "__main__":
    main()
