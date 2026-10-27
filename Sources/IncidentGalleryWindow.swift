import AppKit
import UniformTypeIdentifiers

public final class IncidentGalleryController: NSObject {
    public static let shared = IncidentGalleryController()

    private var window: NSWindow?
    private var scrollView: NSScrollView?
    private var containerView: NSView?
    private var statsLabel: NSTextField?

    private override init() {
        super.init()
    }

    public func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createWindowIfNeeded()
            self.reloadIncidents()
            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 780
        let height: CGFloat = 620

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Журнал инцидентов FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 680, height: 460)

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true
        root.autoresizingMask = [.width, .height]

        let headerH: CGFloat = 95
        let header = NSView(frame: NSRect(x: 0, y: height - headerH, width: width, height: headerH))
        header.autoresizingMask = [.width, .minYMargin]
        header.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: 60, width: 380, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Журнал зафиксированных лиц"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        header.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: 38, width: 380, height: 18))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.stringValue = "История попыток доступа к защищённым приложениям"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        header.addSubview(subtitle)

        let stats = NSTextField(frame: NSRect(x: 20, y: 14, width: 380, height: 18))
        stats.isEditable = false
        stats.isBordered = false
        stats.backgroundColor = .clear
        stats.stringValue = "Загрузка телеметрии..."
        stats.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        stats.textColor = .systemCyan
        header.addSubview(stats)
        self.statsLabel = stats

        let finderBtn = NSButton(frame: NSRect(x: width - 440, y: 52, width: 90, height: 30))
        finderBtn.title = "В Finder"
        finderBtn.bezelStyle = .rounded
        finderBtn.autoresizingMask = [.minXMargin]
        finderBtn.target = self
        finderBtn.action = #selector(openInFinder)
        header.addSubview(finderBtn)

        let exportArchiveBtn = NSButton(frame: NSRect(x: width - 345, y: 52, width: 140, height: 30))
        exportArchiveBtn.title = "Экспорт архива..."
        exportArchiveBtn.bezelStyle = .rounded
        exportArchiveBtn.autoresizingMask = [.minXMargin]
        exportArchiveBtn.target = self
        exportArchiveBtn.action = #selector(exportArchiveClicked)
        header.addSubview(exportArchiveBtn)

        let refreshBtn = NSButton(frame: NSRect(x: width - 200, y: 52, width: 95, height: 30))
        refreshBtn.title = "Обновить"
        refreshBtn.bezelStyle = .rounded
        refreshBtn.autoresizingMask = [.minXMargin]
        refreshBtn.target = self
        refreshBtn.action = #selector(refreshClicked)
        header.addSubview(refreshBtn)

        let clearBtn = NSButton(frame: NSRect(x: width - 100, y: 52, width: 85, height: 30))
        clearBtn.title = "Очистить"
        clearBtn.bezelStyle = .rounded
        clearBtn.autoresizingMask = [.minXMargin]
        clearBtn.target = self
        clearBtn.action = #selector(clearAllIncidents)
        header.addSubview(clearBtn)

        root.addSubview(header)

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

    @objc private func refreshClicked() {
        reloadIncidents()
    }

    private func reloadIncidents() {
        guard let container = containerView, let scroll = scrollView else { return }
        container.subviews.forEach { $0.removeFromSuperview() }

        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)

        let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted(by: >) // newest first

        // Calculate storage & time metrics
        var totalBytes: UInt64 = 0
        var past24Count = 0
        let now = Date()

        for file in files {
            let p = dir.appendingPathComponent(file).path
            if let attrs = try? FileManager.default.attributesOfItem(atPath: p) {
                let sz = (attrs[.size] as? UInt64) ?? 0
                totalBytes += sz
                if let mod = attrs[.modificationDate] as? Date {
                    if now.timeIntervalSince(mod) <= 86400 {
                        past24Count += 1
                    }
                }
            }
        }

        let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
        let metricsStr = files.isEmpty
            ? "Журнал чист • 0 инцидентов"
            : "Всего: \(files.count) инцидентов (\(past24Count) за 24ч) • Память: \(String(format: "%.2f", sizeMB)) МБ"
        statsLabel?.stringValue = metricsStr

        if files.isEmpty {
            let emptyLabel = NSTextField(frame: NSRect(x: 20, y: (scroll.bounds.height - 40) / 2, width: scroll.bounds.width - 40, height: 40))
            emptyLabel.isEditable = false
            emptyLabel.isBordered = false
            emptyLabel.backgroundColor = .clear
            emptyLabel.textColor = .secondaryLabelColor
            emptyLabel.font = .systemFont(ofSize: 15, weight: .medium)
            emptyLabel.alignment = .center
            emptyLabel.stringValue = "🎉 Журнал чист! Ни одного постороннего не зафиксировано."
            container.addSubview(emptyLabel)
            container.frame = scroll.contentView.bounds
            return
        }

        let itemH: CGFloat = 120
        let itemW: CGFloat = scroll.bounds.width - 40
        let totalH = CGFloat(files.count) * (itemH + 12) + 20
        container.frame = NSRect(x: 0, y: 0, width: scroll.bounds.width, height: max(totalH, scroll.bounds.height))

        var currentY = totalH - itemH - 10

        for file in files {
            let fileURL = dir.appendingPathComponent(file)
            let card = makeIncidentCard(fileURL: fileURL, frame: NSRect(x: 20, y: currentY, width: itemW, height: itemH))
            container.addSubview(card)
            currentY -= (itemH + 12)
        }
    }

    private func makeIncidentCard(fileURL: URL, frame: NSRect) -> NSView {
        let card = NSView(frame: frame)
        card.wantsLayer = true
        card.layer?.cornerRadius = 14
        card.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.85).cgColor
        card.layer?.borderWidth = 1.0
        card.layer?.borderColor = NSColor.white.withAlphaComponent(0.1).cgColor
        card.autoresizingMask = [.width]

        let thumbSize: CGFloat = 96
        let thumbBtn = NSButton(frame: NSRect(x: 12, y: 12, width: thumbSize, height: thumbSize))
        thumbBtn.wantsLayer = true
        thumbBtn.layer?.cornerRadius = 10
        thumbBtn.layer?.masksToBounds = true
        thumbBtn.isBordered = false
        thumbBtn.imageScaling = .scaleProportionallyUpOrDown
        thumbBtn.image = NSImage(contentsOf: fileURL)
        thumbBtn.target = self
        thumbBtn.action = #selector(viewIncidentClicked(_:))
        thumbBtn.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        thumbBtn.toolTip = "Нажмите для просмотра в полном разрешении"
        card.addSubview(thumbBtn)

        let filename = fileURL.lastPathComponent
        let dateStr = parseDateFromFilename(filename)

        let titleLabel = NSTextField(frame: NSRect(x: 122, y: frame.height - 38, width: frame.width - 370, height: 22))
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .systemRed
        titleLabel.stringValue = "⚠️ Обнаружено неизвестное лицо"
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        card.addSubview(titleLabel)

        let dateLabel = NSTextField(frame: NSRect(x: 122, y: frame.height - 62, width: frame.width - 370, height: 20))
        dateLabel.isEditable = false
        dateLabel.isBordered = false
        dateLabel.backgroundColor = .clear
        dateLabel.textColor = .white
        dateLabel.stringValue = "Время: \(dateStr)"
        dateLabel.font = .systemFont(ofSize: 13, weight: .medium)
        card.addSubview(dateLabel)

        let statusBadge = NSTextField(frame: NSRect(x: 122, y: 16, width: 170, height: 22))
        statusBadge.isEditable = false
        statusBadge.isBordered = false
        statusBadge.backgroundColor = NSColor.systemRed.withAlphaComponent(0.2)
        statusBadge.textColor = .systemRed
        statusBadge.stringValue = "Доступ заблокирован"
        statusBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        statusBadge.alignment = .center
        statusBadge.wantsLayer = true
        statusBadge.layer?.cornerRadius = 6
        statusBadge.layer?.masksToBounds = true
        card.addSubview(statusBadge)

        // Action Buttons on Right
        let viewBtn = NSButton(frame: NSRect(x: frame.width - 245, y: (frame.height - 30) / 2, width: 75, height: 30))
        viewBtn.title = "Просмотр"
        viewBtn.bezelStyle = .inline
        viewBtn.autoresizingMask = [.minXMargin]
        viewBtn.target = self
        viewBtn.action = #selector(viewIncidentClicked(_:))
        viewBtn.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        card.addSubview(viewBtn)

        let exportBtn = NSButton(frame: NSRect(x: frame.width - 165, y: (frame.height - 30) / 2, width: 80, height: 30))
        exportBtn.title = "Экспорт..."
        exportBtn.bezelStyle = .inline
        exportBtn.autoresizingMask = [.minXMargin]
        exportBtn.target = self
        exportBtn.action = #selector(exportSingleIncidentClicked(_:))
        exportBtn.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        card.addSubview(exportBtn)

        let deleteBtn = NSButton(frame: NSRect(x: frame.width - 80, y: (frame.height - 30) / 2, width: 70, height: 30))
        deleteBtn.title = "Удалить"
        deleteBtn.bezelStyle = .inline
        deleteBtn.autoresizingMask = [.minXMargin]
        deleteBtn.target = self
        deleteBtn.action = #selector(deleteIncidentClicked(_:))
        deleteBtn.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        card.addSubview(deleteBtn)

        return card
    }

    private func parseDateFromFilename(_ name: String) -> String {
        let clean = name.replacingOccurrences(of: "intruder_", with: "").replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".jpeg", with: "")
        let parts = clean.split(separator: "_")
        if parts.count >= 2 {
            let date = parts[0]
            let time = parts[1].replacingOccurrences(of: "-", with: ":")
            return "\(date) в \(time)"
        }
        return name
    }

    @objc private func openInFinder() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        NSWorkspace.shared.open(dir)
    }

    @objc private func exportArchiveClicked() {
        let panel = NSOpenPanel()
        panel.title = "Экспорт архива инцидентов FaceLock"
        panel.message = "Выберите папку для сохранения архива фотографий нарушителей и JSON манифеста:"
        panel.prompt = "Экспортировать"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true

        guard let parentWindow = self.window else {
            if panel.runModal() == .OK, let url = panel.url {
                performArchiveExport(to: url)
            }
            return
        }

        panel.beginSheetModal(for: parentWindow) { [weak self] response in
            if response == .OK, let url = panel.url {
                self?.performArchiveExport(to: url)
            }
        }
    }

    private func performArchiveExport(to destinationURL: URL) {
        do {
            let res = try CameraScanner.shared.exportIncidents(to: destinationURL.path)
            let count = res["count"] as? Int ?? 0
            let totalBytes = res["totalBytes"] as? UInt64 ?? 0
            let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)

            SecurityAuditLogger.shared.logIncidentsAction(
                action: "Exported intruder incident archive to folder",
                count: count,
                details: "Exported \(count) photos (\(String(format: "%.2f", sizeMB)) MB) to \(destinationURL.path)"
            )

            let alert = NSAlert()
            alert.messageText = "Экспорт успешно завершён"
            alert.informativeText = "Экспортировано \(count) фотографий нарушителей (\(String(format: "%.2f", sizeMB)) МБ) и манифест (incidents_manifest.json) в папку:\n\(destinationURL.path)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Открыть папку")
            alert.addButton(withTitle: "Готово")

            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(destinationURL)
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Ошибка экспорта архива"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
        }
    }

    @objc private func exportSingleIncidentClicked(_ sender: NSButton) {
        guard let path = sender.identifier?.rawValue else { return }
        let srcURL = URL(fileURLWithPath: path)
        let filename = srcURL.lastPathComponent

        let savePanel = NSSavePanel()
        savePanel.title = "Экспорт снимка нарушителя"
        savePanel.message = "Выберите место для сохранения фотографии:"
        savePanel.prompt = "Сохранить"
        savePanel.nameFieldStringValue = filename
        if #available(macOS 11.0, *) {
            savePanel.allowedContentTypes = [.jpeg]
        }

        let doSave = { (destURL: URL) in
            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                SecurityAuditLogger.shared.logIncidentsAction(
                    action: "Exported individual intruder photo",
                    count: 1,
                    details: "\(filename) exported to \(destURL.path)"
                )
                let alert = NSAlert()
                alert.messageText = "Фотография экспортирована"
                alert.informativeText = "Снимок нарушителя успешно сохранён в:\n\(destURL.path)"
                alert.alertStyle = .informational
                alert.addButton(withTitle: "Открыть в Finder")
                alert.addButton(withTitle: "Готово")
                if alert.runModal() == .alertFirstButtonReturn {
                    NSWorkspace.shared.activateFileViewerSelecting([destURL])
                }
            } catch {
                let alert = NSAlert()
                alert.messageText = "Ошибка экспорта"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .critical
                alert.runModal()
            }
        }

        guard let parentWindow = self.window else {
            if savePanel.runModal() == .OK, let dest = savePanel.url {
                doSave(dest)
            }
            return
        }

        savePanel.beginSheetModal(for: parentWindow) { response in
            if response == .OK, let dest = savePanel.url {
                doSave(dest)
            }
        }
    }

    @objc private func clearAllIncidents() {
        let alert = NSAlert()
        alert.messageText = "Очистить журнал инцидентов?"
        alert.informativeText = "Все сохранённые фотографии посторонних будут безвозвратно удалены."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Удалить всё")
        alert.addButton(withTitle: "Отмена")

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return }

        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        var deletedCount = 0
        if let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
            for f in files {
                try? FileManager.default.removeItem(at: dir.appendingPathComponent(f))
                deletedCount += 1
            }
        }

        SecurityAuditLogger.shared.logIncidentsAction(
            action: "Purged all intruder incident captures from GUI",
            count: deletedCount
        )

        reloadIncidents()
    }

    @objc private func viewIncidentClicked(_ sender: NSButton) {
        guard let path = sender.identifier?.rawValue else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    @objc private func deleteIncidentClicked(_ sender: NSButton) {
        guard let path = sender.identifier?.rawValue else { return }
        let filename = URL(fileURLWithPath: path).lastPathComponent
        try? FileManager.default.removeItem(atPath: path)

        SecurityAuditLogger.shared.logIncidentsAction(
            action: "Deleted intruder capture from GUI",
            count: 1,
            details: "Removed \(filename)"
        )

        reloadIncidents()
    }
}
