import AppKit
import CoreGraphics
import Foundation

public final class WalkAwayMonitor {
    public static let shared = WalkAwayMonitor()

    private var timer: Timer?
    private var isChecking = false
    private var lastCheckTime: Date = .distantPast

    private init() {}

    public func start() {
        guard timer == nil else { return }

        // Check idle time every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkIdleState()
        }
        print("[WalkAwayMonitor] Started background walk-away monitoring.")
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkIdleState() {
        guard Config.shared.isEnabled, Config.shared.walkAwayLockEnabled else { return }
        guard !LockScreenController.shared.isLocked else { return }
        guard !isChecking else { return }

        // Check how many seconds user has been idle (no mouse/keyboard input)
        let idleSeconds = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)

        guard idleSeconds >= Config.shared.walkAwayIdleSeconds else { return }

        // Debounce checks by at least 20 seconds
        let now = Date()
        guard now.timeIntervalSince(lastCheckTime) >= 20.0 else { return }
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
                    }
                    LockScreenController.shared.showLock(targetApp: nil, intruderImage: intruderImage)
                }
            }
        }
    }
}
