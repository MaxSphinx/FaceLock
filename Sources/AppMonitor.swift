import AppKit

public final class AppMonitor {
    public static let shared = AppMonitor()

    private var lastVerifiedPID: pid_t = 0
    private var lastVerifiedTime: Date = .distantPast
    private var observer: NSObjectProtocol?

    private init() {}

    public func start() {
        guard observer == nil else { return }

        CameraScanner.shared.prepare()

        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleAppActivation(notif)
        }
        print("[AppMonitor] Started monitoring application switches.")
    }

    public func stop() {
        if let obs = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(obs)
            observer = nil
        }
    }

    private func handleAppActivation(_ notification: Notification) {
        guard Config.shared.isEnabled else { return }
        guard !LockScreenController.shared.isLocked else { return }

        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        guard let bundleId = app.bundleIdentifier else { return }

        // Skip self
        if bundleId == Bundle.main.bundleIdentifier || bundleId == "io.github.facelock" {
            return
        }

        // Skip ignored system apps
        if Config.shared.ignoredBundleIdentifiers.contains(bundleId) {
            return
        }

        // Selective Protection Mode check
        if Config.shared.protectionMode == "selective" {
            guard Config.shared.protectedBundleIdentifiers.contains(bundleId) else {
                return
            }
        }

        let pid = app.processIdentifier
        let now = Date()

        // Debounce if user recently verified this exact application
        if pid == lastVerifiedPID && now.timeIntervalSince(lastVerifiedTime) < Config.shared.debounceSeconds {
            return
        }

        // Show quick HUD pill
        let appName = app.localizedName ?? bundleId
        HUDController.shared.showScanning(appName: appName)

        // Turn on camera and scan face
        CameraScanner.shared.scanFace(timeout: Config.shared.verificationTimeout) { [weak self] (success, distance, intruderImage) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if success {
                    self.lastVerifiedPID = pid
                    self.lastVerifiedTime = Date()
                    HUDController.shared.showSuccess()
                    if let d = distance {
                        print("[AppMonitor] Face verified for \(appName) (similarity distance: \(String(format: "%.3f", d)))")
                    } else {
                        print("[AppMonitor] Face detected for \(appName)")
                    }
                } else {
                    HUDController.shared.hide()
                    print("[AppMonitor] Face NOT verified for \(appName)! Locking with intruder photo: \(intruderImage != nil)...")

                    // Send Telegram alert if enabled
                    if let photo = intruderImage {
                        TelegramNotifier.shared.sendIntruderAlert(photo: photo, appName: appName)
                    }

                    LockScreenController.shared.showLock(targetApp: app, intruderImage: intruderImage) { [weak self] in
                        self?.lastVerifiedPID = pid
                        self?.lastVerifiedTime = Date()
                        print("[AppMonitor] Unlocked with PIN/Touch ID for \(appName)")
                    }
                }
            }
        }
    }
}
