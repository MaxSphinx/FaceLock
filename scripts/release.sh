#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${REPO_DIR}"

VERSION="${1:-}"
MESSAGE="${2:-Release ${VERSION}}"

if [ -z "${VERSION}" ]; then
    echo "Usage: $0 <version> [message]"
    echo "Example: $0 1.0.0 'Initial production release'"
    exit 1
fi

# Strip leading 'v' if provided
VERSION="${VERSION#v}"
TAG="v${VERSION}"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "==> Staging uncommitted changes before release..."
    git add .
    git commit -m "chore(release): prepare ${TAG}"
fi

# Check if tag already exists
if git rev-parse "${TAG}" >/dev/null 2>&1; then
    echo "Error: Tag ${TAG} already exists!"
    exit 1
fi

echo "==> Creating annotated tag: ${TAG}"
git tag -a "${TAG}" -m "${MESSAGE}"

echo "==> Pushing commits and tag to GitHub..."
git push origin main
git push origin "${TAG}"

echo ""
echo "=========================================================="
echo "✓ Release ${TAG} successfully published to GitHub!"
echo "  Workflow: https://github.com/MaxSphinx/FaceLock/actions"
echo "  Releases: https://github.com/MaxSphinx/FaceLock/releases/tag/${TAG}"
echo "=========================================================="
