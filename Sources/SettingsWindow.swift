import AppKit

public final class SettingsController: NSObject {
    public static let shared = SettingsController()

    private var window: NSWindow?

    // UI Controls
    private var tokenField: NSTextField?
    private var chatIdField: NSTextField?
    private var telegramSwitch: NSButton?
    private var telegramTestStatusLabel: NSTextField?

    private var modeRadioAll: NSButton?
    private var modeRadioSelective: NSButton?

    private var walkAwaySwitch: NSButton?
    private var idleSlider: NSSlider?
    private var idleLabel: NSTextField?

    private var livenessSwitch: NSButton?
    private var pinField: NSSecureTextField?

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
        let height: CGFloat = 620

        let win = NSWindow(
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

        var currentY: CGFloat = height - 45

        // Section 1: Telegram
        let tgHeader = makeSectionHeader(title: "1. Telegram-оповещения с фото", originY: currentY, width: width)
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

        // Section 2: Protection Mode
        let modeHeader = makeSectionHeader(title: "2. Режим проверки приложений", originY: currentY, width: width)
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
        currentY -= 38

        // Section 3: Walk-away lock
        let walkHeader = makeSectionHeader(title: "3. Авто-замок при уходе от Mac (Walk-away)", originY: currentY, width: width)
        root.addSubview(walkHeader)
        currentY -= 32

        let walkToggle = NSButton(checkboxWithTitle: "Блокировать экран, если никого нет перед Mac", target: self, action: #selector(onConfigChanged))
        walkToggle.frame = NSRect(x: 25, y: currentY, width: 450, height: 20)
        root.addSubview(walkToggle)
        self.walkAwaySwitch = walkToggle
        currentY -= 32

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
        currentY -= 38

        // Section 4: Security (Liveness & PIN)
        let secHeader = makeSectionHeader(title: "4. Безопасность и пароль", originY: currentY, width: width)
        root.addSubview(secHeader)
        currentY -= 32

        let liveToggle = NSButton(checkboxWithTitle: "Защита от спуфинга (Liveness: проверка 3D черт лица)", target: self, action: #selector(onConfigChanged))
        liveToggle.frame = NSRect(x: 25, y: currentY, width: 450, height: 20)
        root.addSubview(liveToggle)
        self.livenessSwitch = liveToggle
        currentY -= 32

        let pinLabel = NSTextField(labelWithString: "PIN-код разблокировки:")
        pinLabel.frame = NSRect(x: 25, y: currentY, width: 170, height: 20)
        pinLabel.textColor = .secondaryLabelColor
        root.addSubview(pinLabel)

        let pinInp = NSSecureTextField(frame: NSRect(x: 200, y: currentY - 2, width: 120, height: 24))
        pinInp.target = self
        pinInp.action = #selector(onConfigChanged)
        root.addSubview(pinInp)
        self.pinField = pinInp

        // Save & Close Button
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

    private func loadCurrentConfig() {
        let config = Config.shared
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

        livenessSwitch?.state = config.livenessDetectionEnabled ? .on : .off
        pinField?.stringValue = config.pin
    }

    @objc private func onSliderChanged() {
        let val = Int(idleSlider?.doubleValue ?? 45)
        idleLabel?.stringValue = "\(val) сек"
        Config.shared.walkAwayIdleSeconds = Double(val)
        Config.shared.save()
    }

    @objc private func onModeChanged() {
        if modeRadioSelective?.state == .on {
            Config.shared.protectionMode = "selective"
        } else {
            Config.shared.protectionMode = "all"
        }
        Config.shared.save()
    }

    @objc private func onConfigChanged() {
        saveSettingsToConfig()
    }

    private func saveSettingsToConfig() {
        let config = Config.shared
        config.telegramBotToken = tokenField?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        config.telegramChatId = chatIdField?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        config.telegramEnabled = (telegramSwitch?.state == .on)

        config.walkAwayLockEnabled = (walkAwaySwitch?.state == .on)
        config.livenessDetectionEnabled = (livenessSwitch?.state == .on)

        if let enteredPin = pinField?.stringValue, !enteredPin.isEmpty {
            config.pin = enteredPin
        }

        config.save()
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
