import AppKit

public final class AppMonitor {
    public static let shared = AppMonitor()

    private var lastVerifiedPID: pid_t = 0
    private var lastVerifiedTime: Date = .distantPast
    private var observer: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?
    private var screenWakeObserver: NSObjectProtocol?

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

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemWake()
        }

        screenWakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemWake()
        }

        print("[AppMonitor] Started monitoring application switches and wake events.")
    }

    public func stop() {
        if let obs = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(obs)
            observer = nil
        }
        if let wObs = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wObs)
            wakeObserver = nil
        }
        if let swObs = screenWakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(swObs)
            screenWakeObserver = nil
        }
    }

    private func handleSystemWake() {
        guard Config.shared.isEnabled, Config.shared.lockOnWake else { return }
        guard !LockScreenController.shared.isLocked else { return }

        print("[AppMonitor] System/screen wake event detected with lockOnWake active. Verifying owner...")
        HUDController.shared.showScanning(appName: "Wake Verification")

        CameraScanner.shared.scanFace(timeout: Config.shared.verificationTimeout) { [weak self] (success, distance, intruderImage) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.lastVerifiedTime = Date()
                    HUDController.shared.showSuccess()
                    if let d = distance {
                        print("[AppMonitor] Face verified on wake (distance: \(String(format: "%.3f", d)))")
                    } else {
                        print("[AppMonitor] Face verified on wake")
                    }
                } else {
                    HUDController.shared.hide()
                    print("[AppMonitor] Wake verification failed! Locking screen...")
                    if let photo = intruderImage {
                        TelegramNotifier.shared.sendIntruderAlert(photo: photo, appName: "Wake From Sleep")
                    }
                    LockScreenController.shared.showLock(targetApp: nil, intruderImage: intruderImage) { [weak self] in
                        self?.lastVerifiedTime = Date()
                        print("[AppMonitor] Unlocked on wake via PIN / Touch ID")
                    }
                }
            }
        }
    }

    private func handleAppActivation(_ notification: Notification) {
        guard Config.shared.isEnabled else { return }
        guard !LockScreenController.shared.isLocked else { return }

        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
        guard let bundleId = app.bundleIdentifier else { return }

        if bundleId == Bundle.main.bundleIdentifier || bundleId == "io.github.facelock" {
            return
        }

        if Config.shared.ignoredBundleIdentifiers.contains(bundleId) {
            return
        }

        if Config.shared.protectionMode == "selective" {
            guard Config.shared.protectedBundleIdentifiers.contains(bundleId) else {
                return
            }
        }

        let pid = app.processIdentifier
        let now = Date()

        if pid == lastVerifiedPID && now.timeIntervalSince(lastVerifiedTime) < Config.shared.debounceSeconds {
            return
        }

        let appName = app.localizedName ?? bundleId
        HUDController.shared.showScanning(appName: appName)

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
