#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_DIR}"

# Check for modified or untracked files
if [ -z "$(git status --porcelain)" ]; then
    echo "✓ Working tree clean, nothing to commit."
    exit 0
fi

# Allow passing custom commit message as first argument
CUSTOM_MSG="${1:-}"

if [ -n "${CUSTOM_MSG}" ]; then
    MSG="${CUSTOM_MSG}"
else
    # Generate human-readable conventional commit message based on staged files
    CHANGED_FILES="$(git status --porcelain | awk '{print $2}')"
    if echo "${CHANGED_FILES}" | grep -q "^Sources/"; then
        MSG="feat(core): refine biometric verification engine"
    elif echo "${CHANGED_FILES}" | grep -q "^Resources/"; then
        MSG="chore(assets): update application assets"
    elif echo "${CHANGED_FILES}" | grep -q -E "^(README|docs/|\.github)"; then
        MSG="docs: update documentation and project guides"
    elif echo "${CHANGED_FILES}" | grep -q "^scripts/"; then
        MSG="chore(scripts): optimize maintenance automation"
    else
        MSG="chore: codebase polish and improvements"
    fi
fi

echo "==> Staging changes..."
git add .

echo "==> Committing: ${MSG}"
git commit -m "${MSG}"

echo "==> Pushing to GitHub (origin/main)..."
git push origin main

echo "✓ Successfully committed and pushed to GitHub."
