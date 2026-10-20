import AppKit
import AVFoundation
import Vision

public final class EnrollmentController: NSObject {
    public static let shared = EnrollmentController()

    private var window: NSWindow?
    private var previewImageView: NSImageView?
    private var statusLabel: NSTextField?
    private var actionButton: NSButton?
    private var progressIndicator: NSProgressIndicator?

    private var capturedVectors: [[Float]] = []
    private var isCapturing = false
    private let targetSampleCount = 12
    private var lastSampleTime: Date = .distantPast

    private override init() {
        super.init()
    }

    public func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.createWindowIfNeeded()
            self.capturedVectors.removeAll()
            self.isCapturing = false
            self.lastSampleTime = .distantPast
            self.progressIndicator?.doubleValue = 0.0
            self.statusLabel?.stringValue = "Расположитесь перед камерой и нажмите «Начать сканирование»"
            self.actionButton?.title = "Начать сканирование"
            self.actionButton?.isEnabled = true

            self.window?.center()
            self.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)

            // Start live preview
            CameraScanner.shared.startEnrollment { [weak self] cgImage, faces in
                self?.handleFrame(cgImage, faces: faces)
            }
        }
    }

    public func close() {
        CameraScanner.shared.stop()
        window?.orderOut(nil)
    }

    private func createWindowIfNeeded() {
        guard window == nil else { return }

        let width: CGFloat = 460
        let height: CGFloat = 530

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "Калибровка Face ID"
        win.isReleasedWhenClosed = false

        let content = NSView(frame: win.contentView!.bounds)
        content.wantsLayer = true

        let title = NSTextField(frame: NSRect(x: 20, y: height - 50, width: width - 40, height: 26))
        title.isEditable = false
        title.isBordered = false
        title.backgroundColor = .clear
        title.stringValue = "Запоминание лица владельца (3D калибровка)"
        title.font = .systemFont(ofSize: 18, weight: .bold)
        title.alignment = .center
        content.addSubview(title)

        let subtitle = NSTextField(frame: NSRect(x: 20, y: height - 85, width: width - 40, height: 30))
        subtitle.isEditable = false
        subtitle.isBordered = false
        subtitle.backgroundColor = .clear
        subtitle.textColor = .secondaryLabelColor
        subtitle.stringValue = "Система запишет ваше лицо под разными углами"
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.alignment = .center
        content.addSubview(subtitle)

        let previewSize: CGFloat = 260
        let previewX = (width - previewSize) / 2
        let previewY = height - 95 - previewSize
        let preview = NSImageView(frame: NSRect(x: previewX, y: previewY, width: previewSize, height: previewSize))
        preview.wantsLayer = true
        preview.layer?.cornerRadius = previewSize / 2
        preview.layer?.masksToBounds = true
        preview.layer?.borderWidth = 3.5
        preview.layer?.borderColor = NSColor.systemCyan.cgColor
        preview.imageScaling = .scaleProportionallyUpOrDown
        content.addSubview(preview)
        self.previewImageView = preview

        let status = NSTextField(frame: NSRect(x: 20, y: previewY - 35, width: width - 40, height: 24))
        status.isEditable = false
        status.isBordered = false
        status.backgroundColor = .clear
        status.font = .systemFont(ofSize: 13, weight: .semibold)
        status.alignment = .center
        content.addSubview(status)
        self.statusLabel = status

        let progress = NSProgressIndicator(frame: NSRect(x: (width - 260) / 2, y: previewY - 65, width: 260, height: 16))
        progress.isIndeterminate = false
        progress.minValue = 0
        progress.maxValue = Double(targetSampleCount)
        content.addSubview(progress)
        self.progressIndicator = progress

        let btn = NSButton(frame: NSRect(x: (width - 200) / 2, y: 20, width: 200, height: 38))
        btn.bezelStyle = .rounded
        btn.title = "Начать сканирование"
        btn.target = self
        btn.action = #selector(onActionClicked)
        content.addSubview(btn)
        self.actionButton = btn

        win.contentView = content
        self.window = win
    }

    @objc private func onActionClicked() {
        if capturedVectors.count >= targetSampleCount {
            close()
            return
        }

        isCapturing = true
        actionButton?.isEnabled = false
        lastSampleTime = .distantPast
        statusLabel?.stringValue = "Смотрите прямо в камеру..."
    }

    private func handleFrame(_ cgImage: CGImage, faces: [VNFaceObservation]) {
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        self.previewImageView?.image = nsImage

        if faces.isEmpty {
            if !isCapturing {
                statusLabel?.stringValue = "Лицо не видно перед камерой"
                previewImageView?.layer?.borderColor = NSColor.systemRed.cgColor
            }
            return
        } else {
            if !isCapturing && capturedVectors.isEmpty {
                statusLabel?.stringValue = "Лицо обнаружено! Нажмите «Начать сканирование»"
                previewImageView?.layer?.borderColor = NSColor.systemGreen.cgColor
            }
        }

        guard isCapturing, !faces.isEmpty else { return }

        // Throttle captures by 0.35s to allow user to tilt/turn head
        let now = Date()
        guard now.timeIntervalSince(lastSampleTime) >= 0.35 else { return }
        lastSampleTime = now

        // Extract 128-D Apple Neural Faceprint
        if let (vec, _) = FaceprintExtractor.shared.extractVector(from: cgImage, faceObservation: faces.first) {
            capturedVectors.append(vec)
            progressIndicator?.doubleValue = Double(capturedVectors.count)

            // Dynamic guidance based on progress
            let count = capturedVectors.count
            if count <= 3 {
                statusLabel?.stringValue = "[\(count)/\(targetSampleCount)] Смотрите прямо в камеру..."
            } else if count <= 6 {
                statusLabel?.stringValue = "[\(count)/\(targetSampleCount)] Слегка поверните голову влево..."
            } else if count <= 9 {
                statusLabel?.stringValue = "[\(count)/\(targetSampleCount)] Слегка поверните голову вправо..."
            } else if count < targetSampleCount {
                statusLabel?.stringValue = "[\(count)/\(targetSampleCount)] Немного наклоните голову вверх или вниз..."
            }

            if count >= targetSampleCount {
                // Complete!
                isCapturing = false
                Config.shared.saveEnrolledVectors(capturedVectors)
                Config.shared.strictFaceMatch = true
                Config.shared.save()

                statusLabel?.stringValue = "✓ Откалибровано 12 ракурсов лица! Защита активна."
                previewImageView?.layer?.borderColor = NSColor.systemGreen.cgColor
                actionButton?.title = "Готово"
                actionButton?.isEnabled = true
            }
        }
    }
}
