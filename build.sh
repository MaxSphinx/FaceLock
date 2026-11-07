#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

LOCK_DIR="/tmp/facelock_build.lock"
while ! mkdir "${LOCK_DIR}" 2>/dev/null; do
    sleep 0.5
done
trap 'rm -rf "${LOCK_DIR}"' EXIT

APP_NAME="FaceLock"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
TMP_BUNDLE="${BUILD_DIR}/${APP_NAME}_staging.$$"
TMP_CONTENTS="${TMP_BUNDLE}/Contents"
TMP_MACOS="${TMP_CONTENTS}/MacOS"
TMP_RESOURCES="${TMP_CONTENTS}/Resources"

echo "==> Building ${APP_NAME} for macOS (Apple Silicon arm64)..."

rm -rf "${TMP_BUNDLE}"
mkdir -p "${TMP_MACOS}"
mkdir -p "${TMP_RESOURCES}"

# Compile Swift sources into staging bundle
swiftc -O \
    -target arm64-apple-macos14.0 \
    -framework AppKit \
    -framework AVFoundation \
    -framework Vision \
    -framework LocalAuthentication \
    -framework CoreImage \
    -framework QuartzCore \
    -framework Accelerate \
    -framework IOKit \
    -framework CryptoKit \
    Sources/*.swift \
    Tests/*.swift \
    -o "${TMP_MACOS}/${APP_NAME}"

# Copy Info.plist and Resources into staging bundle
cp Resources/Info.plist "${TMP_CONTENTS}/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "${TMP_RESOURCES}/AppIcon.icns"
fi

# Code sign staging bundle ad-hoc
echo "==> Code-signing application bundle..."
codesign --force --deep --sign - "${TMP_BUNDLE}"

# Atomically replace target application bundle
rm -rf "${APP_BUNDLE}"
mv "${TMP_BUNDLE}" "${APP_BUNDLE}"

echo "==> Successfully built: ${APP_BUNDLE}"
echo "==> To run: open ${APP_BUNDLE}"
