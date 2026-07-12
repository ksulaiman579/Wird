#!/usr/bin/env python3
"""Stage the exact files to upload to the Supabase `content` bucket (Item 1.27).

Downloads byte-identical mirrors of the upstream CDN files the app fetches at
runtime, into `tool/supabase_upload/` mirroring the bucket layout:

    supabase_upload/
      quran-packs/<upstream-filename>.json      # 64 translation editions
      hadith-packs/ara-<collection>.min.json     # 7 collections x 2
      hadith-packs/eng-<collection>.min.json

Then in the Supabase dashboard, create a PUBLIC bucket named `content` and
drag the two subfolders into it. The app (ContentSource) will prefer these
mirrors and fall back to the CDN automatically.

Run:  python tool/build_supabase_upload.py
(honours CURL_CA_BUNDLE via requests/urllib if the proxy needs it)
"""
import json
import os
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "tool", "supabase_upload")
ALLOWLIST = os.path.join(ROOT, "tool", "editions_allowlist.json")

HADITH_CDN = "https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions"
HADITH_COLLECTIONS = [
    "bukhari", "muslim", "abudawud", "tirmidhi", "nasai", "ibnmajah", "malik",
]


def fetch(url: str, dest: str) -> None:
    if os.path.exists(dest) and os.path.getsize(dest) > 0:
        print(f"  skip (exists): {os.path.basename(dest)}")
        return
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "wird-supabase-stager"})
    with urllib.request.urlopen(req, timeout=60) as r:
        if r.status != 200:
            raise RuntimeError(f"HTTP {r.status} for {url}")
        data = r.read()
    # Validate it parses as JSON before saving (don't upload junk).
    json.loads(data)
    with open(dest, "wb") as f:
        f.write(data)
    print(f"  ok ({len(data)//1024} KB): {os.path.basename(dest)}")


def main() -> int:
    editions = json.load(open(ALLOWLIST, encoding="utf-8"))
    if isinstance(editions, dict):
        editions = editions.get("editions") or next(iter(editions.values()))

    print(f"Staging {len(editions)} translation packs -> quran-packs/")
    q_dir = os.path.join(OUT, "quran-packs")
    failures = []
    for e in editions:
        link = e["link"]
        name = link.split("/")[-1]
        try:
            fetch(link, os.path.join(q_dir, name))
        except Exception as ex:  # noqa: BLE001
            failures.append((name, str(ex)))
            print(f"  FAIL {name}: {ex}")

    print(f"\nStaging {len(HADITH_COLLECTIONS)} hadith collections -> hadith-packs/")
    h_dir = os.path.join(OUT, "hadith-packs")
    for c in HADITH_COLLECTIONS:
        for lang in ("ara", "eng"):
            fn = f"{lang}-{c}.min.json"
            try:
                fetch(f"{HADITH_CDN}/{fn}", os.path.join(h_dir, fn))
            except Exception as ex:  # noqa: BLE001
                failures.append((fn, str(ex)))
                print(f"  FAIL {fn}: {ex}")

    print("\n" + "=" * 50)
    if failures:
        print(f"DONE with {len(failures)} failure(s):")
        for name, err in failures:
            print(f"  - {name}: {err}")
        print("Re-run to retry (existing files are skipped).")
        return 1
    print(f"DONE. Upload the two folders under:\n  {OUT}\n"
          "into the Supabase `content` bucket (public).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
