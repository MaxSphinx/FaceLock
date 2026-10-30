import AppKit
import AVFoundation

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static let commandNotificationName = NSNotification.Name("io.github.facelock.command")

    public static func notifyDaemonReload() {
        DistributedNotificationCenter.default().postNotificationName(
            AppDelegate.commandNotificationName,
            object: nil,
            userInfo: ["action": "reload-config"],
            deliverImmediately: true
        )
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Handle command-line arguments and normalize --*-json alias flags
        var args: [String] = []
        for arg in CommandLine.arguments {
            switch arg {
            case "--status-json":
                args.append(contentsOf: ["--status", "--json"])
            case "--config-json":
                args.append(contentsOf: ["--config", "--json"])
            case "--health-json":
                args.append(contentsOf: ["--health", "--json"])
            case "--diagnostics-json":
                args.append(contentsOf: ["--diagnostics", "--json"])
            case "--vectors-json":
                args.append(contentsOf: ["--vectors", "--json"])
            case "--optimize-vectors-json":
                args.append(contentsOf: ["--optimize-vectors", "--json"])
            case "--incidents-summary-json":
                args.append(contentsOf: ["--incidents-summary", "--json"])
            case "--incidents-json":
                args.append(contentsOf: ["--incidents", "--json"])
            case "--latest-incident-json":
                args.append(contentsOf: ["--latest-incident", "--json"])
            case "--is-locked-json":
                args.append(contentsOf: ["--is-locked", "--json"])
            case "--audit-json":
                args.append(contentsOf: ["--audit", "--json"])
            case "--apps-json":
                args.append(contentsOf: ["--apps", "--json"])
            case "--version-json":
                args.append(contentsOf: ["--version", "--json"])
            case "--toggle-walkaway-json":
                args.append(contentsOf: ["--toggle-walkaway", "--json"])
            case "--toggle-wake-json":
                args.append(contentsOf: ["--toggle-wake", "--json"])
            case "--toggle-liveness-json":
                args.append(contentsOf: ["--toggle-liveness", "--json"])
            case "--toggle-touchid-json":
                args.append(contentsOf: ["--toggle-touchid", "--json"])
            case "--cameras-json":
                args.append(contentsOf: ["--cameras", "--json"])
            case "--reset-camera-json":
                args.append(contentsOf: ["--reset-camera", "--json"])
            case "--reset-apps-json":
                args.append(contentsOf: ["--reset-apps", "--json"])
            case "--profiles-json":
                args.append(contentsOf: ["--profiles", "--json"])
            case "--toggle-shoulder-json", "--toggle-shoulder-defense-json":
                args.append(contentsOf: ["--toggle-shoulder-defense", "--json"])
            case "--toggle-audible-json":
                args.append(contentsOf: ["--toggle-audible", "--json"])
            case "--toggle-battery-aware-json":
                args.append(contentsOf: ["--toggle-battery-aware", "--json"])
            case "--toggle-presentation-json", "--toggle-presentation-mode-json":
                args.append(contentsOf: ["--toggle-presentation", "--json"])
            default:
                args.append(arg)
            }
        }

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
              --incidents-summary [--json] Incident telemetry, time range & 24h count
              --incident <filename>      Inspect a specific logged intruder incident
              --delete-incident <file>   Delete a specific intruder incident photo from disk
              --latest-incident [--json] Inspect the most recent intruder photo capture
              --export-latest-incident <p> Copy latest intruder photo capture to destination path
              --export-incident <f> <p>  Copy specific intruder photo capture to destination path
              --clear-incidents          Purge all saved intruder photo captures from disk
              --prune-incidents <count>  Prune intruder captures keeping latest N photos
              --logs, --audit [--tail N] [--type T] [--json] View security audit event log
              --audit-ui, --audit-window Open security audit log viewer window
              --clear-logs, --clear-audit Purge all recorded security audit log events
              --prune-logs, --prune-audit <count> Prune older audit events keeping latest N
              --export-logs, --export-audit <path> Export security audit log to file
              --verify-face [--timeout]  One-shot face biometric check without locking
              --verify-pin <pin>         Verify whether given PIN matches lock screen PIN
              --lock, --test-lock        Trigger immediate fullscreen lock screen
              --is-locked [--json]       Check whether lock screen is currently engaged
              --export-incidents <dir>   Export all captured intruder incident photos and manifest to directory
              --toggle                   Toggle protection between ACTIVE and PAUSED
              --pause [mins]             Pause protection for N minutes (default: 15)
              --resume                   Resume protection immediately
              --reload, --reload-config  Hot-reload active configuration in running daemon
              --reset-session            Invalidate active biometric session and force re-authentication
              --check-app <bundleId>     Inspect whether bundle ID triggers biometric shield
              --config [--json]          Display active FaceLock configuration
              --backup-config <path>     Export active FaceLock configuration to JSON file
              --restore-config <path>    Import and apply FaceLock configuration from JSON file
              --apps [--json]            List protected and ignored application bundle IDs
              --apps-gui, --apps-window  Open interactive application protection policy window
              --protect-app <bundleId>   Add application bundle ID to protected list
              --unprotect-app <bundleId> Remove application bundle ID from protected list
              --ignore-app <bundleId>    Add application bundle ID to ignored list
              --unignore-app <bundleId>  Remove application bundle ID from ignored list
              --reset-apps [--json]      Reset protected and ignored application lists to defaults
              --set-liveness <on|off|toggle> Enable, disable or toggle anti-spoofing verification
              --toggle-liveness          Toggle anti-spoofing 3D liveness detection
              --set-touchid <on|off|toggle> Enable, disable or toggle Touch ID fallback
              --toggle-touchid           Toggle Touch ID fallback on lock screen
              --set-lock-on-wake <on|off|toggle> Enable, disable or toggle lock verification upon Mac screen wake
              --toggle-wake              Toggle lock verification upon Mac screen wake
              --vectors [--json]         Inspect enrolled biometric facial vectors & cluster metrics
              --optimize-vectors [--json] Prune redundant templates & outliers to optimize cluster compactness
              --export-vectors <path>    Export enrolled facial biometric vectors to JSON file
              --import-vectors <path>    Import facial biometric vectors from JSON file
              --profiles [--json]        List available security profiles and current active profile
              --profile <name>           Activate security profile (normal, cafe, work, home, presentation)
              --toggle-shoulder-defense  Toggle shoulder-surfing bystander defense
              --set-shoulder-defense <on|off> Enable or disable shoulder-surfing defense
              --toggle-audible           Toggle audible alarm & sound cues
              --set-audible <on|off>     Enable or disable audible alarm & sound cues
              --toggle-battery-aware     Toggle battery-aware adaptive idle sweep throttling
              --set-battery-aware <on|off> Enable or disable battery-aware adaptive scanning
              --toggle-presentation, --toggle-presentation-mode Toggle meeting / presentation lock auto-suppression
              --set-presentation-mode <on|off|toggle> Enable or disable meeting lock auto-suppression
              --test, --run-tests        Execute automated unit test suite and benchmarks
              --health [--json]          Fast operational healthcheck (exit 0 if healthy)
              --set-pin <pin>            Update lock screen unlock PIN
              --set-pin-attempts <count> Set allowed failed PIN attempts before lockout (1-10, default: 3)
              --set-pin-lockout <sec>    Set cooling lockout delay after failed PIN attempts (1-60s, default: 5s)
              --set-telegram <tok> <id>  Configure Telegram bot credentials and enable alerts
              --enable-telegram          Enable Telegram notifications
              --disable-telegram         Disable Telegram notifications
              --set-walkaway <sec|off|toggle> Configure walk-away timeout (10-600s), 'off', or 'toggle'
              --toggle-walkaway          Toggle walk-away auto-lock detection
              --set-threshold <val>      Set similarity threshold (0.05 - 0.60, default: 0.22)
              --set-timeout <seconds>    Set camera verification timeout (0.5 - 10.0s, default: 2.0s)
              --set-debounce <seconds>   Set app switch debounce interval (0.5 - 30.0s, default: 2.0s)
              --set-mode <mode>          Set mode: 'all' (every app) or 'selective' (secret apps)
              --cameras [--json]         List available video capture cameras and active selection
              --set-camera <id|name|default> Set preferred camera device by ID, name substring, or 'default'
              --reset-camera [--json]    Reset preferred camera selection to default front/built-in camera
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
            if args.contains("--json") {
                print("{\"name\":\"FaceLock\",\"version\":\"1.1.2\",\"platform\":\"darwin-arm64\"}")
            } else {
                print("FaceLock v1.1.2 (darwin-arm64)")
            }
            exit(0)
        }

        if args.contains("--test") || args.contains("--run-tests") {
            let suite = FaceLockTestSuite()
            let passed = suite.runAll()
            exit(passed ? 0 : 1)
        }

        if args.contains("--diagnostics") || args.contains("-d") {
            Diagnostics.run(jsonOutput: args.contains("--json"))
            exit(0)
        }

        // Inter-process command dispatching if instance is already running
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        let isAlreadyRunning = !runningApps.isEmpty

        if args.contains("--reload") || args.contains("--reload-config") {
            if isAlreadyRunning {
                AppDelegate.notifyDaemonReload()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Dispatched reload signal to daemon\"}")
                } else {
                    print("✓ Dispatched configuration reload signal to running FaceLock daemon.")
                }
            } else {
                Config.shared.reload()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":false,\"message\":\"Config on disk reloaded\"}")
                } else {
                    print("✓ FaceLock daemon is not running; configuration reloaded from disk.")
                }
            }
            exit(0)
        }

        if args.contains("--is-locked") || args.contains("--locked") {
            let state = Config.getLockState()
            let isLocked = (state["isLocked"] as? Bool) ?? false
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: state, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if isLocked {
                    print("🔒 FaceLock screen is currently LOCKED.")
                } else {
                    print("🔓 FaceLock screen is UNLOCKED.")
                }
            }
            exit(isLocked ? 0 : 1)
        }

        if args.contains("--reset-session") {
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "reset-session"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Dispatched reset-session signal to daemon\"}")
                } else {
                    print("✓ Dispatched verification session reset signal to running FaceLock daemon.")
                }
            } else {
                AppMonitor.shared.resetVerificationSession()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":false,\"message\":\"Verification session cache cleared\"}")
                } else {
                    print("✓ Verification session cache cleared offline.")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--check-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --check-app <bundleId>")
                exit(1)
            }
            let config = Config.shared
            let isIgnored = config.ignoredBundleIdentifiers.contains(bundleId)
            let isSelf = (bundleId == "io.github.facelock" || bundleId == Bundle.main.bundleIdentifier)
            let isProtected: Bool
            let willTrigger: Bool

            if isSelf || isIgnored {
                isProtected = false
                willTrigger = false
            } else if config.protectionMode == "selective" {
                isProtected = config.protectedBundleIdentifiers.contains(bundleId)
                willTrigger = isProtected && config.isEnabled
            } else {
                isProtected = true
                willTrigger = config.isEnabled
            }

            if args.contains("--json") {
                let dict: [String: Any] = [
                    "bundleId": bundleId,
                    "shieldActive": config.isEnabled,
                    "mode": config.protectionMode,
                    "isIgnored": isIgnored || isSelf,
                    "isProtected": isProtected,
                    "willLockOnSwitch": willTrigger
                ]
                if let d = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                let statusEmoji = willTrigger ? "🛡️ ACTIVE (Will verify)" : "⚪ PASS (Bypassed)"
                print("""
                FaceLock App Security Inspection:
                  Bundle ID: \(bundleId)
                  Status: \(statusEmoji)
                  Shield Enabled: \(config.isEnabled ? "Yes" : "No")
                  Protection Mode: \(config.protectionMode)
                  Ignored List: \(isIgnored ? "Yes (Ignored)" : "No")
                  Protected List: \(config.protectedBundleIdentifiers.contains(bundleId) ? "Yes" : "No")
                """)
            }
            exit(0)
        }

        if args.contains("--status") {
            let enrolledCount = Config.shared.loadEnrolledVectors().count
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)
            let incidentCount = files.count

            var recent24hCount = 0
            var latestIncidentTimestamp: String? = nil
            let oneDayAgo = Date().addingTimeInterval(-86400)

            for f in files {
                let p = dir.appendingPathComponent(f).path
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
                   let modDate = attrs[.modificationDate] as? Date {
                    if latestIncidentTimestamp == nil {
                        latestIncidentTimestamp = ISO8601DateFormatter().string(from: modDate)
                    }
                    if modDate >= oneDayAgo {
                        recent24hCount += 1
                    }
                }
            }

            if args.contains("--json") {
                let statusDict: [String: Any] = [
                    "version": "1.1.2",
                    "daemon": isAlreadyRunning ? "running" : "stopped",
                    "shieldState": Config.shared.isEnabled ? "active" : "paused",
                    "protectionMode": Config.shared.protectionMode,
                    "activeProfile": Config.shared.activeProfile,
                    "shoulderSurfingDefense": Config.shared.shoulderSurfingDefense,
                    "batteryAwareScanning": Config.shared.batteryAwareScanning,
                    "audibleAlerts": Config.shared.audibleAlerts,
                    "presentationModeSuppression": Config.shared.presentationModeSuppression,
                    "enrolledTemplates": enrolledCount,
                    "incidentCaptures": incidentCount,
                    "recentIncidents24h": recent24hCount,
                    "latestIncidentTimestamp": latestIncidentTimestamp as Any,
                    "similarityThreshold": Double(Config.shared.similarityThreshold),
                    "walkAwayLockEnabled": Config.shared.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": Config.shared.walkAwayIdleSeconds,
                    "lockOnWake": Config.shared.lockOnWake,
                    "maxFailedPinAttempts": Config.shared.maxFailedPinAttempts,
                    "pinLockoutSeconds": Config.shared.pinLockoutSeconds,
                    "livenessDetectionEnabled": Config.shared.livenessDetectionEnabled,
                    "autoTriggerTouchID": Config.shared.autoTriggerTouchID,
                    "telegramEnabled": Config.shared.telegramEnabled
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: statusDict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            let recent24hStr = recent24hCount > 0 ? " (\(recent24hCount) in past 24h)" : ""
            print("""
            FaceLock Status:
              Version: 1.1.2 (darwin-arm64)
              Daemon: \(isAlreadyRunning ? "RUNNING" : "STOPPED")
              Shield: \(Config.shared.isEnabled ? "ACTIVE" : "PAUSED")
              Mode: \(Config.shared.protectionMode)
              Security Profile: \(Config.shared.activeProfile.uppercased()) (\(Config.SecurityProfile(rawValue: Config.shared.activeProfile)?.title ?? Config.shared.activeProfile))
              Shoulder-Surfing Defense: \(Config.shared.shoulderSurfingDefense ? "Enabled" : "Disabled")
              Battery-Aware Polling: \(Config.shared.batteryAwareScanning ? "Enabled" : "Disabled")
              Audible Alerts: \(Config.shared.audibleAlerts ? "Enabled" : "Disabled")
              Meeting Auto-Suppression: \(Config.shared.presentationModeSuppression ? "Enabled" : "Disabled")
              Enrolled Templates: \(enrolledCount) (\(enrolledCount > 0 ? "Strict Neural Biometrics" : "Presence Detection Fallback"))
              Intruder Captures: \(incidentCount) logged\(recent24hStr)
              Decision Threshold: \(Config.shared.similarityThreshold)
              Anti-Spoofing Liveness: \(Config.shared.livenessDetectionEnabled ? "Enabled" : "Disabled")
              Auto-Trigger Touch ID: \(Config.shared.autoTriggerTouchID ? "Enabled" : "Disabled")
              Walk-Away Auto Lock: \(Config.shared.walkAwayLockEnabled ? "Enabled (\(Int(Config.shared.walkAwayIdleSeconds))s)" : "Disabled")
              Lock On Screen Wake: \(Config.shared.lockOnWake ? "Enabled" : "Disabled")
              Telegram Notifications: \(Config.shared.telegramEnabled ? "Configured" : "Disabled")
            """)
            exit(0)
        }

        if args.contains("--health") || args.contains("--ping") {
            let enrolledCount = Config.shared.loadEnrolledVectors().count
            let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
            let camOk = (camAuth == .authorized || camAuth == .notDetermined)
            let isHealthy = isAlreadyRunning && Config.shared.isEnabled && (enrolledCount > 0) && camOk
            var issues: [String] = []
            if !isAlreadyRunning { issues.append("Daemon is stopped") }
            if !Config.shared.isEnabled { issues.append("Shield protection is paused") }
            if enrolledCount == 0 { issues.append("No face templates enrolled") }
            if !camOk { issues.append("Camera access is restricted or denied") }

            if args.contains("--json") {
                let out: [String: Any] = [
                    "healthy": isHealthy,
                    "daemonRunning": isAlreadyRunning,
                    "shieldActive": Config.shared.isEnabled,
                    "enrolledTemplates": enrolledCount,
                    "cameraAuthorized": camAuth == .authorized,
                    "issues": issues
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                if isHealthy {
                    print("✓ FaceLock is HEALTHY (Daemon running, shield active, \(enrolledCount) templates calibrated).")
                } else {
                    print("⚠️ FaceLock HEALTH WARNING:")
                    for issue in issues {
                        print("  • \(issue)")
                    }
                }
            }
            exit(isHealthy ? 0 : 1)
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
                    "lockOnWake": config.lockOnWake,
                    "maxFailedPinAttempts": config.maxFailedPinAttempts,
                    "pinLockoutSeconds": config.pinLockoutSeconds,
                    "preferredCameraID": config.preferredCameraID.isEmpty ? "default" : config.preferredCameraID,
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
              Lock On Screen Wake: \(config.lockOnWake ? "Enabled" : "Disabled")
              Max Failed PIN Attempts: \(config.maxFailedPinAttempts)
              PIN Lockout Delay: \(Int(config.pinLockoutSeconds))s
              Preferred Camera: \(config.preferredCameraID.isEmpty ? "Default (Automatic)" : config.preferredCameraID)
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

        let notifyDaemonIfRunning = {
            if isAlreadyRunning {
                AppDelegate.notifyDaemonReload()
            }
        }

        if let idx = args.firstIndex(of: "--protect-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --protect-app <bundleId>")
                exit(1)
            }
            let added = Config.shared.addProtectedApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added protected application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to protected applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' is already in protected applications list.")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--unprotect-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --unprotect-app <bundleId>")
                exit(1)
            }
            let removed = Config.shared.removeProtectedApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed protected application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from protected applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in protected applications list.")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--ignore-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --ignore-app <bundleId>")
                exit(1)
            }
            let added = Config.shared.addIgnoredApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added ignored application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to ignored applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' is already in ignored applications list.")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--unignore-app"), idx + 1 < args.count {
            let bundleId = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else {
                print("Error: Missing bundle identifier. Usage: facelock --unignore-app <bundleId>")
                exit(1)
            }
            let removed = Config.shared.removeIgnoredApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed ignored application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from ignored applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in ignored applications list.")
                }
            }
            exit(0)
        }

        if args.contains("--reset-apps") {
            Config.shared.resetAllAppLists()
            SecurityAuditLogger.shared.logPolicyChanged(action: "Reset application policy to defaults", bundleId: "all")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "protectedAppsCount": Config.shared.protectedBundleIdentifiers.count,
                    "ignoredAppsCount": Config.shared.ignoredBundleIdentifiers.count,
                    "message": "Reset application lists to factory defaults"
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
            } else {
                print("✓ Reset protected (\(Config.shared.protectedBundleIdentifiers.count)) and ignored (\(Config.shared.ignoredBundleIdentifiers.count)) application lists to factory defaults.")
            }
            exit(0)
        }

        if args.contains("--toggle-liveness") || (args.firstIndex(of: "--set-liveness").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.livenessDetectionEnabled
            Config.shared.livenessDetectionEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "livenessDetectionEnabled", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"livenessDetectionEnabled\":\(enabled)}")
            } else {
                print("✓ Anti-spoofing liveness verification \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-liveness"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
            Config.shared.livenessDetectionEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "livenessDetectionEnabled", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"livenessDetectionEnabled\":\(enabled)}")
            } else {
                print("✓ Anti-spoofing liveness verification \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-touchid") || (args.firstIndex(of: "--set-touchid").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.autoTriggerTouchID
            Config.shared.autoTriggerTouchID = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "autoTriggerTouchID", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"autoTriggerTouchID\":\(enabled)}")
            } else {
                print("✓ Touch ID fallback on lock screen \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-touchid"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
            Config.shared.autoTriggerTouchID = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "autoTriggerTouchID", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"autoTriggerTouchID\":\(enabled)}")
            } else {
                print("✓ Touch ID fallback on lock screen \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-wake") {
            let enabled = !Config.shared.lockOnWake
            Config.shared.lockOnWake = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "lockOnWake", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"lockOnWake\":\(enabled)}")
            } else {
                print("✓ Lock verification upon Mac screen wake \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--set-lock-on-wake") ?? args.firstIndex(of: "--lock-on-wake")) {
            let enabled: Bool
            if idx + 1 < args.count && !args[idx + 1].starts(with: "--") {
                let val = args[idx + 1].lowercased()
                if val == "toggle" {
                    enabled = !Config.shared.lockOnWake
                } else {
                    enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
                }
            } else {
                enabled = !Config.shared.lockOnWake
            }
            Config.shared.lockOnWake = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "lockOnWake", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"lockOnWake\":\(enabled)}")
            } else {
                print("✓ Lock verification upon Mac screen wake \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--backup-config"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --backup-config <path>")
                exit(1)
            }
            do {
                let savedPath = try Config.shared.backupConfig(to: path)
                if args.contains("--json") {
                    print("{\"success\":true,\"path\":\"\(savedPath)\"}")
                } else {
                    print("✓ Exported FaceLock configuration to '\(savedPath)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error backing up config: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--restore-config"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --restore-config <path>")
                exit(1)
            }
            do {
                try Config.shared.restoreConfig(from: path)
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"path\":\"\(path)\"}")
                } else {
                    print("✓ Restored and applied FaceLock configuration from '\(path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error restoring config: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--vectors") || args.contains("--vector-metrics") {
            let metrics = Config.shared.getVectorMetrics()
            if args.contains("--json") {
                if let jsonData = try? JSONSerialization.data(withJSONObject: metrics, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
            } else {
                let count = metrics["count"] as? Int ?? 0
                let dims = metrics["dimensions"] as? Int ?? 0
                let quality = metrics["quality"] as? String ?? "N/A"
                let filePath = metrics["filePath"] as? String ?? ""
                let fileSizeBytes = metrics["fileSizeBytes"] as? UInt64 ?? 0
                let lastMod = metrics["lastModified"] as? String ?? "N/A"

                print("""
                FaceLock Biometric Face Vectors:
                  Enrolled Templates: \(count)
                  Embedding Dimension: \(dims > 0 ? "\(dims)-d (Apple Neural Vision Faceprint)" : "None")
                  Cluster Quality: \(quality)
                  Storage Location: \(filePath) (\(fileSizeBytes) bytes)
                  Last Modified: \(lastMod)
                """)
                if count >= 2,
                   let minVal = metrics["minPairwiseDistance"] as? Double,
                   let avgVal = metrics["avgPairwiseDistance"] as? Double,
                   let maxVal = metrics["maxPairwiseDistance"] as? Double,
                   let stdDev = metrics["standardDeviation"] as? Double {
                    print("""
                  Pairwise Cosine Distances:
                    • Minimum: \(String(format: "%.4f", minVal))
                    • Average: \(String(format: "%.4f", avgVal))
                    • Maximum: \(String(format: "%.4f", maxVal))
                    • Std Dev: \(String(format: "%.4f", stdDev))
                """)
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--export-vectors"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --export-vectors <path>")
                exit(1)
            }
            do {
                let count = try Config.shared.exportVectors(to: path)
                if args.contains("--json") {
                    print("{\"success\":true,\"exportedCount\":\(count),\"path\":\"\(path)\"}")
                } else {
                    print("✓ Exported \(count) facial template vectors to '\(path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting vectors: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--import-vectors"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --import-vectors <path>")
                exit(1)
            }
            let replace = args.contains("--replace")
            do {
                let total = try Config.shared.importVectors(from: path, merge: !replace)
                SecurityAuditLogger.shared.logVectorsModified(action: "Imported facial vectors", count: total, details: "Imported from \(path)")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"totalVectors\":\(total),\"path\":\"\(path)\",\"merged\":\(!replace)}")
                } else {
                    print("✓ Imported vectors from '\(path)'. Total enrolled templates: \(total).")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error importing vectors: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--optimize-vectors") || args.contains("--prune-vectors") {
            let result = Config.shared.optimizeVectors(maxVectors: 15)
            SecurityAuditLogger.shared.logVectorsModified(
                action: "Optimized facial vectors cluster",
                count: result["optimizedCount"] as? Int ?? 0,
                details: "Pruned \(result["prunedRedundant"] as? Int ?? 0) redundant vectors and \(result["prunedOutliers"] as? Int ?? 0) outliers"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let initial = result["initialCount"] as? Int ?? 0
                let optimized = result["optimizedCount"] as? Int ?? 0
                let red = result["prunedRedundant"] as? Int ?? 0
                let out = result["prunedOutliers"] as? Int ?? 0
                let initQuality = result["initialQuality"] as? String ?? ""
                let optQuality = result["optimizedQuality"] as? String ?? ""
                print("""
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                       🧬  FaceLock Neural Vector Cluster Optimizer         
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                • Enrolled Templates: \(initial) -> \(optimized)
                • Redundant vectors pruned: \(red)
                • Outlier samples removed: \(out)
                • Initial Cluster Quality: \(initQuality)
                • Optimized Cluster Quality: \(optQuality)
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                ✓ Enrolled facial template cluster optimized successfully.
                """)
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-threshold"), idx + 1 < args.count {
            if let val = Float(args[idx + 1]), val >= 0.05 && val <= 0.60 {
                Config.shared.similarityThreshold = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "similarityThreshold", value: "\(val)")
                notifyDaemonIfRunning()
                print("✓ Similarity decision threshold updated to \(val).")
                exit(0)
            } else {
                print("Error: Threshold must be a floating point value between 0.05 and 0.60.")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-timeout"), idx + 1 < args.count {
            if let val = Double(args[idx + 1]), val >= 0.5 && val <= 10.0 {
                Config.shared.verificationTimeout = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "verificationTimeout", value: "\(val)s")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"verificationTimeout\":\(val)}")
                } else {
                    print("✓ Verification timeout updated to \(val)s.")
                }
                exit(0)
            } else {
                print("Error: Timeout must be between 0.5 and 10.0 seconds. Usage: facelock --set-timeout <seconds>")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-debounce"), idx + 1 < args.count {
            if let val = Double(args[idx + 1]), val >= 0.5 && val <= 30.0 {
                Config.shared.debounceSeconds = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "debounceSeconds", value: "\(val)s")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"debounceSeconds\":\(val)}")
                } else {
                    print("✓ Switch debounce interval updated to \(val)s.")
                }
                exit(0)
            } else {
                print("Error: Debounce must be between 0.5 and 30.0 seconds. Usage: facelock --set-debounce <seconds>")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-mode"), idx + 1 < args.count {
            let mode = args[idx + 1].lowercased()
            if mode == "all" || mode == "selective" {
                Config.shared.protectionMode = mode
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "protectionMode", value: mode)
                notifyDaemonIfRunning()
                print("✓ Protection mode updated to '\(mode)'.")
                exit(0)
            } else {
                print("Error: Mode must be either 'all' or 'selective'.")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-pin"), idx + 1 < args.count {
            let newPin = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !newPin.isEmpty else {
                print("Error: Missing PIN value. Usage: facelock --set-pin <pin>")
                exit(1)
            }
            Config.shared.pin = newPin
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "pin", value: "****", details: "Lock screen unlock PIN updated")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"message\":\"Lock screen PIN updated\"}")
            } else {
                print("✓ Lock screen PIN successfully updated.")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-pin-attempts"), idx + 1 < args.count {
            guard let count = Int(args[idx + 1]), count >= 1 && count <= 10 else {
                print("Error: Failed attempts threshold must be between 1 and 10.")
                exit(1)
            }
            Config.shared.maxFailedPinAttempts = count
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "maxFailedPinAttempts", value: "\(count)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"maxFailedPinAttempts\":\(count)}")
            } else {
                print("✓ Max failed PIN attempts updated to \(count).")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-pin-lockout"), idx + 1 < args.count {
            guard let secs = Double(args[idx + 1]), secs >= 1.0 && secs <= 60.0 else {
                print("Error: PIN lockout delay must be between 1.0 and 60.0 seconds.")
                exit(1)
            }
            Config.shared.pinLockoutSeconds = secs
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "pinLockoutSeconds", value: "\(Int(secs))s")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"pinLockoutSeconds\":\(secs)}")
            } else {
                print("✓ PIN lockout delay updated to \(Int(secs))s.")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--verify-pin"), idx + 1 < args.count {
            let candidatePin = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let isValid = (candidatePin == Config.shared.pin)
            SecurityAuditLogger.shared.logVerificationCheck(type: "pin_verification", success: isValid, details: "CLI PIN verification test: \(isValid ? "Match" : "Mismatch")")
            if args.contains("--json") {
                print("{\"valid\":\(isValid),\"length\":\(candidatePin.count)}")
            } else {
                if isValid {
                    print("✓ PIN matches configured lock screen PIN.")
                } else {
                    print("❌ PIN does not match.")
                }
            }
            exit(isValid ? 0 : 1)
        }

        if let idx = args.firstIndex(of: "--set-telegram"), idx + 2 < args.count {
            let token = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let chatId = args[idx + 2].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !token.isEmpty && !chatId.isEmpty else {
                print("Error: Usage: facelock --set-telegram <token> <chatId>")
                exit(1)
            }
            Config.shared.telegramBotToken = token
            Config.shared.telegramChatId = chatId
            Config.shared.telegramEnabled = true
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"chatId\":\"\(chatId)\",\"telegramEnabled\":true}")
            } else {
                print("✓ Telegram credentials configured and alerts enabled for chat \(chatId).")
            }
            exit(0)
        }

        if args.contains("--enable-telegram") {
            Config.shared.telegramEnabled = true
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"telegramEnabled\":true}")
            } else {
                print("✓ Telegram intruder alerts enabled.")
            }
            exit(0)
        }

        if args.contains("--disable-telegram") {
            Config.shared.telegramEnabled = false
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"telegramEnabled\":false}")
            } else {
                print("✓ Telegram intruder alerts disabled.")
            }
            exit(0)
        }

        if args.contains("--toggle-walkaway") || (args.firstIndex(of: "--set-walkaway").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.walkAwayLockEnabled
            Config.shared.walkAwayLockEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "walkAwayLockEnabled", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"walkAwayLockEnabled\":\(enabled),\"walkAwayIdleSeconds\":\(Config.shared.walkAwayIdleSeconds)}")
            } else {
                print("✓ Walk-away auto-lock \(enabled ? "enabled (\(Int(Config.shared.walkAwayIdleSeconds))s idle timeout)" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-walkaway"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            if val == "off" || val == "disable" || val == "0" {
                Config.shared.walkAwayLockEnabled = false
                Config.shared.save()
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"walkAwayLockEnabled\":false}")
                } else {
                    print("✓ Walk-away auto-lock disabled.")
                }
            } else if let secs = Double(val), secs >= 10.0 && secs <= 600.0 {
                Config.shared.walkAwayLockEnabled = true
                Config.shared.walkAwayIdleSeconds = secs
                Config.shared.save()
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"walkAwayLockEnabled\":true,\"walkAwayIdleSeconds\":\(secs)}")
                } else {
                    print("✓ Walk-away auto-lock enabled with \(Int(secs))s idle timeout.")
                }
            } else {
                print("Error: Invalid timeout. Provide seconds (10 - 600) or 'off'.")
                exit(1)
            }
            exit(0)
        }

        if args.contains("--profiles") {
            if args.contains("--json") {
                let profiles = Config.SecurityProfile.allCases.map { p -> [String: Any] in
                    return [
                        "id": p.rawValue,
                        "title": p.title,
                        "summary": p.summary,
                        "isActive": (Config.shared.activeProfile == p.rawValue)
                    ]
                }
                let dict: [String: Any] = [
                    "activeProfile": Config.shared.activeProfile,
                    "profiles": profiles
                ]
                if let d = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("FaceLock Security Profiles:")
                for p in Config.SecurityProfile.allCases {
                    let active = (Config.shared.activeProfile == p.rawValue) ? " [ACTIVE] ✅" : ""
                    print("  • \(p.rawValue): \(p.title)\(active)")
                    print("    \(p.summary)")
                }
                print("\n  Active Profile: \(Config.shared.activeProfile)")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--profile") ?? args.firstIndex(of: "--set-profile")), idx + 1 < args.count {
            let targetName = args[idx + 1].lowercased()
            if Config.shared.setProfile(targetName) {
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"activeProfile\":\"\(targetName)\"}")
                } else {
                    print("✓ Applied security profile '\(targetName)': \(Config.SecurityProfile(rawValue: targetName)?.title ?? targetName)")
                }
            } else {
                let valid = Config.SecurityProfile.allCases.map { $0.rawValue }.joined(separator: ", ")
                print("Error: Unknown profile '\(targetName)'. Available profiles: \(valid)")
                exit(1)
            }
            exit(0)
        }

        if args.contains("--toggle-shoulder-defense") || args.contains("--toggle-shoulder") {
            let enabled = !Config.shared.shoulderSurfingDefense
            Config.shared.shoulderSurfingDefense = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "shoulderSurfingDefense", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"shoulderSurfingDefense\":\(enabled)}")
            } else {
                print("✓ Shoulder-surfing defense \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-shoulder-defense"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            Config.shared.shoulderSurfingDefense = enabled
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"shoulderSurfingDefense\":\(enabled)}")
            } else {
                print("✓ Shoulder-surfing defense set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-audible") {
            let enabled = !Config.shared.audibleAlerts
            Config.shared.audibleAlerts = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "audibleAlerts", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"audibleAlerts\":\(enabled)}")
            } else {
                print("✓ Audible sound alerts \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-audible"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.audibleAlerts
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.audibleAlerts = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "audibleAlerts", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"audibleAlerts\":\(enabled)}")
            } else {
                print("✓ Audible sound alerts set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-battery-aware") {
            let enabled = !Config.shared.batteryAwareScanning
            Config.shared.batteryAwareScanning = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "batteryAwareScanning", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"batteryAwareScanning\":\(enabled)}")
            } else {
                print("✓ Battery-aware adaptive scanning \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-battery-aware"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.batteryAwareScanning
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.batteryAwareScanning = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "batteryAwareScanning", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"batteryAwareScanning\":\(enabled)}")
            } else {
                print("✓ Battery-aware adaptive scanning set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-presentation") || args.contains("--toggle-presentation-mode") {
            let enabled = !Config.shared.presentationModeSuppression
            Config.shared.presentationModeSuppression = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "presentationModeSuppression", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"presentationModeSuppression\":\(enabled)}")
            } else {
                print("✓ Meeting / presentation lock auto-suppression \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--set-presentation-mode") ?? args.firstIndex(of: "--set-presentation")), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.presentationModeSuppression
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.presentationModeSuppression = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "presentationModeSuppression", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"presentationModeSuppression\":\(enabled)}")
            } else {
                print("✓ Meeting / presentation lock auto-suppression set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--cameras") {
            let devices = CameraScanner.availableCaptureDevices()
            let preferredID = Config.shared.preferredCameraID
            let activeDevice = CameraScanner.selectDevice(preferredID: preferredID)

            if args.contains("--json") {
                let list = devices.map { dev -> [String: Any] in
                    let isPreferred = (!preferredID.isEmpty && (dev.uniqueID == preferredID || dev.localizedName.localizedCaseInsensitiveContains(preferredID)))
                    let isActive = (dev.uniqueID == activeDevice?.uniqueID)
                    return [
                        "id": dev.uniqueID,
                        "name": dev.localizedName,
                        "isBuiltIn": dev.deviceType == .builtInWideAngleCamera,
                        "isPreferred": isPreferred,
                        "isActive": isActive
                    ]
                }
                let dict: [String: Any] = [
                    "preferredCameraID": preferredID.isEmpty ? "default" : preferredID,
                    "activeCamera": activeDevice?.localizedName ?? "None",
                    "activeCameraID": activeDevice?.uniqueID ?? "None",
                    "cameras": list
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: data, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("FaceLock Detected Video Cameras (\(devices.count)):")
                for (i, dev) in devices.enumerated() {
                    let isPreferred = (!preferredID.isEmpty && (dev.uniqueID == preferredID || dev.localizedName.localizedCaseInsensitiveContains(preferredID)))
                    let isActive = (dev.uniqueID == activeDevice?.uniqueID)
                    var badge = ""
                    if isPreferred && isActive {
                        badge = " [SELECTED & ACTIVE] ✅"
                    } else if isActive {
                        badge = " [ACTIVE DEFAULT] 🎯"
                    } else if isPreferred {
                        badge = " [PREFERRED] ⭐️"
                    }
                    print("  [\(i + 1)] \(dev.localizedName)\(badge)")
                    print("      ID: \(dev.uniqueID)")
                }
                if preferredID.isEmpty {
                    print("\n  Preferred Camera: Automatic (Front / Built-in camera default)")
                } else {
                    print("\n  Preferred Camera ID: \(preferredID)")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-camera"), idx + 1 < args.count {
            let target = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let devices = CameraScanner.availableCaptureDevices()
            var selectedID = ""
            var selectedName = "Default (Auto)"

            if target.lowercased() == "default" || target.lowercased() == "auto" || target == "0" {
                Config.shared.preferredCameraID = ""
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(
                    setting: "preferredCameraID",
                    value: "default",
                    details: "Reset to default automatic camera selection"
                )
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"preferredCameraID\":\"default\",\"name\":\"Default (Auto)\"}")
                } else {
                    print("✓ Reset preferred camera to Default (Automatic front camera).")
                }
                exit(0)
            } else if let num = Int(target), num >= 1 && num <= devices.count {
                let dev = devices[num - 1]
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else if let dev = devices.first(where: { $0.uniqueID == target }) {
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else if let dev = devices.first(where: { $0.localizedName.localizedCaseInsensitiveContains(target) }) {
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Camera not found matching '\(target)'\"}")
                } else {
                    print("Error: Camera not found matching '\(target)'. Use 'facelock --cameras' to list available devices.")
                }
                exit(1)
            }

            Config.shared.preferredCameraID = selectedID
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: selectedID,
                details: "Preferred camera selected: \(selectedName)"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"preferredCameraID\":\"\(selectedID)\",\"name\":\"\(selectedName)\"}")
            } else {
                print("✓ Preferred camera set to: \(selectedName) [\(selectedID)]")
            }
            exit(0)
        }

        if args.contains("--reset-camera") {
            Config.shared.preferredCameraID = ""
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: "default",
                details: "Reset to default automatic camera selection"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"preferredCameraID\":\"default\",\"name\":\"Default (Auto)\"}")
            } else {
                print("✓ Reset preferred camera to Default (Automatic front camera).")
            }
            exit(0)
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

        if args.contains("--incidents-summary") || args.contains("--incident-summary") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            var totalBytes: UInt64 = 0
            var past24HoursCount = 0
            var past7DaysCount = 0
            var newestTimestamp: String? = nil
            var oldestTimestamp: String? = nil
            let now = Date()
            let calendar = Calendar.current
            var todayCount = 0

            let oneDayAgo = now.addingTimeInterval(-86400)
            let sevenDaysAgo = now.addingTimeInterval(-7 * 86400)
            let startOfToday = calendar.startOfDay(for: now)

            for (index, f) in files.enumerated() {
                let p = dir.appendingPathComponent(f).path
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p) {
                    if let sz = attrs[.size] as? UInt64 {
                        totalBytes += sz
                    }
                    if let modDate = attrs[.modificationDate] as? Date {
                        let iso = ISO8601DateFormatter().string(from: modDate)
                        if index == 0 {
                            newestTimestamp = iso
                        }
                        if index == files.count - 1 {
                            oldestTimestamp = iso
                        }
                        if modDate >= oneDayAgo {
                            past24HoursCount += 1
                        }
                        if modDate >= startOfToday {
                            todayCount += 1
                        }
                        if modDate >= sevenDaysAgo {
                            past7DaysCount += 1
                        }
                    }
                }
            }

            if args.contains("--json") {
                let summary: [String: Any] = [
                    "totalCaptures": files.count,
                    "totalSizeBytes": totalBytes,
                    "directory": dir.path,
                    "todayCount": todayCount,
                    "past24HoursCount": past24HoursCount,
                    "past7DaysCount": past7DaysCount,
                    "newestIncidentTimestamp": newestTimestamp as Any,
                    "oldestIncidentTimestamp": oldestTimestamp as Any
                ]
                if let d = try? JSONSerialization.data(withJSONObject: summary, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
            print("""
            FaceLock Intruder Incident Telemetry:
              Total Captures: \(files.count) (\(String(format: "%.2f", sizeMB)) MB)
              Storage Directory: \(dir.path)
              Today: \(todayCount) captures
              Past 24 Hours: \(past24HoursCount) captures
              Past 7 Days: \(past7DaysCount) captures
              Newest Incident: \(newestTimestamp ?? "None")
              Oldest Incident: \(oldestTimestamp ?? "None")
            """)
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

            SecurityAuditLogger.shared.logIncidentsAction(action: "Purged all intruder incident captures via CLI", count: deletedCount)

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

        if let idx = args.firstIndex(of: "--prune-incidents"), idx + 1 < args.count {
            if let keepCount = Int(args[idx + 1]), keepCount >= 0 {
                let removed = CameraScanner.shared.pruneIntruderPhotos(maxRetained: keepCount)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Pruned intruder incident captures via CLI", count: removed, details: "Kept latest \(keepCount) photos")
                if args.contains("--json") {
                    print("{\"success\":true,\"prunedCount\":\(removed),\"maxRetained\":\(keepCount)}")
                } else {
                    print("✓ Pruned \(removed) older intruder captures (retained latest \(keepCount)).")
                }
                exit(0)
            } else {
                print("Error: Count must be a non-negative integer. Usage: facelock --prune-incidents <count>")
                exit(1)
            }
        }

        if args.contains("--latest-incident") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            if let latest = files.first {
                let path = dir.appendingPathComponent(latest).path
                var sz: UInt64 = 0
                var modDate: Date? = nil
                if let attrs = try? FileManager.default.attributesOfItem(atPath: path) {
                    sz = (attrs[.size] as? UInt64) ?? 0
                    modDate = attrs[.modificationDate] as? Date
                }
                let dateStr = modDate != nil ? ISO8601DateFormatter().string(from: modDate!) : ""

                if args.contains("--json") {
                    let out: [String: Any] = [
                        "hasIncident": true,
                        "filename": latest,
                        "path": path,
                        "sizeBytes": sz,
                        "timestamp": dateStr
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let sizeKB = Double(sz) / 1024.0
                    print("""
                    Latest FaceLock Intruder Incident:
                      Filename: \(latest)
                      Timestamp: \(dateStr.isEmpty ? "Unknown" : dateStr)
                      Size: \(String(format: "%.1f", sizeKB)) KB
                      File Path: \(path)
                    """)
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"hasIncident\":false,\"message\":\"No intruder incidents logged\"}")
                } else {
                    print("✓ No intruder incidents logged in \(dir.path).")
                }
                exit(0)
            }
        }

        if let idx = args.firstIndex(of: "--export-latest-incident"), idx + 1 < args.count {
            let destPath = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !destPath.isEmpty else {
                print("Error: Usage: facelock --export-latest-incident <path>")
                exit(1)
            }
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            guard let latest = files.first else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"No intruder incident captures available to export\"}")
                } else {
                    print("Error: No intruder captures found to export.")
                }
                exit(1)
            }

            let srcURL = dir.appendingPathComponent(latest)
            let expandedDest = NSString(string: destPath).expandingTildeInPath
            let destURL = URL(fileURLWithPath: expandedDest)

            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident capture via CLI", count: 1, details: "\(latest) exported to \(destURL.path)")
                if args.contains("--json") {
                    print("{\"success\":true,\"source\":\"\(latest)\",\"destination\":\"\(destURL.path)\"}")
                } else {
                    print("✓ Exported latest incident (\(latest)) to '\(destURL.path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incident photo: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--export-incident"), idx + 2 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let destPath = args[idx + 2].trimmingCharacters(in: .whitespacesAndNewlines)

            guard !filename.isEmpty, !destPath.isEmpty else {
                print("Error: Usage: facelock --export-incident <filename> <destinationPath>")
                exit(1)
            }

            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let srcURL = dir.appendingPathComponent(filename)

            guard FileManager.default.fileExists(atPath: srcURL.path) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Incident '\(filename)' not found\"}")
                } else {
                    print("Error: Incident capture '\(filename)' not found in \(dir.path).")
                }
                exit(1)
            }

            let expandedDest = NSString(string: destPath).expandingTildeInPath
            let destURL = URL(fileURLWithPath: expandedDest)

            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident capture via CLI", count: 1, details: "\(filename) exported to \(destURL.path)")
                if args.contains("--json") {
                    print("{\"success\":true,\"source\":\"\(filename)\",\"destination\":\"\(destURL.path)\"}")
                } else {
                    print("✓ Exported incident (\(filename)) to '\(destURL.path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incident photo: \(error.localizedDescription)")
                }
                exit(1)
            }
        } else if args.contains("--export-incident") {
            print("Error: Missing parameters. Usage: facelock --export-incident <filename> <destinationPath>")
            exit(1)
        }

        if let idx = args.firstIndex(of: "--export-incidents"), idx + 1 < args.count {
            let dest = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !dest.isEmpty else {
                print("Error: Usage: facelock --export-incidents <destinationDirectory>")
                exit(1)
            }
            do {
                let res = try CameraScanner.shared.exportIncidents(to: dest)
                let count = res["count"] as? Int ?? 0
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident archive via CLI", count: count, details: "Exported to \(dest)")
                if args.contains("--json") {
                    if let d = try? JSONSerialization.data(withJSONObject: res, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let count = res["count"] as? Int ?? 0
                    let totalBytes = res["totalBytes"] as? UInt64 ?? 0
                    let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
                    print("✓ Exported \(count) intruder captures (\(String(format: "%.2f", sizeMB)) MB) to: \(dest)")
                    print("  Manifest generated at: \(res["manifestPath"] ?? "")")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incidents: \(error.localizedDescription)")
                }
                exit(1)
            }
        } else if args.contains("--export-incidents") {
            print("Error: Usage: facelock --export-incidents <destinationDirectory>")
            exit(1)
        }

        if let idx = args.firstIndex(of: "--incident"), idx + 1 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let path = dir.appendingPathComponent(filename).path

            guard FileManager.default.fileExists(atPath: path) else {
                if args.contains("--json") {
                    print("{\"found\":false,\"error\":\"Incident '\(filename)' not found\"}")
                } else {
                    print("Error: Incident capture '\(filename)' not found in \(dir.path).")
                }
                exit(1)
            }

            var sz: UInt64 = 0
            var modDate: Date? = nil
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path) {
                sz = (attrs[.size] as? UInt64) ?? 0
                modDate = attrs[.modificationDate] as? Date
            }
            let dateStr = modDate != nil ? ISO8601DateFormatter().string(from: modDate!) : ""

            if args.contains("--json") {
                let out: [String: Any] = [
                    "found": true,
                    "filename": filename,
                    "path": path,
                    "sizeBytes": sz,
                    "timestamp": dateStr
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                let sizeKB = Double(sz) / 1024.0
                print("""
                FaceLock Intruder Incident:
                  Filename: \(filename)
                  Timestamp: \(dateStr.isEmpty ? "Unknown" : dateStr)
                  Size: \(String(format: "%.1f", sizeKB)) KB
                  Path: \(path)
                """)
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--delete-incident"), idx + 1 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let path = dir.appendingPathComponent(filename).path

            guard FileManager.default.fileExists(atPath: path) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Incident '\(filename)' not found\"}")
                } else {
                    print("Error: Incident capture '\(filename)' not found.")
                }
                exit(1)
            }

            do {
                try FileManager.default.removeItem(atPath: path)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Deleted intruder capture via CLI", count: 1, details: "Deleted \(filename)")
                if args.contains("--json") {
                    print("{\"success\":true,\"deleted\":\"\(filename)\"}")
                } else {
                    print("✓ Deleted intruder incident capture '\(filename)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error deleting incident: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--logs") || args.contains("--audit") || args.contains("--audit-logs") {
            var tailCount = 20
            if let idx = args.firstIndex(of: "--tail"), idx + 1 < args.count, let val = Int(args[idx + 1]), val > 0 {
                tailCount = val
            }
            var filterType: String? = nil
            if let idx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), idx + 1 < args.count {
                filterType = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            }

            let events = SecurityAuditLogger.shared.fetchRecentEvents(tail: tailCount, filterType: filterType)
            let stats = SecurityAuditLogger.shared.getLogStats()

            if args.contains("--json") {
                let dict: [String: Any] = [
                    "totalLoggedEvents": stats.totalCount,
                    "retrievedCount": events.count,
                    "filter": filterType ?? "all",
                    "events": events.map { event in
                        var d: [String: Any] = [
                            "id": event.id,
                            "timestamp": event.timestamp,
                            "eventType": event.eventType,
                            "isSuccess": event.isSuccess
                        ]
                        if let app = event.appName { d["appName"] = app }
                        if let b = event.bundleId { d["bundleId"] = b }
                        if let dist = event.distance { d["distance"] = Double(dist) }
                        if let th = event.threshold { d["threshold"] = Double(th) }
                        if let photo = event.intruderPhoto { d["intruderPhoto"] = photo }
                        if let det = event.details { d["details"] = det }
                        return d
                    }
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }

            print("FaceLock Security Audit Log (showing latest \(events.count) of \(stats.totalCount) events):")
            if events.isEmpty {
                if let f = filterType {
                    print("  ✓ No audit events found matching filter '\(f)'.")
                } else {
                    print("  ✓ No security audit events recorded.")
                }
            } else {
                for event in events {
                    let icon: String
                    switch event.eventType {
                    case "face_verified", "wake_verified": icon = "✅"
                    case "intruder_detected", "wake_locked": icon = "🚨"
                    case "walkaway_lock": icon = "🚶"
                    case "touchid_unlocked": icon = "👆"
                    case "pin_unlocked": icon = "🔑"
                    case "pin_failed": icon = "❌"
                    case "pin_bruteforce_attempt", "pin_bruteforce_intruder": icon = "🚫"
                    case "face_retry_success": icon = "🔄✅"
                    case "face_retry_failed": icon = "🔄❌"
                    case "shield_enabled": icon = "🛡️"
                    case "shield_paused": icon = "⏸️"
                    case "policy_changed": icon = "📋"
                    case "config_changed": icon = "⚙️"
                    case "vectors_modified", "vectors_enrolled": icon = "🧬"
                    case "enrollment_cancelled": icon = "🧬⚠️"
                    case "telegram_alert_sent": icon = "📲"
                    case "telegram_alert_failed": icon = "⚠️📲"
                    case "audit_cleared", "audit_pruned", "audit_exported": icon = "🧹"
                    case "incidents_action": icon = "📸"
                    case "pin_check": icon = "🔐"
                    case "face_check": icon = "👤"
                    default: icon = event.isSuccess ? "✓" : "⚠️"
                    }

                    var line = "  [\(event.timestamp)] \(icon) \(event.eventType.uppercased())"
                    if let app = event.appName { line += " | App: \(app)" }
                    if let dist = event.distance {
                        line += " | Dist: \(String(format: "%.4f", dist))"
                        if let th = event.threshold {
                            line += " (Th: \(String(format: "%.2f", th)))"
                        }
                    }
                    if let photo = event.intruderPhoto { line += " | Photo: \(photo)" }
                    if let det = event.details { line += " | \(det)" }
                    print(line)
                }
            }
            exit(0)
        }

        if args.contains("--audit-stats") || args.contains("--log-stats") {
            let stats = SecurityAuditLogger.shared.getLogStats()
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "totalEvents": stats.totalCount,
                    "fileSizeBytes": stats.fileSizeBytes,
                    "lastEventTime": stats.lastEventTime ?? ""
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }
            let sizeKB = Double(stats.fileSizeBytes) / 1024.0
            print("""
            FaceLock Security Audit Log Statistics:
              Total Logged Events: \(stats.totalCount)
              Log File Size: \(String(format: "%.2f", sizeKB)) KB (~/.facelock/audit_log.jsonl)
              Last Event Timestamp: \(stats.lastEventTime ?? "None")
            """)
            exit(0)
        }

        if args.contains("--clear-logs") || args.contains("--clear-audit") {
            let result = SecurityAuditLogger.shared.clearLogs()
            SecurityAuditLogger.shared.log(
                eventType: "audit_cleared",
                appName: "FaceLock CLI",
                details: "Purged security audit event log (\(result.deletedCount) events)",
                isSuccess: true
            )
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "deletedCount": result.deletedCount,
                    "freedSizeBytes": result.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }
            let freedKB = Double(result.freedBytes) / 1024.0
            print("✓ Cleared \(result.deletedCount) security audit events (\(String(format: "%.2f", freedKB)) KB freed).")
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--prune-logs") ?? args.firstIndex(of: "--prune-audit")), idx + 1 < args.count {
            guard let keep = Int(args[idx + 1]), keep >= 0 else {
                print("Error: Keep count must be a non-negative integer.")
                exit(1)
            }
            let res = SecurityAuditLogger.shared.pruneLogs(keeping: keep)
            SecurityAuditLogger.shared.log(
                eventType: "audit_pruned",
                appName: "FaceLock CLI",
                details: "Pruned \(res.prunedCount) older audit events (kept \(res.remainingCount))",
                isSuccess: true
            )
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "prunedCount": res.prunedCount,
                    "remainingCount": res.remainingCount,
                    "freedSizeBytes": res.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedKB = Double(res.freedBytes) / 1024.0
                print("✓ Pruned \(res.prunedCount) older audit log events (kept latest \(res.remainingCount), \(String(format: "%.2f", freedKB)) KB freed).")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--export-logs") ?? args.firstIndex(of: "--export-audit")), idx + 1 < args.count {
            let destPath = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !destPath.isEmpty else {
                print("Error: Usage: facelock --export-logs <path>")
                exit(1)
            }
            do {
                let count = try SecurityAuditLogger.shared.exportLogs(to: destPath)
                SecurityAuditLogger.shared.log(
                    eventType: "audit_exported",
                    appName: "FaceLock CLI",
                    details: "Exported \(count) security audit log events to \(destPath)",
                    isSuccess: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"exportedCount\":\(count),\"path\":\"\(destPath)\"}")
                } else {
                    print("✓ Exported \(count) security audit log events to '\(destPath)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting audit logs: \(error.localizedDescription)")
                }
                exit(1)
            }
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

        if args.contains("--verify-face") || args.contains("--test-face") {
            let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
            if camAuth == .denied || camAuth == .restricted {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Camera access is denied or restricted in System Settings\",\"exitCode\":3}")
                } else {
                    print("Error: Camera access is denied or restricted in macOS System Settings > Privacy & Security > Camera.")
                }
                exit(3)
            }

            let enrolledCount = Config.shared.loadEnrolledVectors().count
            if enrolledCount == 0 {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"No face templates enrolled. Run 'facelock --enroll' first.\",\"exitCode\":3}")
                } else {
                    print("Error: No enrolled face templates found. Run 'facelock --enroll' first to calibrate your face.")
                }
                exit(3)
            }

            var timeout = Config.shared.verificationTimeout
            if let idx = args.firstIndex(of: "--timeout"), idx + 1 < args.count, let val = Double(args[idx + 1]), val >= 0.5 && val <= 10.0 {
                timeout = val
            }

            let saveIntruder = args.contains("--save-intruder")
            CameraScanner.shared.autoSaveIntruders = saveIntruder

            if !args.contains("--json") {
                print("==> Initializing camera sensor and scanning face (timeout: \(timeout)s)...")
            }

            var done = false
            var matchSuccess = false
            var matchDistance: Float?
            var faceDetected = false

            CameraScanner.shared.scanFace(timeout: timeout) { success, distance, intruderImg in
                matchSuccess = success
                matchDistance = distance
                faceDetected = success || (intruderImg != nil)
                done = true
            }

            let deadline = Date().addingTimeInterval(timeout + 3.0)
            while !done && Date() < deadline {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
            }

            let threshold = Config.shared.similarityThreshold

            if matchSuccess {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: true, distance: matchDistance, details: "CLI face check: Owner recognized (dist: \(matchDistance != nil ? String(format: "%.4f", matchDistance!) : "0.0000"), threshold: \(threshold))")
                let distStr = matchDistance != nil ? String(format: "%.4f", matchDistance!) : "0.0000"
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "matched": true,
                        "faceDetected": true,
                        "distance": Double(matchDistance ?? 0.0),
                        "threshold": Double(threshold),
                        "enrolledTemplates": enrolledCount,
                        "status": "owner_verified"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("✓ Face verified! Owner recognized ✅ (distance: \(distStr), threshold: \(threshold), templates: \(enrolledCount))")
                }
                exit(0)
            } else if faceDetected {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: false, distance: matchDistance, details: "CLI face check: Face does not match enrolled owner (dist: \(matchDistance != nil ? String(format: "%.4f", matchDistance!) : "N/A"), threshold: \(threshold))")
                let distStr = matchDistance != nil ? String(format: "%.4f", matchDistance!) : "N/A"
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": false,
                        "matched": false,
                        "faceDetected": true,
                        "distance": Double(matchDistance ?? 1.0),
                        "threshold": Double(threshold),
                        "enrolledTemplates": enrolledCount,
                        "status": "intruder_rejected"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("❌ Face verification failed: Face does not match enrolled owner 🛡️ (best distance: \(distStr), threshold: \(threshold))")
                }
                exit(1)
            } else {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: false, details: "CLI face check timed out: No face detected in camera field of view")
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": false,
                        "matched": false,
                        "faceDetected": false,
                        "status": "no_face_detected",
                        "error": "No face detected in camera view within timeout"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("⚠️ Face verification timed out: No face detected in camera field of view within \(timeout)s.")
                }
                exit(2)
            }
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
            SecurityAuditLogger.shared.logVectorsModified(action: "Purged facial vectors", count: 0, details: "Reset via CLI")
            notifyDaemonIfRunning()
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
                SecurityAuditLogger.shared.logShieldStateChanged(enabled: false, reason: "Protection paused offline via CLI (\(Int(mins)) min)")
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
                SecurityAuditLogger.shared.logShieldStateChanged(enabled: true, reason: "Protection resumed offline via CLI")
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
            } else if args.contains("--audit-gui") || args.contains("--audit-ui") || args.contains("--audit-window") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "audit-log"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched audit log command to running instance.")
                exit(0)
            } else if args.contains("--apps-gui") || args.contains("--apps-window") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "apps-gui"],
                    deliverImmediately: true
                )
                print("[FaceLock] Dispatched applications manager command to running instance.")
                exit(0)
            } else if !args.contains("--reset") {
                let unhandledArgs = args.dropFirst().filter { $0.starts(with: "-") }
                if let unknown = unhandledArgs.first {
                    print("Error: Unrecognized option '\(unknown)'. See 'facelock --help' for available commands.")
                    exit(1)
                }
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "settings"],
                    deliverImmediately: true
                )
                print("[FaceLock] Instance is already running in background (PID: \(runningApps.first?.processIdentifier ?? 0)).")
                print("[FaceLock] Dispatched settings command to running instance.")
                exit(0)
            }
        }

        // Handle offline toggle if daemon is not currently active
        if args.contains("--toggle") {
            Config.shared.isEnabled.toggle()
            Config.shared.save()
            SecurityAuditLogger.shared.logShieldStateChanged(enabled: Config.shared.isEnabled, reason: "Protection toggled offline via CLI")
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
        } else if args.contains("--audit-gui") || args.contains("--audit-ui") || args.contains("--audit-window") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AuditLogController.shared.show()
            }
        } else if args.contains("--apps-gui") || args.contains("--apps-window") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ApplicationsManagerController.shared.show()
            }
        } else {
            let unhandledArgs = args.dropFirst().filter { $0.starts(with: "-") && $0 != "--daemon" && $0 != "--background" }
            if let unknown = unhandledArgs.first {
                print("Error: Unrecognized option '\(unknown)'. See 'facelock --help' for available commands.")
                exit(1)
            }
            if !Config.shared.hasEnrolledFace {
                print("[FaceLock] Note: No face enrolled yet. Running in face detection mode.")
                print("[FaceLock] Open Menu Bar icon -> «Запомнить моё лицо» to train your specific face.")
            }
            if !args.contains("--daemon") && !args.contains("--background") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SettingsController.shared.show()
                }
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
            case "audit-log", "audit", "audit-window", "audit-ui":
                AuditLogController.shared.show()
            case "apps-gui", "apps-window", "apps":
                ApplicationsManagerController.shared.show()
            case "lock", "test-lock":
                LockScreenController.shared.showLock()
            case "toggle":
                StatusBarController.shared.toggleEnabled()
            case "toggle-lock-on-wake":
                StatusBarController.shared.toggleLockOnWake()
            case "toggle-walkaway":
                StatusBarController.shared.toggleWalkAwayLock()
            case "pause":
                let minutes = notif.userInfo?["minutes"] as? Double ?? 15.0
                StatusBarController.shared.pauseFor(minutes: minutes)
            case "resume":
                StatusBarController.shared.resumeProtection()
            case "reload-config":
                Config.shared.reload()
                CameraScanner.shared.reconfigureDeviceIfNeeded()
                StatusBarController.shared.updateIcon()
                print("[FaceLock] Distributed reload signal received: Configuration refreshed.")
            case "reset-session":
                AppMonitor.shared.resetVerificationSession()
                print("[FaceLock] Distributed signal received: Verification session reset.")
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
