import Foundation
import AppKit

public struct AuditEvent: Codable {
    public let id: String
    public let timestamp: String
    public let eventType: String
    public let appName: String?
    public let bundleId: String?
    public let distance: Float?
    public let threshold: Float?
    public let intruderPhoto: String?
    public let details: String?
    public let isSuccess: Bool

    public init(
        id: String = UUID().uuidString.prefix(8).lowercased(),
        timestamp: String = ISO8601DateFormatter().string(from: Date()),
        eventType: String,
        appName: String? = nil,
        bundleId: String? = nil,
        distance: Float? = nil,
        threshold: Float? = nil,
        intruderPhoto: String? = nil,
        details: String? = nil,
        isSuccess: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
        self.appName = appName
        self.bundleId = bundleId
        self.distance = distance
        self.threshold = threshold
        self.intruderPhoto = intruderPhoto
        self.details = details
        self.isSuccess = isSuccess
    }
}

public final class SecurityAuditLogger {
    public static let shared = SecurityAuditLogger()

    private let logQueue = DispatchQueue(label: "io.github.facelock.auditQueue", qos: .utility)
    private let logFileURL: URL

    private init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)
        try? FileManager.default.createDirectory(at: facelockDir, withIntermediateDirectories: true)
        self.logFileURL = facelockDir.appendingPathComponent("audit_log.jsonl")
        recoverAndCleanupOrphanedTempFiles(in: facelockDir)
    }

    private func recoverAndCleanupOrphanedTempFiles(in dir: URL) {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return }
        let orphans = files.filter { $0.hasPrefix("audit_log.jsonl.sb-") }
        guard !orphans.isEmpty else { return }

        for file in orphans {
            let path = dir.appendingPathComponent(file).path
            if let content = try? String(contentsOfFile: path, encoding: .utf8), !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // If the main audit log doesn't exist or is empty, try recovering valid line
                if !FileManager.default.fileExists(atPath: self.logFileURL.path) {
                    try? content.write(to: self.logFileURL, atomically: false, encoding: .utf8)
                } else if let fileHandle = try? FileHandle(forWritingTo: self.logFileURL) {
                    fileHandle.seekToEndOfFile()
                    if let data = content.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                    try? fileHandle.close()
                }
            }
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    public func log(
        eventType: String,
        appName: String? = nil,
        bundleId: String? = nil,
        distance: Float? = nil,
        threshold: Float? = nil,
        intruderPhoto: String? = nil,
        details: String? = nil,
        isSuccess: Bool
    ) {
        let event = AuditEvent(
            eventType: eventType,
            appName: appName,
            bundleId: bundleId,
            distance: distance,
            threshold: threshold,
            intruderPhoto: intruderPhoto,
            details: details,
            isSuccess: isSuccess
        )
        record(event)
    }

    public func record(_ event: AuditEvent) {
        logQueue.sync { [weak self] in
            guard let self = self else { return }
            guard let data = try? JSONEncoder().encode(event),
                  var jsonString = String(data: data, encoding: .utf8) else {
                return
            }
            jsonString.append("\n")
            guard let lineData = jsonString.data(using: .utf8) else { return }

            if FileManager.default.fileExists(atPath: self.logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: self.logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(lineData)
                    try? fileHandle.close()
                }
            } else {
                FileManager.default.createFile(atPath: self.logFileURL.path, contents: lineData, attributes: nil)
            }
        }
    }

    public func logFaceVerified(appName: String?, bundleId: String?, distance: Float?, threshold: Float?) {
        log(
            eventType: "face_verified",
            appName: appName,
            bundleId: bundleId,
            distance: distance,
            threshold: threshold,
            details: "Owner recognized via neural camera scan",
            isSuccess: true
        )
    }

    public func logIntruderDetected(appName: String?, bundleId: String?, distance: Float?, threshold: Float?, intruderPhoto: String?) {
        log(
            eventType: "intruder_detected",
            appName: appName,
            bundleId: bundleId,
            distance: distance,
            threshold: threshold,
            intruderPhoto: intruderPhoto,
            details: "Face unrecognized or mismatched; lock screen activated",
            isSuccess: false
        )
    }

    public func logWalkAwayLock(intruderPhoto: String?) {
        log(
            eventType: "walkaway_lock",
            appName: "System",
            bundleId: "com.apple.loginwindow",
            intruderPhoto: intruderPhoto,
            details: "User left computer unattended; automated lock triggered",
            isSuccess: false
        )
    }

    public func logWakeVerified(distance: Float?, threshold: Float?) {
        log(
            eventType: "wake_verified",
            appName: "System Wake",
            bundleId: "com.apple.loginwindow",
            distance: distance,
            threshold: threshold,
            details: "Owner authorized immediately upon screen wake",
            isSuccess: true
        )
    }

    public func logWakeLocked(intruderPhoto: String?) {
        log(
            eventType: "wake_locked",
            appName: "System Wake",
            bundleId: "com.apple.loginwindow",
            intruderPhoto: intruderPhoto,
            details: "Screen woke but owner face was not confirmed; locked",
            isSuccess: false
        )
    }

    public func logTouchIDUnlocked(targetApp: String?) {
        log(
            eventType: "touchid_unlocked",
            appName: targetApp ?? "FaceLock",
            details: "Unlocked via Apple Secure Enclave Touch ID biometrics",
            isSuccess: true
        )
    }

    public func logPINUnlocked(targetApp: String?) {
        log(
            eventType: "pin_unlocked",
            appName: targetApp ?? "FaceLock",
            details: "Unlocked using master numerical security PIN",
            isSuccess: true
        )
    }

    public func logPINFailed(targetApp: String?) {
        log(
            eventType: "pin_failed",
            appName: targetApp ?? "FaceLock",
            details: "Incorrect PIN entered on lock screen",
            isSuccess: false
        )
    }

    public func logFaceRetrySuccess(targetApp: String?) {
        log(
            eventType: "face_retry_success",
            appName: targetApp ?? "FaceLock",
            details: "Lock screen cleared via manual Face ID re-scan",
            isSuccess: true
        )
    }

    public func logFaceRetryFailed(targetApp: String?) {
        log(
            eventType: "face_retry_failed",
            appName: targetApp ?? "FaceLock",
            details: "Face ID re-scan on lock screen failed",
            isSuccess: false
        )
    }

    public func logShieldStateChanged(enabled: Bool, reason: String? = nil) {
        log(
            eventType: enabled ? "shield_enabled" : "shield_paused",
            appName: "FaceLock",
            details: reason ?? (enabled ? "Biometric shield activated" : "Biometric shield paused"),
            isSuccess: enabled
        )
    }

    public func logConfigChanged(setting: String, value: String, details: String? = nil) {
        log(
            eventType: "config_changed",
            appName: "FaceLock",
            details: details ?? "Updated configuration '\(setting)' to '\(value)'",
            isSuccess: true
        )
    }

    public func logPolicyChanged(action: String, bundleId: String, details: String? = nil) {
        log(
            eventType: "policy_changed",
            appName: bundleId,
            bundleId: bundleId,
            details: details ?? "\(action): \(bundleId)",
            isSuccess: true
        )
    }

    public func logVectorsModified(action: String, count: Int, details: String? = nil) {
        log(
            eventType: "vectors_modified",
            appName: "FaceLock",
            details: details ?? "\(action) (\(count) facial templates)",
            isSuccess: true
        )
    }

    public func logIncidentsAction(action: String, count: Int, details: String? = nil) {
        log(
            eventType: "incidents_action",
            appName: "FaceLock",
            details: details ?? "\(action) (\(count) records affected)",
            isSuccess: true
        )
    }

    public func logVerificationCheck(type: String, success: Bool, distance: Float? = nil, details: String? = nil) {
        log(
            eventType: "\(type)_check",
            appName: "FaceLock CLI",
            distance: distance,
            details: details ?? "\(type) verification check \(success ? "passed" : "failed")",
            isSuccess: success
        )
    }

    public func logTelegramAlert(appName: String?, isSuccess: Bool, details: String) {
        log(
            eventType: isSuccess ? "telegram_alert_sent" : "telegram_alert_failed",
            appName: appName ?? "Telegram Alert",
            details: details,
            isSuccess: isSuccess
        )
    }

    public func fetchRecentEvents(tail: Int = 20, filterType: String? = nil) -> [AuditEvent] {
        var results: [AuditEvent] = []
        logQueue.sync {
            guard let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) else {
                return
            }
            let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let decoder = JSONDecoder()
            for line in lines.reversed() {
                if let data = line.data(using: .utf8),
                   let event = try? decoder.decode(AuditEvent.self, from: data) {
                    if let filter = filterType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !filter.isEmpty && filter != "all" {
                        let evType = event.eventType.lowercased()
                        let match: Bool
                        switch filter {
                        case "face", "biometric", "biometrics":
                            match = evType.contains("face") || evType.contains("wake_verified")
                        case "intruder", "intruders", "alert", "alerts":
                            match = evType.contains("intruder") || evType.contains("wake_locked") || evType.contains("incidents")
                        case "lock", "locks", "lockout", "lockouts", "bruteforce":
                            match = evType.contains("lock") || evType.contains("intruder") || evType.contains("bruteforce")
                        case "pin":
                            match = evType.contains("pin")
                        case "touchid", "touch_id":
                            match = evType.contains("touchid")
                        case "shield":
                            match = evType.contains("shield")
                        case "policy":
                            match = evType.contains("policy")
                        case "config", "settings":
                            match = evType.contains("config") || evType.contains("settings")
                        case "vectors", "vector":
                            match = evType.contains("vector")
                        case "incidents", "incident":
                            match = evType.contains("incident") || evType.contains("intruder")
                        case "telegram", "tg":
                            match = evType.contains("telegram")
                        case "success":
                            match = event.isSuccess
                        case "failure", "failed":
                            match = !event.isSuccess
                        default:
                            match = evType == filter || evType.contains(filter)
                        }
                        if !match {
                            continue
                        }
                    }
                    results.append(event)
                    if results.count >= tail {
                        break
                    }
                }
            }
        }
        return results
    }

    public func pruneLogs(keeping: Int) -> (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) {
        var pruned = 0
        var remaining = 0
        var freed: UInt64 = 0

        logQueue.sync {
            guard let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) else {
                return
            }
            let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let initialCount = lines.count
            let initialSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0

            if initialCount <= keeping {
                remaining = initialCount
                return
            }

            let keptLines = Array(lines.suffix(keeping))
            let newContent = keptLines.joined(separator: "\n") + "\n"

            if let data = newContent.data(using: .utf8) {
                try? data.write(to: self.logFileURL, options: .atomic)
                let newSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0
                freed = (initialSize > newSize) ? (initialSize - newSize) : 0
                pruned = initialCount - keptLines.count
                remaining = keptLines.count
            }
        }
        return (pruned, remaining, freed)
    }

    public func clearLogs() -> (deletedCount: Int, freedBytes: UInt64) {
        var deleted = 0
        var freed: UInt64 = 0
        logQueue.sync {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let size = attrs[.size] as? UInt64 {
                freed = size
            }
            if let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) {
                deleted = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
            }
            try? FileManager.default.removeItem(at: self.logFileURL)
        }
        return (deleted, freed)
    }

    public func getLogStats() -> (totalCount: Int, fileSizeBytes: UInt64, lastEventTime: String?) {
        var count = 0
        var size: UInt64 = 0
        var lastTime: String? = nil

        logQueue.sync {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let s = attrs[.size] as? UInt64 {
                size = s
            }
            if let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) {
                let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                count = lines.count
                if let last = lines.last,
                   let data = last.data(using: .utf8),
                   let event = try? JSONDecoder().decode(AuditEvent.self, from: data) {
                    lastTime = event.timestamp
                }
            }
        }
        return (count, size, lastTime)
    }

    public func exportLogs(to destinationPath: String) throws -> Int {
        let expanded = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expanded)
        var count = 0

        try logQueue.sync {
            guard FileManager.default.fileExists(atPath: self.logFileURL.path) else {
                try Data().write(to: destURL, options: .atomic)
                count = 0
                return
            }
            let data = try Data(contentsOf: self.logFileURL)
            try data.write(to: destURL, options: .atomic)
            if let content = String(data: data, encoding: .utf8) {
                count = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
            }
        }
        return count
    }
}
