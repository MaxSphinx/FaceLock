import AppKit
import UniformTypeIdentifiers

public final class ApplicationsManagerController: NSObject, NSSearchFieldDelegate {
    public static let shared = ApplicationsManagerController()

    private var window: FaceLockUtilityWindow?
    private var segmentedControl: NSSegmentedControl?
    private var searchField: NSSearchField?
    private var statsLabel: NSTextField?
    private var scrollView: NSScrollView?
    private var containerView: NSView?
    private var runningAppsPopup: NSPopUpButton?

    // 0: Protected Apps, 1: Ignored Apps
    private var activeCategory: Int = 0
    private var searchFilter: String = ""

    private override init() {
        super.init()
    }

    public func show(category: Int = 0) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activeCategory = (category == 1) ? 1 : 0
            self.createWindowIfNeeded()
            self.segmentedControl?.selectedSegment = self.activeCategory
            self.reloadList()
            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 740
        let height: CGFloat = 580

        let win = FaceLockUtilityWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Политика приложений FaceLock"
        win.appearance = NSAppearance(named: .darkAqua)
        win.isReleasedWhenClosed = false
        win.minSize = NSSize(width: 620, height: 440)
        win.onRefresh = { [weak self] in
            self?.reloadList()
        }
        win.onSearch = { [weak self] in
            self?.searchField?.becomeFirstResponder()
        }

        let root = NSView(frame: win.contentView!.bounds)
        root.wantsLayer = true
        root.autoresizingMask = [.width, .height]

        // Header View
        let headerH: CGFloat = 100
        let header = NSView(frame: NSRect(x: 0, y: height - headerH, width: width, height: headerH))
        header.autoresizingMask = [.width, .minYMargin]
        header.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: 64, width: 340, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Политика приложений"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.textColor = .white
        header.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: 44, width: 440, height: 18))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.stringValue = "Настройка списка защищаемых и системных приложений macOS"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor
        header.addSubview(subtitle)

        let stats = NSTextField(frame: NSRect(x: 20, y: 20, width: 440, height: 18))
        stats.isEditable = false
        stats.isBordered = false
        stats.backgroundColor = .clear
        stats.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        stats.textColor = .systemCyan
        header.addSubview(stats)
        self.statsLabel = stats

        // Segmented Control for switching Protected vs Ignored
        let seg = NSSegmentedControl(labels: ["Защищаемые приложения", "Игнорируемые системой"], trackingMode: .selectOne, target: self, action: #selector(onCategoryChanged(_:)))
        seg.frame = NSRect(x: 20, y: 2, width: 380, height: 24)
        seg.selectedSegment = 0
        seg.autoresizingMask = [.maxXMargin]
        header.addSubview(seg)
        self.segmentedControl = seg

        // Search Field
        let search = NSSearchField(frame: NSRect(x: width - 290, y: 2, width: 270, height: 24))
        search.placeholderString = "Поиск приложения (Cmd+F)..."
        search.autoresizingMask = [.minXMargin]
        search.target = self
        search.action = #selector(onSearchChanged(_:))
        search.delegate = self
        header.addSubview(search)
        self.searchField = search

        let refreshBtn = NSButton(frame: NSRect(x: width - 110, y: 60, width: 90, height: 28))
        refreshBtn.title = "Обновить"
        refreshBtn.bezelStyle = .rounded
        refreshBtn.autoresizingMask = [.minXMargin]
        refreshBtn.target = self
        refreshBtn.action = #selector(refreshClicked)
        header.addSubview(refreshBtn)

        root.addSubview(header)

        // Bottom Action Bar
        let footerH: CGFloat = 54
        let footer = NSView(frame: NSRect(x: 0, y: 0, width: width, height: footerH))
        footer.autoresizingMask = [.width, .maxYMargin]
        footer.wantsLayer = true

        let border = NSBox(frame: NSRect(x: 0, y: footerH - 1, width: width, height: 1))
        border.boxType = .custom
        border.fillColor = NSColor.white.withAlphaComponent(0.1)
        border.borderWidth = 0
        border.autoresizingMask = [.width]
        footer.addSubview(border)

        // Add from Running Applications Popup
        let runningPopup = NSPopUpButton(frame: NSRect(x: 20, y: 12, width: 220, height: 28), pullsDown: false)
        runningPopup.autoresizingMask = [.maxXMargin]
        runningPopup.target = self
        runningPopup.action = #selector(onRunningAppSelected(_:))
        footer.addSubview(runningPopup)
        self.runningAppsPopup = runningPopup

        let browseBtn = NSButton(frame: NSRect(x: 246, y: 12, width: 140, height: 28))
        browseBtn.title = "Выбрать в Finder..."
        browseBtn.bezelStyle = .rounded
        browseBtn.autoresizingMask = [.maxXMargin]
        browseBtn.target = self
        browseBtn.action = #selector(onBrowseAppsClicked)
        footer.addSubview(browseBtn)

        let addManualBtn = NSButton(frame: NSRect(x: 392, y: 12, width: 130, height: 28))
        addManualBtn.title = "Ввести ID вручную..."
        addManualBtn.bezelStyle = .rounded
        addManualBtn.autoresizingMask = [.maxXMargin]
        addManualBtn.target = self
        addManualBtn.action = #selector(onAddCustomBundleIdClicked)
        footer.addSubview(addManualBtn)

        let resetBtn = NSButton(frame: NSRect(x: width - 210, y: 12, width: 110, height: 28))
        resetBtn.title = "По умолчанию"
        resetBtn.bezelStyle = .rounded
        resetBtn.autoresizingMask = [.minXMargin]
        resetBtn.target = self
        resetBtn.action = #selector(onResetDefaultsClicked)
        footer.addSubview(resetBtn)

        let closeBtn = NSButton(frame: NSRect(x: width - 94, y: 12, width: 75, height: 28))
        closeBtn.title = "Готово"
        closeBtn.bezelStyle = .rounded
        closeBtn.autoresizingMask = [.minXMargin]
        closeBtn.target = self
        closeBtn.action = #selector(closeClicked)
        footer.addSubview(closeBtn)

        root.addSubview(footer)

        // Center Scroll View
        let scrollY = footerH
        let scrollH = height - headerH - footerH
        let scroll = NSScrollView(frame: NSRect(x: 0, y: scrollY, width: width, height: scrollH))
        scroll.autoresizingMask = [.width, .height]
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false

        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: scrollH))
        container.wantsLayer = true
        scroll.documentView = container
        root.addSubview(scroll)

        self.scrollView = scroll
        self.containerView = container
        win.contentView = root
        self.window = win
    }

    public func reloadList() {
        guard let container = containerView, let scroll = scrollView else { return }

        let config = Config.shared
        let protectedList = config.protectedBundleIdentifiers
        let ignoredList = config.ignoredBundleIdentifiers

        // Update counters on segmented control and stats
        segmentedControl?.setLabel("Защищаемые (\(protectedList.count))", forSegment: 0)
        segmentedControl?.setLabel("Игнорируемые (\(ignoredList.count))", forSegment: 1)

        let modeDesc = (config.protectionMode == "selective") ? "Только секретные" : "Все приложения"
        statsLabel?.stringValue = "Защищено: \(protectedList.count)  •  Игнорируется: \(ignoredList.count)  •  Режим защиты: \(modeDesc)"

        // Filter items
        let fullList = (activeCategory == 0) ? protectedList : ignoredList
        let query = searchFilter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filteredList: [String]
        if query.isEmpty {
            filteredList = fullList
        } else {
            filteredList = fullList.filter { bundleId in
                let name = Config.localizedAppName(for: bundleId).lowercased()
                return bundleId.lowercased().contains(query) || name.contains(query)
            }
        }

        // Clean container
        container.subviews.forEach { $0.removeFromSuperview() }

        let itemHeight: CGFloat = 52
        let itemSpacing: CGFloat = 8
        let totalItems = filteredList.count
        let totalHeight = max(scroll.bounds.height, CGFloat(totalItems) * (itemHeight + itemSpacing) + 20)

        container.frame = NSRect(x: 0, y: 0, width: scroll.bounds.width, height: totalHeight)

        if totalItems == 0 {
            let emptyLabel = NSTextField(frame: NSRect(x: 20, y: totalHeight / 2 - 20, width: scroll.bounds.width - 40, height: 40))
            emptyLabel.isEditable = false
            emptyLabel.isBordered = false
            emptyLabel.backgroundColor = .clear
            emptyLabel.alignment = .center
            emptyLabel.textColor = .secondaryLabelColor
            emptyLabel.font = .systemFont(ofSize: 14)
            if query.isEmpty {
                emptyLabel.stringValue = (activeCategory == 0)
                    ? "Список защищаемых приложений пуст.\nДобавьте приложения через меню ниже."
                    : "Список игнорируемых приложений пуст."
            } else {
                emptyLabel.stringValue = "По запросу «\(query)» ничего не найдено."
            }
            container.addSubview(emptyLabel)
            populateRunningAppsMenu()
            return
        }

        var currentY = totalHeight - 14 - itemHeight
        for bundleId in filteredList {
            let row = makeRowView(bundleId: bundleId, frame: NSRect(x: 20, y: currentY, width: scroll.bounds.width - 40, height: itemHeight))
            container.addSubview(row)
            currentY -= (itemHeight + itemSpacing)
        }

        populateRunningAppsMenu()
    }

    private func makeRowView(bundleId: String, frame: NSRect) -> NSView {
        let row = NSView(frame: frame)
        row.wantsLayer = true
        row.layer?.cornerRadius = 10
        row.layer?.backgroundColor = NSColor(white: 0.16, alpha: 0.85).cgColor
        row.layer?.borderWidth = 1.0
        row.layer?.borderColor = NSColor.white.withAlphaComponent(0.08).cgColor
        row.autoresizingMask = [.width]

        // App Icon
        let iconSize: CGFloat = 34
        let iconView = NSImageView(frame: NSRect(x: 10, y: (frame.height - iconSize) / 2, width: iconSize, height: iconSize))
        iconView.image = Config.appIcon(for: bundleId, size: NSSize(width: iconSize, height: iconSize))
        row.addSubview(iconView)

        // App Display Name & Bundle ID
        let textX: CGFloat = 54
        let nameW: CGFloat = frame.width - textX - 220
        let appName = Config.localizedAppName(for: bundleId)

        let nameLabel = NSTextField(frame: NSRect(x: textX, y: 26, width: nameW, height: 18))
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.backgroundColor = .clear
        nameLabel.stringValue = appName
        nameLabel.font = .systemFont(ofSize: 13, weight: .bold)
        nameLabel.textColor = .white
        row.addSubview(nameLabel)

        let idLabel = NSTextField(frame: NSRect(x: textX, y: 8, width: nameW, height: 16))
        idLabel.isEditable = false
        idLabel.isBordered = false
        idLabel.backgroundColor = .clear
        idLabel.stringValue = bundleId
        idLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        idLabel.textColor = .secondaryLabelColor
        row.addSubview(idLabel)

        // Category Badge
        let badgeW: CGFloat = 105
        let badgeH: CGFloat = 20
        let badgeX = frame.width - badgeW - 85
        let badge = NSTextField(frame: NSRect(x: badgeX, y: (frame.height - badgeH) / 2, width: badgeW, height: badgeH))
        badge.isEditable = false
        badge.isBordered = false
        badge.alignment = .center
        badge.wantsLayer = true
        badge.layer?.cornerRadius = 5
        badge.layer?.masksToBounds = true
        badge.font = .systemFont(ofSize: 10, weight: .bold)
        badge.autoresizingMask = [.minXMargin]

        if activeCategory == 0 {
            badge.stringValue = "🛡️ Секретное"
            badge.textColor = .systemIndigo
            badge.backgroundColor = NSColor.systemIndigo.withAlphaComponent(0.18)
        } else {
            badge.stringValue = "⚙️ Системное"
            badge.textColor = .systemGray
            badge.backgroundColor = NSColor.systemGray.withAlphaComponent(0.18)
        }
        row.addSubview(badge)

        // Delete Button
        let delBtn = NSButton(frame: NSRect(x: frame.width - 76, y: (frame.height - 26) / 2, width: 68, height: 26))
        delBtn.title = "Удалить"
        delBtn.bezelStyle = .rounded
        delBtn.contentTintColor = .systemRed
        delBtn.autoresizingMask = [.minXMargin]
        delBtn.target = self
        delBtn.action = #selector(onRemoveAppClicked(_:))
        delBtn.identifier = NSUserInterfaceItemIdentifier(bundleId)
        row.addSubview(delBtn)

        return row
    }

    private func populateRunningAppsMenu() {
        guard let popup = runningAppsPopup else { return }
        popup.removeAllItems()
        popup.addItem(withTitle: "+ Добавить запущенное...")

        let currentSet = Set((activeCategory == 0) ? Config.shared.protectedBundleIdentifiers : Config.shared.ignoredBundleIdentifiers)
        let running = NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .compactMap { app -> (String, String, NSImage)? in
                guard let id = app.bundleIdentifier, !id.isEmpty, id != "io.github.facelock" else { return nil }
                if currentSet.contains(id) { return nil }
                let name = app.localizedName ?? Config.localizedAppName(for: id)
                let icon = app.icon ?? Config.appIcon(for: id, size: NSSize(width: 16, height: 16))
                icon.size = NSSize(width: 16, height: 16)
                return (id, name, icon)
            }
            .sorted(by: { $0.1.localizedCaseInsensitiveCompare($1.1) == .orderedAscending })

        for (id, name, icon) in running {
            let item = NSMenuItem(title: "\(name) (\(id))", action: nil, keyEquivalent: "")
            item.image = icon
            item.representedObject = id
            popup.menu?.addItem(item)
        }
    }

    @objc private func onCategoryChanged(_ sender: NSSegmentedControl) {
        activeCategory = sender.selectedSegment
        reloadList()
    }

    @objc private func onSearchChanged(_ sender: NSSearchField) {
        searchFilter = sender.stringValue
        reloadList()
    }

    @objc private func onRunningAppSelected(_ sender: NSPopUpButton) {
        guard sender.indexOfSelectedItem > 0,
              let id = sender.selectedItem?.representedObject as? String else {
            return
        }

        let appName = Config.localizedAppName(for: id)
        if activeCategory == 0 {
            _ = Config.shared.addProtectedApp(id)
            SecurityAuditLogger.shared.logPolicyChanged(action: "Added protected application via GUI", bundleId: id)
        } else {
            _ = Config.shared.addIgnoredApp(id)
            SecurityAuditLogger.shared.logPolicyChanged(action: "Added ignored application via GUI", bundleId: id)
        }

        AppDelegate.notifyDaemonReload()
        reloadList()

        HUDController.shared.showScanning(appName: "+ \(appName)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HUDController.shared.hide()
        }
    }

    @objc private func onBrowseAppsClicked() {
        guard let win = window else { return }

        let panel = NSOpenPanel()
        panel.title = (activeCategory == 0) ? "Выберите защищаемое приложение" : "Выберите системное приложение"
        panel.prompt = "Добавить"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.application]

        panel.beginSheetModal(for: win) { [weak self] response in
            guard let self = self, response == .OK else { return }
            var addedCount = 0
            var lastName = ""
            for url in panel.urls {
                guard let bundle = Bundle(url: url), let bundleId = bundle.bundleIdentifier else { continue }
                let added = (self.activeCategory == 0)
                    ? Config.shared.addProtectedApp(bundleId)
                    : Config.shared.addIgnoredApp(bundleId)
                if added {
                    addedCount += 1
                    lastName = Config.localizedAppName(for: bundleId)
                    SecurityAuditLogger.shared.logPolicyChanged(
                        action: (self.activeCategory == 0) ? "Added protected app from Finder" : "Added ignored app from Finder",
                        bundleId: bundleId
                    )
                }
            }

            if addedCount > 0 {
                AppDelegate.notifyDaemonReload()
                self.reloadList()
                let hudMsg = (addedCount == 1) ? "+ \(lastName)" : "+ \(addedCount) приложений"
                HUDController.shared.showScanning(appName: hudMsg)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    HUDController.shared.hide()
                }
            }
        }
    }

    @objc private func onAddCustomBundleIdClicked() {
        guard let win = window else { return }

        let alert = NSAlert()
        alert.messageText = (activeCategory == 0)
            ? "Добавить защищаемое приложение"
            : "Добавить игнорируемое приложение"
        alert.informativeText = "Введите Bundle Identifier приложения (например: com.tinyspeck.slackmacgap):"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Добавить")
        alert.addButton(withTitle: "Отмена")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
        input.placeholderString = "com.company.appname"
        alert.accessoryView = input

        alert.beginSheetModal(for: win) { [weak self] response in
            guard let self = self, response == .alertFirstButtonReturn else { return }
            let bundleId = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !bundleId.isEmpty else { return }

            let added = (self.activeCategory == 0)
                ? Config.shared.addProtectedApp(bundleId)
                : Config.shared.addIgnoredApp(bundleId)

            if added {
                SecurityAuditLogger.shared.logPolicyChanged(
                    action: (self.activeCategory == 0) ? "Added protected app manually" : "Added ignored app manually",
                    bundleId: bundleId
                )
                AppDelegate.notifyDaemonReload()
                self.reloadList()
                HUDController.shared.showScanning(appName: "+ \(Config.localizedAppName(for: bundleId))")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    HUDController.shared.hide()
                }
            }
        }
    }

    @objc private func onResetDefaultsClicked() {
        guard let win = window else { return }

        let alert = NSAlert()
        alert.messageText = "Сбросить список по умолчанию?"
        alert.informativeText = (activeCategory == 0)
            ? "Список защищаемых приложений вернётся к стандартному набору macOS (Telegram, Safari, Photos, Notes, etc.)."
            : "Список игнорируемых приложений вернётся к стандартным системным демонам macOS (Finder, Dock, Spotlight, etc.)."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Сбросить")
        alert.addButton(withTitle: "Отмена")

        alert.beginSheetModal(for: win) { [weak self] response in
            guard let self = self, response == .alertFirstButtonReturn else { return }
            if self.activeCategory == 0 {
                Config.shared.resetProtectedApps()
                SecurityAuditLogger.shared.logPolicyChanged(action: "Reset protected apps to defaults", bundleId: "all")
            } else {
                Config.shared.resetIgnoredApps()
                SecurityAuditLogger.shared.logPolicyChanged(action: "Reset ignored apps to defaults", bundleId: "all")
            }
            AppDelegate.notifyDaemonReload()
            self.reloadList()
        }
    }

    @objc private func onRemoveAppClicked(_ sender: NSButton) {
        guard let bundleId = sender.identifier?.rawValue, !bundleId.isEmpty else { return }

        let removed = (activeCategory == 0)
            ? Config.shared.removeProtectedApp(bundleId)
            : Config.shared.removeIgnoredApp(bundleId)

        if removed {
            SecurityAuditLogger.shared.logPolicyChanged(
                action: (activeCategory == 0) ? "Removed protected app via GUI" : "Removed ignored app via GUI",
                bundleId: bundleId
            )
            AppDelegate.notifyDaemonReload()
            reloadList()
        }
    }

    @objc private func refreshClicked() {
        reloadList()
    }

    @objc private func closeClicked() {
        window?.orderOut(nil)
    }
}
