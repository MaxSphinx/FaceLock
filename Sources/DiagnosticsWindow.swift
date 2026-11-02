import AppKit
import UniformTypeIdentifiers

private final class DiagnosticsFlippedView: NSView {
    override var isFlipped: Bool { true }
}

public final class DiagnosticsController: NSObject {
    public static let shared = DiagnosticsController()

    private var window: FaceLockUtilityWindow?
    private var scrollView: NSScrollView?
    private var containerView: DiagnosticsFlippedView?
    private var healthBadgeLabel: NSTextField?
    private var lastUpdatedLabel: NSTextField?

    private override init() {
        super.init()
    }

    public func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createWindowIfNeeded()
            self.reloadDiagnostics()
            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 780
        let height: CGFloat = 680

        let win = FaceLockUtilityWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Диагностика и здоровье FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 680, height: 500)
        win.onRefresh = { [weak self] in
            self?.reloadDiagnostics()
        }

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true
        root.autoresizingMask = [.width, .height]

        // Header (Height: 96)
        let headerH: CGFloat = 96
        let header = NSView(frame: NSRect(x: 0, y: height - headerH, width: width, height: headerH))
        header.autoresizingMask = [.width, .minYMargin]
        header.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: 60, width: 380, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Диагностика системы"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        header.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: 38, width: 440, height: 18))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.stringValue = "Аппаратный статус, камера, Apple Neural Engine, биометрия и хранилище"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        header.addSubview(subtitle)

        let badge = NSTextField(frame: NSRect(x: 20, y: 14, width: 440, height: 18))
        badge.isEditable = false
        badge.isBordered = false
        badge.backgroundColor = .clear
        badge.stringValue = "ПРОВЕРКА СИСТЕМЫ... ⏳"
        badge.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        badge.textColor = .systemCyan
        header.addSubview(badge)
        self.healthBadgeLabel = badge

        // Action Buttons in Header
        let finderBtn = NSButton(frame: NSRect(x: width - 425, y: 52, width: 90, height: 30))
        finderBtn.title = "В Finder"
        finderBtn.bezelStyle = .rounded
        finderBtn.autoresizingMask = [.minXMargin]
        finderBtn.target = self
        finderBtn.action = #selector(openInFinder)
        header.addSubview(finderBtn)

        let exportBtn = NSButton(frame: NSRect(x: width - 330, y: 52, width: 105, height: 30))
        exportBtn.title = "Экспорт JSON..."
        exportBtn.bezelStyle = .rounded
        exportBtn.autoresizingMask = [.minXMargin]
        exportBtn.target = self
        exportBtn.action = #selector(exportReportClicked)
        header.addSubview(exportBtn)

        let testBtn = NSButton(frame: NSRect(x: width - 220, y: 52, width: 100, height: 30))
        testBtn.title = "Healthcheck"
        testBtn.bezelStyle = .rounded
        testBtn.autoresizingMask = [.minXMargin]
        testBtn.target = self
        testBtn.action = #selector(runHealthcheckClicked)
        header.addSubview(testBtn)

        let refreshBtn = NSButton(frame: NSRect(x: width - 115, y: 52, width: 95, height: 30))
        refreshBtn.title = "Обновить"
        refreshBtn.bezelStyle = .rounded
        refreshBtn.autoresizingMask = [.minXMargin]
        refreshBtn.target = self
        refreshBtn.action = #selector(refreshClicked)
        header.addSubview(refreshBtn)

        root.addSubview(header)

        // Footer (Height: 48)
        let footerH: CGFloat = 48
        let footer = NSView(frame: NSRect(x: 0, y: 0, width: width, height: footerH))
        footer.autoresizingMask = [.width, .maxYMargin]
        footer.wantsLayer = true

        let border = NSBox(frame: NSRect(x: 0, y: footerH - 1, width: width, height: 1))
        border.boxType = .custom
        border.fillColor = NSColor.white.withAlphaComponent(0.1)
        border.borderWidth = 0
        border.autoresizingMask = [.width]
        footer.addSubview(border)

        let lastUpdated = NSTextField(frame: NSRect(x: 20, y: 14, width: 500, height: 18))
        lastUpdated.isEditable = false
        lastUpdated.isBordered = false
        lastUpdated.backgroundColor = .clear
        lastUpdated.font = .systemFont(ofSize: 11, weight: .regular)
        lastUpdated.textColor = .tertiaryLabelColor
        footer.addSubview(lastUpdated)
        self.lastUpdatedLabel = lastUpdated

        let closeBtn = NSButton(frame: NSRect(x: width - 95, y: 10, width: 75, height: 28))
        closeBtn.title = "Готово"
        closeBtn.bezelStyle = .rounded
        closeBtn.autoresizingMask = [.minXMargin]
        closeBtn.target = self
        closeBtn.action = #selector(closeClicked)
        footer.addSubview(closeBtn)

        root.addSubview(footer)

        // Scroll View
        let scrollY = footerH
        let scrollH = height - headerH - footerH
        let scroll = NSScrollView(frame: NSRect(x: 0, y: scrollY, width: width, height: scrollH))
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false

        let container = DiagnosticsFlippedView(frame: NSRect(x: 0, y: 0, width: width, height: 900))
        container.wantsLayer = true
        scroll.documentView = container
        root.addSubview(scroll)

        self.scrollView = scroll
        self.containerView = container
        win.contentView = root
        self.window = win
    }

    public func reloadDiagnostics() {
        guard let container = containerView, let scroll = scrollView else { return }

        container.subviews.forEach { $0.removeFromSuperview() }

        let report = Diagnostics.collectReport()
        let width = scroll.bounds.width - 20
        var currentY: CGFloat = 16

        guard let platform = report["platform"] as? [String: Any],
              let daemon = report["daemon"] as? [String: Any],
              let camera = report["camera"] as? [String: Any],
              let biometrics = report["biometrics"] as? [String: Any],
              let storage = report["storage"] as? [String: Any],
              let integrations = report["integrations"] as? [String: Any] else {
            return
        }

        let isRunning = daemon["running"] as? Bool ?? false
        let isAppleSilicon = platform["appleSilicon"] as? Bool ?? false
        let camAuth = (camera["authorization"] as? String) == "authorized"
        let hasVision = biometrics["neuralFaceprintAvailable"] as? Bool ?? false
        let hasTouchID = biometrics["biometricsReady"] as? Bool ?? false

        let isHealthy = isRunning && camAuth && hasVision
        if isHealthy {
            healthBadgeLabel?.stringValue = "СИСТЕМА ПОЛНОСТЬЮ АКТИВНА И ИСПРАВНА (100% HEALTH) ✅"
            healthBadgeLabel?.textColor = .systemGreen
        } else {
            healthBadgeLabel?.stringValue = "ТРЕБУЕТ ВНИМАНИЯ (ПРОВЕРЬТЕ КАМЕРУ / ДЕМОН) ⚠️"
            healthBadgeLabel?.textColor = .systemOrange
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss (dd.MM.yyyy)"
        lastUpdatedLabel?.stringValue = "Данные обновлены: \(formatter.string(from: Date())) • Версия: 1.1.4"

        // Card 1: Platform & Process
        let osVer = platform["osVersion"] as? String ?? "macOS"
        let arch = platform["architecture"] as? String ?? "arm64"
        let pid = platform["pid"] as? Int32 ?? 0
        let pids = (daemon["pids"] as? [Int32] ?? []).map { "\($0)" }.joined(separator: ", ")
        let onBattery = platform["onBatteryPower"] as? Bool ?? false
        let lowPower = platform["lowPowerMode"] as? Bool ?? false
        let powerSourceStr = onBattery ? "Аккумулятор (Battery) 🔋" : "Сетевой адаптер (AC Power) 🔌"
        let lowPowerStr = lowPower ? "Включен (Режим энергосбережения) ⚡️" : "Выключен"

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Платформа и фоновый процесс",
            icon: "cpu",
            iconColor: .systemBlue,
            rows: [
                ("Операционная система", "\(osVer)"),
                ("Архитектура процессора", "\(arch) (\(isAppleSilicon ? "Apple Silicon Neural Engine Active ✅" : "Intel Legacy ⚠️"))"),
                ("Источник питания", "\(powerSourceStr)"),
                ("Режим энергосбережения (Low Power)", "\(lowPowerStr)"),
                ("Фоновый демон FaceLock", isRunning ? "АКТИВЕН (PID: \(pids.isEmpty ? "\(pid)" : pids)) ✅" : "ОСТАНОВЛЕН ℹ️"),
                ("PID текущего процесса", "\(pid)")
            ]
        ) + 16

        // Card 2: Camera Subsystem
        let camAuthStr = camera["authorization"] as? String ?? "unknown"
        let activeCam = camera["activeCamera"] as? String ?? "Default"
        let devicesCount = camera["devicesCount"] as? Int ?? 0
        let preferredID = camera["preferredCameraID"] as? String ?? "default"

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Камера и оптический сенсор",
            icon: "camera.fill",
            iconColor: .systemGreen,
            rows: [
                ("Разрешение в macOS", camAuthStr == "authorized" ? "Предоставлено (AUTHORIZED) ✅" : "\(camAuthStr.uppercased()) ❌"),
                ("Активная камера", "\(activeCam)"),
                ("Выбранный профиль камеры", preferredID.isEmpty ? "Автовыбор (По умолчанию)" : preferredID),
                ("Обнаружено камер в системе", "\(devicesCount) устройств(а)")
            ]
        ) + 16

        // Card 3: Neural Vision & Biometrics
        let simThresh = biometrics["similarityThreshold"] as? Double ?? 0.22
        let bioType = biometrics["biometryType"] as? String ?? "Touch ID"
        let autoTouch = biometrics["autoTriggerTouchID"] as? Bool ?? true

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Apple Neural Vision и биометрия",
            icon: "faceid",
            iconColor: .systemIndigo,
            rows: [
                ("Модель нейровекторов (VNCreateFaceprintRequest)", hasVision ? "Доступна (Apple Vision Engine) ✅" : "Недоступна ❌"),
                ("Порог биометрического допуска", "\(String(format: "%.2f", simThresh)) (Строгий нейро-контроль)"),
                ("Аппаратный датчик biometrics", "\(bioType) (\(hasTouchID ? "Готов к работе ✅" : "Недоступен ⚠️"))"),
                ("Авто-запуск Touch ID на локскрине", autoTouch ? "Включен ✅" : "Выключен")
            ]
        ) + 16

        // Card 4: Active Security Profile & Defense Modules
        let activeProfile = daemon["activeProfile"] as? String ?? "normal"
        let profTitle = Config.SecurityProfile(rawValue: activeProfile)?.title ?? activeProfile.capitalized
        let shoulder = daemon["shoulderSurfingDefense"] as? Bool ?? false
        let battery = daemon["batteryAwareScanning"] as? Bool ?? false
        let audible = daemon["audibleAlerts"] as? Bool ?? false
        let presentation = daemon["presentationModeSuppression"] as? Bool ?? false
        let walkAway = daemon["walkAwayLockEnabled"] as? Bool ?? false
        let walkAwaySec = daemon["walkAwayIdleSeconds"] as? Double ?? 45.0
        let lockOnWake = daemon["lockOnWake"] as? Bool ?? false

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Контекстный профиль и модули защиты",
            icon: "shield.lefthalf.filled",
            iconColor: .systemPurple,
            rows: [
                ("Активный профиль безопасности", "\(profTitle) 🛡️"),
                ("Защита от подглядывания (Shoulder-Surfing)", shoulder ? "Активна (Детекция посторонних за спиной) 👥" : "Выключена (Опционально)"),
                ("Энергосбережение (Battery-Aware IOKit)", battery ? "Включено (Адаптивный опрос при питании от батареи) 🔋" : "Выключено"),
                ("Звуковые сигналы (Audible Chimes)", audible ? "Включены (Звуковые уведомления) 🔔" : "Выключены (Бесшумный режим)"),
                ("Авто-подавление при созвонах/слайдах", presentation ? "Включено (Keynote, Zoom, Teams, Meet...) 🎯" : "Выключено"),
                ("Авто-замок при уходе (Walk-Away Lock)", walkAway ? "Активен (Срабатывание через \(Int(walkAwaySec))с простоя)" : "Выключен"),
                ("Проверка при пробуждении экрана", lockOnWake ? "Включена (Блокировка при открытии крышки) ✅" : "Выключена")
            ]
        ) + 16

        // Card 5: Facial Templates & Cluster Metrics
        let enrolledVectors = storage["enrolledVectors"] as? Int ?? 0
        let vectorMetrics = storage["vectorMetrics"] as? [String: Any] ?? [:]
        let avgDist = vectorMetrics["avgPairwiseDistance"] as? Double ?? 0.0
        let clusterQuality = vectorMetrics["quality"] as? String ?? (enrolledVectors > 0 ? "Качественный" : "Не откалиброван")

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Слепки лица и компактность кластера",
            icon: "person.crop.circle.badge.checkmark",
            iconColor: .systemTeal,
            rows: [
                ("Количество обученных 128-D векторов", enrolledVectors > 0 ? "\(enrolledVectors) векторов обучено ✅" : "Нет векторов (Требуется калибровка) ⚠️"),
                ("Средняя внутрикластерная дистанция", enrolledVectors > 1 ? "\(String(format: "%.4f", avgDist))" : "N/A"),
                ("Оценка качества кластера", "\(clusterQuality)")
            ]
        ) + 16

        // Card 6: Storage, Incidents & Audit
        let intruderCount = storage["intruderCaptures"] as? Int ?? 0
        let recent24h = storage["recent24hCaptures"] as? Int ?? 0
        let intruderBytes = storage["intruderSizeBytes"] as? UInt64 ?? 0
        let intruderMB = Double(intruderBytes) / (1024.0 * 1024.0)
        let auditCount = storage["auditLogEvents"] as? Int ?? 0
        let auditBytes = storage["auditLogSizeBytes"] as? Int64 ?? 0
        let auditMB = Double(auditBytes) / (1024.0 * 1024.0)
        let auditLast = storage["auditLogLastEvent"] as? String ?? "Нет событий"

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Хранилище, инциденты и аудит",
            icon: "externaldrive.fill",
            iconColor: .systemOrange,
            rows: [
                ("Фотоснимки нарушителей", "\(intruderCount) фото (\(recent24h) за 24ч) • \(String(format: "%.2f", intruderMB)) МБ"),
                ("Журнал безопасности (Audit Log)", "\(auditCount) событий • \(String(format: "%.2f", auditMB)) МБ"),
                ("Последнее событие аудита", "\(auditLast)"),
                ("Каталог данных", "~/.facelock/")
            ]
        ) + 16

        // Card 7: Cloud & Integrations
        let tgConfigured = integrations["telegramConfigured"] as? Bool ?? false
        let tgEnabled = integrations["telegramEnabled"] as? Bool ?? false
        let tgReachable = integrations["telegramReachable"] as? Bool ?? false
        let agentInstalled = integrations["maintainerInstalled"] as? Bool ?? false

        var tgStatus = "Не настроен ℹ️"
        if tgConfigured {
            let reachStr = tgReachable ? "Шлюз доступен ✅" : "Нет сети / DNS ❌"
            tgStatus = "\(tgEnabled ? "Активен" : "На паузе") (\(reachStr))"
        }

        currentY += addCard(
            to: container,
            originY: currentY,
            width: width,
            title: "Облако и фоновая автоматизация",
            icon: "paperplane.fill",
            iconColor: .systemPink,
            rows: [
                ("Telegram Bot оповещения", "\(tgStatus)"),
                ("24/7 Автономный фоновый агент (LaunchAgent)", agentInstalled ? "Установлен и активен ✅" : "Не установлен (make maintainer-install) ℹ️")
            ]
        ) + 24

        container.frame = NSRect(x: 0, y: 0, width: scroll.bounds.width, height: max(scroll.bounds.height, currentY))
    }

    private func addCard(
        to container: NSView,
        originY: CGFloat,
        width: CGFloat,
        title: String,
        icon: String,
        iconColor: NSColor,
        rows: [(String, String)]
    ) -> CGFloat {
        let cardPadding: CGFloat = 16
        let rowHeight: CGFloat = 24
        let headerHeight: CGFloat = 34
        let totalCardHeight = headerHeight + CGFloat(rows.count) * rowHeight + cardPadding * 2

        let card = NSView(frame: NSRect(x: 20, y: originY, width: width - 40, height: totalCardHeight))
        card.wantsLayer = true
        card.layer?.cornerRadius = 14
        card.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.04).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.borderColor = NSColor.white.withAlphaComponent(0.08).cgColor

        // Header icon & title
        let imgView = NSImageView(frame: NSRect(x: cardPadding, y: totalCardHeight - 34, width: 22, height: 22))
        let cfg = NSImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        imgView.image = NSImage(systemSymbolName: icon, accessibilityDescription: title)?.withSymbolConfiguration(cfg)
        imgView.contentTintColor = iconColor
        card.addSubview(imgView)

        let titleLabel = NSTextField(frame: NSRect(x: cardPadding + 30, y: totalCardHeight - 34, width: width - 120, height: 22))
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.stringValue = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = .white
        card.addSubview(titleLabel)

        // Rows
        var rowY = totalCardHeight - headerHeight - cardPadding - 4
        for (label, value) in rows {
            let lblField = NSTextField(frame: NSRect(x: cardPadding, y: rowY, width: 290, height: 20))
            lblField.isEditable = false
            lblField.isBordered = false
            lblField.backgroundColor = .clear
            lblField.stringValue = label + ":"
            lblField.font = .systemFont(ofSize: 12, weight: .regular)
            lblField.textColor = .secondaryLabelColor
            card.addSubview(lblField)

            let valField = NSTextField(frame: NSRect(x: cardPadding + 295, y: rowY, width: width - 360, height: 20))
            valField.isEditable = false
            valField.isBordered = false
            valField.backgroundColor = .clear
            valField.stringValue = value
            valField.font = .systemFont(ofSize: 12, weight: .medium)
            valField.textColor = .labelColor
            card.addSubview(valField)

            rowY -= rowHeight
        }

        container.addSubview(card)
        return totalCardHeight
    }

    // MARK: - Actions
    @objc private func refreshClicked() {
        reloadDiagnostics()
        NSSound(named: "Tink")?.play()
    }

    @objc private func closeClicked() {
        window?.orderOut(nil)
    }

    @objc private func openInFinder() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let facelockDir = home.appendingPathComponent(".facelock", isDirectory: true)
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: facelockDir.path)
    }

    @objc private func runHealthcheckClicked() {
        let report = Diagnostics.collectReport()
        guard let daemon = report["daemon"] as? [String: Any],
              let camera = report["camera"] as? [String: Any],
              let biometrics = report["biometrics"] as? [String: Any] else {
            return
        }

        let isRunning = daemon["running"] as? Bool ?? false
        let camAuth = (camera["authorization"] as? String) == "authorized"
        let hasVision = biometrics["neuralFaceprintAvailable"] as? Bool ?? false

        let alert = NSAlert()
        if isRunning && camAuth && hasVision {
            alert.messageText = "FaceLock Healthcheck: 100% Исправен ✅"
            alert.informativeText = "Все основные службы активны: фоновый демон работает, доступ к камере предоставлен, нейронная модель Vision загружена."
            alert.alertStyle = .informational
        } else {
            alert.messageText = "FaceLock Healthcheck: Обнаружены замечания ⚠️"
            alert.informativeText = "Демон: \(isRunning ? "Активен" : "Не запущен")\nКамера: \(camAuth ? "Разрешена" : "Требует доступа")\nVision Faceprint: \(hasVision ? "Доступна" : "Недоступна")"
            alert.alertStyle = .warning
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func exportReportClicked() {
        let report = Diagnostics.collectReport()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]) else {
            return
        }

        let savePanel = NSSavePanel()
        savePanel.title = "Экспорт отчёта диагностики FaceLock"
        savePanel.nameFieldStringValue = "facelock_diagnostics_\(Int(Date().timeIntervalSince1970)).json"
        savePanel.allowedContentTypes = [.json]

        savePanel.beginSheetModal(for: window ?? NSApp.keyWindow ?? NSWindow()) { response in
            if response == .OK, let url = savePanel.url {
                try? jsonData.write(to: url)
                NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: "")
            }
        }
    }
}
