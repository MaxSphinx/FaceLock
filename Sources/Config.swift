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
        walkAwayIdleSeconds: Double = 45.0
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

    public func clearEnrolledVectors() {
        let url = Config.vectorsURL
        try? FileManager.default.removeItem(at: url)
    }
}
