#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="FaceLock"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "==> Building ${APP_NAME} for macOS (Apple Silicon arm64)..."

rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Compile Swift sources
swiftc -O \
    -target arm64-apple-macos14.0 \
    -framework AppKit \
    -framework AVFoundation \
    -framework Vision \
    -framework LocalAuthentication \
    -framework CoreImage \
    -framework QuartzCore \
    -framework Accelerate \
    Sources/*.swift \
    Tests/*.swift \
    -o "${MACOS_DIR}/${APP_NAME}"

# Copy Info.plist and Resources
cp Resources/Info.plist "${CONTENTS_DIR}/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
    cp Resources/AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"
fi

# Code sign ad-hoc
echo "==> Code-signing application bundle..."
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "==> Successfully built: ${APP_BUNDLE}"
echo "==> To run: open ${APP_BUNDLE}"
