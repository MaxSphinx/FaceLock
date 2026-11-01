import Foundation
import Vision
import CoreVideo
import AppKit
import Accelerate

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
        var dot: Float = 0.0
        var normA: Float = 0.0
        var normB: Float = 0.0
        vDSP_dotpr(a, 1, b, 1, &dot, vDSP_Length(a.count))
        vDSP_svesq(a, 1, &normA, vDSP_Length(a.count))
        vDSP_svesq(b, 1, &normB, vDSP_Length(b.count))
        let denom = sqrt(normA) * sqrt(normB)
        if denom == 0.0 { return 1.0 }
        let sim = max(-1.0, min(1.0, dot / denom))
        return 1.0 - sim
    }
}
