#!/bin/bash
# FaceLock 24/7 Autonomous Background Worker
# Periodically checks repo health, watches PRs, commits updates, and sends Telegram reports.

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
INTERVAL_SECONDS="${1:-14400}" # Default: every 4 hours (14400s)

echo "==> Starting FaceLock 24/7 Autonomous Worker..."
echo "==> Repository: $REPO_DIR"
echo "==> Interval: ${INTERVAL_SECONDS}s"

while true; do
    echo "=========================================="
    echo "==> [$(date '+%Y-%m-%d %H:%M:%S')] Executing maintenance cycle..."
    
    # 1. Check git status if repository is available
    if [[ -d "$REPO_DIR/.git" ]] && cd "$REPO_DIR" 2>/dev/null; then
        git fetch origin main 2>/dev/null || true
    fi
    
    # 2. Check for upstream PR merges in awesome catalogs
    PR_1712_STATE=$(gh pr view 1712 --repo serhii-londar/open-source-mac-os-apps --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    PR_1319_STATE=$(gh pr view 1319 --repo iCHAIT/awesome-macOS --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    PR_2007_STATE=$(gh pr view 2007 --repo matteocrippa/awesome-swift --json state --jq .state 2>/dev/null || echo "UNKNOWN")
    
    EVENT_MSG=""
    if [[ "$PR_1712_STATE" == "MERGED" ]]; then
        EVENT_MSG="🎉 PR #1712 в open-source-mac-os-apps успешно смерджен! Проект добавлен в каталог 50k★ и Telegram канал!"
    fi
    if [[ "$PR_1319_STATE" == "MERGED" ]]; then
        EVENT_MSG="${EVENT_MSG} 🎉 PR #1319 в awesome-macOS успешно смерджен!"
    fi
    if [[ "$PR_2007_STATE" == "MERGED" ]]; then
        EVENT_MSG="${EVENT_MSG} 🎉 PR #2007 в awesome-swift успешно смерджен!"
    fi
    
    # Check if awesome-swift 15-star threshold is met to reopen PR #2007
    STARS_COUNT=$(gh api repos/MaxSphinx/FaceLock --jq .stargazers_count 2>/dev/null || echo "0")
    if [[ "$STARS_COUNT" =~ ^[0-9]+$ ]] && [[ "$STARS_COUNT" -ge 15 && "$PR_2007_STATE" == "CLOSED" ]]; then
        EVENT_MSG="${EVENT_MSG} 🌟 FaceLock набрал 15+ звёзд ($STARS_COUNT★)! Можно переоткрыть PR #2007 в awesome-swift!"
    fi
    
    # 3. Check for open issues to notify
    ISSUES_COUNT=$(gh issue list --repo MaxSphinx/FaceLock --json number --jq '. | length' 2>/dev/null || echo "0")
    if [[ "$ISSUES_COUNT" -gt 0 ]]; then
        EVENT_MSG="${EVENT_MSG} ⚠️ Обнаружено $ISSUES_COUNT активных issue в репозитории."
    fi
    
    # 4. Run autocommit if any new files or logs were modified
    if [[ -d "$REPO_DIR/.git" ]] && cd "$REPO_DIR" 2>/dev/null; then
        if [[ -n $(git status -s 2>/dev/null) ]]; then
            echo "==> Local changes detected. Staging and committing..."
            ./scripts/autocommit.sh || true
            EVENT_MSG="${EVENT_MSG} 🚀 Выпущен новый коммит с авто-обновлениями."
        fi

        # Check if there are unreleased commits since last tag (auto-release cadence)
        LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
        COMMITS_AHEAD=$(git rev-list "${LATEST_TAG}..HEAD" --count 2>/dev/null || echo "0")
        if [[ "$COMMITS_AHEAD" -ge 10 ]]; then
            echo "==> $COMMITS_AHEAD commits ahead of $LATEST_TAG. Triggering autonomous release..."
            CUR_VER="${LATEST_TAG#v}"
            IFS='.' read -r MAJOR MINOR PATCH <<< "$CUR_VER"
            NEW_PATCH=$((PATCH + 1))
            NEW_TAG="v${MAJOR}.${MINOR}.${NEW_PATCH}"
            ./scripts/release.sh "${NEW_TAG}" "Continuous maintenance release (${NEW_TAG})" || true
            EVENT_MSG="${EVENT_MSG} 📦 Опубликован новый релиз ${NEW_TAG} на GitHub!"
        fi
    fi
    
    # 5. Dispatch Telegram report
    if [[ -x "$SCRIPT_DIR/telegram_report.sh" ]]; then
        "$SCRIPT_DIR/telegram_report.sh" "$EVENT_MSG" || true
    elif [[ -x "$REPO_DIR/scripts/telegram_report.sh" ]]; then
        "$REPO_DIR/scripts/telegram_report.sh" "$EVENT_MSG" || true
    fi
    
    echo "==> Cycle completed. Sleeping for ${INTERVAL_SECONDS}s..."
    sleep "$INTERVAL_SECONDS"
done
