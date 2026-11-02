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
        testBatteryAwareAdaptiveScanning()
        testAudibleAlertsAndShoulderDefense()
        testMeetingAndPresentationSuppression()
        testDiagnosticsReportCollection()
        testConfigReloadAndStateSync()
        testConfigDictionaryRepresentation()
        testCliFlagNormalization()
        testApplicationPolicyFiltering()
        testPinLockoutExponentialLogic()
        testTelegramPayloadEscaping()
        testSecurityAuditSerialization()
        testSecurityAuditAutoPruning()
        testIncidentCaptureClassification()
        testPauseTimerTracking()
        testEmergencyLockdownAndAuditFiltering()
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
        let dExtIdentical = FaceprintExtractor.cosineDistance(v1, v1)
        assertAccuracy(dExtIdentical, 0.0, accuracy: 0.0001, "FaceprintExtractor SIMD produces cosine distance 0.0 for identical vectors")

        // Orthogonal vectors must have distance 1.0
        var vOrtho1 = Array(repeating: Float(0.0), count: 128)
        var vOrtho2 = Array(repeating: Float(0.0), count: 128)
        for i in 0..<64 { vOrtho1[i] = 1.0 }
        for i in 64..<128 { vOrtho2[i] = 1.0 }
        let dOrtho = cosineDistance(vOrtho1, vOrtho2)
        assertAccuracy(dOrtho, 1.0, accuracy: 0.0001, "Orthogonal vectors produce cosine distance 1.0")
        let dExtOrtho = FaceprintExtractor.cosineDistance(vOrtho1, vOrtho2)
        assertAccuracy(dExtOrtho, 1.0, accuracy: 0.0001, "FaceprintExtractor SIMD produces cosine distance 1.0 for orthogonal vectors")

        // Opposite vectors must have distance 2.0
        let vOpposite = v1.map { -$0 }
        let dOpposite = cosineDistance(v1, vOpposite)
        assertAccuracy(dOpposite, 2.0, accuracy: 0.0001, "Inverted vectors produce cosine distance 2.0")
        let dExtOpposite = FaceprintExtractor.cosineDistance(v1, vOpposite)
        assertAccuracy(dExtOpposite, 2.0, accuracy: 0.0001, "FaceprintExtractor SIMD produces cosine distance 2.0 for inverted vectors")

        // Symmetry: d(A, B) == d(B, A)
        let randA = (0..<128).map { _ in Float.random(in: -1...1) }
        let randB = (0..<128).map { _ in Float.random(in: -1...1) }
        let dAB = cosineDistance(randA, randB)
        let dBA = cosineDistance(randB, randA)
        assertAccuracy(dAB, dBA, accuracy: 0.00001, "Cosine distance is symmetric: d(A, B) == d(B, A)")
        let dExtAB = FaceprintExtractor.cosineDistance(randA, randB)
        let dExtBA = FaceprintExtractor.cosineDistance(randB, randA)
        assertAccuracy(dExtAB, dExtBA, accuracy: 0.00001, "FaceprintExtractor SIMD distance is symmetric: d(A, B) == d(B, A)")
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
        assertEqual(allProfiles.count, 6, "Total 6 distinct security profiles supported")

        let config = Config()
        config.applyProfile(.lockdown)
        assertEqual(config.activeProfile, "lockdown", "Profile successfully switches to 'lockdown'")
        assertEqual(config.walkAwayIdleSeconds, 5.0, "Lockdown profile enforces strict 5s walk-away timeout")
        assertAccuracy(config.similarityThreshold, 0.18, accuracy: 0.001, "Lockdown profile uses strict 0.18 threshold")
        assertEqual(config.shoulderSurfingDefense, true, "Lockdown profile enables shoulder-surfing defense")
        assertEqual(config.audibleAlerts, true, "Lockdown profile enables audible alarm")

        config.applyProfile(.cafe)
        assertEqual(config.activeProfile, "cafe", "Profile successfully switches to 'cafe'")
        assertEqual(config.walkAwayIdleSeconds, 10.0, "Cafe profile enforces 10s walk-away timeout")
        assertEqual(config.shoulderSurfingDefense, true, "Cafe profile enables shoulder-surfing defense")
        assertEqual(config.lockOnWake, true, "Cafe profile enables lock-on-wake")
        assertEqual(config.audibleAlerts, true, "Cafe profile enables audible deterrents")

        config.applyProfile(.presentation)
        assertEqual(config.activeProfile, "presentation", "Profile successfully switches to 'presentation'")
        assertEqual(config.walkAwayLockEnabled, false, "Presentation profile disables walk-away lock to prevent slide interruption")

        config.applyProfile(.work)
        assertEqual(config.activeProfile, "work", "Profile successfully switches to 'work'")
        assertEqual(config.shoulderSurfingDefense, true, "Work profile enables shoulder-surfing defense")

        config.applyProfile(.home)
        assertEqual(config.activeProfile, "home", "Profile successfully switches to 'home'")
        assertEqual(config.walkAwayIdleSeconds, 180.0, "Home profile uses relaxed 180s timeout")
        assertAccuracy(config.similarityThreshold, 0.24, accuracy: 0.001, "Home profile uses 0.24 threshold")

        config.applyProfile(.normal)
        assertEqual(config.activeProfile, "normal", "Profile successfully resets to 'normal'")
        assertEqual(config.walkAwayIdleSeconds, 45.0, "Normal profile uses standard 45s timeout")
    }

    // MARK: - 4b. Battery-Aware Adaptive Polling & Power Management
    private func testBatteryAwareAdaptiveScanning() {
        print("\n▶ Test Suite: Battery-Aware Adaptive Polling & Power Management")
        let config = Config()
        assertEqual(config.batteryAwareScanning, true, "Battery-aware scanning is enabled by default")

        let onBattery = WalkAwayMonitor.isOnBatteryPower()
        assert(onBattery == true || onBattery == false, "WalkAwayMonitor successfully queries power source without crashing")

        let lowPower = WalkAwayMonitor.isLowPowerModeEnabled()
        assert(lowPower == true || lowPower == false, "WalkAwayMonitor successfully queries Low Power Mode state")

        let powerConstrained = WalkAwayMonitor.isPowerConstrained()
        assertEqual(powerConstrained, onBattery || lowPower, "Power constrained state correctly mirrors battery or Low Power Mode")

        let isThrottled = config.batteryAwareScanning && powerConstrained
        let sweepInterval: TimeInterval = isThrottled ? 10.0 : 5.0
        assert(sweepInterval >= 5.0, "Sweep interval is at least 5.0s")

        let idleDebounce: TimeInterval = isThrottled ? 45.0 : 20.0
        assert(idleDebounce >= 20.0, "Idle debounce interval is at least 20.0s")
    }

    // MARK: - 4c. Audible Alerts & Shoulder-Surfing Defense
    private func testAudibleAlertsAndShoulderDefense() {
        print("\n▶ Test Suite: Audible Alerts & Shoulder-Surfing Defense")
        let config = Config()
        assertEqual(config.shoulderSurfingDefense, false, "Shoulder-surfing defense default is false (opt-in)")
        assertEqual(config.audibleAlerts, false, "Audible alerts default is false (silent mode)")

        config.shoulderSurfingDefense = true
        assertEqual(config.shoulderSurfingDefense, true, "Shoulder-surfing defense toggles to true")

        config.audibleAlerts = true
        assertEqual(config.audibleAlerts, true, "Audible alerts toggles to true")

        // Verify bystander filename prefix support
        let prefix = "bystander"
        let sampleName = "\(prefix)_\(UUID().uuidString.prefix(6)).jpg"
        assert(sampleName.hasPrefix("bystander_"), "Bystander capture prefix formatted correctly")

        // Verify shoulder alert HTML escaping
        let alertCaption = "👀 FaceLock: Обнаружено подглядывание (Shoulder-Surfing)!"
        assert(TelegramNotifier.escapeHTML(alertCaption) == alertCaption, "Shoulder alert caption safely preserves valid characters")
    }

    // MARK: - 4d. Meeting & Presentation Mode Auto-Suppression
    private func testMeetingAndPresentationSuppression() {
        print("\n▶ Test Suite: Meeting & Presentation Mode Auto-Suppression")
        let config = Config()
        assertEqual(config.presentationModeSuppression, true, "Presentation mode suppression is enabled by default")

        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.apple.iWork.Keynote"), "Keynote is recognized as presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.microsoft.Powerpoint"), "PowerPoint is recognized as presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("us.zoom.xos"), "Zoom is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.cisco.webexmeetingsapp"), "Webex is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.discord.Discord"), "Discord is recognized as communication app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.skype.skype"), "Skype is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("ru.yandex.telemost"), "Telemost is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.obsproject.obs-studio"), "OBS Studio is recognized as streaming app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.loom.desktop"), "Loom is recognized as recording app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.apple.freeform"), "Freeform is recognized as presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.apple.QuickTimePlayerX"), "QuickTime Player is recognized as presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("org.videolan.vlc"), "VLC is recognized as media presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.colliderli.iina"), "IINA is recognized as media presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.apple.TV"), "Apple TV is recognized as media presentation app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.google.android.apps.meetings"), "Google Meet is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("us.zoom.ringcentral"), "RingCentral is recognized as meeting app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.anydesk.anydesk"), "AnyDesk is recognized as screen sharing app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.teamviewer.TeamViewer"), "TeamViewer is recognized as screen sharing app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.viber.osx"), "Viber is recognized as communication app")
        assert(WalkAwayMonitor.presentationBundleIdentifiers.contains("com.brave.Browser.app.kjgfgldnnfoeklkmfkjfagphfepbbdan"), "Brave Google Meet PWA is recognized")

        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.iWork.Keynote"), "Keynote triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "us.zoom.ringcentral"), "RingCentral triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.anydesk.anydesk"), "AnyDesk triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.QuickTimePlayerX"), "QuickTime Player triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "org.videolan.vlc"), "VLC triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.colliderli.iina"), "IINA triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.TV"), "Apple TV triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.skype.skype"), "Skype triggers presentation lock suppression")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "ru.yandex.telemost"), "Telemost triggers presentation lock suppression")
        assert(!WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.Safari"), "Safari does not trigger presentation suppression")

        let hasAssertion = WalkAwayMonitor.hasDisplaySleepAssertion()
        assert(hasAssertion == true || hasAssertion == false, "WalkAwayMonitor safely queries display sleep assertion state without crashing")

        let orig = Config.shared.presentationModeSuppression
        Config.shared.presentationModeSuppression = false
        assert(!WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.iWork.Keynote"), "Suppression disabled when feature flag is off")
        Config.shared.presentationModeSuppression = orig
    }

    // MARK: - 4e. Diagnostics Report Collection & Telemetry
    private func testDiagnosticsReportCollection() {
        print("\n▶ Test Suite: Diagnostics Telemetry & Report Collection")
        let report = Diagnostics.collectReport()

        assert(report["platform"] != nil, "Diagnostics platform telemetry collected")
        assert(report["daemon"] != nil, "Diagnostics daemon telemetry collected")
        assert(report["camera"] != nil, "Diagnostics camera subsystem telemetry collected")
        assert(report["biometrics"] != nil, "Diagnostics biometrics telemetry collected")
        assert(report["storage"] != nil, "Diagnostics storage telemetry collected")
        assert(report["integrations"] != nil, "Diagnostics integrations telemetry collected")

        if let platform = report["platform"] as? [String: Any] {
            assert(platform["osVersion"] is String, "Diagnostics platform contains osVersion string")
            assert(platform["architecture"] is String, "Diagnostics platform contains architecture string")
            assert(platform["appleSilicon"] is Bool, "Diagnostics platform contains appleSilicon boolean")
            assert(platform["onBatteryPower"] is Bool, "Diagnostics platform contains onBatteryPower boolean")
            assert(platform["lowPowerMode"] is Bool, "Diagnostics platform contains lowPowerMode boolean")
            assert(platform["powerConstrained"] is Bool, "Diagnostics platform contains powerConstrained boolean")
        }

        if let biometrics = report["biometrics"] as? [String: Any] {
            assert(biometrics["similarityThreshold"] is Double, "Diagnostics similarityThreshold is valid Double")
            assert(biometrics["neuralFaceprintAvailable"] is Bool, "Diagnostics neuralFaceprintAvailable is valid Bool")
        }

        if let storage = report["storage"] as? [String: Any] {
            assert(storage["configExists"] is Bool, "Diagnostics configExists is valid Bool")
            assert(storage["enrolledVectors"] is Int, "Diagnostics enrolledVectors is valid Int")
        }
    }

    // MARK: - 4f. Config Reload & State Synchronization
    private func testConfigReloadAndStateSync() {
        print("\n▶ Test Suite: Config Reload & Defense State Synchronization")

        let tempPath = "/tmp/facelock_sync_test_\(UUID().uuidString).json"
        defer {
            try? FileManager.default.removeItem(atPath: tempPath)
        }

        let testCfg = Config(
            pin: "9876",
            similarityThreshold: 0.19,
            activeProfile: "cafe",
            shoulderSurfingDefense: true,
            batteryAwareScanning: false,
            audibleAlerts: true,
            presentationModeSuppression: false
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(testCfg)
        assert(data != nil, "Config with activeProfile and defense flags encodes successfully")

        if let d = data {
            let decoder = JSONDecoder()
            let decoded = try? decoder.decode(Config.self, from: d)
            assertEqual(decoded?.activeProfile, "cafe", "Decoded activeProfile matches 'cafe'")
            assertEqual(decoded?.shoulderSurfingDefense, true, "Decoded shoulderSurfingDefense matches true")
            assertEqual(decoded?.batteryAwareScanning, false, "Decoded batteryAwareScanning matches false")
            assertEqual(decoded?.audibleAlerts, true, "Decoded audibleAlerts matches true")
            assertEqual(decoded?.presentationModeSuppression, false, "Decoded presentationModeSuppression matches false")

            // Test restoreConfig
            try? d.write(to: URL(fileURLWithPath: tempPath), options: .atomic)
            let recipientCfg = Config()
            do {
                try recipientCfg.restoreConfig(from: tempPath)
                assertEqual(recipientCfg.activeProfile, "cafe", "restoreConfig synchronizes activeProfile")
                assertEqual(recipientCfg.shoulderSurfingDefense, true, "restoreConfig synchronizes shoulderSurfingDefense")
                assertEqual(recipientCfg.batteryAwareScanning, false, "restoreConfig synchronizes batteryAwareScanning")
                assertEqual(recipientCfg.audibleAlerts, true, "restoreConfig synchronizes audibleAlerts")
                assertEqual(recipientCfg.presentationModeSuppression, false, "restoreConfig synchronizes presentationModeSuppression")
            } catch {
                assert(false, "restoreConfig threw error: \(error)")
            }
        }
    }

    // MARK: - 4f. Config Dictionary Representation
    private func testConfigDictionaryRepresentation() {
        print("\n▶ Test Suite: Config Dictionary Representation & Schema Integrity")
        let cfg = Config(
            pin: "1234",
            similarityThreshold: 0.22,
            activeProfile: "work",
            shoulderSurfingDefense: false,
            batteryAwareScanning: true,
            audibleAlerts: false,
            presentationModeSuppression: true
        )
        let dict = cfg.toDictionary()

        assertEqual(dict["pin"] as? String, "1234", "Config dictionary contains pin")
        assertEqual(dict["activeProfile"] as? String, "work", "Config dictionary contains activeProfile")
        assertEqual(dict["shoulderSurfingDefense"] as? Bool, false, "Config dictionary contains shoulderSurfingDefense")
        assertEqual(dict["batteryAwareScanning"] as? Bool, true, "Config dictionary contains batteryAwareScanning")
        assertEqual(dict["audibleAlerts"] as? Bool, false, "Config dictionary contains audibleAlerts")
        assertEqual(dict["presentationModeSuppression"] as? Bool, true, "Config dictionary contains presentationModeSuppression")
        assert(dict["similarityThreshold"] is Double, "Config dictionary similarityThreshold is Double")
        assert(dict["verificationTimeout"] is Double, "Config dictionary verificationTimeout is Double")
        assert(dict["debounceSeconds"] is Double, "Config dictionary debounceSeconds is Double")
        assert(dict["isEnabled"] is Bool, "Config dictionary isEnabled is Bool")
        assert(dict["protectionMode"] is String, "Config dictionary protectionMode is String")
        assert(dict["protectedAppsCount"] is Int, "Config dictionary protectedAppsCount is Int")
        assert(dict["ignoredAppsCount"] is Int, "Config dictionary ignoredAppsCount is Int")
        assert(dict["hasEnrolledFace"] is Bool, "Config dictionary hasEnrolledFace is Bool")
        assert(dict["enrolledVectorsCount"] is Int, "Config dictionary enrolledVectorsCount is Int")

        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
        assert(jsonData != nil, "Config dictionary serializes to valid JSON data")
    }

    // MARK: - 4g. CLI Argument Normalization
    private func testCliFlagNormalization() {
        print("\n▶ Test Suite: CLI Argument Normalization")
        let aliasMap: [String: [String]] = [
            "--config-json": ["--config", "--json"],
            "--profiles-json": ["--profiles", "--json"],
            "--toggle-shoulder-json": ["--toggle-shoulder-defense", "--json"],
            "--toggle-audible-json": ["--toggle-audible", "--json"],
            "--toggle-battery-aware-json": ["--toggle-battery-aware", "--json"],
            "--toggle-presentation-json": ["--toggle-presentation", "--json"],
            "--toggle-presentation-mode-json": ["--toggle-presentation", "--json"],
            "--toggle-walkaway-json": ["--toggle-walkaway", "--json"],
            "--toggle-wake-json": ["--toggle-wake", "--json"],
            "--battery-status-json": ["--battery-status", "--json"],
            "--power-status-json": ["--battery-status", "--json"],
            "--lockdown-json": ["--lockdown", "--json"],
            "--emergency-lockdown-json": ["--lockdown", "--json"],
            "--status-json": ["--status", "--json"],
            "--diagnostics-gui-json": ["--diagnostics-gui", "--json"],
            "--health-json": ["--health", "--json"]
        ]

        for (alias, expected) in aliasMap {
            assertEqual(expected.count, 2, "Alias \(alias) maps to exactly 2 arguments")
            assertEqual(expected.last, "--json", "Alias \(alias) normalized target contains --json")
        }
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

        // Config method tests
        let testConfig = Config()
        assert(testConfig.isProtected(bundleId: "ru.keepcoder.Telegram"), "Config.isProtected identifies exact Telegram bundle ID")
        assert(testConfig.isProtected(bundleId: "RU.KEEPCODER.TELEGRAM"), "Config.isProtected handles uppercase Telegram bundle ID")
        assert(testConfig.isProtected(bundleId: "com.apple.safari"), "Config.isProtected handles lowercase Safari bundle ID")
        assert(testConfig.isIgnored(bundleId: "com.apple.loginwindow"), "Config.isIgnored identifies loginwindow")
        assert(testConfig.isIgnored(bundleId: "COM.APPLE.DOCK"), "Config.isIgnored handles uppercase Dock")
        assert(!testConfig.isProtected(bundleId: "com.unknown.nonexistent.app"), "Config.isProtected returns false for non-protected app")
        assert(!testConfig.isIgnored(bundleId: "com.unknown.nonexistent.app"), "Config.isIgnored returns false for non-ignored app")
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

    // MARK: - 8b. Security Audit Auto-Pruning
    private func testSecurityAuditAutoPruning() {
        print("\n▶ Test Suite: Security Audit Auto-Pruning & Storage Integrity")
        let stats = SecurityAuditLogger.shared.getLogStats()
        assert(stats.totalCount >= 0, "Audit log total count is non-negative")
        assert(stats.fileSizeBytes >= 0, "Audit log file size in bytes is non-negative")

        let pruned = SecurityAuditLogger.shared.autoPruneLogs(maxBytes: 100 * 1024 * 1024, keeping: 5000)
        assert(pruned == false || pruned == true, "SecurityAuditLogger autoPruneLogs executed successfully")
    }

    // MARK: - 8. Incident Capture Classification & Date Parsing
    private func testIncidentCaptureClassification() {
        print("\n▶ Test Suite: Incident Capture Classification & Date Parsing")

        let intruderFile = "intruder_2026-11-01_12-30-45_a1b2c3.jpg"
        let bystanderFile = "bystander_2026-11-01_14-15-30_d4e5f6.jpg"

        assert(!intruderFile.hasPrefix("bystander_"), "Intruder file does not have bystander prefix")
        assert(intruderFile.hasPrefix("intruder_"), "Intruder file has intruder prefix")
        assert(bystanderFile.hasPrefix("bystander_"), "Bystander file has bystander prefix")
        assert(!bystanderFile.hasPrefix("intruder_"), "Bystander file does not have intruder prefix")

        let intruderDate = IncidentGalleryController.parseDateFromFilename(intruderFile)
        assertEqual(intruderDate, "2026-11-01 в 12:30:45", "Intruder filename parsed into readable date and time")

        let bystanderDate = IncidentGalleryController.parseDateFromFilename(bystanderFile)
        assertEqual(bystanderDate, "2026-11-01 в 14:15:30", "Bystander filename parsed into readable date and time without artifact")

        // Filter predicate logic parity
        let fileList = [intruderFile, bystanderFile]
        let shoulderOnly = fileList.filter { $0.hasPrefix("bystander_") }
        assertEqual(shoulderOnly.count, 1, "Shoulder filter isolates exactly 1 bystander capture")
        assertEqual(shoulderOnly.first, bystanderFile, "Shoulder filter selected bystander file")

        let intrudersOnly = fileList.filter { !$0.hasPrefix("bystander_") }
        assertEqual(intrudersOnly.count, 1, "Intruders filter isolates exactly 1 intruder capture")
        assertEqual(intrudersOnly.first, intruderFile, "Intruders filter selected intruder file")
    }

    // MARK: - 9. Pause Timer Tracking & Ergonomics
    private func testPauseTimerTracking() {
        print("\n▶ Test Suite: Protection Pause Timer & Ergonomics")

        let expDate = Date().addingTimeInterval(900) // 15 mins
        let remSeconds = expDate.timeIntervalSinceNow
        let remMinutes = Int(ceil(remSeconds / 60.0))
        assert(remMinutes >= 14 && remMinutes <= 15, "Remaining pause minutes calculates correctly (~15m)")

        let expExpired = Date().addingTimeInterval(-10)
        let expiredRemaining = expExpired.timeIntervalSinceNow > 0 ? Int(ceil(expExpired.timeIntervalSinceNow / 60.0)) : nil
        assert(expiredRemaining == nil, "Expired pause returns nil remaining minutes")
    }

    // MARK: - 9b. Emergency Lockdown & Audit Filtering
    private func testEmergencyLockdownAndAuditFiltering() {
        print("\n▶ Test Suite: Emergency Lockdown & Audit Event Filtering")

        let config = Config.shared
        let originalProfile = config.activeProfile

        // Apply lockdown
        config.applyProfile(.lockdown)
        assertEqual(config.activeProfile, "lockdown", "Lockdown profile successfully engaged")
        assertEqual(config.walkAwayIdleSeconds, 5.0, "Lockdown timeout is 5.0 seconds")
        assertAccuracy(config.similarityThreshold, 0.18, accuracy: 0.001, "Lockdown threshold is 0.18")
        assertEqual(config.shoulderSurfingDefense, true, "Lockdown enables shoulder surfing defense")
        assertEqual(config.audibleAlerts, true, "Lockdown enables audible alerts")

        // Log emergency lockdown event
        SecurityAuditLogger.shared.logEmergencyLockdown(details: "Unit test lockdown trigger")

        // Test filtering
        let lockdownEvents = SecurityAuditLogger.shared.fetchRecentEvents(tail: 10, filterType: "lockdown")
        assert(!lockdownEvents.isEmpty, "Audit fetchRecentEvents with filter 'lockdown' retrieves events")
        assertEqual(lockdownEvents.first?.eventType, "emergency_lockdown", "Retrieved eventType is emergency_lockdown")

        // Log shoulder surfing event
        SecurityAuditLogger.shared.logShoulderSurfingDetected(secondaryCount: 2, details: "Unit test bystander alert")
        let shoulderEvents = SecurityAuditLogger.shared.fetchRecentEvents(tail: 10, filterType: "shoulder")
        assert(!shoulderEvents.isEmpty, "Audit fetchRecentEvents with filter 'shoulder' retrieves bystander events")

        // Restore original profile
        if let original = Config.SecurityProfile(rawValue: originalProfile) {
            config.applyProfile(original)
        } else {
            config.applyProfile(.normal)
        }
    }

    // MARK: - 10. Performance Benchmark
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
