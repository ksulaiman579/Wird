"""Write update.json for a release, with the sha256 of every APK.

The app refuses an update whose manifest has no checksum (audit WQA-022),
so always build the manifest with this instead of by hand.

Usage (after `flutter build apk --release --split-per-abi`):
    python tool/make_update_json.py --notes "What changed" [--out update.json]

Reads versionName/versionCode from pubspec.yaml and the APKs from
build/app/outputs/flutter-apk/. Upload update.json and the APKs (named
wird-<abi>.apk, plus wird.apk = the arm64 build) to the GitHub release.
"""
import argparse, hashlib, json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APKS = os.path.join(ROOT, 'build', 'app', 'outputs', 'flutter-apk')
BASE = 'https://github.com/ksulaiman579/Wird/releases/latest/download'
ABIS = ['arm64-v8a', 'armeabi-v7a', 'x86_64']


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--notes', required=True)
    ap.add_argument('--out', default=os.path.join(ROOT, 'update.json'))
    a = ap.parse_args()
    pub = open(os.path.join(ROOT, 'pubspec.yaml'), encoding='utf-8').read()
    name, code = re.search(r'^version:\s*([\d.]+)\+(\d+)', pub, re.M).groups()
    abis = {}
    for abi in ABIS:
        p = os.path.join(APKS, f'app-{abi}-release.apk')
        if not os.path.exists(p):
            raise SystemExit(f'missing {p} - build with --split-per-abi first')
        abis[abi] = {'url': f'{BASE}/wird-{abi}.apk', 'sha256': sha256(p)}
    manifest = {
        'versionCode': int(code),
        'versionName': name,
        'notes': a.notes,
        # wird.apk is the arm64 build, for devices whose ABI isn't matched.
        'apkUrl': f'{BASE}/wird.apk',
        'sha256': abis['arm64-v8a']['sha256'],
        'apks': abis,
    }
    json.dump(manifest, open(a.out, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
    print(f'wrote {a.out} for {name}+{code}')


if __name__ == '__main__':
    main()
