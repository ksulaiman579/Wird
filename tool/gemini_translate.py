#!/usr/bin/env python3
"""Fill the remaining ARB gaps for the ship locales via the Gemini API.

Complements the NLLB draft (tool/translate_arb.py): NLLB left ~255 short/
ambiguous strings as English and can't touch the 9 ICU plural keys. Gemini
(an instruction model) handles both — including correct per-language plural
categories — so this pass gets the 5 ship locales to 100% translated.

Key handling: read from --key-file ONLY (kept outside the repo, never
committed/echoed). The corpus builder shares this key's quota, so batches are
large, requests are few, and 429s back off; the pass is resumable (only fills
strings still equal to English).

  python tool/gemini_translate.py --key-file <path>            # ur,hi,bn,ml,fil
  python tool/gemini_translate.py --key-file <path> --locales hi --limit 20
"""
import argparse
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(__file__))
from translate_arb import (  # reuse the shared infra
    GLOSSARY, ICU, PLACEHOLDER, SHIP_LOCALES, FROZEN, TEMPLATE, load, save_arb,
)

LANG = {
    "ar": "Arabic", "ur": "Urdu", "hi": "Hindi", "bn": "Bengali (Bangla)",
    "ml": "Malayalam", "fil": "Filipino (Tagalog)",
}


def translatable(k, v):
    """Like translate_arb.is_translatable but INCLUDES ICU keys (Gemini can do
    them). Still skips @metadata and pure-glossary values."""
    if k.startswith("@") or not isinstance(v, str):
        return False
    if v.strip() in GLOSSARY:
        return False
    return bool(re.search(r"[A-Za-z]", v))


def gemini(key, model, prompt, tries=6):
    url = (f"https://generativelanguage.googleapis.com/v1beta/models/"
           f"{model}:generateContent?key={key}")
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0.2,
                             "responseMimeType": "application/json"},
    }
    for i in range(tries):
        try:
            req = urllib.request.Request(
                url, data=json.dumps(body).encode(),
                headers={"Content-Type": "application/json"})
            r = json.load(urllib.request.urlopen(req, timeout=120))
            return r["candidates"][0]["content"]["parts"][0]["text"]
        except urllib.error.HTTPError as e:
            if e.code in (429, 500, 503) and i < tries - 1:
                wait = min(90, 2 ** i * 5)
                print(f"    {e.code}; backoff {wait}s", flush=True)
                time.sleep(wait)
                continue
            raise


def build_prompt(lang, items):
    glossary = ", ".join(sorted(GLOSSARY))
    lines = json.dumps({k: v for k, v in items}, ensure_ascii=False, indent=1)
    return f"""You are a professional UI localizer for a Muslim Quran/Hadith/Dua \
memorization app. Translate the following interface strings from English to \
{lang}.

Rules:
- Return ONLY a JSON object mapping each key to its {lang} translation. Same keys, no extras.
- Keep every placeholder like {{count}}, {{name}}, {{error}} EXACTLY as-is (same braces, same name).
- Some values use ICU MessageFormat, e.g. "{{count, plural, one{{...}} other{{...}}}}". Preserve the \
ICU structure and placeholder names EXACTLY; translate only the human words inside the branches, and \
use the CORRECT plural categories for {lang} (Arabic uses zero/one/two/few/many/other; most others one/other).
- Do NOT translate these terms — keep them verbatim (transliterations/brand): {glossary}.
- Tone: reverent, neutral, and aqeedah-safe (Ahlus Sunnah). Concise, natural UI wording.
- Do not add commentary or code fences.

Strings:
{lines}"""


def valid(en_val, tr):
    if not isinstance(tr, str) or not tr.strip():
        return False
    # every placeholder in the source must survive
    for ph in set(PLACEHOLDER.findall(en_val)):
        if ph not in tr:
            return False
    # ICU messages must stay ICU-shaped
    if ICU.search(en_val):
        if not ICU.search(tr) or tr.count("{") != tr.count("}"):
            return False
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key-file", required=True)
    ap.add_argument("--locales", help="comma list (default: ship minus en/ar)")
    ap.add_argument("--model", default="gemini-2.5-flash")
    ap.add_argument("--batch", type=int, default=25)
    ap.add_argument("--limit", type=int, default=0)
    args = ap.parse_args()

    key = open(args.key_file, encoding="utf-8").read().strip()
    en = load(TEMPLATE)
    en_str = {k: v for k, v in en.items() if translatable(k, v)}
    locales = (args.locales.split(",") if args.locales
               else [l for l in SHIP_LOCALES if l not in FROZEN])

    for loc in locales:
        data = load(loc)
        todo = [k for k in en_str
                if data.get(k) is None or data.get(k) == en_str[k]]
        if args.limit:
            todo = todo[:args.limit]
        if not todo:
            print(f"[{loc}] nothing to do"); continue
        print(f"[{loc}] {LANG.get(loc, loc)}: {len(todo)} strings", flush=True)
        done = 0
        for i in range(0, len(todo), args.batch):
            keys = todo[i:i + args.batch]
            prompt = build_prompt(LANG[loc], [(k, en_str[k]) for k in keys])
            try:
                raw = gemini(key, args.model, prompt)
                out = json.loads(raw)
            except Exception as e:
                print(f"    batch failed ({type(e).__name__}) — skipping"); continue
            for k in keys:
                tr = out.get(k)
                if valid(en_str[k], tr):
                    data[k] = tr.strip()
                    done += 1
            save_arb(loc, data)  # checkpoint each batch
            print(f"  {min(i + args.batch, len(todo))}/{len(todo)}", flush=True)
        print(f"[{loc}] filled {done}/{len(todo)}")
    print("Done. Run `flutter gen-l10n` and `flutter analyze`, then review.")


if __name__ == "__main__":
    main()
