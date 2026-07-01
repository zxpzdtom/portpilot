#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${APP_DIR:-$ROOT_DIR/dist/PortPilot.app}"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"
SOURCE_DIR="$ROOT_DIR/Sources/PortPilot"
SPARKLE_VERSION="${SPARKLE_VERSION:-2.9.3}"
SPARKLE_CACHE_DIR="$ROOT_DIR/.build/sparkle-$SPARKLE_VERSION"
SPARKLE_ARCHIVE="$ROOT_DIR/.build/Sparkle-$SPARKLE_VERSION.tar.xz"
SPARKLE_FRAMEWORK="$SPARKLE_CACHE_DIR/Sparkle.framework"
SPARKLE_URL="https://github.com/sparkle-project/Sparkle/releases/download/$SPARKLE_VERSION/Sparkle-$SPARKLE_VERSION.tar.xz"

if [ ! -d "$SPARKLE_FRAMEWORK" ]; then
  mkdir -p "$SPARKLE_CACHE_DIR" "$ROOT_DIR/.build"
  if [ ! -f "$SPARKLE_ARCHIVE" ]; then
    curl -L "$SPARKLE_URL" -o "$SPARKLE_ARCHIVE"
  fi
  tar -xf "$SPARKLE_ARCHIVE" -C "$SPARKLE_CACHE_DIR" Sparkle.framework bin/generate_appcast bin/sign_update bin/generate_keys
fi

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$FRAMEWORKS_DIR"

cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Assets/PortPilot.icns" "$RESOURCES_DIR/PortPilot.icns"
cp -R "$SPARKLE_FRAMEWORK" "$FRAMEWORKS_DIR/Sparkle.framework"

SWIFT_SOURCES=()
while IFS= read -r source_file; do
  SWIFT_SOURCES+=("$source_file")
done < <(find "$SOURCE_DIR" -name '*.swift' -print | sort)

swiftc \
  -parse-as-library \
  -target arm64-apple-macosx14.0 \
  -O \
  -F "$FRAMEWORKS_DIR" \
  -framework SwiftUI \
  -framework AppKit \
  -framework Sparkle \
  -Xlinker -rpath \
  -Xlinker @executable_path/../Frameworks \
  "${SWIFT_SOURCES[@]}" \
  -o "$MACOS_DIR/PortPilot"

chmod +x "$MACOS_DIR/PortPilot"
codesign --force --deep --sign - "$FRAMEWORKS_DIR/Sparkle.framework" >/dev/null
codesign --force --deep --sign - "$APP_DIR" >/dev/null
echo "$APP_DIR"
