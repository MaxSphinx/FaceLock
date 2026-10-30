import AppKit

public final class AuditLogController: NSObject {
    public static let shared = AuditLogController()

    private var window: FaceLockUtilityWindow?
    private var scrollView: NSScrollView?
    private var containerView: NSView?
    private var statsLabel: NSTextField?
    private var filterPopup: NSPopUpButton?
    private var currentFilter: String? = nil

    private override init() {
        super.init()
    }

    public func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createWindowIfNeeded()
            self.reloadLogs()
            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 780
        let height: CGFloat = 620

        let win = FaceLockUtilityWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Журнал аудита безопасности FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 660, height: 460)
        win.onRefresh = { [weak self] in
            self?.reloadLogs()
        }

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true
        root.autoresizingMask = [.width, .height]

        // Top Header
        let headerH: CGFloat = 95
        let header = NSView(frame: NSRect(x: 0, y: height - headerH, width: width, height: headerH))
        header.autoresizingMask = [.width, .minYMargin]
        header.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: 60, width: 380, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Журнал аудита безопасности"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        header.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: 38, width: 380, height: 18))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.stringValue = "Хронология биометрии, попыток доступа и срабатываний замка"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        header.addSubview(subtitle)

        let stats = NSTextField(frame: NSRect(x: 20, y: 14, width: 380, height: 18))
        stats.isEditable = false
        stats.isBordered = false
        stats.backgroundColor = .clear
        stats.stringValue = "Загрузка статистики..."
        stats.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        stats.textColor = .systemCyan
        header.addSubview(stats)
        self.statsLabel = stats

        // Action Buttons
        let finderBtn = NSButton(frame: NSRect(x: width - 495, y: 52, width: 85, height: 30))
        finderBtn.title = "В Finder"
        finderBtn.bezelStyle = .rounded
        finderBtn.autoresizingMask = [.minXMargin]
        finderBtn.target = self
        finderBtn.action = #selector(openInFinder)
        header.addSubview(finderBtn)

        let exportBtn = NSButton(frame: NSRect(x: width - 405, y: 52, width: 90, height: 30))
        exportBtn.title = "Экспорт..."
        exportBtn.bezelStyle = .rounded
        exportBtn.autoresizingMask = [.minXMargin]
        exportBtn.target = self
        exportBtn.action = #selector(exportLogsClicked)
        header.addSubview(exportBtn)

        let pruneBtn = NSButton(frame: NSRect(x: width - 310, y: 52, width: 105, height: 30))
        pruneBtn.title = "Проредить..."
        pruneBtn.bezelStyle = .rounded
        pruneBtn.autoresizingMask = [.minXMargin]
        pruneBtn.target = self
        pruneBtn.action = #selector(pruneLogsClicked)
        header.addSubview(pruneBtn)

        let clearBtn = NSButton(frame: NSRect(x: width - 200, y: 52, width: 90, height: 30))
        clearBtn.title = "Очистить"
        clearBtn.bezelStyle = .rounded
        clearBtn.autoresizingMask = [.minXMargin]
        clearBtn.target = self
        clearBtn.action = #selector(clearLogsClicked)
        header.addSubview(clearBtn)

        let refreshBtn = NSButton(frame: NSRect(x: width - 105, y: 52, width: 85, height: 30))
        refreshBtn.title = "Обновить"
        refreshBtn.bezelStyle = .rounded
        refreshBtn.autoresizingMask = [.minXMargin]
        refreshBtn.target = self
        refreshBtn.action = #selector(refreshClicked)
        header.addSubview(refreshBtn)

        // Filter popup
        let filterLabel = NSTextField(frame: NSRect(x: width - 390, y: 14, width: 65, height: 22))
        filterLabel.isEditable = false
        filterLabel.isBordered = false
        filterLabel.backgroundColor = .clear
        filterLabel.stringValue = "Фильтр:"
        filterLabel.textColor = .secondaryLabelColor
        filterLabel.font = .systemFont(ofSize: 12)
        filterLabel.autoresizingMask = [.minXMargin]
        header.addSubview(filterLabel)

        let popup = NSPopUpButton(frame: NSRect(x: width - 325, y: 12, width: 310, height: 26), pullsDown: false)
        popup.autoresizingMask = [.minXMargin]
        popup.addItem(withTitle: "Все события (All)")
        popup.addItem(withTitle: "Только биометрия (Face ID)")
        popup.addItem(withTitle: "Нарушители и блокировки (Intruders)")
        popup.addItem(withTitle: "Ввод PIN-кода (PIN)")
        popup.addItem(withTitle: "Apple Touch ID")
        popup.addItem(withTitle: "Статус защиты (Shield)")
        popup.addItem(withTitle: "Политика приложений (Policy)")
        popup.addItem(withTitle: "Настройки и конфигурация (Config)")
        popup.addItem(withTitle: "Векторы биометрии (Vectors)")
        popup.addItem(withTitle: "Brute-force и блокировки (Lockouts)")
        popup.addItem(withTitle: "Telegram оповещения (Telegram)")
        popup.target = self
        popup.action = #selector(filterChanged(_:))
        header.addSubview(popup)
        self.filterPopup = popup

        root.addSubview(header)

        // Scroll view for cards
        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: width, height: height - headerH))
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false

        let clip = scroll.contentView
        let content = NSView(frame: clip.bounds)
        content.wantsLayer = true
        scroll.documentView = content
        root.addSubview(scroll)

        self.scrollView = scroll
        self.containerView = content
        win.contentView = root
        self.window = win
    }

    public func reloadLogs() {
        guard let container = containerView, let scroll = scrollView else { return }
        container.subviews.forEach { $0.removeFromSuperview() }

        let stats = SecurityAuditLogger.shared.getLogStats()
        let sizeKB = Double(stats.fileSizeBytes) / 1024.0
        statsLabel?.stringValue = "Всего записей: \(stats.totalCount)  |  Объём: \(String(format: "%.2f", sizeKB)) KB"

        let events = SecurityAuditLogger.shared.fetchRecentEvents(tail: 100, filterType: currentFilter)

        if events.isEmpty {
            let emptyLabel = NSTextField(frame: NSRect(x: 20, y: (scroll.bounds.height - 40) / 2, width: scroll.bounds.width - 40, height: 40))
            emptyLabel.isEditable = false
            emptyLabel.isBordered = false
            emptyLabel.backgroundColor = .clear
            emptyLabel.textColor = .secondaryLabelColor
            emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
            emptyLabel.alignment = .center
            if let f = currentFilter, !f.isEmpty && f != "all" {
                emptyLabel.stringValue = "🔍 Нет событий по выбранному фильтру «\(f)»."
            } else {
                emptyLabel.stringValue = "🛡️ Журнал аудита чист. События безопасности пока не записаны."
            }
            container.addSubview(emptyLabel)
            container.frame = scroll.contentView.bounds
            return
        }

        let itemH: CGFloat = 86
        let itemW: CGFloat = scroll.bounds.width - 40
        let totalH = CGFloat(events.count) * (itemH + 10) + 20
        container.frame = NSRect(x: 0, y: 0, width: scroll.bounds.width, height: max(totalH, scroll.bounds.height))

        var currentY = totalH - itemH - 10

        for event in events {
            let card = makeEventCard(event: event, frame: NSRect(x: 20, y: currentY, width: itemW, height: itemH))
            container.addSubview(card)
            currentY -= (itemH + 10)
        }
    }

    private func makeEventCard(event: AuditEvent, frame: NSRect) -> NSView {
        let card = NSView(frame: frame)
        card.wantsLayer = true
        card.layer?.cornerRadius = 12
        card.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.85).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.borderColor = NSColor.white.withAlphaComponent(0.08).cgColor
        card.autoresizingMask = [.width]

        // Badge info
        let badgeTitle: String
        let badgeColor: NSColor
        let isCritical: Bool

        switch event.eventType {
        case "face_verified", "wake_verified":
            badgeTitle = "✅ Владелец подтверждён"
            badgeColor = .systemGreen
            isCritical = false
        case "intruder_detected", "wake_locked":
            badgeTitle = "🚨 Посторонний заблокирован"
            badgeColor = .systemRed
            isCritical = true
        case "walkaway_lock":
            badgeTitle = "🚶 Авто-замок при уходе"
            badgeColor = .systemOrange
            isCritical = true
        case "pin_unlocked":
            badgeTitle = "🔑 Вход по PIN-коду"
            badgeColor = .systemBlue
            isCritical = false
        case "pin_failed":
            badgeTitle = "❌ Неверный PIN-код"
            badgeColor = .systemRed
            isCritical = true
        case "pin_bruteforce_attempt", "pin_bruteforce_intruder":
            badgeTitle = "🚫 Brute-Force блокировка"
            badgeColor = .systemRed
            isCritical = true
        case "touchid_unlocked":
            badgeTitle = "👆 Вход по Touch ID"
            badgeColor = .systemPurple
            isCritical = false
        case "face_retry_success":
            badgeTitle = "🔄✅ Повторный Face ID успешен"
            badgeColor = .systemTeal
            isCritical = false
        case "face_retry_failed":
            badgeTitle = "🔄❌ Повторный Face ID отклонён"
            badgeColor = .systemRed
            isCritical = true
        case "shield_enabled":
            badgeTitle = "🛡️ Защита включена"
            badgeColor = .systemGreen
            isCritical = false
        case "shield_paused":
            badgeTitle = "⏸️ Защита на паузе"
            badgeColor = .systemOrange
            isCritical = false
        case "policy_changed":
            badgeTitle = "📋 Политика приложений"
            badgeColor = .systemIndigo
            isCritical = false
        case "config_changed":
            badgeTitle = "⚙️ Настройки изменены"
            badgeColor = .systemPurple
            isCritical = false
        case "vectors_modified", "vectors_enrolled":
            badgeTitle = "🧬 Слепки лица обучены"
            badgeColor = .systemTeal
            isCritical = false
        case "enrollment_cancelled":
            badgeTitle = "⚠️ Калибровка отменена"
            badgeColor = .systemOrange
            isCritical = false
        case "incidents_action":
            badgeTitle = "📸 Журнал инцидентов"
            badgeColor = .systemBrown
            isCritical = false
        case "face_check", "pin_check":
            badgeTitle = event.isSuccess ? "🧪 Проверка пройдена" : "🧪 Проверка отклонена"
            badgeColor = event.isSuccess ? .systemGreen : .systemRed
            isCritical = !event.isSuccess
        case "telegram_alert_sent":
            badgeTitle = "📲 Telegram оповещение"
            badgeColor = .systemBlue
            isCritical = false
        case "telegram_alert_failed":
            badgeTitle = "⚠️ Сбой Telegram"
            badgeColor = .systemOrange
            isCritical = true
        case "audit_cleared":
            badgeTitle = "🧹 Очистка аудита"
            badgeColor = .systemGray
            isCritical = false
        case "audit_pruned":
            badgeTitle = "✂️ Ротация аудита"
            badgeColor = .systemGray
            isCritical = false
        case "audit_exported":
            badgeTitle = "📦 Экспорт аудита"
            badgeColor = .systemTeal
            isCritical = false
        default:
            badgeTitle = event.isSuccess ? "✓ \(event.eventType.uppercased())" : "⚠️ \(event.eventType.uppercased())"
            badgeColor = event.isSuccess ? .systemGreen : .systemRed
            isCritical = !event.isSuccess
        }

        if isCritical {
            card.layer?.borderColor = NSColor.systemRed.withAlphaComponent(0.3).cgColor
        }

        // Badge label
        let badge = NSTextField(frame: NSRect(x: 12, y: frame.height - 30, width: 230, height: 20))
        badge.isEditable = false
        badge.isBordered = false
        badge.backgroundColor = badgeColor.withAlphaComponent(0.18)
        badge.textColor = badgeColor
        badge.font = .systemFont(ofSize: 11, weight: .bold)
        badge.alignment = .center
        badge.wantsLayer = true
        badge.layer?.cornerRadius = 5
        badge.layer?.masksToBounds = true
        badge.stringValue = badgeTitle
        card.addSubview(badge)

        // Timestamp
        let timeLabel = NSTextField(frame: NSRect(x: 250, y: frame.height - 30, width: 260, height: 20))
        timeLabel.isEditable = false
        timeLabel.isBordered = false
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .secondaryLabelColor
        timeLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        timeLabel.stringValue = formatTimestamp(event.timestamp)
        card.addSubview(timeLabel)

        // Description / details
        var desc = event.details ?? ""
        if let app = event.appName {
            desc = "Приложение: \(app) • " + desc
        }
        if let dist = event.distance {
            let thStr = (event.threshold != nil) ? " (Порог: \(String(format: "%.2f", event.threshold!)))" : ""
            desc += " • Дистанция: \(String(format: "%.4f", dist))\(thStr)"
        }

        let descLabel = NSTextField(frame: NSRect(x: 14, y: 12, width: frame.width - 140, height: 38))
        descLabel.isEditable = false
        descLabel.isBordered = false
        descLabel.backgroundColor = .clear
        descLabel.textColor = .white
        descLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descLabel.cell?.wraps = true
        descLabel.cell?.isScrollable = false
        descLabel.stringValue = desc
        descLabel.autoresizingMask = [.width]
        card.addSubview(descLabel)

        // If intruder photo exists, provide photo button
        if let photo = event.intruderPhoto, !photo.isEmpty {
            let photoBtn = NSButton(frame: NSRect(x: frame.width - 110, y: (frame.height - 32) / 2, width: 95, height: 30))
            photoBtn.title = "Фото 📷"
            photoBtn.bezelStyle = .inline
            photoBtn.autoresizingMask = [.minXMargin]
            photoBtn.target = self
            photoBtn.action = #selector(openPhotoClicked(_:))
            photoBtn.identifier = NSUserInterfaceItemIdentifier(photo)
            card.addSubview(photoBtn)
        }

        return card
    }

    private func formatTimestamp(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return df.string(from: date)
        }
        return iso
    }

    @objc private func filterChanged(_ sender: NSPopUpButton) {
        let idx = sender.indexOfSelectedItem
        switch idx {
        case 1: currentFilter = "face"
        case 2: currentFilter = "intruder"
        case 3: currentFilter = "pin"
        case 4: currentFilter = "touchid"
        case 5: currentFilter = "shield"
        case 6: currentFilter = "policy"
        case 7: currentFilter = "config"
        case 8: currentFilter = "vectors"
        case 9: currentFilter = "lock"
        case 10: currentFilter = "telegram"
        default: currentFilter = nil
        }
        reloadLogs()
    }

    @objc private func refreshClicked() {
        reloadLogs()
    }

    @objc private func openInFinder() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let file = home.appendingPathComponent(".facelock/audit_log.jsonl")
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: file.deletingLastPathComponent().path)
    }

    @objc private func openPhotoClicked(_ sender: NSButton) {
        guard let filename = sender.identifier?.rawValue else { return }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let photoURL = home.appendingPathComponent(".facelock/intruders").appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: photoURL.path) {
            NSWorkspace.shared.open(photoURL)
        }
    }

    @objc private func pruneLogsClicked() {
        let alert = NSAlert()
        alert.messageText = "Проредить журнал аудита безопасности"
        alert.informativeText = "Выберите количество последних событий безопасности для сохранения. Более старые записи будут удалены для оптимизации журнала:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Оставить 100")
        alert.addButton(withTitle: "Оставить 50")
        alert.addButton(withTitle: "Оставить 25")
        alert.addButton(withTitle: "Отмена")

        let response = alert.runModal()
        let keepCount: Int
        switch response {
        case .alertFirstButtonReturn: keepCount = 100
        case .alertSecondButtonReturn: keepCount = 50
        case .alertThirdButtonReturn: keepCount = 25
        default: return
        }

        let res = SecurityAuditLogger.shared.pruneLogs(keeping: keepCount)
        SecurityAuditLogger.shared.log(
            eventType: "audit_pruned",
            appName: "FaceLock GUI",
            details: "Pruned \(res.prunedCount) older audit events from GUI (retained \(res.remainingCount))",
            isSuccess: true
        )
        reloadLogs()
    }

    @objc private func clearLogsClicked() {
        let alert = NSAlert()
        alert.messageText = "Очистить журнал аудита безопасности?"
        alert.informativeText = "Все записанные события безопасности будут безвозвратно удалены."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Очистить")
        alert.addButton(withTitle: "Отмена")

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        _ = SecurityAuditLogger.shared.clearLogs()
        reloadLogs()
    }

    @objc private func exportLogsClicked() {
        let savePanel = NSSavePanel()
        savePanel.title = "Экспорт журнала аудита безопасности"
        savePanel.nameFieldStringValue = "facelock_audit_\(Date().timeIntervalSince1970).jsonl"
        savePanel.allowedContentTypes = []

        savePanel.begin { [weak self] response in
            guard response == .OK, let url = savePanel.url else { return }
            do {
                _ = try SecurityAuditLogger.shared.exportLogs(to: url.path)
                let successAlert = NSAlert()
                successAlert.messageText = "Экспорт завершён"
                successAlert.informativeText = "Журнал аудита успешно сохранён:\n\(url.path)"
                successAlert.alertStyle = .informational
                successAlert.addButton(withTitle: "OK")
                successAlert.runModal()
            } catch {
                let errAlert = NSAlert()
                errAlert.messageText = "Ошибка экспорта"
                errAlert.informativeText = error.localizedDescription
                errAlert.alertStyle = .critical
                errAlert.addButton(withTitle: "OK")
                errAlert.runModal()
            }
            self?.reloadLogs()
        }
    }
}
