#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "${REPO_DIR}"

echo "==> Checking GitHub for FaceLock updates..."
git fetch origin main -q

LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse origin/main)"

if [ "${LOCAL}" = "${REMOTE}" ]; then
    echo "✓ FaceLock is already up to date (commit ${LOCAL:0:7})."
    exit 0
fi

echo "==> New version detected on remote (${LOCAL:0:7} -> ${REMOTE:0:7}). Pulling..."
git pull --rebase origin main

echo "==> Compiling latest binary..."
./build.sh

echo "==> Updating /Applications/FaceLock.app..."
rm -rf /Applications/FaceLock.app
cp -R build/FaceLock.app /Applications/

echo "==> Reloading active daemon..."
pkill -f "FaceLock.app/Contents/MacOS/FaceLock" 2>/dev/null || true
sleep 1
open /Applications/FaceLock.app

echo "✓ FaceLock successfully updated and restarted (commit ${REMOTE:0:7})!"
