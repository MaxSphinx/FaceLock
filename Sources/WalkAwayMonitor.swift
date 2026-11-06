import AppKit
import CoreGraphics
import Foundation
import IOKit.ps
import IOKit.pwr_mgt

public final class WalkAwayMonitor {
    public static let shared = WalkAwayMonitor()

    private var timer: Timer?
    private var isChecking = false
    private var lastCheckTime: Date = .distantPast

    private init() {}

    public static func isOnBatteryPower() -> Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else { return false }
        guard let powerSourceType = IOPSGetProvidingPowerSourceType(snapshot)?.takeRetainedValue() as? String else { return false }
        return powerSourceType == kIOPMBatteryPowerKey
    }

    public static func isLowPowerModeEnabled() -> Bool {
        if #available(macOS 12.0, *) {
            return ProcessInfo.processInfo.isLowPowerModeEnabled
        }
        return false
    }

    public static func isPowerConstrained() -> Bool {
        return isOnBatteryPower() || isLowPowerModeEnabled()
    }

    public func start() {
        guard timer == nil else { return }

        // Adaptive polling interval: 10s if power is constrained (battery power or Low Power Mode) and battery-aware scanning is active, otherwise 5s
        let interval: TimeInterval = (Config.shared.batteryAwareScanning && WalkAwayMonitor.isPowerConstrained()) ? 10.0 : 5.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkIdleState()
        }
        print("[WalkAwayMonitor] Started background walk-away monitoring (interval: \(Int(interval))s).")
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkIdleState() {
        guard Config.shared.isEnabled, Config.shared.walkAwayLockEnabled else { return }
        guard !LockScreenController.shared.isLocked else { return }
        guard !isChecking else { return }

        // Check if presentation mode is active and should suppress lock
        if WalkAwayMonitor.isPresentationActive() {
            return
        }

        // Check how many seconds user has been idle (no mouse/keyboard input)
        let idleSeconds = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)

        guard idleSeconds >= Config.shared.walkAwayIdleSeconds else { return }

        // Adaptive debounce: 45 seconds when power is constrained (battery power or Low Power Mode), 20 seconds on AC power
        let minDebounce: TimeInterval = (Config.shared.batteryAwareScanning && WalkAwayMonitor.isPowerConstrained()) ? 45.0 : 20.0
        let now = Date()
        guard now.timeIntervalSince(lastCheckTime) >= minDebounce else { return }
        lastCheckTime = now

        isChecking = true
        print("[WalkAwayMonitor] User idle for \(Int(idleSeconds))s. Checking if user is still in front of screen...")

        CameraScanner.shared.scanFace(timeout: 1.5) { [weak self] (success, _, intruderImage) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isChecking = false

                if success {
                    print("[WalkAwayMonitor] User is still in front of screen (reading/watching). Not locking.")
                } else {
                    print("[WalkAwayMonitor] Nobody in front of screen! Auto-locking Mac...")
                    let photoName = CameraScanner.shared.latestSavedIntruderURL?.lastPathComponent
                    SecurityAuditLogger.shared.logWalkAwayLock(intruderPhoto: photoName)
                    if let photo = intruderImage {
                        TelegramNotifier.shared.sendIntruderAlert(photo: photo, appName: "Walk-Away Auto-Lock")
                    } else {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss (dd.MM.yyyy)"
                        let timeStr = formatter.string(from: Date())
                        let alertMsg = """
                        🛡️ <b>FaceLock: Walk-Away авто-блокировка</b>
                        🕒 <b>Время:</b> \(timeStr)
                        ⏳ Компьютер оставлен без присмотра (> \(Int(Config.shared.walkAwayIdleSeconds))с).
                        🔒 Экран MacBook автоматически заблокирован.
                        """
                        TelegramNotifier.shared.sendSecurityAlert(message: alertMsg)
                    }
                    LockScreenController.shared.showLock(targetApp: nil, intruderImage: intruderImage)
                }
            }
        }
    }

    public struct PresentationAppInfo: Codable {
        public let bundleId: String
        public let name: String
        public let category: String

        public init(bundleId: String, name: String, category: String) {
            self.bundleId = bundleId
            self.name = name
            self.category = category
        }

        public func toDictionary() -> [String: String] {
            return [
                "bundleId": bundleId,
                "name": name,
                "category": category
            ]
        }
    }

    public static let presentationCatalog: [PresentationAppInfo] = [
        PresentationAppInfo(bundleId: "com.apple.iWork.Keynote", name: "Keynote", category: "Presentation"),
        PresentationAppInfo(bundleId: "com.microsoft.Powerpoint", name: "Microsoft PowerPoint", category: "Presentation"),
        PresentationAppInfo(bundleId: "com.apple.freeform", name: "Apple Freeform", category: "Presentation"),
        PresentationAppInfo(bundleId: "us.zoom.xos", name: "Zoom Meetings", category: "Meeting"),
        PresentationAppInfo(bundleId: "us.zoom.ZoomPresence", name: "Zoom Rooms", category: "Meeting"),
        PresentationAppInfo(bundleId: "us.zoom.ringcentral", name: "RingCentral Meetings", category: "Meeting"),
        PresentationAppInfo(bundleId: "us.zoom.videomeetings", name: "Zoom Video Meetings", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.microsoft.teams", name: "Microsoft Teams", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.microsoft.teams2", name: "Microsoft Teams (Work or School)", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.cisco.webexmeetingsapp", name: "Cisco Webex Meetings", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.cisco.webex.Cisco-WebEx-Start", name: "Cisco Webex", category: "Meeting"),
        PresentationAppInfo(bundleId: "ru.yandex.telemost", name: "Yandex Telemost", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.google.android.apps.meetings", name: "Google Meet", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.google.Chrome.app.kjgfgldnnfoeklkmfkjfagphfepbbdan", name: "Google Meet (Chrome PWA)", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.brave.Browser.app.kjgfgldnnfoeklkmfkjfagphfepbbdan", name: "Google Meet (Brave PWA)", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.microsoft.edgemac.app.kjgfgldnnfoeklkmfkjfagphfepbbdan", name: "Google Meet (Edge PWA)", category: "Meeting"),
        PresentationAppInfo(bundleId: "com.apple.FaceTime", name: "FaceTime", category: "Communication"),
        PresentationAppInfo(bundleId: "com.tinyspeck.slackmacgap", name: "Slack", category: "Communication"),
        PresentationAppInfo(bundleId: "com.discord.Discord", name: "Discord", category: "Communication"),
        PresentationAppInfo(bundleId: "com.hnc.Discord", name: "Discord PTB", category: "Communication"),
        PresentationAppInfo(bundleId: "com.skype.skype", name: "Skype", category: "Communication"),
        PresentationAppInfo(bundleId: "com.viber.osx", name: "Viber", category: "Communication"),
        PresentationAppInfo(bundleId: "org.whispersystems.signal-desktop", name: "Signal Desktop", category: "Communication"),
        PresentationAppInfo(bundleId: "com.obsproject.obs-studio", name: "OBS Studio", category: "Streaming"),
        PresentationAppInfo(bundleId: "com.loom.desktop", name: "Loom Screen Recorder", category: "Recording"),
        PresentationAppInfo(bundleId: "com.anydesk.anydesk", name: "AnyDesk", category: "Screen Sharing"),
        PresentationAppInfo(bundleId: "com.anydesk.anydeskmac", name: "AnyDesk macOS", category: "Screen Sharing"),
        PresentationAppInfo(bundleId: "com.teamviewer.TeamViewer", name: "TeamViewer", category: "Screen Sharing"),
        PresentationAppInfo(bundleId: "com.screenleap.Screenleap", name: "Screenleap", category: "Screen Sharing"),
        PresentationAppInfo(bundleId: "com.apple.QuickTimePlayerX", name: "QuickTime Player", category: "Media"),
        PresentationAppInfo(bundleId: "com.apple.TV", name: "Apple TV", category: "Media"),
        PresentationAppInfo(bundleId: "org.videolan.vlc", name: "VLC Media Player", category: "Media"),
        PresentationAppInfo(bundleId: "com.colliderli.iina", name: "IINA Media Player", category: "Media")
    ]

    public static let presentationBundleIdentifiers: Set<String> = Set(presentationCatalog.map { $0.bundleId })

    public static func hasDisplaySleepAssertion() -> Bool {
        var assertionsByProcess: Unmanaged<CFDictionary>?
        let status = IOPMCopyAssertionsByProcess(&assertionsByProcess)
        guard status == kIOReturnSuccess,
              let dict = assertionsByProcess?.takeRetainedValue() as? [AnyHashable: Any] else {
            return false
        }
        for (_, assertions) in dict {
            if let list = assertions as? [[String: Any]] {
                for a in list {
                    if let type = a["AssertType"] as? String {
                        if type == "NoDisplaySleepAssertion" || type == "PreventUserIdleDisplaySleep" {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    public static func isPresentationActive(bundleId: String? = nil) -> Bool {
        guard Config.shared.presentationModeSuppression else { return false }
        let bundle = bundleId ?? NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        if let appId = bundle, presentationBundleIdentifiers.contains(where: { $0.caseInsensitiveCompare(appId) == .orderedSame }) {
            return true
        }
        if bundleId == nil && hasDisplaySleepAssertion() {
            return true
        }
        return false
    }

    public static func checkPresentationStatus(bundleId: String? = nil) -> [String: Any] {
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        let frontmostBundle = frontmostApp?.bundleIdentifier ?? "N/A"
        let frontmostName = frontmostApp?.localizedName ?? "N/A"

        let targetBundle = bundleId ?? frontmostApp?.bundleIdentifier
        let appInfo = targetBundle != nil ? presentationCatalog.first(where: { $0.bundleId.caseInsensitiveCompare(targetBundle!) == .orderedSame }) : nil
        let isPresApp = appInfo != nil || (targetBundle != nil && presentationBundleIdentifiers.contains(where: { $0.caseInsensitiveCompare(targetBundle!) == .orderedSame }))

        let hasAssertion = hasDisplaySleepAssertion()
        let suppressionConfigured = Config.shared.presentationModeSuppression
        let isSuppressed = isPresentationActive(bundleId: targetBundle)

        return [
            "queryBundleId": targetBundle ?? "",
            "isPresentationApp": isPresApp,
            "matchedName": appInfo?.name ?? (isPresApp ? (targetBundle ?? "Unknown") : "N/A"),
            "matchedCategory": appInfo?.category ?? (isPresApp ? "Presentation" : "N/A"),
            "frontmostBundleId": frontmostBundle,
            "frontmostName": frontmostName,
            "hasDisplaySleepAssertion": hasAssertion,
            "presentationModeSuppressionConfigured": suppressionConfigured,
            "isLockSuppressed": isSuppressed
        ]
    }

    private func checkPresentationState() -> Bool {
        return WalkAwayMonitor.isPresentationActive()
    }
}
