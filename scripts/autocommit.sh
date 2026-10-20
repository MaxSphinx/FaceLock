#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_DIR}"

# Check for modified or untracked files
if [ -z "$(git status --porcelain)" ]; then
    echo "✓ Working tree clean, nothing to commit."
    exit 0
fi

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# Generate contextual commit message
CHANGED_FILES="$(git status --porcelain | awk '{print $2}')"
if echo "${CHANGED_FILES}" | grep -q "^Sources/"; then
    MSG="feat(core): update biometric engine (${TIMESTAMP})"
elif echo "${CHANGED_FILES}" | grep -q "^Resources/"; then
    MSG="chore(assets): update app resources (${TIMESTAMP})"
elif echo "${CHANGED_FILES}" | grep -q -E "^(README|\.github)"; then
    MSG="docs: synchronize project documentation (${TIMESTAMP})"
else
    MSG="chore(sync): automated workspace update (${TIMESTAMP})"
fi

echo "==> Staging changes..."
git add .

echo "==> Committing: ${MSG}"
git commit -m "${MSG}"

echo "==> Pushing to GitHub (origin/main)..."
git push origin main

echo "✓ Successfully auto-committed and pushed to GitHub."
