#!/usr/bin/env python3
"""Builds assets/data/hadith_nawawi_tr.json: extra-language translations
of the 40 Nawawi (id -> {lang: text}) from fawazahmed0/hadith-api
(Unlicense). Only languages the app ships and the source has: Bengali.
Each text includes the narrator line, as in the source. Validates that all
42 ids are present and non-empty.

Usage: python tool/build_nawawi_translations.py
"""
import json
import urllib.request

CDN = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions'
LANGS = {'bn': 'ben'}

out = {}
for lang, prefix in LANGS.items():
    with urllib.request.urlopen(f'{CDN}/{prefix}-nawawi.min.json', timeout=60) as r:
        data = json.load(r)
    hadiths = {h['hadithnumber']: h['text'].strip() for h in data['hadiths']}
    assert sorted(hadiths) == list(range(1, 43)), f'{lang}: ids'
    assert all(hadiths.values()), f'{lang}: empty text'
    for n, t in hadiths.items():
        out.setdefault(str(n), {})[lang] = t

with open('assets/data/hadith_nawawi_tr.json', 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, separators=(',', ':'))
print('ok', len(out), 'hadith,', list(LANGS))
