# Changelog

All notable changes to **FaceLock** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
