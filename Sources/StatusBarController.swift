import AppKit
import AVFoundation

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

        SecurityAuditLogger.shared.logShieldStateChanged(enabled: Config.shared.isEnabled, reason: "Toggled via menu bar icon")

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

        let profileItem = buildProfilesSubmenu()
        menu.addItem(profileItem)

        let shoulderState = Config.shared.shoulderSurfingDefense ? "Вкл" : "Выкл"
        let shoulderItem = NSMenuItem(title: "Защита от подглядывания (Shoulder-Surfing): \(shoulderState)", action: #selector(toggleShoulderSurfing), keyEquivalent: "")
        shoulderItem.target = self
        menu.addItem(shoulderItem)

        let audibleState = Config.shared.audibleAlerts ? "Вкл" : "Выкл"
        let audibleItem = NSMenuItem(title: "Звуковые сигналы (Audible Chimes): \(audibleState)", action: #selector(toggleAudibleAlerts), keyEquivalent: "")
        audibleItem.target = self
        menu.addItem(audibleItem)

        let batteryState = Config.shared.batteryAwareScanning ? "Вкл" : "Выкл"
        let batteryItem = NSMenuItem(title: "Энергосбережение (Battery Awareness): \(batteryState)", action: #selector(toggleBatteryAware), keyEquivalent: "")
        batteryItem.target = self
        menu.addItem(batteryItem)

        let appsItem = NSMenuItem(title: "Политика приложений (Секретные: \(Config.shared.protectedBundleIdentifiers.count))...", action: #selector(openAppsManager), keyEquivalent: "p")
        appsItem.target = self
        menu.addItem(appsItem)

        let wakeState = Config.shared.lockOnWake ? "Вкл" : "Выкл"
        let wakeItem = NSMenuItem(title: "Проверка при пробуждении: \(wakeState)", action: #selector(toggleLockOnWake), keyEquivalent: "w")
        wakeItem.target = self
        menu.addItem(wakeItem)

        let walkState = Config.shared.walkAwayLockEnabled ? "Вкл (\(Int(Config.shared.walkAwayIdleSeconds))с)" : "Выкл"
        let walkItem = NSMenuItem(title: "Авто-замок при уходе (Walk-Away): \(walkState)", action: #selector(toggleWalkAwayLock), keyEquivalent: "k")
        walkItem.target = self
        menu.addItem(walkItem)

        let cameraItem = buildCameraSubmenu()
        menu.addItem(cameraItem)

        menu.addItem(NSMenuItem.separator())

        let home = FileManager.default.homeDirectoryForCurrentUser
        let intrudersDir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        let incidentCount = ((try? FileManager.default.contentsOfDirectory(atPath: intrudersDir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }.count
        let (auditCount, _, _) = SecurityAuditLogger.shared.getLogStats()

        let galleryTitle = incidentCount > 0
            ? "Журнал инцидентов (Галерея: \(incidentCount) фото)..."
            : "Журнал инцидентов (Галерея фото)..."
        let galleryItem = NSMenuItem(title: galleryTitle, action: #selector(openGallery), keyEquivalent: "g")
        galleryItem.target = self
        menu.addItem(galleryItem)

        let auditTitle = auditCount > 0
            ? "Журнал аудита безопасности (Audit Log: \(auditCount))..."
            : "Журнал аудита безопасности (Audit Log)..."
        let auditItem = NSMenuItem(title: auditTitle, action: #selector(openAuditLog), keyEquivalent: "a")
        auditItem.target = self
        menu.addItem(auditItem)

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
        SecurityAuditLogger.shared.logConfigChanged(setting: "protectionMode", value: Config.shared.protectionMode, details: "Toggled via menu bar icon")
        let msg = (Config.shared.protectionMode == "selective") ? "Режим: Секретные приложения" : "Режим: Все приложения"
        HUDController.shared.showScanning(appName: msg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    @objc public func toggleLockOnWake() {
        Config.shared.lockOnWake.toggle()
        Config.shared.save()
        SecurityAuditLogger.shared.logConfigChanged(setting: "lockOnWake", value: "\(Config.shared.lockOnWake)", details: "Toggled via menu bar icon")
        let msg = Config.shared.lockOnWake ? "Проверка при пробуждении: Вкл" : "Проверка при пробуждении: Выкл"
        HUDController.shared.showScanning(appName: msg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    @objc public func toggleWalkAwayLock() {
        Config.shared.walkAwayLockEnabled.toggle()
        Config.shared.save()
        SecurityAuditLogger.shared.logConfigChanged(
            setting: "walkAwayLockEnabled",
            value: "\(Config.shared.walkAwayLockEnabled)",
            details: "Toggled via menu bar icon"
        )
        let stateStr = Config.shared.walkAwayLockEnabled ? "Вкл (\(Int(Config.shared.walkAwayIdleSeconds))с)" : "Выкл"
        let msg = "Авто-замок Walk-Away: \(stateStr)"
        HUDController.shared.showScanning(appName: msg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    private func buildProfilesSubmenu() -> NSMenuItem {
        let currentProfile = Config.shared.activeProfile
        let profileName = Config.SecurityProfile(rawValue: currentProfile)?.title ?? currentProfile.capitalized
        let item = NSMenuItem(title: "Профиль: \(profileName)", action: nil, keyEquivalent: "")
        let sub = NSMenu()

        for prof in Config.SecurityProfile.allCases {
            let pItem = NSMenuItem(title: prof.title, action: #selector(profileSelected(_:)), keyEquivalent: "")
            pItem.target = self
            pItem.representedObject = prof.rawValue
            pItem.state = (currentProfile == prof.rawValue) ? .on : .off
            sub.addItem(pItem)
        }

        item.submenu = sub
        return item
    }

    @objc private func profileSelected(_ sender: NSMenuItem) {
        if let raw = sender.representedObject as? String,
           let profile = Config.SecurityProfile(rawValue: raw) {
            Config.shared.applyProfile(profile)
            updateIcon()
        }
    }

    @objc private func toggleShoulderSurfing() {
        Config.shared.shoulderSurfingDefense.toggle()
        Config.shared.save()
        let state = Config.shared.shoulderSurfingDefense ? "Вкл" : "Выкл"
        SecurityAuditLogger.shared.logConfigChanged(setting: "shoulderSurfingDefense", value: "\(Config.shared.shoulderSurfingDefense)", details: "Toggled via menu bar icon")
        HUDController.shared.showProfile(name: "Shoulder-Surfing: \(state)")
    }

    @objc private func toggleAudibleAlerts() {
        Config.shared.audibleAlerts.toggle()
        Config.shared.save()
        let state = Config.shared.audibleAlerts ? "Вкл" : "Выкл"
        SecurityAuditLogger.shared.logConfigChanged(setting: "audibleAlerts", value: "\(Config.shared.audibleAlerts)", details: "Toggled via menu bar icon")
        HUDController.shared.showProfile(name: "Звук: \(state)")
        if Config.shared.audibleAlerts {
            HUDController.playAlertSound(type: "warning")
        }
    }

    @objc private func toggleBatteryAware() {
        Config.shared.batteryAwareScanning.toggle()
        Config.shared.save()
        let state = Config.shared.batteryAwareScanning ? "Вкл" : "Выкл"
        SecurityAuditLogger.shared.logConfigChanged(setting: "batteryAwareScanning", value: "\(Config.shared.batteryAwareScanning)", details: "Toggled via menu bar icon")
        HUDController.shared.showProfile(name: "Энергосбережение: \(state)")
    }

    private func buildCameraSubmenu() -> NSMenuItem {
        let preferredID = Config.shared.preferredCameraID
        let activeDevice = CameraScanner.selectDevice(preferredID: preferredID)
        let activeTitle = activeDevice?.localizedName ?? "По умолчанию"
        let parentItem = NSMenuItem(title: "Камера: \(activeTitle)", action: nil, keyEquivalent: "")

        let subMenu = NSMenu()

        // Auto / System default entry
        let defaultItem = NSMenuItem(title: "Авто (Системная по умолчанию)", action: #selector(onSelectCameraMenuItem(_:)), keyEquivalent: "")
        defaultItem.target = self
        defaultItem.representedObject = "default"
        if preferredID.isEmpty || preferredID.lowercased() == "default" {
            defaultItem.state = .on
        }
        subMenu.addItem(defaultItem)
        subMenu.addItem(NSMenuItem.separator())

        let devices = CameraScanner.availableCaptureDevices()
        for dev in devices {
            let item = NSMenuItem(title: dev.localizedName, action: #selector(onSelectCameraMenuItem(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = dev.uniqueID
            if dev.uniqueID == preferredID || (preferredID.isEmpty && dev.uniqueID == activeDevice?.uniqueID) {
                item.state = .on
            }
            subMenu.addItem(item)
        }

        parentItem.submenu = subMenu
        return parentItem
    }

    @objc private func onSelectCameraMenuItem(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        let targetID = (id == "default") ? "" : id
        Config.shared.preferredCameraID = targetID
        Config.shared.save()
        CameraScanner.shared.reconfigureDeviceIfNeeded()
        AppDelegate.notifyDaemonReload()

        let activeDevice = CameraScanner.selectDevice(preferredID: targetID)
        let camName = activeDevice?.localizedName ?? "По умолчанию"
        SecurityAuditLogger.shared.logConfigChanged(
            setting: "preferredCameraID",
            value: targetID.isEmpty ? "default" : targetID,
            details: "Camera switched via menu bar: \(camName)"
        )
        HUDController.shared.showScanning(appName: "Камера: \(camName)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
        NSSound(named: "Tink")?.play()
    }

    @objc private func openGallery() {
        IncidentGalleryController.shared.show()
    }

    @objc private func openAuditLog() {
        AuditLogController.shared.show()
    }

    @objc private func openSettings() {
        SettingsController.shared.show()
    }

    @objc private func openAppsManager() {
        ApplicationsManagerController.shared.show()
    }

    @objc private func menuToggleClicked() {
        toggleEnabled()
    }

    public func pauseFor(minutes: Double) {
        Config.shared.isEnabled = false
        Config.shared.save()
        updateIcon()
        HUDController.shared.showToggleStatus(isEnabled: false)
        SecurityAuditLogger.shared.logShieldStateChanged(enabled: false, reason: "Paused protection for \(Int(minutes)) minutes")

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
        SecurityAuditLogger.shared.logShieldStateChanged(enabled: true, reason: "Resumed protection")
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
        SecurityAuditLogger.shared.logVectorsModified(action: "Purged facial vectors", count: 0, details: "Reset via status bar menu")
        updateIcon()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
