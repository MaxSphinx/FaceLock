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

    public static let presentationBundleIdentifiers: Set<String> = [
        "com.apple.iWork.Keynote",
        "com.microsoft.Powerpoint",
        "us.zoom.xos",
        "us.zoom.ZoomPresence",
        "us.zoom.ringcentral",
        "com.apple.FaceTime",
        "com.apple.QuickTimePlayerX",
        "com.microsoft.teams",
        "com.microsoft.teams2",
        "com.cisco.webexmeetingsapp",
        "com.cisco.webex.Cisco-WebEx-Start",
        "com.tinyspeck.slackmacgap",
        "com.discord.Discord",
        "com.hnc.Discord",
        "com.skype.skype",
        "ru.yandex.telemost",
        "com.obsproject.obs-studio",
        "com.loom.desktop",
        "com.apple.freeform",
        "com.viber.osx",
        "com.anydesk.anydesk",
        "com.anydesk.anydeskmac",
        "com.teamviewer.TeamViewer",
        "com.screenleap.Screenleap",
        "com.google.Chrome.app.kjgfgldnnfoeklkmfkjfagphfepbbdan",
        "com.brave.Browser.app.kjgfgldnnfoeklkmfkjfagphfepbbdan",
        "com.microsoft.edgemac.app.kjgfgldnnfoeklkmfkjfagphfepbbdan",
        "com.google.android.apps.meetings",
        "us.zoom.videomeetings",
        "com.apple.TV",
        "org.videolan.vlc",
        "com.colliderli.iina",
        "org.whispersystems.signal-desktop"
    ]

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

    private func checkPresentationState() -> Bool {
        return WalkAwayMonitor.isPresentationActive()
    }
}
