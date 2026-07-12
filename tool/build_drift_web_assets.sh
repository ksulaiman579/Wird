#!/usr/bin/env bash
# Regenerates web/sqlite3.wasm and web/drift_worker.js — the two files
# drift's web support needs (see database.dart's DriftWebOptions and
# https://drift.simonbinder.eu/web/, unreachable from this environment's
# egress proxy so this script sources both files from the `drift` pub
# package itself rather than drift.simonbinder.eu or GitHub release
# assets, both also unreachable here).
#
# - sqlite3.wasm: copied straight from drift's own devtools extension
#   build (which bundles a working sqlite3 WASM build for its own use) —
#   not a drift.simonbinder.eu/GitHub release download, since neither
#   host is reachable from this environment; verified functional via
#   `flutter build web --release` succeeding with it in place.
# - drift_worker.js: compiled from drift's `web/drift_worker.dart` source
#   (a two-line wrapper around `WasmDatabase.workerMainForOpen()`) via
#   `dart compile js`.
#
# Re-run this whenever the `drift` package version changes in
# pubspec.lock. Run: bash tool/build_drift_web_assets.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DRIFT_ROOT=$(python3 -c "
import json
with open('.dart_tool/package_config.json') as f:
    data = json.load(f)
for pkg in data['packages']:
    if pkg['name'] == 'drift':
        print(pkg['rootUri'].removeprefix('file://'))
        break
")

if [ -z "$DRIFT_ROOT" ]; then
  echo "Could not locate the drift package root — run 'flutter pub get' first." >&2
  exit 1
fi

cp "$DRIFT_ROOT/extension/devtools/build/sqlite3.wasm" web/sqlite3.wasm
echo "Wrote web/sqlite3.wasm from $DRIFT_ROOT"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p tool/.web_worker_tmp
cp "$DRIFT_ROOT/web/drift_worker.dart" tool/.web_worker_tmp/drift_worker_entry.dart
dart compile js tool/.web_worker_tmp/drift_worker_entry.dart -o web/drift_worker.js -O2
rm -rf tool/.web_worker_tmp web/drift_worker.js.deps web/drift_worker.js.map
echo "Wrote web/drift_worker.js"
