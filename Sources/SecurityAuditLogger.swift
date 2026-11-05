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
}
