import AppKit

public final class IncidentGalleryController: NSObject {
    public static let shared = IncidentGalleryController()

    private var window: NSWindow?
    private var scrollView: NSScrollView?
    private var containerView: NSView?

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

        let width: CGFloat = 700
        let height: CGFloat = 560

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Журнал инцидентов FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 580, height: 420)

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true
        root.autoresizingMask = [.width, .height]

        let header = NSView(frame: NSRect(x: 0, y: height - 70, width: width, height: 70))
        header.autoresizingMask = [.width, .minYMargin]
        header.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: 36, width: 350, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Журнал зафиксированных лиц"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        header.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: 14, width: 350, height: 18))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.stringValue = "История попыток доступа к приложениям"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        header.addSubview(subtitle)

        let finderBtn = NSButton(frame: NSRect(x: width - 260, y: 20, width: 130, height: 32))
        finderBtn.title = "Открыть в Finder"
        finderBtn.bezelStyle = .rounded
        finderBtn.autoresizingMask = [.minXMargin]
        finderBtn.target = self
        finderBtn.action = #selector(openInFinder)
        header.addSubview(finderBtn)

        let clearBtn = NSButton(frame: NSRect(x: width - 120, y: 20, width: 100, height: 32))
        clearBtn.title = "Очистить"
        clearBtn.bezelStyle = .rounded
        clearBtn.autoresizingMask = [.minXMargin]
        clearBtn.target = self
        clearBtn.action = #selector(clearAllIncidents)
        header.addSubview(clearBtn)

        root.addSubview(header)

        let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: width, height: height - 70))
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

    private func reloadIncidents() {
        guard let container = containerView, let scroll = scrollView else { return }
        container.subviews.forEach { $0.removeFromSuperview() }

        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)

        let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted(by: >) // newest first

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
        let thumbView = NSImageView(frame: NSRect(x: 12, y: 12, width: thumbSize, height: thumbSize))
        thumbView.wantsLayer = true
        thumbView.layer?.cornerRadius = 10
        thumbView.layer?.masksToBounds = true
        thumbView.imageScaling = .scaleProportionallyUpOrDown
        thumbView.image = NSImage(contentsOf: fileURL)
        card.addSubview(thumbView)

        let filename = fileURL.lastPathComponent
        let dateStr = parseDateFromFilename(filename)

        let titleLabel = NSTextField(frame: NSRect(x: 122, y: frame.height - 38, width: frame.width - 240, height: 22))
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .systemRed
        titleLabel.stringValue = "⚠️ Обнаружено неизвестное лицо"
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        card.addSubview(titleLabel)

        let dateLabel = NSTextField(frame: NSRect(x: 122, y: frame.height - 62, width: frame.width - 240, height: 20))
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

        let viewBtn = NSButton(frame: NSRect(x: frame.width - 165, y: (frame.height - 30) / 2, width: 72, height: 30))
        viewBtn.title = "Просмотр"
        viewBtn.bezelStyle = .inline
        viewBtn.autoresizingMask = [.minXMargin]
        viewBtn.target = self
        viewBtn.action = #selector(viewIncidentClicked(_:))
        viewBtn.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        card.addSubview(viewBtn)

        let deleteBtn = NSButton(frame: NSRect(x: frame.width - 85, y: (frame.height - 30) / 2, width: 70, height: 30))
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
        // intruder_2026-10-19_13-02-16.jpg
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
        if let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
            for f in files {
                try? FileManager.default.removeItem(at: dir.appendingPathComponent(f))
            }
        }
        reloadIncidents()
    }

    @objc private func viewIncidentClicked(_ sender: NSButton) {
        guard let path = sender.identifier?.rawValue else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    @objc private func deleteIncidentClicked(_ sender: NSButton) {
        guard let path = sender.identifier?.rawValue else { return }
        try? FileManager.default.removeItem(atPath: path)
        reloadIncidents()
    }
}
