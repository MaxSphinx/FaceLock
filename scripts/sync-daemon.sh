#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="${FACE_LOCK_REPO:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
INTERVAL="${1:-120}"

echo "==> FaceLock Auto-Sync Daemon active (interval: ${INTERVAL}s)..."
echo "==> Tracking Repository: ${REPO_DIR}"

while true; do
    if [ -d "${REPO_DIR}/.git" ]; then
        # 1. Auto-commit & push local edits
        if [ -n "$(cd "${REPO_DIR}" && git status --porcelain 2>/dev/null)" ]; then
            echo "[$(date '+%H:%M:%S')] Local changes detected in ${REPO_DIR}. Auto-committing..."
            "${SCRIPT_DIR}/autocommit.sh" "${REPO_DIR}" || true
        fi

        # 2. Check remote updates
        "${SCRIPT_DIR}/autoupdate.sh" "${REPO_DIR}" || true
    fi

    sleep "${INTERVAL}"
done
