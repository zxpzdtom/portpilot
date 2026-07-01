#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="${APP_DIR:-$ROOT_DIR/dist/PortPilot.app}"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Assets/PortPilot.icns" "$RESOURCES_DIR/PortPilot.icns"

swiftc \
  -parse-as-library \
  -target arm64-apple-macosx14.0 \
  -O \
  -framework SwiftUI \
  -framework AppKit \
  "$ROOT_DIR/Sources/PortPilot/main.swift" \
  -o "$MACOS_DIR/PortPilot"

chmod +x "$MACOS_DIR/PortPilot"
codesign --force --deep --sign - "$APP_DIR" >/dev/null
echo "$APP_DIR"
