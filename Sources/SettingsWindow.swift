import AppKit

public final class SettingsController: NSObject {
    public static let shared = SettingsController()

    private var window: FaceLockUtilityWindow?

    private var masterSwitch: NSButton?
    private var masterStatusLabel: NSTextField?
    private var cameraPopup: NSPopUpButton?

    private var tokenField: NSTextField?
    private var chatIdField: NSTextField?
    private var telegramSwitch: NSButton?
    private var telegramTestStatusLabel: NSTextField?

    private var modeRadioAll: NSButton?
    private var modeRadioSelective: NSButton?

    private var walkAwaySwitch: NSButton?
    private var idleSlider: NSSlider?
    private var idleLabel: NSTextField?
    private var lockOnWakeSwitch: NSButton?

    private var livenessSwitch: NSButton?
    private var pinField: NSSecureTextField?
    private var attemptsSlider: NSSlider?
    private var attemptsLabel: NSTextField?
    private var lockoutSlider: NSSlider?
    private var lockoutLabel: NSTextField?

    private var auditStatsLabel: NSTextField?

    private override init() {
        super.init()
    }

    public func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createWindowIfNeeded()
            self.loadCurrentConfig()
            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 520
        let height: CGFloat = 924

        let win = FaceLockUtilityWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Настройки FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true

        var currentY: CGFloat = height - 42

        // Section 1: Master Shield Status & Camera
        let masterHeader = makeSectionHeader(title: "1. Статус защиты и камера FaceLock", originY: currentY, width: width)
        root.addSubview(masterHeader)
        currentY -= 32

        let mSwitch = NSButton(checkboxWithTitle: "Защита активна (Face ID при открытии приложений)", target: self, action: #selector(onMasterSwitchChanged))
        mSwitch.frame = NSRect(x: 25, y: currentY, width: 360, height: 22)
        mSwitch.font = .systemFont(ofSize: 13, weight: .semibold)
        root.addSubview(mSwitch)
        self.masterSwitch = mSwitch

        let statusLbl = NSTextField(frame: NSRect(x: 390, y: currentY, width: 110, height: 20))
        statusLbl.isEditable = false
        statusLbl.isBordered = false
        statusLbl.backgroundColor = .clear
        statusLbl.font = .systemFont(ofSize: 12, weight: .bold)
        root.addSubview(statusLbl)
        self.masterStatusLabel = statusLbl
        currentY -= 34

        let camLabel = NSTextField(labelWithString: "Камера:")
        camLabel.frame = NSRect(x: 25, y: currentY, width: 65, height: 20)
        camLabel.textColor = .secondaryLabelColor
        root.addSubview(camLabel)

        let camPopup = NSPopUpButton(frame: NSRect(x: 95, y: currentY - 2, width: 390, height: 26))
        camPopup.target = self
        camPopup.action = #selector(onCameraPopupChanged)
        root.addSubview(camPopup)
        self.cameraPopup = camPopup
        currentY -= 36

        // Section 2: Telegram Alerts
        let tgHeader = makeSectionHeader(title: "2. Telegram-оповещения с фото", originY: currentY, width: width)
        root.addSubview(tgHeader)
        currentY -= 35

        let tgToggle = NSButton(checkboxWithTitle: "Включить отправку фото нарушителя в Telegram", target: self, action: #selector(onConfigChanged))
        tgToggle.frame = NSRect(x: 25, y: currentY, width: 450, height: 22)
        root.addSubview(tgToggle)
        self.telegramSwitch = tgToggle
        currentY -= 32

        let tokenLabel = NSTextField(labelWithString: "Bot Token:")
        tokenLabel.frame = NSRect(x: 25, y: currentY, width: 90, height: 20)
        tokenLabel.textColor = .secondaryLabelColor
        root.addSubview(tokenLabel)

        let tokenInp = NSTextField(frame: NSRect(x: 120, y: currentY - 2, width: 360, height: 24))
        tokenInp.placeholderString = "Например: 123456789:ABCdefGhIJKlmNo..."
        tokenInp.target = self
        tokenInp.action = #selector(onConfigChanged)
        root.addSubview(tokenInp)
        self.tokenField = tokenInp
        currentY -= 32

        let chatLabel = NSTextField(labelWithString: "Chat ID:")
        chatLabel.frame = NSRect(x: 25, y: currentY, width: 90, height: 20)
        chatLabel.textColor = .secondaryLabelColor
        root.addSubview(chatLabel)

        let chatInp = NSTextField(frame: NSRect(x: 120, y: currentY - 2, width: 230, height: 24))
        chatInp.placeholderString = "Ваш ID (например: 987654321)"
        chatInp.target = self
        chatInp.action = #selector(onConfigChanged)
        root.addSubview(chatInp)
        self.chatIdField = chatInp

        let testBtn = NSButton(frame: NSRect(x: 360, y: currentY - 4, width: 120, height: 28))
        testBtn.title = "Тест бота"
        testBtn.bezelStyle = .rounded
        testBtn.target = self
        testBtn.action = #selector(testTelegramClicked)
        root.addSubview(testBtn)
        currentY -= 26

        let tgStatus = NSTextField(frame: NSRect(x: 120, y: currentY, width: 360, height: 18))
        tgStatus.isEditable = false
        tgStatus.isBordered = false
        tgStatus.backgroundColor = .clear
        tgStatus.font = .systemFont(ofSize: 11, weight: .regular)
        tgStatus.textColor = .systemGreen
        root.addSubview(tgStatus)
        self.telegramTestStatusLabel = tgStatus
        currentY -= 36

        // Section 3: App Protection Mode
        let modeHeader = makeSectionHeader(title: "3. Режим проверки приложений", originY: currentY, width: width)
        root.addSubview(modeHeader)
        currentY -= 32

        let radioAll = NSButton(radioButtonWithTitle: "Все приложения (проверять при каждом переключении)", target: self, action: #selector(onModeChanged))
        radioAll.frame = NSRect(x: 25, y: currentY, width: 450, height: 20)
        root.addSubview(radioAll)
        self.modeRadioAll = radioAll
        currentY -= 26

        let radioSelective = NSButton(radioButtonWithTitle: "Только секретные (Telegram, Safari, Заметки, Фото, Терминал...)", target: self, action: #selector(onModeChanged))
        radioSelective.frame = NSRect(x: 25, y: currentY, width: 470, height: 20)
        root.addSubview(radioSelective)
        self.modeRadioSelective = radioSelective
        currentY -= 28

        let manageAppsBtn = NSButton(frame: NSRect(x: 45, y: currentY, width: 260, height: 26))
        manageAppsBtn.title = "Настроить список приложений..."
        manageAppsBtn.bezelStyle = .rounded
        manageAppsBtn.target = self
        manageAppsBtn.action = #selector(openAppsManagerClicked)
        root.addSubview(manageAppsBtn)
        currentY -= 36

        // Section 4: Walk-Away & Wake
        let walkHeader = makeSectionHeader(title: "4. Авто-замок при уходе и пробуждении", originY: currentY, width: width)
        root.addSubview(walkHeader)
        currentY -= 32

        let walkToggle = NSButton(checkboxWithTitle: "Блокировать экран, если никого нет перед Mac (Walk-away)", target: self, action: #selector(onConfigChanged))
        walkToggle.frame = NSRect(x: 25, y: currentY, width: 450, height: 20)
        root.addSubview(walkToggle)
        self.walkAwaySwitch = walkToggle
        currentY -= 30

        let idleText = NSTextField(labelWithString: "Таймаут бездействия:")
        idleText.frame = NSRect(x: 25, y: currentY, width: 150, height: 20)
        idleText.textColor = .secondaryLabelColor
        root.addSubview(idleText)

        let slider = NSSlider(value: 45, minValue: 15, maxValue: 180, target: self, action: #selector(onSliderChanged))
        slider.frame = NSRect(x: 180, y: currentY - 2, width: 220, height: 24)
        root.addSubview(slider)
        self.idleSlider = slider

        let sliderVal = NSTextField(labelWithString: "45 сек")
        sliderVal.frame = NSRect(x: 410, y: currentY, width: 80, height: 20)
        sliderVal.font = .systemFont(ofSize: 12, weight: .bold)
        root.addSubview(sliderVal)
        self.idleLabel = sliderVal
        currentY -= 32

        let wakeToggle = NSButton(checkboxWithTitle: "Проверять лицо при пробуждении Mac / экрана (Lock on Wake)", target: self, action: #selector(onConfigChanged))
        wakeToggle.frame = NSRect(x: 25, y: currentY, width: 470, height: 20)
        root.addSubview(wakeToggle)
        self.lockOnWakeSwitch = wakeToggle
        currentY -= 38

        // Section 5: Security, PIN & Lockout
        let secHeader = makeSectionHeader(title: "5. Безопасность и защита от подбора", originY: currentY, width: width)
        root.addSubview(secHeader)
        currentY -= 32

        let liveToggle = NSButton(checkboxWithTitle: "Защита от спуфинга (Liveness: проверка 3D черт лица)", target: self, action: #selector(onConfigChanged))
        liveToggle.frame = NSRect(x: 25, y: currentY, width: 450, height: 20)
        root.addSubview(liveToggle)
        self.livenessSwitch = liveToggle
        currentY -= 30

        let pinLabel = NSTextField(labelWithString: "PIN-код разблокировки:")
        pinLabel.frame = NSRect(x: 25, y: currentY, width: 170, height: 20)
        pinLabel.textColor = .secondaryLabelColor
        root.addSubview(pinLabel)

        let pinInp = NSSecureTextField(frame: NSRect(x: 200, y: currentY - 2, width: 120, height: 24))
        pinInp.target = self
        pinInp.action = #selector(onConfigChanged)
        root.addSubview(pinInp)
        self.pinField = pinInp
        currentY -= 30

        let attemptsText = NSTextField(labelWithString: "Попыток PIN до кулдауна:")
        attemptsText.frame = NSRect(x: 25, y: currentY, width: 170, height: 20)
        attemptsText.textColor = .secondaryLabelColor
        root.addSubview(attemptsText)

        let aSlider = NSSlider(value: 3, minValue: 1, maxValue: 10, target: self, action: #selector(onAttemptsSliderChanged))
        aSlider.numberOfTickMarks = 10
        aSlider.allowsTickMarkValuesOnly = true
        aSlider.frame = NSRect(x: 200, y: currentY - 2, width: 200, height: 24)
        root.addSubview(aSlider)
        self.attemptsSlider = aSlider

        let aVal = NSTextField(labelWithString: "3")
        aVal.frame = NSRect(x: 410, y: currentY, width: 80, height: 20)
        aVal.font = .systemFont(ofSize: 12, weight: .bold)
        root.addSubview(aVal)
        self.attemptsLabel = aVal
        currentY -= 30

        let lockoutText = NSTextField(labelWithString: "Задержка кулдауна:")
        lockoutText.frame = NSRect(x: 25, y: currentY, width: 170, height: 20)
        lockoutText.textColor = .secondaryLabelColor
        root.addSubview(lockoutText)

        let lSlider = NSSlider(value: 5, minValue: 1, maxValue: 60, target: self, action: #selector(onLockoutSliderChanged))
        lSlider.frame = NSRect(x: 200, y: currentY - 2, width: 200, height: 24)
        root.addSubview(lSlider)
        self.lockoutSlider = lSlider

        let lVal = NSTextField(labelWithString: "5 сек")
        lVal.frame = NSRect(x: 410, y: currentY, width: 80, height: 20)
        lVal.font = .systemFont(ofSize: 12, weight: .bold)
        root.addSubview(lVal)
        self.lockoutLabel = lVal
        currentY -= 38

        // Section 6: Security Audit & Incidents
        let auditHeader = makeSectionHeader(title: "6. Журнал безопасности и аудит", originY: currentY, width: width)
        root.addSubview(auditHeader)
        currentY -= 28

        let auditStats = NSTextField(frame: NSRect(x: 25, y: currentY, width: 460, height: 18))
        auditStats.isEditable = false
        auditStats.isBordered = false
        auditStats.backgroundColor = .clear
        auditStats.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        auditStats.textColor = .secondaryLabelColor
        root.addSubview(auditStats)
        self.auditStatsLabel = auditStats
        currentY -= 34

        let openAuditBtn = NSButton(frame: NSRect(x: 25, y: currentY, width: 225, height: 30))
        openAuditBtn.title = "Журнал аудита..."
        openAuditBtn.bezelStyle = .rounded
        openAuditBtn.target = self
        openAuditBtn.action = #selector(openAuditLogClicked)
        root.addSubview(openAuditBtn)

        let openGalleryBtn = NSButton(frame: NSRect(x: 265, y: currentY, width: 225, height: 30))
        openGalleryBtn.title = "Галерея инцидентов..."
        openGalleryBtn.bezelStyle = .rounded
        openGalleryBtn.target = self
        openGalleryBtn.action = #selector(openGalleryClicked)
        root.addSubview(openGalleryBtn)

        // Save Button at bottom
        let saveBtn = NSButton(frame: NSRect(x: (width - 160) / 2, y: 16, width: 160, height: 36))
        saveBtn.title = "Сохранить"
        saveBtn.bezelStyle = .rounded
        saveBtn.target = self
        saveBtn.action = #selector(saveAndClose)
        root.addSubview(saveBtn)

        win.contentView = root
        self.window = win
    }

    private func makeSectionHeader(title: String, originY: CGFloat, width: CGFloat) -> NSView {
        let container = NSView(frame: NSRect(x: 20, y: originY, width: width - 40, height: 26))
        let label = NSTextField(frame: NSRect(x: 0, y: 2, width: width - 40, height: 22))
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = NSColor.systemCyan
        label.stringValue = title
        container.addSubview(label)
        return container
    }

    private func updateStatusLabel(isEnabled: Bool) {
        if isEnabled {
            masterStatusLabel?.stringValue = "● АКТИВНО"
            masterStatusLabel?.textColor = .systemGreen
        } else {
            masterStatusLabel?.stringValue = "○ НА ПАУЗЕ"
            masterStatusLabel?.textColor = .systemOrange
        }
    }

    private func loadCurrentConfig() {
        let config = Config.shared
        masterSwitch?.state = config.isEnabled ? .on : .off
        updateStatusLabel(isEnabled: config.isEnabled)

        cameraPopup?.removeAllItems()
        cameraPopup?.addItem(withTitle: "Автоматически (По умолчанию)")
        let devices = CameraScanner.availableCaptureDevices()
        var selectedIdx = 0
        let preferredID = config.preferredCameraID
        for (i, dev) in devices.enumerated() {
            cameraPopup?.addItem(withTitle: "\(dev.localizedName) [\(dev.uniqueID.prefix(8))]")
            if !preferredID.isEmpty && (dev.uniqueID == preferredID || dev.localizedName.localizedCaseInsensitiveContains(preferredID)) {
                selectedIdx = i + 1
            }
        }
        cameraPopup?.selectItem(at: selectedIdx)

        tokenField?.stringValue = config.telegramBotToken
        chatIdField?.stringValue = config.telegramChatId
        telegramSwitch?.state = config.telegramEnabled ? .on : .off
        telegramTestStatusLabel?.stringValue = ""

        if config.protectionMode == "selective" {
            modeRadioSelective?.state = .on
            modeRadioAll?.state = .off
        } else {
            modeRadioAll?.state = .on
            modeRadioSelective?.state = .off
        }

        walkAwaySwitch?.state = config.walkAwayLockEnabled ? .on : .off
        idleSlider?.doubleValue = config.walkAwayIdleSeconds
        idleLabel?.stringValue = "\(Int(config.walkAwayIdleSeconds)) сек"
        lockOnWakeSwitch?.state = config.lockOnWake ? .on : .off

        livenessSwitch?.state = config.livenessDetectionEnabled ? .on : .off
        pinField?.stringValue = config.pin

        let attempts = max(1, min(10, config.maxFailedPinAttempts))
        attemptsSlider?.doubleValue = Double(attempts)
        attemptsLabel?.stringValue = "\(attempts)"

        let lockout = max(1.0, min(60.0, config.pinLockoutSeconds))
        lockoutSlider?.doubleValue = lockout
        lockoutLabel?.stringValue = "\(Int(lockout)) сек"

        let auditStats = SecurityAuditLogger.shared.getLogStats()
        let sizeKB = Double(auditStats.fileSizeBytes) / 1024.0
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        let incidentCount = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }.count
        auditStatsLabel?.stringValue = "Аудит: \(auditStats.totalCount) событий (\(String(format: "%.2f", sizeKB)) KB)  •  Инциденты: \(incidentCount) фото"
    }

    @objc private func onMasterSwitchChanged() {
        let isEnabled = (masterSwitch?.state == .on)
        Config.shared.isEnabled = isEnabled
        Config.shared.save()
        SecurityAuditLogger.shared.logShieldStateChanged(enabled: isEnabled, reason: "Toggled via Settings window")
        StatusBarController.shared.updateIcon()
        HUDController.shared.showToggleStatus(isEnabled: isEnabled)
        updateStatusLabel(isEnabled: isEnabled)
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onCameraPopupChanged(_ sender: NSPopUpButton) {
        let idx = sender.indexOfSelectedItem
        let devices = CameraScanner.availableCaptureDevices()
        if idx == 0 || idx > devices.count {
            Config.shared.preferredCameraID = ""
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: "default",
                details: "Reset to default automatic camera selection in Settings"
            )
        } else {
            let dev = devices[idx - 1]
            Config.shared.preferredCameraID = dev.uniqueID
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: dev.uniqueID,
                details: "Selected camera '\(dev.localizedName)' in Settings"
            )
        }
        Config.shared.save()
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onSliderChanged() {
        let val = Int(idleSlider?.doubleValue ?? 45)
        idleLabel?.stringValue = "\(val) сек"
        Config.shared.walkAwayIdleSeconds = Double(val)
        Config.shared.save()
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onAttemptsSliderChanged() {
        let val = Int(attemptsSlider?.doubleValue ?? 3)
        attemptsLabel?.stringValue = "\(val)"
        Config.shared.maxFailedPinAttempts = val
        Config.shared.save()
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onLockoutSliderChanged() {
        let val = Int(lockoutSlider?.doubleValue ?? 5)
        lockoutLabel?.stringValue = "\(val) сек"
        Config.shared.pinLockoutSeconds = Double(val)
        Config.shared.save()
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onModeChanged() {
        if modeRadioSelective?.state == .on {
            Config.shared.protectionMode = "selective"
        } else {
            Config.shared.protectionMode = "all"
        }
        Config.shared.save()
        AppDelegate.notifyDaemonReload()
    }

    @objc private func onConfigChanged() {
        saveSettingsToConfig()
    }

    private func saveSettingsToConfig() {
        let config = Config.shared
        config.isEnabled = (masterSwitch?.state == .on)
        updateStatusLabel(isEnabled: config.isEnabled)
        StatusBarController.shared.updateIcon()

        config.telegramBotToken = tokenField?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        config.telegramChatId = chatIdField?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        config.telegramEnabled = (telegramSwitch?.state == .on)

        config.walkAwayLockEnabled = (walkAwaySwitch?.state == .on)
        config.lockOnWake = (lockOnWakeSwitch?.state == .on)
        config.livenessDetectionEnabled = (livenessSwitch?.state == .on)

        if let enteredPin = pinField?.stringValue, !enteredPin.isEmpty {
            config.pin = enteredPin
        }

        config.maxFailedPinAttempts = Int(attemptsSlider?.doubleValue ?? 3)
        config.pinLockoutSeconds = Double(lockoutSlider?.doubleValue ?? 5.0)

        config.save()
        AppDelegate.notifyDaemonReload()
        SecurityAuditLogger.shared.logConfigChanged(
            setting: "GUI Settings",
            value: "saved",
            details: "Security preferences updated via Settings window"
        )
    }

    @objc private func openAuditLogClicked() {
        AuditLogController.shared.show()
    }

    @objc private func openGalleryClicked() {
        IncidentGalleryController.shared.show()
    }

    @objc private func openAppsManagerClicked() {
        ApplicationsManagerController.shared.show()
    }

    @objc private func testTelegramClicked() {
        saveSettingsToConfig()
        let token = Config.shared.telegramBotToken
        let chatId = Config.shared.telegramChatId

        telegramTestStatusLabel?.textColor = .white
        telegramTestStatusLabel?.stringValue = "Отправка тестового запроса..."

        TelegramNotifier.shared.sendTestMessage(token: token, chatId: chatId) { [weak self] success, msg in
            self?.telegramTestStatusLabel?.textColor = success ? .systemGreen : .systemRed
            self?.telegramTestStatusLabel?.stringValue = msg
        }
    }

    @objc private func saveAndClose() {
        saveSettingsToConfig()
        window?.orderOut(nil)
    }
}
