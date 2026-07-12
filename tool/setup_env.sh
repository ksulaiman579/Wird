#!/usr/bin/env bash
# Idempotent environment setup for the Daily app.
# Installs Flutter SDK to /opt/flutter if missing, then runs flutter pub get.
set -euo pipefail

FLUTTER_DIR="/opt/flutter"
FLUTTER_CHANNEL="stable"

if [ -x "${FLUTTER_DIR}/bin/flutter" ]; then
  echo "Flutter already installed at ${FLUTTER_DIR}"
else
  echo "Cloning Flutter (${FLUTTER_CHANNEL}) into ${FLUTTER_DIR}..."
  if [ -n "${CURL_CA_BUNDLE:-}" ]; then
    export GIT_SSL_CAINFO="${CURL_CA_BUNDLE}"
  fi
  git clone --depth 1 -b "${FLUTTER_CHANNEL}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${FLUTTER_DIR}/bin/cache/dart-sdk/bin:${PATH}"

flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version

if [ -f "$(dirname "$0")/../pubspec.yaml" ]; then
  echo "Running flutter pub get..."
  (cd "$(dirname "$0")/.." && flutter pub get)
else
  echo "No pubspec.yaml yet — skipping pub get (run again after 'flutter create')."
fi

echo
echo "Add this to your shell for the rest of the session:"
echo "  export PATH=\"${FLUTTER_DIR}/bin:${FLUTTER_DIR}/bin/cache/dart-sdk/bin:\$PATH\""
