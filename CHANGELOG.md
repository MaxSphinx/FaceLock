# Changelog

All notable changes to **FaceLock** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2026-10-27

### Added
- **Incident Gallery GUI Archive Export & Single Photo Save (`IncidentGalleryWindow.swift`)**:
  - Added "Экспорт архива..." button with native `NSOpenPanel` folder selection allowing one-click export of all intruder snapshots with automatic JSON manifest generation (`incidents_manifest.json`) and Finder reveal.
  - Added per-incident "Экспорт..." button with `NSSavePanel` sheet on each incident card for direct single-photo extraction.
  - Integrated real-time incident telemetry status bar inside the gallery window displaying total incident count, past 24-hour frequency, and disk space usage.
- **Dynamic Status Bar Badge Counts (`StatusBarController.swift`)**:
  - Dynamically displays real-time item counts for both incidents ("Журнал инцидентов (Галерея: N фото)...") and audit logs ("Журнал аудита безопасности (Audit Log: N)...") in the menu bar dropdown.
- **Deep Security Audit Trail Coverage (`SecurityAuditLogger.swift` & `AppDelegate.swift`)**:
  - Added audit events for policy rule modifications (`logPolicyChanged`): adding/removing protected applications, adding/removing ignored applications.
  - Added audit events for security configuration updates (`logConfigChanged`): anti-spoofing liveness toggle, Touch ID auto-trigger, screen wake lock verification, and PIN brute-force defense limits and cooldowns.
  - Added audit events for facial vector database operations (`logVectorsModified`): vector imports, clustering optimizations, and database resets.
  - Added audit events for incident capture lifecycle (`logIncidentsAction`): bulk archive exports, single image exports, individual deletions, and database purges.
  - Added audit events for verification tests (`logVerificationCheck`) across CLI face checks and PIN verification.
  - Added audit events for security audit log lifecycle: log exports, retention pruning, and purges.
  - Extended audit log query filtering to support `config`, `policy`, `settings`, and `vectors` categories.

## [1.0.7] - 2026-10-26

### Added
- **Interactive Security Audit Log GUI Window (`AuditLogWindow.swift`)**: Built a full macOS desktop window (`--audit-gui`, `--audit-ui`, `--audit-window`, `make audit-gui`) with real-time event cards, event categorization filter (All, Biometrics, Intruders, PIN, Touch ID, Shield), live refresh, `NSSavePanel` JSON export, Finder reveal, and quick photo inspection.
- **Audit Log Retention Pruning (`--prune-audit <count>`, `make prune-audit`)**: Added thread-safe retention pruning in `SecurityAuditLogger.swift` to prune older log events while keeping the latest $N$ entries with atomic writes and freed storage reporting.
- **Status Bar Audit Trail Integration**: Added "Журнал аудита безопасности (Audit Log)..." (shortcut `a`) to the status bar menu in `StatusBarController` for instant GUI inspection.
- **Settings GUI Controls for PIN Protection & Audit Log**: Added interactive sliders for failed PIN attempt limits (1-10) and cooldown delays (1-60s) in Section 5 of `SettingsWindow`, along with Section 6 providing real-time audit event telemetry, storage footprint metrics, and one-click navigation to both the Audit Log and Incident Gallery.
- **Dynamic Multi-Display Reconfiguration Security Hardening**: Added `NSApplication.didChangeScreenParametersNotification` listener in `LockScreenController` to dynamically adapt, re-anchor, and cover all displays with `FullscreenLockWindow`s when external monitors are connected, disconnected, or screen resolutions change while locked.
- **Complete Incident Dataset Archival & Manifest Export (`--export-incidents <dir>`)**: Added `--export-incidents <dir>` CLI command and `make export-incidents DIR=...` to export all captured intruder incident photos to a destination directory alongside an automated JSON manifest file (`incidents_manifest.json`) containing timestamps, file sizes, and counts.
- **Biometric Security Audit Logger (`SecurityAuditLogger.swift`)**: Built-in persistent structured audit trail (`~/.facelock/audit_log.jsonl`) recording biometric verifications, intruder alerts, PIN unlock attempts, Touch ID authorizations, walk-away locks, and protection toggles.
- **Audit Log CLI Management (`--audit`, `--audit-stats`, `--clear-audit`, `--export-audit`)**: Added comprehensive CLI commands and JSON export tools to inspect, monitor, export, and purge security audit events.
- **PIN Brute-force Defense & Temporary Lockout**: Implemented consecutive failed PIN attempt tracking with configurable cooldown lockout in `LockScreenController` to prevent brute-force attacks.
- **PIN Brute-Force Intruder Snapshots & Alerting (`--set-pin-attempts`, `--set-pin-lockout`)**: Automatically captures an intruder photo and dispatches an instant Telegram alert when repeated failed PIN unlock attempts occur at the lock shield, accompanied by configurable cooling lockout and dynamic UI countdown.
- **Settings GUI Controls for PIN Protection & Audit Log**: Added interactive sliders for failed PIN attempt limits (1-10) and cooldown delays (1-60s) in Section 5 of `SettingsWindow`, along with direct navigation to the Security Audit Log and Incident Gallery.
- **Atomic Persistence & Daemon Live Synchronization**: Enforced atomic writes across facial vector saves and audit log exports, with automatic distributed IPC reload signals to ensure background daemons instantly reflect changes.
- **Biometric Vector Dataset Optimization (`--optimize-vectors`)**: Implemented statistical outlier filtering and redundancy pruning to optimize facial template cluster compactness while preserving biometric accuracy.
- **Lock Screen State Telemetry (`--is-locked`)**: Added CLI command to query active lock shield state offline or via daemon with `--json` support and shell exit codes (0 = locked, 1 = unlocked).
- **Incident Telemetry & Summary CLI (`--incidents-summary`, `--incident-summary`)**: Added telemetry CLI with full `--json` support displaying total captures, storage footprint in MB, past 24-hour count, today's count, past 7-day count, and oldest/newest timestamps.
- **Targeted Incident Export CLI (`--export-incident <filename> <destPath>`)**: Added CLI command to export any specific intruder incident photo to a destination path, complementing `--export-latest-incident`.
- **Status & Diagnostics Security Metrics**: Enhanced `facelock --status` and `facelock --diagnostics` (including their `--json` modes) with past 24-hour incident counters, anti-spoofing liveness status, and latest incident timestamps.
- **Telegram Reporter Audit & Telemetry**: Updated `scripts/telegram_report.sh` to include audit log volume and 24-hour incident statistics in automated Telegram status dispatches.
- **Makefile Automation & Test Coverage**: Added `make is-locked`, `make optimize-vectors`, `make export-incidents`, `make audit`, `make audit-stats`, `make clear-audit`, `make incidents-summary`, and `make incidents-summary-json` targets, and expanded `make test` verification.

## [1.0.6] - 2026-10-24

### Added
- **Lock Screen Face ID Retry Button**: Added an on-demand "Повторить Face ID" biometric retry button on the fullscreen lock shield in `LockScreenController`, enabling instant camera facial verification without requiring Touch ID hardware or manual PIN typing.
- **Fast User Switching & macOS Session Security Hardening**: Added `NSWorkspace.sessionDidResignActiveNotification` and `NSWorkspace.sessionDidBecomeActiveNotification` observers in `AppMonitor` to immediately invalidate active verification sessions upon user switching or logout.
- **Session Cache Invalidation CLI & Distributed IPC (`--reset-session`)**: Added `--reset-session` CLI flag (with `--json` support) and distributed IPC broadcast (`reset-session`) to clear verification debounce caches in running daemons.
- **Biometric Template Cluster Metrics CLI (`--vectors`)**: Added `--vectors` (and `--vectors --json`) CLI flags to inspect enrolled facial template vectors, embedding dimensionality (128-d Apple Neural Vision faceprints), pairwise cosine distance distribution (min, avg, max, standard deviation), cluster tightness score, and dataset file metadata.
- **Diagnostics Suite Vector Clustering**: Integrated detailed vector cluster statistics into `Diagnostics.run()` (and `--diagnostics --json`).
- **Autonomous Catalog Watcher & PR Status Tracking**: Enhanced `telegram_report.sh` to extract comments on closed catalog PRs (detecting 15-star minimum requirements on `awesome-swift` PR #2007) with automated REST API fallback on GraphQL timeouts and added notification in `autonomous_worker.sh` when the repository reaches 15 stars.
- **Makefile Enhancements**: Added `make vectors`, `make vectors-json`, and `make reset-session` targets, along with automated CLI tests in `make test`.

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
