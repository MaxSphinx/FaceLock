#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="${HOME}/Library/LaunchAgents/io.github.facelock.sync.plist"

mkdir -p "${HOME}/Library/LaunchAgents"
mkdir -p "${HOME}/.facelock"

cat << EOF > "${PLIST}"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>io.github.facelock.sync</string>
    <key>ProgramArguments</key>
    <array>
        <string>${REPO_DIR}/scripts/sync-daemon.sh</string>
        <string>120</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardErrorPath</key>
    <string>${HOME}/.facelock/sync_error.log</string>
    <key>StandardOutPath</key>
    <string>${HOME}/.facelock/sync.log</string>
</dict>
</plist>
EOF

launchctl unload "${PLIST}" 2>/dev/null || true
launchctl load "${PLIST}"
echo "✓ Background auto-sync LaunchAgent active (checks every 2 minutes)"
