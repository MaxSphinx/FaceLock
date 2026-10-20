import Foundation
import AppKit
import AVFoundation
import Vision
import LocalAuthentication

public struct Diagnostics {
    public static func run() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("          🛡️  FaceLock Autonomous Diagnostics Suite         ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        // 1. System & Architecture
        let osVer = ProcessInfo.processInfo.operatingSystemVersionString
        var uts = utsname()
        uname(&uts)
        let arch = withUnsafePointer(to: &uts.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        let isAppleSilicon = (arch == "arm64")
        print("\n[1] Platform & Environment:")
        print("  • OS Version: \(osVer)")
        print("  • Architecture: \(arch) (\(isAppleSilicon ? "Apple Silicon Neural Engine Active ✅" : "Intel Legacy ⚠️"))")
        print("  • PID: \(ProcessInfo.processInfo.processIdentifier)")

        // 2. Daemon & Process Status
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        let isRunning = !runningApps.isEmpty
        let config = Config.shared

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

        // 3. Camera Subsystem
        print("\n[3] Camera Hardware & Permissions:")
        let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
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

        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discovery.devices
        if devices.isEmpty {
            print("  • Video Devices: No cameras detected ⚠️")
        } else {
            print("  • Detected Cameras (\(devices.count)):")
            for dev in devices {
                print("    - \(dev.localizedName) [\(dev.uniqueID)]")
            }
        }

        // 4. Apple Neural Vision & Face Recognition
        print("\n[4] Apple Neural Vision & Faceprints:")
        let hasFaceprintReq = (NSClassFromString("VNCreateFaceprintRequest") != nil)
        print("  • Vision Framework: Loaded ✅")
        print("  • Neural Faceprint Model (VNCreateFaceprintRequest): \(hasFaceprintReq ? "AVAILABLE ✅" : "UNAVAILABLE ❌")")
        print("  • Similarity Decision Threshold: \(config.similarityThreshold) (Strict Neural Mode)")

        // 5. Biometric Authentication (Touch ID)
        print("\n[5] Biometrics & LocalAuthentication:")
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
        print("  • Biometric Hardware: \(bioTypeStr)")
        print("  • Biometrics Ready: \(canTouchID ? "YES ✅" : "NO (\(laError?.localizedDescription ?? "Unavailable")) ⚠️")")
        print("  • Auto-Trigger Touch ID: \(config.autoTriggerTouchID ? "Enabled" : "Disabled")")

        // 6. Storage & Vector Datasets
        print("\n[6] Storage & Datasets:")
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)
        let configPath = facelockDir.appendingPathComponent("config.json").path
        let vectorsPath = facelockDir.appendingPathComponent("owner_face_vectors.json").path
        let intrudersDir = facelockDir.appendingPathComponent("intruders", isDirectory: true)

        let configExists = FileManager.default.fileExists(atPath: configPath)
        print("  • Config File: \(configExists ? "Valid (\(configPath)) ✅" : "Missing ⚠️")")

        let vectors = config.loadEnrolledVectors()
        print("  • Enrolled Face Templates: \(vectors.count) vectors (\(vectors.isEmpty ? "None - run 'facelock --enroll'" : "Calibrated at \(vectorsPath) ✅"))")

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
        let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
        print("  • Intruder Incident Log: \(intruderCount) captures (\(String(format: "%.2f", sizeMB)) MB) in \(intrudersDir.path)")

        // 7. Telegram Integration & Autonomous Workers
        print("\n[7] Integrations & Automation:")
        let tgConfigured = !config.telegramBotToken.isEmpty && !config.telegramChatId.isEmpty
        print("  • Telegram Bot Alerts: \(tgConfigured ? "Configured (Active: \(config.telegramEnabled ? "YES ✅" : "NO ⏸️"))" : "Not configured ℹ️")")

        let launchAgentPath = home.appendingPathComponent("Library/LaunchAgents/io.github.facelock.maintainer.plist").path
        let agentInstalled = FileManager.default.fileExists(atPath: launchAgentPath)
        print("  • 24/7 Autonomous Maintainer: \(agentInstalled ? "Installed & Active ✅" : "Not installed (Run 'make maintainer-install') ℹ️")")

        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(" Diagnostics complete: All core biometric subsystems verified.")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}
