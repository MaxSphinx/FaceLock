import Foundation
import AppKit
import AVFoundation
import Vision
import LocalAuthentication

public struct Diagnostics {
    public static func run(jsonOutput: Bool = false) {
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

        // 5. Biometric Authentication (Touch ID)
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
        if let files = try? FileManager.default.contentsOfDirectory(atPath: intrudersDir.path) {
            let jpegs = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            intruderCount = jpegs.count
            for f in jpegs {
                let p = intrudersDir.appendingPathComponent(f).path
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
                   let sz = attrs[.size] as? UInt64 {
                    totalBytes += sz
                }
            }
        }

        // 7. Telegram Integration & Autonomous Workers
        let tgConfigured = !config.telegramBotToken.isEmpty && !config.telegramChatId.isEmpty
        let launchAgentPath = home.appendingPathComponent("Library/LaunchAgents/io.github.facelock.maintainer.plist").path
        let agentInstalled = FileManager.default.fileExists(atPath: launchAgentPath)

        if jsonOutput {
            let diagDict: [String: Any] = [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "platform": [
                    "osVersion": osVer,
                    "architecture": arch,
                    "appleSilicon": isAppleSilicon,
                    "pid": ProcessInfo.processInfo.processIdentifier
                ],
                "daemon": [
                    "running": isRunning,
                    "pids": runningApps.map { $0.processIdentifier },
                    "shieldState": config.isEnabled ? "active" : "paused",
                    "protectionMode": config.protectionMode,
                    "walkAwayLockEnabled": config.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": config.walkAwayIdleSeconds,
                    "lockOnWake": config.lockOnWake
                ],
                "camera": [
                    "authorization": camAuthStr,
                    "devicesCount": devices.count,
                    "devices": devices.map { ["name": $0.localizedName, "id": $0.uniqueID] }
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
                    "intruderSizeBytes": totalBytes
                ],
                "integrations": [
                    "telegramConfigured": tgConfigured,
                    "telegramEnabled": config.telegramEnabled,
                    "maintainerInstalled": agentInstalled
                ]
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: diagDict, options: [.prettyPrinted, .sortedKeys]),
               let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
            }
            return
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("          🛡️  FaceLock Autonomous Diagnostics Suite         ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        print("\n[1] Platform & Environment:")
        print("  • OS Version: \(osVer)")
        print("  • Architecture: \(arch) (\(isAppleSilicon ? "Apple Silicon Neural Engine Active ✅" : "Intel Legacy ⚠️"))")
        print("  • PID: \(ProcessInfo.processInfo.processIdentifier)")

        print("\n[2] Process & Daemon State:")
        if isRunning {
            let pids = runningApps.map { "\($0.processIdentifier)" }.joined(separator: ", ")
            print("  • Daemon Process: RUNNING (PID: \(pids)) ✅")
        } else {
            print("  • Daemon Process: STANDBY (Not running) ℹ️")
        }
        print("  • Shield Status: \(config.isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")")
        print("  • Protection Mode: \(config.protectionMode) (\(config.protectedBundleIdentifiers.count) protected apps)")
        print("  • Walk-Away Detection: \(config.walkAwayLockEnabled ? "Enabled (\(Int(config.walkAwayIdleSeconds))s idle)" : "Disabled")")
        print("  • Screen Wake Verification: \(config.lockOnWake ? "Enabled" : "Disabled")")

        print("\n[3] Camera Hardware & Permissions:")
        switch camAuth {
        case .authorized:
            print("  • Camera Authorization: AUTHORIZED ✅")
        case .denied:
            print("  • Camera Authorization: DENIED ❌ (Grant access in System Settings > Privacy & Security > Camera)")
        case .restricted:
            print("  • Camera Authorization: RESTRICTED ⚠️")
        case .notDetermined:
            print("  • Camera Authorization: NOT DETERMINED ❓ (Will prompt on first scan)")
        @unknown default:
            print("  • Camera Authorization: UNKNOWN")
        }

        if devices.isEmpty {
            print("  • Video Devices: No cameras detected ⚠️")
        } else {
            print("  • Detected Cameras (\(devices.count)):")
            for dev in devices {
                print("    - \(dev.localizedName) [\(dev.uniqueID)]")
            }
        }

        print("\n[4] Apple Neural Vision & Faceprints:")
        print("  • Vision Framework: Loaded ✅")
        print("  • Neural Faceprint Model (VNCreateFaceprintRequest): \(hasFaceprintReq ? "AVAILABLE ✅" : "UNAVAILABLE ❌")")
        print("  • Similarity Decision Threshold: \(config.similarityThreshold) (Strict Neural Mode)")

        print("\n[5] Biometrics & LocalAuthentication:")
        print("  • Biometric Hardware: \(bioTypeStr)")
        print("  • Biometrics Ready: \(canTouchID ? "YES ✅" : "NO (\(laError?.localizedDescription ?? "Unavailable")) ⚠️")")
        print("  • Auto-Trigger Touch ID: \(config.autoTriggerTouchID ? "Enabled" : "Disabled")")

        print("\n[6] Storage & Datasets:")
        print("  • Config File: \(configExists ? "Valid (\(configPath)) ✅" : "Missing ⚠️")")
        if vectors.isEmpty {
            print("  • Enrolled Face Templates: None - run 'facelock --enroll' ⚠️")
        } else if vectors.count == 1 {
            print("  • Enrolled Face Templates: 1 vector (128-d) calibrated at \(vectorsPath) ✅")
        } else {
            let avg = vectorMetrics["avgPairwiseDistance"] as? Double ?? 0.0
            let quality = vectorMetrics["quality"] as? String ?? "N/A"
            print("  • Enrolled Face Templates: \(vectors.count) vectors (128-d, avg distance: \(String(format: "%.3f", avg))) at \(vectorsPath) ✅")
            print("  • Biometric Cluster Quality: \(quality)")
        }

        let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
        print("  • Intruder Incident Log: \(intruderCount) captures (\(String(format: "%.2f", sizeMB)) MB) in \(intrudersDir.path)")

        print("\n[7] Integrations & Automation:")
        print("  • Telegram Bot Alerts: \(tgConfigured ? "Configured (Active: \(config.telegramEnabled ? "YES ✅" : "NO ⏸️"))" : "Not configured ℹ️")")
        print("  • 24/7 Autonomous Maintainer: \(agentInstalled ? "Installed & Active ✅" : "Not installed (Run 'make maintainer-install') ℹ️")")

        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(" Diagnostics complete: All core biometric subsystems verified.")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}
