#!/usr/bin/env bash
# FaceLock One-Line Installer for macOS (Apple Silicon)
# Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MaxSphinx/FaceLock/main/install.sh)"

set -euo pipefail

echo "=========================================================="
echo "          FaceLock — Biometric App Shield                 "
echo "=========================================================="

# 1. Architecture Check
ARCH="$(uname -m)"
if [ "${ARCH}" != "arm64" ]; then
    echo "❌ Error: FaceLock is optimized for Apple Silicon (M1/M2/M3/M4)."
    echo "   Detected architecture: ${ARCH}"
    exit 1
fi

# 2. OS Version Check
OS_VER="$(sw_vers -productVersion | cut -d. -f1)"
if [ "${OS_VER}" -lt 14 ]; then
    echo "❌ Error: macOS 14.0 (Sonoma) or newer is required."
    echo "   Current version: $(sw_vers -productVersion)"
    exit 1
fi

REPO="MaxSphinx/FaceLock"
TMP_DIR="$(mktemp -d)"
ZIP_FILE="${TMP_DIR}/FaceLock.zip"

cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "==> Fetching latest release from GitHub..."
RELEASE_URL="https://github.com/${REPO}/releases/latest/download/FaceLock-macOS-arm64.zip"

if curl -fsSL -o "${ZIP_FILE}" "${RELEASE_URL}"; then
    echo "✓ Downloaded latest release archive."
else
    echo "==> Pre-built binary not yet ready on release page. Building from source..."
    git clone --depth 1 "https://github.com/${REPO}.git" "${TMP_DIR}/src"
    cd "${TMP_DIR}/src"
    ./build.sh
    cd - >/dev/null
    mv "${TMP_DIR}/src/build/FaceLock.app" "${TMP_DIR}/FaceLock.app"
fi

if [ -f "${ZIP_FILE}" ] && [ ! -d "${TMP_DIR}/FaceLock.app" ]; then
    unzip -q "${ZIP_FILE}" -d "${TMP_DIR}"
fi

echo "==> Installing to /Applications/FaceLock.app..."
pkill -f "FaceLock.app/Contents/MacOS/FaceLock" 2>/dev/null || true
rm -rf /Applications/FaceLock.app
cp -R "${TMP_DIR}/FaceLock.app" /Applications/

# 3. Setup CLI symlink
echo "==> Configuring CLI command 'facelock'..."
if [ -d "/opt/homebrew/bin" ] && [ -w "/opt/homebrew/bin" ]; then
    ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /opt/homebrew/bin/facelock
    echo "✓ Symlink ready at /opt/homebrew/bin/facelock"
elif [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /usr/local/bin/facelock
    echo "✓ Symlink ready at /usr/local/bin/facelock"
else
    mkdir -p "${HOME}/.local/bin"
    ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock "${HOME}/.local/bin/facelock"
    echo "✓ Symlink ready at ${HOME}/.local/bin/facelock"
fi

echo "==> Launching FaceLock..."
open /Applications/FaceLock.app

echo ""
echo "=========================================================="
echo "🎉 FaceLock successfully installed!"
echo ""
echo "Next step: Calibrate your face (takes ~20 seconds):"
echo "  $ facelock --enroll"
echo ""
echo "Star the repo if you like it: https://github.com/${REPO}"
echo "=========================================================="
