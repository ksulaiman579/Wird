#!/usr/bin/env python3
"""Audit REAL translation coverage of the ARB files (Item 5.x).

`audit_arbs.py` only checks key PARITY — it passes even when a value is just
the English string copied over (a fallback). This script measures how much is
actually translated: for each app_<lang>.arb it counts keys whose value is
byte-identical to app_en.arb (⇒ almost certainly untranslated).

A small allowlist of keys that are EXPECTED to equal English (brand name,
pure-placeholder strings) is excluded so they don't count as failures.

Usage:  python tool/audit_translations.py [path-to-l10n-dir]
Exit 1 if any non-English locale is <100% translated (minus allowlist).
"""
import json
import os
import re
import sys

# Keys whose value may legitimately match English (proper nouns / Islamic
# terms conventionally transliterated the same across many languages, and
# pure-placeholder strings). Not counted as untranslated.
ALLOW_IDENTICAL = {
    "appTitle",            # "Wird" — proper noun
    "achievementProgress", # "{current} / {target}" — pure placeholders
    "navAlManhaj", "alManhajTitle",  # "Al-Manhaj" — brand/proper noun
    "qiblaTitle",          # "Qibla"
    "tasbihTitle",         # "Tasbih"
    "navDuas", "duasTitle",  # "Duas"
    "navHadith",           # "Hadith"
    "todayGreeting",       # "Assalamu alaikum" — transliterated greeting
    # Loanwords that many languages legitimately keep as-is:
    "sessionTitle", "downloadsTitle", "settingsBackup", "navHome",
    "commonStart", "navQuran", "quranTitle", "exploreSectionDuasAdhkar",
}

L10N = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lib", "l10n")


def load_values(path):
    d = json.load(open(path, encoding="utf-8"))
    # Keep only real message keys (skip @-metadata and @@locale).
    return {k: v for k, v in d.items()
            if not k.startswith("@") and isinstance(v, str)}


def main():
    en_path = os.path.join(L10N, "app_en.arb")
    if not os.path.isfile(en_path):
        print(f"No app_en.arb in {L10N}")
        return 2
    en = load_values(en_path)
    total = len(en)
    print(f"English template: {total} message keys\n")

    arbs = sorted(f for f in os.listdir(L10N)
                  if re.fullmatch(r"app_[A-Za-z_]+\.arb", f) and f != "app_en.arb")
    worst = []
    for f in arbs:
        lang = f[len("app_"):-len(".arb")]
        v = load_values(os.path.join(L10N, f))
        identical = [k for k in en
                     if k not in ALLOW_IDENTICAL and v.get(k) == en[k]]
        missing = [k for k in en if k not in v]
        translated = total - len(identical) - len(missing)
        pct = round(100 * translated / total) if total else 0
        worst.append((pct, lang, len(identical), len(missing)))

    worst.sort()
    print(f"{'lang':<6}{'translated%':>12}{'englishFallback':>18}{'missing':>9}")
    print("-" * 45)
    for pct, lang, ident, miss in worst:
        flag = "" if pct == 100 else "  <-- INCOMPLETE"
        print(f"{lang:<6}{pct:>11}%{ident:>18}{miss:>9}{flag}")

    incomplete = [w for w in worst if w[0] < 100]
    print("\n" + "=" * 45)
    print(f"{len(arbs) - len(incomplete)}/{len(arbs)} locales fully translated; "
          f"{len(incomplete)} incomplete.")
    return 1 if incomplete else 0


if __name__ == "__main__":
    sys.exit(main())
