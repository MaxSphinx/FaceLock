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

    private var isScanning = false
    private var scanCompletion: ((Bool, Float?, NSImage?) -> Void)?
    private var scanTimer: DispatchSourceTimer?
    private var latestIntruderPhoto: NSImage?
    private var lastFrameSnapshot: NSImage?
    public private(set) var lastCandidateVector: [Float]?

    public func clearCandidateFaceprint() {
        self.lastCandidateVector = nil
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

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video) else {
            print("[CameraScanner] No video camera found!")
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
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

    public func scanFace(timeout: Double = 1.3, completion: @escaping (Bool, Float?, NSImage?) -> Void) {
        cameraQueue.async { [weak self] in
            guard let self = self else { return }
            self.configureSessionIfNeeded()

            guard self.isConfigured else {
                DispatchQueue.main.async { completion(false, nil, nil) }
                return
            }

            self.isScanning = true
            self.scanCompletion = completion
            self.latestIntruderPhoto = nil
            self.lastFrameSnapshot = nil

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
        let intruderImage = self.latestIntruderPhoto
        if let photo = intruderImage {
            self.saveIntruderPhoto(photo)
        }

        let comp = scanCompletion
        scanCompletion = nil
        DispatchQueue.main.async {
            comp?(false, nil, intruderImage)
        }
    }

    private func handleScanSuccess(distance: Float?) {
        guard isScanning else { return }
        isScanning = false
        scanTimer?.cancel()
        scanTimer = nil
        latestIntruderPhoto = nil
        lastFrameSnapshot = nil

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

        let enrolled = Config.shared.loadEnrolledVectors()
        let isStrict = Config.shared.strictFaceMatch && !enrolled.isEmpty

        if !isStrict {
            handleScanSuccess(distance: 0.0)
            return
        }

        let targetFace = faces.first
        if let (candidateVec, faceObs) = FaceprintExtractor.shared.extractVector(from: pixelBuffer, faceObservation: targetFace) {
            self.lastCandidateVector = candidateVec

            if self.latestIntruderPhoto == nil {
                self.latestIntruderPhoto = self.cropFace(from: pixelBuffer, boundingBox: faceObs.boundingBox)
            }

            let sortedDists = enrolled.map { FaceprintExtractor.cosineDistance(candidateVec, $0) }.sorted()
            let minDistance = sortedDists.first ?? 100.0
            let top3Distance = sortedDists.count >= 3 ? (sortedDists[0] + sortedDists[1] + sortedDists[2]) / 3.0 : minDistance
            let th = Config.shared.similarityThreshold

            let isOwnerMatch = minDistance <= th && (enrolled.count < 3 || top3Distance <= (th + 0.05))

            print("[CameraScanner] Face verification: min=\(String(format: "%.4f", minDistance)), top3=\(String(format: "%.4f", top3Distance)) (th: \(th)) -> \(isOwnerMatch ? "OWNER MATCH ✅" : "INTRUDER REJECTED 🛡️")")

            if isOwnerMatch {
                // Matching owner face found!
                handleScanSuccess(distance: minDistance)
                return
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
    public func saveIntruderPhoto(_ image: NSImage) -> URL? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let entropy = UUID().uuidString.prefix(6)
        let filename = "intruder_\(formatter.string(from: Date()))_\(entropy).jpg"
        let url = dir.appendingPathComponent(filename)

        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else {
            return nil
        }
        try? jpeg.write(to: url)
        print("[CameraScanner] Intruder photo saved: \(url.path)")
        pruneOldIntruderPhotos(in: dir, maxRetained: 150)
        return url
    }

    @discardableResult
    public func pruneIntruderPhotos(maxRetained: Int = 150) -> Int {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        return pruneOldIntruderPhotos(in: dir, maxRetained: maxRetained)
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
