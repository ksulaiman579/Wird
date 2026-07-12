#!/usr/bin/env bash
# Vercel has no native Flutter build image, so this downloads the pinned
# Flutter SDK itself before building. Runs as vercel.json's `buildCommand`.
#
# Pin this to whatever `flutter --version` reports for local development
# (see .metadata's `channel` + this repo's CLAUDE.md) so Vercel builds with
# the exact same SDK version every other verification in this repo used.
set -euo pipefail

FLUTTER_VERSION="3.44.4"
FLUTTER_CHANNEL="stable"
FLUTTER_SDK_DIR="$HOME/flutter-sdk"

if [ ! -d "$FLUTTER_SDK_DIR" ]; then
  echo "Downloading Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL)..."
  curl -fsSL -o /tmp/flutter.tar.xz \
    "https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
  mkdir -p "$FLUTTER_SDK_DIR"
  tar -xJf /tmp/flutter.tar.xz -C "$FLUTTER_SDK_DIR" --strip-components=1
  rm /tmp/flutter.tar.xz
fi

export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

# Vercel runs the build as root while the SDK was unpacked under a different
# owner; Flutter shells out to `git` on its own SDK directory, which aborts
# with "detected dubious ownership" (exit 128). Mark the build dirs safe.
git config --global --add safe.directory '*'

flutter --version
flutter config --no-analytics
flutter pub get

# Cloud backup is enabled only if these are set as Vercel Environment
# Variables (Project → Settings → Environment Variables). The publishable
# key is public/safe to ship in web JS; without them the PWA builds fully
# offline (cloud feature hidden). The SECRET key must never be set here.
DEFINES=()
if [ -n "${WIRD_SUPABASE_URL:-}" ] && [ -n "${WIRD_SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  echo "Cloud backup: ENABLED (Supabase env vars present)"
  DEFINES+=(--dart-define=WIRD_SUPABASE_URL="$WIRD_SUPABASE_URL")
  DEFINES+=(--dart-define=WIRD_SUPABASE_PUBLISHABLE_KEY="$WIRD_SUPABASE_PUBLISHABLE_KEY")
else
  echo "Cloud backup: disabled (no Supabase env vars)"
fi

flutter build web --release ${DEFINES[@]+"${DEFINES[@]}"}
