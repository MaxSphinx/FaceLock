# Changelog

All notable changes to **FaceLock** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.4] - 2026-11-03

### Added
- **Biometric Vector & Audit Export Resilience (`Config.swift`, `SecurityAuditLogger.swift`)**:
  - Added automatic parent directory creation in `Config.exportVectors(to:)` and `SecurityAuditLogger.exportLogs(to:)` ensuring exports to deeply nested subdirectories succeed reliably.
  - Added `Config.backupVectors(to:)` and `Config.restoreVectors(from:merge:)` aliases alongside `SecurityAuditLogger.exportAudit(to:)`.
- **Typed PIN Brute-force Audit Event Logging (`SecurityAuditLogger.swift`, `LockScreenWindow.swift`)**:
  - Implemented `SecurityAuditLogger.logPinBruteforce(appName:attempts:lockoutSeconds:)` providing structured, typed audit logging for failed PIN lockout events.
- **Biometric Vector CLI Aliases & Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added CLI flag normalization for `--backup-vectors`, `--restore-vectors`, `--backup-vectors-json`, `--restore-vectors-json`, `--export-logs`, and `--prune-logs`.
  - Added Makefile targets `make export-vectors DEST=`, `make export-vectors-json DEST=`, `make backup-vectors`, `make backup-vectors-json`, `make import-vectors SRC=`, `make import-vectors-json SRC=`, `make restore-vectors`, `make restore-vectors-json`, `make export-audit-json FILE=`, `make export-logs`, and `make export-logs-json`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 305 unit tests (up from 287) across 24 specialized test suites with 100% pass rate, adding dedicated vector and audit export resilience verification.
- **Telegram PIN Brute-force Dedicated Alerting (`TelegramNotifier.swift`, `LockScreenWindow.swift`)**:
  - Implemented `formatPinBruteforceAlertCaption(attempts:appName:timestamp:lockoutSeconds:)` with HTML sanitization and structured Russian notifications.
  - Implemented unified `sendPinBruteforceAlert(photo:attempts:appName:lockoutSeconds:completion:)` supporting both photo snapshots and text fallback.
- **Security Profile Validation & Enumeration (`Config.swift`)**:
  - Added `Config.isValidProfile(_:)` with case-insensitive validation across all supported profiles.
  - Added `Config.allProfileNames` static property returning all available security profile identifier strings.
- **IPC GUI Window Dispatching JSON Ergonomics (`AppDelegate.swift`)**:
  - Added structured JSON confirmation output when `--settings`, `--enroll`, `--gallery`, `--audit-gui`, and `--apps-gui` commands are dispatched to a running FaceLock background daemon.
- **Extended CLI Argument Normalization & Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added flag normalization for `--audit-stats-json`, `--audit-gui-json`, `--apps-gui-json`, `--clear-audit-json`, `--clear-incidents-json`, `--test-telegram-json`, `--settings-json`, `--gallery-json`, `--enroll-json`, `--backup-config-json`, `--restore-config-json`, `--export-audit-json`, `--prune-incidents-json`, and `--verify-pin-json`.
  - Added Makefile targets `make audit-stats-json`, `make clear-audit-json`, `make clear-incidents-json`, `make test-telegram-json`, `make backup-config-json`, `make export-config-json`, `make restore-config-json`, and `make import-config-json`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 287 unit tests (up from 260) with 100% pass rate across 23 test suites, covering PIN brute-force alert escaping, profile validation, and expanded CLI aliases.

- **Config Export / Import CLI Ergonomics & Directory Resilience (`Config.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Added `--export-config` and `--import-config` aliases alongside `--backup-config` and `--restore-config`.
  - Added automatic parent directory creation in `Config.backupConfig(to:)` ensuring exports to nested subpaths succeed cleanly.
  - Added Makefile targets `make export-config DEST=` and `make import-config SRC=`.
- **Telegram Emergency Lockdown Alerting (`TelegramNotifier.swift`, `StatusBarController.swift`, `AppDelegate.swift`)**:
  - Implemented `sendLockdownAlert(reason:completion:)` and `formatLockdownAlertCaption(reason:timestamp:)` to dispatch instant high-priority alerts with HTML sanitization when emergency lockdown is engaged via CLI or menu bar.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 260 unit tests across 21 specialized test suites covering config export/import roundtrip, Telegram lockdown payload escaping, and CLI normalizers with 100% pass rate.
- **macOS Low Power Mode & Power-Constrained Throttling (`WalkAwayMonitor.swift`, `Diagnostics.swift`, `DiagnosticsWindow.swift`)**:
  - Integrated `ProcessInfo.processInfo.isLowPowerModeEnabled` and `WalkAwayMonitor.isPowerConstrained()` combining battery power and macOS Low Power Mode.
  - Automatically throttles background idle sweep interval to 10s and debounce to 45s whenever power is constrained.
  - Added live display of Power Source and Low Power Mode state in Diagnostics GUI card and telemetry dictionary.
- **Dedicated Power & Battery CLI Telemetry (`AppDelegate.swift`, `Makefile`)**:
  - Added CLI options `--battery-status` and `--power-status` with both formatted terminal summary and structured `--json` output.
  - Added aliases `--battery-status-json` and `--power-status-json` in argument normalizer.
  - Added Makefile targets `make battery-status` and `make battery-status-json`.
- **Security Audit Log Automated Quota Pruning (`SecurityAuditLogger.swift`)**:
  - Implemented `autoPruneIfNeeded()` to automatically check and prune audit log to the most recent 5,000 entries when file size exceeds 5MB.
  - Added `autoPruneLogs(maxBytes:keeping:)` with atomic write safety to prevent disk exhaustion.
- **Conferencing & Screen Sharing Auto-Suppression Expansion (`WalkAwayMonitor.swift`)**:
  - Expanded meeting bundle identifiers with RingCentral (`us.zoom.ringcentral`), AnyDesk (`com.anydesk.anydesk`, `com.anydesk.anydeskmac`), TeamViewer (`com.teamviewer.TeamViewer`), Screenleap (`com.screenleap.Screenleap`), Viber (`com.viber.osx`), Brave Google Meet PWA, and Edge Google Meet PWA.
- **Incident Gallery Classification & Filtering (`IncidentGalleryWindow.swift`)**:
  - Differentiated Shoulder-Surfing bystander captures (`bystander_*.jpg`) and unauthorized intruder captures (`intruder_*.jpg`) with tailored visual cards, color codes (orange vs red), and Russian/English status badges.
  - Added multi-criteria filter selector: "Все инциденты", "За последние 24ч", "За последние 7 дней", "Только подглядывания (Shoulder)", and "Только нарушители (Intruders)".
  - Fixed timestamp parsing for bystander filenames (`IncidentGalleryController.parseDateFromFilename`).
- **Telemetry & CLI Incident Classification (`AppDelegate.swift`)**:
  - Extended `--incidents` to support `--type <intruder|bystander>` filtering and added `"type"` attribute to each JSON incident capture entry.
  - Enriched `--incidents-summary` and `--incidents-summary-json` with distinct `intrudersCount` and `bystandersCount` metrics.
  - Added comprehensive JSON response support for `--pause`, `--resume`, `--toggle`, and `--lock` CLI commands (both daemon-connected and offline modes).
  - Expanded argument normalizer with `--toggle-json`, `--pause-json`, `--resume-json`, `--lock-json`, `--reload-json`, `--reset-session-json`, and `--profile-json`.
  - Added Makefile targets `make toggle-json`, `make pause`, `make pause-json`, `make resume`, `make resume-json`, `make lock-json`, `make reload-json`, `make reset-session-json`, and `make profile-json`.
  - Scaled automated test suite to 250 unit tests across 18 specialized test suites with 100% pass rate.
- **Protection Pause Management & Countdown Ergonomics (`StatusBarController.swift`)**:
  - Added interactive "Таймер паузы..." submenu with quick presets (15 мин, 30 мин, 1 час, 4 часа / Полдня).
  - Integrated live remaining pause minutes countdown in menu item header, status bar button tooltip (`~X мин осталось`), and added "+15 мин" extension button when paused.
- **Emergency Lockdown Trigger & Ergonomics (`AppDelegate.swift`, `LockScreenWindow.swift`, `StatusBarController.swift`, `Makefile`)**:
  - Added atomic `--lockdown` and `--emergency-lockdown` CLI flags and normalizer alias `--lockdown-json` to immediately engage maximum security profile and seal the screen.
  - Added Makefile targets `make lockdown` and `make lockdown-json`.
  - Added menu bar status item "🚨 Экстренная блокировка (Lockdown)..." (`Cmd+Shift+L`) with sound alert and HUD notice.
  - Added dedicated distributed IPC action `"lockdown"` to seamlessly lock the screen via running daemon.
  - Enhanced lock screen card to display tailored lockdown mode badge ("Режим Lockdown: Защита активна") when strict lockdown profile is active.
- **CLI Ergonomics & Profile Quick-Query Fallback (`AppDelegate.swift`)**:
  - Enhanced `--profile` / `--set-profile` so querying without an argument cleanly lists the active profile and all available profiles in formatted text or JSON without error.
- **Audit Log Categorization & Event Coverage Expansion (`SecurityAuditLogger.swift`, `AuditLogWindow.swift`, `AppDelegate.swift`)**:
  - Implemented `logEmergencyLockdown()` in `SecurityAuditLogger`.
  - Added dedicated audit log filters for "Подглядывание (Shoulder-Surfing)" and "Профили и Lockdown (Profiles & Lockdown)".
  - Added icon and badge support for `emergency_lockdown`, `shoulder_surfing_alert`, and `profile_switched` across CLI `--logs` and GUI `AuditLogWindow`.
- **Automated Test Suite Expansion to 201 Tests (`Tests/FaceLockTests.swift`)**:
  - Added test suites for Low Power Mode sensing, power-constrained sweep throttling, meeting & media playback bundle expansion, config dictionary serialization, audit log auto-pruning, incident capture classification, date parsing, emergency lockdown profile, and pause countdown math (201 passing tests, 100% reliability).

## [1.1.3] - 2026-11-01

### Added
- **Interactive Diagnostics & System Health GUI (`DiagnosticsWindow.swift`, `Makefile`, `StatusBarController.swift`)**:
  - Implemented standalone interactive `DiagnosticsWindow` accessible via Menu Bar, Makefile (`make diagnostics-gui`), and CLI (`facelock --diagnostics-gui`).
  - Displays real-time operational health checks: Apple Silicon architecture, daemon status, camera subsystem permissions, Vision Neural Engine availability, Touch ID biometrics, storage disk usage, and Telegram reachability.
  - Live refresh capability (`Cmd+R`), direct Finder shortcut to `~/.facelock`, and one-click JSON diagnostic report export.
  - Integrated "Диагностика и здоровье системы (Diagnostics)..." (`Cmd+D`) entry directly into the macOS menu bar status item.
- **Hardware-Accelerated SIMD Vector Math (`FaceprintExtractor.swift`)**:
  - Upgraded `FaceprintExtractor.cosineDistance` to use Apple Accelerate framework `vDSP` SIMD vector cosine similarity (`vDSP_dotpr` and `vDSP_svesq`), delivering hardware acceleration on Apple Silicon.
- **Lock Screen Ergonomics & Caps Lock Sensing (`LockScreenWindow.swift`)**:
  - Added dynamic Caps Lock indicator badge (`capslock.fill`) on the PIN authentication card responding in real-time to modifier flag changes via `flagsChanged`.
  - Added subtle audio cue reinforcement for PIN failure, lock engagement, and successful unlocks when audible alerts are enabled.
- **Shoulder-Surfing Defense Photo Capture & Telegram Alerting (`CameraScanner.swift`, `TelegramNotifier.swift`)**:
  - Integrated automatic photo capture for unauthorized secondary background faces (`bystander_*.jpg`).
  - Added dedicated Telegram notification dispatch (`sendBystanderAlert`) with 45s throttling debounce to alert owner in real-time of eavesdropping.
- **Lockdown Security Profile (`Config.swift`, `Tests/FaceLockTests.swift`)**:
  - Added 6th security profile `lockdown` featuring ultra-strict 5s walk-away timeout, 0.18 neural matching threshold, mandatory shoulder-surfing defense, lock-on-wake, and audible deterrents.
- **Meeting & Video Call Detection Expansion (`WalkAwayMonitor.swift`)**:
  - Added support for Skype, Yandex Telemost, OBS Studio, Loom, Freeform, QuickTime Player, and Chrome Google Meet app.
  - Linked `IOKit.pwr_mgt` and integrated `IOPMCopyAssertionsByProcess` to detect active display sleep assertions from presentation and playback software.
- **State Synchronization & IPC Enhancements (`Config.swift`, `AppDelegate.swift`, `StatusBarController.swift`)**:
  - Enhanced `Config.reload()` and `Config.restoreConfig()` to synchronize all runtime defense settings (`activeProfile`, `shoulderSurfingDefense`, `batteryAwareScanning`, `audibleAlerts`, and `presentationModeSuppression`) on hot-reload.
  - Added case-insensitive bundle identifier check helpers `Config.isProtected(bundleId:)` and `Config.isIgnored(bundleId:)`.
  - Extended distributed IPC command receiver (`handleDistributedCommand`) to support `diagnostics-gui`, `profile`, `toggle-shoulder`, `toggle-audible`, `toggle-battery`, and `toggle-presentation`.
- **Test Suite Expansion to 132 Tests (`Tests/FaceLockTests.swift`)**:
  - Expanded automated unit test suite from 74 to 132 passing tests (100% reliability), validating SIMD cosine distance parity, diagnostic report generation, config reload synchronization, bundle policy filtering, and CLI argument normalization.

## [1.1.2] - 2026-10-31

### Added
- **Meeting & Presentation Auto-Suppression Parity (`WalkAwayMonitor.swift`, `StatusBarController.swift`)**:
  - Exported `presentationBundleIdentifiers` set covering Keynote, PowerPoint, Zoom, Webex, Teams, FaceTime, Slack, and Discord.
  - Implemented standalone `WalkAwayMonitor.isPresentationActive(bundleId:)` supporting both frontmost workspace evaluation and explicit bundle querying.
  - Added "Подавление при звонках/презентациях: Вкл/Выкл" toggle into macOS menu bar status item with HUD feedback.
- **CLI Ergonomics & Diagnostic Parity (`AppDelegate.swift`, `Diagnostics.swift`, `Makefile`)**:
  - Added CLI flags `--toggle-presentation`, `--toggle-presentation-mode`, `--set-presentation-mode <on|off|toggle>`, and `--toggle-presentation-json`.
  - Added `--set-profile <name>` alias for direct profile switching from terminal scripts.
  - Integrated `activeProfile`, `shoulderSurfingDefense`, `batteryAwareScanning`, `audibleAlerts`, and `presentationModeSuppression` into `--diagnostics` (both text and JSON modes) and `--status` outputs.
  - Synchronized version string `1.1.2` across bundle `Info.plist`, CLI `--version`, and status telemetry.
  - Added Makefile target `make toggle-presentation`.
- **Test Suite Expansion to 70 Tests (`Tests/FaceLockTests.swift`)**:
  - Added automated test cases for presentation and meeting app identification, bundle suppression logic, feature flag state toggling, and presentation CLI alias normalization.

## [1.1.1] - 2026-10-30

### Added
- **Settings GUI Profile & Defense Parity (`SettingsWindow.swift`)**:
  - Integrated Security Context Profile selector with dynamic descriptive summary badge across all 5 profiles (`normal`, `cafe`, `work`, `home`, `presentation`).
  - Added GUI controls for Shoulder-Surfing bystander defense, battery-aware adaptive scanning, audible chimes, and presentation mode suppression.
  - Implemented responsive `NSScrollView` with flipped layout (`SettingsFlippedView`) ensuring ergonomic scrolling across all MacBook display sizes.
- **Hardware Battery-Aware Polling Integration (`WalkAwayMonitor.swift`, `build.sh`)**:
  - Linked macOS `IOKit` framework and implemented live power source sensing via `IOKit.ps` (`IOPSCopyPowerSourcesInfo` / `IOPSGetProvidingPowerSourceType`).
  - Adaptive 45s debounce and throttled idle polling when running on MacBook battery to maximize battery longevity.
  - Expanded meeting / presentation auto-suppression detection (Keynote, PowerPoint, Zoom, Teams, Webex, Slack Huddle).
- **CLI Ergonomics & Flag Normalization (`AppDelegate.swift`, `Makefile`)**:
  - Added `--set-audible <on|off|toggle>`, `--toggle-battery-aware`, and `--set-battery-aware <on|off|toggle>`.
  - Added JSON alias normalization for `--profiles-json`, `--toggle-shoulder-json`, `--toggle-audible-json`, and `--toggle-battery-aware-json`.
  - Updated `--help` output with detailed descriptions for profiles, shoulder defense, audible alerts, and battery awareness.
  - Added Makefile targets `make profiles`, `make profile PROFILE=`, `make toggle-shoulder`, `make toggle-audible`, `make toggle-battery`, and `make test`.
- **Test Suite Expansion to 61 Tests (`Tests/FaceLockTests.swift`)**:
  - Expanded automated unit tests to 61 passing test cases (100% reliability), verifying all 5 profiles, power management detection, audio alert configurations, and CLI argument normalization.

## [1.1.0] - 2026-10-30

### Added
- **Security Context Profiles (`Config.swift`, `StatusBarController.swift`, `AppDelegate.swift`)**:
  - Implemented 5 specialized security profiles:
    - `normal`: Balanced 45s walk-away, silent intruder capture, standard threshold (0.22).
    - `cafe`: Ultra-strict 10s walk-away, active shoulder-surfing defense, lock-on-wake, and audible alarm.
    - `work`: Confidential apps whitelist, 45s walk-away, Telegram notifications.
    - `home`: Relaxed 180s walk-away, friendly HUD, expanded tolerance (0.24).
    - `presentation`: Focus mode with automatic lock suppression during Keynote, Zoom, Meet, or full-screen gaming.
  - Added CLI management: `facelock --profiles [--json]` and `facelock --profile <name>`.
  - Added dedicated Menu Bar profile switcher submenu with live status indicators.
- **Shoulder-Surfing Bystander Defense (`CameraScanner.swift`, `HUDWindow.swift`, `SecurityAuditLogger.swift`)**:
  - Neural camera scans for secondary unauthorized bystander faces while owner is active in front of screen.
  - Dispatches discrete visual HUD alert (`⚠️ Внимание: лицо за спиной!`) and optional audible warning chimes.
  - Full structured audit trail recording (`shoulder_surfing_alert`).
  - Added CLI flag `facelock --toggle-shoulder-defense` and Menu Bar toggle.
- **Battery-Aware Adaptive Polling (`WalkAwayMonitor.swift`)**:
  - Dynamic power-source sensing (`IOPSGetProvidingPowerSourceType`) to conserve MacBook battery life by throttling idle camera sweeps when unplugged.
  - Presentation mode auto-suppression during slide decks or video meetings.
- **100% Automated Test Suite & Benchmarks (`Tests/FaceLockTests.swift`, `Makefile`, `.github/workflows/build.yml`)**:
  - Built-in zero-dependency test suite running 37 unit tests covering 128-D vector cosine distance, L2 normalization, centroid clustering, outlier detection, policy filtering, PIN lockout math, and HTML sanitization.
  - High-performance Apple Silicon benchmark executing 30,000 vector comparisons in 0.0004s (0.01 µs / comparison).
  - CLI command `facelock --test` and Makefile target `make test`.
  - Integrated into GitHub Actions CI workflow.
- **Audible Deterrent & Chime System (`HUDWindow.swift`, `AppDelegate.swift`)**:
  - Added system audio cues (`Funk`, `Basso`, `Tink`) for warnings, locks, and unlocks.
  - CLI toggle `facelock --toggle-audible`.
- **Autonomous Release Cadence (`scripts/autonomous_worker.sh`, `scripts/release.sh`)**:
  - Added autonomous release cut logic triggering periodic GitHub releases on meaningful commit milestones.

## [1.0.16] - 2026-10-30

### Added
- **Interactive Application Protection Policy Manager (`ApplicationsManagerWindow.swift`)**:
  - Designed and implemented a dedicated Application Protection Policy manager window accessible from Settings, Menu Bar, and CLI (`facelock --apps-gui`).
  - Segmented control to switch between **Защищаемые приложения** (Protected Apps) and **Игнорируемые системой** (Ignored System Apps) with dynamic count badges.
  - Real-time search field with keyboard shortcut `Cmd+F` for filtering applications by display name or bundle identifier.
  - App cards displaying native application icons (`NSWorkspace.shared.icon`), localized titles, bundle identifiers, and category badges.
  - One-click addition from running macOS applications via dynamic popup menu with running app icons and names.
  - Native macOS Finder integration (`NSOpenPanel`) to select applications directly from `/Applications`.
  - Manual Bundle ID entry dialog for custom and background processes.
  - One-click removal with immediate daemon hot-reloading (`AppDelegate.notifyDaemonReload`) and structured audit trail recording (`policy_changed`).
  - One-click policy reset to factory defaults with confirmation dialog.
- **Settings & Status Bar Menu Integration (`SettingsWindow.swift`, `StatusBarController.swift`)**:
  - Added "Настроить список приложений..." direct action button in Section 3 ("Режим проверки приложений") in Preferences.
  - Added "Политика приложений (Секретные: N)..." (`Cmd+P`) quick-access entry in the macOS menu bar status item.
- **CLI Commands & IPC Automation (`AppDelegate.swift`, `Config.swift`)**:
  - Added `facelock --apps-gui` (`--apps-window`) to launch the application rules manager window.
  - Added `facelock --reset-apps` (`--reset-apps-json`) command restoring factory default protection and ignore rules.
  - Added automated argument alias resolution for `--reset-apps-json`.
  - Enriched `Config` with `defaultProtectedBundleIdentifiers`, `defaultIgnoredBundleIdentifiers`, `localizedAppName(for:)`, `appIcon(for:size:)`, and policy reset helpers.
- **Makefile Automation & Test Expansion (`Makefile`)**:
  - Added `make apps-gui`, `make protect-app APP=`, `make unprotect-app APP=`, `make ignore-app APP=`, `make unignore-app APP=`, and `make reset-apps` targets.
  - Expanded `make test` CLI test suite with application policy addition, removal, and reset validations.

## [1.0.15] - 2026-10-30

### Added
- **Interactive Incident Pruning & Period Filtering (`IncidentGalleryWindow.swift`)**:
  - Added dedicated period filter dropdown in the Incident Gallery window: `Все инциденты (All)`, `За последние 24ч (24h)`, and `За последние 7 дней (7d)` with instant dynamic re-filtering.
  - Added interactive "Проредить..." (Prune Incidents) dialog allowing users to retain the latest 20, 10, or 5 snapshots and safely remove older intruder images to conserve disk space.
  - Integrated structured audit logging (`incidents_action`) recording files pruned directly from the GUI gallery.
- **Interactive Audit Log Pruning Dialog (`AuditLogWindow.swift`)**:
  - Added interactive "Проредить..." (Prune Audit) dialog in the Security Audit Log viewer, allowing one-click retention of the latest 100, 50, or 25 security audit records with live telemetry updates.
  - Added structured audit trail recording (`audit_pruned`) of GUI pruning operations.
- **macOS Window Ergonomics & Keyboard Shortcuts (`FaceLockUtilityWindow.swift`)**:
  - Created reusable `FaceLockUtilityWindow` standardizing keyboard ergonomics across accessory daemon windows:
    - `Escape` / `Cmd+W`: Cleanly close Settings, Incident Gallery, and Audit Log windows.
    - `Cmd+R`: Instantly trigger content refresh in Incident Gallery and Audit Log viewers.
- **Makefile Parametrization (`Makefile`)**:
  - Parameterized `make prune-incidents` with `KEEP=` flag support (`make prune-incidents KEEP=20`), defaulting to 30.

## [1.0.14] - 2026-10-30

### Added
- **Menu Bar Dynamic Camera Selection Submenu (`StatusBarController.swift`)**:
  - Integrated dynamic camera switching submenu directly into the macOS menu bar status menu (`Камера: <Active Camera>`).
  - Lists all discovered video capture devices (FaceTime HD, Apple Continuity Camera / iPhone, external webcams, Studio Displays) with real-time active checkmarks and `Авто (Системная по умолчанию)`.
  - Instantly reconfigures the live video capture pipeline, persists `preferredCameraID`, records structured security audit events, and displays visual HUD confirmation.
- **Lock Screen Keyboard Ergonomics & Biometric Hotkeys (`LockScreenWindow.swift`)**:
  - Added native keyboard shortcuts on the full-screen lock shield:
    - `Cmd+T`: Instantly trigger Touch ID biometric verification.
    - `Cmd+R` / `Cmd+F`: Trigger immediate Face ID re-scan without manual mouse navigation.
    - `Escape`: Clear PIN field input and reset error state.
  - Added informative tooltips on Face ID retry, Touch ID, and PIN input controls.
- **Dedicated Camera Reset CLI Command & Makefile Automation (`AppDelegate.swift`, `Makefile`)**:
  - Added `facelock --reset-camera` (`--reset-camera-json`) command to quickly restore default automatic camera discovery.
  - Added `make reset-camera` Makefile convenience target.
  - Expanded `make test` CLI test suite with camera reset verification.

## [1.0.13] - 2026-10-29

### Added
- **Multi-Camera Device Selection & Dynamic Hot-Switching (`CameraScanner.swift`, `Config.swift`)**:
  - Integrated hardware video capture discovery and selection supporting external webcams, Studio Displays, and Apple Continuity Camera (iPhone) alongside built-in FaceTime HD cameras.
  - Added persistent `preferredCameraID` property in configuration with graceful fallback to system default camera if preferred device is detached or unavailable.
  - Implemented dynamic video input re-anchoring (`reconfigureDeviceIfNeeded`) allowing background daemons to switch active capture streams seamlessly upon configuration reloads.
- **Dedicated Camera CLI Management & JSON Ergonomics (`AppDelegate.swift`)**:
  - Added `facelock --cameras` (`--cameras-json`) command listing all connected video capture devices, hardware IDs, and active/preferred badges (`[SELECTED & ACTIVE] ✅`, `[ACTIVE DEFAULT] 🎯`).
  - Added `facelock --set-camera <id|name|default>` enabling instant camera switching by hardware UUID, device name substring, index, or `'default'`.
  - Added structured audit trail event `preferredCameraID` in `audit_log.jsonl` whenever camera devices are changed.
- **Interactive Camera Selection in Settings UI (`SettingsWindow.swift`)**:
  - Added dedicated camera selection dropdown in Section 1 ("1. Статус защиты и камера FaceLock") displaying all detected cameras with device IDs.
  - Dispatches immediate IPC reload signal to running daemons upon dropdown selection.
- **Hardware Diagnostics & Makefile Targets Expansion (`Diagnostics.swift`, `Makefile`)**:
  - Diagnostics suite (`--diagnostics`, `--diagnostics-json`) now displays preferred vs active camera device, connection status, and selection state.
  - Added `make cameras`, `make cameras-json`, `make set-camera CAMERA=`, `make backup-config DEST=`, and `make restore-config SRC=` targets.
  - Expanded `make test` CLI test suite with camera device listing and selection validations.

## [1.0.12] - 2026-10-29

### Added
- **Status Bar Quick-Action Walk-Away Lock Toggle (`StatusBarController.swift`)**:
  - Integrated direct menu bar quick-toggle for Walk-Away auto-lock protection (`Авто-замок при уходе (Walk-Away): Вкл (45с) | Выкл`) with keyboard shortcut `Cmd+K`.
  - Dynamically displays active idle timeout in the dropdown title and emits real-time HUD notification and audit trail events on change.
- **Interactive Feature Toggles & Extended CLI Ergonomics (`AppDelegate.swift`)**:
  - Added dedicated CLI toggle flags and parameter normalization for all primary protection features: `--toggle-walkaway`, `--toggle-wake`, `--toggle-liveness`, and `--toggle-touchid`.
  - Supported `toggle` parameter for `--set-walkaway toggle`, `--set-liveness toggle`, and `--set-touchid toggle`.
  - Added automatic JSON alias resolution for `--toggle-walkaway-json`, `--toggle-wake-json`, `--toggle-liveness-json`, and `--toggle-touchid-json`.
- **Live IPC Synchronization in Preferences UI (`SettingsWindow.swift`)**:
  - Live preference sliders (`idleSlider`, `attemptsSlider`, `lockoutSlider`) and mode radio controls now immediately dispatch `io.github.facelock.command` IPC reload signals to active background daemons.
  - Changes take effect instantaneously across running daemon instances without requiring explicit modal window dismissal or manual daemon restart.
- **Dedicated Audit Maintenance Visual Badging & CLI Formatting (`AuditLogWindow.swift`, `AppDelegate.swift`)**:
  - Added specialized badge styling for audit management actions: `audit_cleared` ("🧹 Очистка аудита"), `audit_pruned` ("✂️ Ротация аудита"), and `audit_exported` ("📦 Экспорт аудита").
  - Extended CLI `--audit` log formatter with `🧹` icon for audit lifecycle operations.
- **Makefile `export-audit` Target & Test Suite Expansion (`Makefile`)**:
  - Added `make export-audit FILE=/path/to/destination.jsonl` target for easy security log archiving from the command line.
  - Expanded `make test` CLI test suite verifying feature toggle switches and telegram audit log filtering.

## [1.0.11] - 2026-10-29

### Added
- **Fallback Telegram Security Alerts on Camera-Obscured Lock Events (`AppMonitor.swift`, `WalkAwayMonitor.swift`)**:
  - Automatically dispatches structured Telegram text alerts whenever an unauthorized app switch, screen wake verification failure, or Walk-Away lock triggers while face photo capture is unavailable or obscured (e.g., closed camera shutter, zero ambient illumination, or transient sensor delay).
  - Guarantees immediate notification delivery to the owner regardless of physical camera obstructions.
- **Biometric Calibration Audit Logging & Distributed IPC Sync (`EnrollmentWindow.swift`)**:
  - Records structured security audit events (`vectors_enrolled` and `enrollment_cancelled`) upon successful 12-sample facial calibration or user cancellation.
  - Automatically posts distributed IPC reload notification (`io.github.facelock.reloadConfig`), propagating newly calibrated face vectors to running background daemons without requiring manual daemon restarts.
- **Cloud & Telegram Gateway Diagnostics (`Diagnostics.swift`)**:
  - Integrated live network gateway verification for `api.telegram.org` within `facelock --diagnostics` and machine-readable JSON output (`--diagnostics --json`).
  - Instantly surfaces DNS reachability status, connection timeouts, and proxy/firewall impediments.
- **Complete Telegram Photo Dispatch Failure Audit Trail (`TelegramNotifier.swift`)**:
  - Added audit logging (`telegram_alert_failed`) for multipart photo upload failures, capturing HTTP status codes and transport errors in `audit_log.jsonl`.
- **Audit Viewer Badging for Face Calibration & Enrollment (`AuditLogWindow.swift`, `SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Added dedicated visual badging and filter matching for biometric template enrollment events (`vectors_enrolled` 🧬, `enrollment_cancelled` 🧬⚠️).
  - Extended CLI `--audit` log formatter with contextual emoji representations for Telegram alerts and calibration actions.

## [1.0.10] - 2026-10-29

### Added
- **Direct `--*-json` CLI Flag Ergonomics & Strict Option Validation (`AppDelegate.swift`)**:
  - Implemented automatic argument normalization for all machine-readable JSON flags: `--status-json`, `--config-json`, `--health-json`, `--diagnostics-json`, `--vectors-json`, `--optimize-vectors-json`, `--incidents-summary-json`, `--incidents-json`, `--latest-incident-json`, `--is-locked-json`, `--audit-json`, `--apps-json`, and `--version-json`.
  - Added strict CLI option validation preventing typos or unrecognized flags from unintentionally launching or opening GUI settings.
- **Status Bar Security Audit Trail (`StatusBarController.swift`)**:
  - Added structured audit trail logging for menu bar protection mode switches, screen wake lock toggles, and biometric vector purges.
- **Multi-Face Candidate Prioritization & Foreground Sorting (`CameraScanner.swift`)**:
  - Dynamically sorts detected faces by bounding box area to prioritize prominent foreground faces sitting directly in front of the screen.
  - Sequentially verifies all candidate faces when multiple individuals appear in camera view (e.g. background passersby in shared spaces), eliminating false lockouts when the owner is present.
- **Vision Capture Quality Anti-Spoofing Assessment (`CameraScanner.swift`)**:
  - Integrates `VNDetectFaceCaptureQualityRequest` when anti-spoofing liveness detection is enabled, automatically filtering out blurry motion artifacts and planar screen glare.
- **Telegram Security Text Alerts & Camera-Obscured Fallbacks (`TelegramNotifier.swift`, `LockScreenWindow.swift`)**:
  - Added formatted text-only security alert dispatching (`sendSecurityAlert`) to Telegram.
  - Dispatches immediate Telegram security alerts during PIN brute-force attempts even when camera face capture is obscured or unrendered.
  - Automatically records Telegram alert dispatches and API statuses directly into the security audit log (`telegram_alert_sent` / `telegram_alert_failed`).
- **Audit Log GUI Telegram Filter & Status Badges (`AuditLogWindow.swift`)**:
  - Added dedicated Telegram notification filter and visual event badges (📲 Telegram оповещение, ⚠️ Сбой Telegram).

## [1.0.9] - 2026-10-27

### Added
- **Interactive Audit Log GUI Categories & Visual Badging (`AuditLogWindow.swift`)**:
  - Expanded filter popup with 4 dedicated categories: "Политика приложений (Policy)", "Настройки и конфигурация (Config)", "Векторы биометрии (Vectors)", and "Brute-force и блокировки (Lockouts)".
  - Added specialized badge titles, color coding, and critical alert styling for configuration modifications (⚙️ purple), application policy alterations (📋 indigo), biometric vector updates (🧬 teal), incident operations (📸 brown), brute-force defense events (🚫 red), and verification tests (🧪 green/red).
- **Settings GUI Audit Trail & Live Metrics (`SettingsWindow.swift`)**:
  - Integrated dual telemetry status displaying both audit log entries (count & KB size) and captured intruder snapshots.
  - Automatically records security audit events and dispatches distributed IPC reload signals to active background daemons whenever preferences or master shield toggles are modified via the Settings window.

### Fixed
- **Synchronous Audit Log Persistence & Orphaned File Cleanup (`SecurityAuditLogger.swift`)**:
  - Eliminated race condition where CLI commands exited before asynchronous log writes flushed to disk, ensuring all audit records are immediately committed to `audit_log.jsonl`.
  - Added automatic recovery of orphaned temporary file records (`audit_log.jsonl.sb-*`) on startup and sanitized temporary working files.
  - Granular filter matching across policy, configuration, vectors, and lockout events.
  - Extended CLI `--audit` output with contextual emojis for faster visual inspection in terminal workflows.

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
