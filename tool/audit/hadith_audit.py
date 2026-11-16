"""Read-only audit of the hadith editions Wird downloads.

Downloads ara/eng/urd/ben editions for each collection (cached in
tool/downloads/hadith_audit/), applies the same rules as
validateAndGroupHadith in lib/core/content/hadith_pack_repository.dart,
and writes docs/audit/evidence/hadith_audit.json + a markdown table.
Changes no app data. Usage: python -I tool/audit/hadith_audit.py
"""
import json, os, re, urllib.request
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CACHE = os.path.join(ROOT, 'tool', 'downloads', 'hadith_audit')
OUT = os.path.join(ROOT, 'docs', 'audit', 'evidence')
CDN = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions'
BOOKS = ['bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah', 'malik']
EXTRA = ['urd', 'ben']


def declared_counts():
    src = open(os.path.join(ROOT, 'lib', 'core', 'content', 'hadith_pack_repository.dart'),
               encoding='utf-8').read()
    block = src[src.index('hadithCollectionCounts'):]
    block = block[:block.index('};')]
    return {k: int(v) for k, v in re.findall(r"'(\w+)':\s*(\d+)", block)}


def fetch(ed):
    os.makedirs(CACHE, exist_ok=True)
    p = os.path.join(CACHE, ed + '.json')
    if not os.path.exists(p):
        try:
            with urllib.request.urlopen(f'{CDN}/{ed}.min.json', timeout=120) as r:
                data = r.read()
        except Exception as e:  # missing edition upstream
            return None, str(e)
        open(p, 'wb').write(data)
    return json.load(open(p, encoding='utf-8')), None


def audit(book, declared):
    ara, _ = fetch('ara-' + book)
    eng, _ = fetch('eng-' + book)
    a = {h['hadithnumber']: h for h in ara['hadiths']}
    e = {h['hadithnumber']: h for h in eng['hadiths']}
    r = {'book': book, 'declared': declared.get(book)}
    r['raw_ara'], r['raw_eng'] = len(ara['hadiths']), len(eng['hadiths'])
    r['dup_numbers_ara'] = [n for n, c in Counter(h['hadithnumber'] for h in ara['hadiths']).items() if c > 1][:20]
    r['dup_numbers_eng'] = [n for n, c in Counter(h['hadithnumber'] for h in eng['hadiths']).items() if c > 1][:20]
    r['only_in_ara'] = sorted(set(a) - set(e))[:20]
    r['only_in_eng'] = sorted(set(e) - set(a))[:20]
    both = sorted(set(a) & set(e))
    empty_both = [n for n in both if not a[n]['text'].strip() and not e[n]['text'].strip()]
    empty_ara_only = [n for n in both if not a[n]['text'].strip() and e[n]['text'].strip()]
    empty_eng_only = [n for n in both if a[n]['text'].strip() and not e[n]['text'].strip()]
    kept = [n for n in both if n not in set(empty_both)]
    r['kept'] = len(kept)
    r['kept_matches_declared'] = len(kept) == declared.get(book)
    r['empty_both'] = len(empty_both)
    r['empty_arabic_only'] = {'count': len(empty_ara_only), 'sample': empty_ara_only[:10]}
    r['empty_english_only'] = {'count': len(empty_eng_only), 'sample': empty_eng_only[:10]}
    ints = sorted({int(n) for n in kept})
    gaps = [i for i in range(ints[0], ints[-1] + 1) if i not in set(ints)]
    r['integer_gaps'] = {'count': len(gaps), 'sample': gaps[:15]}
    r['decimal_numbers'] = sum(1 for n in kept if n != int(n))
    # Same English text under two numbers (possible duplicate narration).
    texts = Counter(e[n]['text'].strip() for n in kept if len(e[n]['text'].strip()) > 80)
    r['repeated_english_texts'] = sum(c - 1 for c in texts.values() if c > 1)
    r['no_grade'] = sum(1 for n in kept if not e[n].get('grades'))
    # Chapter mapping as the app does it.
    md = eng['metadata']
    ranges = [(int(v['hadithnumber_first']), int(v['hadithnumber_last']), k)
              for k, v in md['section_details'].items()
              if not (v['hadithnumber_first'] == 0 and v['hadithnumber_last'] == 0)]
    def sec(n):
        for f, l, k in ranges:
            if f <= int(n) <= l:
                return k
        return None
    per = Counter(sec(n) for n in kept)
    r['uncategorized'] = per.pop(None, 0)
    r['sections_declared'] = len(md['sections'])
    r['sections_with_hadith'] = len(per)
    r['sections_empty_title'] = sum(1 for k in per if not (md['sections'].get(k) or '').strip())
    overlaps = 0
    rs = sorted(ranges)
    for (f1, l1, _), (f2, l2, _) in zip(rs, rs[1:]):
        if f2 <= l1:
            overlaps += 1
    r['overlapping_section_ranges'] = overlaps
    for lang in EXTRA:
        x, err = fetch(f'{lang}-{book}')
        if x is None:
            r[lang] = {'available': False, 'error': err[:80]}
            continue
        xn = {h['hadithnumber']: h for h in x['hadiths']}
        missing = [n for n in kept if not (xn.get(n, {}).get('text') or '').strip()]
        r[lang] = {'available': True, 'missing_for_kept': len(missing), 'sample': missing[:10]}
    return r


def main():
    declared = declared_counts()
    rows = [audit(b, declared) for b in BOOKS]
    os.makedirs(OUT, exist_ok=True)
    json.dump(rows, open(os.path.join(OUT, 'hadith_audit.json'), 'w', encoding='utf-8'),
              indent=1, ensure_ascii=False)
    hdr = ('| Book | Declared | Kept | Match | Empty both | Empty AR only | Empty EN only | '
           'Int gaps | Decimal | Repeated EN | No grade | Uncategorized | Overlaps | Urdu missing | Bengali missing |')
    lines = [hdr, '|' + '---|' * 15]
    for r in rows:
        lines.append('| ' + ' | '.join(str(x) for x in [
            r['book'], r['declared'], r['kept'], r['kept_matches_declared'], r['empty_both'],
            r['empty_arabic_only']['count'], r['empty_english_only']['count'],
            r['integer_gaps']['count'], r['decimal_numbers'], r['repeated_english_texts'],
            r['no_grade'], r['uncategorized'], r['overlapping_section_ranges'],
            r['urd'].get('missing_for_kept', 'n/a'), r['ben'].get('missing_for_kept', 'n/a')]) + ' |')
    open(os.path.join(OUT, 'hadith_audit.md'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
