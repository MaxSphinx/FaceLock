import Foundation
import Vision
import CoreVideo
import AppKit

public final class FaceprintExtractor {
    public static let shared = FaceprintExtractor()

    private let reqClass: VNImageBasedRequest.Type? = NSClassFromString("VNCreateFaceprintRequest") as? VNImageBasedRequest.Type

    private init() {}

    public func extractVector(from pixelBuffer: CVPixelBuffer, faceObservation: VNFaceObservation? = nil) -> ([Float], VNFaceObservation)? {
        guard let reqClass = reqClass else { return nil }
        let req = reqClass.init()
        if let face = faceObservation {
            req.setValue([face], forKey: "inputFaceObservations")
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([req])
        } catch {
            return nil
        }

        guard let faceObs = req.results?.first as? VNFaceObservation,
              let fp = (faceObs as AnyObject).value(forKey: "faceprint") as AnyObject?,
              let data = fp.value(forKey: "descriptorData") as? Data else {
            return nil
        }

        let floats = data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
        guard floats.count == 128 else { return nil }
        return (floats, faceObs)
    }

    public func extractVector(from cgImage: CGImage, faceObservation: VNFaceObservation? = nil) -> ([Float], VNFaceObservation)? {
        guard let reqClass = reqClass else { return nil }
        let req = reqClass.init()
        if let face = faceObservation {
            req.setValue([face], forKey: "inputFaceObservations")
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([req])
        } catch {
            return nil
        }

        guard let faceObs = req.results?.first as? VNFaceObservation,
              let fp = (faceObs as AnyObject).value(forKey: "faceprint") as AnyObject?,
              let data = fp.value(forKey: "descriptorData") as? Data else {
            return nil
        }

        let floats = data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
        guard floats.count == 128 else { return nil }
        return (floats, faceObs)
    }

    public static func cosineDistance(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 1.0 }
        var dot: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        let denom = sqrt(normA) * sqrt(normB)
        return denom > 0 ? (1.0 - (dot / denom)) : 1.0
    }
}
