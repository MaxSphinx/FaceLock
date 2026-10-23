import Foundation
import Vision

public final class Config: Codable {
    public static let shared = Config.load()

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

    public init(
        pin: String = "0000",
        similarityThreshold: Float = 0.22,
        verificationTimeout: Double = 2.0,
        debounceSeconds: Double = 2.0,
        isEnabled: Bool = true,
        strictFaceMatch: Bool = true,
        showHUD: Bool = true,
        autoTriggerTouchID: Bool = true,
        ignoredBundleIdentifiers: [String] = [
            "io.github.facelock",
            "com.apple.controlcenter",
            "com.apple.notificationcenterui",
            "com.apple.Spotlight",
            "com.apple.WindowManager",
            "com.apple.loginwindow",
            "com.apple.ScreenSaver.Engine",
            "com.apple.systemuiserver",
            "com.apple.dock"
        ],
        telegramBotToken: String = "",
        telegramChatId: String = "",
        telegramEnabled: Bool = false,
        protectionMode: String = "all",
        protectedBundleIdentifiers: [String] = [
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
        ],
        livenessDetectionEnabled: Bool = true,
        walkAwayLockEnabled: Bool = true,
        walkAwayIdleSeconds: Double = 45.0,
        lockOnWake: Bool = false
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
        self.ignoredBundleIdentifiers = try container.decodeIfPresent([String].self, forKey: .ignoredBundleIdentifiers) ?? [
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
        self.telegramBotToken = try container.decodeIfPresent(String.self, forKey: .telegramBotToken) ?? ""
        self.telegramChatId = try container.decodeIfPresent(String.self, forKey: .telegramChatId) ?? ""
        self.telegramEnabled = try container.decodeIfPresent(Bool.self, forKey: .telegramEnabled) ?? false
        self.protectionMode = try container.decodeIfPresent(String.self, forKey: .protectionMode) ?? "all"
        self.protectedBundleIdentifiers = try container.decodeIfPresent([String].self, forKey: .protectedBundleIdentifiers) ?? [
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
        self.livenessDetectionEnabled = try container.decodeIfPresent(Bool.self, forKey: .livenessDetectionEnabled) ?? true
        self.walkAwayLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .walkAwayLockEnabled) ?? true
        self.walkAwayIdleSeconds = try container.decodeIfPresent(Double.self, forKey: .walkAwayIdleSeconds) ?? 45.0
        self.lockOnWake = try container.decodeIfPresent(Bool.self, forKey: .lockOnWake) ?? false
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
            try? data.write(to: url)
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
        }
    }

    public func backupConfig(to destinationPath: String) throws -> String {
        let expanded = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expanded)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: destURL, options: .atomic)
        return destURL.path
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
        self.save()
    }

    public var hasEnrolledFace: Bool {
        return !loadEnrolledVectors().isEmpty
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
            try? data.write(to: url)
        }
    }

    public func addEnrolledVector(_ vector: [Float]) {
        var current = loadEnrolledVectors()
        current.append(vector)
        if current.count > 30 {
            current.removeFirst(current.count - 30)
        }
        saveEnrolledVectors(current)
        print("[Config] Added new face vector sample. Total enrolled: \(current.count)")
    }

    public func addProtectedApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if !protectedBundleIdentifiers.contains(trimmed) {
            protectedBundleIdentifiers.append(trimmed)
            save()
            return true
        }
        return false
    }

    public func removeProtectedApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        if let idx = protectedBundleIdentifiers.firstIndex(of: trimmed) {
            protectedBundleIdentifiers.remove(at: idx)
            save()
            return true
        }
        return false
    }

    public func addIgnoredApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if !ignoredBundleIdentifiers.contains(trimmed) {
            ignoredBundleIdentifiers.append(trimmed)
            save()
            return true
        }
        return false
    }

    public func removeIgnoredApp(_ bundleId: String) -> Bool {
        let trimmed = bundleId.trimmingCharacters(in: .whitespacesAndNewlines)
        if let idx = ignoredBundleIdentifiers.firstIndex(of: trimmed) {
            ignoredBundleIdentifiers.remove(at: idx)
            save()
            return true
        }
        return false
    }

    public func clearEnrolledVectors() {
        let url = Config.vectorsURL
        try? FileManager.default.removeItem(at: url)
    }

    public func exportVectors(to destinationPath: String) throws -> Int {
        let expandedPath = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expandedPath)
        let vectors = loadEnrolledVectors()
        guard !vectors.isEmpty else {
            throw NSError(domain: "io.github.facelock", code: 1, userInfo: [NSLocalizedDescriptionKey: "No enrolled face vectors found to export"])
        }
        let data = try JSONEncoder().encode(vectors)
        try data.write(to: destURL, options: .atomic)
        return vectors.count
    }

    public func importVectors(from sourcePath: String, merge: Bool = true) throws -> Int {
        let expandedPath = NSString(string: sourcePath).expandingTildeInPath
        let sourceURL = URL(fileURLWithPath: expandedPath)
        let data = try Data(contentsOf: sourceURL)
        let imported = try JSONDecoder().decode([[Float]].self, from: data)
        guard !imported.isEmpty else {
            throw NSError(domain: "io.github.facelock", code: 2, userInfo: [NSLocalizedDescriptionKey: "Imported vector file is empty"])
        }
        var combined: [[Float]]
        if merge {
            combined = loadEnrolledVectors()
            for vec in imported {
                if !vec.isEmpty && !combined.contains(where: { $0 == vec }) {
                    combined.append(vec)
                }
            }
        } else {
            combined = imported
        }
        if combined.count > 30 {
            combined = Array(combined.suffix(30))
        }
        saveEnrolledVectors(combined)
        return combined.count
    }
}
