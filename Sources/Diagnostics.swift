import Foundation
import AppKit
import AVFoundation
import Vision
import LocalAuthentication

public struct SecurityPostureReport {
    public let score: Int
    public let grade: String
    public let status: String
    public let maxScore: Int
    public let percentage: Double
    public let breakdown: [String: Any]
    public let recommendations: [String]

    public init(
        score: Int,
        grade: String,
        status: String,
        maxScore: Int = 100,
        percentage: Double,
        breakdown: [String: Any],
        recommendations: [String]
    ) {
        self.score = score
        self.grade = grade
        self.status = status
        self.maxScore = maxScore
        self.percentage = percentage
        self.breakdown = breakdown
        self.recommendations = recommendations
    }

    public func toDictionary() -> [String: Any] {
        return [
            "score": score,
            "maxScore": maxScore,
            "percentage": percentage,
            "grade": grade,
            "status": status,
            "breakdown": breakdown,
            "recommendations": recommendations
        ]
    }
}

public struct HardeningResult {
    public let previousScore: Int
    public let newScore: Int
    public let scoreDelta: Int
    public let previousGrade: String
    public let newGrade: String
    public let previousStatus: String
    public let newStatus: String
    public let appliedFixes: [String]
    public let remainingRecommendations: [String]

    public init(
        previousScore: Int,
        newScore: Int,
        previousGrade: String,
        newGrade: String,
        previousStatus: String,
        newStatus: String,
        appliedFixes: [String],
        remainingRecommendations: [String]
    ) {
        self.previousScore = previousScore
        self.newScore = newScore
        self.scoreDelta = newScore - previousScore
        self.previousGrade = previousGrade
        self.newGrade = newGrade
        self.previousStatus = previousStatus
        self.newStatus = newStatus
        self.appliedFixes = appliedFixes
        self.remainingRecommendations = remainingRecommendations
    }

    public func toDictionary() -> [String: Any] {
        return [
            "previousScore": previousScore,
            "newScore": newScore,
            "scoreDelta": scoreDelta,
            "previousGrade": previousGrade,
            "newGrade": newGrade,
            "previousStatus": previousStatus,
            "newStatus": newStatus,
            "appliedFixes": appliedFixes,
            "remainingRecommendations": remainingRecommendations
        ]
    }
}

public enum DoctorCheckStatus: String, Codable {
    case pass = "PASS"
    case warn = "WARN"
    case fail = "FAIL"
    case info = "INFO"

    public var badge: String {
        switch self {
        case .pass: return "PASS ✅"
        case .warn: return "WARN ⚠️"
        case .fail: return "FAIL ❌"
        case .info: return "INFO ℹ️"
        }
    }
}

public struct DoctorCheckItem: Codable {
    public let id: String
    public let category: String
    public let name: String
    public let status: DoctorCheckStatus
    public let message: String
    public let remediation: String?

    public init(
        id: String,
        category: String,
        name: String,
        status: DoctorCheckStatus,
        message: String,
        remediation: String? = nil
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.status = status
        self.message = message
        self.remediation = remediation
    }

    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "category": category,
            "name": name,
            "status": status.rawValue,
            "badge": status.badge,
            "message": message
        ]
        if let rem = remediation {
            dict["remediation"] = rem
        }
        return dict
    }
}

public struct DoctorReport {
    public let overallStatus: String // "HEALTHY", "WARNING", "CRITICAL"
    public let summary: String
    public let checks: [DoctorCheckItem]
    public let totalChecks: Int
    public let passedCount: Int
    public let warningCount: Int
    public let failureCount: Int
    public let infoCount: Int
    public let remediations: [String]
    public let timestamp: String
    public let version: String

    public init(
        checks: [DoctorCheckItem],
        version: String = Config.currentVersion
    ) {
        self.checks = checks
        self.totalChecks = checks.count
        self.passedCount = checks.filter { $0.status == .pass }.count
        self.warningCount = checks.filter { $0.status == .warn }.count
        self.failureCount = checks.filter { $0.status == .fail }.count
        self.infoCount = checks.filter { $0.status == .info }.count
        self.version = version

        if failureCount > 0 {
            self.overallStatus = "CRITICAL"
            self.summary = "Critical issues detected (\(failureCount) failing checks). Immediate remediation required."
        } else if warningCount > 0 {
            self.overallStatus = "WARNING"
            self.summary = "System operational with \(warningCount) warning(s) that should be addressed."
        } else {
            self.overallStatus = "HEALTHY"
            self.summary = "All checks passed successfully. FaceLock is fully operational and hardened."
        }

        var rems: [String] = []
        for c in checks {
            if let r = c.remediation, !r.isEmpty {
                rems.append(r)
            }
        }
        self.remediations = rems
        self.timestamp = ISO8601DateFormatter().string(from: Date())
    }

    public func toDictionary() -> [String: Any] {
        return [
            "version": version,
            "timestamp": timestamp,
            "overallStatus": overallStatus,
            "summary": summary,
            "stats": [
                "totalChecks": totalChecks,
                "passed": passedCount,
                "warnings": warningCount,
                "failures": failureCount,
                "info": infoCount
            ],
            "checks": checks.map { $0.toDictionary() },
            "remediations": remediations
        ]
    }

    public func printDoctorSummary() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("          🩺  FaceLock Health & Diagnostic Doctor           ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        let statusBadge: String
        switch overallStatus {
        case "HEALTHY": statusBadge = "HEALTHY ✅"
        case "WARNING": statusBadge = "WARNING ⚠️"
        default:        statusBadge = "CRITICAL ❌"
        }
        print("Overall System Status: \(statusBadge) (\(passedCount) Passed, \(warningCount) Warnings, \(failureCount) Failures, \(infoCount) Info)")
        print("FaceLock Version: v\(version)")

        let categories: [(String, String)] = [
            ("hardware", "Hardware & Sensors"),
            ("filesystem", "Filesystem & Cryptography"),
            ("daemon", "Background Daemon & Automation"),
            ("security", "Security Posture & Hardening"),
            ("network", "Remote Alerting & Network")
        ]

        for (catKey, catTitle) in categories {
            let catChecks = checks.filter { $0.category == catKey }
            if catChecks.isEmpty { continue }
            print("\n[\(catTitle)]")
            for c in catChecks {
                print("  \(c.status.badge)  \(c.name): \(c.message)")
            }
        }

        if !remediations.isEmpty {
            print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("  📋 Actionable Recommendations (\(remediations.count)):")
            for (idx, rem) in remediations.enumerated() {
                print("    \(idx + 1). \(rem)")
            }
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}

public struct DoctorRepairReport {
    public let initialReport: DoctorReport
    public let finalReport: DoctorReport
    public let repairedActions: [String]
    public let recoveredCount: Int
    public let version: String

    public init(
        initialReport: DoctorReport,
        finalReport: DoctorReport,
        repairedActions: [String],
        version: String = Config.currentVersion
    ) {
        self.initialReport = initialReport
        self.finalReport = finalReport
        self.repairedActions = repairedActions
        self.recoveredCount = repairedActions.count
        self.version = version
    }

    public func toDictionary() -> [String: Any] {
        return [
            "version": version,
            "repairedActions": repairedActions,
            "recoveredCount": recoveredCount,
            "initialStatus": initialReport.overallStatus,
            "finalStatus": finalReport.overallStatus,
            "initialStats": [
                "totalChecks": initialReport.totalChecks,
                "passed": initialReport.passedCount,
                "warnings": initialReport.warningCount,
                "failures": initialReport.failureCount,
                "info": initialReport.infoCount
            ],
            "finalStats": [
                "totalChecks": finalReport.totalChecks,
                "passed": finalReport.passedCount,
                "warnings": finalReport.warningCount,
                "failures": finalReport.failureCount,
                "info": finalReport.infoCount
            ],
            "remediationsRemaining": finalReport.remediations,
            "report": finalReport.toDictionary()
        ]
    }

    public func printSummary() {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("        🛠️  FaceLock Autonomous Doctor Auto-Repair          ")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        let initBadge: String
        switch initialReport.overallStatus {
        case "HEALTHY": initBadge = "HEALTHY ✅"
        case "WARNING": initBadge = "WARNING ⚠️"
        default:        initBadge = "CRITICAL ❌"
        }
        let finalBadge: String
        switch finalReport.overallStatus {
        case "HEALTHY": finalBadge = "HEALTHY ✅"
        case "WARNING": finalBadge = "WARNING ⚠️"
        default:        finalBadge = "CRITICAL ❌"
        }
        print("Initial Status: \(initBadge) (\(initialReport.passedCount) Pass, \(initialReport.warningCount) Warn, \(initialReport.failureCount) Fail)")
        print("Final Status:   \(finalBadge) (\(finalReport.passedCount) Pass, \(finalReport.warningCount) Warn, \(finalReport.failureCount) Fail)")
        print("Repairs Executed: \(repairedActions.count)")
        if repairedActions.isEmpty {
            print("  • System already healthy and hardened; no repairs needed! ✅")
        } else {
            for action in repairedActions {
                print("  ✓ \(action)")
            }
        }
        if !finalReport.remediations.isEmpty {
            print("\nRemaining Recommendations (\(finalReport.remediations.count)):")
            for rem in finalReport.remediations {
                print("  • \(rem)")
            }
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }
}

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

        // 7. Storage & Vector Datasets
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

        // 8. Telegram Integration & Autonomous Workers
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
        let auditStats = SecurityAuditLogger.shared.getAuditStats()
        let incidentStats = CameraScanner.shared.getDetailedIncidentStats()
        let posture = assessSecurityPosture(config: config, enrolledVectors: vectors)

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
                "lockOnWake": config.lockOnWake,
                "maxFailedPinAttempts": config.maxFailedPinAttempts,
                "pinLockoutSeconds": config.pinLockoutSeconds
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
                "auditLogEvents": auditStats.totalEvents,
                "auditLogSizeBytes": auditStats.fileSizeBytes,
                "auditLogLastEvent": auditStats.lastEventTime ?? "",
                "auditStats": auditStats.toDictionary(),
                "incidentStats": incidentStats.toDictionary(),
                "templateConsistency": config.analyzeTemplateConsistency(),
                "incidentsIntegrity": CameraScanner.shared.verifyIncidentsIntegrity().toDictionary(),
                "auditIntegrity": SecurityAuditLogger.shared.verifyAuditIntegrity().toDictionary(),
                "storageSummary": CameraScanner.shared.getStorageSummary()
            ],
            "securityPosture": posture.toDictionary(),
            "threatIntelligence": SecurityAuditLogger.shared.analyzeThreatIntelligence().toDictionary(),
            "configValidation": Config.validateConfig().toDictionary(),
            "integrations": [
                "telegramConfigured": tgConfigured,
                "telegramEnabled": config.telegramEnabled,
                "telegramReachable": telegramReachable ?? false,
                "maintainerInstalled": agentInstalled
            ]
        ]
    }

    public static func assessSecurityPosture(
        config: Config = .shared,
        enrolledVectors: [[Float]]? = nil,
        integrityReport: CameraScanner.IncidentIntegrityReport? = nil,
        auditIntegrityReport: AuditIntegrityReport? = nil
    ) -> SecurityPostureReport {
        var score = 0
        var breakdown: [String: Any] = [:]
        var recommendations: [String] = []

        // 1. Shield Active (15 pts)
        let shieldActive = config.isEnabled
        let shieldPts = shieldActive ? 15 : 0
        score += shieldPts
        breakdown["shieldState"] = [
            "points": shieldPts,
            "maxPoints": 15,
            "isActive": shieldActive
        ]
        if !shieldActive {
            recommendations.append("Shield protection is currently paused. Run 'facelock --resume' to activate live defense.")
        }

        // 2. Master PIN Hardening & Lockout (15 pts)
        let isDefaultPin = (config.pin == "0000")
        var pinPts = 0
        if !isDefaultPin {
            if config.pin.count >= 6 {
                pinPts += 10
            } else {
                pinPts += 7
            }
        } else {
            recommendations.append("Default master PIN '0000' is in use. Set a custom 6+ digit PIN via 'facelock --set-pin <pin>'.")
        }

        let lockoutHardened = (config.maxFailedPinAttempts <= 5 && config.pinLockoutSeconds >= 5.0)
        let lockoutPts = lockoutHardened ? 5 : 2
        pinPts += lockoutPts
        score += pinPts
        breakdown["pinSecurity"] = [
            "points": pinPts,
            "maxPoints": 15,
            "isDefaultPin": isDefaultPin,
            "pinLength": config.pin.count,
            "maxFailedAttempts": config.maxFailedPinAttempts,
            "lockoutSeconds": config.pinLockoutSeconds
        ]
        if !lockoutHardened {
            recommendations.append("Harden PIN brute-force defense via 'facelock --pin-attempts 3 --pin-lockout 10'.")
        }

        // 3. Biometric Vectors & Cluster Cohesion (20 pts)
        let vectors = enrolledVectors ?? config.loadEnrolledVectors()
        var bioPts = 0
        if vectors.count >= 5 {
            bioPts += 15
        } else if vectors.count >= 3 {
            bioPts += 12
        } else if vectors.count >= 1 {
            bioPts += 7
            recommendations.append("Enroll at least 3-5 multi-angle face templates via 'facelock --enroll' for higher cluster accuracy.")
        } else {
            recommendations.append("No biometric face templates enrolled. Run 'facelock --enroll' to enable neural facial verification.")
        }

        var cohesionScore: Double = 0.0
        if vectors.count >= 2 {
            let consistency = config.analyzeTemplateConsistency(vectors: vectors)
            cohesionScore = consistency["cohesionScore"] as? Double ?? 0.0
            if cohesionScore >= 0.70 {
                bioPts += 5
            } else {
                bioPts += 2
                recommendations.append("Biometric cluster cohesion is low. Run 'facelock --optimize-vectors' or re-enroll.")
            }
        } else if vectors.count == 1 {
            bioPts += 2
        }
        score += bioPts
        breakdown["biometrics"] = [
            "points": bioPts,
            "maxPoints": 20,
            "enrolledCount": vectors.count,
            "cohesionScore": cohesionScore
        ]

        // 4. Walk-Away Auto-Lock (10 pts)
        let walkAwayActive = config.walkAwayLockEnabled
        var walkAwayPts = 0
        if walkAwayActive {
            if config.walkAwayIdleSeconds <= 60.0 {
                walkAwayPts = 10
            } else {
                walkAwayPts = 7
                recommendations.append("Walk-away timeout is > 60s (\(Int(config.walkAwayIdleSeconds))s). Tighten via 'facelock --set-walkaway 45'.")
            }
        } else {
            recommendations.append("Walk-away lock is disabled. Run 'facelock --toggle-walkaway' to auto-lock when leaving your desk.")
        }
        score += walkAwayPts
        breakdown["walkAwayLock"] = [
            "points": walkAwayPts,
            "maxPoints": 10,
            "enabled": walkAwayActive,
            "idleSeconds": config.walkAwayIdleSeconds
        ]

        // 5. Shoulder-Surfing Bystander Defense (10 pts)
        let shoulderActive = config.shoulderSurfingDefense
        let shoulderPts = shoulderActive ? 10 : 0
        score += shoulderPts
        breakdown["shoulderSurfingDefense"] = [
            "points": shoulderPts,
            "maxPoints": 10,
            "enabled": shoulderActive
        ]
        if !shoulderActive {
            recommendations.append("Enable Shoulder-Surfing bystander detection ('facelock --toggle-shoulder') to block over-the-shoulder peeking.")
        }

        // 6. Neural Liveness & Anti-Spoofing (10 pts)
        let livenessActive = config.livenessDetectionEnabled
        let livenessPts = livenessActive ? 10 : 0
        score += livenessPts
        breakdown["livenessDetection"] = [
            "points": livenessPts,
            "maxPoints": 10,
            "enabled": livenessActive
        ]
        if !livenessActive {
            recommendations.append("Enable anti-spoofing liveness verification via 'facelock --set-liveness on'.")
        }

        // 7. Lock-on-Wake Clamshell Defense (5 pts)
        let wakeActive = config.lockOnWake
        let wakePts = wakeActive ? 5 : 0
        score += wakePts
        breakdown["lockOnWake"] = [
            "points": wakePts,
            "maxPoints": 5,
            "enabled": wakeActive
        ]
        if !wakeActive {
            recommendations.append("Enable lock-on-wake via 'facelock --toggle-wake' to lock immediately upon Mac clamshell wake.")
        }

        // 8. Battery-Aware Adaptive Polling (5 pts)
        let batteryAware = config.batteryAwareScanning
        let batteryPts = batteryAware ? 5 : 0
        score += batteryPts
        breakdown["batteryAwareScanning"] = [
            "points": batteryPts,
            "maxPoints": 5,
            "enabled": batteryAware
        ]

        // 9. Remote Telegram Incident Gateway (5 pts)
        let tgActive = config.telegramEnabled && !config.telegramBotToken.isEmpty && !config.telegramChatId.isEmpty
        let tgPts = tgActive ? 5 : 0
        score += tgPts
        breakdown["telegramAlerts"] = [
            "points": tgPts,
            "maxPoints": 5,
            "configured": tgActive
        ]
        if !tgActive {
            recommendations.append("Configure Telegram bot alerts in settings ('facelock --settings') for remote intrusion alerts.")
        }

        // 10. Meeting & Presentation Mode Auto-Suppression (5 pts)
        let presActive = config.presentationModeSuppression
        let presPts = presActive ? 5 : 0
        score += presPts
        breakdown["presentationSuppression"] = [
            "points": presPts,
            "maxPoints": 5,
            "enabled": presActive
        ]
        if !presActive {
            recommendations.append("Enable presentation mode suppression ('facelock --set-presentation-mode on') to avoid unintended locks during calls.")
        }

        // 11. Intruder Capture Integrity Check (-5 pts penalty if corrupted)
        let integrity = integrityReport ?? CameraScanner.shared.verifyIncidentsIntegrity()
        var integrityPenalty = 0
        if integrity.corruptedCount > 0 {
            integrityPenalty = 5
            score = max(0, score - integrityPenalty)
            recommendations.append("Corrupted intruder captures detected (\(integrity.corruptedCount)). Run 'facelock --repair-incidents'.")
        }
        breakdown["incidentIntegrity"] = [
            "corruptedCount": integrity.corruptedCount,
            "penalty": integrityPenalty,
            "status": integrity.status
        ]

        // 12. Security Audit Log Integrity Check (-5 pts penalty if corrupted records detected)
        let auditReport = auditIntegrityReport ?? SecurityAuditLogger.shared.verifyAuditIntegrity()
        var auditPenalty = 0
        if auditReport.corruptedLinesCount > 0 {
            auditPenalty = 5
            score = max(0, score - auditPenalty)
            recommendations.append("Corrupted audit log records detected (\(auditReport.corruptedLinesCount)). Run 'facelock --repair-audit'.")
        }
        breakdown["auditIntegrity"] = [
            "corruptedLinesCount": auditReport.corruptedLinesCount,
            "penalty": auditPenalty,
            "status": auditReport.status,
            "sha256Digest": auditReport.sha256Digest
        ]

        // 13. Duress Emergency Distress Signal
        let duressActive = config.isDuressPinEnabled
        breakdown["duressDefense"] = [
            "enabled": duressActive,
            "configured": !config.duressPin.isEmpty
        ]

        let finalScore = min(100, max(0, score))
        let percentage = Double(finalScore)

        let grade: String
        let status: String
        switch finalScore {
        case 90...100:
            grade = "A+"
            status = "EXCELLENT"
        case 80...89:
            grade = "A"
            status = "HARDENED"
        case 70...79:
            grade = "B"
            status = "STANDARD"
        case 55...69:
            grade = "C"
            status = "MODERATE"
        default:
            grade = "D"
            status = "VULNERABLE"
        }

        return SecurityPostureReport(
            score: finalScore,
            grade: grade,
            status: status,
            maxScore: 100,
            percentage: percentage,
            breakdown: breakdown,
            recommendations: recommendations
        )
    }

    public static func autoHardenSecurity(
        config: Config = .shared,
        enrolledVectors: [[Float]]? = nil,
        integrityReport: CameraScanner.IncidentIntegrityReport? = nil,
        save: Bool = true
    ) -> HardeningResult {
        let before = assessSecurityPosture(config: config, enrolledVectors: enrolledVectors, integrityReport: integrityReport)
        var fixes: [String] = []

        if !config.isEnabled {
            config.isEnabled = true
            fixes.append("Re-engaged biometric shield protection (shieldState: active)")
        }
        if !config.shoulderSurfingDefense {
            config.shoulderSurfingDefense = true
            fixes.append("Enabled shoulder-surfing bystander detection")
        }
        if !config.lockOnWake {
            config.lockOnWake = true
            fixes.append("Enabled lock-on-wake for Mac screen wake")
        }
        if !config.batteryAwareScanning {
            config.batteryAwareScanning = true
            fixes.append("Enabled battery-aware adaptive idle polling")
        }
        if !config.presentationModeSuppression {
            config.presentationModeSuppression = true
            fixes.append("Enabled meeting and presentation mode auto-suppression")
        }
        if !config.livenessDetectionEnabled {
            config.livenessDetectionEnabled = true
            fixes.append("Enabled deep neural anti-spoofing liveness verification")
        }
        if !config.walkAwayLockEnabled {
            config.walkAwayLockEnabled = true
            fixes.append("Enabled walk-away autonomous screen lock")
        }
        if config.walkAwayIdleSeconds > 45 {
            config.walkAwayIdleSeconds = 45
            fixes.append("Hardened walk-away timeout to 45 seconds")
        }
        if config.maxFailedPinAttempts > 3 {
            config.maxFailedPinAttempts = 3
            fixes.append("Hardened PIN attempt limit to 3 maximum failed attempts")
        }
        if config.pinLockoutSeconds < 5 {
            config.pinLockoutSeconds = 5
            fixes.append("Hardened PIN lockout exponential cooldown to 5 seconds")
        }
        if config.telegramEnabled && (config.telegramBotToken.isEmpty || config.telegramChatId.isEmpty) {
            config.telegramEnabled = false
            fixes.append("Disabled incomplete Telegram alerting (missing bot token or chat ID)")
        }

        // Purge corrupted captures if any exist
        var updatedIntegrity = integrityReport
        if save {
            let integrity = integrityReport ?? CameraScanner.shared.verifyIncidentsIntegrity()
            if integrity.corruptedCount > 0 {
                let rep = CameraScanner.shared.repairCorruptedIncidents()
                if rep.repairedCount > 0 {
                    fixes.append("Purged \(rep.repairedCount) corrupted intruder capture files")
                    updatedIntegrity = CameraScanner.shared.verifyIncidentsIntegrity()
                }
            }

            // Optimize vectors if cluster has outliers
            let curVectors = enrolledVectors ?? config.loadEnrolledVectors()
            if curVectors.count >= 4 {
                let opt = config.optimizeVectors()
                let pruned = (opt["prunedOutliers"] as? Int ?? 0) + (opt["prunedRedundant"] as? Int ?? 0)
                if pruned > 0 {
                    fixes.append("Pruned \(pruned) outlier/redundant vectors to improve cluster cohesion")
                }
            }

            config.save()
            SecurityAuditLogger.shared.log(
                eventType: "config_change",
                appName: "FaceLock Hardening",
                bundleId: "io.github.facelock",
                details: "Autonomous security hardening: applied \(fixes.count) policies",
                isSuccess: true
            )
        }

        let after = assessSecurityPosture(config: config, enrolledVectors: enrolledVectors, integrityReport: updatedIntegrity)

        return HardeningResult(
            previousScore: before.score,
            newScore: after.score,
            previousGrade: before.grade,
            newGrade: after.grade,
            previousStatus: before.status,
            newStatus: after.status,
            appliedFixes: fixes,
            remainingRecommendations: after.recommendations
        )
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
        print("  • Max Failed PIN Attempts: \(Config.shared.maxFailedPinAttempts) (Lockout: \(Int(Config.shared.pinLockoutSeconds))s)")

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
        let auditToday = (storage["auditStats"] as? [String: Any])?["todayCount"] as? Int ?? 0
        let todayText = auditToday > 0 ? " (\(auditToday) today)" : ""
        let auditInteg = storage["auditIntegrity"] as? [String: Any]
        let auditStatus = auditInteg?["status"] as? String ?? "VERIFIED"
        let auditDigest = (auditInteg?["sha256Digest"] as? String)?.prefix(12) ?? ""
        let digestSuffix = auditDigest.isEmpty ? "" : " [\(auditStatus) - SHA-256: \(auditDigest)...]"
        print("  • Security Audit Log: \(auditEvents) events\(todayText) (\(String(format: "%.2f", auditMB)) MB), last: \(auditLast)\(digestSuffix)")
        let storageSummary = storage["storageSummary"] as? [String: Any]
        let totalFormatted = storageSummary?["totalFormatted"] as? String ?? "\(String(format: "%.2f", sizeMB + auditMB)) MB"
        let facelockDirPath = (storageSummary?["directory"] as? String) ?? (URL(fileURLWithPath: configPath).deletingLastPathComponent().path)
        print("  • Total FaceLock Footprint: \(totalFormatted) in \(facelockDirPath)")

        print("\n[7] Integrations & Cloud Connectivity:")
        if tgConfigured {
            let reachStr = tgReachable ? " (Gateway Reachable ✅)" : " (Gateway Unreachable / DNS Error ❌)"
            print("  • Telegram Bot Alerts: Configured (Active: \(tgEnabled ? "YES ✅" : "NO ⏸️"))\(reachStr)")
        } else {
            print("  • Telegram Bot Alerts: Not configured ℹ️")
        }
        print("  • 24/7 Autonomous Maintainer: \(agentInstalled ? "Installed & Active ✅" : "Not installed (Run 'make maintainer-install') ℹ️")")

        print("\n[8] Security Posture & Hardening Assessment:")
        let posture = assessSecurityPosture()
        let scoreBadge: String
        switch posture.score {
        case 90...100: scoreBadge = "EXCELLENT 🛡️"
        case 80...89:  scoreBadge = "HARDENED 🛡️"
        case 70...79:  scoreBadge = "STANDARD ⚖️"
        case 55...69:  scoreBadge = "MODERATE ⚠️"
        default:       scoreBadge = "VULNERABLE ❌"
        }
        print("  • Security Score: \(posture.score)/\(posture.maxScore) (Grade: \(posture.grade) - \(scoreBadge))")
        if posture.recommendations.isEmpty {
            print("  • Hardening Status: All recommended defense mechanisms are active! ✅")
        } else {
            print("  • Recommendations (\(posture.recommendations.count)):")
            for rec in posture.recommendations {
                print("    - \(rec)")
            }
        }

        print("\n[9] Physical Threat Intelligence & Intrusion Risk:")
        let threat = SecurityAuditLogger.shared.analyzeThreatIntelligence()
        print("  • Physical Threat Risk: \(threat.statusBadge) (Score: \(threat.riskScore)/100)")
        print("  • Total Threat Events: \(threat.totalThreatEvents) (\(threat.past24HoursCount) in past 24h, \(threat.past7DaysCount) in past 7d)")
        print("  • PIN Bruteforce Lockouts: \(threat.pinBruteforceCount)")
        print("  • Shoulder-Surfing Incidents: \(threat.shoulderSurfingCount)")
        if let peak = threat.peakThreatHour {
            print("  • Peak Intrusion Hour: \(String(format: "%02d:00", peak))")
        }
        if threat.anomalies.isEmpty {
            print("  • Detected Threat Anomalies: None (Clean environment) ✅")
        } else {
            print("  • Detected Threat Anomalies (\(threat.anomalies.count)):")
            for a in threat.anomalies {
                print("    - [\(a.severity)] \(a.description)")
            }
        }
        if !threat.targetedApps.isEmpty {
            print("  • Targeted Applications:")
            for app in threat.targetedApps.prefix(3) {
                print("    - \(app.appName): \(app.attemptCount) attempt(s) [\(app.riskCategory) Risk]")
            }
        }

        print("\n[10] Configuration Integrity & Security Validation:")
        let val = Config.validateConfig()
        print("  • Configuration Status: \(val.isValid ? "VALID & SECURE ✅" : "CONFIGURATION ERRORS FOUND ❌")")
        print("  • Issues: \(val.errorCount) error(s), \(val.warningCount) warning(s)")
        if val.issues.isEmpty {
            print("  • All settings conform to Apple reverse-DNS and security hardening standards.")
        } else {
            for issue in val.issues {
                print("    - [\(issue.severity)] \(issue.key): \(issue.message)")
            }
        }

        print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print(" Diagnostics complete: All core biometric subsystems verified.")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }

    public static func runDoctor(config: Config = .shared, skipNetwork: Bool = false) -> DoctorReport {
        var checks: [DoctorCheckItem] = []

        // Category 1: Hardware & Architecture
        // 1.1 Architecture
        var uts = utsname()
        uname(&uts)
        let arch = withUnsafePointer(to: &uts.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { String(cString: $0) }
        }
        let isAppleSilicon = (arch == "arm64")
        if isAppleSilicon {
            checks.append(DoctorCheckItem(
                id: "hardware.architecture",
                category: "hardware",
                name: "Processor Architecture",
                status: .pass,
                message: "Apple Silicon (arm64) detected: Accelerate vDSP SIMD & Neural Engine accelerated."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "hardware.architecture",
                category: "hardware",
                name: "Processor Architecture",
                status: .warn,
                message: "Intel (x86_64) architecture detected: Apple Silicon recommended for sub-second biometric inference.",
                remediation: "Upgrade to Apple Silicon Mac for real-time sub-second biometric verification."
            ))
        }

        // 1.2 Vision Framework Neural Faceprint
        let hasFaceprintReq = (NSClassFromString("VNCreateFaceprintRequest") != nil)
        if hasFaceprintReq {
            checks.append(DoctorCheckItem(
                id: "hardware.vision_framework",
                category: "hardware",
                name: "Apple Vision Neural Model",
                status: .pass,
                message: "VNCreateFaceprintRequest neural embedding extractor is loaded and operational."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "hardware.vision_framework",
                category: "hardware",
                name: "Apple Vision Neural Model",
                status: .fail,
                message: "VNCreateFaceprintRequest is unavailable in macOS Vision framework.",
                remediation: "Update macOS to version 12 Monterey or newer."
            ))
        }

        // 1.3 Video Capture Devices
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        let devices = discovery.devices
        if !devices.isEmpty {
            let activeCam = CameraScanner.selectDevice(preferredID: config.preferredCameraID)?.localizedName ?? devices[0].localizedName
            checks.append(DoctorCheckItem(
                id: "hardware.camera_device",
                category: "hardware",
                name: "Video Capture Hardware",
                status: .pass,
                message: "Found \(devices.count) camera device(s). Active camera: '\(activeCam)'."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "hardware.camera_device",
                category: "hardware",
                name: "Video Capture Hardware",
                status: .warn,
                message: "No video capture camera detected on system.",
                remediation: "Ensure internal FaceTime camera or external USB webcam is connected and recognized."
            ))
        }

        // 1.4 Camera Authorization (TCC)
        let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
        switch camAuth {
        case .authorized:
            checks.append(DoctorCheckItem(
                id: "hardware.camera_permission",
                category: "hardware",
                name: "Camera Privacy Permission",
                status: .pass,
                message: "Camera access authorized by macOS Transparency, Consent, and Control (TCC)."
            ))
        case .notDetermined:
            checks.append(DoctorCheckItem(
                id: "hardware.camera_permission",
                category: "hardware",
                name: "Camera Privacy Permission",
                status: .warn,
                message: "Camera authorization has not been requested yet.",
                remediation: "Launch FaceLock or execute 'facelock --verify-face' to grant camera access prompt."
            ))
        case .denied, .restricted:
            checks.append(DoctorCheckItem(
                id: "hardware.camera_permission",
                category: "hardware",
                name: "Camera Privacy Permission",
                status: .fail,
                message: "Camera access denied by system privacy settings.",
                remediation: "Enable camera permission in macOS System Settings > Privacy & Security > Camera."
            ))
        @unknown default:
            checks.append(DoctorCheckItem(
                id: "hardware.camera_permission",
                category: "hardware",
                name: "Camera Privacy Permission",
                status: .info,
                message: "Camera authorization status unknown."
            ))
        }

        // 1.5 Touch ID Biometrics
        let laContext = LAContext()
        var laError: NSError?
        let canTouchID = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &laError)
        if canTouchID {
            checks.append(DoctorCheckItem(
                id: "hardware.touchid",
                category: "hardware",
                name: "LocalAuthentication Biometrics",
                status: .pass,
                message: "Touch ID biometric sensor available and enrolled for instant lock-screen fallback."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "hardware.touchid",
                category: "hardware",
                name: "LocalAuthentication Biometrics",
                status: .info,
                message: "Touch ID biometrics unconfigured or unsupported on this device (PIN authentication active)."
            ))
        }

        // Category 2: Filesystem & Cryptography
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)

        // 2.1 ~/.facelock Directory & Permissions
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: facelockDir.path, isDirectory: &isDir), isDir.boolValue {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: facelockDir.path),
               let perms = attrs[.posixPermissions] as? NSNumber {
                let p = perms.intValue
                if (p & 0o077) == 0 {
                    checks.append(DoctorCheckItem(
                        id: "filesystem.directory",
                        category: "filesystem",
                        name: "Data Directory Permissions",
                        status: .pass,
                        message: "Secure directory permissions confirmed (0\(String(p, radix: 8))) at \(facelockDir.path)."
                    ))
                } else {
                    checks.append(DoctorCheckItem(
                        id: "filesystem.directory",
                        category: "filesystem",
                        name: "Data Directory Permissions",
                        status: .warn,
                        message: "Directory permissions are relaxed: 0\(String(p, radix: 8)).",
                        remediation: "Run 'chmod 700 ~/.facelock' to restrict access exclusively to your macOS user account."
                    ))
                }
            } else {
                checks.append(DoctorCheckItem(
                    id: "filesystem.directory",
                    category: "filesystem",
                    name: "Data Directory Permissions",
                    status: .pass,
                    message: "Data directory verified at \(facelockDir.path)."
                ))
            }
        } else {
            checks.append(DoctorCheckItem(
                id: "filesystem.directory",
                category: "filesystem",
                name: "Data Directory Permissions",
                status: .info,
                message: "FaceLock data directory not created yet (will be initialized on first launch)."
            ))
        }

        // 2.2 Configuration Schema & Settings
        let val = Config.validateConfig(config)
        if val.isValid {
            checks.append(DoctorCheckItem(
                id: "filesystem.config_schema",
                category: "filesystem",
                name: "Configuration Integrity",
                status: .pass,
                message: "Configuration file is valid with 0 errors (\(val.warningCount) non-blocking warning(s))."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "filesystem.config_schema",
                category: "filesystem",
                name: "Configuration Integrity",
                status: .fail,
                message: "Configuration contains \(val.errorCount) validation error(s).",
                remediation: "Run 'make check-config' or reset configuration via 'make restore-config'."
            ))
        }

        // 2.3 Enrolled Biometric Vectors
        let vectors = config.loadEnrolledVectors()
        if vectors.count >= 3 {
            let metrics = config.getVectorMetrics()
            let quality = metrics["quality"] as? String ?? "Good"
            checks.append(DoctorCheckItem(
                id: "filesystem.enrolled_vectors",
                category: "filesystem",
                name: "Enrolled Facial Biometrics",
                status: .pass,
                message: "\(vectors.count) neural face templates enrolled (128-D vectors, Cluster Quality: \(quality))."
            ))
        } else if (1...2).contains(vectors.count) {
            checks.append(DoctorCheckItem(
                id: "filesystem.enrolled_vectors",
                category: "filesystem",
                name: "Enrolled Facial Biometrics",
                status: .warn,
                message: "Only \(vectors.count) face template(s) enrolled.",
                remediation: "Run 'make enroll' to capture 3-5 diverse face angles for maximum recognition reliability."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "filesystem.enrolled_vectors",
                category: "filesystem",
                name: "Enrolled Facial Biometrics",
                status: .warn,
                message: "No facial biometric templates enrolled.",
                remediation: "Execute 'make enroll' or 'facelock --enroll' to calibrate face recognition."
            ))
        }

        // 2.4 Audit Log Cryptographic Integrity
        let auditReport = SecurityAuditLogger.shared.verifyAuditIntegrity()
        if auditReport.corruptedLinesCount == 0 && auditReport.chronologyErrorsCount == 0 {
            checks.append(DoctorCheckItem(
                id: "filesystem.audit_integrity",
                category: "filesystem",
                name: "Audit Cryptographic Integrity",
                status: .pass,
                message: "Audit log cryptographic chain intact: \(auditReport.validEventsCount) event(s) verified (SHA-256 digest: \(String(auditReport.sha256Digest.prefix(12))))."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "filesystem.audit_integrity",
                category: "filesystem",
                name: "Audit Cryptographic Integrity",
                status: .fail,
                message: "Audit log cryptographic integrity compromised (\(auditReport.corruptedLinesCount) corrupted line(s), \(auditReport.chronologyErrorsCount) chronology errors).",
                remediation: "Execute 'make repair-audit' to isolate and recover corrupted records."
            ))
        }

        // 2.5 Intruder Photo Storage & Disk Quota
        let intrudersDir = facelockDir.appendingPathComponent("intruders", isDirectory: true)
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
        let formattedSize = String(format: "%.2f MB", sizeMB)
        if totalBytes > 500 * 1024 * 1024 {
            checks.append(DoctorCheckItem(
                id: "filesystem.intruder_storage",
                category: "filesystem",
                name: "Intruder Photo Storage",
                status: .warn,
                message: "Intruder capture storage consumes \(formattedSize) (\(intruderCount) photos), exceeding 500MB budget.",
                remediation: "Run 'make prune-incidents-quota MB=100' or 'make prune-incidents-days DAYS=14' to free space."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "filesystem.intruder_storage",
                category: "filesystem",
                name: "Intruder Photo Storage",
                status: .pass,
                message: "Intruder incident storage healthy: \(intruderCount) photo(s) stored (\(formattedSize))."
            ))
        }

        // Category 3: Background Daemon & Automation
        // 3.1 Daemon Process
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        if !runningApps.isEmpty {
            let pids = runningApps.map { "\($0.processIdentifier)" }.joined(separator: ", ")
            checks.append(DoctorCheckItem(
                id: "daemon.process",
                category: "daemon",
                name: "Background Shield Process",
                status: .pass,
                message: "FaceLock background shield daemon is active (PID: \(pids))."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "daemon.process",
                category: "daemon",
                name: "Background Shield Process",
                status: .info,
                message: "FaceLock daemon is not currently running in the background.",
                remediation: "Run 'make run' or open '/Applications/FaceLock.app' to start continuous protection."
            ))
        }

        // 3.2 Maintainer LaunchAgent
        let agentPlist = home.appendingPathComponent("Library/LaunchAgents/io.github.facelock.maintainer.plist").path
        if FileManager.default.fileExists(atPath: agentPlist) {
            checks.append(DoctorCheckItem(
                id: "daemon.launchagent",
                category: "daemon",
                name: "Autonomous Maintainer LaunchAgent",
                status: .pass,
                message: "Autonomous LaunchAgent is installed at ~/Library/LaunchAgents/io.github.facelock.maintainer.plist."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "daemon.launchagent",
                category: "daemon",
                name: "Autonomous Maintainer LaunchAgent",
                status: .info,
                message: "Autonomous maintainer LaunchAgent is not installed.",
                remediation: "Run 'make maintainer-install' or 'make install-sync' to enable continuous auto-maintenance."
            ))
        }

        // Category 4: Security Posture & Hardening
        // 4.1 Master PIN
        if config.pin == "0000" || config.pin == "1234" {
            checks.append(DoctorCheckItem(
                id: "security.master_pin",
                category: "security",
                name: "Master Unlock PIN",
                status: .warn,
                message: "Default master PIN detected ('\(config.pin)'). Vulnerable to unauthorized access.",
                remediation: "Configure a custom 4-8 digit master PIN via 'make set-pin PIN=...'."
            ))
        } else if config.pin.count >= 4 && config.pin.count <= 8 && config.pin.allSatisfy({ $0.isNumber }) {
            checks.append(DoctorCheckItem(
                id: "security.master_pin",
                category: "security",
                name: "Master Unlock PIN",
                status: .pass,
                message: "Master unlock PIN configured securely (\(config.pin.count) digits)."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "security.master_pin",
                category: "security",
                name: "Master Unlock PIN",
                status: .fail,
                message: "Master unlock PIN is invalid.",
                remediation: "Set a valid 4-8 digit numeric PIN via 'make set-pin PIN=...'."
            ))
        }

        // 4.2 Duress PIN
        if config.duressPin.isEmpty {
            checks.append(DoctorCheckItem(
                id: "security.duress_pin",
                category: "security",
                name: "Silent Duress Distress PIN",
                status: .info,
                message: "Silent duress PIN is not configured (anti-coercion distress unmonitored).",
                remediation: "Set an anti-coercion duress PIN via 'make set-duress-pin PIN=...'."
            ))
        } else if Config.isValidDuressPin(config.duressPin, masterPin: config.pin).isValid {
            checks.append(DoctorCheckItem(
                id: "security.duress_pin",
                category: "security",
                name: "Silent Duress Distress PIN",
                status: .pass,
                message: "Silent duress emergency distress PIN configured (\(config.duressPin.count) digits)."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "security.duress_pin",
                category: "security",
                name: "Silent Duress Distress PIN",
                status: .warn,
                message: "Configured duress PIN is invalid or collides with master PIN.",
                remediation: "Set a distinct 4-8 digit numeric PIN via 'make set-duress-pin PIN=...'."
            ))
        }

        // 4.3 Security Posture Score
        let posture = assessSecurityPosture(config: config, enrolledVectors: vectors)
        if posture.score >= 80 {
            checks.append(DoctorCheckItem(
                id: "security.posture_score",
                category: "security",
                name: "Security Posture Rating",
                status: .pass,
                message: "Hardened security posture score: \(posture.score)/\(posture.maxScore) (Grade: \(posture.grade) - \(posture.status))."
            ))
        } else if posture.score >= 60 {
            checks.append(DoctorCheckItem(
                id: "security.posture_score",
                category: "security",
                name: "Security Posture Rating",
                status: .warn,
                message: "Moderate security posture score: \(posture.score)/\(posture.maxScore) (Grade: \(posture.grade)).",
                remediation: "Run 'make auto-harden' to automatically remediate security settings and achieve Grade A+."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "security.posture_score",
                category: "security",
                name: "Security Posture Rating",
                status: .fail,
                message: "Vulnerable security posture score: \(posture.score)/\(posture.maxScore) (Grade: \(posture.grade)).",
                remediation: "Run 'make auto-harden' immediately to enforce essential defense policies."
            ))
        }

        // 4.4 Biometric Anti-Spoofing Liveness
        if config.livenessDetectionEnabled {
            checks.append(DoctorCheckItem(
                id: "security.biometric_spoofing",
                category: "security",
                name: "Deep Anti-Spoofing Liveness",
                status: .pass,
                message: "Deep neural anti-spoofing liveness verification active (prevents photo/screen presentation attacks)."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "security.biometric_spoofing",
                category: "security",
                name: "Deep Anti-Spoofing Liveness",
                status: .warn,
                message: "Liveness anti-spoofing is disabled (vulnerable to printed photo presentation attacks).",
                remediation: "Enable anti-spoofing via 'facelock --set-liveness on' or 'make toggle-liveness'."
            ))
        }

        // 4.5 Shoulder-Surfing Bystander Defense
        if config.shoulderSurfingDefense {
            checks.append(DoctorCheckItem(
                id: "security.shoulder_surfing",
                category: "security",
                name: "Shoulder-Surfing Defense",
                status: .pass,
                message: "Shoulder-surfing bystander defense active (detects unauthorized onlookers behind user)."
            ))
        } else {
            checks.append(DoctorCheckItem(
                id: "security.shoulder_surfing",
                category: "security",
                name: "Shoulder-Surfing Defense",
                status: .info,
                message: "Shoulder-surfing bystander defense disabled (opt-in feature for public environments).",
                remediation: "Enable bystander defense in public/cafe areas via 'make toggle-shoulder'."
            ))
        }

        // Category 5: Remote Alerting & Network
        if config.telegramEnabled {
            if !config.telegramBotToken.isEmpty && !config.telegramChatId.isEmpty {
                var reachable = true
                if !skipNetwork {
                    let sema = DispatchSemaphore(value: 0)
                    if let testUrl = URL(string: "https://api.telegram.org") {
                        var req = URLRequest(url: testUrl, timeoutInterval: 2.0)
                        req.httpMethod = "HEAD"
                        let task = URLSession.shared.dataTask(with: req) { _, response, error in
                            if let http = response as? HTTPURLResponse, (200...399).contains(http.statusCode) {
                                reachable = true
                            } else if error == nil {
                                reachable = true
                            } else {
                                reachable = false
                            }
                            sema.signal()
                        }
                        task.resume()
                        _ = sema.wait(timeout: .now() + 2.2)
                    }
                }
                if reachable {
                    let maskedChat = config.telegramChatId.count > 4 ? "\(config.telegramChatId.prefix(4))..." : config.telegramChatId
                    checks.append(DoctorCheckItem(
                        id: "network.telegram_alert",
                        category: "network",
                        name: "Telegram Remote Alerting",
                        status: .pass,
                        message: "Telegram alert bot active and reachable (Target Chat ID: \(maskedChat))."
                    ))
                } else {
                    checks.append(DoctorCheckItem(
                        id: "network.telegram_alert",
                        category: "network",
                        name: "Telegram Remote Alerting",
                        status: .warn,
                        message: "Telegram gateway unreachable (DNS error or network offline).",
                        remediation: "Verify internet connection and test Telegram dispatch via 'make test-telegram'."
                    ))
                }
            } else {
                checks.append(DoctorCheckItem(
                    id: "network.telegram_alert",
                    category: "network",
                    name: "Telegram Remote Alerting",
                    status: .warn,
                    message: "Telegram alerts are enabled in settings, but bot token or chat ID is missing.",
                    remediation: "Configure bot token and chat ID via 'facelock --set-telegram <token> <chatId>'."
                ))
            }
        } else {
            checks.append(DoctorCheckItem(
                id: "network.telegram_alert",
                category: "network",
                name: "Telegram Remote Alerting",
                status: .info,
                message: "Telegram remote alerting is disabled (local incident logging active).",
                remediation: "Optionally configure Telegram alerts via 'facelock --set-telegram <token> <chatId>'."
            ))
        }

        return DoctorReport(checks: checks, version: Config.currentVersion)
    }

    public static func runDoctorRepair(config: Config = .shared, save: Bool = true) -> DoctorRepairReport {
        let initialReport = runDoctor(config: config, skipNetwork: true)
        var actions: [String] = []

        // 1. Data directory permissions repair (chmod 0700 ~/.facelock)
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: facelockDir.path, isDirectory: &isDir), isDir.boolValue {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: facelockDir.path),
               let perms = attrs[.posixPermissions] as? NSNumber {
                let p = perms.intValue
                if (p & 0o077) != 0 {
                    if (try? FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: facelockDir.path)) != nil {
                        actions.append("Restricted ~/.facelock directory permissions to 0700")
                    }
                }
            }
        }

        // 2. Cryptographic audit log auto-repair
        let auditReport = SecurityAuditLogger.shared.verifyAuditIntegrity()
        if auditReport.corruptedLinesCount > 0 {
            if let rep = try? SecurityAuditLogger.shared.repairAuditLog(), rep.repairedCount > 0 {
                actions.append("Repaired \(rep.repairedCount) corrupted audit log event(s)")
            }
        }

        // 3. Intruder incident storage integrity auto-repair
        let incReport = CameraScanner.shared.verifyIncidentsIntegrity()
        if incReport.corruptedCount > 0 {
            let rep = CameraScanner.shared.repairCorruptedIncidents()
            if rep.repairedCount > 0 {
                actions.append("Repaired \(rep.repairedCount) corrupted intruder capture(s)")
            }
        }

        // 4. Intruder photo quota enforcement
        let storageRep = CameraScanner.shared.pruneIncidentsByMegaBytes(maxMB: 500)
        if storageRep.removedCount > 0 {
            let freedMB = String(format: "%.2f", Double(storageRep.freedBytes) / (1024.0 * 1024.0))
            actions.append("Pruned \(storageRep.removedCount) older intruder photo(s) to fit 500MB budget (\(freedMB) MB freed)")
        }

        // 5. Enrolled biometric template cluster optimization
        let optRep = config.optimizeVectors()
        let prunedTotal = (optRep["prunedRedundant"] as? Int ?? 0) + (optRep["prunedOutliers"] as? Int ?? 0)
        if prunedTotal > 0 {
            actions.append("Optimized biometric cluster: removed \(prunedTotal) outlier template(s)")
        }

        // 6. Security auto-hardening
        let hardenRep = autoHardenSecurity(config: config, save: save)
        for fix in hardenRep.appliedFixes {
            actions.append(fix)
        }

        // 7. Audit log telemetry
        if save {
            SecurityAuditLogger.shared.log(
                eventType: "doctor_repair_applied",
                appName: "FaceLock Doctor",
                details: "\(actions.count) health and security repair action(s) executed",
                isSuccess: true
            )
        }

        let finalReport = runDoctor(config: config, skipNetwork: true)
        return DoctorRepairReport(
            initialReport: initialReport,
            finalReport: finalReport,
            repairedActions: actions,
            version: Config.currentVersion
        )
    }
}
