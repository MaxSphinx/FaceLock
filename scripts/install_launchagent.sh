#!/bin/bash
# Install FaceLock 24/7 Autonomous Maintainer as a macOS LaunchAgent

set -euo pipefail

PLIST_PATH="$HOME/Library/LaunchAgents/io.github.facelock.maintainer.plist"
SCRIPT_PATH="$HOME/.facelock/bin/autonomous_worker.sh"
LOG_DIR="$HOME/.facelock/logs"

mkdir -p "$LOG_DIR"
mkdir -p "$HOME/Library/LaunchAgents"
mkdir -p "$HOME/.facelock/bin"

# Copy worker and reporter scripts to ~/.facelock/bin to avoid macOS ~/Documents TCC restriction
cp -f /Users/maksim/Documents/antigravity/kind-shannon/FaceLock/scripts/autonomous_worker.sh "$HOME/.facelock/bin/"
cp -f /Users/maksim/Documents/antigravity/kind-shannon/FaceLock/scripts/telegram_report.sh "$HOME/.facelock/bin/"
chmod +x "$HOME/.facelock/bin"/*

# Unload existing agent if running
if launchctl list | grep -q "io.github.facelock.maintainer"; then
    echo "==> Unloading existing agent..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi

cat << EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>io.github.facelock.maintainer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
        <string>14400</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_DIR/maintainer.log</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/maintainer.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
</dict>
</plist>
EOF

echo "==> Loading LaunchAgent $PLIST_PATH..."
launchctl load "$PLIST_PATH"
echo "✓ FaceLock 24/7 Autonomous Maintainer successfully installed and running!"
echo "Logs: tail -f $LOG_DIR/maintainer.log"
