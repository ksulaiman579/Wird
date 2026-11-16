"""Compare a sample of the app's hadith (fawazahmed0 hadith-api) with
sunnah.com. Input: docs/audit/evidence/sunnah_sample_raw.json, collected in
a browser from sunnah.com/<book>:<n> pages (sunnah.com blocks scripts).
Checks per hadith: Arabic opening words, book number, grade.
Writes docs/audit/evidence/hadith_sample.md. Read-only.
"""
import json, os, re, sys, unicodedata
sys.stdout.reconfigure(encoding='utf-8')
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EV = os.path.join(ROOT, 'docs', 'audit', 'evidence')
C = os.path.join(ROOT, 'tool', 'downloads', 'hadith_audit')


def bare(s):
    s = ''.join(c for c in unicodedata.normalize('NFKD', s or '') if unicodedata.category(c) in ('Lo', 'Zs'))
    s = s.translate(str.maketrans('أإآٱىة', 'اااايه'))
    return ' '.join(s.split())


def words(s, k=6):
    return ' '.join(bare(s).split()[:k])


def section_for(md, n):
    for k, v in md['section_details'].items():
        f, l = int(v['hadithnumber_first']), int(v['hadithnumber_last'])
        if (f or l) and f <= int(n) <= l:
            return k
    return None


def grade_word(gs):
    t = ' '.join(g.get('grade', '') for g in gs).lower()
    for w in ('sahih', 'hasan', 'daif', "da'if", 'maudu', 'mawdu'):
        if w in t.replace('ḍ', 'd').replace('ʿ', "'"):
            return w
    return t[:30] or '-'


def main():
    raw = json.load(open(os.path.join(EV, 'sunnah_sample_raw.json'), encoding='utf-8'))
    cache = {}
    rows, tally = [], {}
    for r in raw:
        b, n = r['b'], r['n']
        if b not in cache:
            ara = json.load(open(os.path.join(C, f'ara-{b}.json'), encoding='utf-8'))
            eng = json.load(open(os.path.join(C, f'eng-{b}.json'), encoding='utf-8'))
            cache[b] = ({h['hadithnumber']: h for h in ara['hadiths']},
                        {h['hadithnumber']: h for h in eng['hadiths']}, eng['metadata'])
        A, E, md = cache[b]
        app_ar = A.get(n, {}).get('text', '')
        sec = section_for(md, n)
        m = re.search(r'In-book reference\s*:\s*Book (\d+)', r.get('ref') or '')
        sn_book = m.group(1) if m else ('0' if 'Introduction' in (r.get('ref') or '') else None)
        if not r.get('ar'):
            verdict = 'unverified (page not found)'
        elif words(app_ar) == words(r['ar']):
            verdict = 'match'
        elif words(app_ar, 3) == words(r['ar'], 3):
            verdict = 'match (opening differs slightly)'
        else:
            verdict = 'numbering difference'
        book_ok = sn_book is None or sec is None or str(sec) == sn_book
        app_g = grade_word(E.get(n, {}).get('grades', []))
        sn_g = (r.get('grade') or '-').lower()
        rows.append((b, n, verdict, sec, sn_book, book_ok, app_g, sn_g[:40]))
        key = (b, verdict)
        tally[key] = tally.get(key, 0) + 1
    out = ['| Book | No. | Arabic | App book | sunnah.com book | Book same | App grade | sunnah.com grade |',
           '|---|---|---|---|---|---|---|---|']
    out += ['| ' + ' | '.join(str(x) for x in row) + ' |' for row in rows]
    out.append('')
    out.append('Tally: ' + ', '.join(f'{b} {v}: {c}' for (b, v), c in sorted(tally.items())))
    open(os.path.join(EV, 'hadith_sample.md'), 'w', encoding='utf-8').write('\n'.join(out) + '\n')
    print(out[-1])
    for row in rows:
        if row[2] != 'match' or not row[5]:
            print(row)


if __name__ == '__main__':
    main()
