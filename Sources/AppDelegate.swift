import AppKit
import AVFoundation

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static let commandNotificationName = NSNotification.Name("io.github.facelock.command")

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Handle command-line arguments
        let args = CommandLine.arguments

        if args.contains("--help") || args.contains("-h") {
            print("""
            FaceLock - Biometric Application Shield for macOS

            USAGE:
              facelock [options]

            OPTIONS:
              --enroll                   Launch camera face enrollment wizard
              --settings                 Open configuration and alert settings
              --gallery                  Open intruder incident log gallery
              --incidents [--json]       List logged intruder incident captures
              --clear-incidents          Purge all saved intruder photo captures from disk
              --lock, --test-lock        Trigger immediate fullscreen lock screen
              --toggle                   Toggle protection between ACTIVE and PAUSED
              --pause [mins]             Pause protection for N minutes (default: 15)
              --resume                   Resume protection immediately
              --config [--json]          Display active FaceLock configuration
              --apps [--json]            List protected and ignored application bundle IDs
              --protect-app <bundleId>   Add application bundle ID to protected list
              --unprotect-app <bundleId> Remove application bundle ID from protected list
              --set-threshold <val>      Set similarity threshold (0.05 - 0.60, default: 0.22)
              --set-mode <mode>          Set mode: 'all' (every app) or 'selective' (secret apps)
              --diagnostics, -d [--json] Run complete biometric & hardware system diagnostics
              --status [--json]          Print current daemon status and vector metrics
              --test-telegram            Dispatch a verification alert to configured Telegram chat
              --reset                    Purge all enrolled facial vectors
              --update                   Check GitHub for updates, pull, recompile & reload
              --version, -v              Print version information
              --help, -h                 Show this help guide
            """)
            exit(0)
        }

        if args.contains("--version") || args.contains("-v") {
            print("FaceLock v1.0.0 (darwin-arm64)")
            exit(0)
        }

        if args.contains("--diagnostics") || args.contains("-d") {
            Diagnostics.run(jsonOutput: args.contains("--json"))
            exit(0)
        }

        // Inter-process command dispatching if instance is already running
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        let isAlreadyRunning = !runningApps.isEmpty

        if args.contains("--status") {
            let enrolledCount = Config.shared.loadEnrolledVectors().count
            if args.contains("--json") {
                let statusDict: [String: Any] = [
                    "version": "1.0.0",
                    "daemon": isAlreadyRunning ? "running" : "stopped",
                    "shieldState": Config.shared.isEnabled ? "active" : "paused",
                    "protectionMode": Config.shared.protectionMode,
                    "enrolledTemplates": enrolledCount,
                    "similarityThreshold": Double(Config.shared.similarityThreshold),
                    "walkAwayLockEnabled": Config.shared.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": Config.shared.walkAwayIdleSeconds,
                    "telegramEnabled": Config.shared.telegramEnabled
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: statusDict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("""
            FaceLock Status:
              Daemon: \(isAlreadyRunning ? "RUNNING" : "STOPPED")
              Shield: \(Config.shared.isEnabled ? "ACTIVE" : "PAUSED")
              Mode: \(Config.shared.protectionMode)
              Enrolled Templates: \(enrolledCount) (\(enrolledCount > 0 ? "Strict Neural Biometrics" : "Presence Detection Fallback"))
              Decision Threshold: \(Config.shared.similarityThreshold)
              Walk-Away Auto Lock: \(Config.shared.walkAwayLockEnabled ? "Enabled (\(Int(Config.shared.walkAwayIdleSeconds))s)" : "Disabled")
              Telegram Notifications: \(Config.shared.telegramEnabled ? "Configured" : "Disabled")
            """)
            exit(0)
        }

        if args.contains("--config") {
            let config = Config.shared
            if args.contains("--json") {
                let configDict: [String: Any] = [
                    "similarityThreshold": Double(config.similarityThreshold),
                    "verificationTimeout": config.verificationTimeout,
                    "debounceSeconds": config.debounceSeconds,
                    "isEnabled": config.isEnabled,
                    "strictFaceMatch": config.strictFaceMatch,
                    "protectionMode": config.protectionMode,
                    "walkAwayLockEnabled": config.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": config.walkAwayIdleSeconds,
                    "telegramEnabled": config.telegramEnabled,
                    "livenessDetectionEnabled": config.livenessDetectionEnabled,
                    "autoTriggerTouchID": config.autoTriggerTouchID,
                    "protectedAppsCount": config.protectedBundleIdentifiers.count,
                    "ignoredAppsCount": config.ignoredBundleIdentifiers.count,
                    "hasEnrolledFace": config.hasEnrolledFace
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: configDict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("""
            FaceLock Configuration:
              Protection State: \(config.isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")
              Protection Mode: \(config.protectionMode)
              Decision Threshold: \(config.similarityThreshold)
              Verification Timeout: \(config.verificationTimeout)s
              Switch Debounce: \(config.debounceSeconds)s
              Walk-Away Auto Lock: \(config.walkAwayLockEnabled ? "Enabled (\(Int(config.walkAwayIdleSeconds))s idle)" : "Disabled")
              Anti-Spoofing Liveness: \(config.livenessDetectionEnabled ? "Enabled" : "Disabled")
              Touch ID Fallback: \(config.autoTriggerTouchID ? "Enabled" : "Disabled")
              Telegram Alerts: \(config.telegramEnabled ? "Enabled" : "Disabled")
              Protected Apps: \(config.protectedBundleIdentifiers.count) applications
              Enrolled Face Vectors: \(config.loadEnrolledVectors().count) templates
            """)
            exit(0)
        }

        if args.contains("--apps") {
            let config = Config.shared
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "mode": config.protectionMode,
                    "protectedApps": config.protectedBundleIdentifiers,
                    "ignoredApps": config.ignoredBundleIdentifiers
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("FaceLock Protected Applications (Mode: \(config.protectionMode)):")
            for app in config.protectedBundleIdentifiers {
                print("  • \(app)")
            }
            print("\nIgnored System Applications:")
            for app in config.ignoredBundleIdentifiers {
                print("  - \(app)")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--protect-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --protect-app <bundleId>")
                exit(1)
            }
            let config = Config.shared
            if !config.protectedBundleIdentifiers.contains(bundleId) {
                config.protectedBundleIdentifiers.append(bundleId)
                config.save()
                print("✓ Added '\(bundleId)' to protected applications list.")
            } else {
                print("ℹ️ '\(bundleId)' is already in protected applications list.")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--unprotect-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --unprotect-app <bundleId>")
                exit(1)
            }
            let config = Config.shared
            if let pos = config.protectedBundleIdentifiers.firstIndex(of: bundleId) {
                config.protectedBundleIdentifiers.remove(at: pos)
                config.save()
                print("✓ Removed '\(bundleId)' from protected applications list.")
            } else {
                print("ℹ️ '\(bundleId)' was not found in protected applications list.")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-threshold"), idx + 1 < args.count {
            if let val = Float(args[idx + 1]), val >= 0.05 && val <= 0.60 {
                Config.shared.similarityThreshold = val
                Config.shared.save()
                print("✓ Similarity decision threshold updated to \(val).")
                exit(0)
            } else {
                print("Error: Threshold must be a floating point value between 0.05 and 0.60.")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-mode"), idx + 1 < args.count {
            let mode = args[idx + 1].lowercased()
            if mode == "all" || mode == "selective" {
                Config.shared.protectionMode = mode
                Config.shared.save()
                print("✓ Protection mode updated to '\(mode)'.")
                exit(0)
            } else {
                print("Error: Mode must be either 'all' or 'selective'.")
                exit(1)
            }
        }

        if args.contains("--incidents") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            var totalBytes: UInt64 = 0
            var incidentsData: [[String: Any]] = []

            for f in files {
                let p = dir.appendingPathComponent(f).path
                var sz: UInt64 = 0
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
                   let s = attrs[.size] as? UInt64 {
                    sz = s
                    totalBytes += s
                }
                incidentsData.append([
                    "filename": f,
                    "path": p,
                    "sizeBytes": sz
                ])
            }

            if args.contains("--json") {
                let outputDict: [String: Any] = [
                    "totalCaptures": files.count,
                    "totalSizeBytes": totalBytes,
                    "directory": dir.path,
                    "incidents": incidentsData
                ]
                if let d = try? JSONSerialization.data(withJSONObject: outputDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
            print("""
            FaceLock Intruder Incident Log:
              Total Captures: \(files.count) (\(String(format: "%.2f", sizeMB)) MB)
              Storage Directory: \(dir.path)
            """)
            if files.isEmpty {
                print("  ✓ No intruder events logged.")
            } else {
                print("  Recent Captures (latest \(min(5, files.count))):")
                for f in files.prefix(5) {
                    print("    - \(f)")
                }
            }
            exit(0)
        }

        if args.contains("--clear-incidents") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            var deletedCount = 0
            var freedBytes: UInt64 = 0

            if let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
                let jpegs = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                for f in jpegs {
                    let p = dir.appendingPathComponent(f).path
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
                       let sz = attrs[.size] as? UInt64 {
                        freedBytes += sz
                    }
                    if (try? FileManager.default.removeItem(atPath: p)) != nil {
                        deletedCount += 1
                    }
                }
            }

            if args.contains("--json") {
                let outDict: [String: Any] = [
                    "success": true,
                    "deletedCount": deletedCount,
                    "freedSizeBytes": freedBytes,
                    "directory": dir.path
                ]
                if let d = try? JSONSerialization.data(withJSONObject: outDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let freedMB = Double(freedBytes) / (1024.0 * 1024.0)
            print("[FaceLock] Cleared \(deletedCount) intruder captures (\(String(format: "%.2f", freedMB)) MB freed) from \(dir.path).")
            exit(0)
        }

        if args.contains("--test-telegram") {
            let token = Config.shared.telegramBotToken.trimmingCharacters(in: .whitespacesAndNewlines)
            let chatId = Config.shared.telegramChatId.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !token.isEmpty && !chatId.isEmpty else {
                if args.contains("--json") {
                    let errDict: [String: Any] = [
                        "success": false,
                        "error": "Telegram Bot Token or Chat ID not configured in ~/.facelock/config.json"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: errDict, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Telegram Bot Token or Chat ID is not configured.")
                    print("To configure, open 'facelock --settings' or edit ~/.facelock/config.json.")
                }
                exit(1)
            }

            if !args.contains("--json") {
                print("[FaceLock] Dispatching verification alert to Telegram (chat: \(chatId))...")
            }
            var done = false
            var testSuccess = false
            var testMessage = ""

            TelegramNotifier.shared.sendTestMessage(token: token, chatId: chatId) { success, msg in
                testSuccess = success
                testMessage = msg
                done = true
            }

            let timeoutDate = Date().addingTimeInterval(10.0)
            while !done && Date() < timeoutDate {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
            }

            if args.contains("--json") {
                let outDict: [String: Any] = [
                    "success": testSuccess,
                    "chatId": chatId,
                    "message": testMessage
                ]
                if let d = try? JSONSerialization.data(withJSONObject: outDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                if testSuccess {
                    print("✓ Telegram test notification successfully sent to chat \(chatId)!")
                } else {
                    print("⚠️ Telegram test notification failed: \(testMessage.isEmpty ? "Request timed out" : testMessage)")
                }
            }
            exit(testSuccess ? 0 : 1)
        }

        if args.contains("--update") {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            proc.arguments = ["pull", "--rebase", "origin", "main"]
            try? proc.run()
            proc.waitUntilExit()

            print("[FaceLock] Rebuilding latest binary...")
            let buildProc = Process()
            buildProc.executableURL = URL(fileURLWithPath: "/usr/bin/make")
            buildProc.arguments = ["install"]
            try? buildProc.run()
            buildProc.waitUntilExit()
            exit(0)
        }

        if args.contains("--reset") {
            Config.shared.clearEnrolledVectors()
            print("[FaceLock] Cleared all enrolled faces.")
        }

        if let pauseIdx = args.firstIndex(of: "--pause") {
            var mins = 15.0
            if pauseIdx + 1 < args.count, let val = Double(args[pauseIdx + 1]) {
                mins = val
            }
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "pause", "minutes": mins],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched pause command (\(Int(mins)) min) to running instance.")
            } else {
                Config.shared.isEnabled = false
                Config.shared.save()
                print("[FaceLock] Protection paused offline.")
            }
            exit(0)
        }

        if args.contains("--resume") || args.contains("--unpause") {
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "resume"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched resume command to running instance.")
            } else {
                Config.shared.isEnabled = true
                Config.shared.save()
                print("[FaceLock] Protection resumed: ACTIVE 🛡️")
            }
            exit(0)
        }

        if isAlreadyRunning {
            if args.contains("--toggle") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "toggle"],
                    deliverImmediately: true
                )
                print("[FaceLock] Sent toggle signal to running instance.")
                exit(0)
            } else if args.contains("--lock") || args.contains("--test-lock") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "lock"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched lock command to running instance.")
                exit(0)
            } else if args.contains("--settings") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "settings"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched settings command to running instance.")
                exit(0)
            } else if args.contains("--enroll") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "enroll"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched enrollment command to running instance.")
                exit(0)
            } else if args.contains("--gallery") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "gallery"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched gallery command to running instance.")
                exit(0)
            } else if !args.contains("--reset") {
                print("[FaceLock] Instance is already running in background (PID: \(runningApps.first?.processIdentifier ?? 0)).")
                print("Use 'facelock --settings' to configure or 'facelock --diagnostics' for checks.")
                exit(0)
            }
        }

        // Handle offline toggle if daemon is not currently active
        if args.contains("--toggle") {
            Config.shared.isEnabled.toggle()
            Config.shared.save()
            print("[FaceLock] Toggled protection state: \(Config.shared.isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")")
            exit(0)
        }

        // Request camera permission if needed
        checkCameraAuthorization()

        // Setup distributed IPC listener
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleDistributedCommand(_:)),
            name: AppDelegate.commandNotificationName,
            object: nil
        )

        // Setup UI and Monitors
        StatusBarController.shared.setup()
        AppMonitor.shared.start()
        WalkAwayMonitor.shared.start()

        if args.contains("--enroll") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                EnrollmentController.shared.show()
            }
        } else if args.contains("--test-lock") || args.contains("--lock") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                LockScreenController.shared.showLock()
            }
        } else if args.contains("--settings") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SettingsController.shared.show()
            }
        } else if args.contains("--gallery") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                IncidentGalleryController.shared.show()
            }
        } else {
            // First run check
            if !Config.shared.hasEnrolledFace {
                print("[FaceLock] Note: No face enrolled yet. Running in face detection mode.")
                print("[FaceLock] Open Menu Bar icon -> «Запомнить моё лицо» to train your specific face.")
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
        WalkAwayMonitor.shared.stop()
        AppMonitor.shared.stop()
        CameraScanner.shared.stop()
    }

    @objc private func handleDistributedCommand(_ notif: Notification) {
        guard let action = notif.userInfo?["action"] as? String else { return }
        DispatchQueue.main.async {
            switch action {
            case "settings":
                SettingsController.shared.show()
            case "enroll":
                EnrollmentController.shared.show()
            case "gallery":
                IncidentGalleryController.shared.show()
            case "lock", "test-lock":
                LockScreenController.shared.showLock()
            case "toggle":
                StatusBarController.shared.toggleEnabled()
            case "pause":
                let minutes = notif.userInfo?["minutes"] as? Double ?? 15.0
                StatusBarController.shared.pauseFor(minutes: minutes)
            case "resume":
                StatusBarController.shared.resumeProtection()
            default:
                break
            }
        }
    }

    private func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("[FaceLock] Camera permission granted.")
                } else {
                    print("[FaceLock] Camera permission denied.")
                }
            }
        case .denied, .restricted:
            print("[FaceLock] WARNING: Camera permission is denied/restricted in System Settings!")
        case .authorized:
            print("[FaceLock] Camera authorized.")
        @unknown default:
            break
        }
    }
}
