# Changelog

All notable changes to **FaceLock** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.6] - 2026-11-08

### Added
- **Diagnostic Doctor Expansion to 20 Comprehensive Checks (`Diagnostics.swift`)**:
  - Added `hardware.power_efficiency`: Evaluates whether battery-aware adaptive idle polling (`config.batteryAwareScanning`) is active to throttle camera sweeps on MacBook battery and Low Power Mode.
  - Added `security.presentation_suppression`: Evaluates whether meeting and presentation mode auto-suppression (`config.presentationModeSuppression`) is active across recognized meeting/presentation tools (Zoom, Meet, Keynote, PowerPoint, Webex, Teams, etc.) to prevent disruptive lockouts during conferences and slide decks.
- **Doctor Strict Mode Enforcement (`AppDelegate.swift`, `Makefile`)**:
  - Implemented `--doctor-strict` CLI mode designed for automated maintenance pipelines, CI/CD gates, and security compliance verification. Fails with non-zero exit code (1) if ANY warning or failure is detected.
  - Added CLI options `--doctor-strict` and `--doctor-strict --json` (with `--doctor-strict-json`, `--diag-doctor-strict-json`, `--check-doctor-strict-json`, `--strict-doctor-json`, `--diag-doctor-strict`, `--check-doctor-strict`, `--strict-doctor` aliases).
  - Added Makefile targets `make doctor-strict` and `make doctor-strict-json`.
- **Diagnostic Health Report Export Engine (`Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Diagnostics.exportDoctorReport(toPath:config:skipNetwork:)` allowing atomic JSON export of comprehensive health and security audit diagnostics (defaulting to `~/.facelock/doctor_report.json` with secure `0600` POSIX permissions, or to custom path).
  - Added CLI options `--doctor-export [path]` and `--doctor-export [path] --json` (with `--doctor-export-json`, `--export-doctor-json`, `--export-doctor` aliases).
  - Added Makefile targets `make doctor-export` and `make doctor-export-json`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV126Enhancements()` asserting 20+ doctor check items, strict mode verification logic, atomic doctor report export file integrity, version synchronization, and full CLI argument normalization matrix.
- **Version Bump to v1.2.6 (`Config.swift`, `Resources/Info.plist`)**:
  - Synchronized version string `1.2.6` across `Config.currentVersion` and macOS bundle `Info.plist`.

## [1.2.5] - 2026-11-08

### Added
- **Autonomous Doctor Health Auto-Repair Suite (`Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Diagnostics.runDoctorRepair(config:save:)` and `DoctorRepairReport` delivering automated, hands-off remediation for system and security issues:
    - *Filesystem Permissions*: Enforces strict `0700` POSIX permissions on `~/.facelock` to protect facial vectors and incident logs against local snooping.
    - *Cryptographic Audit Chain Repair*: Detects corrupted audit lines or chronological discrepancies and repairs the integrity chain (`SecurityAuditLogger.shared.repairAuditLog()`).
    - *Incident Dataset Recovery*: Detects truncated or invalid JPEG intruder photos and removes corrupted captures (`CameraScanner.shared.repairCorruptedIncidents()`).
    - *Disk Quota Enforcement*: Prunes oldest intruder captures exceeding 500MB budget to prevent disk exhaustion.
    - *Facial Biometric Cluster Optimization*: Removes template outliers and redundant vectors (`Config.shared.optimizeVectors()`).
    - *Security Posture Hardening*: Enforces essential defense policies (biometric shield activation, bystander defense, lock-on-wake, liveness anti-spoofing, 45s walk-away timeout, and PIN lockout exponential cooldown).
    - *Audit Telemetry*: Logs `doctor_repair_applied` event with full details in `SecurityAuditLogger`.
  - Added CLI options `--doctor-repair` and `--doctor-repair --json` (with `--doctor-repair-json`, `--doctor-fix`, `--doctor-fix-json`, `--repair-doctor`, `--repair-doctor-json` aliases).
  - Added Makefile targets `make doctor-repair`, `make doctor-repair-json`, `make doctor-fix`, `make doctor-fix-json`.
- **Diagnostic Doctor Diagnostic Expansion to 18 Checks (`Diagnostics.swift`)**:
  - Added `security.biometric_spoofing`: Evaluates neural anti-spoofing liveness verification state.
  - Added `security.shoulder_surfing`: Evaluates shoulder-surfing bystander defense readiness.
- **Audit Telemetry Metric Enrichment (`SecurityAuditLogger.swift`)**:
  - Added `doctorRepairs` metric counter to `SecurityAuditLogger.AuditSummary`.
- **Build Lock Self-Healing & Resilience (`build.sh`)**:
  - Implemented automatic stale lock recovery in `build.sh`: writes PID to `/tmp/facelock_build.lock/pid`, detects inactive PIDs or locks older than 60s, breaks stale locks, and sets robust traps on EXIT/INT/TERM/HUP.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV125Enhancements()` verifying 18+ doctor check items, `DoctorRepairReport` data structure and dictionary serialization, `runDoctorRepair()` execution, `AuditSummary.doctorRepairs` metric, and CLI argument normalizations.
- **Version Bump to v1.2.5 (`Config.swift`, `Resources/Info.plist`)**:
  - Synchronized version string `1.2.5` across `Config.currentVersion` and macOS bundle `Info.plist`.

## [1.2.4] - 2026-11-07

### Added
- **Autonomous System Health & Diagnostic Doctor Suite (`Diagnostics.swift`, `AppDelegate.swift`, `Makefile`, `scripts/telegram_report.sh`)**:
  - Implemented `Diagnostics.runDoctor()` evaluating 16 mission-critical system, biometrics, hardware, and security layers:
    - *Hardware & Sensors*: Apple Silicon (arm64) architecture verification, Apple Vision neural faceprint model availability (`VNCreateFaceprintRequest`), AVFoundation camera capture device detection, macOS TCC camera privacy authorization status, and LocalAuthentication Touch ID sensor presence.
    - *Filesystem & Cryptography*: Secure `~/.facelock` directory permissions (0700 enforcement), configuration schema validity (`Config.validateConfig()`), enrolled facial biometric template count & cluster quality, cryptographic SHA-256 audit log chain integrity (`SecurityAuditLogger.verifyAuditIntegrity()`), and intruder capture storage quota monitoring.
    - *Background Daemon & Automation*: Real-time background shield daemon process detection (`io.github.facelock`) and autonomous maintainer LaunchAgent service installation verification.
    - *Security Posture & Hardening*: Master unlock PIN security check (default PIN warning), anti-coercion silent duress PIN check, and comprehensive security posture rating (Grade A-F).
    - *Remote Alerting & Network*: Telegram bot token, chat ID configuration, and live gateway reachability check to `api.telegram.org`.
  - Introduced `DoctorCheckStatus` (`PASS`, `WARN`, `FAIL`, `INFO`) with badges, `DoctorCheckItem`, and `DoctorReport` with structured status breakdown (`HEALTHY`, `WARNING`, `CRITICAL`), check statistics, and deduplicated actionable remediation recommendations.
  - Added CLI options `--doctor` and `--doctor --json` (with `--doctor-json`, `--diag-doctor-json`, `--check-doctor-json`, `--doctor-check-json`, `--diag-doctor`, `--check-doctor`, `--doctor-check` normalizations).
  - Added Makefile targets `make doctor` and `make doctor-json`.
  - Added real-time Doctor diagnostic status badge (`DOCTOR_STATUS`) to the 24/7 autonomous Telegram status reporter (`scripts/telegram_report.sh`).
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV124Enhancements()` verifying 16+ comprehensive doctor checks, status badges, dictionary and JSON serialization, simulated degradation (critical failure & warning handling), and CLI argument normalizations.
- **Version Bump to v1.2.4 (`Config.swift`, `Resources/Info.plist`)**:
  - Synchronized version string across `Config.currentVersion` and macOS bundle `Info.plist`.

## [1.2.3] - 2026-11-07

### Added
- **Autonomous Security Hardening & Remediation Engine (`Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Diagnostics.autoHardenSecurity()` auto-remediating security vulnerabilities: re-engaging paused shield, enabling shoulder-surfing bystander defense, enabling lock-on-wake, activating battery-aware adaptive polling, turning on meeting/presentation suppression, enabling deep neural liveness anti-spoofing, tightening walk-away timeouts to 45s, enforcing PIN brute-force attempt and cooling lockout limits, repairing corrupted captures, optimizing biometric cluster cohesion, and logging audit telemetry.
  - Added CLI options `--harden` (with `--auto-harden`, `--harden-security`, `--harden-json`, `--auto-harden-json` normalizations).
  - Added Makefile targets `make harden`, `make harden-json`, `make auto-harden`, `make auto-harden-json`.
- **Centralized Component Version Synchronization (`Config.swift`, `AppDelegate.swift`, `Resources/Info.plist`)**:
  - Introduced `Config.currentVersion` ("1.2.3") ensuring unified, synchronized version reporting across `--version`, `--version --json`, `--status`, `--status --json`, `--health --json`, and macOS `Info.plist` bundle metadata.
- **Silent Duress Emergency PIN & Anti-Coercion Protocol Suite (`Config.swift`, `LockScreenWindow.swift`, `TelegramNotifier.swift`, `SecurityAuditLogger.swift`, `Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Config.duressPin` and anti-coercion validation (`Config.isValidDuressPin(_:masterPin:)`) allowing users to designate a secondary 4-8 digit numeric PIN for physical or psychological duress situations.
  - Implemented silent emergency distress flow on lock screen (`LockScreenWindow.swift`):
    - Smoothly unlocks the display without alert beeps, audio cues, or visual warnings so the coercer remains unaware that a distress signal was initiated.
    - Concurrently triggers silent camera snapshot via `CameraScanner.shared.scanFace(timeout: 1.5)` saving photo with `duress_` prefix.
    - Immediately dispatches high-urgency distress alert to Telegram via `TelegramNotifier.shared.sendDuressAlert()` with HTML formatting and application context.
    - Records security audit event `duress_pin_unlocked` in `SecurityAuditLogger.shared`.
  - Added `duressPinUnlocks` counter to `SecurityAuditLogger.AuditSummary`.
  - Added CLI commands `--set-duress-pin <pin>`, `--clear-duress-pin`, and `--duress-status` with full `--*-json` normalization.
  - Integrated `duressDefense` status telemetry into `Diagnostics.assessSecurityPosture()` breakdown.
- **Intruder Photo Disk Budgeting & Megabyte Storage Quota Pruning (`CameraScanner.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `CameraScanner.pruneIncidentsByDiskQuota(maxBytes:)` and `CameraScanner.pruneIncidentsByMegaBytes(maxMB:)` safely pruning oldest intruder captures to keep disk footprint within allocated storage quotas.
  - Added CLI options `--prune-incidents-quota <MB>` and `--prune-incidents-quota-json <MB>` as aliases for `--prune-incidents-size`.
- **Custom Meeting & Presentation Application Whitelist Suite (`Config.swift`, `WalkAwayMonitor.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented dynamic registration of custom meeting and presentation application bundle identifiers (`customPresentationBundleIdentifiers`) with strict bundle ID validation, deduplication against built-in catalog apps, and persistent storage in `config.json`.
  - Extended `WalkAwayMonitor.isPresentationActive(bundleId:)` to recognize user-registered meeting applications alongside the built-in 33-app presentation catalog for intelligent walk-away lock auto-suppression.
  - Added CLI options `--add-meeting-app <bundleId>` (with `--add-presentation-app` alias), `--remove-meeting-app <bundleId>` (with `--remove-presentation-app` alias), `--reset-meeting-apps`, and `--custom-meeting-apps` with full `--*-json` normalizations.
  - Added Makefile targets `add-meeting-app APP=`, `add-meeting-app-json APP=`, `remove-meeting-app APP=`, `remove-meeting-app-json APP=`, `reset-meeting-apps`, `reset-meeting-apps-json`, `custom-meeting-apps`, and `custom-meeting-apps-json`.
- **Makefile & CLI Workflow Automation (`Makefile`)**:
  - Added Makefile targets `set-duress-pin PIN=`, `set-duress-pin-json PIN=`, `clear-duress-pin`, `clear-duress-pin-json`, `duress-status`, `duress-status-json`, `prune-incidents-quota MB=`, `prune-incidents-quota-json MB=`.
  - Updated `make help` with duress defense and storage quota documentation.
  - Integrated verification of all new CLI commands and JSON outputs into `make test`.
- **Autonomous Status & Telegram Reporter Enrichment (`scripts/telegram_report.sh`)**:
  - Added real-time Security Posture Rating, Threat Intelligence Level, and Duress Defense status badges to autonomous Telegram status reports.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV123Enhancements()` covering valid/invalid duress PINs, master PIN collision rejection, duress enable/clear state, audit log summary tracking, duress Telegram caption escaping, storage quota pruning, posture breakdown integration, and CLI argument normalizations.

## [1.2.2] - 2026-11-06

### Added
- **Physical Security Threat Intelligence & Intrusion Risk Engine (`SecurityAuditLogger.swift`, `Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `SecurityAuditLogger.analyzeThreatIntelligence()` and `ThreatIntelligenceReport` assessing physical attack vectors and calculating real-time intrusion risk scores (0-100 scale):
    - Attack Vector Breakdown: PIN brute-force attempts, shoulder-surfing snooping captures, unrecognized intruder photos, walk-away locks, and wake locks.
    - Velocity Tracking: Event frequency tracking in past 24 hours and past 7 days.
    - 24-Hour Temporal Distribution: Bucketing incidents across 0..23 hours and identifying `peakThreatHour`.
    - Targeted Application Profiling: Tracking targeted apps (`Terminal`, `Keychain Access`, `Safari`, `System Settings`, etc.) categorized by sensitivity risk (`CRITICAL`, `HIGH`, `MEDIUM`).
    - Anomaly Pattern Recognition: `PIN_BRUTEFORCE_DETECTED`, `HIGH_VELOCITY_INTRUSIONS`, `PERSISTENT_SHOULDER_SURFING`, `OFF_HOURS_ACCESS_ATTEMPT`, and `PRIVILEGED_TARGET_ACCESS`.
    - Context-Aware Actionable Mitigations: Dynamic recommendations to harden defense profiles, tighten timeouts, enable bystander shield, or configure Telegram alerts.
  - Added CLI options `--threat-intel` and `--risk-level` (supporting `--threat-intel-json`, `--threat-intelligence-json`, `--risk-level-json` normalizations).
  - Enriched `Diagnostics.collectReport()` with `"threatIntelligence"` telemetry and added Section `[9] Physical Threat Intelligence & Intrusion Risk` to `Diagnostics.run()`.
- **Configuration Security & Syntax Validation Suite (`Config.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Config.validateConfig()` and `ConfigValidationReport` performing deep validation:
    - Master PIN compliance (4-8 digits) and default PIN warning (`0000`, `1234`).
    - Similarity threshold bounds (0.05 - 0.50) and loose threshold warnings.
    - Timer bounds (verification timeout, debounce interval, walk-away idle, PIN lockout cooling).
    - Application policy validation: CFBundleIdentifier syntax checking, duplicate detection, and protected/ignored collision warnings.
    - Telegram gateway credentials validation (token format, chat ID).
  - Added CLI options `--validate-config` and `--check-config` (with `--validate-config-json` and `--check-config-json`).
  - Added Section `[10] Configuration Integrity & Security Validation` to `Diagnostics.run()`.
- **Makefile & CLI Workflow Automation (`Makefile`)**:
  - Added Makefile targets `threat-intel`, `threat-intel-json`, `risk-level`, `risk-level-json`, `validate-config`, `validate-config-json`, `check-config`, `check-config-json`.
  - Updated `make help` with documentation for threat intelligence and validation targets.
  - Added verification of all new flags into `make test`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV122Enhancements()` covering clean baseline telemetry, critical threat scoring, anomaly detection, off-hours access, targeted app ranking, configuration validation, and CLI argument normalizations.

## [1.2.1] - 2026-11-07

### Added
- **Cryptographic Security Audit Log Integrity & Tamper Verification Suite (`SecurityAuditLogger.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `SecurityAuditLogger.verifyAuditIntegrity()` and `AuditIntegrityReport` performing end-to-end audit validation:
    - Calculates live SHA-256 cryptographic digest of `audit_log.jsonl` using Apple `CryptoKit`.
    - Detects unparseable/corrupted JSON lines and records line indices.
    - Validates chronological monotonicity of event timestamps to detect timestamp tampering or system clock rollback anomalies (`WARNING_CHRONOLOGY`).
    - Validates event types against canonical security event taxonomy (`SecurityAuditLogger.knownEventTypes`).
    - Evaluates health status (`VERIFIED`, `WARNING_CHRONOLOGY`, `CORRUPTED_DETECTED`, `EMPTY`).
  - Implemented `SecurityAuditLogger.repairAuditLog()` creating an atomic timestamped `.bak` backup copy, pruning corrupted/malformed JSON records, and rewriting clean JSONL events.
  - Added CLI options `--audit-integrity` (with `--check-audit` alias), `--repair-audit` (with `--clean-corrupted-audit` alias), and `--audit-digest` (with `--audit-checksum` alias) supporting structured JSON telemetry (`--*-json`).
  - Integrated audit log integrity into `Diagnostics.collectReport()` (`auditIntegrity` dictionary) and `Diagnostics.run()` storage report with SHA-256 fingerprint attestation.
  - Extended `Diagnostics.assessSecurityPosture()` with -5 point penalty and actionable remediation advice (`"Run 'facelock --repair-audit'"`) upon detected audit corruption.
- **Makefile & Build Workflow Enhancements (`Makefile`, `build.sh`)**:
  - Added Makefile targets `audit-integrity`, `audit-integrity-json`, `check-audit`, `check-audit-json`, `repair-audit`, `repair-audit-json`, `audit-digest`, `audit-digest-json`.
  - Linked `-framework CryptoKit` in `build.sh` for Apple Silicon cryptographic hashing acceleration.
  - Integrated CLI verification of audit integrity flags into `make test`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Added `testMaintenanceV121Enhancements()` validating clean audit verification, chronology anomaly detection, corrupted record repair with backup creation, security posture deduction, diagnostics dictionary integration, and CLI argument normalization aliases.

## [1.2.0] - 2026-11-06

### Added
- **Comprehensive Mac Security Posture & Hardening Assessment Suite (`Diagnostics.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Diagnostics.assessSecurityPosture()` and `SecurityPostureReport` evaluating the end-to-end security hardening of macOS and FaceLock on a 100-point scale:
    - Shield Active (15 pts): Active vs paused state validation.
    - Master PIN Hardening & Lockout (15 pts): Evaluates non-default PIN, length (6+ digits bonus), and brute-force cooling lockout rules.
    - Biometric Vector Density & Cohesion (20 pts): Enrolled templates count (3-5+ templates) and multi-angle cluster cohesion score ($S_{cohesion} \ge 0.70$).
    - Walk-Away Defense (10 pts): Auto-lock enabled with strict idle timeout threshold ($\le 60\text{s}$).
    - Shoulder-Surfing Defense (10 pts): Bystander detection and secondary face snooping monitor.
    - Neural Liveness & Anti-Spoofing (10 pts): Deep neural anti-spoofing verification.
    - Screen Wake Clamshell Lock (5 pts): Instant biometric lock on Mac display / lid wake.
    - Battery-Aware Adaptive Polling (5 pts): Adaptive sweep throttling via live IOKit power status.
    - Remote Telegram Gateway (5 pts): Instant intrusion alerting via configured Telegram bot.
    - Intruder Integrity Audit Penalty (-5 pts penalty applied if corrupted captures exist).
  - Categorizes security posture into actionable grades (`A+` 90-100 EXCELLENT, `A` 80-89 HARDENED, `B` 70-79 STANDARD, `C` 55-69 MODERATE, `D` <55 VULNERABLE).
  - Dynamically synthesizes prioritized actionable recommendations to harden system security.
  - Added CLI options `--security-score` and `--posture` (with `--security-score-json`, `--posture-json`, `--posture-score-json` normalizations).
  - Enriched `Diagnostics.collectReport()` with structured `"securityPosture"` dictionary.
  - Enriched human-readable `Diagnostics.run()` with Section `[8] Security Posture & Hardening Assessment`.
- **Presentation & Meeting Mode Telemetry Suite (`WalkAwayMonitor.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `WalkAwayMonitor.presentationCatalog` cataloging 33 popular macOS presentation, meeting, streaming, recording, communication, and media player applications (Keynote, PowerPoint, Freeform, Zoom Meetings/Rooms, Teams, Webex, Telemost, Google Meet, Slack, Discord, Skype, OBS Studio, Loom, AnyDesk, TeamViewer, QuickTime, VLC, IINA, FaceTime, etc.).
  - Implemented `WalkAwayMonitor.checkPresentationStatus(bundleId:) -> [String: Any]` inspecting target application or frontmost window, checking for active macOS display sleep assertions (`IOPMCopyAssertionsByProcess`), and determining lock suppression status.
  - Added CLI commands `--presentation-apps` (with `--meeting-apps` alias and `--presentation-apps-json`) and `--check-presentation [bundleId]` (with `--check-presentation-json`).
- **Makefile & CLI Workflow Automation (`Makefile`)**:
  - Added Makefile targets `security-score`, `security-score-json`, `posture`, `posture-json`, `presentation-apps`, `presentation-apps-json`, `meeting-apps`, `meeting-apps-json`, `check-presentation APP=`, `check-presentation-json APP=`.
  - Updated `make help` with documentation for new posture assessment and meeting telemetry targets.
  - Integrated verification of all new CLI commands and JSON outputs into `make test`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Expanded automated test suite across 35 test suites covering hardened 100/100 score verification, degraded configuration scoring, corrupted capture penalty deduction, actionable recommendation synthesis, presentation catalog enumeration, meeting application detection, and CLI argument normalizations.

## [1.1.9] - 2026-11-06

### Added
- **Biometric Template Drift & Consistency Analysis (`Config.swift`, `AppDelegate.swift`)**:
  - Implemented `Config.analyzeTemplateConsistency(vectors:) -> [String: Any]` calculating cluster centroid, medoid template index, intra-cluster dispersion, cohesion score (0.0 to 1.0), and angle/pose diversity score.
  - Added intelligent enrollment status classification (`OPTIMAL`, `ADEQUATE`, `DISPERSE`, `REDUNDANT`, `SINGLE_SAMPLE`, `EMPTY`) with actionable advice for multi-angle biometric calibration.
  - Added CLI command `--vector-consistency` (with `--analyze-vectors` alias and `--*-json` normalization) presenting rich ANSI status cards and structured JSON telemetry.
- **Intruder Capture Integrity Verification & Corrupted Photo Repair (`CameraScanner.swift`, `AppDelegate.swift`)**:
  - Implemented `CameraScanner.isImageHeaderValid(data:)` with magic byte validation for JPEG (`0xFF 0xD8 0xFF`) and PNG (`0x89 0x50 0x4E 0x47`) formats.
  - Implemented `CameraScanner.verifyIncidentsIntegrity()` and `IncidentIntegrityReport` identifying truncated captures, 0-byte photos, non-image files, and directory size metrics.
  - Implemented `CameraScanner.repairCorruptedIncidents()` to safely purge corrupted and zero-byte incident captures while preserving valid security intruder photos.
  - Added CLI options `--incidents-integrity` (with `--check-incidents` alias) and `--repair-incidents` (with `--clean-corrupted-incidents` alias and full `--*-json` support).
- **Security Audit Analytical Digest & Success Rate Metrics (`SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Implemented `SecurityAuditLogger.AuditSummary` struct and `SecurityAuditLogger.getAuditSummary()` calculating active logging duration, biometric verification success rate, fallback breakdown (PIN, Touch ID), security alert distribution (shoulder surfing, emergency lockdown, PIN bruteforce), and top challenged applications.
  - Added CLI command `--audit-summary` (with `--audit-summary-json` normalization) for real-time audit digest and application challenge frequency analysis.
- **Diagnostics Report Enrichment (`Diagnostics.swift`)**:
  - Enriched `Diagnostics.collectReport()["storage"]` with live `templateConsistency` and `incidentsIntegrity` dictionaries for autonomous monitoring.
- **Bundle Identifier Validation Suite & Hardened App Controls (`Config.swift`, `AppDelegate.swift`, `Makefile`)**:
  - Implemented `Config.isValidBundleIdentifier(_:)` strictly validating Apple reverse-DNS CFBundleIdentifier specifications: character constraints (alphanumeric, dots, hyphens, underscores), length (1-255), and rejecting CLI flag injection (e.g. `--json`).
  - Hardened `--protect-app`, `--unprotect-app`, `--ignore-app`, `--unignore-app`, and `--check-app` with safe argument parsing via `valueForOption` and structured JSON error responses.
  - Added CLI flag normalizations: `--protect-app-json`, `--unprotect-app-json`, `--ignore-app-json`, `--unignore-app-json`, and `--check-app-json`.
  - Added Makefile targets `check-app-json`, `protect-app-json`, `unprotect-app-json`, `ignore-app-json`, and `unignore-app-json`.
- **Makefile & CLI Workflow Automation (`Makefile`)**:
  - Added Makefile targets `vector-consistency`, `vector-consistency-json`, `incidents-integrity`, `incidents-integrity-json`, `check-incidents`, `check-incidents-json`, `repair-incidents`, `repair-incidents-json`, `audit-summary`, `audit-summary-json`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 660 unit tests across 34 specialized test suites with 100% pass rate, covering bundle identifier validation, image header magic byte verification, incident integrity scanning, corrupted capture repair, biometric cluster cohesion, medoid index computation, audit analytical digest aggregation, and CLI argument normalizations.

## [1.1.8] - 2026-11-05

### Added
- **Hardened PIN Validation Suite & Structured CLI Setters (`Config.swift`, `AppDelegate.swift`)**:
  - Wired `--set-pin <pin>` to strict validation using `Config.isValidPin(pin)` ensuring 4-8 numeric digits, returning structured JSON responses (`{"success":true,"message":"Lock screen PIN updated","pinLength":N}` and `{"success":false,"error":...}`).
  - Wired `--set-pin-attempts <count>` to `Config.isValidPinAttempts(count)` with structured error reporting in JSON mode.
  - Wired `--set-pin-lockout <sec>` to `Config.isValidPinLockout(sec)` with structured error reporting in JSON mode.
  - Handled missing argument scenarios cleanly with JSON errors across `--set-pin`, `--set-pin-attempts`, `--set-pin-lockout`, and `--verify-pin`.
  - Added CLI flag normalizations: `--pin-attempts` -> `--set-pin-attempts`, `--pin-attempts-json` -> `["--set-pin-attempts", "--json"]`, `--pin-lockout` -> `--set-pin-lockout`, `--pin-lockout-json` -> `["--set-pin-lockout", "--json"]`, `--set-pin-json` -> `["--set-pin", "--json"]`.
- **Safe Incident Deletion & Single Incident Export (`CameraScanner.swift`, `AppDelegate.swift`)**:
  - Implemented `CameraScanner.deleteIncident(filename:) -> (success: Bool, freedBytes: UInt64, error: String?)` with strict basename sanitization and extension checks (.jpg, .jpeg, .png) preventing path traversal.
  - Implemented `CameraScanner.exportIncident(filename:to:) throws -> (source: String, destination: String, sizeBytes: UInt64)` with basename sanitization and directory resolution.
  - Hardened `CameraScanner.getIncidentDetails(filename:)` with basename sanitization.
  - Replaced raw filesystem calls in `--delete-incident`, `--export-incident`, and `--incident` in `AppDelegate.swift` with the unified, safe `CameraScanner` methods.
- **Structured Security Audit Telemetry (`SecurityAuditLogger.swift`, `AppDelegate.swift`, `Diagnostics.swift`)**:
  - Implemented `SecurityAuditLogger.AuditStats` struct with `todayCount`, `past24HoursCount`, and `toDictionary()` representation.
  - Implemented `SecurityAuditLogger.getAuditStats() -> AuditStats` calculating live date-based frequency metrics.
  - Enhanced `--audit-stats` output (both JSON and human-readable) with `todayCount` and `past24HoursCount`.
  - Enriched `Diagnostics.collectReport()` storage dictionary with full `incidentStats` dictionary and `daemon` dictionary with `maxFailedPinAttempts` and `pinLockoutSeconds`.
- **Makefile & CLI Workflow Automation (`Makefile`)**:
  - Added Makefile targets `pin-attempts-json ATTEMPTS=`, `pin-lockout-json SECONDS=`, `set-pin PIN=`, `set-pin-json PIN=`.
  - Documented new targets in `make help`.
  - Added CLI verification checks for the new targets in `make test`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 585 unit tests across 32 specialized test suites with 100% pass rate, covering incident deletion, incident export, audit statistics telemetry, diagnostics report enrichment, and CLI normalizations.

## [1.1.7] - 2026-11-05

### Added
- **Configuration Validation Suite & Safe Setters (`Config.swift`, `AppDelegate.swift`)**:
  - Added dedicated static validation methods in `Config.swift`: `isValidThreshold`, `isValidTimeout`, `isValidDebounce`, `isValidPin`, `isValidWalkAwayTimeout`, `isValidProtectionMode`, `isValidPinAttempts`, and `isValidPinLockout`.
  - Hardened CLI setters `--set-threshold`, `--set-timeout`, `--set-debounce`, `--set-mode`, `--set-walkaway` with strict validation boundaries and structured JSON responses (both success and error formats).
- **Incident Search & Detailed Inspection (`CameraScanner.swift`, `AppDelegate.swift`)**:
  - Implemented `CameraScanner.matchesIncidentQuery(filename:query:)` and `CameraScanner.searchIncidents(query:filterType:limit:)` supporting substring and classification keyword queries.
  - Added `CameraScanner.IncidentRecord` structure and `CameraScanner.getIncidentDetails(filename:)`.
  - Added CLI options `--incidents-search <query>` (with aliases `--search-incidents`, `--incident-search`, and `--incidents --query <text>`).
  - Enriched `--latest-incident` and `--incident <filename>` outputs with typed classification (`intruder`, `walkaway`, `wake`, `bystander`, `bruteforce`) across JSON and formatted text modes.
  - Extended `CameraScanner.IncidentStats` and `--incidents-summary` with `largestIncidentFilename` and `largestIncidentSizeBytes` telemetry.
- **Age-Based Incident & Audit Retention (`CameraScanner.swift`, `SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Implemented `CameraScanner.pruneIncidentsOlderThan(days:)` enabling automated purging of intruder photos older than specified retention windows with freed byte calculation.
  - Implemented `SecurityAuditLogger.pruneLogs(olderThanDays:)` enabling atomic pruning of audit log events by age while preserving newer security audit entries.
  - Added CLI options `--prune-incidents-days <days>` and `--prune-audit-days <days>` (with `--prune-logs-days` alias and `--json` support).
- **Operational Healthcheck Telemetry Enrichment (`AppDelegate.swift`)**:
  - Enriched `--health` and `--health --json` reporting with engine version (`1.1.7`), active profile identifier, total incidents count, 24-hour incidents count, and total security audit events count.
- **CLI Normalization & Makefile Automation (`Makefile`, `AppDelegate.swift`)**:
  - Added argument normalizations for `--incidents-search-json`, `--search-incidents-json`, `--incident-search-json`, `--set-threshold-json`, `--set-timeout-json`, `--set-debounce-json`, `--set-mode-json`, `--set-walkaway-json`.
  - Added Makefile targets `make incidents-search QUERY=`, `make incidents-search-json QUERY=`, `make set-threshold THRESHOLD=`, `make set-timeout TIMEOUT=`, `make set-debounce DEBOUNCE=`, `make set-mode MODE=`, and `make set-walkaway SECONDS=`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 554 unit tests (up from 451) across 31 specialized test suites with 100% pass rate, covering the configuration validation suite, incident query matching, detailed incident records, and CLI normalizations.

## [1.1.6] - 2026-11-05

### Added
- **Centralized Incident Telemetry & Selective Purging (`CameraScanner.swift`, `AppDelegate.swift`)**:
  - Implemented `CameraScanner.IncidentStats` structure and `CameraScanner.getDetailedIncidentStats()` reporting comprehensive telemetry (`totalCaptures`, `totalSizeBytes`, `averageSizeBytes`, storage directory, `todayCount`, `past24HoursCount`, `past7DaysCount`, timestamps, and classification `typeBreakdown`).
  - Added selective incident purging via `CameraScanner.clearIncidents(filterType:)` with case-insensitive validation and alias support (`shoulder`, `shoulder_surfing`, `all`).
  - Extended CLI `--incidents-summary` (and `--incidents-summary --json`) with typed classification telemetry and average capture size metrics.
  - Enhanced CLI `--clear-incidents` with `--type <category>` (and `--clear-incidents-type-json`).
- **Security Audit Log Search & Multi-Field Querying (`SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Implemented `SecurityAuditLogger.matchesQuery(event:query:)` and `SecurityAuditLogger.searchEvents(query:filterType:tail:)` enabling case-insensitive keyword searches across `eventType`, `appName`, `bundleId`, `details`, and `intruderPhoto`.
  - Added CLI `--audit-search <query>`, `--search-audit`, `--audit --query <text>`, and normalized `--audit-search-json`.
- **CLI Normalization & Makefile Automation (`Makefile`, `AppDelegate.swift`)**:
  - Added CLI flag normalization for `--audit-search-json`, `--search-audit-json`, `--search-audit`, and `--clear-incidents-type-json`.
  - Added Makefile targets `make clear-incidents-type TYPE=`, `make clear-incidents-type-json TYPE=`, `make audit-search QUERY=`, and `make audit-search-json QUERY=`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 451 unit tests (up from 417) across 29 specialized test suites with 100% pass rate, covering incident telemetry calculations, selective typed clearing, multi-field audit event search matching, and CLI normalizations.

## [1.1.5] - 2026-11-05

### Added
- **Multi-Format Security Audit Log Export (`SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Implemented multi-format audit log export supporting standard JSONL (`jsonl`), formatted JSON array (`json`), and RFC-4180 compliant CSV (`csv`) with automatic field escaping (`SecurityAuditLogger.escapeCSVField`).
  - Added format verification via `SecurityAuditLogger.supportedExportFormats` and `SecurityAuditLogger.isValidExportFormat(_:)`.
  - Added audit log category filtering during export via `--filter` / `--type` parameter mapped through `SecurityAuditLogger.matchesEventFilter(event:filter:)`.
  - Extended CLI `--export-audit` and `--export-logs` with `--format <jsonl|json|csv>`, `--csv`, and `--type <category>`.
- **Intruder Incident Archive Filtering (`CameraScanner.swift`, `AppDelegate.swift`)**:
  - Enhanced `CameraScanner.exportIncidents(to:filterType:)` to filter incident exports by classification type (`intruder`, `walkaway`, `wake`, `bystander`, `bruteforce`).
  - Updated CLI `--export-incidents <dir> [--type <type>]` with structured telemetry reporting and audit trail logging.
- **CLI Flag Normalization & Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added CLI flag normalization for `--export-audit-csv`, `--export-logs-csv`, `--export-audit-array`, and `--export-logs-array`.
  - Added dedicated Makefile targets `make export-audit-csv FILE=` and `make export-audit-csv-json FILE=` with `.PHONY` declarations.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 417 unit tests (up from 395) across 28 specialized test suites with 100% pass rate, covering CSV/JSON export formats, RFC-4180 escaping, format validation, incident type filtering during export, and CLI normalization.

## [1.1.4] - 2026-11-04

### Added
- **Security Audit Telemetry & Event Category Validation (`SecurityAuditLogger.swift`)**:
  - Added `SecurityAuditLogger.supportedEventFilters` enumerating 16 supported filter categories (`face`, `intruder`, `lock`, `pin`, `touchid`, `shield`, `policy`, `config`, `vectors`, `incidents`, `telegram`, `shoulder`, `profile`, `emergency`, `success`, `failure`).
  - Added `SecurityAuditLogger.isValidEventFilter(_:)` with case-insensitive validation and alias mapping (e.g. `biometrics`, `touch_id`, `alerts`, `lockdown`, `settings`, etc.).
  - Added `SecurityAuditLogger.getDetailedLogStats()` calculating comprehensive security metrics (`totalEvents`, `fileSizeBytes`, `lastEventTime`, `successCount`, `failureCount`, and `typeBreakdown`).
- **Audit Stats CLI Enrichment & Argument Normalization (`AppDelegate.swift`, `Makefile`)**:
  - Enriched `--audit-stats` (and `--audit-stats --json`) with breakdown of successful vs failure/alert events, top event types distribution, and comprehensive typed metrics.
  - Added CLI argument normalization for `--log-stats-json` and `--log-stats`.
  - Added Makefile targets `make log-stats` and `make log-stats-json` with `.PHONY` declarations.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 395 unit tests (up from 364) across 28 specialized test suites with 100% pass rate, adding dedicated coverage for audit filter validation, log telemetry integrity, and CLI flag normalization.
- **Incident Manifest Type Metadata & Breakdown Telemetry (`CameraScanner.swift`)**:
  - Enhanced `CameraScanner.exportIncidents(to:)` to attach typed classification (`intruder`, `walkaway`, `wake`, `bystander`, `bruteforce`) to each manifest record and compute a comprehensive `typeBreakdown` summary.
  - Added `CameraScanner.supportedIncidentTypes` and `CameraScanner.isValidIncidentType(_:)` with case-insensitive validation and whitespace trimming resilience.
- **Security Profile Resolution & String Normalization (`Config.swift`)**:
  - Added `Config.profile(named:)` safely mapping string identifiers to `SecurityProfile` with whitespace trimming and case normalization.
  - Hardened `Config.isValidProfile(_:)` and `Config.setProfile(_:)` against leading/trailing whitespace inputs.
- **CLI Flag Normalization & Extended Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added argument normalization for `--toggle-battery`, `--toggle-battery-json`, `--toggle-shoulder`, `--toggle-presentation-mode`, `--presentation-mode-json`, and `--export-incidents-json`.
  - Added Makefile targets `make toggle-shoulder-json`, `make toggle-audible-json`, `make toggle-battery-json`, `make toggle-presentation-json`, `make toggle-liveness`, `make toggle-liveness-json`, `make toggle-touchid`, `make toggle-touchid-json`, `make toggle-wake-json`, `make toggle-walkaway`, `make toggle-walkaway-json`, and `make export-incidents-json DIR=`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 364 unit tests (up from 345) across 27 specialized test suites with 100% pass rate, adding coverage for incident manifest type telemetry, supported type validation, whitespace-resilient profile resolution, and expanded toggle CLI flag normalization.
- **Incident Management Ergonomics, Type Classification & Slicing (`CameraScanner.swift`, `AppDelegate.swift`, `IncidentGalleryWindow.swift`)**:
  - Implemented `CameraScanner.incidentType(for:)` mapping capture prefixes (`bystander_`, `walkaway_`, `wake_`, `bruteforce_`, `intruder_`) into structured classification types.
  - Enhanced CLI `--incidents` with `--filter` / `--type` and `--tail` / `--limit` pagination, enriching JSON outputs with typed classification and ISO-8601 timestamp metadata.
  - Refined `IncidentGalleryController.parseDateFromFilename` with universal prefix stripping across all capture kinds.
  - Added automatic parent directory creation resilience to single incident photo exports (`--export-latest-incident` and `--export-incident`).
- **Incident CLI Aliases & Extended Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added argument normalization for `--export-latest-incident-json`, `--export-incident-json`, `--incident-json`, `--delete-incident-json`, and `--profiles-json`.
  - Added Makefile targets `make health-json`, `make profiles-json`, `make latest-incident-json`, `make export-latest-incident DEST=`, `make export-latest-incident-json DEST=`, `make incident FILE=`, `make incident-json FILE=`, `make delete-incident FILE=`, and `make delete-incident-json FILE=`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 345 unit tests (up from 320) across 27 specialized test suites with 100% pass rate, covering incident type classification, gallery date parsing parity, incident slicing, single photo export directory creation, and flag normalization.
- **Biometric Vector Dimensionality Validation & Finite Checks (`Config.swift`)**:
  - Implemented `Config.isValidVector(_:)` ensuring enrolled and imported templates strictly adhere to 128 dimensions without NaN or Infinite floating-point values.
  - Added robust validation in `addEnrolledVector(_:)` and `importVectors(from:merge:)` preventing template corruption and downstream SIMD mathematical failures.
- **Biometric Template Purge Lifecycle & Typed Audit Logging (`Config.swift`, `SecurityAuditLogger.swift`, `AppDelegate.swift`)**:
  - Enhanced `Config.clearEnrolledVectors()` to return the exact count of purged biometric templates (`@discardableResult`).
  - Added typed `SecurityAuditLogger.logVectorsCleared(count:details:)` capturing `vectors_cleared` audit events.
  - Upgraded CLI `--clear-vectors` and `--reset` with structured `--json` output (`clearedCount`, `action`, `success`) and deterministic `exit(0)` lifecycle termination.
- **Vector Purge CLI Aliases & Makefile Targets (`AppDelegate.swift`, `Makefile`)**:
  - Added argument normalization for `--clear-vectors-json`, `--reset-vectors-json`, `--reset-json`, `--reset-vectors`, and `--reset`.
  - Added Makefile targets `make clear-vectors`, `make clear-vectors-json`, `make reset-vectors`, and `make reset-vectors-json`.
- **Automated Test Suite Expansion (`Tests/FaceLockTests.swift`)**:
  - Scaled automated test suite to 320 unit tests (up from 305) across 25 specialized test suites with 100% pass rate, verifying vector dimensionality validation, finite value constraints, purge metrics, and CLI normalization.

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
