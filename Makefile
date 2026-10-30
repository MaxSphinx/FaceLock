.PHONY: all build run enroll test-lock lock is-locked is-locked-json settings gallery status config apps apps-gui protect-app unprotect-app ignore-app unignore-app reset-apps diagnostics health toggle toggle-wake wake reload reset-session check-app vectors vectors-json optimize-vectors optimize-vectors-json install install-cli uninstall stop clean help commit update sync install-sync uninstall-sync release maintainer-install maintainer-stop report clear-incidents prune-incidents export-incidents test-telegram incidents incidents-summary incidents-summary-json latest-incident verify-face verify-pin status-json diagnostics-json audit audit-json audit-stats audit-gui prune-audit clear-audit export-audit pin-attempts pin-lockout cameras cameras-json set-camera reset-camera backup-config restore-config test

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

all: build

help:
	@echo "FaceLock Build & Management"
	@echo ""
	@echo "  make build          - Compile Swift binary and sign app bundle"
	@echo "  make install        - Install to /Applications/FaceLock.app and setup CLI"
	@echo "  make update         - Pull updates from GitHub, recompile & hot-reload"
	@echo "  make commit         - Auto-stage, commit with contextual message & push"
	@echo "  make release        - Cut git release tag & trigger GitHub Release build"
	@echo "  make sync           - Run continuous auto-commit & auto-update daemon"
	@echo "  make install-sync   - Install background auto-sync LaunchAgent daemon"
	@echo "  make uninstall-sync - Remove background auto-sync daemon"
	@echo "  make run            - Launch FaceLock background daemon"
	@echo "  make enroll         - Launch face calibration wizard"
	@echo "  make settings       - Open settings window"
	@echo "  make gallery        - Open intruder incident log"
	@echo "  make test-lock      - Trigger immediate fullscreen lock test"
	@echo "  make lock           - Trigger lock screen via daemon or standalone"
	@echo "  make is-locked      - Check if screen lock is currently active"
	@echo "  make toggle         - Toggle protection between ACTIVE and PAUSED"
	@echo "  make toggle-wake    - Toggle lock verification upon Mac screen wake"
	@echo "  make reload         - Hot-reload active configuration in running daemon"
	@echo "  make reset-session  - Invalidate active biometric verification session cache"
	@echo "  make check-app APP= - Inspect if bundle ID triggers biometric shield"
	@echo "  make status         - Display current protection & biometric status"
	@echo "  make status-json    - Display status in JSON format"
	@echo "  make health         - Fast operational healthcheck (exit 0 if healthy)"
	@echo "  make config         - Display active FaceLock configuration settings"
	@echo "  make apps           - List protected and ignored application bundle IDs"
	@echo "  make apps-gui       - Open interactive application protection policy window"
	@echo "  make protect-app APP= - Add application bundle ID to protected list"
	@echo "  make unprotect-app APP= - Remove application bundle ID from protected list"
	@echo "  make ignore-app APP= - Add application bundle ID to ignored list"
	@echo "  make unignore-app APP= - Remove application bundle ID from ignored list"
	@echo "  make reset-apps     - Reset application protection rules to factory defaults"
	@echo "  make cameras        - List available video capture cameras and active selection"
	@echo "  make cameras-json   - List video capture cameras in JSON format"
	@echo "  make set-camera CAMERA= - Set preferred camera device by ID, name or 'default'"
	@echo "  make reset-camera   - Reset preferred camera selection to default front camera"
	@echo "  make backup-config DEST= - Backup FaceLock configuration to JSON file"
	@echo "  make restore-config SRC= - Restore FaceLock configuration from JSON file"
	@echo "  make vectors        - Inspect enrolled facial templates and cluster metrics"
	@echo "  make optimize-vectors - Prune redundant vectors and outliers to optimize cluster"
	@echo "  make audit          - View security audit event log"
	@echo "  make audit-gui      - Open security audit log GUI window"
	@echo "  make audit-stats    - View security audit statistics"
	@echo "  make prune-audit KEEP= - Prune older audit events keeping latest N (default: 100)"
	@echo "  make clear-audit    - Purge security audit event log"
	@echo "  make export-audit FILE= - Export security audit log events to JSONL file"
	@echo "  make incidents      - List logged intruder incident captures"
	@echo "  make incidents-summary - Intruder telemetry (total, 24h, 7d, timestamps)"
	@echo "  make export-incidents DIR= - Export all intruder incident photos & manifest"
	@echo "  make latest-incident- Display most recent intruder incident capture"
	@echo "  make clear-incidents- Purge all saved intruder captures from disk"
	@echo "  make prune-incidents- Prune older intruder captures (keep latest 30)"
	@echo "  make verify-face    - One-shot biometric face verification via camera"
	@echo "  make pin-attempts ATTEMPTS= - Set max failed PIN attempts before lockout"
	@echo "  make pin-lockout SECONDS= - Set cooling lockout delay after failed PINs"
	@echo "  make test-telegram  - Dispatch test notification to Telegram chat"
	@echo "  make diagnostics    - Run full biometric, hardware & storage diagnostics"
	@echo "  make diagnostics-json - Run diagnostics in JSON format"
	@echo "  make stop           - Terminate running FaceLock instance"
	@echo "  make uninstall      - Remove application and CLI symlink"
	@echo "  make clean          - Remove build artifacts"

build:
	@./build.sh

profiles: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --profiles

profile: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --profile $(PROFILE)

run: build
	@echo "Launching FaceLock..."
	@open build/FaceLock.app

enroll: build
	@echo "Launching Face ID Calibration..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --enroll

test-lock: build
	@echo "Testing Fullscreen Lock (Touch ID or PIN)..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-lock

lock: build
	@echo "Triggering Lock Screen..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --lock

is-locked: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked || true

is-locked-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked --json || true

toggle: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle

toggle-wake: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake toggle

wake: toggle-wake

reload: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reload

reset-session: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session

check-app: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app $(APP)

settings: build
	@echo "Opening Settings..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --settings

gallery: build
	@echo "Opening Incident Gallery..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --gallery

status: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --status

status-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --status --json

health: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --health || true

config: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --config

apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps

apps-gui: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps-gui

protect-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make protect-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app "$(APP)"

unprotect-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make unprotect-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app "$(APP)"

ignore-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make ignore-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app "$(APP)"

unignore-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make unignore-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app "$(APP)"

reset-apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-apps

cameras: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras

cameras-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras --json

set-camera: build
	@if [ -z "$(CAMERA)" ]; then \
		echo "Usage: make set-camera CAMERA=<id|name|default>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-camera "$(CAMERA)"

reset-camera: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-camera

backup-config: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make backup-config DEST=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-config "$(DEST)"

restore-config: build
	@if [ -z "$(SRC)" ]; then \
		echo "Usage: make restore-config SRC=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --restore-config "$(SRC)"

vectors: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors

vectors-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors --json

optimize-vectors: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors

optimize-vectors-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors --json

incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents

incidents-summary: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary

incidents-summary-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary --json

export-incidents: build
	@if [ -z "$(DIR)" ]; then \
		echo "Usage: make export-incidents DIR=/path/to/destination"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-incidents "$(DIR)"

latest-incident: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident

verify-face: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --verify-face

verify-pin: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --verify-pin $(PIN)

pin-attempts: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-attempts $(ATTEMPTS)

pin-lockout: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-lockout $(SECONDS)

clear-incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-incidents

prune-incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents $(or $(KEEP),30)

test-telegram: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-telegram

audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit

audit-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --json

audit-stats: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats

audit-gui: build
	@echo "Opening Security Audit Log..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-gui

prune-audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit $(or $(KEEP),100)

clear-audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-audit

export-audit: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make export-audit FILE=/path/to/destination.jsonl"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit "$(FILE)"

test: build
	@echo "==> Running FaceLock Automated Unit Tests & Benchmarks..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --test
	@echo "==> Running CLI verification tests..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --help > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --version > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --status > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --status --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --config > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type policy --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type telegram --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-camera default --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-camera --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-config /tmp/facelock_cfg_test.json > /dev/null && rm -f /tmp/facelock_cfg_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway 45 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-walkaway --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway toggle --json > /dev/null
	@CUR_PIN=$$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.facelock/config.json'))).get('pin', '0000'))" 2>/dev/null || echo "0000"); \
	build/FaceLock.app/Contents/MacOS/FaceLock --verify-pin "$$CUR_PIN" --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --enable-telegram --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-liveness on --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-liveness --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-liveness toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-touchid on --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-touchid --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-touchid toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-wake --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake off --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reload --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app com.apple.Safari --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app com.apple.dock --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-attempts 3 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-lockout 5 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit 1000 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit /tmp/facelock_audit_test.jsonl --json > /dev/null && rm -f /tmp/facelock_audit_test.jsonl
	@mkdir -p /tmp/facelock_test_export && build/FaceLock.app/Contents/MacOS/FaceLock --export-incidents /tmp/facelock_test_export --json > /dev/null && rm -rf /tmp/facelock_test_export
	@build/FaceLock.app/Contents/MacOS/FaceLock --health --json > /dev/null || true
	@echo "✓ All CLI tests passed!"

diagnostics: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics

diagnostics-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics --json

commit:
	@./scripts/autocommit.sh

release:
	@./scripts/release.sh $(VERSION) "$(MSG)"

update:
	@./scripts/autoupdate.sh

sync:
	@./scripts/sync-daemon.sh

install-sync:
	@./scripts/install-sync.sh

uninstall-sync:
	@echo "Stopping background auto-sync LaunchAgent..."
	@-launchctl unload $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist 2>/dev/null || true
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist
	@echo "✓ Auto-sync LaunchAgent removed"
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist
	@echo "✓ Auto-sync LaunchAgent removed"

install: build install-cli
	@echo "Installing FaceLock to /Applications..."
	@rm -rf /Applications/FaceLock.app
	@cp -R build/FaceLock.app /Applications/
	@echo "✓ FaceLock successfully installed to /Applications/FaceLock.app"

install-cli:
	@echo "Configuring CLI symlink..."
	@if [ -d "/opt/homebrew/bin" ] && [ -w "/opt/homebrew/bin" ]; then \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /opt/homebrew/bin/facelock; \
		echo "✓ Symlink created in /opt/homebrew/bin/facelock"; \
	elif [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /usr/local/bin/facelock; \
		echo "✓ Symlink created in /usr/local/bin/facelock"; \
	else \
		mkdir -p $(HOME)/.local/bin; \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock $(HOME)/.local/bin/facelock; \
		echo "✓ Symlink created in $(HOME)/.local/bin/facelock"; \
	fi

uninstall:
	@echo "Uninstalling FaceLock..."
	@pkill -f "FaceLock.app/Contents/MacOS/FaceLock" 2>/dev/null || true
	@rm -rf /Applications/FaceLock.app
	@rm -f $(BINDIR)/facelock
	@echo "✓ FaceLock uninstalled"

stop:
	@echo "Stopping FaceLock process..."
	@-pkill -f "FaceLock.app/Contents/MacOS/FaceLock" || true

report:
	@./scripts/telegram_report.sh

maintainer-install:
	@./scripts/install_launchagent.sh

maintainer-stop:
	@echo "Stopping 24/7 Autonomous Maintainer..."
	@-launchctl unload $(HOME)/Library/LaunchAgents/io.github.facelock.maintainer.plist 2>/dev/null || true
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.maintainer.plist
	@echo "✓ Autonomous Maintainer stopped"

clean:
	@rm -rf build
