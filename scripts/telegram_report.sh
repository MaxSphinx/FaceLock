#!/bin/bash
# FaceLock 24/7 Autonomous Status & Telegram Reporter
# Usage: ./scripts/telegram_report.sh [custom_message]

set -euo pipefail

REPO="MaxSphinx/FaceLock"
CONFIG_FILE="$HOME/.facelock/config.json"

# Extract Telegram credentials from config.json if available
TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

if [[ -f "$CONFIG_FILE" ]]; then
    if [[ -z "$TOKEN" ]]; then
        TOKEN=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('telegramBotToken', ''))" 2>/dev/null || true)
    fi
    if [[ -z "$CHAT_ID" ]]; then
        CHAT_ID=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('telegramChatId', ''))" 2>/dev/null || true)
    fi
fi

# Fetch GitHub stats
echo "==> Fetching GitHub stats for $REPO..."
REPO_JSON=$(gh api "repos/$REPO" 2>/dev/null || echo "{}")
STARS=$(echo "$REPO_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin).get('stargazers_count', 'N/A'))")
FORKS=$(echo "$REPO_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin).get('forks_count', 'N/A'))")
OPEN_ISSUES=$(echo "$REPO_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin).get('open_issues_count', 'N/A'))")

# Check status of PRs to awesome catalogs
PR_1712=$(gh pr view 1712 --repo serhii-londar/open-source-mac-os-apps --json state --jq .state 2>/dev/null || echo "PENDING")
PR_1319=$(gh pr view 1319 --repo iCHAIT/awesome-macOS --json state --jq .state 2>/dev/null || echo "PENDING")
PR_2007=$(gh pr view 2007 --repo matteocrippa/awesome-swift --json state --jq .state 2>/dev/null || echo "PENDING")

# Latest commit info
LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "N/A")
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")

CUSTOM_MSG="${1:-}"

# Compose formatted Telegram message
MESSAGE="🛡️ <b>FaceLock 24/7 Autonomous Report</b>
📅 <i>$DATE_NOW</i>

📊 <b>Статистика репозитория:</b>
• ⭐ Звёзды: <b>$STARS</b>
• 🍴 Форки: <b>$FORKS</b>
• 🐞 Открытые Issues: <b>$OPEN_ISSUES</b>

🌐 <b>Статус Pull Request в каталоги:</b>
• <code>open-source-mac-os-apps #1712</code> (50k★): <b>$PR_1712</b>
• <code>awesome-macOS #1319</code> (19k★): <b>$PR_1319</b>
• <code>awesome-swift #2007</code> (26k★): <b>$PR_2007</b>

💻 <b>Последний коммит:</b>
<code>$LATEST_COMMIT</code>"

if [[ -n "$CUSTOM_MSG" ]]; then
    MESSAGE="$MESSAGE

📝 <b>Действие агента:</b>
$CUSTOM_MSG"
fi

echo "$MESSAGE"

# Dispatch to Telegram if credentials are set
if [[ -n "$TOKEN" && -n "$CHAT_ID" ]]; then
    echo "==> Sending report to Telegram chat $CHAT_ID..."
    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "parse_mode=HTML" \
        -d "text=$MESSAGE")
    if echo "$RESPONSE" | grep -q '"ok":true'; then
        echo "✓ Telegram message sent successfully!"
    else
        echo "⚠️ Telegram API response: $RESPONSE"
    fi
else
    echo "ℹ️ Telegram Bot Token or Chat ID not configured in $CONFIG_FILE."
    echo "To enable direct Telegram notifications, add 'telegramBotToken' and 'telegramChatId' to $CONFIG_FILE."
fi
