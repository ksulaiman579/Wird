#!/usr/bin/env python3
"""Audit all ARB files against the English master for:
   1. Valid JSON
   2. Missing keys
   3. Extra keys
   4. Missing ICU placeholders ({current}, {total}, {target}, {date})
"""
import json, os, sys, glob

L10N = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "lib", "l10n")

# Load English master
with open(os.path.join(L10N, "app_en.arb"), encoding="utf-8") as f:
    en = json.load(f)

# Extract string keys (skip @@locale and @-metadata)
en_keys = sorted(k for k in en if not k.startswith("@"))

# Placeholder patterns per key
PLACEHOLDERS = {
    "progressStepOf": ["{current}", "{total}"],
    "achievementProgress": ["{current}", "{target}"],
    "backupLastAuto": ["{date}"],
}

errors = []
arb_files = sorted(glob.glob(os.path.join(L10N, "app_*.arb")))
print(f"Found {len(arb_files)} ARB files to audit.\n")

for path in arb_files:
    fname = os.path.basename(path)
    if fname == "app_en.arb":
        continue  # skip master

    # 1. JSON validity
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"  {fname}: INVALID JSON — {e}")
        continue

    locale = data.get("@@locale", "???")
    keys = sorted(k for k in data if not k.startswith("@"))

    # 2. Missing keys
    missing = set(en_keys) - set(keys)
    if missing:
        errors.append(f"  {fname} ({locale}): MISSING keys: {sorted(missing)}")

    # 3. Extra keys (not in English)
    extra = set(keys) - set(en_keys)
    if extra:
        errors.append(f"  {fname} ({locale}): EXTRA keys: {sorted(extra)}")

    # 4. Placeholder checks
    for key, placeholders in PLACEHOLDERS.items():
        if key in data:
            for ph in placeholders:
                if ph not in data[key]:
                    errors.append(f"  {fname} ({locale}): key '{key}' is MISSING placeholder {ph}: \"{data[key]}\"")

    # 5. Empty strings
    for key in en_keys:
        if key in data and isinstance(data[key], str) and data[key].strip() == "":
            errors.append(f"  {fname} ({locale}): key '{key}' is EMPTY")

if errors:
    print(f"ERRORS FOUND ({len(errors)}):\n")
    for e in errors:
        print(e)
    sys.exit(1)
else:
    print("All ARB files pass validation. No missing keys, placeholders, or JSON errors.")
    sys.exit(0)
