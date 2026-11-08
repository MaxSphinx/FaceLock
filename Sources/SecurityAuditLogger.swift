import Foundation
import AppKit
import CryptoKit

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

public struct AuditStats {
    public let totalEvents: Int
    public let fileSizeBytes: UInt64
    public let lastEventTime: String?
    public let successCount: Int
    public let failureCount: Int
    public let todayCount: Int
    public let past24HoursCount: Int
    public let typeBreakdown: [String: Int]

    public init(
        totalEvents: Int,
        fileSizeBytes: UInt64,
        lastEventTime: String?,
        successCount: Int,
        failureCount: Int,
        todayCount: Int,
        past24HoursCount: Int,
        typeBreakdown: [String: Int]
    ) {
        self.totalEvents = totalEvents
        self.fileSizeBytes = fileSizeBytes
        self.lastEventTime = lastEventTime
        self.successCount = successCount
        self.failureCount = failureCount
        self.todayCount = todayCount
        self.past24HoursCount = past24HoursCount
        self.typeBreakdown = typeBreakdown
    }

    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "totalEvents": totalEvents,
            "fileSizeBytes": fileSizeBytes,
            "successCount": successCount,
            "failureCount": failureCount,
            "todayCount": todayCount,
            "past24HoursCount": past24HoursCount,
            "typeBreakdown": typeBreakdown
        ]
        if let last = lastEventTime {
            dict["lastEventTime"] = last
        }
        return dict
    }
}

public struct AuditIntegrityReport: Codable {
    public let totalLinesScanned: Int
    public let validEventsCount: Int
    public let corruptedLinesCount: Int
    public let emptyLinesCount: Int
    public let chronologyErrorsCount: Int
    public let unknownTypeCount: Int
    public let sha256Digest: String
    public let fileSizeBytes: UInt64
    public let filePath: String
    public let firstEventTimestamp: String?
    public let lastEventTimestamp: String?
    public let status: String
    public let corruptedLineIndices: [Int]

    public init(
        totalLinesScanned: Int,
        validEventsCount: Int,
        corruptedLinesCount: Int,
        emptyLinesCount: Int,
        chronologyErrorsCount: Int,
        unknownTypeCount: Int,
        sha256Digest: String,
        fileSizeBytes: UInt64,
        filePath: String,
        firstEventTimestamp: String? = nil,
        lastEventTimestamp: String? = nil,
        status: String,
        corruptedLineIndices: [Int] = []
    ) {
        self.totalLinesScanned = totalLinesScanned
        self.validEventsCount = validEventsCount
        self.corruptedLinesCount = corruptedLinesCount
        self.emptyLinesCount = emptyLinesCount
        self.chronologyErrorsCount = chronologyErrorsCount
        self.unknownTypeCount = unknownTypeCount
        self.sha256Digest = sha256Digest
        self.fileSizeBytes = fileSizeBytes
        self.filePath = filePath
        self.firstEventTimestamp = firstEventTimestamp
        self.lastEventTimestamp = lastEventTimestamp
        self.status = status
        self.corruptedLineIndices = corruptedLineIndices
    }

    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "totalLinesScanned": totalLinesScanned,
            "validEventsCount": validEventsCount,
            "corruptedLinesCount": corruptedLinesCount,
            "emptyLinesCount": emptyLinesCount,
            "chronologyErrorsCount": chronologyErrorsCount,
            "unknownTypeCount": unknownTypeCount,
            "sha256Digest": sha256Digest,
            "fileSizeBytes": fileSizeBytes,
            "filePath": filePath,
            "status": status,
            "corruptedLineIndices": corruptedLineIndices
        ]
        if let first = firstEventTimestamp {
            dict["firstEventTimestamp"] = first
        }
        if let last = lastEventTimestamp {
            dict["lastEventTimestamp"] = last
        }
        return dict
    }
}

public final class SecurityAuditLogger {
    public static let shared = SecurityAuditLogger()

    private let logQueue = DispatchQueue(label: "io.github.facelock.auditQueue", qos: .utility)
    private let logFileURL: URL
    private var writeCountSinceCheck: Int = 0

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
            self.autoPruneIfNeeded()
        }
    }

    private func autoPruneIfNeeded() {
        writeCountSinceCheck += 1
        if writeCountSinceCheck >= 50 {
            writeCountSinceCheck = 0
            if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let size = attrs[.size] as? UInt64, size > 5 * 1024 * 1024 {
                _ = self.pruneLogsInternal(keeping: 5000)
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

    public func logDuressPinUnlocked(targetApp: String?) {
        log(
            eventType: "duress_pin_unlocked",
            appName: targetApp ?? "FaceLock",
            details: "Duress emergency code entered - silent distress protocol activated",
            isSuccess: true
        )
    }

    public func logShoulderSurfingDetected(secondaryCount: Int, details: String? = nil) {
        log(
            eventType: "shoulder_surfing_alert",
            appName: "Security",
            details: details ?? "Detected \(secondaryCount) unauthorized face(s) in background while owner active",
            isSuccess: false
        )
    }

    public func logProfileSwitched(from oldProfile: String, to newProfile: String) {
        log(
            eventType: "profile_switched",
            appName: "FaceLock",
            details: "Security profile changed from '\(oldProfile)' to '\(newProfile)'",
            isSuccess: true
        )
    }

    public func logEmergencyLockdown(details: String? = nil) {
        log(
            eventType: "emergency_lockdown",
            appName: "FaceLock",
            details: details ?? "Emergency security lockdown engaged",
            isSuccess: false
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

    public func logPinBruteforce(appName: String?, attempts: Int, lockoutSeconds: Int) {
        log(
            eventType: "pin_bruteforce_attempt",
            appName: appName ?? "FaceLock",
            details: "\(attempts) consecutive failed PIN attempts detected (lockout: \(lockoutSeconds)s)",
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

    public func logPolicyChanged(action: String, bundleId: String? = nil, details: String? = nil) {
        log(
            eventType: "policy_changed",
            appName: bundleId ?? "Policy",
            bundleId: bundleId,
            details: details ?? (bundleId != nil ? "\(action): \(bundleId!)" : action),
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

    public func logVectorsCleared(count: Int, details: String? = nil) {
        log(
            eventType: "vectors_cleared",
            appName: "FaceLock",
            details: details ?? "Purged \(count) enrolled biometric face vector(s)",
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

    public static let supportedEventFilters: [String] = [
        "face", "intruder", "lock", "pin", "touchid", "shield",
        "policy", "config", "vectors", "incidents", "telegram",
        "shoulder", "profile", "emergency", "success", "failure"
    ]

    public static let supportedExportFormats: [String] = ["jsonl", "json", "csv"]

    public static func isValidExportFormat(_ format: String) -> Bool {
        let normalized = format.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return supportedExportFormats.contains(normalized)
    }

    public static func escapeCSVField(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }

    public static func matchesEventFilter(event: AuditEvent, filter: String) -> Bool {
        let f = filter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !f.isEmpty && f != "all" else { return true }
        let evType = event.eventType.lowercased()
        switch f {
        case "face", "biometric", "biometrics":
            return evType.contains("face") || evType.contains("wake_verified")
        case "intruder", "intruders", "alert", "alerts":
            return evType.contains("intruder") || evType.contains("wake_locked") || evType.contains("incidents")
        case "lock", "locks", "lockout", "lockouts", "bruteforce":
            return evType.contains("lock") || evType.contains("intruder") || evType.contains("bruteforce")
        case "pin":
            return evType.contains("pin")
        case "touchid", "touch_id":
            return evType.contains("touchid")
        case "shield":
            return evType.contains("shield")
        case "policy":
            return evType.contains("policy")
        case "config", "settings":
            return evType.contains("config") || evType.contains("settings")
        case "vectors", "vector", "enroll", "enrollment":
            return evType.contains("vector") || evType.contains("enroll")
        case "incidents", "incident":
            return evType.contains("incident") || evType.contains("intruder")
        case "telegram", "tg":
            return evType.contains("telegram")
        case "shoulder", "shoulder_surfing", "bystander":
            return evType.contains("shoulder") || evType.contains("bystander")
        case "profile", "profiles":
            return evType.contains("profile")
        case "emergency", "lockdown":
            return evType.contains("lockdown") || evType.contains("emergency")
        case "success":
            return event.isSuccess
        case "failure", "failed":
            return !event.isSuccess
        default:
            return evType == f || evType.contains(f)
        }
    }

    public static func isValidEventFilter(_ filter: String) -> Bool {
        let normalized = filter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return false }
        if normalized == "all" { return true }
        if supportedEventFilters.contains(normalized) { return true }
        switch normalized {
        case "biometric", "biometrics",
             "intruders", "alert", "alerts",
             "locks", "lockout", "lockouts", "bruteforce",
             "touch_id",
             "settings",
             "vector", "enroll", "enrollment",
             "incident",
             "tg",
             "shoulder_surfing", "bystander",
             "profiles",
             "lockdown",
             "failed":
            return true
        default:
            return false
        }
    }

    public static func matchesQuery(event: AuditEvent, query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return true }
        if event.eventType.lowercased().contains(q) { return true }
        if let app = event.appName, app.lowercased().contains(q) { return true }
        if let bundle = event.bundleId, bundle.lowercased().contains(q) { return true }
        if let details = event.details, details.lowercased().contains(q) { return true }
        if let photo = event.intruderPhoto, photo.lowercased().contains(q) { return true }
        return false
    }

    public func searchEvents(query: String? = nil, filterType: String? = nil, tail: Int = 20) -> [AuditEvent] {
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
                    if let filter = filterType, !filter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if !SecurityAuditLogger.matchesEventFilter(event: event, filter: filter) {
                            continue
                        }
                    }
                    if let q = query, !q.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if !SecurityAuditLogger.matchesQuery(event: event, query: q) {
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

    public func fetchRecentEvents(tail: Int = 20, filterType: String? = nil) -> [AuditEvent] {
        return searchEvents(query: nil, filterType: filterType, tail: tail)
    }

    @discardableResult
    private func pruneLogsInternal(keeping: Int) -> (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) {
        guard let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) else {
            return (0, 0, 0)
        }
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let initialCount = lines.count
        let initialSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0

        if initialCount <= keeping {
            return (0, initialCount, 0)
        }

        let keptLines = Array(lines.suffix(keeping))
        let newContent = keptLines.joined(separator: "\n") + "\n"

        if let data = newContent.data(using: .utf8) {
            try? data.write(to: self.logFileURL, options: .atomic)
            let newSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0
            let freed = (initialSize > newSize) ? (initialSize - newSize) : 0
            return (initialCount - keptLines.count, keptLines.count, freed)
        }
        return (0, initialCount, 0)
    }

    public func pruneLogs(keeping: Int) -> (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) {
        var result: (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) = (0, 0, 0)
        logQueue.sync {
            result = self.pruneLogsInternal(keeping: keeping)
        }
        return result
    }

    public func pruneLogs(olderThanDays days: Int) -> (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) {
        guard days >= 0 else { return (0, 0, 0) }
        var result: (prunedCount: Int, remainingCount: Int, freedBytes: UInt64) = (0, 0, 0)
        logQueue.sync {
            guard let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) else {
                return
            }
            let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let initialCount = lines.count
            let initialSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0
            guard initialCount > 0 else { return }

            let cutoff = Date().addingTimeInterval(-Double(days) * 86400.0)
            let isoFormatter = ISO8601DateFormatter()
            let decoder = JSONDecoder()

            var keptLines: [String] = []
            keptLines.reserveCapacity(initialCount)

            for line in lines {
                if let data = line.data(using: .utf8),
                   let event = try? decoder.decode(AuditEvent.self, from: data) {
                    if let eventDate = isoFormatter.date(from: event.timestamp) {
                        if eventDate >= cutoff {
                            keptLines.append(line)
                        }
                    } else {
                        keptLines.append(line)
                    }
                } else {
                    keptLines.append(line)
                }
            }

            let pruned = initialCount - keptLines.count
            if pruned > 0 {
                let newContent = keptLines.isEmpty ? "" : (keptLines.joined(separator: "\n") + "\n")
                if let data = newContent.data(using: .utf8) {
                    try? data.write(to: self.logFileURL, options: .atomic)
                    let newSize = (try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path)[.size] as? UInt64) ?? 0
                    let freed = (initialSize > newSize) ? (initialSize - newSize) : 0
                    result = (pruned, keptLines.count, freed)
                    return
                }
            }
            result = (0, initialCount, 0)
        }
        return result
    }

    @discardableResult
    public func autoPruneLogs(maxBytes: UInt64 = 5 * 1024 * 1024, keeping: Int = 5000) -> Bool {
        var didPrune = false
        logQueue.sync {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let size = attrs[.size] as? UInt64, size > maxBytes {
                let res = self.pruneLogsInternal(keeping: keeping)
                didPrune = res.prunedCount > 0
            }
        }
        return didPrune
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

    public func getAuditStats() -> AuditStats {
        var count = 0
        var size: UInt64 = 0
        var lastTime: String? = nil
        var successCount = 0
        var failureCount = 0
        var todayCount = 0
        var past24HoursCount = 0
        var typeBreakdown: [String: Int] = [:]

        let now = Date()
        let oneDayAgo = now.addingTimeInterval(-86400)
        let todayPrefix = ISO8601DateFormatter().string(from: now).prefix(10)
        let isoFormatter = ISO8601DateFormatter()

        logQueue.sync {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
               let s = attrs[.size] as? UInt64 {
                size = s
            }
            if let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) {
                let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                count = lines.count
                let decoder = JSONDecoder()
                for line in lines {
                    if let data = line.data(using: .utf8),
                       let event = try? decoder.decode(AuditEvent.self, from: data) {
                        lastTime = event.timestamp
                        if event.isSuccess {
                            successCount += 1
                        } else {
                            failureCount += 1
                        }
                        if event.timestamp.hasPrefix(todayPrefix) {
                            todayCount += 1
                        }
                        if let date = isoFormatter.date(from: event.timestamp), date >= oneDayAgo {
                            past24HoursCount += 1
                        }
                        typeBreakdown[event.eventType, default: 0] += 1
                    }
                }
            }
        }
        return AuditStats(
            totalEvents: count,
            fileSizeBytes: size,
            lastEventTime: lastTime,
            successCount: successCount,
            failureCount: failureCount,
            todayCount: todayCount,
            past24HoursCount: past24HoursCount,
            typeBreakdown: typeBreakdown
        )
    }

    public func getLogStats() -> (totalCount: Int, fileSizeBytes: UInt64, lastEventTime: String?) {
        let detailed = getDetailedLogStats()
        return (detailed.totalCount, detailed.fileSizeBytes, detailed.lastEventTime)
    }

    public func getDetailedLogStats() -> (totalCount: Int, fileSizeBytes: UInt64, lastEventTime: String?, successCount: Int, failureCount: Int, typeBreakdown: [String: Int]) {
        let stats = getAuditStats()
        return (stats.totalEvents, stats.fileSizeBytes, stats.lastEventTime, stats.successCount, stats.failureCount, stats.typeBreakdown)
    }

    public struct ThreatAnomaly: Codable {
        public let code: String
        public let description: String
        public let severity: String

        public var title: String {
            return code
        }

        public init(code: String, description: String, severity: String) {
            self.code = code
            self.description = description
            self.severity = severity
        }

        public func toDictionary() -> [String: String] {
            return [
                "code": code,
                "description": description,
                "severity": severity
            ]
        }
    }

    public struct TargetedAppRisk: Codable {
        public let appName: String
        public let bundleId: String?
        public let attemptCount: Int
        public let lastAttemptTime: String?
        public let riskCategory: String

        public init(appName: String, bundleId: String? = nil, attemptCount: Int, lastAttemptTime: String? = nil, riskCategory: String) {
            self.appName = appName
            self.bundleId = bundleId
            self.attemptCount = attemptCount
            self.lastAttemptTime = lastAttemptTime
            self.riskCategory = riskCategory
        }

        public func toDictionary() -> [String: Any] {
            var d: [String: Any] = [
                "appName": appName,
                "attemptCount": attemptCount,
                "riskCategory": riskCategory
            ]
            if let b = bundleId { d["bundleId"] = b }
            if let l = lastAttemptTime { d["lastAttemptTime"] = l }
            return d
        }
    }

    public struct ThreatIntelligenceReport {
        public let riskScore: Int
        public let riskLevel: String
        public let statusBadge: String
        public let totalThreatEvents: Int
        public let past24HoursCount: Int
        public let past7DaysCount: Int
        public let pinBruteforceCount: Int
        public let shoulderSurfingCount: Int
        public let intruderCaptureCount: Int
        public let walkawayLockCount: Int
        public let wakeLockCount: Int
        public let emergencyLockdownCount: Int
        public let hourlyDistribution: [Int: Int]
        public let peakThreatHour: Int?
        public let targetedApps: [TargetedAppRisk]
        public let anomalies: [ThreatAnomaly]
        public let mitigations: [String]

        public init(
            riskScore: Int,
            riskLevel: String,
            statusBadge: String,
            totalThreatEvents: Int,
            past24HoursCount: Int,
            past7DaysCount: Int,
            pinBruteforceCount: Int,
            shoulderSurfingCount: Int,
            intruderCaptureCount: Int,
            walkawayLockCount: Int,
            wakeLockCount: Int,
            emergencyLockdownCount: Int,
            hourlyDistribution: [Int: Int],
            peakThreatHour: Int?,
            targetedApps: [TargetedAppRisk],
            anomalies: [ThreatAnomaly],
            mitigations: [String]
        ) {
            self.riskScore = riskScore
            self.riskLevel = riskLevel
            self.statusBadge = statusBadge
            self.totalThreatEvents = totalThreatEvents
            self.past24HoursCount = past24HoursCount
            self.past7DaysCount = past7DaysCount
            self.pinBruteforceCount = pinBruteforceCount
            self.shoulderSurfingCount = shoulderSurfingCount
            self.intruderCaptureCount = intruderCaptureCount
            self.walkawayLockCount = walkawayLockCount
            self.wakeLockCount = wakeLockCount
            self.emergencyLockdownCount = emergencyLockdownCount
            self.hourlyDistribution = hourlyDistribution
            self.peakThreatHour = peakThreatHour
            self.targetedApps = targetedApps
            self.anomalies = anomalies
            self.mitigations = mitigations
        }

        public func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [
                "riskScore": riskScore,
                "riskLevel": riskLevel,
                "statusBadge": statusBadge,
                "totalThreatEvents": totalThreatEvents,
                "past24HoursCount": past24HoursCount,
                "past7DaysCount": past7DaysCount,
                "pinBruteforceCount": pinBruteforceCount,
                "shoulderSurfingCount": shoulderSurfingCount,
                "intruderCaptureCount": intruderCaptureCount,
                "walkawayLockCount": walkawayLockCount,
                "wakeLockCount": wakeLockCount,
                "emergencyLockdownCount": emergencyLockdownCount,
                "hourlyDistribution": Dictionary(uniqueKeysWithValues: hourlyDistribution.map { (String($0.key), $0.value) }),
                "targetedApps": targetedApps.map { $0.toDictionary() },
                "anomalies": anomalies.map { $0.toDictionary() },
                "mitigations": mitigations
            ]
            if let peak = peakThreatHour {
                dict["peakThreatHour"] = peak
            }
            return dict
        }
    }

    public func analyzeThreatIntelligence(events: [AuditEvent]? = nil) -> ThreatIntelligenceReport {
        var parsedEvents: [AuditEvent] = []
        if let evs = events {
            parsedEvents = evs
        } else {
            logQueue.sync {
                if let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    let decoder = JSONDecoder()
                    for line in lines {
                        if let data = line.data(using: .utf8),
                           let event = try? decoder.decode(AuditEvent.self, from: data) {
                            parsedEvents.append(event)
                        }
                    }
                }
            }
        }

        let now = Date()
        let isoFormatter = ISO8601DateFormatter()
        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        var past24h = 0
        var past7d = 0
        var pinBruteforce = 0
        var shoulderSurfing = 0
        var intruderCaptures = 0
        var walkawayLocks = 0
        var wakeLocks = 0
        var emergencyLockdowns = 0
        var totalThreat = 0

        var hourlyMap: [Int: Int] = [:]
        for h in 0..<24 {
            hourlyMap[h] = 0
        }

        struct AppAcc {
            var count: Int = 0
            var bundleId: String? = nil
            var lastTime: String? = nil
        }
        var appMap: [String: AppAcc] = [:]

        for event in parsedEvents {
            let t = event.eventType
            let eventDate: Date = {
                if let d = isoFormatter.date(from: event.timestamp) { return d }
                if let d = fallbackFormatter.date(from: event.timestamp) { return d }
                return now
            }()

            let age = max(0.0, now.timeIntervalSince(eventDate))
            let isPast24h = age <= 86400.0
            let isPast7d = age <= (7.0 * 86400.0)

            let hour = Calendar.current.component(.hour, from: eventDate)

            var isThreatEvent = false
            if t == "pin_bruteforce" {
                pinBruteforce += 1
                isThreatEvent = true
            } else if t == "shoulder_surfing" {
                shoulderSurfing += 1
                isThreatEvent = true
            } else if t == "intruder_detected" {
                intruderCaptures += 1
                isThreatEvent = true
            } else if t == "walkaway_lock" {
                walkawayLocks += 1
                isThreatEvent = true
            } else if t == "wake_locked" {
                wakeLocks += 1
                isThreatEvent = true
            } else if t == "emergency_lockdown" {
                emergencyLockdowns += 1
                isThreatEvent = true
            } else if t == "pin_failed" {
                isThreatEvent = true
            }

            if isThreatEvent {
                totalThreat += 1
                if isPast24h { past24h += 1 }
                if isPast7d { past7d += 1 }
                hourlyMap[hour, default: 0] += 1

                if let app = event.appName, !app.isEmpty,
                   app != "FaceLock CLI", app != "System",
                   app != "Wake Verification", app != "Walk-Away Auto-Lock" {
                    var acc = appMap[app] ?? AppAcc()
                    acc.count += 1
                    if acc.bundleId == nil { acc.bundleId = event.bundleId }
                    acc.lastTime = event.timestamp
                    appMap[app] = acc
                }
            }
        }

        // Compute targeted applications and risk categorization
        var targetedApps: [TargetedAppRisk] = []
        for (appName, acc) in appMap {
            let bId = acc.bundleId?.lowercased() ?? ""
            let nameLower = appName.lowercased()
            let risk: String
            if nameLower.contains("terminal") || nameLower.contains("keychain") || nameLower.contains("password") ||
               nameLower.contains("settings") || nameLower.contains("system preferences") || bId.contains("terminal") ||
               bId.contains("iterm") || bId.contains("keychain") {
                risk = "CRITICAL"
            } else if nameLower.contains("safari") || nameLower.contains("chrome") || nameLower.contains("brave") ||
                      nameLower.contains("telegram") || nameLower.contains("whatsapp") || nameLower.contains("signal") ||
                      nameLower.contains("slack") || nameLower.contains("notes") || nameLower.contains("mail") {
                risk = "HIGH"
            } else {
                risk = "MEDIUM"
            }
            targetedApps.append(TargetedAppRisk(
                appName: appName,
                bundleId: acc.bundleId,
                attemptCount: acc.count,
                lastAttemptTime: acc.lastTime,
                riskCategory: risk
            ))
        }
        targetedApps.sort { $0.attemptCount > $1.attemptCount }

        // Determine peak threat hour
        var peakHour: Int? = nil
        var maxHourCount = 0
        for h in 0..<24 {
            let c = hourlyMap[h, default: 0]
            if c > maxHourCount {
                maxHourCount = c
                peakHour = h
            }
        }

        // Quantitative risk score calculation (0 - 100)
        var score = 0
        score += min(40, pinBruteforce * 20)
        score += min(25, shoulderSurfing * 10)
        score += min(25, intruderCaptures * 8)
        score += min(20, emergencyLockdowns * 10)

        if past24h >= 3 {
            score += 15
        } else if past24h >= 1 {
            score += 5
        }

        let hasCriticalApp = targetedApps.contains { $0.riskCategory == "CRITICAL" }
        if hasCriticalApp {
            score += 15
        }

        let finalScore = min(100, max(0, score))

        let riskLevel: String
        let badge: String
        switch finalScore {
        case 70...100:
            riskLevel = "CRITICAL"
            badge = "CRITICAL 🔴"
        case 45..<70:
            riskLevel = "HIGH"
            badge = "HIGH 🟠"
        case 20..<45:
            riskLevel = "ELEVATED"
            badge = "ELEVATED 🟡"
        default:
            riskLevel = "LOW"
            badge = "LOW 🟢"
        }

        // Anomaly detection
        var anomalies: [ThreatAnomaly] = []
        if pinBruteforce > 0 {
            anomalies.append(ThreatAnomaly(
                code: "PIN_BRUTEFORCE_DETECTED",
                description: "\(pinBruteforce) unauthorized PIN brute-force attempt(s) triggered lockouts.",
                severity: "CRITICAL"
            ))
        }
        if past24h >= 3 {
            anomalies.append(ThreatAnomaly(
                code: "HIGH_VELOCITY_INTRUSIONS",
                description: "\(past24h) physical security intrusion event(s) recorded in the past 24 hours.",
                severity: "HIGH"
            ))
        }
        if shoulderSurfing >= 2 {
            anomalies.append(ThreatAnomaly(
                code: "PERSISTENT_SHOULDER_SURFING",
                description: "Multiple bystander snooping events detected behind active user.",
                severity: "HIGH"
            ))
        }

        // Check off-hours access (23:00 to 05:59)
        var offHoursCount = 0
        for h in [23, 0, 1, 2, 3, 4, 5] {
            offHoursCount += hourlyMap[h, default: 0]
        }
        if offHoursCount > 0 {
            anomalies.append(ThreatAnomaly(
                code: "OFF_HOURS_ACCESS_ATTEMPT",
                description: "\(offHoursCount) suspicious access or intruder event(s) recorded during late night off-hours (23:00-05:59).",
                severity: "MEDIUM"
            ))
        }

        if hasCriticalApp {
            anomalies.append(ThreatAnomaly(
                code: "PRIVILEGED_TARGET_ACCESS",
                description: "Privileged applications (Terminal, Keychain, Settings) targeted by unauthorized users.",
                severity: "HIGH"
            ))
        }

        // Context-aware actionable mitigations
        var mitigations: [String] = []
        if pinBruteforce > 0 {
            mitigations.append("Harden PIN policy: update to 6+ digit PIN (--set-pin) and reduce allowed attempts to 3 with cooling lockout (--set-pin-attempts 3 --set-pin-lockout 10).")
        }
        if shoulderSurfing > 0 && !Config.shared.shoulderSurfingDefense {
            mitigations.append("Enable shoulder-surfing defense to automatically detect bystanders looking over your shoulder (--toggle-shoulder).")
        }
        if finalScore >= 45 {
            mitigations.append("Elevate defense profile: switch to 'cafe' or 'lockdown' profile (--profile lockdown) to enforce strict timeouts and audible alarms.")
        }
        if !Config.shared.lockOnWake {
            mitigations.append("Enable screen wake verification to protect against unauthorized access upon clamshell opening (--toggle-wake).")
        }
        if !Config.shared.telegramEnabled || Config.shared.telegramBotToken.isEmpty {
            mitigations.append("Configure Telegram intruder alerts for instantaneous remote push notifications with intruder capture photos (--set-telegram <token> <chatId>).")
        }
        if mitigations.isEmpty {
            mitigations.append("Maintain current security configuration; no immediate threat mitigations required.")
        }

        return ThreatIntelligenceReport(
            riskScore: finalScore,
            riskLevel: riskLevel,
            statusBadge: badge,
            totalThreatEvents: totalThreat,
            past24HoursCount: past24h,
            past7DaysCount: past7d,
            pinBruteforceCount: pinBruteforce,
            shoulderSurfingCount: shoulderSurfing,
            intruderCaptureCount: intruderCaptures,
            walkawayLockCount: walkawayLocks,
            wakeLockCount: wakeLocks,
            emergencyLockdownCount: emergencyLockdowns,
            hourlyDistribution: hourlyMap,
            peakThreatHour: peakHour,
            targetedApps: targetedApps,
            anomalies: anomalies,
            mitigations: mitigations
        )
    }

    public struct AuditSummary {
        public let totalEvents: Int
        public let fileSizeBytes: UInt64
        public let firstEventTime: String?
        public let lastEventTime: String?
        public let timeSpanHours: Double
        public let successfulVerifications: Int
        public let intruderDetections: Int
        public let pinUnlocks: Int
        public let touchIdUnlocks: Int
        public let shoulderSurfingIncidents: Int
        public let emergencyLockdowns: Int
        public let pinLockouts: Int
        public let verificationSuccessRate: Double
        public let topChallengedApplications: [String: Int]
        public let averageDailyEvents: Double
        public let duressPinUnlocks: Int
        public let doctorRepairs: Int

        public init(
            totalEvents: Int,
            fileSizeBytes: UInt64,
            firstEventTime: String?,
            lastEventTime: String?,
            timeSpanHours: Double,
            successfulVerifications: Int,
            intruderDetections: Int,
            pinUnlocks: Int,
            touchIdUnlocks: Int,
            shoulderSurfingIncidents: Int,
            emergencyLockdowns: Int,
            pinLockouts: Int,
            verificationSuccessRate: Double,
            topChallengedApplications: [String: Int],
            averageDailyEvents: Double,
            duressPinUnlocks: Int = 0,
            doctorRepairs: Int = 0
        ) {
            self.totalEvents = totalEvents
            self.fileSizeBytes = fileSizeBytes
            self.firstEventTime = firstEventTime
            self.lastEventTime = lastEventTime
            self.timeSpanHours = timeSpanHours
            self.successfulVerifications = successfulVerifications
            self.intruderDetections = intruderDetections
            self.pinUnlocks = pinUnlocks
            self.touchIdUnlocks = touchIdUnlocks
            self.shoulderSurfingIncidents = shoulderSurfingIncidents
            self.emergencyLockdowns = emergencyLockdowns
            self.pinLockouts = pinLockouts
            self.verificationSuccessRate = verificationSuccessRate
            self.topChallengedApplications = topChallengedApplications
            self.averageDailyEvents = averageDailyEvents
            self.duressPinUnlocks = duressPinUnlocks
            self.doctorRepairs = doctorRepairs
        }

        public func toDictionary() -> [String: Any] {
            return [
                "totalEvents": totalEvents,
                "fileSizeBytes": fileSizeBytes,
                "firstEventTime": firstEventTime ?? "",
                "lastEventTime": lastEventTime ?? "",
                "timeSpanHours": Double(round(timeSpanHours * 10) / 10),
                "successfulVerifications": successfulVerifications,
                "intruderDetections": intruderDetections,
                "pinUnlocks": pinUnlocks,
                "touchIdUnlocks": touchIdUnlocks,
                "shoulderSurfingIncidents": shoulderSurfingIncidents,
                "emergencyLockdowns": emergencyLockdowns,
                "pinLockouts": pinLockouts,
                "verificationSuccessRate": Double(round(verificationSuccessRate * 1000) / 1000),
                "topChallengedApplications": topChallengedApplications,
                "averageDailyEvents": Double(round(averageDailyEvents * 10) / 10),
                "duressPinUnlocks": duressPinUnlocks,
                "doctorRepairs": doctorRepairs
            ]
        }
    }

    public func getAuditSummary(events: [AuditEvent]? = nil) -> AuditSummary {
        var parsedEvents: [AuditEvent] = []
        var size: UInt64 = 0

        if let evs = events {
            parsedEvents = evs
            size = UInt64(evs.count * 128)
        } else {
            logQueue.sync {
                if let attrs = try? FileManager.default.attributesOfItem(atPath: self.logFileURL.path),
                   let s = attrs[.size] as? UInt64 {
                    size = s
                }
                if let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    let decoder = JSONDecoder()
                    for line in lines {
                        if let data = line.data(using: .utf8),
                           let event = try? decoder.decode(AuditEvent.self, from: data) {
                            parsedEvents.append(event)
                        }
                    }
                }
            }
        }

        let total = parsedEvents.count
        guard total > 0 else {
            return AuditSummary(
                totalEvents: 0,
                fileSizeBytes: size,
                firstEventTime: nil,
                lastEventTime: nil,
                timeSpanHours: 0.0,
                successfulVerifications: 0,
                intruderDetections: 0,
                pinUnlocks: 0,
                touchIdUnlocks: 0,
                shoulderSurfingIncidents: 0,
                emergencyLockdowns: 0,
                pinLockouts: 0,
                verificationSuccessRate: 1.0,
                topChallengedApplications: [:],
                averageDailyEvents: 0.0
            )
        }

        let firstTime = parsedEvents.first?.timestamp
        let lastTime = parsedEvents.last?.timestamp

        let isoFormatter = ISO8601DateFormatter()
        var timeSpanHours: Double = 0.0
        if let fStr = firstTime, let lStr = lastTime,
           let fDate = isoFormatter.date(from: fStr),
           let lDate = isoFormatter.date(from: lStr) {
            let diff = max(0.0, lDate.timeIntervalSince(fDate))
            timeSpanHours = diff / 3600.0
        }

        var successVerif = 0
        var intruderDet = 0
        var pinUnlocks = 0
        var touchIdUnlocks = 0
        var shoulderInc = 0
        var emergencyLock = 0
        var pinLockouts = 0
        var duressPinUnlocks = 0
        var doctorRepairs = 0
        var appChallenges: [String: Int] = [:]

        for event in parsedEvents {
            let t = event.eventType
            if t == "face_verified" || t == "wake_verified" {
                successVerif += 1
            } else if t == "intruder_detected" || t == "wake_locked" || t == "walkaway_lock" {
                intruderDet += 1
            } else if t == "pin_unlocked" {
                pinUnlocks += 1
            } else if t == "duress_pin_unlocked" {
                duressPinUnlocks += 1
            } else if t == "touchid_unlocked" {
                touchIdUnlocks += 1
            } else if t == "shoulder_surfing" {
                shoulderInc += 1
            } else if t == "emergency_lockdown" {
                emergencyLock += 1
            } else if t == "pin_bruteforce" {
                pinLockouts += 1
            } else if t == "doctor_repair" || t == "doctor_repair_applied" {
                doctorRepairs += 1
            }

            if let app = event.appName, !app.isEmpty, app != "FaceLock CLI", app != "System" {
                appChallenges[app, default: 0] += 1
            }
        }

        let totalAttempts = successVerif + intruderDet
        let successRate = totalAttempts > 0 ? Double(successVerif) / Double(totalAttempts) : 1.0
        let days = max(1.0, timeSpanHours / 24.0)
        let avgDaily = Double(total) / days

        let sortedApps = appChallenges.sorted { $0.value > $1.value }.prefix(5)
        var topApps: [String: Int] = [:]
        for (k, v) in sortedApps {
            topApps[k] = v
        }

        return AuditSummary(
            totalEvents: total,
            fileSizeBytes: size,
            firstEventTime: firstTime,
            lastEventTime: lastTime,
            timeSpanHours: timeSpanHours,
            successfulVerifications: successVerif,
            intruderDetections: intruderDet,
            pinUnlocks: pinUnlocks,
            touchIdUnlocks: touchIdUnlocks,
            shoulderSurfingIncidents: shoulderInc,
            emergencyLockdowns: emergencyLock,
            pinLockouts: pinLockouts,
            verificationSuccessRate: successRate,
            topChallengedApplications: topApps,
            averageDailyEvents: avgDaily,
            duressPinUnlocks: duressPinUnlocks,
            doctorRepairs: doctorRepairs
        )
    }

    public func exportAudit(
        to destinationPath: String,
        filterType: String? = nil,
        format: String? = nil
    ) throws -> (exportedCount: Int, path: String, format: String, fileSizeBytes: UInt64) {
        let expanded = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expanded)
        let parentDir = destURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        // Determine effective export format
        let effectiveFormat: String
        if let explicitFormat = format?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !explicitFormat.isEmpty {
            guard SecurityAuditLogger.isValidExportFormat(explicitFormat) else {
                throw NSError(
                    domain: "io.github.facelock",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Unsupported export format '\(explicitFormat)'. Supported formats: \(SecurityAuditLogger.supportedExportFormats.joined(separator: ", "))"]
                )
            }
            effectiveFormat = explicitFormat
        } else {
            let lowerPath = destinationPath.lowercased()
            if lowerPath.hasSuffix(".csv") {
                effectiveFormat = "csv"
            } else if lowerPath.hasSuffix(".json") && !lowerPath.hasSuffix(".jsonl") {
                effectiveFormat = "json"
            } else {
                effectiveFormat = "jsonl"
            }
        }

        var exportedCount = 0
        var fileSizeBytes: UInt64 = 0

        try logQueue.sync {
            guard FileManager.default.fileExists(atPath: self.logFileURL.path),
                  let content = try? String(contentsOf: self.logFileURL, encoding: .utf8) else {
                let emptyData: Data
                switch effectiveFormat {
                case "json":
                    emptyData = "[]\n".data(using: .utf8) ?? Data()
                case "csv":
                    emptyData = "id,timestamp,eventType,appName,bundleId,distance,threshold,intruderPhoto,details,isSuccess\n".data(using: .utf8) ?? Data()
                default:
                    emptyData = Data()
                }
                try emptyData.write(to: destURL, options: .atomic)
                fileSizeBytes = UInt64(emptyData.count)
                return
            }

            let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            let decoder = JSONDecoder()
            var matchedEvents: [AuditEvent] = []
            matchedEvents.reserveCapacity(lines.count)

            for line in lines {
                if let data = line.data(using: .utf8),
                   let event = try? decoder.decode(AuditEvent.self, from: data) {
                    if let f = filterType, !f.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        if !SecurityAuditLogger.matchesEventFilter(event: event, filter: f) {
                            continue
                        }
                    }
                    matchedEvents.append(event)
                }
            }

            exportedCount = matchedEvents.count

            let outputData: Data
            switch effectiveFormat {
            case "json":
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted]
                outputData = (try? encoder.encode(matchedEvents)) ?? "[]\n".data(using: .utf8)!
            case "csv":
                var csv = "id,timestamp,eventType,appName,bundleId,distance,threshold,intruderPhoto,details,isSuccess\n"
                for ev in matchedEvents {
                    let id = SecurityAuditLogger.escapeCSVField(ev.id)
                    let ts = SecurityAuditLogger.escapeCSVField(ev.timestamp)
                    let type = SecurityAuditLogger.escapeCSVField(ev.eventType)
                    let app = SecurityAuditLogger.escapeCSVField(ev.appName ?? "")
                    let bundle = SecurityAuditLogger.escapeCSVField(ev.bundleId ?? "")
                    let dist = ev.distance.map { String(format: "%.4f", $0) } ?? ""
                    let th = ev.threshold.map { String(format: "%.2f", $0) } ?? ""
                    let photo = SecurityAuditLogger.escapeCSVField(ev.intruderPhoto ?? "")
                    let det = SecurityAuditLogger.escapeCSVField(ev.details ?? "")
                    let succ = ev.isSuccess ? "true" : "false"
                    csv += "\(id),\(ts),\(type),\(app),\(bundle),\(dist),\(th),\(photo),\(det),\(succ)\n"
                }
                outputData = csv.data(using: .utf8) ?? Data()
            default: // "jsonl"
                let encoder = JSONEncoder()
                var rawLines: [String] = []
                for ev in matchedEvents {
                    if let d = try? encoder.encode(ev), let s = String(data: d, encoding: .utf8) {
                        rawLines.append(s)
                    }
                }
                let body = rawLines.joined(separator: "\n") + (rawLines.isEmpty ? "" : "\n")
                outputData = body.data(using: .utf8) ?? Data()
            }

            try outputData.write(to: destURL, options: .atomic)
            fileSizeBytes = UInt64(outputData.count)
        }

        return (exportedCount, destURL.path, effectiveFormat, fileSizeBytes)
    }

    public func exportLogs(
        to destinationPath: String,
        filterType: String? = nil,
        format: String? = nil
    ) throws -> Int {
        let res = try exportAudit(to: destinationPath, filterType: filterType, format: format)
        return res.exportedCount
    }

    public static let knownEventTypes: Set<String> = [
        "face_verified",
        "intruder_detected",
        "pin_unlocked",
        "pin_failed",
        "touchid_unlocked",
        "touchid_failed",
        "shoulder_surfing",
        "emergency_lockdown",
        "pin_bruteforce",
        "walkaway_lock",
        "wake_verified",
        "wake_locked",
        "shield_paused",
        "shield_resumed",
        "policy_updated",
        "config_updated",
        "vectors_updated",
        "vectors_optimized",
        "session_reset",
        "health_check"
    ]

    public var auditLogURL: URL {
        return logFileURL
    }

    public func verifyAuditIntegrity(fileURL: URL? = nil) -> AuditIntegrityReport {
        let targetURL = fileURL ?? self.logFileURL
        return logQueue.sync {
            guard FileManager.default.fileExists(atPath: targetURL.path),
                  let data = try? Data(contentsOf: targetURL),
                  let content = String(data: data, encoding: .utf8) else {
                return AuditIntegrityReport(
                    totalLinesScanned: 0,
                    validEventsCount: 0,
                    corruptedLinesCount: 0,
                    emptyLinesCount: 0,
                    chronologyErrorsCount: 0,
                    unknownTypeCount: 0,
                    sha256Digest: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                    fileSizeBytes: 0,
                    filePath: targetURL.path,
                    status: "EMPTY",
                    corruptedLineIndices: []
                )
            }

            let shaDigest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            let rawLines = content.components(separatedBy: .newlines)
            let decoder = JSONDecoder()
            let isoFormatter = ISO8601DateFormatter()

            var validCount = 0
            var corruptedCount = 0
            var emptyCount = 0
            var chronologyErrors = 0
            var unknownTypeCount = 0
            var corruptedIndices: [Int] = []
            var firstTime: String? = nil
            var lastTime: String? = nil
            var previousDate: Date? = nil

            for (idx, rawLine) in rawLines.enumerated() {
                let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    if idx < rawLines.count - 1 || rawLines.count == 1 {
                        emptyCount += 1
                    }
                    continue
                }

                guard let lineData = trimmed.data(using: .utf8),
                      let event = try? decoder.decode(AuditEvent.self, from: lineData) else {
                    corruptedCount += 1
                    corruptedIndices.append(idx + 1)
                    continue
                }

                validCount += 1
                if firstTime == nil {
                    firstTime = event.timestamp
                }
                lastTime = event.timestamp

                if !SecurityAuditLogger.knownEventTypes.contains(event.eventType) {
                    unknownTypeCount += 1
                }

                if let curDate = isoFormatter.date(from: event.timestamp) {
                    if let prev = previousDate, curDate < prev {
                        chronologyErrors += 1
                    }
                    previousDate = curDate
                }
            }

            let status: String
            if validCount == 0 && corruptedCount == 0 {
                status = "EMPTY"
            } else if corruptedCount > 0 {
                status = "CORRUPTED_DETECTED"
            } else if chronologyErrors > 0 {
                status = "WARNING_CHRONOLOGY"
            } else {
                status = "VERIFIED"
            }

            return AuditIntegrityReport(
                totalLinesScanned: rawLines.count,
                validEventsCount: validCount,
                corruptedLinesCount: corruptedCount,
                emptyLinesCount: emptyCount,
                chronologyErrorsCount: chronologyErrors,
                unknownTypeCount: unknownTypeCount,
                sha256Digest: shaDigest,
                fileSizeBytes: UInt64(data.count),
                filePath: targetURL.path,
                firstEventTimestamp: firstTime,
                lastEventTimestamp: lastTime,
                status: status,
                corruptedLineIndices: corruptedIndices
            )
        }
    }

    public func repairAuditLog(fileURL: URL? = nil) throws -> (repairedCount: Int, purgedCorruptedCount: Int, remainingCount: Int, backupPath: String) {
        let targetURL = fileURL ?? self.logFileURL
        return try logQueue.sync {
            guard FileManager.default.fileExists(atPath: targetURL.path),
                  let data = try? Data(contentsOf: targetURL),
                  let content = String(data: data, encoding: .utf8) else {
                return (0, 0, 0, "")
            }

            let backupName = "audit_log_\(Int(Date().timeIntervalSince1970)).jsonl.bak"
            let backupURL = targetURL.deletingLastPathComponent().appendingPathComponent(backupName)
            try data.write(to: backupURL, options: .atomic)

            let rawLines = content.components(separatedBy: .newlines)
            let decoder = JSONDecoder()
            let encoder = JSONEncoder()

            var validLines: [String] = []
            var purgedCount = 0

            for rawLine in rawLines {
                let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { continue }

                if let lineData = trimmed.data(using: .utf8),
                   let event = try? decoder.decode(AuditEvent.self, from: lineData) {
                    if let reencoded = try? encoder.encode(event), let s = String(data: reencoded, encoding: .utf8) {
                        validLines.append(s)
                    } else {
                        validLines.append(trimmed)
                    }
                } else {
                    purgedCount += 1
                }
            }

            let newContent = validLines.joined(separator: "\n") + (validLines.isEmpty ? "" : "\n")
            try (newContent.data(using: .utf8) ?? Data()).write(to: targetURL, options: .atomic)

            return (validLines.count, purgedCount, validLines.count, backupURL.path)
        }
    }
}
