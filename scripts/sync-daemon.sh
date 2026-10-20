#!/usr/bin/env bash
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INTERVAL="${1:-60}" # Check every 60 seconds by default

echo "==> FaceLock Auto-Sync Daemon started (interval: ${INTERVAL}s)..."
echo "==> Repository: ${REPO_DIR}"

while true; do
    # 1. Auto-commit & push local edits
    if [ -n "$(cd "${REPO_DIR}" && git status --porcelain 2>/dev/null)" ]; then
        echo "[$(date '+%H:%M:%S')] Local changes detected. Auto-committing..."
        "${REPO_DIR}/scripts/autocommit.sh" || true
    fi

    # 2. Check remote updates
    "${REPO_DIR}/scripts/autoupdate.sh" || true

    sleep "${INTERVAL}"
done
