#!/bin/bash
# FaceLock 24/7 Autonomous Status & Telegram Reporter
# Usage: ./scripts/telegram_report.sh [custom_message]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
if [[ -d "$REPO_DIR" ]]; then
    cd "$REPO_DIR"
fi

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

# Fetch GitHub stats safely
echo "==> Fetching GitHub stats for $REPO..."
REPO_JSON=$(gh api "repos/$REPO" 2>/dev/null || echo "{}")
STARS=$(echo "$REPO_JSON" | python3 -c "import sys, json; 
try:
    d = json.load(sys.stdin)
    print(d.get('stargazers_count', 'N/A'))
except Exception:
    print('N/A')
")
FORKS=$(echo "$REPO_JSON" | python3 -c "import sys, json; 
try:
    d = json.load(sys.stdin)
    print(d.get('forks_count', 'N/A'))
except Exception:
    print('N/A')
")
OPEN_ISSUES=$(echo "$REPO_JSON" | python3 -c "import sys, json; 
try:
    d = json.load(sys.stdin)
    print(d.get('open_issues_count', 'N/A'))
except Exception:
    print('N/A')
")

# Check status of PRs to awesome catalogs safely
format_pr_status() {
    local repo="$1"
    local pr_num="$2"
    local raw
    raw=$(gh pr view "$pr_num" --repo "$repo" --json state,mergeable 2>/dev/null || echo "{}")
    echo "$raw" | python3 -c "import sys, json
try:
    d = json.load(sys.stdin)
    s = d.get('state', 'PENDING')
    m = d.get('mergeable', '')
    if s == 'MERGED':
        print('MERGED 🎉')
    elif s == 'OPEN':
        if m == 'CONFLICTING':
            print('OPEN ⚠️ (конфликт)')
        elif m == 'MERGEABLE':
            print('OPEN ⏳ (готов к мерджу)')
        else:
            print('OPEN ⏳ (на ревью)')
    elif s == 'CLOSED':
        print('CLOSED 🛑')
    else:
        print(s)
except Exception:
    print('PENDING')
" 2>/dev/null || echo "PENDING"
}

PR_1712=$(format_pr_status "serhii-londar/open-source-mac-os-apps" 1712)
PR_1319=$(format_pr_status "iCHAIT/awesome-macOS" 1319)
PR_2007=$(format_pr_status "matteocrippa/awesome-swift" 2007)

# Fetch local daemon telemetry safely
DAEMON_PID=$(pgrep -f "FaceLock.app/Contents/MacOS/FaceLock" 2>/dev/null | head -n 1 || true)
if [[ -n "$DAEMON_PID" ]]; then
    DAEMON_STATUS="АКТИВЕН (PID $DAEMON_PID) ✅"
else
    DAEMON_STATUS="ОСТАНОВЛЕН ℹ️"
fi

SHIELD_STATUS=$(python3 -c "import json, os
p = os.path.expanduser('~/.facelock/config.json')
if os.path.exists(p):
    try:
        c = json.load(open(p))
        print('АКТИВНА 🛡️' if c.get('isEnabled', True) else 'НА ПАУЗЕ ⏸️')
    except:
        print('N/A')
else:
    print('N/A')
" 2>/dev/null || echo "N/A")

ENROLLED_COUNT=$(python3 -c "import json, os
p = os.path.expanduser('~/.facelock/owner_face_vectors.json')
if os.path.exists(p):
    try:
        v = json.load(open(p))
        print(f'{len(v)} нейровекторов')
    except:
        print('0')
else:
    print('0')
" 2>/dev/null || echo "0")

INTRUDER_COUNT=$(python3 -c "import os
p = os.path.expanduser('~/.facelock/intruders')
if os.path.exists(p):
    print(f'{len([f for f in os.listdir(p) if f.endswith(\".jpg\") or f.endswith(\".jpeg\")])} инцидентов')
else:
    print('0')
" 2>/dev/null || echo "0")

# Latest commit info
if [[ -d "$REPO_DIR/.git" ]]; then
    LATEST_COMMIT=$(git -C "$REPO_DIR" log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "N/A")
elif [[ -d "$HOME/Developer/FaceLock/.git" ]]; then
    LATEST_COMMIT=$(git -C "$HOME/Developer/FaceLock" log -1 --pretty=format:"%h - %s" 2>/dev/null || echo "N/A")
else
    LATEST_COMMIT=$(gh api "repos/$REPO/commits/main" --jq '"\(.sha[0:7]) - \(.commit.message | split("\n")[0])"' 2>/dev/null || echo "N/A")
fi
SAFE_LATEST_COMMIT=$(echo "$LATEST_COMMIT" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
DATE_NOW=$(date "+%Y-%m-%d %H:%M:%S")

CUSTOM_MSG="${1:-}"

# Compose formatted Telegram message
MESSAGE="🛡️ <b>FaceLock Status Report</b>
📅 <i>$DATE_NOW</i>

📊 <b>Статистика репозитория:</b>
• ⭐ Звёзды: <b>$STARS</b>
• 🍴 Форки: <b>$FORKS</b>
• 🐞 Открытые Issues: <b>$OPEN_ISSUES</b>

🌐 <b>Статус Pull Request в каталоги:</b>
• <code>open-source-mac-os-apps #1712</code> (50k★): <b>$PR_1712</b>
• <code>awesome-macOS #1319</code> (19k★): <b>$PR_1319</b>
• <code>awesome-swift #2007</code> (26k★): <b>$PR_2007</b>

🖥️ <b>Локальный статус FaceLock:</b>
• Демон: <b>$DAEMON_STATUS</b>
• Защита: <b>$SHIELD_STATUS</b>
• Слепки лица: <b>$ENROLLED_COUNT</b>
• Нарушители: <b>$INTRUDER_COUNT</b>

💻 <b>Последний коммит:</b>
<code>$SAFE_LATEST_COMMIT</code>"

if [[ -n "$CUSTOM_MSG" ]]; then
    MESSAGE="$MESSAGE

📝 <b>Обновление:</b>
$CUSTOM_MSG"
fi

echo "$MESSAGE"

# Dispatch to Telegram if credentials are set
if [[ -n "$TOKEN" && -n "$CHAT_ID" ]]; then
    echo "==> Sending report to Telegram chat $CHAT_ID..."
    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        --data-urlencode "chat_id=$CHAT_ID" \
        --data-urlencode "parse_mode=HTML" \
        --data-urlencode "text=$MESSAGE")
    if echo "$RESPONSE" | grep -q '"ok":true'; then
        echo "✓ Telegram message sent successfully!"
    else
        echo "⚠️ Telegram API response: $RESPONSE"
    fi
else
    echo "ℹ️ Telegram Bot Token or Chat ID not configured in $CONFIG_FILE."
    echo "To enable direct Telegram notifications, add 'telegramBotToken' and 'telegramChatId' to $CONFIG_FILE."
fi
