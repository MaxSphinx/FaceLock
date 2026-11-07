import Foundation
import Vision
import AppKit
import UniformTypeIdentifiers

public final class Config: Codable {
    // Last maintenance check: 2026-11-07
    public static let currentVersion = "1.2.3"
    public static let shared = Config.load()

    public static let defaultProtectedBundleIdentifiers: [String] = [
        "ru.keepcoder.Telegram",
        "com.apple.Safari",
        "com.google.Chrome",
        "com.apple.mobilesms",
        "com.apple.Notes",
        "com.apple.Photos",
        "com.apple.mail",
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "net.whatsapp.WhatsApp",
        "com.apple.keychainaccess",
        "com.apple.systempreferences"
    ]

    public static let defaultIgnoredBundleIdentifiers: [String] = [
        "io.github.facelock",
        "com.apple.controlcenter",
        "com.apple.notificationcenterui",
        "com.apple.Spotlight",
        "com.apple.WindowManager",
        "com.apple.loginwindow",
        "com.apple.ScreenSaver.Engine",
        "com.apple.systemuiserver",
        "com.apple.dock"
    ]

    public enum SecurityProfile: String, CaseIterable, Codable {
        case normal = "normal"
        case cafe = "cafe"
        case work = "work"
        case home = "home"
        case presentation = "presentation"
        case lockdown = "lockdown"

        public var title: String {
            switch self {
            case .normal: return "Сбалансированный (Normal)"
            case .cafe: return "Кафе / Публичное место (Cafe - Strict)"
            case .work: return "Офис / Работа (Work)"
            case .home: return "Домашний (Home - Relaxed)"
            case .presentation: return "Презентация / Созвон (Presentation)"
            case .lockdown: return "Максимальная защита (Lockdown - Maximum)"
            }
        }

        public var summary: String {
            switch self {
            case .normal: return "45с walk-away, тихий снимок, стандартный порог (0.22)."
            case .cafe: return "10с walk-away, защита от подглядывания (Shoulder-Surfing), блокировка при пробуждении, звуковой сигнал."
            case .work: return "45с walk-away, выборочная защита секретных приложений, Telegram алерты."
            case .home: return "180с walk-away, увеличенный порог допуска (0.24), дружелюбный HUD."
            case .presentation: return "Авто-подавление блокировки во время показа слайдов и созвонов."
            case .lockdown: return "5с walk-away, сверхстрогий порог (0.18), защита от подглядывания, звуковая тревога."
            }
        }
    }

    public var pin: String
    public var similarityThreshold: Float
    public var verificationTimeout: Double
    public var debounceSeconds: Double
    public var isEnabled: Bool
    public var strictFaceMatch: Bool
    public var showHUD: Bool
    public var autoTriggerTouchID: Bool
    public var ignoredBundleIdentifiers: [String]

    public var telegramBotToken: String
    public var telegramChatId: String
    public var telegramEnabled: Bool

    public var protectionMode: String
    public var protectedBundleIdentifiers: [String]

    public var livenessDetectionEnabled: Bool

    public var walkAwayLockEnabled: Bool
    public var walkAwayIdleSeconds: Double
    public var lockOnWake: Bool
    public var maxFailedPinAttempts: Int
    public var pinLockoutSeconds: Double
    public var preferredCameraID: String

    public var activeProfile: String
    public var shoulderSurfingDefense: Bool
    public var batteryAwareScanning: Bool
    public var audibleAlerts: Bool
    public var presentationModeSuppression: Bool
    public var duressPin: String
    public var customPresentationBundleIdentifiers: [String]

    public init(
        pin: String = "0000",
        similarityThreshold: Float = 0.22,
        verificationTimeout: Double = 2.0,
        debounceSeconds: Double = 2.0,
        isEnabled: Bool = true,
        strictFaceMatch: Bool = true,
        showHUD: Bool = true,
        autoTriggerTouchID: Bool = true,
        ignoredBundleIdentifiers: [String] = Config.defaultIgnoredBundleIdentifiers,
        telegramBotToken: String = "",
        telegramChatId: String = "",
        telegramEnabled: Bool = false,
        protectionMode: String = "all",
        protectedBundleIdentifiers: [String] = Config.defaultProtectedBundleIdentifiers,
        livenessDetectionEnabled: Bool = true,
        walkAwayLockEnabled: Bool = true,
        walkAwayIdleSeconds: Double = 45.0,
        lockOnWake: Bool = false,
        maxFailedPinAttempts: Int = 3,
        pinLockoutSeconds: Double = 5.0,
        preferredCameraID: String = "",
        activeProfile: String = "normal",
        shoulderSurfingDefense: Bool = false,
        batteryAwareScanning: Bool = true,
        audibleAlerts: Bool = false,
        presentationModeSuppression: Bool = true,
        duressPin: String = "",
        customPresentationBundleIdentifiers: [String] = []
    ) {
        self.pin = pin
        self.similarityThreshold = similarityThreshold
        self.verificationTimeout = verificationTimeout
        self.debounceSeconds = debounceSeconds
        self.isEnabled = isEnabled
        self.strictFaceMatch = strictFaceMatch
        self.showHUD = showHUD
        self.autoTriggerTouchID = autoTriggerTouchID
        self.ignoredBundleIdentifiers = ignoredBundleIdentifiers
        self.telegramBotToken = telegramBotToken
        self.telegramChatId = telegramChatId
        self.telegramEnabled = telegramEnabled
        self.protectionMode = protectionMode
        self.protectedBundleIdentifiers = protectedBundleIdentifiers
        self.livenessDetectionEnabled = livenessDetectionEnabled
        self.walkAwayLockEnabled = walkAwayLockEnabled
        self.walkAwayIdleSeconds = walkAwayIdleSeconds
        self.lockOnWake = lockOnWake
        self.maxFailedPinAttempts = maxFailedPinAttempts
        self.pinLockoutSeconds = pinLockoutSeconds
        self.preferredCameraID = preferredCameraID
        self.activeProfile = activeProfile
        self.shoulderSurfingDefense = shoulderSurfingDefense
        self.batteryAwareScanning = batteryAwareScanning
        self.audibleAlerts = audibleAlerts
        self.presentationModeSuppression = presentationModeSuppression
        self.duressPin = duressPin
        self.customPresentationBundleIdentifiers = customPresentationBundleIdentifiers
    }

    private enum CodingKeys: String, CodingKey {
        case pin
        case similarityThreshold
        case verificationTimeout
        case debounceSeconds
        case isEnabled
        case strictFaceMatch
        case showHUD
        case autoTriggerTouchID
        case ignoredBundleIdentifiers
        case telegramBotToken
        case telegramChatId
        case telegramEnabled
        case protectionMode
        case protectedBundleIdentifiers
        case livenessDetectionEnabled
        case walkAwayLockEnabled
        case walkAwayIdleSeconds
        case lockOnWake
        case maxFailedPinAttempts
        case pinLockoutSeconds
        case preferredCameraID
        case activeProfile
        case shoulderSurfingDefense
        case batteryAwareScanning
        case audibleAlerts
        case presentationModeSuppression
        case duressPin
        case customPresentationBundleIdentifiers
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pin = try container.decodeIfPresent(String.self, forKey: .pin) ?? "0000"
        self.similarityThreshold = try container.decodeIfPresent(Float.self, forKey: .similarityThreshold) ?? 0.22
        self.verificationTimeout = try container.decodeIfPresent(Double.self, forKey: .verificationTimeout) ?? 2.0
        self.debounceSeconds = try container.decodeIfPresent(Double.self, forKey: .debounceSeconds) ?? 2.0
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.strictFaceMatch = try container.decodeIfPresent(Bool.self, forKey: .strictFaceMatch) ?? true
        self.showHUD = try container.decodeIfPresent(Bool.self, forKey: .showHUD) ?? true
        self.autoTriggerTouchID = try container.decodeIfPresent(Bool.self, forKey: .autoTriggerTouchID) ?? true
        self.ignoredBundleIdentifiers = try container.decodeIfPresent([String].self, forKey: .ignoredBundleIdentifiers) ?? Config.defaultIgnoredBundleIdentifiers
        self.telegramBotToken = try container.decodeIfPresent(String.self, forKey: .telegramBotToken) ?? ""
        self.telegramChatId = try container.decodeIfPresent(String.self, forKey: .telegramChatId) ?? ""
        self.telegramEnabled = try container.decodeIfPresent(Bool.self, forKey: .telegramEnabled) ?? false
        self.protectionMode = try container.decodeIfPresent(String.self, forKey: .protectionMode) ?? "all"
        self.protectedBundleIdentifiers = try container.decodeIfPresent([String].self, forKey: .protectedBundleIdentifiers) ?? Config.defaultProtectedBundleIdentifiers
        self.livenessDetectionEnabled = try container.decodeIfPresent(Bool.self, forKey: .livenessDetectionEnabled) ?? true
        self.walkAwayLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .walkAwayLockEnabled) ?? true
        self.walkAwayIdleSeconds = try container.decodeIfPresent(Double.self, forKey: .walkAwayIdleSeconds) ?? 45.0
        self.lockOnWake = try container.decodeIfPresent(Bool.self, forKey: .lockOnWake) ?? false
        self.maxFailedPinAttempts = try container.decodeIfPresent(Int.self, forKey: .maxFailedPinAttempts) ?? 3
        self.pinLockoutSeconds = try container.decodeIfPresent(Double.self, forKey: .pinLockoutSeconds) ?? 5.0
        self.preferredCameraID = try container.decodeIfPresent(String.self, forKey: .preferredCameraID) ?? ""
        self.activeProfile = try container.decodeIfPresent(String.self, forKey: .activeProfile) ?? "normal"
        self.shoulderSurfingDefense = try container.decodeIfPresent(Bool.self, forKey: .shoulderSurfingDefense) ?? false
        self.batteryAwareScanning = try container.decodeIfPresent(Bool.self, forKey: .batteryAwareScanning) ?? true
        self.audibleAlerts = try container.decodeIfPresent(Bool.self, forKey: .audibleAlerts) ?? false
        self.presentationModeSuppression = try container.decodeIfPresent(Bool.self, forKey: .presentationModeSuppression) ?? true
        self.duressPin = try container.decodeIfPresent(String.self, forKey: .duressPin) ?? ""
        self.customPresentationBundleIdentifiers = try container.decodeIfPresent([String].self, forKey: .customPresentationBundleIdentifiers) ?? []
    }

    public static func profile(named profileName: String) -> SecurityProfile? {
        let normalized = profileName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return SecurityProfile(rawValue: normalized)
    }

    public static func isValidProfile(_ profileName: String) -> Bool {
        return profile(named: profileName) != nil
    }

    public static func isValidThreshold(_ threshold: Float) -> Bool {
        return threshold >= 0.05 && threshold <= 0.60
    }

    public static func isValidTimeout(_ timeout: Double) -> Bool {
        return timeout >= 0.5 && timeout <= 10.0
    }

    public static func isValidDebounce(_ debounce: Double) -> Bool {
        return debounce >= 0.5 && debounce <= 30.0
    }

    public static func isValidPin(_ pin: String) -> Bool {
        let trimmed = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 4 && trimmed.allSatisfy { $0.isNumber }
    }

    public static func isValidWalkAwayTimeout(_ timeout: Double) -> Bool {
        return timeout >= 10.0 && timeout <= 600.0
    }

    public static func isValidProtectionMode(_ mode: String) -> Bool {
        let normalized = mode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return normalized == "all" || normalized == "selective"
    }

    public static func isValidPinAttempts(_ attempts: Int) -> Bool {
        return attempts >= 1 && attempts <= 10
    }

    public static func isValidPinLockout(_ seconds: Double) -> Bool {
        return seconds >= 1.0 && seconds <= 60.0
    }

    public static func isValidBundleIdentifier(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 255 else { return false }
        guard !trimmed.hasPrefix("-") else { return false }
        guard !trimmed.hasPrefix("."), !trimmed.hasSuffix(".") else { return false }
        guard !trimmed.contains("..") else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_")
        guard trimmed.unicodeScalars.allSatisfy({ allowed.contains($0) }) else { return false }
        let components = trimmed.components(separatedBy: ".")
        guard components.allSatisfy({ comp in
            guard let first = comp.first else { return false }
            return first.isLetter || first.isNumber || first == "_"
        }) else { return false }
        return true
    }

    public static func isValidDuressPin(_ candidate: String, masterPin: String) -> (isValid: Bool, error: String?) {
        let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (true, nil)
        }
        guard trimmed.count >= 4 && trimmed.count <= 8 else {
            return (false, "Код принуждения должен содержать от 4 до 8 цифр.")
        }
        guard trimmed.allSatisfy({ $0.isNumber }) else {
            return (false, "Код принуждения должен состоять только из цифр.")
        }
        let cleanMaster = masterPin.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != cleanMaster else {
            return (false, "Код принуждения не должен совпадать с основным мастер-PIN.")
        }
        return (true, nil)
    }

    public var isDuressPinEnabled: Bool {
        let trimmed = duressPin.trimmingCharacters(in: .whitespacesAndNewlines)
        let master = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed != master && trimmed.count >= 4 && trimmed.count <= 8 && trimmed.allSatisfy { $0.isNumber }
    }

    public func setDuressPin(_ newPin: String) -> (success: Bool, message: String) {
        let validation = Config.isValidDuressPin(newPin, masterPin: self.pin)
        if !validation.isValid {
            return (false, validation.error ?? "Недопустимый код принуждения.")
        }
        self.duressPin = newPin.trimmingCharacters(in: .whitespacesAndNewlines)
        self.save()
        return (true, "Код принуждения успешно установлен")
    }

    public func clearDuressPin() {
        self.duressPin = ""
        self.save()
    }

    public static var allProfileNames: [String] {
        return SecurityProfile.allCases.map { $0.rawValue }
    }

    public func setProfile(_ profileName: String) -> Bool {
        guard let profile = Config.profile(named: profileName) else {
            return false
        }
        applyProfile(profile)
        return true
    }

    public func applyProfile(_ profile: SecurityProfile) {
        let oldProfile = self.activeProfile
        self.activeProfile = profile.rawValue

        switch profile {
        case .normal:
            self.walkAwayIdleSeconds = 45.0
            self.walkAwayLockEnabled = true
            self.shoulderSurfingDefense = false
            self.lockOnWake = false
            self.audibleAlerts = false
            self.presentationModeSuppression = true
            self.similarityThreshold = 0.22
        case .cafe:
            self.walkAwayIdleSeconds = 10.0
            self.walkAwayLockEnabled = true
            self.shoulderSurfingDefense = true
            self.lockOnWake = true
            self.audibleAlerts = true
            self.presentationModeSuppression = false
            self.similarityThreshold = 0.20
        case .work:
            self.walkAwayIdleSeconds = 45.0
            self.walkAwayLockEnabled = true
            self.shoulderSurfingDefense = true
            self.lockOnWake = true
            self.audibleAlerts = false
            self.presentationModeSuppression = true
            self.similarityThreshold = 0.22
        case .home:
            self.walkAwayIdleSeconds = 180.0
            self.walkAwayLockEnabled = true
            self.shoulderSurfingDefense = false
            self.lockOnWake = false
            self.audibleAlerts = false
            self.presentationModeSuppression = true
            self.similarityThreshold = 0.24
        case .presentation:
            self.walkAwayIdleSeconds = 300.0
            self.walkAwayLockEnabled = false
            self.shoulderSurfingDefense = false
            self.lockOnWake = false
            self.audibleAlerts = false
            self.presentationModeSuppression = true
        case .lockdown:
            self.walkAwayIdleSeconds = 5.0
            self.walkAwayLockEnabled = true
            self.shoulderSurfingDefense = true
            self.lockOnWake = true
            self.audibleAlerts = true
            self.presentationModeSuppression = false
            self.similarityThreshold = 0.18
        }

        save()
        SecurityAuditLogger.shared.logProfileSwitched(from: oldProfile, to: profile.rawValue)
        HUDController.shared.showProfile(name: profile.title)
    }

    private static var configURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("config.json")
    }

    private static var vectorsURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock", isDirectory: true)
        return dir.appendingPathComponent("owner_face_vectors.json")
    }

    private static var lockStateURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock", isDirectory: true)
        return dir.appendingPathComponent("lock_state.json")
    }

    public static func saveLockState(isLocked: Bool) {
        let url = lockStateURL
        let dict: [String: Any] = [
            "isLocked": isLocked,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) {
            try? data.write(to: url)
        }
    }

    public static func getLockState() -> [String: Any] {
        let url = lockStateURL
        if let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json
        }
        return ["isLocked": false, "timestamp": "N/A"]
    }

    public static func load() -> Config {
        let url = configURL
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(Config.self, from: data) {
            // Apply strict Apple Neural Faceprint threshold (0.22)
            if decoded.similarityThreshold >= 0.28 {
                decoded.similarityThreshold = 0.22
                decoded.save()
            }
            return decoded
        }
        let fresh = Config()
        fresh.save()
        return fresh
    }

    public func save() {
        let url = Config.configURL
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self) {
            try? data.write(to: url, options: .atomic)
        }
    }

    public func reload() {
        if let data = try? Data(contentsOf: Config.configURL),
           let fresh = try? JSONDecoder().decode(Config.self, from: data) {
            self.pin = fresh.pin
            self.similarityThreshold = fresh.similarityThreshold
            self.verificationTimeout = fresh.verificationTimeout
            self.debounceSeconds = fresh.debounceSeconds
            self.isEnabled = fresh.isEnabled
            self.strictFaceMatch = fresh.strictFaceMatch
            self.showHUD = fresh.showHUD
            self.autoTriggerTouchID = fresh.autoTriggerTouchID
            self.ignoredBundleIdentifiers = fresh.ignoredBundleIdentifiers
            self.telegramBotToken = fresh.telegramBotToken
            self.telegramChatId = fresh.telegramChatId
            self.telegramEnabled = fresh.telegramEnabled
            self.protectionMode = fresh.protectionMode
            self.protectedBundleIdentifiers = fresh.protectedBundleIdentifiers
            self.livenessDetectionEnabled = fresh.livenessDetectionEnabled
            self.walkAwayLockEnabled = fresh.walkAwayLockEnabled
            self.walkAwayIdleSeconds = fresh.walkAwayIdleSeconds
            self.lockOnWake = fresh.lockOnWake
            self.maxFailedPinAttempts = fresh.maxFailedPinAttempts
            self.pinLockoutSeconds = fresh.pinLockoutSeconds
            self.preferredCameraID = fresh.preferredCameraID
            self.activeProfile = fresh.activeProfile
            self.shoulderSurfingDefense = fresh.shoulderSurfingDefense
            self.batteryAwareScanning = fresh.batteryAwareScanning
            self.audibleAlerts = fresh.audibleAlerts
            self.presentationModeSuppression = fresh.presentationModeSuppression
            self.duressPin = fresh.duressPin
            self.customPresentationBundleIdentifiers = fresh.customPresentationBundleIdentifiers
        }
    }

    public func backupConfig(to destinationPath: String) throws -> String {
        let expanded = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expanded)
        let parentDir = destURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: destURL, options: .atomic)
        return destURL.path
    }

    public func exportConfig(to destinationPath: String) throws -> String {
        return try backupConfig(to: destinationPath)
    }

    public func restoreConfig(from sourcePath: String) throws {
        let expanded = NSString(string: sourcePath).expandingTildeInPath
        let sourceURL = URL(fileURLWithPath: expanded)
        let data = try Data(contentsOf: sourceURL)
        let imported = try JSONDecoder().decode(Config.self, from: data)
        self.pin = imported.pin
        self.similarityThreshold = imported.similarityThreshold
        self.verificationTimeout = imported.verificationTimeout
        self.debounceSeconds = imported.debounceSeconds
        self.isEnabled = imported.isEnabled
        self.strictFaceMatch = imported.strictFaceMatch
        self.showHUD = imported.showHUD
        self.autoTriggerTouchID = imported.autoTriggerTouchID
        self.ignoredBundleIdentifiers = imported.ignoredBundleIdentifiers
        self.telegramBotToken = imported.telegramBotToken
        self.telegramChatId = imported.telegramChatId
        self.telegramEnabled = imported.telegramEnabled
        self.protectionMode = imported.protectionMode
        self.protectedBundleIdentifiers = imported.protectedBundleIdentifiers
        self.livenessDetectionEnabled = imported.livenessDetectionEnabled
        self.walkAwayLockEnabled = imported.walkAwayLockEnabled
        self.walkAwayIdleSeconds = imported.walkAwayIdleSeconds
        self.lockOnWake = imported.lockOnWake
        self.maxFailedPinAttempts = imported.maxFailedPinAttempts
        self.pinLockoutSeconds = imported.pinLockoutSeconds
        self.preferredCameraID = imported.preferredCameraID
        self.activeProfile = imported.activeProfile
        self.shoulderSurfingDefense = imported.shoulderSurfingDefense
        self.batteryAwareScanning = imported.batteryAwareScanning
        self.audibleAlerts = imported.audibleAlerts
        self.presentationModeSuppression = imported.presentationModeSuppression
        self.duressPin = imported.duressPin
        self.customPresentationBundleIdentifiers = imported.customPresentationBundleIdentifiers
        self.save()
    }

    public func importConfig(from sourcePath: String) throws {
        try restoreConfig(from: sourcePath)
    }

    public var hasEnrolledFace: Bool {
        return !loadEnrolledVectors().isEmpty
    }

    public func toDictionary() -> [String: Any] {
        return [
            "pin": pin,
            "similarityThreshold": Double(similarityThreshold),
            "verificationTimeout": verificationTimeout,
            "debounceSeconds": debounceSeconds,
            "isEnabled": isEnabled,
            "strictFaceMatch": strictFaceMatch,
            "showHUD": showHUD,
            "autoTriggerTouchID": autoTriggerTouchID,
            "ignoredBundleIdentifiers": ignoredBundleIdentifiers,
            "telegramBotToken": telegramBotToken.isEmpty ? "" : "••••••••",
            "telegramChatId": telegramChatId,
            "telegramEnabled": telegramEnabled,
            "protectionMode": protectionMode,
            "protectedBundleIdentifiers": protectedBundleIdentifiers,
            "livenessDetectionEnabled": livenessDetectionEnabled,
            "walkAwayLockEnabled": walkAwayLockEnabled,
            "walkAwayIdleSeconds": walkAwayIdleSeconds,
            "lockOnWake": lockOnWake,
            "maxFailedPinAttempts": maxFailedPinAttempts,
            "pinLockoutSeconds": pinLockoutSeconds,
            "preferredCameraID": preferredCameraID.isEmpty ? "default" : preferredCameraID,
            "activeProfile": activeProfile,
            "shoulderSurfingDefense": shoulderSurfingDefense,
            "batteryAwareScanning": batteryAwareScanning,
            "audibleAlerts": audibleAlerts,
            "presentationModeSuppression": presentationModeSuppression,
            "duressPin": duressPin.isEmpty ? "" : "••••••••",
            "isDuressPinEnabled": isDuressPinEnabled,
            "hasEnrolledFace": hasEnrolledFace,
            "protectedAppsCount": protectedBundleIdentifiers.count,
            "ignoredAppsCount": ignoredBundleIdentifiers.count,
            "customPresentationBundleIdentifiers": customPresentationBundleIdentifiers,
            "customMeetingAppsCount": customPresentationBundleIdentifiers.count,
            "enrolledVectorsCount": loadEnrolledVectors().count
        ]
    }

    public func loadEnrolledVectors() -> [[Float]] {
        let url = Config.vectorsURL
        guard let data = try? Data(contentsOf: url),
              let array = try? JSONDecoder().decode([[Float]].self, from: data) else {
            return []
        }
        return array
    }

    public func saveEnrolledVectors(_ vectors: [[Float]]) {
        let url = Config.vectorsURL
        if let data = try? JSONEncoder().encode(vectors) {
            try? data.write(to: url, options: .atomic)
            AppDelegate.notifyDaemonReload()
        }
    }

    public static func isValidVector(_ vector: [Float]) -> Bool {
        return vector.count == 128 && !vector.contains(where: { $0.isNaN || $0.isInfinite })
    }

    public func addEnrolledVector(_ vector: [Float]) {
        guard Config.isValidVector(vector) else {
            print("[Config] Rejected invalid face vector (must be 128 finite floats).")
            return
        }
        var current = loadEnrolledVectors()
        current.append(vector)
        if current.count > 30 {
            current.removeFirst(current.count - 30)
        }
        saveEnrolledVectors(current)
        print("[Config] Added new face vector sample. Total enrolled: \(current.count)")
    }

    public func isProtected(bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return protectedBundleIdentifiers.contains { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    public func isIgnored(bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return ignoredBundleIdentifiers.contains { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    public func addProtectedApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if !isProtected(bundleId: trimmed) {
            protectedBundleIdentifiers.append(trimmed)
            save()
            return true
        }
        return false
    }

    public func removeProtectedApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if let idx = protectedBundleIdentifiers.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            protectedBundleIdentifiers.remove(at: idx)
            save()
            return true
        }
        return false
    }

    public func addIgnoredApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if !isIgnored(bundleId: trimmed) {
            ignoredBundleIdentifiers.append(trimmed)
            save()
            return true
        }
        return false
    }

    public func removeIgnoredApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if let idx = ignoredBundleIdentifiers.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            ignoredBundleIdentifiers.remove(at: idx)
            save()
            return true
        }
        return false
    }

    public func resetProtectedApps() {
        self.protectedBundleIdentifiers = Config.defaultProtectedBundleIdentifiers
        save()
    }

    public func resetIgnoredApps() {
        self.ignoredBundleIdentifiers = Config.defaultIgnoredBundleIdentifiers
        save()
    }

    public func resetAllAppLists() {
        self.protectedBundleIdentifiers = Config.defaultProtectedBundleIdentifiers
        self.ignoredBundleIdentifiers = Config.defaultIgnoredBundleIdentifiers
        save()
    }

    public func addMeetingApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if !customPresentationBundleIdentifiers.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            customPresentationBundleIdentifiers.append(trimmed)
            save()
            return true
        }
        return false
    }

    public func removeMeetingApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Config.isValidBundleIdentifier(trimmed) else { return false }
        if let idx = customPresentationBundleIdentifiers.firstIndex(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            customPresentationBundleIdentifiers.remove(at: idx)
            save()
            return true
        }
        return false
    }

    public func resetMeetingApps() {
        self.customPresentationBundleIdentifiers = []
        save()
    }

    public static func localizedAppName(for bundleId: String) -> String {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            let bundle = Bundle(url: url)
            if let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, !displayName.isEmpty {
                return displayName
            }
            if let name = bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String, !name.isEmpty {
                return name
            }
            return url.deletingPathExtension().lastPathComponent
        }
        switch bundleId {
        case "ru.keepcoder.Telegram": return "Telegram"
        case "com.apple.Safari": return "Safari"
        case "com.google.Chrome": return "Google Chrome"
        case "com.apple.mobilesms": return "Messages"
        case "com.apple.Notes": return "Notes"
        case "com.apple.Photos": return "Photos"
        case "com.apple.mail": return "Mail"
        case "com.apple.Terminal": return "Terminal"
        case "com.googlecode.iterm2": return "iTerm2"
        case "net.whatsapp.WhatsApp": return "WhatsApp"
        case "com.apple.keychainaccess": return "Keychain Access"
        case "com.apple.systempreferences": return "System Settings"
        case "io.github.facelock": return "FaceLock"
        case "com.apple.controlcenter": return "Control Center"
        case "com.apple.notificationcenterui": return "Notification Center"
        case "com.apple.Spotlight": return "Spotlight"
        case "com.apple.WindowManager": return "Window Manager"
        case "com.apple.loginwindow": return "Login Window"
        case "com.apple.ScreenSaver.Engine": return "Screen Saver"
        case "com.apple.systemuiserver": return "SystemUIServer"
        case "com.apple.dock": return "Dock"
        default:
            return bundleId.components(separatedBy: ".").last?.capitalized ?? bundleId
        }
    }

    public static func appIcon(for bundleId: String, size: NSSize = NSSize(width: 32, height: 32)) -> NSImage {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            icon.size = size
            return icon
        }
        let config = NSImage.SymbolConfiguration(pointSize: size.width * 0.7, weight: .regular)
        if let img = NSImage(systemSymbolName: "app.dashed", accessibilityDescription: bundleId)?.withSymbolConfiguration(config) {
            return img
        }
        let fallback = NSWorkspace.shared.icon(for: .application)
        fallback.size = size
        return fallback
    }

    @discardableResult
    public func clearEnrolledVectors() -> Int {
        let count = loadEnrolledVectors().count
        let url = Config.vectorsURL
        try? FileManager.default.removeItem(at: url)
        AppDelegate.notifyDaemonReload()
        return count
    }

    public func exportVectors(to destinationPath: String) throws -> Int {
        let expandedPath = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expandedPath)
        let parentDir = destURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentDir.path) {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }
        let vectors = loadEnrolledVectors()
        guard !vectors.isEmpty else {
            throw NSError(domain: "io.github.facelock", code: 1, userInfo: [NSLocalizedDescriptionKey: "No enrolled face vectors found to export"])
        }
        let data = try JSONEncoder().encode(vectors)
        try data.write(to: destURL, options: .atomic)
        return vectors.count
    }

    public func backupVectors(to destinationPath: String) throws -> Int {
        return try exportVectors(to: destinationPath)
    }

    public func restoreVectors(from sourcePath: String, merge: Bool = true) throws -> Int {
        return try importVectors(from: sourcePath, merge: merge)
    }

    public func importVectors(from sourcePath: String, merge: Bool = true) throws -> Int {
        let expandedPath = NSString(string: sourcePath).expandingTildeInPath
        let sourceURL = URL(fileURLWithPath: expandedPath)
        let data = try Data(contentsOf: sourceURL)
        let imported = try JSONDecoder().decode([[Float]].self, from: data)
        guard !imported.isEmpty else {
            throw NSError(domain: "io.github.facelock", code: 2, userInfo: [NSLocalizedDescriptionKey: "Imported vector file is empty"])
        }
        let validVectors = imported.filter { Config.isValidVector($0) }
        guard !validVectors.isEmpty else {
            throw NSError(domain: "io.github.facelock", code: 3, userInfo: [NSLocalizedDescriptionKey: "Imported vector file contains no valid 128-dimensional biometric templates"])
        }
        var combined: [[Float]]
        if merge {
            combined = loadEnrolledVectors()
            for vec in validVectors {
                if !combined.contains(where: { $0 == vec }) {
                    combined.append(vec)
                }
            }
        } else {
            combined = validVectors
        }
        if combined.count > 30 {
            combined = Array(combined.suffix(30))
        }
        saveEnrolledVectors(combined)
        return combined.count
    }

    public func getVectorMetrics() -> [String: Any] {
        let vectors = loadEnrolledVectors()
        let count = vectors.count
        let dims = vectors.first?.count ?? 0
        let url = Config.vectorsURL

        var fileSizeBytes: UInt64 = 0
        var modDateStr = "N/A"
        var isoModDate: String? = nil

        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
            fileSizeBytes = attrs[.size] as? UInt64 ?? 0
            if let date = attrs[.modificationDate] as? Date {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
                modDateStr = fmt.string(from: date)
                isoModDate = ISO8601DateFormatter().string(from: date)
            }
        }

        var minPairwise: Float = 0
        var maxPairwise: Float = 0
        var avgPairwise: Float = 0
        var stdDevPairwise: Float = 0
        var qualityStr = "None"

        if count >= 2 {
            var distances: [Float] = []
            for i in 0..<count {
                for j in (i + 1)..<count {
                    distances.append(FaceprintExtractor.cosineDistance(vectors[i], vectors[j]))
                }
            }
            if !distances.isEmpty {
                let sum = distances.reduce(0, +)
                let avg = sum / Float(distances.count)
                let sorted = distances.sorted()
                let minVal = sorted.first ?? 0
                let maxVal = sorted.last ?? 0
                let variance = distances.map { pow($0 - avg, 2) }.reduce(0, +) / Float(distances.count)
                let stdDev = sqrt(variance)

                minPairwise = minVal
                maxPairwise = maxVal
                avgPairwise = avg
                stdDevPairwise = stdDev

                if avg <= 0.12 {
                    qualityStr = "Optimal (Excellent cluster tightness)"
                } else if avg <= 0.20 {
                    qualityStr = "Good (Solid biometric consistency)"
                } else {
                    qualityStr = "Fair (High template variance)"
                }
            }
        } else if count == 1 {
            qualityStr = "Single Sample (Calibration recommended for multi-angle robustness)"
        } else {
            qualityStr = "No Templates Enrolled"
        }

        var result: [String: Any] = [
            "count": count,
            "dimensions": dims,
            "quality": qualityStr,
            "filePath": url.path,
            "fileSizeBytes": fileSizeBytes,
            "lastModified": modDateStr
        ]
        if let iso = isoModDate {
            result["lastModifiedISO"] = iso
        }
        if count >= 2 {
            result["minPairwiseDistance"] = Double(minPairwise)
            result["maxPairwiseDistance"] = Double(maxPairwise)
            result["avgPairwiseDistance"] = Double(avgPairwise)
            result["standardDeviation"] = Double(stdDevPairwise)
        }
        return result
    }

    public func optimizeVectors(maxVectors: Int = 12) -> [String: Any] {
        let originalVectors = loadEnrolledVectors()
        let initialCount = originalVectors.count
        guard initialCount > 1 else {
            let metrics = getVectorMetrics()
            return [
                "initialCount": initialCount,
                "optimizedCount": initialCount,
                "prunedRedundant": 0,
                "prunedOutliers": 0,
                "initialQuality": metrics["quality"] as? String ?? "N/A",
                "optimizedQuality": metrics["quality"] as? String ?? "N/A",
                "initialAvgDistance": metrics["avgPairwiseDistance"] as? Double ?? 0.0,
                "optimizedAvgDistance": metrics["avgPairwiseDistance"] as? Double ?? 0.0
            ]
        }

        let initialMetrics = getVectorMetrics()
        let initialAvgDist = initialMetrics["avgPairwiseDistance"] as? Double ?? 0.0
        let initialQuality = initialMetrics["quality"] as? String ?? "N/A"

        // 1. Redundancy filter: drop vectors that are nearly identical (cosine dist < 0.035)
        var deduped: [[Float]] = []
        var prunedRedundant = 0

        for vec in originalVectors {
            let isTooClose = deduped.contains { existing in
                FaceprintExtractor.cosineDistance(vec, existing) < 0.035
            }
            if isTooClose {
                prunedRedundant += 1
            } else {
                deduped.append(vec)
            }
        }

        // 2. Outlier filtering
        var filtered = deduped
        var prunedOutliers = 0

        if deduped.count >= 3 {
            let dim = deduped[0].count
            var centroid = [Float](repeating: 0.0, count: dim)
            for vec in deduped {
                for i in 0..<dim {
                    centroid[i] += vec[i]
                }
            }
            for i in 0..<dim {
                centroid[i] /= Float(deduped.count)
            }
            let norm = sqrt(centroid.reduce(0) { $0 + $1 * $1 })
            if norm > 0.0001 {
                for i in 0..<dim {
                    centroid[i] /= norm
                }
            }

            let distsToCentroid = deduped.map { FaceprintExtractor.cosineDistance($0, centroid) }
            let meanDist = distsToCentroid.reduce(0, +) / Float(distsToCentroid.count)
            let variance = distsToCentroid.map { pow($0 - meanDist, 2) }.reduce(0, +) / Float(distsToCentroid.count)
            let stdDev = sqrt(variance)

            var nonOutliers: [[Float]] = []
            for (idx, vec) in deduped.enumerated() {
                let d = distsToCentroid[idx]
                if d > (meanDist + 1.8 * stdDev) && d > 0.22 {
                    prunedOutliers += 1
                } else {
                    nonOutliers.append(vec)
                }
            }
            if nonOutliers.count >= 2 {
                filtered = nonOutliers
            }
        }

        // 3. Bound to maxVectors if needed
        if filtered.count > maxVectors {
            filtered = Array(filtered.suffix(maxVectors))
        }

        // Save optimized vectors if any were removed
        if filtered.count != initialCount {
            saveEnrolledVectors(filtered)
        }

        let finalMetrics = getVectorMetrics()
        let finalAvgDist = finalMetrics["avgPairwiseDistance"] as? Double ?? 0.0
        let finalQuality = finalMetrics["quality"] as? String ?? "N/A"

        return [
            "initialCount": initialCount,
            "optimizedCount": filtered.count,
            "prunedRedundant": prunedRedundant,
            "prunedOutliers": prunedOutliers,
            "initialQuality": initialQuality,
            "optimizedQuality": finalQuality,
            "initialAvgDistance": initialAvgDist,
            "optimizedAvgDistance": finalAvgDist
        ]
    }

    public func analyzeTemplateConsistency(vectors: [[Float]]? = nil) -> [String: Any] {
        let actualVectors = vectors ?? loadEnrolledVectors()
        let count = actualVectors.count
        guard count >= 2 else {
            return [
                "count": count,
                "status": count == 1 ? "SINGLE_SAMPLE" : "EMPTY",
                "cohesionScore": count == 1 ? 1.0 : 0.0,
                "diversityScore": 0.0,
                "medoidIndex": count == 1 ? 0 : -1,
                "recommendation": count == 1
                    ? "Enroll 3-5 additional angles in different lighting to improve biometric stability."
                    : "No facial vectors enrolled. Run 'facelock --enroll' to calibrate."
            ]
        }

        let dim = actualVectors[0].count
        // 1. Calculate centroid
        var centroid = [Float](repeating: 0.0, count: dim)
        for vec in actualVectors {
            for i in 0..<dim {
                centroid[i] += vec[i]
            }
        }
        for i in 0..<dim {
            centroid[i] /= Float(count)
        }
        let norm = sqrt(centroid.reduce(0) { $0 + $1 * $1 })
        if norm > 0.0001 {
            for i in 0..<dim {
                centroid[i] /= norm
            }
        }

        // 2. Find medoid (vector closest to centroid)
        var minCentroidDist: Float = Float.greatestFiniteMagnitude
        var medoidIdx = 0
        var distancesToCentroid: [Float] = []

        for (idx, vec) in actualVectors.enumerated() {
            let dist = FaceprintExtractor.cosineDistance(vec, centroid)
            distancesToCentroid.append(dist)
            if dist < minCentroidDist {
                minCentroidDist = dist
                medoidIdx = idx
            }
        }

        let avgDistToCentroid = distancesToCentroid.reduce(0, +) / Float(count)

        // 3. Pairwise distances
        var pairwiseDistances: [Float] = []
        for i in 0..<count {
            for j in (i + 1)..<count {
                pairwiseDistances.append(FaceprintExtractor.cosineDistance(actualVectors[i], actualVectors[j]))
            }
        }

        let avgPairwise = pairwiseDistances.isEmpty ? 0.0 : (pairwiseDistances.reduce(0, +) / Float(pairwiseDistances.count))
        let minPairwise = pairwiseDistances.min() ?? 0.0
        let maxPairwise = pairwiseDistances.max() ?? 0.0

        // Cohesion: 1.0 is highest (tight cluster <= 0.05), dropping to 0.0 at >= 0.25
        let cohesion = max(0.0, min(1.0, 1.0 - (Double(avgPairwise) / 0.25)))

        // Diversity: evaluates spread between min and max pairwise distance
        let hasNearDuplicates = minPairwise < 0.02
        let diversityScore = max(0.0, min(1.0, Double(maxPairwise - minPairwise) / 0.18))

        var rec: String = "Biometric cluster is well-balanced."
        var statusStr = "OPTIMAL"

        if avgPairwise > 0.20 {
            statusStr = "DISPERSE"
            rec = "Template cluster shows high variance (>0.20). Consider pruning outliers with 'facelock --optimize-vectors'."
        } else if hasNearDuplicates && count > 6 {
            statusStr = "REDUNDANT"
            rec = "Detected near-identical template captures. Pruning redundant vectors will increase check speeds."
        } else if count < 4 {
            statusStr = "ADEQUATE"
            rec = "Good baseline. Enrolling 2-3 additional angles (with glasses, smile, slight tilt) will boost recognition."
        }

        return [
            "count": count,
            "status": statusStr,
            "cohesionScore": Double(round(cohesion * 1000) / 1000),
            "diversityScore": Double(round(diversityScore * 1000) / 1000),
            "medoidIndex": medoidIdx,
            "minPairwiseDistance": Double(minPairwise),
            "maxPairwiseDistance": Double(maxPairwise),
            "avgPairwiseDistance": Double(avgPairwise),
            "avgDistanceToCentroid": Double(avgDistToCentroid),
            "recommendation": rec
        ]
    }

    @discardableResult
    public func autoHardenSecurity() -> [String: Any] {
        let initialReport = Diagnostics.assessSecurityPosture(config: self)
        var changesApplied: [String] = []

        if !self.isEnabled {
            self.isEnabled = true
            changesApplied.append("Enabled FaceLock shield protection")
        }

        if !self.walkAwayLockEnabled {
            self.walkAwayLockEnabled = true
            changesApplied.append("Enabled walk-away auto-lock detection")
        }

        if self.walkAwayIdleSeconds > 45.0 {
            let oldSec = Int(self.walkAwayIdleSeconds)
            self.walkAwayIdleSeconds = 45.0
            changesApplied.append("Tightened walk-away timeout from \(oldSec)s to 45s")
        }

        if !self.shoulderSurfingDefense {
            self.shoulderSurfingDefense = true
            changesApplied.append("Enabled Shoulder-Surfing bystander defense")
        }

        if !self.livenessDetectionEnabled {
            self.livenessDetectionEnabled = true
            changesApplied.append("Enabled neural anti-spoofing liveness detection")
        }

        if !self.lockOnWake {
            self.lockOnWake = true
            changesApplied.append("Enabled instant biometric lock upon display/clamshell wake")
        }

        if !self.batteryAwareScanning {
            self.batteryAwareScanning = true
            changesApplied.append("Enabled battery-aware adaptive camera sweep throttling")
        }

        if !self.presentationModeSuppression {
            self.presentationModeSuppression = true
            changesApplied.append("Enabled presentation and video call lock auto-suppression")
        }

        if self.maxFailedPinAttempts > 5 {
            let old = self.maxFailedPinAttempts
            self.maxFailedPinAttempts = 5
            changesApplied.append("Hardened PIN brute-force threshold from \(old) to 5 attempts")
        }

        if self.pinLockoutSeconds < 5.0 {
            self.pinLockoutSeconds = 5.0
            changesApplied.append("Set PIN cooling lockout delay to at least 5.0s")
        }

        let repairResult = CameraScanner.shared.repairCorruptedIncidents()
        if repairResult.repairedCount > 0 {
            changesApplied.append("Repaired \(repairResult.repairedCount) corrupted intruder capture file(s)")
        }

        if !changesApplied.isEmpty {
            self.save()
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "securityPostureHardening",
                value: "applied",
                details: "\(changesApplied.count) security control(s) hardened via autoHardenSecurity"
            )
        }

        let hardenedReport = Diagnostics.assessSecurityPosture(config: self)
        let scoreDelta = hardenedReport.score - initialReport.score

        return [
            "success": true,
            "initialScore": initialReport.score,
            "initialGrade": initialReport.grade,
            "hardenedScore": hardenedReport.score,
            "hardenedGrade": hardenedReport.grade,
            "scoreDelta": scoreDelta,
            "status": hardenedReport.status,
            "changesApplied": changesApplied,
            "recommendations": hardenedReport.recommendations
        ]
    }

    public struct ConfigValidationIssue: Codable {
        public let key: String
        public let severity: String
        public let message: String
        public let remediation: String

        public init(key: String, severity: String, message: String, remediation: String) {
            self.key = key
            self.severity = severity
            self.message = message
            self.remediation = remediation
        }

        public func toDictionary() -> [String: String] {
            return [
                "key": key,
                "severity": severity,
                "message": message,
                "remediation": remediation
            ]
        }
    }

    public struct ConfigValidationReport {
        public let isValid: Bool
        public let errorCount: Int
        public let warningCount: Int
        public let infoCount: Int
        public let issues: [ConfigValidationIssue]
        public let suggestions: [String]

        public init(
            isValid: Bool,
            errorCount: Int,
            warningCount: Int,
            infoCount: Int,
            issues: [ConfigValidationIssue],
            suggestions: [String]
        ) {
            self.isValid = isValid
            self.errorCount = errorCount
            self.warningCount = warningCount
            self.infoCount = infoCount
            self.issues = issues
            self.suggestions = suggestions
        }

        public func toDictionary() -> [String: Any] {
            return [
                "isValid": isValid,
                "errorCount": errorCount,
                "warningCount": warningCount,
                "infoCount": infoCount,
                "issues": issues.map { $0.toDictionary() },
                "suggestions": suggestions
            ]
        }
    }

    public static func validateConfig(_ targetConfig: Config? = nil) -> ConfigValidationReport {
        let config = targetConfig ?? Config.shared
        var issues: [ConfigValidationIssue] = []
        var suggestions: [String] = []

        // 1. PIN Validation
        if !Config.isValidPin(config.pin) {
            issues.append(ConfigValidationIssue(
                key: "pin",
                severity: "ERROR",
                message: "PIN must consist of 4 to 8 decimal digits (current: '\(config.pin)').",
                remediation: "facelock --set-pin <4-8 digits>"
            ))
        } else if config.pin == "0000" || config.pin == "1234" {
            issues.append(ConfigValidationIssue(
                key: "pin",
                severity: "WARNING",
                message: "Using default or trivial PIN '\(config.pin)' reduces unlock security.",
                remediation: "facelock --set-pin <unique-pin>"
            ))
        }
        if config.pin.count < 6 {
            suggestions.append("Upgrade PIN to 6 or 8 digits to defend against shoulder-surfing and brute-force.")
        }

        // 2. Thresholds and Timers
        if !Config.isValidThreshold(config.similarityThreshold) {
            issues.append(ConfigValidationIssue(
                key: "similarityThreshold",
                severity: "ERROR",
                message: "Similarity threshold must be between 0.05 and 0.50 (current: \(config.similarityThreshold)).",
                remediation: "facelock --set-threshold 0.22"
            ))
        } else if config.similarityThreshold > 0.30 {
            issues.append(ConfigValidationIssue(
                key: "similarityThreshold",
                severity: "WARNING",
                message: "High similarity threshold (\(config.similarityThreshold)) increases risk of false positive biometric acceptance.",
                remediation: "facelock --set-threshold 0.22"
            ))
        }

        if !Config.isValidTimeout(config.verificationTimeout) {
            issues.append(ConfigValidationIssue(
                key: "verificationTimeout",
                severity: "ERROR",
                message: "Verification timeout must be between 0.5s and 10.0s (current: \(config.verificationTimeout)s).",
                remediation: "facelock --set-timeout 2.0"
            ))
        }

        if !Config.isValidDebounce(config.debounceSeconds) {
            issues.append(ConfigValidationIssue(
                key: "debounceSeconds",
                severity: "ERROR",
                message: "Debounce interval must be between 0.5s and 30.0s (current: \(config.debounceSeconds)s).",
                remediation: "facelock --set-debounce 2.0"
            ))
        }

        if !Config.isValidWalkAwayTimeout(config.walkAwayIdleSeconds) {
            issues.append(ConfigValidationIssue(
                key: "walkAwayIdleSeconds",
                severity: "ERROR",
                message: "Walk-away idle timeout must be between 5s and 600s (current: \(config.walkAwayIdleSeconds)s).",
                remediation: "facelock --set-walkaway 45"
            ))
        }

        if !Config.isValidPinAttempts(config.maxFailedPinAttempts) {
            issues.append(ConfigValidationIssue(
                key: "maxFailedPinAttempts",
                severity: "ERROR",
                message: "Max failed PIN attempts must be between 1 and 10 (current: \(config.maxFailedPinAttempts)).",
                remediation: "facelock --set-pin-attempts 3"
            ))
        }

        if !Config.isValidPinLockout(config.pinLockoutSeconds) {
            issues.append(ConfigValidationIssue(
                key: "pinLockoutSeconds",
                severity: "ERROR",
                message: "PIN lockout cooling period must be between 1.0s and 60.0s (current: \(config.pinLockoutSeconds)s).",
                remediation: "facelock --set-pin-lockout 5"
            ))
        }

        // 3. Security Profile
        if !Config.isValidProfile(config.activeProfile) {
            issues.append(ConfigValidationIssue(
                key: "activeProfile",
                severity: "ERROR",
                message: "Unknown security profile '\(config.activeProfile)'. Valid: normal, cafe, work, home, presentation, lockdown.",
                remediation: "facelock --profile normal"
            ))
        }

        // 4. Protection Mode
        if !Config.isValidProtectionMode(config.protectionMode) {
            issues.append(ConfigValidationIssue(
                key: "protectionMode",
                severity: "ERROR",
                message: "Invalid protection mode '\(config.protectionMode)'. Valid modes: all, selective.",
                remediation: "facelock --set-mode all"
            ))
        }

        // 5. Application Bundle Identifiers
        var seenProtected: Set<String> = []
        for bundle in config.protectedBundleIdentifiers {
            if !Config.isValidBundleIdentifier(bundle) {
                issues.append(ConfigValidationIssue(
                    key: "protectedBundleIdentifiers",
                    severity: "ERROR",
                    message: "Invalid bundle identifier format '\(bundle)' in protected list.",
                    remediation: "facelock --unprotect-app \(bundle)"
                ))
            } else if seenProtected.contains(bundle.lowercased()) {
                issues.append(ConfigValidationIssue(
                    key: "protectedBundleIdentifiers",
                    severity: "WARNING",
                    message: "Duplicate bundle identifier '\(bundle)' in protected list.",
                    remediation: "facelock --unprotect-app \(bundle)"
                ))
            } else {
                seenProtected.insert(bundle.lowercased())
            }
        }

        var seenIgnored: Set<String> = []
        for bundle in config.ignoredBundleIdentifiers {
            if !Config.isValidBundleIdentifier(bundle) {
                issues.append(ConfigValidationIssue(
                    key: "ignoredBundleIdentifiers",
                    severity: "ERROR",
                    message: "Invalid bundle identifier format '\(bundle)' in ignored list.",
                    remediation: "facelock --unignore-app \(bundle)"
                ))
            } else if seenIgnored.contains(bundle.lowercased()) {
                issues.append(ConfigValidationIssue(
                    key: "ignoredBundleIdentifiers",
                    severity: "WARNING",
                    message: "Duplicate bundle identifier '\(bundle)' in ignored list.",
                    remediation: "facelock --unignore-app \(bundle)"
                ))
            } else {
                seenIgnored.insert(bundle.lowercased())
            }

            if seenProtected.contains(bundle.lowercased()) {
                issues.append(ConfigValidationIssue(
                    key: "ignoredBundleIdentifiers",
                    severity: "WARNING",
                    message: "Bundle identifier '\(bundle)' is present in both protected and ignored lists (ignored takes precedence).",
                    remediation: "facelock --unprotect-app \(bundle) or facelock --unignore-app \(bundle)"
                ))
            }
        }

        // 6. Telegram Configuration
        if config.telegramEnabled {
            let token = config.telegramBotToken.trimmingCharacters(in: .whitespacesAndNewlines)
            let chatId = config.telegramChatId.trimmingCharacters(in: .whitespacesAndNewlines)
            if token.isEmpty {
                issues.append(ConfigValidationIssue(
                    key: "telegramBotToken",
                    severity: "ERROR",
                    message: "Telegram alerts are enabled but bot token is empty.",
                    remediation: "facelock --set-telegram <token> <chatId>"
                ))
            } else if !token.contains(":") {
                issues.append(ConfigValidationIssue(
                    key: "telegramBotToken",
                    severity: "WARNING",
                    message: "Telegram bot token does not contain standard format '<botId>:<hash>'.",
                    remediation: "facelock --set-telegram <validToken> <chatId>"
                ))
            }
            if chatId.isEmpty {
                issues.append(ConfigValidationIssue(
                    key: "telegramChatId",
                    severity: "ERROR",
                    message: "Telegram alerts are enabled but chat ID is empty.",
                    remediation: "facelock --set-telegram <token> <chatId>"
                ))
            }
        }

        // 7. Defense Suggestions
        if !config.lockOnWake {
            suggestions.append("Enable screen wake verification (--toggle-wake) to shield Mac upon lid open.")
        }
        if !config.shoulderSurfingDefense {
            suggestions.append("Enable shoulder-surfing defense (--toggle-shoulder) for bystander detection in public spaces.")
        }
        if !config.batteryAwareScanning {
            suggestions.append("Enable battery-aware scanning (--toggle-battery-aware) to preserve battery life.")
        }
        if !config.presentationModeSuppression {
            suggestions.append("Enable presentation mode auto-suppression (--toggle-presentation) to prevent locks during calls.")
        }

        let errs = issues.filter { $0.severity == "ERROR" }.count
        let warns = issues.filter { $0.severity == "WARNING" }.count
        let infos = issues.filter { $0.severity == "INFO" }.count

        return ConfigValidationReport(
            isValid: errs == 0,
            errorCount: errs,
            warningCount: warns,
            infoCount: infos,
            issues: issues,
            suggestions: suggestions
        )
    }
}
