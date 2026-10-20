.PHONY: all build run enroll test-lock settings gallery status install install-cli uninstall stop clean help commit update sync install-sync uninstall-sync release

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
	@echo "  make status         - Display current protection & biometric status"
	@echo "  make stop           - Terminate running FaceLock instance"
	@echo "  make uninstall      - Remove application and CLI symlink"
	@echo "  make clean          - Remove build artifacts"

build:
	@./build.sh

run: build
	@echo "Launching FaceLock..."
	@open build/FaceLock.app

enroll: build
	@echo "Launching Face ID Calibration..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --enroll

test-lock: build
	@echo "Testing Fullscreen Lock (Touch ID or PIN)..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-lock

settings: build
	@echo "Opening Settings..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --settings

gallery: build
	@echo "Opening Incident Gallery..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --gallery

status: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --status

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

clean:
	@rm -rf build
