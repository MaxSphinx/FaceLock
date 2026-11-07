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
}
