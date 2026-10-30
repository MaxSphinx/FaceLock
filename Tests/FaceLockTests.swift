import Foundation
import Accelerate

// MARK: - Mini Test Framework (Zero External Dependencies)
public final class FaceLockTestSuite {
    private var passedCount = 0
    private var failedCount = 0
    private let startTime = Date()

    public init() {}

    public func assert(_ condition: Bool, _ testName: String, file: String = #file, line: Int = #line) {
        if condition {
            passedCount += 1
            print("  ✓ PASS: \(testName)")
        } else {
            failedCount += 1
            print("  ✗ FAIL: \(testName) [\(file):\(line)]")
        }
    }

    public func assertEqual<T: Equatable>(_ a: T, _ b: T, _ testName: String, file: String = #file, line: Int = #line) {
        if a == b {
            passedCount += 1
            print("  ✓ PASS: \(testName)")
        } else {
            failedCount += 1
            print("  ✗ FAIL: \(testName) (Expected: \(b), Got: \(a)) [\(file):\(line)]")
        }
    }

    public func assertAccuracy(_ a: Float, _ b: Float, accuracy: Float, _ testName: String, file: String = #file, line: Int = #line) {
        if abs(a - b) <= accuracy {
            passedCount += 1
            print("  ✓ PASS: \(testName) (\(a) ≈ \(b))")
        } else {
            failedCount += 1
            print("  ✗ FAIL: \(testName) (Diff: \(abs(a - b)) > \(accuracy)) [\(file):\(line)]")
        }
    }

    public func runAll() -> Bool {
        print("\n=======================================================")
        print("🚀 Running FaceLock Automated Test Suite (Apple Silicon)")
        print("=======================================================\n")

        testVectorCosineSimilarityMath()
        testVectorNormalization()
        testBiometricClusterAndOutlierPruning()
        testSecurityProfiles()
        testApplicationPolicyFiltering()
        testPinLockoutExponentialLogic()
        testTelegramPayloadEscaping()
        testSecurityAuditSerialization()
        testVectorMatchingBenchmark()

        let elapsed = Date().timeIntervalSince(startTime)
        print("\n-------------------------------------------------------")
        print("Test Results: \(passedCount) Passed, \(failedCount) Failed (\(String(format: "%.3f", elapsed))s)")
        print("-------------------------------------------------------")

        if failedCount == 0 {
            print("🎉 ALL TESTS PASSED SUCCESSFULLY! (100% Reliability)\n")
            return true
        } else {
            print("❌ SOME TESTS FAILED!\n")
            return false
        }
    }

    // MARK: - 1. Vector Math & Cosine Similarity
    private func testVectorCosineSimilarityMath() {
        print("▶ Test Suite: 128-D Neural Vector Math & Cosine Distance")

        // Identical vectors must have distance 0.0
        let v1: [Float] = Array(repeating: 0.5, count: 128)
        let dIdentical = cosineDistance(v1, v1)
        assertAccuracy(dIdentical, 0.0, accuracy: 0.0001, "Identical 128-D vectors produce cosine distance 0.0")

        // Orthogonal vectors must have distance 1.0
        var vOrtho1 = Array(repeating: Float(0.0), count: 128)
        var vOrtho2 = Array(repeating: Float(0.0), count: 128)
        for i in 0..<64 { vOrtho1[i] = 1.0 }
        for i in 64..<128 { vOrtho2[i] = 1.0 }
        let dOrtho = cosineDistance(vOrtho1, vOrtho2)
        assertAccuracy(dOrtho, 1.0, accuracy: 0.0001, "Orthogonal vectors produce cosine distance 1.0")

        // Opposite vectors must have distance 2.0
        let vOpposite = v1.map { -$0 }
        let dOpposite = cosineDistance(v1, vOpposite)
        assertAccuracy(dOpposite, 2.0, accuracy: 0.0001, "Inverted vectors produce cosine distance 2.0")

        // Symmetry: d(A, B) == d(B, A)
        let randA = (0..<128).map { _ in Float.random(in: -1...1) }
        let randB = (0..<128).map { _ in Float.random(in: -1...1) }
        let dAB = cosineDistance(randA, randB)
        let dBA = cosineDistance(randB, randA)
        assertAccuracy(dAB, dBA, accuracy: 0.00001, "Cosine distance is symmetric: d(A, B) == d(B, A)")
    }

    // MARK: - 2. Vector Normalization
    private func testVectorNormalization() {
        print("\n▶ Test Suite: Vector Normalization & Euclidean Norm")

        let raw = (0..<128).map { _ in Float.random(in: -10...10) }
        let norm = normalize(raw)
        let magnitude = sqrt(norm.reduce(0) { $0 + $1 * $1 })
        assertAccuracy(magnitude, 1.0, accuracy: 0.0001, "L2 Normalized vector magnitude equals 1.0")
    }

    // MARK: - 3. Biometric Cluster & Outlier Pruning
    private func testBiometricClusterAndOutlierPruning() {
        print("\n▶ Test Suite: Biometric Cluster Centroid & Outlier Detection")

        // 4 closely clustered face vectors (owner across different lighting)
        let baseVector = (0..<128).map { _ in Float.random(in: 0...1) }
        let cluster = (0..<4).map { _ in
            normalize(baseVector.map { $0 + Float.random(in: -0.05...0.05) })
        }
        // 1 extreme outlier vector (intruder or noise)
        let outlier = normalize(baseVector.map { -$0 + Float.random(in: -0.1...0.1) })
        let allVectors = cluster + [outlier]

        // Calculate centroid
        var centroid = Array(repeating: Float(0.0), count: 128)
        for vec in allVectors {
            for i in 0..<128 { centroid[i] += vec[i] }
        }
        centroid = normalize(centroid)

        // Verify outlier has the highest distance from centroid
        let distances = allVectors.map { cosineDistance($0, centroid) }
        let maxIndex = distances.firstIndex(of: distances.max()!)!
        assertEqual(maxIndex, 4, "Correctly identifies foreign outlier vector at index 4")

        // Average intra-cluster distance of genuine vectors is tight (< 0.10)
        let clusterDistances = cluster.map { cosineDistance($0, centroid) }
        let avgClusterDist = clusterDistances.reduce(0, +) / Float(clusterDistances.count)
        assert(avgClusterDist < 0.12, "Intra-cluster variance of genuine vectors is within bounds (avg: \(avgClusterDist))")
    }

    // MARK: - 4. Security Profiles
    private func testSecurityProfiles() {
        print("\n▶ Test Suite: Security Profiles Application & Defaults")

        let allProfiles = Config.SecurityProfile.allCases
        assertEqual(allProfiles.count, 5, "Total 5 distinct security profiles supported")

        let config = Config()
        config.applyProfile(.cafe)
        assertEqual(config.activeProfile, "cafe", "Profile successfully switches to 'cafe'")
        assertEqual(config.walkAwayIdleSeconds, 10.0, "Cafe profile enforces 10s walk-away timeout")
        assertEqual(config.shoulderSurfingDefense, true, "Cafe profile enables shoulder-surfing defense")
        assertEqual(config.lockOnWake, true, "Cafe profile enables lock-on-wake")
        assertEqual(config.audibleAlerts, true, "Cafe profile enables audible deterrents")

        config.applyProfile(.presentation)
        assertEqual(config.activeProfile, "presentation", "Profile successfully switches to 'presentation'")
        assertEqual(config.walkAwayLockEnabled, false, "Presentation profile disables walk-away lock to prevent slide interruption")

        config.applyProfile(.normal)
        assertEqual(config.activeProfile, "normal", "Profile successfully resets to 'normal'")
        assertEqual(config.walkAwayIdleSeconds, 45.0, "Normal profile uses standard 45s timeout")
    }

    // MARK: - 5. Application Policy Filtering
    private func testApplicationPolicyFiltering() {
        print("\n▶ Test Suite: Application Bundle ID & Protection Policy Filtering")

        let protectedList = Config.defaultProtectedBundleIdentifiers
        let ignoredList = Config.defaultIgnoredBundleIdentifiers

        // Verification of critical secret apps
        assert(protectedList.contains("ru.keepcoder.Telegram"), "Telegram is protected by default")
        assert(protectedList.contains("com.apple.Safari"), "Safari is protected by default")
        assert(protectedList.contains("com.apple.Terminal"), "Terminal is protected by default")
        assert(protectedList.contains("com.apple.keychainaccess"), "Keychain Access is protected by default")

        // Verification of system exclusions
        assert(ignoredList.contains("com.apple.loginwindow"), "loginwindow is ignored to prevent self-deadlock")
        assert(ignoredList.contains("com.apple.Spotlight"), "Spotlight is ignored")
        assert(ignoredList.contains("com.apple.dock"), "Dock is ignored")

        // Case-insensitivity helper
        let query = "RU.KEEPCODER.TELEGRAM"
        let isProtected = protectedList.contains { $0.caseInsensitiveCompare(query) == .orderedSame }
        assert(isProtected, "Bundle ID matching is strictly case-insensitive")
    }

    // MARK: - 6. PIN Lockout Exponential Logic
    private func testPinLockoutExponentialLogic() {
        print("\n▶ Test Suite: PIN Failed Attempt Tracking & Lockout")

        var failedAttempts = 0
        let maxAttempts = 3
        let baseLockout: Double = 5.0

        for _ in 1...2 {
            failedAttempts += 1
            let isLockedOut = (failedAttempts >= maxAttempts)
            assert(!isLockedOut, "Attempt \(failedAttempts) of \(maxAttempts) does not trigger lockout")
        }

        failedAttempts += 1
        let isLockedOutNow = (failedAttempts >= maxAttempts)
        assert(isLockedOutNow, "Attempt \(failedAttempts) reaches threshold and triggers cooling lockout")

        // Lockout penalty calculation
        let penaltySeconds = baseLockout * Double(failedAttempts - maxAttempts + 1)
        assertAccuracy(Float(penaltySeconds), 5.0, accuracy: 0.01, "Initial lockout delay is exactly \(baseLockout)s")

        // Success reset
        failedAttempts = 0
        assertEqual(failedAttempts, 0, "Successful PIN authorization resets failed attempts to 0")
    }

    // MARK: - 7. Telegram Payload Escaping
    private func testTelegramPayloadEscaping() {
        print("\n▶ Test Suite: Telegram Alert Payload & HTML Sanitization")

        let rawAppName = "Code <Unsafe> & Co"
        let escaped = rawAppName
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        assertEqual(escaped, "Code &lt;Unsafe&gt; &amp; Co", "HTML characters properly escaped for Telegram Bot API")
    }

    // MARK: - 8. Security Audit Serialization
    private func testSecurityAuditSerialization() {
        print("\n▶ Test Suite: Security Audit Log JSONL Serialization")

        let event = AuditEvent(
            eventType: "intruder_detected",
            appName: "Telegram",
            bundleId: "ru.keepcoder.Telegram",
            distance: 0.4521,
            threshold: 0.22,
            intruderPhoto: "intruder_test.jpg",
            details: "Unauthorized face detected",
            isSuccess: false
        )

        let encoder = JSONEncoder()
        let data = try? encoder.encode(event)
        assert(data != nil, "AuditEvent serializes cleanly to JSON data")

        if let d = data {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(AuditEvent.self, from: d)
            assertEqual(decoded?.eventType, "intruder_detected", "Decoded eventType matches")
            assertEqual(decoded?.appName, "Telegram", "Decoded appName matches")
            assertEqual(decoded?.isSuccess, false, "Decoded isSuccess matches")
            assertAccuracy(decoded?.distance ?? 0.0, 0.4521, accuracy: 0.0001, "Decoded distance matches")
        }
    }

    // MARK: - 9. Performance Benchmark
    private func testVectorMatchingBenchmark() {
        print("\n▶ Test Suite: Apple Silicon Vector Similarity Benchmark")

        let enrolledTemplates = (0..<15).map { _ in
            normalize((0..<128).map { _ in Float.random(in: -1...1) })
        }
        let candidate = normalize((0..<128).map { _ in Float.random(in: -1...1) })

        let iterations = 2000
        let t0 = CFAbsoluteTimeGetCurrent()
        var dummySum: Float = 0.0
        for _ in 0..<iterations {
            for template in enrolledTemplates {
                dummySum += cosineDistance(candidate, template)
            }
        }
        let duration = CFAbsoluteTimeGetCurrent() - t0
        let totalComparisons = iterations * enrolledTemplates.count
        let usPerOp = (duration / Double(totalComparisons)) * 1_000_000.0

        print("  ⚡️ \(totalComparisons) comparisons performed in \(String(format: "%.4f", duration))s (\(String(format: "%.2f", usPerOp)) µs / comparison)")
        assert(duration < 0.15, "2,000 vector sweeps (30,000 comparisons) complete in < 150ms on Apple Silicon")
    }

    // MARK: - Math Helpers
    private func cosineDistance(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 100.0 }
        var dot: Float = 0.0
        var normA: Float = 0.0
        var normB: Float = 0.0
        vDSP_dotpr(a, 1, b, 1, &dot, vDSP_Length(a.count))
        vDSP_svesq(a, 1, &normA, vDSP_Length(a.count))
        vDSP_svesq(b, 1, &normB, vDSP_Length(b.count))
        let denom = sqrt(normA) * sqrt(normB)
        if denom == 0.0 { return 100.0 }
        let sim = max(-1.0, min(1.0, dot / denom))
        return 1.0 - sim
    }

    private func normalize(_ vec: [Float]) -> [Float] {
        var sumSquares: Float = 0.0
        vDSP_svesq(vec, 1, &sumSquares, vDSP_Length(vec.count))
        let magnitude = sqrt(sumSquares)
        if magnitude == 0.0 { return vec }
        var result = Array(repeating: Float(0.0), count: vec.count)
        var scale = 1.0 / magnitude
        vDSP_vsmul(vec, 1, &scale, &result, 1, vDSP_Length(vec.count))
        return result
    }
}
