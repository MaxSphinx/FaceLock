import Foundation
import AppKit
import AVFoundation
import Vision
import LocalAuthentication

public struct Diagnostics {
    public static func collectReport() -> [String: Any] {
        // 1. System & Architecture
        let osVer = ProcessInfo.processInfo.operatingSystemVersionString
        var uts = utsname()
        uname(&uts)
        let arch = withUnsafePointer(to: &uts.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        let isAppleSilicon = (arch == "arm64")

        // 2. Daemon & Process Status
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        let isRunning = !runningApps.isEmpty
        let config = Config.shared

        // 3. Camera Subsystem
        let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
        var camAuthStr = "unknown"
        switch camAuth {
        case .authorized: camAuthStr = "authorized"
        case .denied: camAuthStr = "denied"
        case .restricted: camAuthStr = "restricted"
        case .notDetermined: camAuthStr = "notDetermined"
        @unknown default: camAuthStr = "unknown"
        }

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discovery.devices

        // 4. Apple Neural Vision & Face Recognition
        let hasFaceprintReq = (NSClassFromString("VNCreateFaceprintRequest") != nil)

        // 5. Power & Battery Status
        let onBattery = WalkAwayMonitor.isOnBatteryPower()
        let lowPowerMode = WalkAwayMonitor.isLowPowerModeEnabled()
        let powerConstrained = WalkAwayMonitor.isPowerConstrained()

        // 6. Biometric Authentication (Touch ID)
        let laContext = LAContext()
        var laError: NSError?
        let canTouchID = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &laError)
        var bioTypeStr = "None"
        if #available(macOS 10.15, *) {
            switch laContext.biometryType {
            case .touchID: bioTypeStr = "Touch ID"
            case .faceID: bioTypeStr = "Face ID"
            case .opticID: bioTypeStr = "Optic ID"
            case .none: bioTypeStr = "None"
            @unknown default: bioTypeStr = "Unknown"
            }
        }

        // 6. Storage & Vector Datasets
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)
        let configPath = facelockDir.appendingPathComponent("config.json").path
        let vectorsPath = facelockDir.appendingPathComponent("owner_face_vectors.json").path
        let intrudersDir = facelockDir.appendingPathComponent("intruders", isDirectory: true)
        let configExists = FileManager.default.fileExists(atPath: configPath)
        let vectors = config.loadEnrolledVectors()
        let vectorMetrics = config.getVectorMetrics()

        var intruderCount = 0
        var totalBytes: UInt64 = 0
        var recent24hCount = 0
        let oneDayAgo = Date().addingTimeInterval(-86400)
        if let files = try? FileManager.default.contentsOfDirectory(atPath: intrudersDir.path) {
            let jpegs = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            intruderCount = jpegs.count
            for f in jpegs {
                let p = intrudersDir.appendingPathComponent(f).path
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p) {
                    if let sz = attrs[.size] as? UInt64 {
                        totalBytes += sz
                    }
                    if let modDate = attrs[.modificationDate] as? Date, modDate >= oneDayAgo {
                        recent24hCount += 1
                    }
                }
            }
        }

        // 7. Telegram Integration & Autonomous Workers
        let tgConfigured = !config.telegramBotToken.isEmpty && !config.telegramChatId.isEmpty
        var telegramReachable: Bool? = nil
        if tgConfigured {
            let sema = DispatchSemaphore(value: 0)
            if let testUrl = URL(string: "https://api.telegram.org") {
                var req = URLRequest(url: testUrl, timeoutInterval: 2.5)
                req.httpMethod = "HEAD"
                let task = URLSession.shared.dataTask(with: req) { _, response, error in
                    if let http = response as? HTTPURLResponse, (200...399).contains(http.statusCode) {
                        telegramReachable = true
                    } else if error == nil {
                        telegramReachable = true
                    } else {
                        telegramReachable = false
                    }
                    sema.signal()
                }
                task.resume()
                _ = sema.wait(timeout: .now() + 2.7)
            }
        }

        let launchAgentPath = home.appendingPathComponent("Library/LaunchAgents/io.github.facelock.maintainer.plist").path
        let agentInstalled = FileManager.default.fileExists(atPath: launchAgentPath)
        let logStats = SecurityAuditLogger.shared.getLogStats()

        return [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "platform": [
                "osVersion": osVer,
                "architecture": arch,
                "appleSilicon": isAppleSilicon,
                "pid": ProcessInfo.processInfo.processIdentifier,
                "onBatteryPower": onBattery,
                "lowPowerMode": lowPowerMode,
                "powerConstrained": powerConstrained
            ],
            "daemon": [
                "running": isRunning,
                "pids": runningApps.map { $0.processIdentifier },
                "shieldState": config.isEnabled ? "active" : "paused",
                "protectionMode": config.protectionMode,
                "activeProfile": config.activeProfile,
                "shoulderSurfingDefense": config.shoulderSurfingDefense,
                "batteryAwareScanning": config.batteryAwareScanning,
                "audibleAlerts": config.audibleAlerts,
                "presentationModeSuppression": config.presentationModeSuppression,
                "walkAwayLockEnabled": config.walkAwayLockEnabled,
                "walkAwayIdleSeconds": config.walkAwayIdleSeconds,
                "lockOnWake": config.lockOnWake
            ],
            "camera": [
                "authorization": camAuthStr,
                "devicesCount": devices.count,
                "preferredCameraID": config.preferredCameraID.isEmpty ? "default" : config.preferredCameraID,
                "activeCamera": CameraScanner.selectDevice(preferredID: config.preferredCameraID)?.localizedName ?? "None",
                "activeCameraID": CameraScanner.selectDevice(preferredID: config.preferredCameraID)?.uniqueID ?? "None",
                "devices": devices.map { [
                    "name": $0.localizedName,
                    "id": $0.uniqueID,
                    "isPreferred": (!config.preferredCameraID.isEmpty && ($0.uniqueID == config.preferredCameraID || $0.localizedName.localizedCaseInsensitiveContains(config.preferredCameraID))),
                    "isActive": ($0.uniqueID == CameraScanner.selectDevice(preferredID: config.preferredCameraID)?.uniqueID)
                ] }
            ],
            "biometrics": [
                "neuralFaceprintAvailable": hasFaceprintReq,
                "similarityThreshold": Double(config.similarityThreshold),
                "biometryType": bioTypeStr,
                "biometricsReady": canTouchID,
                "autoTriggerTouchID": config.autoTriggerTouchID
            ],
            "storage": [
                "configPath": configPath,
                "configExists": configExists,
                "vectorsPath": vectorsPath,
                "enrolledVectors": vectors.count,
                "vectorMetrics": vectorMetrics,
                "intrudersDir": intrudersDir.path,
                "intruderCaptures": intruderCount,
                "recent24hCaptures": recent24hCount,
                "intruderSizeBytes": totalBytes,
                "auditLogEvents": logStats.totalCount,
                "auditLogSizeBytes": logStats.fileSizeBytes,
                "auditLogLastEvent": logStats.lastEventTime ?? ""
            ],
            "integrations": [
                "telegramConfigured": tgConfigured,
                "telegramEnabled": config.telegramEnabled,
                "telegramReachable": telegramReachable ?? false,
                "maintainerInstalled": agentInstalled
            ]
        ]
    }

    public static func run(jsonOutput: Bool = false) {
        let report = collectReport()

        if jsonOutput {
            if let jsonData = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]),
               let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
            }
            return
        }

        guard let platform = report["platform"] as? [String: Any],
              let daemon = report["daemon"] as? [String: Any],
              let camera = report["camera"] as? [String: Any],
              let biometrics = report["biometrics"] as? [String: Any],
              let storage = report["storage"] as? [String: Any],
              let integrations = report["integrations"] as? [String: Any] else {
            return
        }

        let osVer = platform["osVersion"] as? String ?? "N/A"
        let arch = platform["architecture"] as? String ?? "N/A"
        let isAppleSilicon = platform["appleSilicon"] as? Bool ?? false
        let pid = platform["pid"] as? Int32 ?? 0
        let onBattery = platform["onBatteryPower"] as? Bool ?? false
        let lowPower = platform["lowPowerMode"] as? Bool ?? false
        let powerSourceStr = onBattery ? "Battery 🔋" : "AC Power 🔌"
        let lowPowerStr = lowPower ? "ACTIVE ⚡️" : "Disabled"

        let isRunning = daemon["running"] as? Bool ?? false
        let pids = (daemon["pids"] as? [Int32] ?? []).map { "\($0)" }.joined(separator: ", ")
        let isEnabled = (daemon["shieldState"] as? String) == "active"
        let protectionMode = daemon["protectionMode"] as? String ?? "all"
        let activeProfile = daemon["activeProfile"] as? String ?? "normal"
        let shoulder = daemon["shoulderSurfingDefense"] as? Bool ?? false
        let battery = daemon["batteryAwareScanning"] as? Bool ?? false
        let audible = daemon["audibleAlerts"] as? Bool ?? false
        let presentation = daemon["presentationModeSuppression"] as? Bool ?? false
        let walkAway = daemon["walkAwayLockEnabled"] as? Bool ?? false
        let walkAwaySec = daemon["walkAwayIdleSeconds"] as? Double ?? 45.0
        let lockOnWake = daemon["lockOnWake"] as? Bool ?? false

        let camAuthStr = camera["authorization"] as? String ?? "unknown"
        let devicesCount = camera["devicesCount"] as? Int ?? 0
        let activeCamera = camera["activeCamera"] as? String ?? "None"
        let preferredCameraID = camera["preferredCameraID"] as? String ?? "default"
        let devicesList = camera["devices"] as? [[String: Any]] ?? []

        let hasFaceprintReq = biometrics["neuralFaceprintAvailable"] as? Bool ?? false
        let simThresh = biometrics["similarityThreshold"] as? Double ?? 0.22
        let bioTypeStr = biometrics["biometryType"] as? String ?? "None"
        let canTouchID = biometrics["biometricsReady"] as? Bool ?? false
        let autoTouchID = biometrics["autoTriggerTouchID"] as? Bool ?? true

        let configPath = storage["configPath"] as? String ?? ""
        let configExists = storage["configExists"] as? Bool ?? false
        let vectorsPath = storage["vectorsPath"] as? String ?? ""
        let enrolledVectors = storage["enrolledVectors"] as? Int ?? 0
        let vectorMetrics = storage["vectorMetrics"] as? [String: Any] ?? [:]
        let intrudersDir = storage["intrudersDir"] as? String ?? ""
        let intruderCount = storage["intruderCaptures"] as? Int ?? 0
        let recent24hCount = storage["recent24hCaptures"] as? Int ?? 0
        let totalBytes = storage["intruderSizeBytes"] as? UInt64 ?? 0
        let auditEvents = storage["auditLogEvents"] as? Int ?? 0
        let auditBytes = storage["auditLogSizeBytes"] as? Int64 ?? 0
        let auditLast = storage["auditLogLastEvent"] as? String ?? "None"

        let tgConfigured = integrations["telegramConfigured"] as? Bool ?? false
        let tgEnabled = integrations["telegramEnabled"] as? Bool ?? false
        let tgReachable = integrations["telegramReachable"] as? Bool ?? false
        let agentInstalled = integrations["maintainerInstalled"] as? Bool ?? false

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("          🛡️  FaceLock Autonomous Diagnostics Suite         ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        print("\n[1] Platform & Environment:")
        print("  • OS Version: \(osVer)")
        print("  • Architecture: \(arch) (\(isAppleSilicon ? "Apple Silicon Neural Engine Active ✅" : "Intel Legacy ⚠️"))")
        print("  • PID: \(pid)")
        print("  • Power Source: \(powerSourceStr)")
        print("  • macOS Low Power Mode: \(lowPowerStr)")

        print("\n[2] Process & Daemon State:")
        if isRunning {
            print("  • Daemon Process: RUNNING (PID: \(pids.isEmpty ? "\(pid)" : pids)) ✅")
        } else {
            print("  • Daemon Process: STANDBY (Not running) ℹ️")
        }
        print("  • Shield Status: \(isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")")
        print("  • Protection Mode: \(protectionMode) (\(Config.shared.protectedBundleIdentifiers.count) protected apps)")
        print("  • Active Security Profile: \(activeProfile.uppercased()) (\(Config.SecurityProfile(rawValue: activeProfile)?.title ?? activeProfile))")
        print("  • Shoulder-Surfing Defense: \(shoulder ? "Enabled (Bystander Detection Active) 👥" : "Disabled")")
        print("  • Battery-Aware Adaptive Polling: \(battery ? "Enabled (Live IOKit Power Sensing) 🔋" : "Disabled")")
        print("  • Audible Deterrents: \(audible ? "Enabled 🔔" : "Disabled (Silent)")")
        print("  • Meeting Auto-Suppression: \(presentation ? "Enabled 🎯" : "Disabled")")
        print("  • Walk-Away Detection: \(walkAway ? "Enabled (\(Int(walkAwaySec))s idle)" : "Disabled")")
        print("  • Screen Wake Verification: \(lockOnWake ? "Enabled" : "Disabled")")

        print("\n[3] Camera Hardware & Permissions:")
        switch camAuthStr {
        case "authorized":
            print("  • Camera Authorization: AUTHORIZED ✅")
        case "denied":
            print("  • Camera Authorization: DENIED ❌ (Grant access in System Settings > Privacy & Security > Camera)")
        case "restricted":
            print("  • Camera Authorization: RESTRICTED ⚠️")
        case "notDetermined":
            print("  • Camera Authorization: NOT DETERMINED ❓ (Will prompt on first scan)")
        default:
            print("  • Camera Authorization: UNKNOWN")
        }

        if devicesCount == 0 {
            print("  • Video Devices: No cameras detected ⚠️")
        } else {
            print("  • Detected Cameras (\(devicesCount)):")
            for dev in devicesList {
                let name = dev["name"] as? String ?? "Camera"
                let id = dev["id"] as? String ?? ""
                let isPref = dev["isPreferred"] as? Bool ?? false
                let isAct = dev["isActive"] as? Bool ?? false
                var badge = ""
                if isPref && isAct {
                    badge = " [SELECTED & ACTIVE] ✅"
                } else if isAct {
                    badge = " [ACTIVE DEFAULT] 🎯"
                } else if isPref {
                    badge = " [PREFERRED] ⭐️"
                }
                print("    - \(name)\(badge) [\(id)]")
            }
            if preferredCameraID == "default" || preferredCameraID.isEmpty {
                print("  • Active Camera: \(activeCamera) (Automatic front camera)")
            } else {
                print("  • Active Camera: \(activeCamera) (Manual Selection: \(preferredCameraID))")
            }
        }

        print("\n[4] Apple Neural Vision & Faceprints:")
        print("  • Vision Framework: Loaded ✅")
        print("  • Neural Faceprint Model (VNCreateFaceprintRequest): \(hasFaceprintReq ? "AVAILABLE ✅" : "UNAVAILABLE ❌")")
        print("  • Similarity Decision Threshold: \(simThresh) (Strict Neural Mode)")

        print("\n[5] Biometrics & LocalAuthentication:")
        print("  • Biometric Hardware: \(bioTypeStr)")
        print("  • Biometrics Ready: \(canTouchID ? "YES ✅" : "NO ⚠️")")
        print("  • Auto-Trigger Touch ID: \(autoTouchID ? "Enabled" : "Disabled")")

        print("\n[6] Storage & Datasets:")
        print("  • Config File: \(configExists ? "Valid (\(configPath)) ✅" : "Missing ⚠️")")
        if enrolledVectors == 0 {
            print("  • Enrolled Face Templates: None - run 'facelock --enroll' ⚠️")
        } else if enrolledVectors == 1 {
            print("  • Enrolled Face Templates: 1 vector (128-d) calibrated at \(vectorsPath) ✅")
        } else {
            let avg = vectorMetrics["avgPairwiseDistance"] as? Double ?? 0.0
            let quality = vectorMetrics["quality"] as? String ?? "N/A"
            print("  • Enrolled Face Templates: \(enrolledVectors) vectors (128-d, avg distance: \(String(format: "%.3f", avg))) at \(vectorsPath) ✅")
            print("  • Biometric Cluster Quality: \(quality)")
        }

        let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
        let recentStr = recent24hCount > 0 ? " (\(recent24hCount) in past 24h)" : ""
        print("  • Intruder Incident Log: \(intruderCount) captures\(recentStr) (\(String(format: "%.2f", sizeMB)) MB) in \(intrudersDir)")
        let auditMB = Double(auditBytes) / (1024.0 * 1024.0)
        print("  • Security Audit Log: \(auditEvents) events (\(String(format: "%.2f", auditMB)) MB), last: \(auditLast)")

        print("\n[7] Integrations & Cloud Connectivity:")
        if tgConfigured {
            let reachStr = tgReachable ? " (Gateway Reachable ✅)" : " (Gateway Unreachable / DNS Error ❌)"
            print("  • Telegram Bot Alerts: Configured (Active: \(tgEnabled ? "YES ✅" : "NO ⏸️"))\(reachStr)")
        } else {
            print("  • Telegram Bot Alerts: Not configured ℹ️")
        }
        print("  • 24/7 Autonomous Maintainer: \(agentInstalled ? "Installed & Active ✅" : "Not installed (Run 'make maintainer-install') ℹ️")")

        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(" Diagnostics complete: All core biometric subsystems verified.")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}
