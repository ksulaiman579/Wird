"""Read-only check of the bundled Quran (assets/data/quran).

Structure: 114 surahs, 6,236 ayahs, juz 1..30 in order, no empty fields.
Text: compares each ayah's bare letters (marks removed, letter variants
folded) against an independent edition (quran-api ara-quransimple, Tanzil
simple). Writes docs/audit/evidence/quran_audit.json.
Usage: python -I tool/audit/quran_audit.py  (after downloading the edition
to tool/downloads/quran_audit/)
"""
import json, os, re, sys, unicodedata
sys.stdout.reconfigure(encoding='utf-8')
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
Q = os.path.join(ROOT, 'assets', 'data', 'quran')
REF = os.path.join(ROOT, 'tool', 'downloads', 'quran_audit', 'ara-quransimple.json')

FOLD = str.maketrans({'ٱ': 'ا', 'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ى': 'ي', 'ئ': 'ي', 'ؤ': 'و',
                      'ة': 'ه', 'ۥ': '', 'ۦ': '', 'ء': '', 'ـ': ''})


def bare(s):
    s = ''.join(c for c in unicodedata.normalize('NFKD', s) if unicodedata.category(c) == 'Lo')
    s = s.translate(FOLD)
    s = re.sub('[اويه]', '', s)  # drop long vowels/ha: spelling differs by script
    return "".join(c for i, c in enumerate(s) if i == 0 or c != s[i - 1])  # Uthmani writes one lam in al-layl


BASMALA = bare('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ')


def main():
    ref = {}
    for v in json.load(open(REF, encoding='utf-8'))['quran']:
        ref[(v['chapter'], v['verse'])] = v['text']
    res = {'surahs': 0, 'ayahs': 0, 'empty': [], 'juz_order_errors': [], 'mismatch': []}
    last_juz = 1
    for s in range(1, 115):
        d = json.load(open(os.path.join(Q, f'surah_{s:03d}.json'), encoding='utf-8'))
        res['surahs'] += 1
        for a in d['ayahs']:
            res['ayahs'] += 1
            for k in ('arabic', 'translation', 'transliteration'):
                if not (a.get(k) or '').strip():
                    res['empty'].append(f"{s}:{a['ayah']} {k}")
            if a['juz'] < last_juz or a['juz'] > last_juz + 1:
                res['juz_order_errors'].append(f"{s}:{a['ayah']}")
            last_juz = a['juz']
            r = ref.get((s, a['ayah']))
            other = bare(r) if r else None
            if other and a['ayah'] == 1 and s not in (1, 9) and other.startswith(BASMALA):
                other = other[len(BASMALA):]  # simple edition prefixes the basmala
            if other is None or other != bare(a['arabic']):
                res['mismatch'].append({'ref': f"{s}:{a['ayah']}", 'app': a['arabic'][:80],
                                        'other': (r or '')[:80]})
    res['last_juz'] = last_juz
    json.dump(res, open(os.path.join(ROOT, 'docs', 'audit', 'evidence', 'quran_audit.json'), 'w',
                        encoding='utf-8'), ensure_ascii=False, indent=1)
    print('surahs', res['surahs'], 'ayahs', res['ayahs'], 'last juz', last_juz,
          'empty', len(res['empty']), 'juz errors', len(res['juz_order_errors']),
          'text mismatches', len(res['mismatch']))
    for m in res['mismatch'][:8]:
        print(m)


if __name__ == '__main__':
    main()
