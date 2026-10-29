import AppKit
import LocalAuthentication
import QuartzCore

public final class LockScreenController: NSObject, NSTextFieldDelegate {
    public static let shared = LockScreenController()

    public private(set) var isLocked = false

    private var lockWindows: [NSWindow] = []
    private var cardView: NSView?
    private var headerContainer: NSView?
    private var pinField: NSSecureTextField?
    private var errorLabel: NSTextField?
    private var faceRetryBtn: NSButton?
    private var isFaceRetrying = false
    private var targetApp: NSRunningApplication?
    private var intruderImage: NSImage?
    private var onUnlockCallback: (() -> Void)?
    private var failedPinAttempts = 0
    private var lockoutTimer: Timer?
    private var lockoutSecondsRemaining = 0

    private override init() {
        super.init()
    }

    public func showLock(targetApp: NSRunningApplication? = nil, intruderImage: NSImage? = nil, onUnlock: (() -> Void)? = nil) {
        guard !isLocked else { return }
        isLocked = true
        failedPinAttempts = 0
        lockoutTimer?.invalidate()
        lockoutTimer = nil
        Config.saveLockState(isLocked: true)
        self.targetApp = targetApp
        self.intruderImage = intruderImage
        self.onUnlockCallback = onUnlock

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createLockWindows()

            // Bring our app to front
            NSApp.activate(ignoringOtherApps: true)

            for win in self.lockWindows {
                win.alphaValue = 0.0
                win.orderFrontRegardless()
            }

            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                for win in self.lockWindows {
                    win.animator().alphaValue = 1.0
                }
            } completionHandler: {
                if let mainWin = self.lockWindows.first {
                    mainWin.makeKey()
                    self.pinField?.becomeFirstResponder()
                }

                self.animateCardEntrance()

                // Auto-trigger Touch ID if enabled
                if Config.shared.autoTriggerTouchID {
                    self.triggerTouchID()
                }
            }
        }
    }

    @objc private func handleScreenParametersChanged() {
        guard isLocked else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isLocked else { return }
            print("[LockScreenController] Display configuration change detected while locked. Re-anchoring full-screen shield...")
            self.reconfigureLockWindows()
        }
    }

    private func reconfigureLockWindows() {
        guard isLocked else { return }
        let currentPin = pinField?.stringValue ?? ""
        for win in lockWindows {
            win.orderOut(nil)
        }
        lockWindows.removeAll()

        createLockWindows()

        for win in lockWindows {
            win.alphaValue = 1.0
            win.orderFrontRegardless()
        }

        if let mainWin = lockWindows.first {
            mainWin.makeKey()
            pinField?.stringValue = currentPin
            pinField?.becomeFirstResponder()
        }
    }

    private func createLockWindows() {
        lockWindows.removeAll()

        let screens = NSScreen.screens.isEmpty ? [NSScreen.main].compactMap { $0 } : NSScreen.screens

        for (index, screen) in screens.enumerated() {
            let win = FullscreenLockWindow(screen: screen)
            win.appearance = NSAppearance(named: .darkAqua)

            let backgroundEffect = NSVisualEffectView(frame: screen.frame)
            backgroundEffect.material = .fullScreenUI
            backgroundEffect.blendingMode = .behindWindow
            backgroundEffect.state = .active
            backgroundEffect.autoresizingMask = [.width, .height]

            // Dark tint overlay
            let darkOverlay = NSBox(frame: screen.frame)
            darkOverlay.boxType = .custom
            darkOverlay.fillColor = NSColor.black.withAlphaComponent(0.68)
            darkOverlay.borderWidth = 0
            darkOverlay.autoresizingMask = [.width, .height]
            backgroundEffect.addSubview(darkOverlay)

            if index == 0 {
                let card = makeCardView(screenSize: screen.frame.size)
                backgroundEffect.addSubview(card)
                self.cardView = card
            }

            win.contentView = backgroundEffect
            lockWindows.append(win)
        }
    }

    private func makeCardView(screenSize: CGSize) -> NSView {
        let hasIntruder = (self.intruderImage != nil)
        let cardW: CGFloat = hasIntruder ? 460 : 440
        let cardH: CGFloat = hasIntruder ? 620 : 520
        let cardX = (screenSize.width - cardW) / 2
        let cardY = (screenSize.height - cardH) / 2 - 40

        let container = NSView(frame: NSRect(x: cardX, y: cardY, width: cardW, height: cardH))
        container.wantsLayer = true
        container.layer?.cornerRadius = 28
        container.layer?.masksToBounds = false
        container.appearance = NSAppearance(named: .darkAqua)

        let effect = NSVisualEffectView(frame: container.bounds)
        effect.material = .hudWindow
        effect.blendingMode = .withinWindow
        effect.state = .active
        effect.wantsLayer = true
        effect.layer?.cornerRadius = 28
        effect.layer?.masksToBounds = true
        effect.layer?.borderWidth = 1.0
        effect.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        container.addSubview(effect)

        let headerH: CGFloat = hasIntruder ? 160 : 110
        let headerBox = NSView(frame: NSRect(x: 0, y: cardH - headerH - 12, width: cardW, height: headerH))
        headerBox.wantsLayer = true
        effect.addSubview(headerBox)
        self.headerContainer = headerBox

        if let photo = self.intruderImage {
            let avatarSize: CGFloat = 144
            let avatarX = (cardW - avatarSize) / 2
            let avatarY: CGFloat = 6

            let avatarContainer = NSView(frame: NSRect(x: avatarX, y: avatarY, width: avatarSize, height: avatarSize))
            avatarContainer.wantsLayer = true
            avatarContainer.layer?.cornerRadius = avatarSize / 2
            avatarContainer.layer?.masksToBounds = false
            avatarContainer.layer?.shadowColor = NSColor.systemRed.cgColor
            avatarContainer.layer?.shadowOpacity = 0.85
            avatarContainer.layer?.shadowRadius = 14
            avatarContainer.layer?.shadowOffset = .zero

            let avatarView = NSImageView(frame: avatarContainer.bounds)
            avatarView.wantsLayer = true
            avatarView.layer?.cornerRadius = avatarSize / 2
            avatarView.layer?.masksToBounds = true
            avatarView.layer?.borderWidth = 4.0
            avatarView.layer?.borderColor = NSColor.systemRed.cgColor
            avatarView.image = photo
            avatarView.imageScaling = .scaleProportionallyUpOrDown
            avatarContainer.addSubview(avatarView)

            let badgeSize: CGFloat = 34
            let badgeView = NSImageView(frame: NSRect(x: avatarSize - 32, y: 0, width: badgeSize, height: badgeSize))
            let badgeConfig = NSImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            badgeView.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Intruder")?.withSymbolConfiguration(badgeConfig)
            badgeView.contentTintColor = NSColor.systemYellow
            avatarContainer.addSubview(badgeView)

            headerBox.addSubview(avatarContainer)

            let glow = CABasicAnimation(keyPath: "shadowRadius")
            glow.fromValue = 8.0
            glow.toValue = 22.0
            glow.duration = 0.9
            glow.autoreverses = true
            glow.repeatCount = .infinity
            glow.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            avatarContainer.layer?.add(glow, forKey: "aura")
        } else {
            let iconView = NSImageView(frame: NSRect(x: (cardW - 68) / 2, y: 20, width: 68, height: 68))
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 56, weight: .semibold)
            iconView.image = NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: "Locked")?.withSymbolConfiguration(symbolConfig)
            iconView.contentTintColor = NSColor.systemRed
            headerBox.addSubview(iconView)
        }

        let titleY = cardH - (hasIntruder ? 212 : 150)
        let title = NSTextField(frame: NSRect(x: 20, y: titleY, width: cardW - 40, height: 32))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.textColor = .white
        let appTitle = targetApp?.localizedName ?? "Компьютер"
        let defaultTitle = (targetApp == nil) ? "Сеанс заблокирован" : "\(appTitle) заблокировано"
        title.stringValue = hasIntruder ? "Обнаружен посторонний!" : defaultTitle
        title.font = .systemFont(ofSize: 23, weight: .bold)
        title.alignment = .center
        effect.addSubview(title)

        let subY = cardH - (hasIntruder ? 266 : 200)
        let subtitle = NSTextField(frame: NSRect(x: 30, y: subY, width: cardW - 60, height: 42))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.textColor = NSColor(white: 0.85, alpha: 1.0)
        let defaultSubtitle = (targetApp == nil)
            ? "Автоматическая блокировка (Walk-Away). Приложите Touch ID или введите PIN-код:"
            : "Лицо не распознано. Приложите Touch ID или введите PIN-код:"
        subtitle.stringValue = hasIntruder
            ? "Зафиксировано чужое лицо перед экраном.\nРазблокируйте через Touch ID или введите PIN-код:"
            : defaultSubtitle
        subtitle.font = .systemFont(ofSize: 13, weight: .medium)
        subtitle.alignment = .center
        effect.addSubview(subtitle)

        let pinContainerW: CGFloat = 260
        let pinY = cardH - (hasIntruder ? 332 : 260)
        let pinField = NSSecureTextField(frame: NSRect(x: (cardW - pinContainerW) / 2, y: pinY, width: pinContainerW, height: 44))
        pinField.wantsLayer = true
        pinField.layer?.cornerRadius = 12
        pinField.layer?.masksToBounds = true
        pinField.layer?.borderWidth = 1.0
        pinField.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        pinField.font = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        pinField.alignment = .center
        pinField.placeholderString = "••••••"
        pinField.focusRingType = .none
        pinField.target = self
        pinField.action = #selector(onPinSubmitted)
        pinField.delegate = self
        effect.addSubview(pinField)
        self.pinField = pinField

        let errY = pinY - 26
        let errLabel = NSTextField(frame: NSRect(x: 20, y: errY, width: cardW - 40, height: 20))
        errLabel.isEditable = false
        errLabel.isBordered = false
        errLabel.backgroundColor = .clear
        errLabel.textColor = .systemRed
        errLabel.stringValue = "Неверный PIN-код"
        errLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        errLabel.alignment = .center
        errLabel.isHidden = true
        effect.addSubview(errLabel)
        self.errorLabel = errLabel

        let btnY = errY - 46
        let unlockBtn = NSButton(frame: NSRect(x: (cardW - pinContainerW) / 2, y: btnY, width: pinContainerW, height: 38))
        unlockBtn.title = "Разблокировать"
        unlockBtn.bezelStyle = .rounded
        unlockBtn.keyEquivalent = "\r"
        unlockBtn.target = self
        unlockBtn.action = #selector(onPinSubmitted)
        effect.addSubview(unlockBtn)

        let faceRetryY = btnY - 42
        let faceRetry = NSButton(frame: NSRect(x: (cardW - pinContainerW) / 2, y: faceRetryY, width: pinContainerW, height: 34))
        faceRetry.bezelStyle = .inline
        faceRetry.title = " Повторить Face ID"
        faceRetry.toolTip = "Повторить распознавание лица (Cmd+R или Cmd+F)"
        let faceConfig = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        faceRetry.image = NSImage(systemSymbolName: "faceid", accessibilityDescription: "Face ID")?.withSymbolConfiguration(faceConfig)
        faceRetry.imagePosition = .imageLeading
        faceRetry.contentTintColor = .labelColor
        faceRetry.target = self
        faceRetry.action = #selector(onFaceRetryClicked)
        effect.addSubview(faceRetry)
        self.faceRetryBtn = faceRetry

        let touchY = faceRetryY - 38
        let touchBtn = NSButton(frame: NSRect(x: (cardW - pinContainerW) / 2, y: touchY, width: pinContainerW, height: 34))
        touchBtn.bezelStyle = .inline
        touchBtn.title = " Использовать Touch ID"
        touchBtn.toolTip = "Аутентификация по Touch ID (Cmd+T)"
        let touchConfig = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        touchBtn.image = NSImage(systemSymbolName: "touchid", accessibilityDescription: "Touch ID")?.withSymbolConfiguration(touchConfig)
        touchBtn.imagePosition = .imageLeading
        touchBtn.contentTintColor = .labelColor
        touchBtn.target = self
        touchBtn.action = #selector(onTouchIDClicked)
        effect.addSubview(touchBtn)

        return container
    }

    // MARK: - Animations
    private func animateCardEntrance() {
        guard let card = cardView else { return }

        let spring = CASpringAnimation(keyPath: "transform.scale")
        spring.damping = 13
        spring.initialVelocity = 0.5
        spring.mass = 1.0
        spring.stiffness = 160
        spring.fromValue = 0.88
        spring.toValue = 1.0
        spring.duration = spring.settlingDuration
        card.layer?.add(spring, forKey: "pop")
    }

    private func shakeCard() {
        guard let card = cardView else { return }

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.45
        animation.values = [-16.0, 16.0, -12.0, 12.0, -8.0, 8.0, -4.0, 4.0, -1.0, 1.0, 0.0]
        card.layer?.add(animation, forKey: "shake")

        // Flash red border on PIN field
        pinField?.layer?.borderColor = NSColor.systemRed.cgColor
        pinField?.layer?.borderWidth = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.pinField?.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
            self?.pinField?.layer?.borderWidth = 1.0
        }
    }

    // MARK: - Actions
    public func controlTextDidChange(_ obj: Notification) {
        guard lockoutTimer == nil else { return }
        errorLabel?.isHidden = true
        pinField?.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        pinField?.layer?.borderWidth = 1.0

        guard let entered = pinField?.stringValue else { return }
        if entered == Config.shared.pin {
            failedPinAttempts = 0
            SecurityAuditLogger.shared.logPINUnlocked(targetApp: targetApp?.localizedName)
            unlock()
        }
    }

    @objc private func onPinSubmitted() {
        guard lockoutTimer == nil else { return }
        guard let entered = pinField?.stringValue, !entered.isEmpty else { return }

        if entered == Config.shared.pin {
            failedPinAttempts = 0
            SecurityAuditLogger.shared.logPINUnlocked(targetApp: targetApp?.localizedName)
            unlock()
        } else {
            failedPinAttempts += 1
            SecurityAuditLogger.shared.logPINFailed(targetApp: targetApp?.localizedName)
            NSSound.beep()
            shakeCard()
            pinField?.stringValue = ""

            let maxAttempts = max(1, Config.shared.maxFailedPinAttempts)
            if failedPinAttempts >= maxAttempts {
                handlePinBruteForceDetected()
            } else {
                errorLabel?.stringValue = "Неверный PIN-код (\(failedPinAttempts)/\(maxAttempts))"
                errorLabel?.isHidden = false
            }
        }
    }

    private func handlePinBruteForceDetected() {
        let attempts = failedPinAttempts
        SecurityAuditLogger.shared.log(
            eventType: "pin_bruteforce_attempt",
            appName: targetApp?.localizedName ?? "Lock Screen",
            details: "\(attempts) consecutive failed PIN attempts detected",
            isSuccess: false
        )

        // Capture intruder snapshot via camera immediately
        CameraScanner.shared.scanFace(timeout: 1.5) { [weak self] (_, _, intruderPhoto) in
            DispatchQueue.main.async {
                if let photo = intruderPhoto {
                    let photoURL = CameraScanner.shared.saveIntruderPhoto(photo)
                    let photoName = photoURL?.lastPathComponent
                    TelegramNotifier.shared.sendIntruderAlert(
                        photo: photo,
                        appName: "Lock Screen PIN Brute Force (\(attempts) attempts)"
                    )
                    SecurityAuditLogger.shared.log(
                        eventType: "pin_bruteforce_intruder",
                        appName: self?.targetApp?.localizedName ?? "Lock Screen",
                        intruderPhoto: photoName,
                        details: "Intruder snapshot captured after \(attempts) failed PIN attempts",
                        isSuccess: false
                    )
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss (dd.MM.yyyy)"
                    let timeStr = formatter.string(from: Date())
                    let targetName = self?.targetApp?.localizedName ?? "Lock Screen"
                    let safeTargetName = TelegramNotifier.escapeHTML(targetName)
                    let alertMsg = """
                    🚨 <b>FaceLock: Подозрительная активность!</b>
                    ⚠️ Зафиксировано <b>\(attempts)</b> неверных попыток ввода PIN подряд.
                    💻 <b>Приложение:</b> \(safeTargetName)
                    🕒 <b>Время:</b> \(timeStr)
                    🔒 Введена временная блокировка клавиатуры.
                    """
                    TelegramNotifier.shared.sendSecurityAlert(message: alertMsg)
                }
            }
        }

        // Apply temporary lockout
        let lockoutSecs = max(1, Int(Config.shared.pinLockoutSeconds))
        lockoutSecondsRemaining = lockoutSecs
        pinField?.isEnabled = false
        errorLabel?.stringValue = "Слишком много попыток. Заблокировано на \(lockoutSecondsRemaining) сек..."
        errorLabel?.isHidden = false

        lockoutTimer?.invalidate()
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self = self else {
                t.invalidate()
                return
            }
            self.lockoutSecondsRemaining -= 1
            if self.lockoutSecondsRemaining <= 0 {
                t.invalidate()
                self.lockoutTimer = nil
                self.pinField?.isEnabled = true
                self.pinField?.becomeFirstResponder()
                self.errorLabel?.stringValue = "Повторите ввод PIN"
            } else {
                self.errorLabel?.stringValue = "Слишком много попыток. Заблокировано на \(self.lockoutSecondsRemaining) сек..."
            }
        }
    }

    @objc private func onTouchIDClicked() {
        triggerTouchID()
    }

    @objc private func onFaceRetryClicked() {
        guard !isFaceRetrying else { return }
        guard Config.shared.hasEnrolledFace else {
            errorLabel?.stringValue = "Слепки лица не обучены"
            errorLabel?.isHidden = false
            return
        }

        isFaceRetrying = true
        faceRetryBtn?.isEnabled = false
        faceRetryBtn?.title = " Сканирование лица..."
        errorLabel?.isHidden = true

        CameraScanner.shared.scanFace(timeout: Config.shared.verificationTimeout) { [weak self] (success, _, _) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isFaceRetrying = false
                self.faceRetryBtn?.isEnabled = true
                self.faceRetryBtn?.title = " Повторить Face ID"

                if success {
                    self.failedPinAttempts = 0
                    self.lockoutTimer?.invalidate()
                    self.lockoutTimer = nil
                    SecurityAuditLogger.shared.logFaceRetrySuccess(targetApp: self.targetApp?.localizedName)
                    self.unlock()
                } else {
                    SecurityAuditLogger.shared.logFaceRetryFailed(targetApp: self.targetApp?.localizedName)
                    NSSound.beep()
                    self.shakeCard()
                    self.errorLabel?.stringValue = "Лицо не распознано"
                    self.errorLabel?.isHidden = false
                    self.pinField?.becomeFirstResponder()
                }
            }
        }
    }

    public func triggerTouchID() {
        let context = LAContext()
        context.localizedFallbackTitle = "Ввести PIN"
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "разблокировать экран") { [weak self] success, evalError in
                DispatchQueue.main.async {
                    if success {
                        self?.failedPinAttempts = 0
                        self?.lockoutTimer?.invalidate()
                        self?.lockoutTimer = nil
                        SecurityAuditLogger.shared.logTouchIDUnlocked(targetApp: self?.targetApp?.localizedName)
                        self?.unlock()
                    } else {
                        // User cancelled or failed Touch ID, focus PIN
                        self?.pinField?.becomeFirstResponder()
                    }
                }
            }
        }
    }

    public func clearPinField() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isLocked else { return }
            if self.lockoutTimer == nil {
                self.pinField?.stringValue = ""
                self.errorLabel?.isHidden = true
                self.pinField?.becomeFirstResponder()
            }
        }
    }

    public func retryFaceFromShortcut() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isLocked else { return }
            self.onFaceRetryClicked()
        }
    }

    // MARK: - Unlock with Animation
    public func unlock() {
        guard isLocked else { return }

        NSSound(named: "Glass")?.play()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Morph header icon into green success checkmark
            if let header = self.headerContainer {
                let successView = NSImageView(frame: NSRect(x: (header.bounds.width - 70) / 2, y: (header.bounds.height - 70) / 2, width: 70, height: 70))
                let checkConfig = NSImage.SymbolConfiguration(pointSize: 64, weight: .bold)
                successView.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Unlocked")?.withSymbolConfiguration(checkConfig)
                successView.contentTintColor = NSColor.systemGreen
                successView.alphaValue = 0.0
                header.subviews.forEach { $0.removeFromSuperview() }
                header.addSubview(successView)

                NSAnimationContext.runAnimationGroup { ctx in
                    ctx.duration = 0.15
                    successView.animator().alphaValue = 1.0
                }
            }

            // Shrink and fade out card
            if let card = self.cardView {
                let shrink = CABasicAnimation(keyPath: "transform.scale")
                shrink.toValue = 0.90
                shrink.duration = 0.25
                shrink.timingFunction = CAMediaTimingFunction(name: .easeIn)
                card.layer?.add(shrink, forKey: "shrink")
            }

            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.25
                for win in self.lockWindows {
                    win.animator().alphaValue = 0.0
                }
            }, completionHandler: {
                NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)
                Config.saveLockState(isLocked: false)

                for win in self.lockWindows {
                    win.orderOut(nil)
                }

                CameraScanner.shared.clearCandidateFaceprint()

                self.lockWindows.removeAll()
                self.isLocked = false
                self.isFaceRetrying = false
                self.failedPinAttempts = 0
                self.lockoutTimer?.invalidate()
                self.lockoutTimer = nil
                self.faceRetryBtn = nil
                self.errorLabel?.isHidden = true
                self.pinField?.stringValue = ""
                self.intruderImage = nil

                // Restore previous target app
                if let app = self.targetApp {
                    if #available(macOS 14.0, *) {
                        app.activate()
                    } else {
                        app.activate(options: .activateIgnoringOtherApps)
                    }
                }

                self.onUnlockCallback?()
                self.onUnlockCallback = nil
            })
        }
    }
}

private final class FullscreenLockWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func cancelOperation(_ sender: Any?) {}

    override func performClose(_ sender: Any?) {}

    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            let chars = (event.charactersIgnoringModifiers ?? "").lowercased()
            if chars == "q" || chars == "w" || chars == "m" || chars == "h" {
                return // Suppress bypass shortcuts
            }
            if chars == "t" {
                LockScreenController.shared.triggerTouchID()
                return
            }
            if chars == "r" || chars == "f" {
                LockScreenController.shared.retryFaceFromShortcut()
                return
            }
        } else if event.keyCode == 53 { // ESC key
            LockScreenController.shared.clearPinField()
            return
        }
        super.keyDown(with: event)
    }
}
