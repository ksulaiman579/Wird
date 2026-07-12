#!/usr/bin/env python3
"""Builds the bundled Knowledge Library catalogue (M24.3).

Reads the local IslamHouse corpus index (`islamhouse_routed_index.json`,
produced when the reference corpus was downloaded — not committed to this
repo) and emits `assets/data/knowledge_library.json`: a compact,
metadata-only catalogue of Islamic books the app offers for on-demand
download. **No PDFs are bundled** — each entry carries the IslamHouse CDN
`url` the app pulls from at download time (same model as the audio).

Provenance / vetting basis: every book is published by IslamHouse.com
(the da'wah-publishing arm of the Saudi Ministry of Islamic Affairs,
Rabwah office) — a mainstream Ahlus-Sunnah / Salafi source. That
publisher-level provenance is the aqeedah basis; this script makes no
per-book judgement. It only *filters* the corpus to a shippable set.

Filters (user-approved M24 scope):
  - discipline in the 8 curated categories (the noisy "General" bucket and
    the "01_Quran" category — translations live in the separate
    translation-pack pipeline — are excluded)
  - url ends in .pdf (drops .doc/.docx/.chm/.zip/.epub/... the viewer
    can't render)
  - size <= 50 MB (drops a handful of 150-700 MB scans that would crash
    mobile PDF rendering / be a hostile download)
  - deduped by url

Size is read from the on-disk corpus file when present (fast, local);
otherwise a single ranged GET (`Range: bytes=0-0`) reads the
`Content-Range` total from the CDN (IslamHouse's Cloudflare edge rejects
HEAD but honours ranged GET). Entries whose size can't be determined are
dropped rather than shipped unsized.

Usage:
    python tool/build_islamhouse_catalogue.py [CORPUS_DIR]
    (CORPUS_DIR defaults to C:/Users/Administrator/Desktop/Resources)
"""
import json
import os
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "data" / "knowledge_library.json"

DEFAULT_CORPUS = Path("C:/Users/Administrator/Desktop/Resources")

MAX_BYTES = 50 * 1024 * 1024

# corpus discipline dir -> (display name, stable slug used in-app/routes)
DISCIPLINES = {
    "02_Aqeedah": ("Aqeedah (Creed)", "aqeedah"),
    "03_Hadith": ("Hadith", "hadith"),
    "04_Tafseer": ("Tafsir", "tafsir"),
    "05_Fiqh": ("Fiqh (Jurisprudence)", "fiqh"),
    "06_Seerah": ("Seerah (Biography)", "seerah"),
    "07_Dawah": ("Da'wah", "dawah"),
    "08_Adab_wa_Akhlaq": ("Manners & Ethics", "adab"),
    "09_Arabic_Language": ("Arabic Language", "arabic"),
}

LANG_CODE = {
    "AR(Arabic)": "ar",
    "EN(English)": "en",
    "UR(Urdu)": "ur",
    "BN(Bangla)": "bn",
    "TG(Tagalog)": "tl",
    "HI(Hindi)": "hi",
    "ML(Malayalam)": "ml",
}


def local_size(corpus, rel_path):
    if not rel_path:
        return None
    p = corpus / rel_path.replace("\\", "/")
    try:
        return p.stat().st_size
    except OSError:
        return None


def remote_size(url):
    """Total size via a 1-byte ranged GET reading Content-Range."""
    req = urllib.request.Request(
        url,
        headers={"Range": "bytes=0-0", "User-Agent": "Mozilla/5.0 (WirdCatalogueBuilder)"},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            cr = resp.headers.get("Content-Range")  # "bytes 0-0/1234567"
            if cr and "/" in cr:
                total = cr.rsplit("/", 1)[1].strip()
                if total.isdigit():
                    return int(total)
            cl = resp.headers.get("Content-Length")
            if cl and cl.isdigit():
                return int(cl)
    except Exception:
        return None
    return None


def clean_title(t):
    t = (t or "").strip()
    # collapse internal whitespace/newlines the corpus titles sometimes carry
    return " ".join(t.split())


def main():
    corpus = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CORPUS
    index_path = corpus / "islamhouse_routed_index.json"
    if not index_path.exists():
        raise SystemExit(f"corpus index not found: {index_path}")

    with open(index_path, encoding="utf-8") as f:
        idx = json.load(f)

    seen_urls = set()
    out = []
    dropped = {"discipline": 0, "nonpdf": 0, "toobig": 0, "nosize": 0, "dup": 0, "lang": 0}

    for b in idx:
        disc = b.get("discipline")
        if disc not in DISCIPLINES:
            dropped["discipline"] += 1
            continue
        url = b.get("url", "")
        if not url.lower().endswith(".pdf"):
            dropped["nonpdf"] += 1
            continue
        if not url.startswith("https://"):
            dropped["nonpdf"] += 1
            continue
        if url in seen_urls:
            dropped["dup"] += 1
            continue
        lang = b.get("language")
        if lang not in LANG_CODE:
            dropped["lang"] += 1
            continue

        size = local_size(corpus, b.get("path"))
        if size is None:
            size = remote_size(url)
        if size is None:
            dropped["nosize"] += 1
            continue
        if size > MAX_BYTES:
            dropped["toobig"] += 1
            continue

        seen_urls.add(url)
        display, slug = DISCIPLINES[disc]
        out.append({
            "id": b["id"],
            "title": clean_title(b.get("title")),
            "author": clean_title(b.get("author")) or "IslamHouse",
            "discipline": slug,
            "languageCode": LANG_CODE[lang],
            "url": url,
            "sizeBytes": size,
        })

    out.sort(key=lambda e: (e["languageCode"], e["discipline"], e["title"]))

    # self-validation
    for e in out:
        assert e["url"].startswith("https://") and e["url"].lower().endswith(".pdf")
        assert 0 < e["sizeBytes"] <= MAX_BYTES
        assert e["discipline"] in {s for _, s in DISCIPLINES.values()}

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(out, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )

    from collections import Counter
    per_lang = Counter(e["languageCode"] for e in out)
    per_disc = Counter(e["discipline"] for e in out)
    print(f"wrote {OUT} — {len(out)} books, {OUT.stat().st_size} bytes")
    print("per language:", dict(per_lang))
    print("per discipline:", dict(per_disc))
    print("dropped:", dropped)


if __name__ == "__main__":
    main()
