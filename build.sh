#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

LOCK_DIR="/tmp/facelock_build.lock"
PID_FILE="${LOCK_DIR}/pid"

acquire_lock() {
    local waited=0
    while ! mkdir "${LOCK_DIR}" 2>/dev/null; do
        if [ -f "${PID_FILE}" ]; then
            local lock_pid
            lock_pid=$(cat "${PID_FILE}" 2>/dev/null || true)
            if [ -n "${lock_pid}" ] && ! kill -0 "${lock_pid}" 2>/dev/null; then
                echo "==> Stale build lock detected from inactive PID ${lock_pid}. Recovering..."
                rm -rf "${LOCK_DIR}"
                continue
            fi
        fi

        if [ -d "${LOCK_DIR}" ]; then
            local lock_age
            lock_age=$(python3 -c "import os, time; print(int(time.time() - os.path.getmtime('${LOCK_DIR}')))" 2>/dev/null || echo "0")
            if [ "${lock_age}" -ge 60 ]; then
                echo "==> Stale build lock older than 60s (${lock_age}s) detected. Recovering..."
                rm -rf "${LOCK_DIR}"
                continue
            fi
        fi

        waited=$((waited + 1))
        if [ ${waited} -ge 20 ]; then # 10s timeout
            echo "==> Build lock wait timeout (10s) reached. Recovering..."
            rm -rf "${LOCK_DIR}"
            continue
        fi
        sleep 0.5
    done
    echo "$$" > "${PID_FILE}"
}

acquire_lock
trap 'rm -rf "${LOCK_DIR}"' EXIT INT TERM HUP

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
