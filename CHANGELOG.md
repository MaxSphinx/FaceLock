# Changelog

All notable changes to **FaceLock** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5] - 2026-10-24

### Added
- **Live Distributed IPC Configuration Hot-Reloading**: Added `--reload` / `--reload-config` CLI commands and automatic distributed IPC notifications (`reload-config`) on all configuration mutations, allowing background daemons to immediately adopt changes without restarting.
- **Application Security Inspection CLI**: Added `--check-app <bundleId>` (with `--json` support) and `make check-app APP=...` to evaluate whether a target bundle ID triggers biometric protection under current rules and modes.
- **Makefile Hot-Reload Target**: Added `make reload` target and automated test coverage in `make test`.

### Fixed
- **Camera Scanner & App Switch Concurrency Guards**: Added `isVerifying` protection and wake event debouncing in `AppMonitor` to prevent overlapping camera sessions during rapid application switching or simultaneous system/display wake notifications.
- **Camera Session Completion Safety**: Handled active scan completion handoff in `CameraScanner` to prevent dangling closures on concurrent requests.

## [1.0.4] - 2026-10-24

### Added
- **Screen Lock Session Reset & Security Hardening**: Added distributed notification listeners (`com.apple.screenIsLocked` & `com.apple.screenIsUnlocked`) in `AppMonitor` to immediately invalidate cached verification debounce sessions when the user locks macOS (e.g. Cmd+Ctrl+Q), preventing bypass upon subsequent wake.
- **GUI Settings for Screen Wake Lock**: Added UI toggle for `lockOnWake` in `SettingsWindow` under Section 4 ("Авто-замок при уходе и пробуждении") with live state synchronization.
- **Status Bar Toggle for Screen Wake**: Added "Проверка при пробуждении: [Вкл|Выкл]" shortcut item in the status bar menu with visual HUD feedback.
- **CLI Toggle & Alias Enhancements**: Added `--lock-on-wake` alias, support for `--set-lock-on-wake toggle`, and inter-process command dispatching.
- **Makefile Targets**: Added `make toggle-wake` and `make wake` targets with automated test coverage in `make test`.

## [1.0.3] - 2026-10-23

### Added
- **Screen Wake Biometric Verification (`lockOnWake`)**: Added `--set-lock-on-wake <on|off>` and system/display wake monitors in `AppMonitor` to optionally verify owner biometrics or lock upon waking from sleep or opening the laptop lid.
- **Config Backup & Restoration**: Added `--backup-config <path>` and `--restore-config <path>` with atomic writes and strict decoding validation.
- **Individual Incident Management**: Added `--incident <filename>`, `--delete-incident <filename>`, and `--export-latest-incident <path>` to inspect, selectively purge, or export captured intruder snapshots.
- **Immediate Lock Action in Status Bar**: Added "Заблокировать экран сейчас" (`make lock` / shortcut `L`) to the status bar menu for instant on-demand screen shielding.
- **Backwards-Compatible Robust Codable**: Added custom `init(from decoder: Decoder)` in `Config` using `decodeIfPresent` fallbacks to prevent configuration loss when schema expands across versions.
- **Makefile Enhancements**: Added `make health`, `make status-json`, and `make diagnostics-json` targets; updated test suite to dynamically inspect the active PIN without failing on customized configurations.

### Fixed
- **Status Bar Tooltip**: Corrected status item tooltip to reflect single-click menu behavior.

## [1.0.2] - 2026-10-22

### Added
- **One-Shot Biometric Face Verification CLI**: Added `--verify-face` (with optional `--timeout <sec>`, `--save-intruder`, and `--json`) to execute instant camera face verification headlessly without triggering a screen lock. Returns exit code 0 on verified owner face, 1 on intruder rejection, and 2 on timeout.
- **PIN Verification CLI Command**: Added `--verify-pin <pin>` (with `--json` support) to validate candidate PINs against active lock screen configuration with exit code integration for shell scripts.
- **Latest Incident Inspection**: Added `--latest-incident` (with `--json` support) and `make latest-incident` to inspect details, timestamps, and paths of the most recent intruder photo.
- **Non-Destructive Test Suite**: Enhanced `Makefile` test suite to use non-destructive PIN verification rather than forcefully overwriting user PIN configurations.

## [1.0.1] - 2026-10-22

### Added
- **Instant PIN Auto-Unlock**: Added text change listener to PIN field for immediate verification and error auto-clearing without requiring manual Enter keystrokes.
- **Incident Retention Pruning**: Added `--prune-incidents <count>` and `make prune-incidents` to prune older intruder snapshots while keeping the latest $N$ entries.
- **CLI Verification & Debounce Controls**: Added `--set-timeout <seconds>` and `--set-debounce <seconds>` flags for direct terminal adjustment of timing thresholds.
- **Telegram Status Telemetry**: Enhanced status reporter to include real-time daemon state, shield status, enrolled neural vectors, and incident counts.

### Fixed
- **Camera Session Lifecycle**: Added `NSWindowDelegate` handler in `EnrollmentController` to guarantee clean camera teardown when closing the calibration window via the window close button.

## [1.0.0] - 2026-10-20

### Added
- **Core Biometric Shield**: Active camera verification triggered on application focus changes via `NSWorkspace`.
- **Apple Neural Engine ANFRv4 Extractor**: 128-dimensional facial embeddings using Apple's native deep faceprint neural network.
- **Dual-Verification Cluster Metric**: Combined minimum cosine distance ($d \le 0.22$) and Top-3 ensemble validation ($d \le 0.27$) against enrolled owner templates.
- **Unbypassable Fullscreen Lock**: `.screenSaver` window level overlay intercepting Esc, Cmd+Q, Cmd+W, Cmd+M, and system shortcuts.
- **Night-Mode Intruder Capture**: Low-light exposure lift (+1.3 EV) and shadow enhancement filters for crisp intruder photography.
- **Telegram Bot Instant Alerts**: Automated multipart/form-data upload of intruder snapshots with timestamp and targeted app metadata.
- **Interactive Incident Gallery**: Visual macOS window with chronological list of captured intruder events, deletion, and Finder reveal.
- **Walk-Away Auto Lock**: Background monitor checking user inactivity via `CGEventSource` combined with silent camera verification.
- **First-Class CLI Tooling**: `--enroll`, `--settings`, `--gallery`, `--test-lock`, `--status`, `--version`, and `--help`.
- **LaunchAgent Support**: One-command background daemon startup for macOS.
