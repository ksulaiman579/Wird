#!/usr/bin/env python3
"""Apply a batch of new UI-chrome keys to every ARB at once (Item C).

Hand-editing 63 app_<lang>.arb files per string batch is the bottleneck in
the localization sweep. This tool takes ONE batch file describing the new
keys — their English text, optional description, ICU placeholders, and any
per-language translations — and:

  1. Adds each key (+ @-metadata with description & placeholders) to the
     English master app_en.arb.
  2. Writes the key into every app_<lang>.arb, using the supplied
     translation for that language or falling back to the English value
     (so the app stays compilable and key-parity stays green immediately;
     un-translated locales simply read English until filled in a later
     batch — same graceful behaviour gen_l10n already gives).

Stable key ordering is preserved (English master keeps insertion order with
@-metadata paired after each key; locale files are written sorted).

Usage:
    python tool/apply_l10n_batch.py tool/l10n_batches/<batch>.json

Batch file schema:
{
  "keys": {
    "todayGoalTitle": {
      "en": "Today's goal",
      "desc": "Heading of the Today hero card.",
      "placeholders": {"count": {}},         # optional, ICU {count}
      "t": {"ar": "هدف اليوم", "fr": "Objectif du jour", ...}
    },
    ...
  }
}
"""
import glob
import json
import os
import sys

L10N = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lib", "l10n"
)


def _load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def _write(path, data):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def _locale_of(path):
    base = os.path.basename(path)
    return base[len("app_"):-len(".arb")]


def apply_batch(batch_path):
    batch = _load(batch_path)
    keys = batch["keys"]

    # 1. English master — append key + @-metadata (description + placeholders).
    en_path = os.path.join(L10N, "app_en.arb")
    en = _load(en_path)
    added = 0
    for key, spec in keys.items():
        if key not in en:
            added += 1
        en[key] = spec["en"]
        meta = {}
        if spec.get("desc"):
            meta["description"] = spec["desc"]
        if spec.get("placeholders"):
            meta["placeholders"] = spec["placeholders"]
        if meta:
            en["@" + key] = meta
    _write(en_path, en)

    # 2. Every locale file — translation or English fallback.
    for path in sorted(glob.glob(os.path.join(L10N, "app_*.arb"))):
        loc = _locale_of(path)
        if loc == "en":
            continue
        data = _load(path)
        for key, spec in keys.items():
            t = spec.get("t", {})
            data[key] = t.get(loc, spec["en"])
        # sorted, but keep @@locale first
        locale_val = data.get("@@locale", loc)
        body = {k: v for k, v in data.items() if k != "@@locale"}
        ordered = {"@@locale": locale_val}
        for k in sorted(body):
            ordered[k] = body[k]
        _write(path, ordered)

    n_langs = len(glob.glob(os.path.join(L10N, "app_*.arb")))
    print(f"Applied {len(keys)} keys ({added} new) across {n_langs} locales.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)
    apply_batch(sys.argv[1])
