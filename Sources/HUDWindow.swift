import AppKit
import QuartzCore

public final class HUDController {
    public static let shared = HUDController()

    private var hudWindow: NSWindow?
    private var iconView: NSImageView?
    private var titleLabel: NSTextField?
    private var visualEffectView: NSVisualEffectView?
    private var hideTimer: DispatchSourceTimer?

    private init() {}

    public func showScanning(appName: String? = nil) {
        guard Config.shared.showHUD else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createHUDIfNeeded()

            self.hideTimer?.cancel()
            self.hideTimer = nil

            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            let img = NSImage(systemSymbolName: "faceid", accessibilityDescription: "Face ID")?.withSymbolConfiguration(symbolConfig)
            self.iconView?.image = img
            self.iconView?.contentTintColor = NSColor.systemCyan

            if let app = appName {
                self.titleLabel?.stringValue = "Face ID: \(app)"
            } else {
                self.titleLabel?.stringValue = "Face ID..."
            }

            self.animateAppearance()
            self.startPulseAnimation()
        }
    }

    public func showSuccess() {
        guard Config.shared.showHUD else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.hudWindow != nil else { return }

            self.stopPulseAnimation()
            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let img = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Verified")?.withSymbolConfiguration(symbolConfig)
            self.iconView?.image = img
            self.iconView?.contentTintColor = NSColor.systemGreen
            self.titleLabel?.stringValue = "Подтверждено"

            // Subtle bounce on icon
            self.bounceIcon()

            self.hideTimer?.cancel()
            let timer = DispatchSource.makeTimerSource(queue: .main)
            timer.schedule(deadline: .now() + 0.45)
            timer.setEventHandler { [weak self] in
                self?.hide()
            }
            self.hideTimer = timer
            timer.resume()
        }
    }

    public func showToggleStatus(isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createHUDIfNeeded()

            self.hideTimer?.cancel()
            self.hideTimer = nil
            self.stopPulseAnimation()

            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            if isEnabled {
                let img = NSImage(systemSymbolName: "lock.shield.fill", accessibilityDescription: "Enabled")?.withSymbolConfiguration(symbolConfig)
                self.iconView?.image = img
                self.iconView?.contentTintColor = NSColor.systemGreen
                self.titleLabel?.stringValue = "FaceLock: Включено"
            } else {
                let img = NSImage(systemSymbolName: "lock.slash.fill", accessibilityDescription: "Disabled")?.withSymbolConfiguration(symbolConfig)
                self.iconView?.image = img
                self.iconView?.contentTintColor = NSColor.systemOrange
                self.titleLabel?.stringValue = "FaceLock: Пауза"
            }

            self.animateAppearance()
            self.bounceIcon()

            let timer = DispatchSource.makeTimerSource(queue: .main)
            timer.schedule(deadline: .now() + 1.2)
            timer.setEventHandler { [weak self] in
                self?.hide()
            }
            self.hideTimer = timer
            timer.resume()
        }
    }

    public func showShoulderSurfingAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createHUDIfNeeded()

            self.hideTimer?.cancel()
            self.hideTimer = nil
            self.stopPulseAnimation()

            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let img = NSImage(systemSymbolName: "person.2.slash.fill", accessibilityDescription: "Shoulder Surfing")?.withSymbolConfiguration(symbolConfig)
                ?? NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Warning")?.withSymbolConfiguration(symbolConfig)
            self.iconView?.image = img
            self.iconView?.contentTintColor = NSColor.systemYellow
            self.titleLabel?.stringValue = "Внимание: лицо за спиной!"

            self.animateAppearance()
            self.bounceIcon()
            HUDController.playAlertSound(type: "shoulder")

            let timer = DispatchSource.makeTimerSource(queue: .main)
            timer.schedule(deadline: .now() + 2.5)
            timer.setEventHandler { [weak self] in
                self?.hide()
            }
            self.hideTimer = timer
            timer.resume()
        }
    }

    public func showProfile(name: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createHUDIfNeeded()

            self.hideTimer?.cancel()
            self.hideTimer = nil
            self.stopPulseAnimation()

            let symbolConfig = NSImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let img = NSImage(systemSymbolName: "shield.lefthalf.filled", accessibilityDescription: "Profile")?.withSymbolConfiguration(symbolConfig)
            self.iconView?.image = img
            self.iconView?.contentTintColor = NSColor.systemCyan
            self.titleLabel?.stringValue = "Профиль: \(name)"

            self.animateAppearance()
            self.bounceIcon()

            let timer = DispatchSource.makeTimerSource(queue: .main)
            timer.schedule(deadline: .now() + 1.5)
            timer.setEventHandler { [weak self] in
                self?.hide()
            }
            self.hideTimer = timer
            timer.resume()
        }
    }

    public static func playAlertSound(type: String) {
        guard Config.shared.audibleAlerts else { return }
        DispatchQueue.main.async {
            switch type {
            case "warning", "shoulder":
                NSSound(named: "Funk")?.play()
            case "intruder", "lock":
                NSSound(named: "Basso")?.play()
            case "success", "unlock":
                NSSound(named: "Tink")?.play()
            default:
                break
            }
        }
    }

    public func hide() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let win = self.hudWindow else { return }
            self.hideTimer?.cancel()
            self.hideTimer = nil
            self.stopPulseAnimation()

            let targetOrigin = NSPoint(x: win.frame.origin.x, y: win.frame.origin.y + 15)

            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.25
                ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                win.animator().setFrameOrigin(targetOrigin)
                win.animator().alphaValue = 0.0
            }, completionHandler: {
                win.orderOut(nil)
            })
        }
    }

    private func createHUDIfNeeded() {
        guard hudWindow == nil else { return }

        let width: CGFloat = 220
        let height: CGFloat = 40
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = height / 2.0
        visualEffect.layer?.masksToBounds = true
        visualEffect.layer?.borderWidth = 1.0
        visualEffect.layer?.borderColor = NSColor.white.withAlphaComponent(0.25).cgColor
        visualEffect.appearance = NSAppearance(named: .darkAqua)
        self.visualEffectView = visualEffect

        // Icon
        let icon = NSImageView(frame: NSRect(x: 14, y: (height - 24) / 2, width: 24, height: 24))
        icon.wantsLayer = true
        icon.imageScaling = .scaleProportionallyUpOrDown
        visualEffect.addSubview(icon)
        self.iconView = icon

        // Label
        let label = NSTextField(frame: NSRect(x: 46, y: (height - 20) / 2, width: width - 56, height: 20))
        label.isEditable = false
        label.isBordered = false
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.alignment = .left
        visualEffect.addSubview(label)
        self.titleLabel = label

        window.contentView = visualEffect
        self.hudWindow = window
    }

    private func animateAppearance() {
        guard let win = hudWindow, let screen = NSScreen.main else { return }
        let screenRect = screen.visibleFrame
        let targetX = screenRect.origin.x + (screenRect.width - win.frame.width) / 2
        let targetY = screen.frame.origin.y + screen.frame.height - win.frame.height - 10

        // Start slightly higher
        win.setFrameOrigin(NSPoint(x: targetX, y: targetY + 18))
        win.alphaValue = 0.0
        win.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            win.animator().setFrameOrigin(NSPoint(x: targetX, y: targetY))
            win.animator().alphaValue = 1.0
        }
    }

    private func startPulseAnimation() {
        guard let layer = iconView?.layer else { return }
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.15
        pulse.duration = 0.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "pulse")
    }

    private func stopPulseAnimation() {
        iconView?.layer?.removeAnimation(forKey: "pulse")
    }

    private func bounceIcon() {
        guard let layer = iconView?.layer else { return }
        let bounce = CAKeyframeAnimation(keyPath: "transform.scale")
        bounce.values = [1.0, 1.25, 0.95, 1.05, 1.0]
        bounce.duration = 0.4
        bounce.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(bounce, forKey: "bounce")
    }
}
