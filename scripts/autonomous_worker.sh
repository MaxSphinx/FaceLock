#!/bin/bash
# FaceLock 24/7 Autonomous Background Worker
# Periodically checks repo health, watches PRs, commits updates, and sends Telegram reports.

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

REPO_DIR="/Users/maksim/Documents/antigravity/kind-shannon/FaceLock"
INTERVAL_SECONDS="${1:-14400}" # Default: every 4 hours (14400s)

echo "==> Starting FaceLock 24/7 Autonomous Worker..."
echo "==> Repository: $REPO_DIR"
echo "==> Interval: ${INTERVAL_SECONDS}s"

cd "$REPO_DIR"

while true; do
    echo "=========================================="
    echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] Executing maintenance cycle..."
    
    # 1. Check git status
    git fetch origin main 2>/dev/null || true
    
    # 2. Check for upstream PR merges in awesome catalogs
    PR_1712_STATE=$(gh pr view 1712 --repo serhii-londar/open-source-mac-os-apps --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    PR_1319_STATE=$(gh pr view 1319 --repo iCHAIT/awesome-macOS --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    PR_2007_STATE=$(gh pr view 2007 --repo matteocrippa/awesome-swift --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    
    EVENT_MSG=""
    if [[ "$PR_1712_STATE" == "MERGED" ]]; then
        EVENT_MSG="🎉 PR #1712 в open-source-mac-os-apps успешно смерджен! Проект добавлен в каталог 50k★ и Telegram канал!"
    elif [[ "$PR_1319_STATE" == "MERGED" ]]; then
        EVENT_MSG="🎉 PR #1319 в awesome-macOS успешно смерджен!"
    elif [[ "$PR_2007_STATE" == "MERGED" ]]; then
        EVENT_MSG="🎉 PR #2007 в awesome-swift успешно смерджен!"
    fi
    
    # 3. Check for open issues to notify
    ISSUES_COUNT=$(gh issue list --repo MaxSphinx/FaceLock --json number --jq '. | length' 2>/dev/null || echo "0")
    if [[ "$ISSUES_COUNT" -gt 0 ]]; then
        EVENT_MSG="${EVENT_MSG} ⚠️ Обнаружено $ISSUES_COUNT активных issue в репозитории."
    fi
    
    # 4. Run autocommit if any new files or logs were modified
    if [[ -n $(git status -s) ]]; then
        echo "==> Local changes detected. Staging and committing..."
        ./scripts/autocommit.sh || true
        EVENT_MSG="${EVENT_MSG} 🚀 Выпущен новый коммит с авто-обновлениями."
    fi
    
    # 5. Dispatch Telegram report
    ./scripts/telegram_report.sh "$EVENT_MSG" || true
    
    echo "==> Cycle completed. Sleeping for ${INTERVAL_SECONDS}s..."
    sleep "$INTERVAL_SECONDS"
done
