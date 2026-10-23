import AppKit

public final class StatusBarController: NSObject, NSMenuDelegate {
    public static let shared = StatusBarController()

    private var statusItem: NSStatusItem?
    private var pauseTimer: Timer?

    private override init() {
        super.init()
    }

    public func setup() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = item.button {
                button.target = self
                button.action = #selector(self.statusBarButtonClicked(_:))
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            }

            self.statusItem = item
            self.updateIcon()
        }
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let menu = buildMenu()
        menu.delegate = self
        statusItem?.menu = menu
        sender.performClick(nil)
    }

    public func menuDidClose(_ menu: NSMenu) {
        // Reset statusItem.menu to nil so next left-click triggers action directly
        statusItem?.menu = nil
    }

    public func updateIcon() {
        guard let button = statusItem?.button else { return }
        let isEnabled = Config.shared.isEnabled
        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let symbolName = isEnabled ? "faceid" : "lock.slash"

        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: "FaceLock")?.withSymbolConfiguration(config) {
            button.image = img
            button.contentTintColor = isEnabled ? nil : NSColor.systemOrange
        }

        button.toolTip = isEnabled
            ? "FaceLock: Защита активна (кликните для меню)"
            : "FaceLock: На паузе (кликните для меню)"
    }

    public func toggleEnabled() {
        Config.shared.isEnabled.toggle()
        Config.shared.save()
        pauseTimer?.invalidate()
        pauseTimer = nil

        updateIcon()

        // Visual HUD feedback
        HUDController.shared.showToggleStatus(isEnabled: Config.shared.isEnabled)

        // Subtle audio feedback
        NSSound(named: "Tink")?.play()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let isEnabled = Config.shared.isEnabled
        let hasFace = Config.shared.hasEnrolledFace
        let statusTitle = isEnabled
            ? (hasFace ? "✓ FaceLock: Активно (Лицо обучено)" : "✓ FaceLock: Активно (Детекция лица)")
            : "○ FaceLock: На паузе"

        let statusHeader = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusHeader.isEnabled = false
        menu.addItem(statusHeader)

        let toggleTitle = isEnabled ? "Приостановить защиту" : "Включить защиту"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(menuToggleClicked), keyEquivalent: "s")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let pause15 = NSMenuItem(title: "Пауза на 15 минут", action: #selector(pauseFor15Min), keyEquivalent: "")
        pause15.target = self
        menu.addItem(pause15)

        let isSelective = (Config.shared.protectionMode == "selective")
        let modeTitle = isSelective ? "Режим: Только секретные приложения (Telegram, Safari...)" : "Режим: Все приложения подряд"
        let modeItem = NSMenuItem(title: modeTitle, action: #selector(toggleProtectionMode), keyEquivalent: "m")
        modeItem.target = self
        menu.addItem(modeItem)

        let wakeState = Config.shared.lockOnWake ? "Вкл" : "Выкл"
        let wakeItem = NSMenuItem(title: "Проверка при пробуждении: \(wakeState)", action: #selector(toggleLockOnWake), keyEquivalent: "w")
        wakeItem.target = self
        menu.addItem(wakeItem)

        menu.addItem(NSMenuItem.separator())

        let galleryItem = NSMenuItem(title: "Журнал инцидентов (Галерея фото)...", action: #selector(openGallery), keyEquivalent: "g")
        galleryItem.target = self
        menu.addItem(galleryItem)

        let enrollItem = NSMenuItem(title: "Запомнить моё лицо (Калибровка 3D Face ID)...", action: #selector(openEnrollment), keyEquivalent: "e")
        enrollItem.target = self
        menu.addItem(enrollItem)

        let testLockItem = NSMenuItem(title: "Проверить экран блокировки (Тест)...", action: #selector(testLock), keyEquivalent: "t")
        testLockItem.target = self
        menu.addItem(testLockItem)

        let immediateLockItem = NSMenuItem(title: "Заблокировать экран сейчас", action: #selector(immediateLock), keyEquivalent: "l")
        immediateLockItem.target = self
        menu.addItem(immediateLockItem)

        menu.addItem(NSMenuItem.separator())

        let tgState = Config.shared.telegramEnabled ? "Вкл" : "Выкл"
        let settingsItem = NSMenuItem(title: "Настройки (Telegram: \(tgState), Пароль, Walk-away)...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        if hasFace {
            let resetFacesItem = NSMenuItem(title: "Сбросить слепки лица", action: #selector(resetFaces), keyEquivalent: "")
            resetFacesItem.target = self
            menu.addItem(resetFacesItem)
        }

        menu.addItem(NSMenuItem.separator())

        // 7. Quit
        let quitItem = NSMenuItem(title: "Завершить FaceLock", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func toggleProtectionMode() {
        if Config.shared.protectionMode == "selective" {
            Config.shared.protectionMode = "all"
        } else {
            Config.shared.protectionMode = "selective"
        }
        Config.shared.save()
        let msg = (Config.shared.protectionMode == "selective") ? "Режим: Секретные приложения" : "Режим: Все приложения"
        HUDController.shared.showScanning(appName: msg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    @objc public func toggleLockOnWake() {
        Config.shared.lockOnWake.toggle()
        Config.shared.save()
        let msg = Config.shared.lockOnWake ? "Проверка при пробуждении: Вкл" : "Проверка при пробуждении: Выкл"
        HUDController.shared.showScanning(appName: msg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    @objc private func openGallery() {
        IncidentGalleryController.shared.show()
    }

    @objc private func openSettings() {
        SettingsController.shared.show()
    }

    @objc private func menuToggleClicked() {
        toggleEnabled()
    }

    public func pauseFor(minutes: Double) {
        Config.shared.isEnabled = false
        Config.shared.save()
        updateIcon()
        HUDController.shared.showToggleStatus(isEnabled: false)

        pauseTimer?.invalidate()
        pauseTimer = Timer.scheduledTimer(withTimeInterval: max(1.0, minutes * 60), repeats: false) { [weak self] _ in
            self?.resumeProtection()
        }
    }

    public func resumeProtection() {
        pauseTimer?.invalidate()
        pauseTimer = nil
        Config.shared.isEnabled = true
        Config.shared.save()
        updateIcon()
        HUDController.shared.showToggleStatus(isEnabled: true)
        NSSound(named: "Tink")?.play()
    }

    @objc private func pauseFor15Min() {
        pauseFor(minutes: 15)
    }

    @objc private func openEnrollment() {
        EnrollmentController.shared.show()
    }

    @objc private func testLock() {
        LockScreenController.shared.showLock()
    }

    @objc private func immediateLock() {
        LockScreenController.shared.showLock()
    }

    @objc private func openIntrudersFolder() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(dir)
    }

    @objc private func resetFaces() {
        Config.shared.clearEnrolledVectors()
        Config.shared.strictFaceMatch = false
        Config.shared.save()
        updateIcon()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
