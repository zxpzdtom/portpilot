#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SPARKLE_VERSION="${SPARKLE_VERSION:-2.9.3}"
SPARKLE_CACHE_DIR="$ROOT_DIR/.build/sparkle-$SPARKLE_VERSION"
SPARKLE_ARCHIVE="$ROOT_DIR/.build/Sparkle-$SPARKLE_VERSION.tar.xz"
SPARKLE_URL="https://github.com/sparkle-project/Sparkle/releases/download/$SPARKLE_VERSION/Sparkle-$SPARKLE_VERSION.tar.xz"
RELEASE_DIR="${1:-$ROOT_DIR/dist/releases}"
APP_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT_DIR/Info.plist")"
RELEASE_TAG="${RELEASE_TAG:-v$APP_VERSION}"

mkdir -p "$SPARKLE_CACHE_DIR" "$ROOT_DIR/.build"

if [ ! -x "$SPARKLE_CACHE_DIR/bin/generate_appcast" ]; then
  if [ ! -f "$SPARKLE_ARCHIVE" ]; then
    curl -L "$SPARKLE_URL" -o "$SPARKLE_ARCHIVE"
  fi
  tar -xf "$SPARKLE_ARCHIVE" -C "$SPARKLE_CACHE_DIR" bin/generate_appcast bin/sign_update bin/generate_keys
fi

"$SPARKLE_CACHE_DIR/bin/generate_appcast" "$RELEASE_DIR" \
  --download-url-prefix "https://github.com/zxpzdtom/portpilot/releases/download/$RELEASE_TAG/" \
  --link "https://github.com/zxpzdtom/portpilot/releases/tag/$RELEASE_TAG" \
  -o "$ROOT_DIR/appcast.xml"
