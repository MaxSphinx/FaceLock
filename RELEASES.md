# FaceLock Releases & Version History

All official releases, binary assets, and detailed update breakdowns for **FaceLock** are documented here.

Official pre-compiled application archives are automatically published to [GitHub Releases](https://github.com/MaxSphinx/FaceLock/releases) on every version tag.

---

## [v1.0.0] — Initial Production Release (2026-10-20)

> **Headline**: Initial stable release of FaceLock — High-performance native biometric shield and intruder defense system for macOS Apple Silicon.

### 📦 Binary Assets
- **Download**: [`FaceLock-macOS-arm64.zip`](https://github.com/MaxSphinx/FaceLock/releases/download/v1.0.0/FaceLock-macOS-arm64.zip)
- **Architecture**: Apple Silicon (`arm64` — M1, M2, M3, M4 series)
- **Minimum OS**: macOS 14.0 (Sonoma) or macOS 15.0+ (Sequoia)
- **Dependencies**: Pure native AppKit & Vision (Zero external libraries)

---

### 🌟 Release Highlights

#### 1. Deep Neural Biometrics (Apple Vision ANFRv4)
- Leverages Apple's native deep faceprint neural network (`VNCreateFaceprintRequest`).
- Extracts 128-dimensional L2-normalized biometric vectors running directly on the Apple Neural Engine (ANE).
- **Dual-Verification Cluster Metric**:
  - Requires candidate face to satisfy both $d_{\min} \le 0.22$ and $\text{top3\_avg} \le 0.27$.
  - Completely eliminates false acceptances on strangers while maintaining instant verification for the owner.

#### 2. Unbypassable Security Shield (`.screenSaver` Level)
- Enforces a fullscreen dark glassmorphic security overlay at `CGWindowLevelForKey(.screenSaverWindow)`.
- Blocks hotkey escapes (<kbd>Cmd+Q</kbd>, <kbd>Cmd+W</kbd>, <kbd>Cmd+M</kbd>, <kbd>Cmd+H</kbd>, <kbd>Esc</kbd>).
- Audio and tactile feedback on authentication attempts (`NSSound.beep()` on error, `Glass` click on unlock).
- Biometric Touch ID or master PIN fallback.

#### 3. Low-Light Intruder Snapshot & Night-Mode Lift
- Automatic face cropping with generous 80% shoulder headroom.
- CoreImage hardware pipeline applying real-time exposure lift (+1.3 EV), shadow recovery, and tone curve equalization.
- Intruder faces remain crisp and identifiable even in dark rooms.

#### 4. Instant Telegram Bot Alerts
- Multi-part HTTPS multipart/form-data upload of intruder photographs directly to your personal Telegram chat.
- Includes formatted HTML caption with timestamp and targeted application name.

#### 5. Walk-Away Inactivity Lock
- Monitors user input inactivity via `CGEventSource`.
- After 45 seconds of no keyboard/mouse events, FaceLock silently samples the camera. If you stepped away, the Mac locks immediately.

#### 6. Universal & Selective Vault Modes
- **All Applications**: Continuous biometric protection on every window focus switch.
- **Selective Mode**: Guards only confidential apps (Telegram, Safari, Chrome, Terminal, Notes, Photos, WhatsApp, etc.).

#### 7. First-Class CLI & Automation
- Interactive flags: `--enroll`, `--settings`, `--gallery`, `--test-lock`, `--status`, `--update`, `--version`, `--help`.
- Automated sync engine (`make commit`, `make update`, `scripts/sync-daemon.sh`).

---

## How to Update

### Method 1: Built-in Self-Updater (Recommended)
```bash
facelock --update
```

### Method 2: Via Git & Make
```bash
cd FaceLock
make update
```

### Method 3: Download Binary Release
1. Download `FaceLock-macOS-arm64.zip` from [Releases](https://github.com/MaxSphinx/FaceLock/releases).
2. Unzip and drag `FaceLock.app` into your `/Applications/` folder.

---

## Release Process for Maintainers

To publish a new official release:

```bash
# Example: cut release v1.1.0
make release VERSION=1.1.0 MSG="Feature release: proximity unlock & stats"
```
This automatically tags the commit, updates the changelog, and triggers GitHub Actions to build and publish the `.zip` binary archive to GitHub Releases.
