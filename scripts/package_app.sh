#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/.build/release"
APP_NAME="statusbar_cat"
APP_DIR="${ROOT_DIR}/build/${APP_NAME}.app"

pushd "${ROOT_DIR}" >/dev/null
swift build -c release
popd >/dev/null

mkdir -p "${APP_DIR}/Contents/MacOS" "${APP_DIR}/Contents/Resources"
cp "${BUILD_DIR}/ayabar" "${APP_DIR}/Contents/MacOS/${APP_NAME}"

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>statusbar_cat</string>
  <key>CFBundleDisplayName</key>
  <string>statusbar_cat</string>
  <key>CFBundleExecutable</key>
  <string>statusbar_cat</string>
  <key>CFBundleIdentifier</key>
  <string>dev.statusbarcat.app</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
PLIST

echo "Packaged: ${APP_DIR}"
