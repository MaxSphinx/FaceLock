#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "==> Pushing FaceLock to GitHub (git@github.com:MaxSphinx/FaceLock.git)..."
git push -u origin main
echo "✓ Successfully pushed to https://github.com/MaxSphinx/FaceLock"
