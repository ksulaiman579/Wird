#!/usr/bin/env python3
"""Build assets/data/cities.json — the manual city picker's data (M5.2).

Replaces `geolocator` (banned on F-Droid: its Android build links
`play-services-location`) with a bundled, searchable list of cities the
user picks from, so prayer-time location needs no runtime permission at
all. One capital city per sovereign state/territory, ~250 entries total —
comfortably "a few hundred major world cities" per the plan.

Source: dr5hn/countries-states-cities-database (ODbL — see the printed
attribution notice and DATA_SOURCES.md). Coordinates are the country's
listed capital city; a handful of countries whose capital name doesn't
exactly match any city entry in the database are skipped and logged
rather than guessed.

Run: python3 tool/build_cities_asset.py
"""
from __future__ import annotations

import json
import unicodedata
import urllib.request
from pathlib import Path

# A handful of countries whose `capital` field uses a different name (or
# language) than the matching city entry uses — everything else is matched
# by normalized name, so this stays a short, manually-verified list rather
# than a broad fuzzy-matching pass that could silently pick the wrong city.
CAPITAL_ALIASES = {
    "Mexico": "Mexico City",
    "Singapore": "Singapore",
    "Cocos (Keeling) Islands": "West Island",
    "Hong Kong S.A.R.": "Hong Kong",
    "Macau S.A.R.": "Macau",
    "Kazakhstan": "Nur-Sultan",
    "Libya": "Tripoli",
    "Man (Isle of)": "Douglas",
    "Ivory Coast": "Yamoussoukro",
    "Indonesia": "Jakarta Pusat",  # Central Jakarta — the city's admin/political core
}


def _normalize(name: str) -> str:
    stripped = unicodedata.normalize("NFKD", name)
    return "".join(c for c in stripped if not unicodedata.combining(c)).strip().lower()

REPO_ROOT = Path(__file__).resolve().parent.parent
DOWNLOADS = REPO_ROOT / "tool" / "downloads" / "cities"
OUT_PATH = REPO_ROOT / "assets" / "data" / "cities.json"

# Pinned to a commit for reproducibility (see DATA_SOURCES.md).
_SHA = "7d23ecbf6268bd72765266c45a83d3f4f9e8173c"
_BASE = f"https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/{_SHA}/json"
COUNTRIES_URL = f"{_BASE}/countries.json"
COUNTRIES_STATES_CITIES_URL = f"{_BASE}/countries+states+cities.json"

COUNTRIES_FILE = DOWNLOADS / "countries.json"
COUNTRIES_STATES_CITIES_FILE = DOWNLOADS / "countries+states+cities.json"


def ensure_sources() -> None:
    DOWNLOADS.mkdir(parents=True, exist_ok=True)
    for path, url in (
        (COUNTRIES_FILE, COUNTRIES_URL),
        (COUNTRIES_STATES_CITIES_FILE, COUNTRIES_STATES_CITIES_URL),
    ):
        if path.exists():
            continue
        print(f"Fetching {url} -> {path} ...")
        urllib.request.urlretrieve(url, path)


def build() -> list[dict]:
    with COUNTRIES_FILE.open(encoding="utf-8") as f:
        countries = json.load(f)
    with COUNTRIES_STATES_CITIES_FILE.open(encoding="utf-8") as f:
        countries_with_cities = json.load(f)

    cities_by_country_id = {c["id"]: c for c in countries_with_cities}

    result = []
    skipped = []
    for country in countries:
        display_name = country.get("capital")
        if not display_name:
            skipped.append(country["name"])
            continue
        search_name = CAPITAL_ALIASES.get(country["name"], display_name)

        detail = cities_by_country_id.get(country["id"])
        all_cities = [
            city
            for state in (detail.get("states", []) if detail else [])
            for city in state.get("cities", [])
        ]

        target = _normalize(search_name)
        match = next(
            (c for c in all_cities if _normalize(c["name"]) == target), None
        )
        if match is None:
            # Fall back to a prefix match (e.g. capital "Bogotá" vs the
            # city entry "Bogotá D.C.") — only when unambiguous.
            candidates = [
                c for c in all_cities if _normalize(c["name"]).startswith(target)
            ]
            if len(candidates) == 1:
                match = candidates[0]

        if match is None:
            skipped.append(f"{country['name']} (capital: {display_name})")
            continue

        result.append({
            "name": display_name,
            "country": country["name"],
            "countryCode": country["iso2"],
            "lat": float(match["latitude"]),
            "lng": float(match["longitude"]),
        })

    result.sort(key=lambda c: c["name"])

    if skipped:
        print(f"Skipped {len(skipped)} countries (capital not found as a city entry):")
        for s in skipped:
            print(f"  - {s}")

    return result


def validate(cities: list[dict]) -> None:
    assert len(cities) >= 150, f"expected at least 150 cities, got {len(cities)}"
    seen = set()
    for c in cities:
        key = (c["name"], c["country"])
        assert key not in seen, f"duplicate city entry: {key}"
        seen.add(key)
        assert -90 <= c["lat"] <= 90, f"invalid latitude for {c['name']}: {c['lat']}"
        assert -180 <= c["lng"] <= 180, f"invalid longitude for {c['name']}: {c['lng']}"
        assert c["name"] and c["country"] and c["countryCode"], f"empty field in {c}"


def main() -> None:
    ensure_sources()
    cities = build()
    validate(cities)
    OUT_PATH.write_text(json.dumps(cities, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(cities)} cities to {OUT_PATH}")


if __name__ == "__main__":
    main()
