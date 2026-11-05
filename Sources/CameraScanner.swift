import Foundation
import AVFoundation
import Vision
import CoreImage
import AppKit

public final class CameraScanner: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public static let shared = CameraScanner()

    private let session = AVCaptureSession()
    private let cameraQueue = DispatchQueue(label: "io.github.facelock.cameraQueue", qos: .userInteractive)
    private var videoOutput: AVCaptureVideoDataOutput?
    private var isConfigured = false
    public private(set) var currentDeviceID: String?

    public static func availableCaptureDevices() -> [AVCaptureDevice] {
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        return discovery.devices
    }

    public static func selectDevice(preferredID: String) -> AVCaptureDevice? {
        let devices = availableCaptureDevices()
        let trimmed = preferredID.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed.lowercased() != "default" && trimmed.lowercased() != "auto" {
            if let matched = devices.first(where: { $0.uniqueID == trimmed }) {
                return matched
            }
            if let matchedName = devices.first(where: { $0.localizedName.localizedCaseInsensitiveContains(trimmed) }) {
                return matchedName
            }
        }
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video)
    }

    private var isScanning = false
    private var scanCompletion: ((Bool, Float?, NSImage?) -> Void)?
    private var scanTimer: DispatchSourceTimer?
    private var latestIntruderPhoto: NSImage?
    private var lastFrameSnapshot: NSImage?
    private var hasDetectedFaceInCurrentScan = false
    public private(set) var lastCandidateVector: [Float]?
    public private(set) var latestBestDistance: Float?
    public private(set) var latestSavedIntruderURL: URL?
    public var autoSaveIntruders: Bool = true
    private var lastShoulderAlertTime: Date = .distantPast

    public func clearCandidateFaceprint() {
        self.lastCandidateVector = nil
        self.latestBestDistance = nil
        self.latestSavedIntruderURL = nil
    }

    // Enrollment support
    public var enrollmentFrameHandler: ((CGImage, [VNFaceObservation]) -> Void)?

    private override init() {
        super.init()
    }

    public func prepare() {
        cameraQueue.async { [weak self] in
            self?.configureSessionIfNeeded()
        }
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .medium

        guard let device = CameraScanner.selectDevice(preferredID: Config.shared.preferredCameraID) else {
            print("[CameraScanner] No video camera found!")
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
                self.currentDeviceID = device.uniqueID
            }
        } catch {
            print("[CameraScanner] Failed to create device input: \(error)")
            session.commitConfiguration()
            return
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        output.setSampleBufferDelegate(self, queue: cameraQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
            self.videoOutput = output
        }

        session.commitConfiguration()
        isConfigured = true
    }

    public func reconfigureDeviceIfNeeded() {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            let preferredID = Config.shared.preferredCameraID
            guard let newDevice = CameraScanner.selectDevice(preferredID: preferredID) else { return }
            if self.currentDeviceID == newDevice.uniqueID && self.isConfigured {
                return
            }
            guard self.isConfigured else {
                self.configureSessionIfNeeded()
                return
            }
            self.session.beginConfiguration()
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            do {
                let input = try AVCaptureDeviceInput(device: newDevice)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.currentDeviceID = newDevice.uniqueID
                    print("[CameraScanner] Active camera set to: \(newDevice.localizedName) [\(newDevice.uniqueID)]")
                }
            } catch {
                print("[CameraScanner] Failed to switch camera input: \(error)")
            }
            self.session.commitConfiguration()
        }
    }

    public func scanFace(timeout: Double = 1.3, completion: @escaping (Bool, Float?, NSImage?) -> Void) {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            self.configureSessionIfNeeded()

            guard self.isConfigured else {
                DispatchQueue.main.async { completion(false, nil, nil) }
                return
            }

            if self.isScanning {
                let prev = self.scanCompletion
                self.scanCompletion = nil
                DispatchQueue.main.async {
                    prev?(false, nil, nil)
                }
            }

            self.isScanning = true
            self.scanCompletion = completion
            self.latestIntruderPhoto = nil
            self.lastFrameSnapshot = nil
            self.latestBestDistance = nil
            self.hasDetectedFaceInCurrentScan = false

            if !self.session.isRunning {
                self.session.startRunning()
            }

            // Set deadline timer
            self.scanTimer?.cancel()
            let timer = DispatchSource.makeTimerSource(queue: self.cameraQueue)
            timer.schedule(deadline: .now() + timeout)
            timer.setEventHandler { [weak self] in
                self?.handleScanTimeout()
            }
            self.scanTimer = timer
            timer.resume()
        }
    }

    private func handleScanTimeout() {
        guard isScanning else { return }
        isScanning = false
        scanTimer?.cancel()
        scanTimer = nil

        if session.isRunning {
            session.stopRunning()
        }

        // Only save intruder photo if an actual human face was detected and rejected.
        // If no face was seen (e.g. user walked away), do not treat empty frame as intruder.
        var intruderImage = self.latestIntruderPhoto
        if intruderImage == nil && self.hasDetectedFaceInCurrentScan {
            intruderImage = self.lastFrameSnapshot
        }
        if let photo = intruderImage, autoSaveIntruders {
            self.latestSavedIntruderURL = self.saveIntruderPhoto(photo)
        } else {
            self.latestSavedIntruderURL = nil
        }

        let bestDist = self.latestBestDistance
        let comp = scanCompletion
        scanCompletion = nil
        DispatchQueue.main.async {
            comp?(false, bestDist, intruderImage)
        }
    }

    private func handleScanSuccess(distance: Float?) {
        guard isScanning else { return }
        isScanning = false
        scanTimer?.cancel()
        scanTimer = nil
        latestIntruderPhoto = nil
        lastFrameSnapshot = nil
        latestBestDistance = nil
        latestSavedIntruderURL = nil

        if session.isRunning {
            session.stopRunning()
        }

        let comp = scanCompletion
        scanCompletion = nil
        DispatchQueue.main.async {
            comp?(true, distance, nil)
        }
    }

    public func stop() {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            self.scanTimer?.cancel()
            self.scanTimer = nil
            self.enrollmentFrameHandler = nil
            self.latestIntruderPhoto = nil
            self.lastFrameSnapshot = nil
            self.latestBestDistance = nil
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        if let enrollHandler = enrollmentFrameHandler {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let faceReq = VNDetectFaceRectanglesRequest()
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
                try? handler.perform([faceReq])
                let faces = faceReq.results ?? []
                DispatchQueue.main.async {
                    enrollHandler(cgImage, faces)
                }
            }
            return
        }

        guard isScanning else { return }

        if self.lastFrameSnapshot == nil {
            self.lastFrameSnapshot = self.fullSnapshot(from: pixelBuffer)
        }

        let faceReq = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([faceReq])
        } catch {
            return
        }

        var faces = faceReq.results ?? []

        if faces.isEmpty {
            let ci = CIImage(cvPixelBuffer: pixelBuffer)
            if let exp = CIFilter(name: "CIExposureAdjust") {
                exp.setValue(ci, forKey: kCIInputImageKey)
                exp.setValue(1.5, forKey: kCIInputEVKey)
                if let boosted = exp.outputImage {
                    let lowLightReq = VNDetectFaceRectanglesRequest()
                    let lowLightHandler = VNImageRequestHandler(ciImage: boosted, options: [:])
                    try? lowLightHandler.perform([lowLightReq])
                    faces = lowLightReq.results ?? []
                }
            }
        }

        guard !faces.isEmpty else { return }
        self.hasDetectedFaceInCurrentScan = true

        let enrolled = Config.shared.loadEnrolledVectors()
        let isStrict = Config.shared.strictFaceMatch && !enrolled.isEmpty

        if !isStrict {
            handleScanSuccess(distance: 0.0)
            return
        }

        // Sort faces by bounding box area (largest / most prominent foreground face first)
        let sortedFaces = faces.sorted {
            ($0.boundingBox.width * $0.boundingBox.height) > ($1.boundingBox.width * $1.boundingBox.height)
        }

        // Run anti-spoofing quality assessment if liveness detection is enabled
        if Config.shared.livenessDetectionEnabled {
            let qualityReq = VNDetectFaceCaptureQualityRequest()
            qualityReq.inputFaceObservations = sortedFaces
            try? handler.perform([qualityReq])
        }

        let th = Config.shared.similarityThreshold

        for face in sortedFaces {
            // Anti-spoofing check: filter out extreme motion blur or low-quality planar captures
            if Config.shared.livenessDetectionEnabled, let quality = face.faceCaptureQuality, quality < 0.18 {
                print("[CameraScanner] Anti-spoofing: skipping low-quality candidate (score: \(String(format: "%.3f", quality)))")
                continue
            }

            if let (candidateVec, faceObs) = FaceprintExtractor.shared.extractVector(from: pixelBuffer, faceObservation: face) {
                if self.lastCandidateVector == nil {
                    self.lastCandidateVector = candidateVec
                }

                if self.latestIntruderPhoto == nil {
                    self.latestIntruderPhoto = self.cropFace(from: pixelBuffer, boundingBox: faceObs.boundingBox)
                }

                let sortedDists = enrolled.map { FaceprintExtractor.cosineDistance(candidateVec, $0) }.sorted()
                let minDistance = sortedDists.first ?? 100.0
                if self.latestBestDistance == nil || minDistance < self.latestBestDistance! {
                    self.latestBestDistance = minDistance
                }
                let top3Distance = sortedDists.count >= 3 ? (sortedDists[0] + sortedDists[1] + sortedDists[2]) / 3.0 : minDistance

                let isOwnerMatch = minDistance <= th && (enrolled.count < 3 || top3Distance <= (th + 0.05))

                print("[CameraScanner] Face verification: min=\(String(format: "%.4f", minDistance)), top3=\(String(format: "%.4f", top3Distance)) (th: \(th)) -> \(isOwnerMatch ? "OWNER MATCH ✅" : "INTRUDER REJECTED 🛡️")")

                if isOwnerMatch {
                    // Matching owner face found! Check for shoulder-surfing if multiple faces are in frame
                    if sortedFaces.count > 1 && Config.shared.shoulderSurfingDefense {
                        let otherFaces = sortedFaces.filter { $0 != face }
                        var unauthorizedBystander = false
                        var primaryBystanderFace: VNFaceObservation? = nil
                        for other in otherFaces {
                            if let (otherVec, _) = FaceprintExtractor.shared.extractVector(from: pixelBuffer, faceObservation: other) {
                                let otherMinDist = enrolled.map { FaceprintExtractor.cosineDistance(otherVec, $0) }.min() ?? 100.0
                                if otherMinDist > th {
                                    unauthorizedBystander = true
                                    primaryBystanderFace = other
                                    break
                                }
                            } else {
                                unauthorizedBystander = true
                                primaryBystanderFace = other
                                break
                            }
                        }

                        if unauthorizedBystander {
                            print("[CameraScanner] ⚠️ Shoulder-Surfing Alert: unauthorized bystander detected behind owner!")
                            SecurityAuditLogger.shared.logShoulderSurfingDetected(secondaryCount: otherFaces.count)
                            HUDController.shared.showShoulderSurfingAlert()

                            let now = Date()
                            if now.timeIntervalSince(self.lastShoulderAlertTime) >= 45.0 {
                                self.lastShoulderAlertTime = now
                                let targetFace = primaryBystanderFace ?? otherFaces.first!
                                if let bystanderPhoto = self.cropFace(from: pixelBuffer, boundingBox: targetFace.boundingBox) {
                                    if self.autoSaveIntruders {
                                        _ = self.saveIntruderPhoto(bystanderPhoto, prefix: "bystander")
                                    }
                                    if Config.shared.telegramEnabled {
                                        TelegramNotifier.shared.sendBystanderAlert(photo: bystanderPhoto, bystanderCount: otherFaces.count)
                                    }
                                }
                            }
                        }
                    }

                    handleScanSuccess(distance: minDistance)
                    return
                }
            }
        }
    }

    // MARK: - Intruder Cropping and Image Enhancement
    private func cropFace(from pixelBuffer: CVPixelBuffer, boundingBox: CGRect) -> NSImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let extent = ciImage.extent

        // Normalized coordinates with origin at bottom-left in Vision and Core Image
        let faceRect = CGRect(
            x: boundingBox.origin.x * extent.width,
            y: boundingBox.origin.y * extent.height,
            width: boundingBox.width * extent.width,
            height: boundingBox.height * extent.height
        )

        // Perfectly centered square with 80% generous headroom for hair and shoulders
        let side = min(max(faceRect.width, faceRect.height) * 1.85, min(extent.width, extent.height))
        var originX = faceRect.midX - side / 2
        var originY = faceRect.midY - side / 2
        if originX < 0 { originX = 0 }
        if originY < 0 { originY = 0 }
        if originX + side > extent.width { originX = extent.width - side }
        if originY + side > extent.height { originY = extent.height - side }

        let squareRect = CGRect(x: originX, y: originY, width: side, height: side)
        let cropped = ciImage.cropped(to: squareRect)

        // Apply Night-Mode / Brightness / Shadow enhancement
        let enhanced = enhancePhoto(cropped)

        let context = CIContext()
        guard let cgImage = context.createCGImage(enhanced, from: enhanced.extent) else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }

    private func fullSnapshot(from pixelBuffer: CVPixelBuffer) -> NSImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let enhanced = enhancePhoto(ciImage)
        let context = CIContext()
        guard let cgImage = context.createCGImage(enhanced, from: enhanced.extent) else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }

    private func enhancePhoto(_ input: CIImage) -> CIImage {
        var output = input

        // Lift shadows and normalize exposure for dark ambient environments
        if let expFilter = CIFilter(name: "CIExposureAdjust") {
            expFilter.setValue(output, forKey: kCIInputImageKey)
            expFilter.setValue(1.3, forKey: kCIInputEVKey)
            if let res = expFilter.outputImage { output = res }
        }

        if let shadowFilter = CIFilter(name: "CIHighlightShadowAdjust") {
            shadowFilter.setValue(output, forKey: kCIInputImageKey)
            shadowFilter.setValue(0.95, forKey: "inputShadowAmount")
            shadowFilter.setValue(0.85, forKey: "inputHighlightAmount")
            if let res = shadowFilter.outputImage { output = res }
        }

        let autoFilters = output.autoAdjustmentFilters(options: [
            .enhance: true,
            .redEye: false
        ])
        for filter in autoFilters {
            filter.setValue(output, forKey: kCIInputImageKey)
            if let res = filter.outputImage { output = res }
        }

        if let colorFilter = CIFilter(name: "CIColorControls") {
            colorFilter.setValue(output, forKey: kCIInputImageKey)
            colorFilter.setValue(1.18, forKey: kCIInputContrastKey)
            colorFilter.setValue(1.15, forKey: kCIInputSaturationKey)
            if let res = colorFilter.outputImage { output = res }
        }

        return output
    }

    @discardableResult
    public func saveIntruderPhoto(_ image: NSImage, prefix: String = "intruder") -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let entropy = UUID().uuidString.prefix(6)
        let filename = "\(prefix)_\(formatter.string(from: Date()))_\(entropy).jpg"
        let url = dir.appendingPathComponent(filename)

        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else {
            return nil
        }
        try? jpeg.write(to: url)
        print("[CameraScanner] Capture photo saved (\(prefix)): \(url.path)")
        pruneOldIntruderPhotos(in: dir, maxRetained: 150)
        return url
    }

    public static let supportedIncidentTypes: [String] = [
        "intruder",
        "walkaway",
        "wake",
        "bystander",
        "bruteforce"
    ]

    public static func isValidIncidentType(_ type: String) -> Bool {
        let normalized = type.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "all" || normalized == "shoulder" || normalized == "shoulder_surfing" {
            return true
        }
        return supportedIncidentTypes.contains(normalized)
    }

    public static func incidentType(for filename: String) -> String {
        if filename.hasPrefix("bystander_") {
            return "bystander"
        } else if filename.hasPrefix("walkaway_") {
            return "walkaway"
        } else if filename.hasPrefix("wake_") {
            return "wake"
        } else if filename.hasPrefix("bruteforce_") {
            return "bruteforce"
        } else {
            return "intruder"
        }
    }

    public struct IncidentRecord {
        public let filename: String
        public let path: String
        public let sizeBytes: UInt64
        public let type: String
        public let timestamp: String

        public func toDictionary() -> [String: Any] {
            return [
                "filename": filename,
                "path": path,
                "sizeBytes": sizeBytes,
                "type": type,
                "timestamp": timestamp
            ]
        }
    }

    public static func matchesIncidentQuery(filename: String, query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return true }
        if filename.lowercased().contains(q) { return true }
        let incType = incidentType(for: filename).lowercased()
        if incType.contains(q) { return true }
        if (q == "shoulder" || q == "shoulder_surfing") && incType == "bystander" { return true }
        return false
    }

    public struct IncidentStats {
        public let totalCaptures: Int
        public let totalSizeBytes: UInt64
        public let todayCount: Int
        public let past24HoursCount: Int
        public let past7DaysCount: Int
        public let newestIncidentTimestamp: String?
        public let oldestIncidentTimestamp: String?
        public let typeBreakdown: [String: Int]
        public let averageSizeBytes: Double
        public let directory: String
        public let largestIncidentFilename: String?
        public let largestIncidentSizeBytes: UInt64

        public func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [
                "totalCaptures": totalCaptures,
                "totalSizeBytes": totalSizeBytes,
                "todayCount": todayCount,
                "past24HoursCount": past24HoursCount,
                "past7DaysCount": past7DaysCount,
                "typeBreakdown": typeBreakdown,
                "averageSizeBytes": averageSizeBytes,
                "directory": directory,
                "largestIncidentSizeBytes": largestIncidentSizeBytes
            ]
            if let newest = newestIncidentTimestamp { dict["newestIncidentTimestamp"] = newest }
            if let oldest = oldestIncidentTimestamp { dict["oldestIncidentTimestamp"] = oldest }
            if let largest = largestIncidentFilename { dict["largestIncidentFilename"] = largest }
            return dict
        }
    }

    public func getIncidentDetails(filename: String) -> IncidentRecord? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        let fileURL = dir.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        var sz: UInt64 = 0
        var modDateStr = ""
        if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
            sz = (attrs[.size] as? UInt64) ?? 0
            if let modDate = attrs[.modificationDate] as? Date {
                modDateStr = ISO8601DateFormatter().string(from: modDate)
            }
        }
        let incType = CameraScanner.incidentType(for: filename)
        return IncidentRecord(
            filename: filename,
            path: fileURL.path,
            sizeBytes: sz,
            type: incType,
            timestamp: modDateStr
        )
    }

    public func searchIncidents(query: String? = nil, filterType: String? = nil, limit: Int? = nil) -> [IncidentRecord] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        var files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted(by: >)

        if let filter = filterType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !filter.isEmpty && filter != "all" {
            let now = Date()
            files = files.filter { f in
                let p = dir.appendingPathComponent(f).path
                let modDate = (try? FileManager.default.attributesOfItem(atPath: p)[.modificationDate] as? Date) ?? .distantPast
                let ageSeconds = now.timeIntervalSince(modDate)
                switch filter {
                case "shoulder", "shoulder_surfing", "bystander", "bystanders":
                    return f.hasPrefix("bystander_")
                case "intruder", "intruders":
                    return f.hasPrefix("intruder_")
                case "walkaway", "walk_away":
                    return f.hasPrefix("walkaway_")
                case "wake":
                    return f.hasPrefix("wake_")
                case "bruteforce", "pin":
                    return f.hasPrefix("bruteforce_")
                case "24h", "today":
                    return ageSeconds <= 86400
                case "7d", "week":
                    return ageSeconds <= 7 * 86400
                default:
                    return f.lowercased().contains(filter)
                }
            }
        }

        if let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            files = files.filter { CameraScanner.matchesIncidentQuery(filename: $0, query: q) }
        }

        if let lim = limit, lim > 0 {
            files = Array(files.prefix(lim))
        }

        var results: [IncidentRecord] = []
        results.reserveCapacity(files.count)
        for f in files {
            if let details = getIncidentDetails(filename: f) {
                results.append(details)
            }
        }
        return results
    }

    public func getDetailedIncidentStats() -> IncidentStats {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted(by: >)

        var totalBytes: UInt64 = 0
        var past24HoursCount = 0
        var past7DaysCount = 0
        var todayCount = 0
        var newestTimestamp: String? = nil
        var oldestTimestamp: String? = nil
        var typeBreakdown: [String: Int] = [:]
        var maxCaptureSize: UInt64 = 0
        var largestFilename: String? = nil

        let now = Date()
        let calendar = Calendar.current
        let oneDayAgo = now.addingTimeInterval(-86400)
        let sevenDaysAgo = now.addingTimeInterval(-7 * 86400)
        let startOfToday = calendar.startOfDay(for: now)

        for (index, f) in files.enumerated() {
            let p = dir.appendingPathComponent(f).path
            let incType = CameraScanner.incidentType(for: f)
            typeBreakdown[incType, default: 0] += 1

            if let attrs = try? FileManager.default.attributesOfItem(atPath: p) {
                if let sz = attrs[.size] as? UInt64 {
                    totalBytes += sz
                    if sz > maxCaptureSize {
                        maxCaptureSize = sz
                        largestFilename = f
                    }
                }
                if let modDate = attrs[.modificationDate] as? Date {
                    let iso = ISO8601DateFormatter().string(from: modDate)
                    if index == 0 {
                        newestTimestamp = iso
                    }
                    if index == files.count - 1 {
                        oldestTimestamp = iso
                    }
                    if modDate >= oneDayAgo {
                        past24HoursCount += 1
                    }
                    if modDate >= startOfToday {
                        todayCount += 1
                    }
                    if modDate >= sevenDaysAgo {
                        past7DaysCount += 1
                    }
                }
            }
        }

        let avgBytes = files.isEmpty ? 0.0 : Double(totalBytes) / Double(files.count)
        return IncidentStats(
            totalCaptures: files.count,
            totalSizeBytes: totalBytes,
            todayCount: todayCount,
            past24HoursCount: past24HoursCount,
            past7DaysCount: past7DaysCount,
            newestIncidentTimestamp: newestTimestamp,
            oldestIncidentTimestamp: oldestTimestamp,
            typeBreakdown: typeBreakdown,
            averageSizeBytes: avgBytes,
            directory: dir.path,
            largestIncidentFilename: largestFilename,
            largestIncidentSizeBytes: maxCaptureSize
        )
    }

    @discardableResult
    public func clearIncidents(filterType: String? = nil) -> (deletedCount: Int, freedBytes: UInt64) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)

        let normalizedFilter: String?
        if let f = filterType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !f.isEmpty && f != "all" {
            if f == "shoulder" || f == "shoulder_surfing" {
                normalizedFilter = "bystander"
            } else {
                normalizedFilter = f
            }
        } else {
            normalizedFilter = nil
        }

        var deletedCount = 0
        var freedBytes: UInt64 = 0

        guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else {
            return (0, 0)
        }

        var jpegs = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
        if let filter = normalizedFilter {
            jpegs = jpegs.filter { CameraScanner.incidentType(for: $0) == filter }
        }

        for f in jpegs {
            let p = dir.appendingPathComponent(f).path
            if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
               let sz = attrs[.size] as? UInt64 {
                freedBytes += sz
            }
            if (try? FileManager.default.removeItem(atPath: p)) != nil {
                deletedCount += 1
            }
        }

        let actionDesc = normalizedFilter != nil
            ? "Purged \(normalizedFilter!) intruder incident captures via CLI"
            : "Purged all intruder incident captures via CLI"
        SecurityAuditLogger.shared.logIncidentsAction(action: actionDesc, count: deletedCount)
        return (deletedCount, freedBytes)
    }

    @discardableResult
    public func pruneIntruderPhotos(maxRetained: Int = 150) -> Int {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        return pruneOldIntruderPhotos(in: dir, maxRetained: maxRetained)
    }

    @discardableResult
    public func pruneIncidentsOlderThan(days: Int) -> (removedCount: Int, remainingCount: Int, freedBytes: UInt64) {
        guard days >= 0 else { return (0, 0, 0) }
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return (0, 0, 0) }
        let jpegs = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
        let cutoff = Date().addingTimeInterval(-Double(days) * 86400.0)
        var removedCount = 0
        var remainingCount = 0
        var freedBytes: UInt64 = 0

        for file in jpegs {
            let fileURL = dir.appendingPathComponent(file)
            if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
                let modDate = (attrs[.modificationDate] as? Date) ?? Date()
                let size = (attrs[.size] as? UInt64) ?? 0
                if modDate < cutoff {
                    if (try? FileManager.default.removeItem(at: fileURL)) != nil {
                        removedCount += 1
                        freedBytes += size
                    } else {
                        remainingCount += 1
                    }
                } else {
                    remainingCount += 1
                }
            } else {
                remainingCount += 1
            }
        }
        if removedCount > 0 {
            SecurityAuditLogger.shared.logIncidentsAction(action: "Pruned incidents older than \(days) day(s)", count: removedCount)
        }
        return (removedCount, remainingCount, freedBytes)
    }

    public func exportIncidents(to destinationPath: String, filterType: String? = nil) throws -> [String: Any] {
        let expanded = NSString(string: destinationPath).expandingTildeInPath
        let destURL = URL(fileURLWithPath: expanded)

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: destURL.path) {
            try fileManager.createDirectory(at: destURL, withIntermediateDirectories: true)
        }

        let home = fileManager.homeDirectoryForCurrentUser
        let sourceDir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)

        let normalizedFilter: String?
        if let f = filterType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !f.isEmpty && f != "all" {
            if f == "shoulder" || f == "shoulder_surfing" {
                normalizedFilter = "bystander"
            } else {
                normalizedFilter = f
            }
        } else {
            normalizedFilter = nil
        }

        guard let files = try? fileManager.contentsOfDirectory(atPath: sourceDir.path) else {
            return [
                "count": 0,
                "totalBytes": UInt64(0),
                "filter": normalizedFilter ?? "all",
                "typeBreakdown": [String: Int](),
                "destination": destURL.path,
                "manifestPath": ""
            ]
        }

        var jpegFiles = files.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }.sorted()
        if let filter = normalizedFilter {
            jpegFiles = jpegFiles.filter { CameraScanner.incidentType(for: $0) == filter }
        }

        var manifestEntries: [[String: Any]] = []
        var totalBytes: UInt64 = 0
        var exportedCount = 0
        var typeBreakdown: [String: Int] = [:]

        for file in jpegFiles {
            let srcFile = sourceDir.appendingPathComponent(file)
            let dstFile = destURL.appendingPathComponent(file)

            if fileManager.fileExists(atPath: dstFile.path) {
                try? fileManager.removeItem(at: dstFile)
            }

            try fileManager.copyItem(at: srcFile, to: dstFile)
            exportedCount += 1

            let incType = CameraScanner.incidentType(for: file)
            typeBreakdown[incType, default: 0] += 1

            var size: UInt64 = 0
            var modDate = ""
            if let attrs = try? fileManager.attributesOfItem(atPath: dstFile.path) {
                size = attrs[.size] as? UInt64 ?? 0
                totalBytes += size
                if let date = attrs[.modificationDate] as? Date {
                    modDate = ISO8601DateFormatter().string(from: date)
                }
            }
            manifestEntries.append([
                "filename": file,
                "type": incType,
                "sizeBytes": size,
                "modified": modDate
            ])
        }

        let manifestURL = destURL.appendingPathComponent("incidents_manifest.json")
        let manifestData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalCount": exportedCount,
            "totalBytes": totalBytes,
            "filter": normalizedFilter ?? "all",
            "typeBreakdown": typeBreakdown,
            "incidents": manifestEntries
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: manifestData, options: [.prettyPrinted, .sortedKeys])
        try jsonData.write(to: manifestURL, options: .atomic)

        return [
            "count": exportedCount,
            "totalBytes": totalBytes,
            "filter": normalizedFilter ?? "all",
            "typeBreakdown": typeBreakdown,
            "destination": destURL.path,
            "manifestPath": manifestURL.path
        ]
    }

    @discardableResult
    private func pruneOldIntruderPhotos(in dir: URL, maxRetained: Int) -> Int {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return 0 }
        let jpegs = files
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
            .sorted(by: >)
        var removedCount = 0
        if jpegs.count > maxRetained {
            for oldFile in jpegs.suffix(from: maxRetained) {
                if (try? FileManager.default.removeItem(at: dir.appendingPathComponent(oldFile))) != nil {
                    removedCount += 1
                }
            }
        }
        return removedCount
    }

    // MARK: - Capture Faceprints for Enrollment
    public func startEnrollment(frameCallback: @escaping (CGImage, [VNFaceObservation]) -> Void) {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            self.configureSessionIfNeeded()
            self.isScanning = false
            self.enrollmentFrameHandler = frameCallback
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    public func extractFaceVector(from pixelBuffer: CVPixelBuffer) -> [Float]? {
        return FaceprintExtractor.shared.extractVector(from: pixelBuffer)?.0
    }
}
