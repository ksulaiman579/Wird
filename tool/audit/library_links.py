"""Read-only HEAD check of every Knowledge Library link. Writes
docs/audit/evidence/library_links.json. Usage: python -I tool/audit/library_links.py"""
import json, os, urllib.request
from concurrent.futures import ThreadPoolExecutor
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
d = json.load(open(os.path.join(ROOT, 'assets', 'data', 'knowledge_library.json'), encoding='utf-8'))

def head(x):
    try:
        req = urllib.request.Request(x['url'], method='HEAD', headers={'User-Agent': 'wird-audit'})
        with urllib.request.urlopen(req, timeout=40) as r:
            size = int(r.headers.get('Content-Length') or 0)
            return {'id': x['id'], 'status': r.status, 'size': size, 'size_ok': abs(size - x['sizeBytes']) < 1024,
                    'type': r.headers.get('Content-Type')}
    except Exception as e:
        return {'id': x['id'], 'status': getattr(e, 'code', None), 'error': str(e)[:100]}

with ThreadPoolExecutor(6) as ex:
    res = list(ex.map(head, d))
json.dump(res, open(os.path.join(ROOT, 'docs', 'audit', 'evidence', 'library_links.json'), 'w'), indent=0)
bad = [r for r in res if r.get('status') != 200]
print('total', len(res), 'not200', len(bad), 'size mismatch', sum(1 for r in res if r.get('status') == 200 and not r['size_ok']))
