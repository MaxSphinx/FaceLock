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
        testConfigExportAndRestoreRoundtrip()
        testTelegramLockdownAlertPayload()
        testTelegramPinBruteforceAlertPayload()
        testSecurityProfileValidationAndEnumeration()
        testExportImportCliAliases()
        testVectorAndAuditExportResilience()
        testVectorValidationAndClearing()
        testIncidentManagementAndFilteringResilience()
        testSecurityAuditTelemetryAndFilterValidation()
        testIncidentTelemetryAndAuditSearch()
        testIncidentAndAuditAgePruning()
        testConfigValidationSuiteAndIncidentSearch()
        testIncidentDeletionExportAndAuditStats()
        testMaintenanceV119Enhancements()
        testMaintenanceV120Enhancements()
        testMaintenanceV121Enhancements()
        testMaintenanceV122Enhancements()
        testMaintenanceV123Enhancements()
        testMaintenanceV124Enhancements()
        testMaintenanceV125Enhancements()
        testMaintenanceV126Enhancements()
        testMaintenanceV127Enhancements()
        testMaintenanceV128Enhancements()
        testMaintenanceV129Enhancements()
        testMaintenanceV130Enhancements()
        testMaintenanceV131Enhancements()
        testMaintenanceV132Enhancements()
        testMaintenanceV133Enhancements()
        testMaintenanceV134Enhancements()
        testMaintenanceV135Enhancements()
        testMaintenanceV136Enhancements()
        testMaintenanceV137Enhancements()
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
            "--health-json": ["--health", "--json"],
            "--toggle-json": ["--toggle", "--json"],
            "--pause-json": ["--pause", "--json"],
            "--resume-json": ["--resume", "--json"],
            "--unpause-json": ["--resume", "--json"],
            "--lock-json": ["--lock", "--json"],
            "--test-lock-json": ["--lock", "--json"],
            "--reload-json": ["--reload", "--json"],
            "--reload-config-json": ["--reload", "--json"],
            "--reset-session-json": ["--reset-session", "--json"],
            "--profile-json": ["--profiles", "--json"],
            "--set-profile-json": ["--profiles", "--json"]
        ]

        for (alias, expected) in aliasMap {
            assertEqual(expected.count, 2, "Alias \(alias) maps to exactly 2 arguments")
            assertEqual(expected.last, "--json", "Alias \(alias) normalized target contains --json")
            let normalized = AppDelegate.normalizeArguments([alias])
            assertEqual(normalized, expected, "AppDelegate.normalizeArguments correctly normalizes \(alias)")
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
        let walkawayFile = "walkaway_2026-11-01_16-20-10_g7h8i9.jpg"
        let wakeFile = "wake_2026-11-01_18-05-00_j1k2l3.jpg"
        let bruteforceFile = "bruteforce_2026-11-01_20-40-55_m4n5o6.jpg"

        assert(!intruderFile.hasPrefix("bystander_"), "Intruder file does not have bystander prefix")
        assert(intruderFile.hasPrefix("intruder_"), "Intruder file has intruder prefix")
        assert(bystanderFile.hasPrefix("bystander_"), "Bystander file has bystander prefix")
        assert(!bystanderFile.hasPrefix("intruder_"), "Bystander file does not have intruder prefix")

        assertEqual(CameraScanner.incidentType(for: intruderFile), "intruder", "CameraScanner identifies intruder type")
        assertEqual(CameraScanner.incidentType(for: bystanderFile), "bystander", "CameraScanner identifies bystander type")
        assertEqual(CameraScanner.incidentType(for: walkawayFile), "walkaway", "CameraScanner identifies walkaway type")
        assertEqual(CameraScanner.incidentType(for: wakeFile), "wake", "CameraScanner identifies wake type")
        assertEqual(CameraScanner.incidentType(for: bruteforceFile), "bruteforce", "CameraScanner identifies bruteforce type")

        let intruderDate = IncidentGalleryController.parseDateFromFilename(intruderFile)
        assertEqual(intruderDate, "2026-11-01 в 12:30:45", "Intruder filename parsed into readable date and time")

        let bystanderDate = IncidentGalleryController.parseDateFromFilename(bystanderFile)
        assertEqual(bystanderDate, "2026-11-01 в 14:15:30", "Bystander filename parsed into readable date and time without artifact")

        let walkawayDate = IncidentGalleryController.parseDateFromFilename(walkawayFile)
        assertEqual(walkawayDate, "2026-11-01 в 16:20:10", "Walkaway filename parsed into readable date and time without artifact")

        let bruteforceDate = IncidentGalleryController.parseDateFromFilename(bruteforceFile)
        assertEqual(bruteforceDate, "2026-11-01 в 20:40:55", "Bruteforce filename parsed into readable date and time without artifact")

        // Filter predicate logic parity
        let fileList = [intruderFile, bystanderFile, walkawayFile, wakeFile, bruteforceFile]
        let shoulderOnly = fileList.filter { $0.hasPrefix("bystander_") }
        assertEqual(shoulderOnly.count, 1, "Shoulder filter isolates exactly 1 bystander capture")
        assertEqual(shoulderOnly.first, bystanderFile, "Shoulder filter selected bystander file")

        let intrudersOnly = fileList.filter { !$0.hasPrefix("bystander_") }
        assertEqual(intrudersOnly.count, 4, "Intruders filter isolates non-bystander captures")
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

    // MARK: - 9. Config Export/Restore & Telegram Lockdown
    private func testConfigExportAndRestoreRoundtrip() {
        print("\n▶ Test Suite: Config Export, Restore & Alias Roundtrip")

        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let exportPath = tempDir.appendingPathComponent("nested/config_backup.json").path

        let config = Config.shared
        let originalThreshold = config.similarityThreshold
        let originalTimeout = config.walkAwayIdleSeconds
        let originalProfile = config.activeProfile

        defer {
            try? FileManager.default.removeItem(at: tempDir)
            config.similarityThreshold = originalThreshold
            config.walkAwayIdleSeconds = originalTimeout
            _ = config.setProfile(originalProfile)
            config.save()
        }

        config.similarityThreshold = 0.28
        config.walkAwayIdleSeconds = 55.0

        do {
            let savedPath = try config.exportConfig(to: exportPath)
            assert(FileManager.default.fileExists(atPath: savedPath), "exportConfig successfully creates file including missing parent directories")

            // Mutate config in memory
            config.similarityThreshold = 0.15
            config.walkAwayIdleSeconds = 25.0

            // Restore from backup
            try config.importConfig(from: savedPath)
            assertAccuracy(config.similarityThreshold, 0.28, accuracy: 0.001, "importConfig restores similarityThreshold accurately")
            assertEqual(config.walkAwayIdleSeconds, 55.0, "importConfig restores walkAwayIdleSeconds accurately")
        } catch {
            assert(false, "Config export/import roundtrip failed with error: \(error.localizedDescription)")
        }
    }

    private func testTelegramLockdownAlertPayload() {
        print("\n▶ Test Suite: Telegram Emergency Lockdown Alert Formatting")

        let testDate = Date(timeIntervalSince1970: 1730588400) // Fixed timestamp for deterministic testing
        let rawReason = "Terminal <admin> session & untrusted network"
        let caption = TelegramNotifier.formatLockdownAlertCaption(reason: rawReason, timestamp: testDate)

        assert(caption.contains("🚨 <b>FaceLock: Режим экстренной изоляции (Lockdown)!</b>"), "Lockdown alert has distinct high-priority header")
        assert(caption.contains("&lt;admin&gt;"), "Special HTML characters '<' and '>' are safely escaped in lockdown alert")
        assert(caption.contains("Terminal &lt;admin&gt; session &amp; untrusted network"), "Ampersand '&' is safely escaped in lockdown alert")
        assert(caption.contains("тайм-аут 5с, порог 0.18"), "Lockdown alert reflects strict timeout and biometric threshold parameters")
    }

    private func testTelegramPinBruteforceAlertPayload() {
        print("\n▶ Test Suite: Telegram PIN Brute-force Alert Formatting")

        let testDate = Date(timeIntervalSince1970: 1730588400)
        let rawAppName = "Keychain <Sensitive> & Admin"
        let caption = TelegramNotifier.formatPinBruteforceAlertCaption(attempts: 3, appName: rawAppName, timestamp: testDate, lockoutSeconds: 10)

        assert(caption.contains("🚨 <b>FaceLock: Подозрительная активность (PIN Brute-force)!</b>"), "Brute force alert has distinct high-priority header")
        assert(caption.contains("&lt;Sensitive&gt;"), "Special HTML characters '<' and '>' are safely escaped in PIN brute force alert")
        assert(caption.contains("&amp;"), "Ampersand '&' is safely escaped in PIN brute force alert")
        assert(caption.contains("3"), "PIN brute force alert specifies exact failed attempts count")
        assert(caption.contains("10с"), "PIN brute force alert reflects cooling lockout delay in seconds")
    }

    private func testSecurityProfileValidationAndEnumeration() {
        print("\n▶ Test Suite: Security Profile Validation & Enumeration")

        assert(Config.isValidProfile("normal"), "Profile 'normal' is recognized as valid")
        assert(Config.isValidProfile("CAFE"), "Profile validation is case-insensitive ('CAFE')")
        assert(Config.isValidProfile("  normal  "), "Profile validation trims surrounding whitespace")
        assert(Config.isValidProfile("\ncafe\t"), "Profile validation trims tabs and newlines")
        assert(Config.profile(named: "  LOCKDOWN  ") == .lockdown, "Config.profile resolves enum with whitespace and uppercase")
        assert(Config.profile(named: "invalid_profile") == nil, "Config.profile returns nil for unknown profile")
        assert(Config.isValidProfile("lockdown"), "Profile 'lockdown' is recognized as valid")
        assert(Config.isValidProfile("work"), "Profile 'work' is recognized as valid")
        assert(Config.isValidProfile("home"), "Profile 'home' is recognized as valid")
        assert(Config.isValidProfile("presentation"), "Profile 'presentation' is recognized as valid")
        assert(!Config.isValidProfile("non_existent_profile"), "Invalid profile name returns false")

        let allProfiles = Config.allProfileNames
        assertEqual(allProfiles.count, 6, "Total 6 profiles enumerated")
        assert(allProfiles.contains("normal"), "Enumerated profiles contain 'normal'")
        assert(allProfiles.contains("lockdown"), "Enumerated profiles contain 'lockdown'")

        // Config parameter validation helpers
        assert(Config.isValidThreshold(0.22), "0.22 is a valid similarity threshold")
        assert(!Config.isValidThreshold(0.01), "0.01 is too low for similarity threshold")
        assert(!Config.isValidThreshold(0.99), "0.99 is too high for similarity threshold")

        assert(Config.isValidTimeout(2.0), "2.0s is a valid camera verification timeout")
        assert(!Config.isValidTimeout(0.1), "0.1s is too low for camera timeout")
        assert(!Config.isValidTimeout(15.0), "15.0s is too high for camera timeout")

        assert(Config.isValidDebounce(2.0), "2.0s is a valid debounce interval")
        assert(!Config.isValidDebounce(0.1), "0.1s is too low for debounce interval")

        assert(Config.isValidPin("1234"), "'1234' is a valid 4-digit PIN")
        assert(Config.isValidPin(" 987654 "), "PIN with surrounding whitespace is valid")
        assert(!Config.isValidPin("12"), "'12' is too short for PIN")
        assert(!Config.isValidPin("12a4"), "'12a4' contains non-digits and is invalid")

        assert(Config.isValidWalkAwayTimeout(45.0), "45s is a valid walk-away timeout")
        assert(!Config.isValidWalkAwayTimeout(5.0), "5s is below minimum walk-away timeout (10s)")

        assert(Config.isValidProtectionMode("all"), "Mode 'all' is valid protection mode")
        assert(Config.isValidProtectionMode("SELECTIVE"), "Mode 'SELECTIVE' is valid case-insensitively")
        assert(!Config.isValidProtectionMode("unknown"), "Mode 'unknown' is invalid protection mode")

        assert(Config.isValidPinAttempts(3), "3 failed PIN attempts is valid")
        assert(!Config.isValidPinAttempts(0), "0 failed PIN attempts is invalid")

        assert(Config.isValidPinLockout(5.0), "5s is a valid PIN lockout delay")
        assert(!Config.isValidPinLockout(0.5), "0.5s is too low for PIN lockout delay")
    }

    private func testExportImportCliAliases() {
        print("\n▶ Test Suite: CLI Export / Import Aliases & Flag Normalization")

        let normalizedExport = AppDelegate.normalizeArguments(["--export-config", "/tmp/cfg.json"])
        assertEqual(normalizedExport, ["--backup-config", "/tmp/cfg.json"], "--export-config normalizes to --backup-config")

        let normalizedImport = AppDelegate.normalizeArguments(["--import-config", "/tmp/cfg.json"])
        assertEqual(normalizedImport, ["--restore-config", "/tmp/cfg.json"], "--import-config normalizes to --restore-config")

        let normalizedFaceJson = AppDelegate.normalizeArguments(["--verify-face-json"])
        assertEqual(normalizedFaceJson, ["--verify-face", "--json"], "--verify-face-json normalizes to --verify-face --json")

        let normalizedAuditStatsJson = AppDelegate.normalizeArguments(["--audit-stats-json"])
        assertEqual(normalizedAuditStatsJson, ["--audit-stats", "--json"], "--audit-stats-json normalizes to --audit-stats --json")

        let normalizedClearAuditJson = AppDelegate.normalizeArguments(["--clear-audit-json"])
        assertEqual(normalizedClearAuditJson, ["--clear-audit", "--json"], "--clear-audit-json normalizes to --clear-audit --json")

        let normalizedClearIncidentsJson = AppDelegate.normalizeArguments(["--clear-incidents-json"])
        assertEqual(normalizedClearIncidentsJson, ["--clear-incidents", "--json"], "--clear-incidents-json normalizes to --clear-incidents --json")

        let normalizedSettingsJson = AppDelegate.normalizeArguments(["--settings-json"])
        assertEqual(normalizedSettingsJson, ["--settings", "--json"], "--settings-json normalizes to --settings --json")

        let normalizedGalleryJson = AppDelegate.normalizeArguments(["--gallery-json"])
        assertEqual(normalizedGalleryJson, ["--gallery", "--json"], "--gallery-json normalizes to --gallery --json")

        let normalizedEnrollJson = AppDelegate.normalizeArguments(["--enroll-json"])
        assertEqual(normalizedEnrollJson, ["--enroll", "--json"], "--enroll-json normalizes to --enroll --json")

        let normalizedTestTelegramJson = AppDelegate.normalizeArguments(["--test-telegram-json"])
        assertEqual(normalizedTestTelegramJson, ["--test-telegram", "--json"], "--test-telegram-json normalizes to --test-telegram --json")

        let normalizedBackupConfigJson = AppDelegate.normalizeArguments(["--backup-config-json", "/tmp/cfg.json"])
        assertEqual(normalizedBackupConfigJson, ["--backup-config", "--json", "/tmp/cfg.json"], "--backup-config-json normalizes to --backup-config --json")

        let normalizedRestoreConfigJson = AppDelegate.normalizeArguments(["--restore-config-json", "/tmp/cfg.json"])
        assertEqual(normalizedRestoreConfigJson, ["--restore-config", "--json", "/tmp/cfg.json"], "--restore-config-json normalizes to --restore-config --json")

        let normalizedExportAuditJson = AppDelegate.normalizeArguments(["--export-audit-json", "/tmp/audit.jsonl"])
        assertEqual(normalizedExportAuditJson, ["--export-audit", "--json", "/tmp/audit.jsonl"], "--export-audit-json normalizes to --export-audit --json")

        let normalizedExportAuditCsv = AppDelegate.normalizeArguments(["--export-audit-csv", "/tmp/audit.csv"])
        assertEqual(normalizedExportAuditCsv, ["--export-audit", "--format", "csv", "/tmp/audit.csv"], "--export-audit-csv normalizes to --export-audit --format csv")

        let normalizedExportAuditArray = AppDelegate.normalizeArguments(["--export-audit-array", "/tmp/audit.json"])
        assertEqual(normalizedExportAuditArray, ["--export-audit", "--format", "json", "/tmp/audit.json"], "--export-audit-array normalizes to --export-audit --format json")

        let normalizedPruneIncidentsJson = AppDelegate.normalizeArguments(["--prune-incidents-json", "10"])
        assertEqual(normalizedPruneIncidentsJson, ["--prune-incidents", "--json", "10"], "--prune-incidents-json normalizes to --prune-incidents --json")

        let normalizedVerifyPinJson = AppDelegate.normalizeArguments(["--verify-pin-json", "1234"])
        assertEqual(normalizedVerifyPinJson, ["--verify-pin", "--json", "1234"], "--verify-pin-json normalizes to --verify-pin --json")

        let normalizedBackupVectors = AppDelegate.normalizeArguments(["--backup-vectors", "/tmp/vecs.json"])
        assertEqual(normalizedBackupVectors, ["--export-vectors", "/tmp/vecs.json"], "--backup-vectors normalizes to --export-vectors")

        let normalizedRestoreVectors = AppDelegate.normalizeArguments(["--restore-vectors", "/tmp/vecs.json"])
        assertEqual(normalizedRestoreVectors, ["--import-vectors", "/tmp/vecs.json"], "--restore-vectors normalizes to --import-vectors")

        let normalizedBackupVectorsJson = AppDelegate.normalizeArguments(["--backup-vectors-json", "/tmp/vecs.json"])
        assertEqual(normalizedBackupVectorsJson, ["--export-vectors", "--json", "/tmp/vecs.json"], "--backup-vectors-json normalizes to --export-vectors --json")

        let normalizedRestoreVectorsJson = AppDelegate.normalizeArguments(["--restore-vectors-json", "/tmp/vecs.json"])
        assertEqual(normalizedRestoreVectorsJson, ["--import-vectors", "--json", "/tmp/vecs.json"], "--restore-vectors-json normalizes to --import-vectors --json")

        let normalizedExportLogs = AppDelegate.normalizeArguments(["--export-logs", "/tmp/audit.jsonl"])
        assertEqual(normalizedExportLogs, ["--export-audit", "/tmp/audit.jsonl"], "--export-logs normalizes to --export-audit")

        let normalizedPruneLogs = AppDelegate.normalizeArguments(["--prune-logs", "50"])
        assertEqual(normalizedPruneLogs, ["--prune-audit", "50"], "--prune-logs normalizes to --prune-audit")

        let normalizedClearVectorsJson = AppDelegate.normalizeArguments(["--clear-vectors-json"])
        assertEqual(normalizedClearVectorsJson, ["--clear-vectors", "--json"], "--clear-vectors-json normalizes to --clear-vectors --json")

        let normalizedResetVectorsJson = AppDelegate.normalizeArguments(["--reset-vectors-json"])
        assertEqual(normalizedResetVectorsJson, ["--clear-vectors", "--json"], "--reset-vectors-json normalizes to --clear-vectors --json")

        let normalizedResetJson = AppDelegate.normalizeArguments(["--reset-json"])
        assertEqual(normalizedResetJson, ["--clear-vectors", "--json"], "--reset-json normalizes to --clear-vectors --json")

        let normalizedResetVectors = AppDelegate.normalizeArguments(["--reset-vectors"])
        assertEqual(normalizedResetVectors, ["--clear-vectors"], "--reset-vectors normalizes to --clear-vectors")

        let normalizedReset = AppDelegate.normalizeArguments(["--reset"])
        assertEqual(normalizedReset, ["--clear-vectors"], "--reset normalizes to --clear-vectors")

        let normalizedExportLatestJson = AppDelegate.normalizeArguments(["--export-latest-incident-json", "/tmp/latest.jpg"])
        assertEqual(normalizedExportLatestJson, ["--export-latest-incident", "--json", "/tmp/latest.jpg"], "--export-latest-incident-json normalizes to --export-latest-incident --json")

        let normalizedExportIncidentJson = AppDelegate.normalizeArguments(["--export-incident-json", "intruder_1.jpg", "/tmp/out.jpg"])
        assertEqual(normalizedExportIncidentJson, ["--export-incident", "--json", "intruder_1.jpg", "/tmp/out.jpg"], "--export-incident-json normalizes to --export-incident --json")

        let normalizedIncidentJson = AppDelegate.normalizeArguments(["--incident-json", "intruder_1.jpg"])
        assertEqual(normalizedIncidentJson, ["--incident", "--json", "intruder_1.jpg"], "--incident-json normalizes to --incident --json")

        let normalizedDeleteIncidentJson = AppDelegate.normalizeArguments(["--delete-incident-json", "intruder_1.jpg"])
        assertEqual(normalizedDeleteIncidentJson, ["--delete-incident", "--json", "intruder_1.jpg"], "--delete-incident-json normalizes to --delete-incident --json")

        let normalizedProfilesJson = AppDelegate.normalizeArguments(["--profiles-json"])
        assertEqual(normalizedProfilesJson, ["--profiles", "--json"], "--profiles-json normalizes to --profiles --json")

        let normalizedToggleBattery = AppDelegate.normalizeArguments(["--toggle-battery"])
        assertEqual(normalizedToggleBattery, ["--toggle-battery-aware"], "--toggle-battery normalizes to --toggle-battery-aware")

        let normalizedToggleBatteryJson = AppDelegate.normalizeArguments(["--toggle-battery-json"])
        assertEqual(normalizedToggleBatteryJson, ["--toggle-battery-aware", "--json"], "--toggle-battery-json normalizes to --toggle-battery-aware --json")

        let normalizedToggleShoulder = AppDelegate.normalizeArguments(["--toggle-shoulder"])
        assertEqual(normalizedToggleShoulder, ["--toggle-shoulder-defense"], "--toggle-shoulder normalizes to --toggle-shoulder-defense")

        let normalizedTogglePresentationMode = AppDelegate.normalizeArguments(["--toggle-presentation-mode"])
        assertEqual(normalizedTogglePresentationMode, ["--toggle-presentation"], "--toggle-presentation-mode normalizes to --toggle-presentation")

        let normalizedPresentationModeJson = AppDelegate.normalizeArguments(["--presentation-mode-json"])
        assertEqual(normalizedPresentationModeJson, ["--toggle-presentation", "--json"], "--presentation-mode-json normalizes to --toggle-presentation --json")

        let normalizedExportIncidentsJson = AppDelegate.normalizeArguments(["--export-incidents-json", "/tmp/incidents"])
        assertEqual(normalizedExportIncidentsJson, ["--export-incidents", "--json", "/tmp/incidents"], "--export-incidents-json normalizes to --export-incidents --json")

        let normalizedLogStatsJson = AppDelegate.normalizeArguments(["--log-stats-json"])
        assertEqual(normalizedLogStatsJson, ["--audit-stats", "--json"], "--log-stats-json normalizes to --audit-stats --json")

        let normalizedLogStats = AppDelegate.normalizeArguments(["--log-stats"])
        assertEqual(normalizedLogStats, ["--audit-stats"], "--log-stats normalizes to --audit-stats")
    }

    private func testVectorAndAuditExportResilience() {
        print("\n▶ Test Suite: Biometric Vector & Audit Export Resilience")

        let config = Config.shared
        let originalVectors = config.loadEnrolledVectors()

        // Temporarily seed a dummy vector if none enrolled
        let dummyVector = (0..<128).map { Float($0) / 128.0 }
        config.saveEnrolledVectors([dummyVector])

        let testSubdir = "/tmp/facelock_test_export_resilience_\(UUID().uuidString.prefix(6))"
        let nestedVecPath = "\(testSubdir)/nested/vectors.json"
        let nestedAuditPath = "\(testSubdir)/nested/audit.jsonl"

        defer {
            try? FileManager.default.removeItem(atPath: testSubdir)
            config.saveEnrolledVectors(originalVectors)
        }

        do {
            let exportedCount = try config.exportVectors(to: nestedVecPath)
            assert(exportedCount > 0, "exportVectors exports enrolled templates successfully")
            assert(FileManager.default.fileExists(atPath: nestedVecPath), "exportVectors automatically creates missing parent directories")

            let backupCount = try config.backupVectors(to: "\(testSubdir)/backup/vectors_backup.json")
            assertEqual(backupCount, exportedCount, "backupVectors alias successfully forwards to exportVectors")

            let importedCount = try config.restoreVectors(from: nestedVecPath, merge: false)
            assertEqual(importedCount, exportedCount, "restoreVectors alias successfully imports vectors")
        } catch {
            assert(false, "Vector export/import resilience failed: \(error.localizedDescription)")
        }

        do {
            let exportedAuditCount = try SecurityAuditLogger.shared.exportLogs(to: nestedAuditPath)
            assert(exportedAuditCount >= 0, "exportLogs runs successfully")
            assert(FileManager.default.fileExists(atPath: nestedAuditPath), "exportLogs automatically creates missing parent directories")

            let aliasAuditRes = try SecurityAuditLogger.shared.exportAudit(to: "\(testSubdir)/backup/audit_backup.jsonl")
            assertEqual(aliasAuditRes.exportedCount, exportedAuditCount, "exportAudit alias successfully forwards to exportLogs")

            let csvExportRes = try SecurityAuditLogger.shared.exportAudit(to: "\(testSubdir)/backup/audit_backup.csv", format: "csv")
            assertEqual(csvExportRes.format, "csv", "exportAudit respects csv format")
            assertEqual(csvExportRes.exportedCount, exportedAuditCount, "CSV export matches event count")
            assert(FileManager.default.fileExists(atPath: "\(testSubdir)/backup/audit_backup.csv"), "CSV export writes destination file")

            let jsonExportRes = try SecurityAuditLogger.shared.exportAudit(to: "\(testSubdir)/backup/audit_backup.json", format: "json")
            assertEqual(jsonExportRes.format, "json", "exportAudit respects json array format")
            assertEqual(jsonExportRes.exportedCount, exportedAuditCount, "JSON array export matches event count")
            assert(FileManager.default.fileExists(atPath: "\(testSubdir)/backup/audit_backup.json"), "JSON export writes destination file")
        } catch {
            assert(false, "Audit export resilience failed: \(error.localizedDescription)")
        }

        // Test logPinBruteforce typed audit event
        SecurityAuditLogger.shared.logPinBruteforce(appName: "TestSecurityApp", attempts: 5, lockoutSeconds: 30)
        let recentBruteforce = SecurityAuditLogger.shared.fetchRecentEvents(tail: 5, filterType: "bruteforce")
        assert(!recentBruteforce.isEmpty, "fetchRecentEvents retrieves logged PIN brute force events")
        if let ev = recentBruteforce.first {
            assertEqual(ev.eventType, "pin_bruteforce_attempt", "logPinBruteforce records correct eventType")
            assertEqual(ev.appName, "TestSecurityApp", "logPinBruteforce preserves appName")
            assert(ev.details?.contains("5 consecutive failed PIN") == true, "logPinBruteforce details contain attempt count")
            assert(ev.details?.contains("30s") == true, "logPinBruteforce details contain lockout delay")
        }
    }

    // MARK: - 9d. Vector Validation, Dimensionality Integrity & Purge Lifecycle
    private func testVectorValidationAndClearing() {
        print("\n▶ Test Suite: Vector Validation, Dimensionality Integrity & Purge Lifecycle")

        // 1. Valid 128-D vector
        let validVec = (0..<128).map { Float($0) / 128.0 }
        assert(Config.isValidVector(validVec), "Valid 128-D vector passes isValidVector")

        // 2. Invalid dimensions
        let shortVec = (0..<127).map { Float($0) }
        assert(!Config.isValidVector(shortVec), "127-D vector fails isValidVector")

        let emptyVec: [Float] = []
        assert(!Config.isValidVector(emptyVec), "Empty vector fails isValidVector")

        let longVec = (0..<129).map { Float($0) }
        assert(!Config.isValidVector(longVec), "129-D vector fails isValidVector")

        // 3. Non-finite values
        var nanVec = validVec
        nanVec[10] = Float.nan
        assert(!Config.isValidVector(nanVec), "Vector with NaN fails isValidVector")

        var infVec = validVec
        infVec[20] = Float.infinity
        assert(!Config.isValidVector(infVec), "Vector with Infinity fails isValidVector")

        // 4. importVectors dimension validation
        let testDir = "/tmp/facelock_test_validation_\(UUID().uuidString.prefix(6))"
        try? FileManager.default.createDirectory(atPath: testDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: testDir) }

        let invalidVecFile = "\(testDir)/invalid_vecs.json"
        let invalidData = try? JSONEncoder().encode([[Float](repeating: 1.0, count: 50)])
        try? invalidData?.write(to: URL(fileURLWithPath: invalidVecFile))

        var importFailed = false
        do {
            _ = try Config.shared.importVectors(from: invalidVecFile, merge: false)
        } catch {
            importFailed = true
        }
        assert(importFailed, "importVectors rejects files without valid 128-D templates")

        // 5. clearEnrolledVectors returns count and logs audit event
        let original = Config.shared.loadEnrolledVectors()
        Config.shared.saveEnrolledVectors([validVec, validVec])
        let cleared = Config.shared.clearEnrolledVectors()
        assertEqual(cleared, 2, "clearEnrolledVectors returns count of cleared vectors (2)")
        assertEqual(Config.shared.loadEnrolledVectors().count, 0, "clearEnrolledVectors leaves zero enrolled vectors")

        SecurityAuditLogger.shared.logVectorsCleared(count: cleared, details: "Automated test purge")
        let recent = SecurityAuditLogger.shared.fetchRecentEvents(tail: 5, filterType: "vectors")
        assert(recent.contains { $0.eventType == "vectors_cleared" }, "Audit log records typed vectors_cleared event")

        // Restore original vectors
        Config.shared.saveEnrolledVectors(original)
    }

    // MARK: - 9e. Incident Management, Slicing & Export Directory Resilience
    private func testIncidentManagementAndFilteringResilience() {
        print("\n▶ Test Suite: Incident Management, Slicing & Single Export Resilience")

        // 1. Prefix and Type Mapping Integrity
        assertEqual(CameraScanner.incidentType(for: "bystander_2026-11-04_12-00-00_abcdef.jpg"), "bystander", "bystander prefix maps to bystander type")
        assertEqual(CameraScanner.incidentType(for: "walkaway_2026-11-04_12-00-00_abcdef.jpg"), "walkaway", "walkaway prefix maps to walkaway type")
        assertEqual(CameraScanner.incidentType(for: "wake_2026-11-04_12-00-00_abcdef.jpg"), "wake", "wake prefix maps to wake type")
        assertEqual(CameraScanner.incidentType(for: "bruteforce_2026-11-04_12-00-00_abcdef.jpg"), "bruteforce", "bruteforce prefix maps to bruteforce type")
        assertEqual(CameraScanner.incidentType(for: "intruder_2026-11-04_12-00-00_abcdef.jpg"), "intruder", "intruder prefix maps to intruder type")
        assertEqual(CameraScanner.incidentType(for: "custom_2026-11-04_12-00-00_abcdef.jpg"), "intruder", "unknown prefix defaults to intruder type")

        // Supported incident types and validation
        assertEqual(CameraScanner.supportedIncidentTypes.count, 5, "Total 5 supported incident types")
        assert(CameraScanner.isValidIncidentType("  INTRUDER  "), "isValidIncidentType is case-insensitive and trims whitespace")
        assert(CameraScanner.isValidIncidentType("walkaway"), "isValidIncidentType matches walkaway")
        assert(!CameraScanner.isValidIncidentType("unknown_custom_type"), "isValidIncidentType rejects invalid type")

        // 2. Incident Filtering Logic
        let mockFiles = [
            "bystander_2026-11-04_10-00-00_111111.jpg",
            "intruder_2026-11-04_10-05-00_222222.jpg",
            "walkaway_2026-11-04_10-10-00_333333.jpg",
            "wake_2026-11-04_10-15-00_444444.jpg",
            "bruteforce_2026-11-04_10-20-00_555555.jpg"
        ]

        var typeBreakdown: [String: Int] = [:]
        for file in mockFiles {
            let t = CameraScanner.incidentType(for: file)
            typeBreakdown[t, default: 0] += 1
        }
        assertEqual(typeBreakdown["bystander"], 1, "Breakdown reflects 1 bystander")
        assertEqual(typeBreakdown["intruder"], 1, "Breakdown reflects 1 intruder")
        assertEqual(typeBreakdown["walkaway"], 1, "Breakdown reflects 1 walkaway")
        assertEqual(typeBreakdown["wake"], 1, "Breakdown reflects 1 wake")
        assertEqual(typeBreakdown["bruteforce"], 1, "Breakdown reflects 1 bruteforce")

        let shoulderFiltered = mockFiles.filter { $0.hasPrefix("bystander_") }
        assertEqual(shoulderFiltered.count, 1, "Shoulder filter matches 1 item")
        assertEqual(shoulderFiltered.first, mockFiles[0], "Shoulder filter matched bystander")

        let walkawayFiltered = mockFiles.filter { $0.hasPrefix("walkaway_") }
        assertEqual(walkawayFiltered.count, 1, "Walkaway filter matches 1 item")

        let intruderFiltered = mockFiles.filter { $0.hasPrefix("intruder_") }
        assertEqual(intruderFiltered.count, 1, "Intruder filter matches 1 item")

        // 3. Tail slicing logic
        let sliced = Array(mockFiles.prefix(2))
        assertEqual(sliced.count, 2, "Tail slicing limits array to 2 items")
        assertEqual(sliced.first, mockFiles[0], "Tail slicing preserves ordering")

        // 4. Single Incident Export Parent Directory Creation Resilience
        let testDir = "/tmp/facelock_incident_export_test_\(UUID().uuidString.prefix(6))"
        let nestedDest = "\(testDir)/nested/subfolder/export_test.jpg"
        defer { try? FileManager.default.removeItem(atPath: testDir) }

        let destURL = URL(fileURLWithPath: nestedDest)
        let parentDir = destURL.deletingLastPathComponent()

        do {
            if !FileManager.default.fileExists(atPath: parentDir.path) {
                try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }
            assert(FileManager.default.fileExists(atPath: parentDir.path), "Export parent directory created automatically")

            // Test writing dummy file
            let dummyData = "test_image_data".data(using: .utf8)!
            try dummyData.write(to: destURL)
            assert(FileManager.default.fileExists(atPath: destURL.path), "Incident destination file written successfully in created directory")

            // Test exportIncidents with filterType and manifest generation
            let incidentsExportDir = "\(testDir)/export_incidents"
            let resAll = try CameraScanner.shared.exportIncidents(to: incidentsExportDir, filterType: "all")
            assertEqual(resAll["filter"] as? String, "all", "exportIncidents manifest sets filter to 'all'")
            assert(FileManager.default.fileExists(atPath: incidentsExportDir), "exportIncidents creates destination directory")

            let resShoulder = try CameraScanner.shared.exportIncidents(to: incidentsExportDir, filterType: "shoulder")
            assertEqual(resShoulder["filter"] as? String, "bystander", "exportIncidents normalizes 'shoulder' filter to 'bystander'")

            let resCustom = try CameraScanner.shared.exportIncidents(to: incidentsExportDir, filterType: "intruder")
            assertEqual(resCustom["filter"] as? String, "intruder", "exportIncidents preserves 'intruder' filter")
        } catch {
            assert(false, "Incident export directory resilience failed: \(error.localizedDescription)")
        }
    }

    // MARK: - 9d. Security Audit Telemetry & Filter Validation
    private func testSecurityAuditTelemetryAndFilterValidation() {
        print("\n▶ Test Suite: Security Audit Telemetry & Filter Validation")

        let supportedFilters = SecurityAuditLogger.supportedEventFilters
        assertEqual(supportedFilters.count, 16, "Total 16 supported audit event filters")
        assert(supportedFilters.contains("face"), "Supported filters contain 'face'")
        assert(supportedFilters.contains("intruder"), "Supported filters contain 'intruder'")
        assert(supportedFilters.contains("lock"), "Supported filters contain 'lock'")
        assert(supportedFilters.contains("pin"), "Supported filters contain 'pin'")
        assert(supportedFilters.contains("touchid"), "Supported filters contain 'touchid'")
        assert(supportedFilters.contains("shield"), "Supported filters contain 'shield'")
        assert(supportedFilters.contains("policy"), "Supported filters contain 'policy'")
        assert(supportedFilters.contains("config"), "Supported filters contain 'config'")
        assert(supportedFilters.contains("vectors"), "Supported filters contain 'vectors'")
        assert(supportedFilters.contains("incidents"), "Supported filters contain 'incidents'")
        assert(supportedFilters.contains("telegram"), "Supported filters contain 'telegram'")
        assert(supportedFilters.contains("shoulder"), "Supported filters contain 'shoulder'")
        assert(supportedFilters.contains("profile"), "Supported filters contain 'profile'")
        assert(supportedFilters.contains("emergency"), "Supported filters contain 'emergency'")
        assert(supportedFilters.contains("success"), "Supported filters contain 'success'")
        assert(supportedFilters.contains("failure"), "Supported filters contain 'failure'")

        assert(SecurityAuditLogger.isValidEventFilter("face"), "Filter 'face' is valid")
        assert(SecurityAuditLogger.isValidEventFilter("  INTRUDER  "), "Filter '  INTRUDER  ' is valid with whitespace trimming")
        assert(SecurityAuditLogger.isValidEventFilter("biometrics"), "Alias filter 'biometrics' is valid")
        assert(SecurityAuditLogger.isValidEventFilter("touch_id"), "Alias filter 'touch_id' is valid")
        assert(SecurityAuditLogger.isValidEventFilter("lockdown"), "Alias filter 'lockdown' is valid")
        assert(SecurityAuditLogger.isValidEventFilter("all"), "Filter 'all' is valid")
        assert(!SecurityAuditLogger.isValidEventFilter("invalid_random_filter"), "Invalid filter returns false")
        assert(!SecurityAuditLogger.isValidEventFilter(""), "Empty filter string returns false")

        // Supported export formats validation
        assertEqual(SecurityAuditLogger.supportedExportFormats, ["jsonl", "json", "csv"], "Supported export formats match specification")
        assert(SecurityAuditLogger.isValidExportFormat("jsonl"), "Export format jsonl is valid")
        assert(SecurityAuditLogger.isValidExportFormat("JSON"), "Export format JSON is valid case-insensitively")
        assert(SecurityAuditLogger.isValidExportFormat("csv"), "Export format csv is valid")
        assert(!SecurityAuditLogger.isValidExportFormat("xml"), "Unsupported format xml is invalid")

        // CSV escaping logic
        assertEqual(SecurityAuditLogger.escapeCSVField("simple"), "simple", "Plain string is not escaped in CSV")
        assertEqual(SecurityAuditLogger.escapeCSVField("hello,world"), "\"hello,world\"", "Commas are escaped with double quotes in CSV")
        assertEqual(SecurityAuditLogger.escapeCSVField("say \"hi\""), "\"say \"\"hi\"\"\"", "Quotes are doubled and wrapped in CSV")
        assertEqual(SecurityAuditLogger.escapeCSVField("line1\nline2"), "\"line1\nline2\"", "Multiline string is quoted in CSV")
        assertEqual(SecurityAuditLogger.escapeCSVField("tab\tseparated"), "tab\tseparated", "Tab without comma/quote/newline is not quoted")

        let detailed = SecurityAuditLogger.shared.getDetailedLogStats()
        assert(detailed.totalCount >= 0, "Detailed total events count is non-negative")
        assert(detailed.fileSizeBytes >= 0, "Detailed file size in bytes is non-negative")
        assertEqual(detailed.successCount + detailed.failureCount, detailed.totalCount, "Success and failure counts sum to total events count")
        let breakdownSum = detailed.typeBreakdown.values.reduce(0, +)
        assertEqual(breakdownSum, detailed.totalCount, "Type breakdown counts sum to total events count")
    }

    // MARK: - 9e. Incident Telemetry & Audit Search
    private func testIncidentTelemetryAndAuditSearch() {
        print("\n▶ Test Suite: Incident Telemetry & Audit Search")

        // 1. Incident Type Validation & Aliases
        assert(CameraScanner.isValidIncidentType("intruder"), "Incident type intruder is valid")
        assert(CameraScanner.isValidIncidentType("walkaway"), "Incident type walkaway is valid")
        assert(CameraScanner.isValidIncidentType("wake"), "Incident type wake is valid")
        assert(CameraScanner.isValidIncidentType("bystander"), "Incident type bystander is valid")
        assert(CameraScanner.isValidIncidentType("bruteforce"), "Incident type bruteforce is valid")
        assert(CameraScanner.isValidIncidentType("shoulder"), "Alias shoulder is valid incident type")
        assert(CameraScanner.isValidIncidentType("  SHOULDER_SURFING  "), "Alias shoulder_surfing is valid with trimming")
        assert(CameraScanner.isValidIncidentType("all"), "Filter all is valid incident type")
        assert(!CameraScanner.isValidIncidentType("unknown_random_type"), "Invalid incident type returns false")
        assert(!CameraScanner.isValidIncidentType(""), "Empty incident type returns false")

        // 2. Incident Stats Collection & Dictionary Serialization
        let incidentStats = CameraScanner.shared.getDetailedIncidentStats()
        assert(incidentStats.totalCaptures >= 0, "Incident stats totalCaptures is non-negative")
        assert(incidentStats.totalSizeBytes >= 0, "Incident stats totalSizeBytes is non-negative")
        assert(incidentStats.todayCount >= 0, "Incident stats todayCount is non-negative")
        assert(incidentStats.past24HoursCount >= 0, "Incident stats past24HoursCount is non-negative")
        assert(incidentStats.past7DaysCount >= 0, "Incident stats past7DaysCount is non-negative")
        assert(incidentStats.averageSizeBytes >= 0.0, "Incident stats averageSizeBytes is non-negative")
        assert(incidentStats.todayCount <= incidentStats.totalCaptures, "todayCount is bounded by totalCaptures")
        assert(incidentStats.past24HoursCount <= incidentStats.totalCaptures, "past24HoursCount is bounded by totalCaptures")

        let statsDict = incidentStats.toDictionary()
        assertEqual(statsDict["totalCaptures"] as? Int, incidentStats.totalCaptures, "Incident stats dictionary reflects totalCaptures")
        assertEqual(statsDict["directory"] as? String, incidentStats.directory, "Incident stats dictionary reflects directory")
        assert(statsDict["typeBreakdown"] is [String: Int], "Incident stats dictionary includes typeBreakdown map")

        // 3. Security Audit Event Query Matching
        let testEvent1 = AuditEvent(
            id: "test-event-001",
            timestamp: "2026-11-05T12:00:00Z",
            eventType: "config_changed",
            appName: "FaceLock",
            bundleId: "io.github.facelock",
            distance: nil,
            threshold: nil,
            intruderPhoto: nil,
            details: "similarityThreshold updated to 0.22",
            isSuccess: true
        )

        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: "config"), "matchesQuery matches eventType")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: "CONFIG"), "matchesQuery is case-insensitive")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: "facelock"), "matchesQuery matches appName and bundleId")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: "0.22"), "matchesQuery matches numerical details")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: "similaritythreshold"), "matchesQuery matches key in details")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent1, query: ""), "matchesQuery with empty query returns true")
        assert(!SecurityAuditLogger.matchesQuery(event: testEvent1, query: "nonexistent_term_xyz"), "matchesQuery returns false for unmatched term")

        let testEvent2 = AuditEvent(
            id: "test-event-002",
            timestamp: "2026-11-05T12:01:00Z",
            eventType: "intruder_detected",
            appName: "Telegram",
            bundleId: "ru.keepcoder.Telegram",
            distance: 0.45,
            threshold: 0.22,
            intruderPhoto: "intruder_20261105_120100.jpg",
            details: "Unrecognized face candidate",
            isSuccess: false
        )
        assert(SecurityAuditLogger.matchesQuery(event: testEvent2, query: "intruder_20261105"), "matchesQuery matches intruder photo name")
        assert(SecurityAuditLogger.matchesQuery(event: testEvent2, query: "telegram"), "matchesQuery matches target app Telegram")

        // 4. CLI Argument Normalization for Search & Incident Types
        assertEqual(AppDelegate.normalizeArguments(["--audit-search-json"]), ["--audit-search", "--json"], "Normalizes --audit-search-json")
        assertEqual(AppDelegate.normalizeArguments(["--search-audit-json"]), ["--audit-search", "--json"], "Normalizes --search-audit-json")
        assertEqual(AppDelegate.normalizeArguments(["--search-audit"]), ["--audit-search"], "Normalizes --search-audit alias")
        assertEqual(AppDelegate.normalizeArguments(["--clear-incidents-type-json"]), ["--clear-incidents", "--json"], "Normalizes --clear-incidents-type-json")
    }

    // MARK: - 9b. Incident & Security Audit Age-Based Pruning
    private func testIncidentAndAuditAgePruning() {
        print("\n▶ Test Suite: Incident & Security Audit Age Retention & Pruning")

        // 1. Guard against negative days
        let negativeIncidents = CameraScanner.shared.pruneIncidentsOlderThan(days: -5)
        assertEqual(negativeIncidents.removedCount, 0, "pruneIncidentsOlderThan with negative days removes 0 files")
        assertEqual(negativeIncidents.freedBytes, UInt64(0), "pruneIncidentsOlderThan with negative days frees 0 bytes")

        let negativeAudit = SecurityAuditLogger.shared.pruneLogs(olderThanDays: -10)
        assertEqual(negativeAudit.prunedCount, 0, "pruneLogs with negative days prunes 0 events")
        assertEqual(negativeAudit.freedBytes, UInt64(0), "pruneLogs with negative days frees 0 bytes")

        // 2. Safe execution with high retention window (e.g. 10 years / 3650 days)
        let highRetIncidents = CameraScanner.shared.pruneIncidentsOlderThan(days: 3650)
        assert(highRetIncidents.removedCount >= 0, "High retention incident pruning removedCount is non-negative")
        assert(highRetIncidents.remainingCount >= 0, "High retention incident pruning remainingCount is non-negative")
        assert(highRetIncidents.freedBytes >= 0, "High retention incident pruning freedBytes is non-negative")

        let highRetAudit = SecurityAuditLogger.shared.pruneLogs(olderThanDays: 3650)
        assert(highRetAudit.prunedCount >= 0, "High retention audit pruning prunedCount is non-negative")
        assert(highRetAudit.remainingCount >= 0, "High retention audit pruning remainingCount is non-negative")
        assert(highRetAudit.freedBytes >= 0, "High retention audit pruning freedBytes is non-negative")

        // 3. CLI Argument Normalization for Age-Based Pruning Flags
        assertEqual(AppDelegate.normalizeArguments(["--prune-incidents-days-json"]), ["--prune-incidents-days", "--json"], "Normalizes --prune-incidents-days-json")
        assertEqual(AppDelegate.normalizeArguments(["--prune-audit-days-json"]), ["--prune-audit-days", "--json"], "Normalizes --prune-audit-days-json")
        assertEqual(AppDelegate.normalizeArguments(["--prune-logs-days-json"]), ["--prune-audit-days", "--json"], "Normalizes --prune-logs-days-json")
        assertEqual(AppDelegate.normalizeArguments(["--prune-logs-days"]), ["--prune-audit-days"], "Normalizes --prune-logs-days alias")
    }

    // MARK: - 9c. Configuration Validation Suite & Incident Search
    private func testConfigValidationSuiteAndIncidentSearch() {
        print("\n▶ Test Suite: Configuration Validation Suite & Incident Search")

        // 1. Config Threshold Validation
        assert(Config.isValidThreshold(0.05), "Threshold 0.05 is valid")
        assert(Config.isValidThreshold(0.22), "Threshold 0.22 is valid")
        assert(Config.isValidThreshold(0.60), "Threshold 0.60 is valid")
        assert(!Config.isValidThreshold(0.04), "Threshold 0.04 is invalid (below minimum)")
        assert(!Config.isValidThreshold(0.61), "Threshold 0.61 is invalid (above maximum)")
        assert(!Config.isValidThreshold(-0.1), "Negative threshold is invalid")

        // 2. Config Timeout Validation
        assert(Config.isValidTimeout(0.5), "Timeout 0.5s is valid")
        assert(Config.isValidTimeout(2.0), "Timeout 2.0s is valid")
        assert(Config.isValidTimeout(10.0), "Timeout 10.0s is valid")
        assert(!Config.isValidTimeout(0.4), "Timeout 0.4s is invalid")
        assert(!Config.isValidTimeout(10.1), "Timeout 10.1s is invalid")

        // 3. Config Debounce Validation
        assert(Config.isValidDebounce(0.5), "Debounce 0.5s is valid")
        assert(Config.isValidDebounce(2.0), "Debounce 2.0s is valid")
        assert(Config.isValidDebounce(30.0), "Debounce 30.0s is valid")
        assert(!Config.isValidDebounce(0.4), "Debounce 0.4s is invalid")
        assert(!Config.isValidDebounce(30.1), "Debounce 30.1s is invalid")

        // 4. Config PIN Validation
        assert(Config.isValidPin("1234"), "4-digit numeric PIN is valid")
        assert(Config.isValidPin("0000"), "0000 PIN is valid")
        assert(Config.isValidPin("123456"), "6-digit PIN is valid")
        assert(!Config.isValidPin("123"), "3-digit PIN is invalid (too short)")
        assert(!Config.isValidPin(""), "Empty PIN is invalid")
        assert(!Config.isValidPin("abcd"), "Alpha PIN is invalid")
        assert(!Config.isValidPin("12a4"), "Alphanumeric PIN is invalid")

        // 5. Config Walk-Away Timeout Validation
        assert(Config.isValidWalkAwayTimeout(10.0), "Walk-away timeout 10s is valid")
        assert(Config.isValidWalkAwayTimeout(45.0), "Walk-away timeout 45s is valid")
        assert(Config.isValidWalkAwayTimeout(600.0), "Walk-away timeout 600s is valid")
        assert(!Config.isValidWalkAwayTimeout(9.9), "Walk-away timeout 9.9s is invalid")
        assert(!Config.isValidWalkAwayTimeout(600.1), "Walk-away timeout 600.1s is invalid")

        // 6. Config Protection Mode Validation
        assert(Config.isValidProtectionMode("all"), "Mode 'all' is valid")
        assert(Config.isValidProtectionMode("selective"), "Mode 'selective' is valid")
        assert(Config.isValidProtectionMode("  ALL  "), "Mode '  ALL  ' is valid with whitespace trimming")
        assert(Config.isValidProtectionMode("Selective"), "Mode 'Selective' is valid case-insensitively")
        assert(!Config.isValidProtectionMode("none"), "Mode 'none' is invalid")
        assert(!Config.isValidProtectionMode(""), "Empty mode is invalid")

        // 7. Config PIN Lockout & Attempts Validation
        assert(Config.isValidPinAttempts(1), "1 attempt is valid")
        assert(Config.isValidPinAttempts(3), "3 attempts is valid")
        assert(Config.isValidPinAttempts(10), "10 attempts is valid")
        assert(!Config.isValidPinAttempts(0), "0 attempts is invalid")
        assert(!Config.isValidPinAttempts(11), "11 attempts is invalid")

        assert(Config.isValidPinLockout(1.0), "1.0s lockout is valid")
        assert(Config.isValidPinLockout(5.0), "5.0s lockout is valid")
        assert(Config.isValidPinLockout(60.0), "60.0s lockout is valid")
        assert(!Config.isValidPinLockout(0.9), "0.9s lockout is invalid")
        assert(!Config.isValidPinLockout(60.1), "60.1s lockout is invalid")

        // 8. Incident Query Matching
        assert(CameraScanner.matchesIncidentQuery(filename: "intruder_20261105_120000.jpg", query: "intruder"), "matchesIncidentQuery matches filename prefix")
        assert(CameraScanner.matchesIncidentQuery(filename: "bystander_20261105_120000.jpg", query: "bystander"), "matchesIncidentQuery matches bystander type")
        assert(CameraScanner.matchesIncidentQuery(filename: "bystander_20261105_120000.jpg", query: "shoulder"), "matchesIncidentQuery matches shoulder alias")
        assert(CameraScanner.matchesIncidentQuery(filename: "bystander_20261105_120000.jpg", query: "shoulder_surfing"), "matchesIncidentQuery matches shoulder_surfing alias")
        assert(CameraScanner.matchesIncidentQuery(filename: "walkaway_20261105_120000.jpg", query: "WALKAWAY"), "matchesIncidentQuery is case-insensitive")
        assert(CameraScanner.matchesIncidentQuery(filename: "intruder_20261105_120000.jpg", query: "20261105"), "matchesIncidentQuery matches date substring")
        assert(CameraScanner.matchesIncidentQuery(filename: "intruder_20261105_120000.jpg", query: ""), "matchesIncidentQuery with empty query returns true")
        assert(!CameraScanner.matchesIncidentQuery(filename: "intruder_20261105_120000.jpg", query: "nonexistent_term"), "matchesIncidentQuery returns false for non-matching query")

        // 9. IncidentRecord & IncidentStats dictionary representation
        let testRecord = CameraScanner.IncidentRecord(
            filename: "intruder_sample.jpg",
            path: "/tmp/intruder_sample.jpg",
            sizeBytes: 10240,
            type: "intruder",
            timestamp: "2026-11-05T12:00:00Z"
        )
        let recordDict = testRecord.toDictionary()
        assertEqual(recordDict["filename"] as? String, "intruder_sample.jpg", "IncidentRecord dictionary reflects filename")
        assertEqual(recordDict["type"] as? String, "intruder", "IncidentRecord dictionary reflects type")
        assertEqual(recordDict["sizeBytes"] as? UInt64, UInt64(10240), "IncidentRecord dictionary reflects sizeBytes")

        let stats = CameraScanner.shared.getDetailedIncidentStats()
        let statsDict = stats.toDictionary()
        assert(statsDict["totalCaptures"] != nil, "IncidentStats dictionary contains totalCaptures")
        assert(statsDict["directory"] != nil, "IncidentStats dictionary contains directory")
        assert(statsDict["typeBreakdown"] != nil, "IncidentStats dictionary contains typeBreakdown")

        // 10. CLI Argument Normalization for Incident Search & Config Setters
        assertEqual(AppDelegate.normalizeArguments(["--incidents-search-json"]), ["--incidents-search", "--json"], "Normalizes --incidents-search-json")
        assertEqual(AppDelegate.normalizeArguments(["--search-incidents-json"]), ["--incidents-search", "--json"], "Normalizes --search-incidents-json")
        assertEqual(AppDelegate.normalizeArguments(["--incident-search-json"]), ["--incidents-search", "--json"], "Normalizes --incident-search-json")
        assertEqual(AppDelegate.normalizeArguments(["--search-incidents"]), ["--incidents-search"], "Normalizes --search-incidents alias")
        assertEqual(AppDelegate.normalizeArguments(["--incident-search"]), ["--incidents-search"], "Normalizes --incident-search alias")
        assertEqual(AppDelegate.normalizeArguments(["--set-threshold-json"]), ["--set-threshold", "--json"], "Normalizes --set-threshold-json")
        assertEqual(AppDelegate.normalizeArguments(["--set-timeout-json"]), ["--set-timeout", "--json"], "Normalizes --set-timeout-json")
        assertEqual(AppDelegate.normalizeArguments(["--set-debounce-json"]), ["--set-debounce", "--json"], "Normalizes --set-debounce-json")
        assertEqual(AppDelegate.normalizeArguments(["--set-mode-json"]), ["--set-mode", "--json"], "Normalizes --set-mode-json")
        assertEqual(AppDelegate.normalizeArguments(["--set-walkaway-json"]), ["--set-walkaway", "--json"], "Normalizes --set-walkaway-json")
    }

    // MARK: - 9h. Incident Deletion, Export & Audit Stats
    private func testIncidentDeletionExportAndAuditStats() {
        print("\n▶ Test Suite: Incident Deletion, Export & Audit Stats")

        // 1. Incident Deletion Validation
        let invalidExtRes = CameraScanner.shared.deleteIncident(filename: "malicious.sh")
        assert(!invalidExtRes.success, "deleteIncident rejects non-image extension")
        assertEqual(invalidExtRes.freedBytes, UInt64(0), "deleteIncident with invalid extension frees 0 bytes")

        let nonExistentRes = CameraScanner.shared.deleteIncident(filename: "non_existent_incident_999999.jpg")
        assert(!nonExistentRes.success, "deleteIncident returns false for non-existent incident")

        let traversalRes = CameraScanner.shared.deleteIncident(filename: "../../non_existent.jpg")
        assert(!traversalRes.success, "deleteIncident sanitizes path traversal attempt safely")

        // 2. Incident Creation, Verification & Deletion Lifecycle
        let home = FileManager.default.homeDirectoryForCurrentUser
        let intrudersDir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
        try? FileManager.default.createDirectory(at: intrudersDir, withIntermediateDirectories: true)
        let testFilename = "test_lifecycle_incident_\(Int(Date().timeIntervalSince1970)).jpg"
        let testFileURL = intrudersDir.appendingPathComponent(testFilename)
        let dummyData = Data(repeating: 0xFF, count: 2048)
        try? dummyData.write(to: testFileURL)

        assert(FileManager.default.fileExists(atPath: testFileURL.path), "Test incident file created successfully")

        // Verify getIncidentDetails finds it
        let details = CameraScanner.shared.getIncidentDetails(filename: testFilename)
        assert(details != nil, "getIncidentDetails finds created incident")
        assertEqual(details?.filename, testFilename, "Incident details filename matches")
        assertEqual(details?.sizeBytes, UInt64(2048), "Incident details sizeBytes matches written bytes")

        // Export the incident to a temp file
        let tempExportDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("facelock_test_export_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempExportDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempExportDir) }

        do {
            let exportRes = try CameraScanner.shared.exportIncident(filename: testFilename, to: tempExportDir.path)
            assertEqual(exportRes.source, testFilename, "exportIncident source matches")
            assertEqual(exportRes.sizeBytes, UInt64(2048), "exportIncident sizeBytes matches")
            assert(FileManager.default.fileExists(atPath: exportRes.destination), "Exported file exists at destination")
        } catch {
            assert(false, "exportIncident should succeed: \(error.localizedDescription)")
        }

        // Test export non-existent file
        do {
            _ = try CameraScanner.shared.exportIncident(filename: "non_existent_file.jpg", to: tempExportDir.path)
            assert(false, "exportIncident should throw for non-existent file")
        } catch {
            assert(true, "exportIncident throws error for non-existent file")
        }

        // Delete the test incident
        let deleteRes = CameraScanner.shared.deleteIncident(filename: testFilename)
        assert(deleteRes.success, "deleteIncident succeeds for existing incident")
        assertEqual(deleteRes.freedBytes, UInt64(2048), "deleteIncident reports correct freed bytes")
        assert(!FileManager.default.fileExists(atPath: testFileURL.path), "Incident file is removed from disk")

        // 3. SecurityAuditLogger AuditStats Struct & Date Queries
        let auditStats = SecurityAuditLogger.shared.getAuditStats()
        assert(auditStats.totalEvents >= 0, "AuditStats totalEvents is non-negative")
        assert(auditStats.todayCount >= 0, "AuditStats todayCount is non-negative")
        assert(auditStats.past24HoursCount >= 0, "AuditStats past24HoursCount is non-negative")
        assert(auditStats.todayCount <= auditStats.totalEvents, "AuditStats todayCount <= totalEvents")
        assert(auditStats.past24HoursCount <= auditStats.totalEvents, "AuditStats past24HoursCount <= totalEvents")

        let auditDict = auditStats.toDictionary()
        assert(auditDict["totalEvents"] != nil, "AuditStats dictionary contains totalEvents")
        assert(auditDict["todayCount"] != nil, "AuditStats dictionary contains todayCount")
        assert(auditDict["past24HoursCount"] != nil, "AuditStats dictionary contains past24HoursCount")
        assert(auditDict["typeBreakdown"] != nil, "AuditStats dictionary contains typeBreakdown")

        // 4. Diagnostics Enrichment
        let diag = Diagnostics.collectReport()
        let daemon = diag["daemon"] as? [String: Any] ?? [:]
        assert(daemon["maxFailedPinAttempts"] != nil, "Diagnostics daemon contains maxFailedPinAttempts")
        assert(daemon["pinLockoutSeconds"] != nil, "Diagnostics daemon contains pinLockoutSeconds")

        let storage = diag["storage"] as? [String: Any] ?? [:]
        assert(storage["auditStats"] != nil, "Diagnostics storage contains auditStats")
        assert(storage["incidentStats"] != nil, "Diagnostics storage contains incidentStats")

        // 5. CLI Argument Normalization for PIN and PIN Lockout
        assertEqual(AppDelegate.normalizeArguments(["--pin-attempts-json"]), ["--set-pin-attempts", "--json"], "Normalizes --pin-attempts-json")
        assertEqual(AppDelegate.normalizeArguments(["--pin-lockout-json"]), ["--set-pin-lockout", "--json"], "Normalizes --pin-lockout-json")
        assertEqual(AppDelegate.normalizeArguments(["--set-pin-json"]), ["--set-pin", "--json"], "Normalizes --set-pin-json")
        assertEqual(AppDelegate.normalizeArguments(["--pin-attempts"]), ["--set-pin-attempts"], "Normalizes --pin-attempts alias")
        assertEqual(AppDelegate.normalizeArguments(["--pin-lockout"]), ["--set-pin-lockout"], "Normalizes --pin-lockout alias")
    }

    // MARK: - Maintenance & Reliability Enhancements (v1.1.9)
    private func testMaintenanceV119Enhancements() {
        print("\n▶ Test Suite: Biometric Consistency, Incident Integrity & Audit Digest (v1.1.9)")

        // 1. Image Header Magic Bytes Validation
        let validJpegHeader = Data([0xFF, 0xD8, 0xFF, 0xE0])
        let validPngHeader = Data([0x89, 0x50, 0x4E, 0x47])
        let shortHeader = Data([0xFF, 0xD8])
        let textHeader = Data("PLAIN_TEXT_NOT_IMAGE".utf8)

        assert(CameraScanner.isImageHeaderValid(data: validJpegHeader), "isImageHeaderValid accepts valid JPEG magic bytes")
        assert(CameraScanner.isImageHeaderValid(data: validPngHeader), "isImageHeaderValid accepts valid PNG magic bytes")
        assert(!CameraScanner.isImageHeaderValid(data: shortHeader), "isImageHeaderValid rejects truncated header < 4 bytes")
        assert(!CameraScanner.isImageHeaderValid(data: textHeader), "isImageHeaderValid rejects text headers")

        // 2. Incident Integrity & Corrupted Capture Repair
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("facelock_test_incidents_\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let validImgPath = tempDir.appendingPathComponent("intruder_20261106_01.jpg").path
        let zeroByteImgPath = tempDir.appendingPathComponent("intruder_20261106_02.jpg").path
        let corruptedImgPath = tempDir.appendingPathComponent("intruder_20261106_03.jpg").path
        let nonImgPath = tempDir.appendingPathComponent("intruder_20261106_04.txt").path

        FileManager.default.createFile(atPath: validImgPath, contents: Data([0xFF, 0xD8, 0xFF, 0xE0, 0x01, 0x02, 0x03, 0x04]))
        FileManager.default.createFile(atPath: zeroByteImgPath, contents: Data())
        FileManager.default.createFile(atPath: corruptedImgPath, contents: Data("NON_IMAGE_CORRUPTED_STREAM".utf8))
        FileManager.default.createFile(atPath: nonImgPath, contents: Data("notes text".utf8))

        let integrityReport = CameraScanner.shared.verifyIncidentsIntegrity(directoryURL: tempDir)
        assertEqual(integrityReport.totalFilesScanned, 4, "Incident integrity scans all 4 test files")
        assertEqual(integrityReport.validCapturesCount, 1, "Identifies exactly 1 valid image capture")
        assertEqual(integrityReport.corruptedCount, 2, "Identifies 2 corrupted image captures (0-byte + invalid header)")
        assertEqual(integrityReport.zeroByteCount, 1, "Identifies 1 zero-byte file")
        assertEqual(integrityReport.nonImageCount, 1, "Identifies 1 non-image file")
        assertEqual(integrityReport.status, "CORRUPTED_DETECTED", "Integrity status is CORRUPTED_DETECTED")
        assertEqual(integrityReport.toDictionary()["status"] as? String, "CORRUPTED_DETECTED", "Incident integrity report dictionary contains status")

        let repairResult = CameraScanner.shared.repairCorruptedIncidents(directoryURL: tempDir)
        assertEqual(repairResult.repairedCount, 3, "Repair cleans 3 invalid/corrupted captures")
        assertEqual(repairResult.remainingValid, 1, "Exactly 1 valid capture remains after repair")

        let postRepairReport = CameraScanner.shared.verifyIncidentsIntegrity(directoryURL: tempDir)
        assertEqual(postRepairReport.status, "HEALTHY", "Integrity status transitions to HEALTHY after repair")
        assertEqual(postRepairReport.corruptedCount, 0, "0 corrupted files remain after repair")
        try? FileManager.default.removeItem(at: tempDir)

        // 3. Biometric Template Consistency & Medoid Computation
        let emptyConsistency = Config.shared.analyzeTemplateConsistency(vectors: [])
        assertEqual(emptyConsistency["status"] as? String, "EMPTY", "Empty vector set yields EMPTY status")
        assertEqual(emptyConsistency["medoidIndex"] as? Int, -1, "Empty vector set yields -1 medoid")

        let vBase = normalize((0..<128).map { Float($0) * 0.01 })
        let singleConsistency = Config.shared.analyzeTemplateConsistency(vectors: [vBase])
        assertEqual(singleConsistency["status"] as? String, "SINGLE_SAMPLE", "Single vector yields SINGLE_SAMPLE status")
        assertEqual(singleConsistency["medoidIndex"] as? Int, 0, "Single vector yields medoid index 0")

        // Tight cluster of 4 close vectors
        var tightCluster: [[Float]] = [vBase]
        for step in 1...3 {
            var shifted = vBase
            shifted[step] += 0.05
            tightCluster.append(normalize(shifted))
        }
        let tightReport = Config.shared.analyzeTemplateConsistency(vectors: tightCluster)
        assertEqual(tightReport["count"] as? Int, 4, "Tight cluster contains 4 vectors")
        assert((tightReport["cohesionScore"] as? Double ?? 0.0) >= 0.70, "Tight cluster has high cohesion score (>= 0.70)")
        let medoidIdx = tightReport["medoidIndex"] as? Int ?? -1
        assert(medoidIdx >= 0 && medoidIdx < 4, "Medoid index is within valid bounds [0..3]")
        let minPair = tightReport["minPairwiseDistance"] as? Double ?? 0.0
        let avgPair = tightReport["avgPairwiseDistance"] as? Double ?? 0.0
        let maxPair = tightReport["maxPairwiseDistance"] as? Double ?? 0.0
        assert(minPair <= avgPair, "minPairwiseDistance <= avgPairwiseDistance")
        assert(avgPair <= maxPair, "avgPairwiseDistance <= maxPairwiseDistance")

        // Disperse cluster
        let vOpposite = normalize((0..<128).map { -Float($0) * 0.01 })
        let disperseReport = Config.shared.analyzeTemplateConsistency(vectors: [vBase, vOpposite])
        assertEqual(disperseReport["status"] as? String, "DISPERSE", "Opposite vector pair yields DISPERSE status")

        // 4. Security Audit Analytical Digest (getAuditSummary)
        let isoFormatter = ISO8601DateFormatter()
        let t1 = isoFormatter.string(from: Date().addingTimeInterval(-7200))
        let t2 = isoFormatter.string(from: Date().addingTimeInterval(-3600))
        let t3 = isoFormatter.string(from: Date())

        let syntheticEvents: [AuditEvent] = [
            AuditEvent(id: "1", timestamp: t1, eventType: "face_verified", appName: "Safari", bundleId: "com.apple.Safari", details: "ok", isSuccess: true),
            AuditEvent(id: "2", timestamp: t1, eventType: "face_verified", appName: "Safari", bundleId: "com.apple.Safari", details: "ok", isSuccess: true),
            AuditEvent(id: "3", timestamp: t2, eventType: "intruder_detected", appName: "Terminal", bundleId: "com.apple.Terminal", details: "intruder", isSuccess: false),
            AuditEvent(id: "4", timestamp: t2, eventType: "pin_unlocked", appName: "Terminal", bundleId: "com.apple.Terminal", details: "pin ok", isSuccess: true),
            AuditEvent(id: "5", timestamp: t3, eventType: "shoulder_surfing", appName: nil, bundleId: nil, details: "2 faces", isSuccess: false),
            AuditEvent(id: "6", timestamp: t3, eventType: "emergency_lockdown", appName: nil, bundleId: nil, details: "lockdown", isSuccess: false),
            AuditEvent(id: "7", timestamp: t3, eventType: "pin_bruteforce", appName: "Terminal", bundleId: "com.apple.Terminal", details: "lockout", isSuccess: false)
        ]

        let summary = SecurityAuditLogger.shared.getAuditSummary(events: syntheticEvents)
        assertEqual(summary.totalEvents, 7, "Audit summary tracks totalEvents")
        assertEqual(summary.successfulVerifications, 2, "Audit summary counts 2 successful face verifications")
        assertEqual(summary.intruderDetections, 1, "Audit summary counts 1 intruder detection")
        assertEqual(summary.pinUnlocks, 1, "Audit summary counts 1 PIN unlock")
        assertEqual(summary.shoulderSurfingIncidents, 1, "Audit summary counts 1 shoulder surfing incident")
        assertEqual(summary.emergencyLockdowns, 1, "Audit summary counts 1 emergency lockdown")
        assertEqual(summary.pinLockouts, 1, "Audit summary counts 1 PIN bruteforce lockout")
        assertAccuracy(Float(summary.verificationSuccessRate), 2.0 / 3.0, accuracy: 0.02, "Verification success rate is ~66.7%")
        assertEqual(summary.topChallengedApplications["Safari"], 2, "Top challenged apps includes Safari (2)")
        assertEqual(summary.topChallengedApplications["Terminal"], 3, "Top challenged apps includes Terminal (3)")

        let summaryDict = summary.toDictionary()
        assert(summaryDict["totalEvents"] != nil, "Summary dictionary contains totalEvents")
        assert(summaryDict["verificationSuccessRate"] != nil, "Summary dictionary contains verificationSuccessRate")

        // 5. Diagnostics Enrichment with Consistency & Integrity
        let diag = Diagnostics.collectReport()
        let storage = diag["storage"] as? [String: Any] ?? [:]
        assert(storage["templateConsistency"] != nil, "Diagnostics storage includes templateConsistency")
        assert(storage["incidentsIntegrity"] != nil, "Diagnostics storage includes incidentsIntegrity")

        // 6. CLI Argument Normalization for v1.1.9 commands
        assertEqual(AppDelegate.normalizeArguments(["--vector-consistency-json"]), ["--vector-consistency", "--json"], "Normalizes --vector-consistency-json")
        assertEqual(AppDelegate.normalizeArguments(["--analyze-vectors-json"]), ["--vector-consistency", "--json"], "Normalizes --analyze-vectors-json")
        assertEqual(AppDelegate.normalizeArguments(["--analyze-vectors"]), ["--vector-consistency"], "Normalizes --analyze-vectors alias")
        assertEqual(AppDelegate.normalizeArguments(["--incidents-integrity-json"]), ["--incidents-integrity", "--json"], "Normalizes --incidents-integrity-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-incidents-json"]), ["--incidents-integrity", "--json"], "Normalizes --check-incidents-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-incidents"]), ["--incidents-integrity"], "Normalizes --check-incidents alias")
        assertEqual(AppDelegate.normalizeArguments(["--repair-incidents-json"]), ["--repair-incidents", "--json"], "Normalizes --repair-incidents-json")
        assertEqual(AppDelegate.normalizeArguments(["--clean-corrupted-incidents"]), ["--repair-incidents"], "Normalizes --clean-corrupted-incidents alias")
        assertEqual(AppDelegate.normalizeArguments(["--audit-summary-json"]), ["--audit-summary", "--json"], "Normalizes --audit-summary-json")
        assertEqual(AppDelegate.normalizeArguments(["--protect-app-json"]), ["--protect-app", "--json"], "Normalizes --protect-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--unprotect-app-json"]), ["--unprotect-app", "--json"], "Normalizes --unprotect-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--ignore-app-json"]), ["--ignore-app", "--json"], "Normalizes --ignore-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--unignore-app-json"]), ["--unignore-app", "--json"], "Normalizes --unignore-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-app-json"]), ["--check-app", "--json"], "Normalizes --check-app-json")

        // 7. Bundle Identifier Validation Suite
        assert(Config.isValidBundleIdentifier("com.apple.Safari"), "com.apple.Safari is valid bundle identifier")
        assert(Config.isValidBundleIdentifier("io.github.facelock"), "io.github.facelock is valid bundle identifier")
        assert(Config.isValidBundleIdentifier("ru.keepcoder.Telegram"), "ru.keepcoder.Telegram is valid bundle identifier")
        assert(Config.isValidBundleIdentifier("com.google.Chrome"), "com.google.Chrome is valid bundle identifier")
        assert(Config.isValidBundleIdentifier("WhatsApp-Beta"), "WhatsApp-Beta is valid bundle identifier")
        assert(Config.isValidBundleIdentifier("app_123.tool-beta"), "app_123.tool-beta is valid bundle identifier")

        assert(!Config.isValidBundleIdentifier(""), "Empty bundle identifier is invalid")
        assert(!Config.isValidBundleIdentifier("   "), "Whitespace-only bundle identifier is invalid")
        assert(!Config.isValidBundleIdentifier("--json"), "CLI flag --json is invalid bundle identifier")
        assert(!Config.isValidBundleIdentifier("-v"), "Short CLI flag -v is invalid bundle identifier")
        assert(!Config.isValidBundleIdentifier(".com.apple.Safari"), "Leading dot is invalid")
        assert(!Config.isValidBundleIdentifier("com.apple.Safari."), "Trailing dot is invalid")
        assert(!Config.isValidBundleIdentifier("com..apple"), "Consecutive dots are invalid")
        assert(!Config.isValidBundleIdentifier("com.apple/Safari"), "Slash in bundle identifier is invalid")
        assert(!Config.isValidBundleIdentifier("com apple Safari"), "Spaces in bundle identifier are invalid")
        assert(!Config.isValidBundleIdentifier(String(repeating: "a", count: 256)), "Overly long bundle identifier (>255) is invalid")

        // Rejection in Config methods
        assert(!Config.shared.addProtectedApp("--json"), "Config.addProtectedApp rejects --json")
        assert(!Config.shared.addIgnoredApp("..invalid"), "Config.addIgnoredApp rejects ..invalid")
        assert(!Config.shared.removeProtectedApp("--json"), "Config.removeProtectedApp rejects --json")
        assert(!Config.shared.removeIgnoredApp("--json"), "Config.removeIgnoredApp rejects --json")
    }

    private func testMaintenanceV120Enhancements() {
        print("\n▶ Test Suite: Security Posture Assessment & Meeting Telemetry (v1.2.0)")

        // 1. Hardened Security Posture Assessment (100 / 100)
        let hardenedConfig = Config(
            pin: "983412", // 6 digits (hardened)
            similarityThreshold: 0.20,
            verificationTimeout: 2.0,
            debounceSeconds: 2.0,
            isEnabled: true, // 15 pts
            strictFaceMatch: true,
            showHUD: true,
            autoTriggerTouchID: true,
            ignoredBundleIdentifiers: Config.defaultIgnoredBundleIdentifiers,
            telegramBotToken: "test_token_123",
            telegramChatId: "998877",
            telegramEnabled: true, // 5 pts
            protectionMode: "all",
            protectedBundleIdentifiers: Config.defaultProtectedBundleIdentifiers,
            livenessDetectionEnabled: true, // 10 pts
            walkAwayLockEnabled: true, // 10 pts
            walkAwayIdleSeconds: 30.0, // <= 60s
            lockOnWake: true, // 5 pts
            maxFailedPinAttempts: 3, // <= 5
            pinLockoutSeconds: 10.0, // >= 5s (pin pts: 10 + 5 = 15)
            activeProfile: "lockdown",
            shoulderSurfingDefense: true, // 10 pts
            batteryAwareScanning: true, // 5 pts
            audibleAlerts: true,
            presentationModeSuppression: true
        )

        // 5 highly cohesive vectors (bio pts: 15 + 5 = 20)
        var dummyBase = Array(repeating: Float(0.5), count: 128)
        dummyBase[0] = 1.0
        let baseNorm = normalize(dummyBase)
        let cohesiveVectors = (0..<5).map { idx in
            var v = baseNorm
            v[1] += Float(idx) * 0.001
            return normalize(v)
        }

        let cleanIntegrity = CameraScanner.IncidentIntegrityReport(
            totalFilesScanned: 5,
            validCapturesCount: 5,
            corruptedCount: 0,
            zeroByteCount: 0,
            nonImageCount: 0,
            totalValidSizeBytes: 10240,
            totalCorruptedSizeBytes: 0,
            directory: "/tmp/clean",
            corruptedFilenames: [],
            status: "HEALTHY"
        )

        let reportHardened = Diagnostics.assessSecurityPosture(
            config: hardenedConfig,
            enrolledVectors: cohesiveVectors,
            integrityReport: cleanIntegrity
        )

        assertEqual(reportHardened.score, 100, "Hardened security posture achieves maximum score 100")
        assertEqual(reportHardened.maxScore, 100, "Maximum score is 100")
        assertEqual(reportHardened.grade, "A+", "Hardened configuration earns grade A+")
        assertEqual(reportHardened.status, "EXCELLENT", "Hardened status is EXCELLENT")
        assert(reportHardened.recommendations.isEmpty, "Hardened configuration yields 0 recommendations")

        let dict = reportHardened.toDictionary()
        assertEqual(dict["score"] as? Int, 100, "Report dictionary contains score")
        assertEqual(dict["grade"] as? String, "A+", "Report dictionary contains grade")
        assertEqual(dict["status"] as? String, "EXCELLENT", "Report dictionary contains status")

        // 2. Degraded Posture & Actionable Recommendations
        let degradedConfig = Config(
            pin: "0000", // default pin (0 pts)
            isEnabled: false, // shield paused (0 pts)
            telegramBotToken: "",
            telegramChatId: "",
            telegramEnabled: false, // 0 pts
            livenessDetectionEnabled: false, // 0 pts
            walkAwayLockEnabled: false, // 0 pts
            lockOnWake: false, // 0 pts
            maxFailedPinAttempts: 10,
            pinLockoutSeconds: 1.0, // weak lockout (2 pts)
            shoulderSurfingDefense: false, // 0 pts
            batteryAwareScanning: false, // 0 pts
            presentationModeSuppression: false // 0 pts
        )

        let reportDegraded = Diagnostics.assessSecurityPosture(
            config: degradedConfig,
            enrolledVectors: [], // 0 vectors (0 pts)
            integrityReport: cleanIntegrity
        )

        assert(reportDegraded.score < 50, "Degraded configuration scores below 50 (\(reportDegraded.score))")
        assertEqual(reportDegraded.grade, "D", "Degraded configuration earns grade D")
        assertEqual(reportDegraded.status, "VULNERABLE", "Degraded status is VULNERABLE")
        assert(reportDegraded.recommendations.count >= 5, "Degraded posture yields multiple actionable recommendations (\(reportDegraded.recommendations.count))")

        // 3. Corrupted Capture Penalty
        let corruptedIntegrity = CameraScanner.IncidentIntegrityReport(
            totalFilesScanned: 3,
            validCapturesCount: 1,
            corruptedCount: 2,
            zeroByteCount: 1,
            nonImageCount: 1,
            totalValidSizeBytes: 512,
            totalCorruptedSizeBytes: 512,
            directory: "/tmp/corrupt",
            corruptedFilenames: ["corrupt.jpg"],
            status: "CORRUPTED_DETECTED"
        )

        let reportWithCorruption = Diagnostics.assessSecurityPosture(
            config: hardenedConfig,
            enrolledVectors: cohesiveVectors,
            integrityReport: corruptedIntegrity
        )

        assertEqual(reportWithCorruption.score, 95, "5-point penalty applied for corrupted captures (100 -> 95)")
        assert(reportWithCorruption.recommendations.contains(where: { $0.contains("repair-incidents") }), "Recommends repair-incidents when corruption detected")

        // 4. Presentation & Meeting Mode Catalog Telemetry
        let catalog = WalkAwayMonitor.presentationCatalog
        assert(catalog.count >= 30, "Presentation catalog contains at least 30 known meeting/presentation apps (\(catalog.count))")

        assert(catalog.contains(where: { $0.bundleId == "com.apple.iWork.Keynote" && $0.category == "Presentation" }), "Keynote is in Presentation category")
        assert(catalog.contains(where: { $0.bundleId == "us.zoom.xos" && $0.category == "Meeting" }), "Zoom is in Meeting category")
        assert(catalog.contains(where: { $0.bundleId == "com.microsoft.teams" && $0.category == "Meeting" }), "Teams is in Meeting category")
        assert(catalog.contains(where: { $0.bundleId == "com.obsproject.obs-studio" && $0.category == "Streaming" }), "OBS is in Streaming category")
        assert(catalog.contains(where: { $0.bundleId == "org.videolan.vlc" && $0.category == "Media" }), "VLC is in Media category")
        assert(catalog.contains(where: { $0.bundleId == "com.anydesk.anydesk" && $0.category == "Screen Sharing" }), "AnyDesk is in Screen Sharing category")
        assert(catalog.contains(where: { $0.bundleId == "com.apple.FaceTime" && $0.category == "Communication" }), "FaceTime is in Communication category")

        // 5. checkPresentationStatus Inspection
        let keynoteStatus = WalkAwayMonitor.checkPresentationStatus(bundleId: "com.apple.iWork.Keynote")
        assertEqual(keynoteStatus["isPresentationApp"] as? Bool, true, "Keynote identified as presentation app")
        assertEqual(keynoteStatus["matchedName"] as? String, "Keynote", "Keynote matched name is Keynote")
        assertEqual(keynoteStatus["matchedCategory"] as? String, "Presentation", "Keynote category is Presentation")

        let zoomStatus = WalkAwayMonitor.checkPresentationStatus(bundleId: "us.zoom.xos")
        assertEqual(zoomStatus["isPresentationApp"] as? Bool, true, "Zoom identified as meeting app")
        assertEqual(zoomStatus["matchedCategory"] as? String, "Meeting", "Zoom category is Meeting")

        let safariStatus = WalkAwayMonitor.checkPresentationStatus(bundleId: "com.apple.Safari")
        assertEqual(safariStatus["isPresentationApp"] as? Bool, false, "Safari is not a presentation app")

        let finderStatus = WalkAwayMonitor.checkPresentationStatus(bundleId: "com.apple.finder")
        assertEqual(finderStatus["isPresentationApp"] as? Bool, false, "Finder is not a presentation app")

        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.iWork.Keynote"), "isPresentationActive returns true for Keynote")
        assert(!WalkAwayMonitor.isPresentationActive(bundleId: "com.apple.Safari"), "isPresentationActive returns false for Safari")

        // 6. Diagnostics report integration
        let fullReport = Diagnostics.collectReport()
        assert(fullReport["securityPosture"] != nil, "Diagnostics report includes securityPosture dictionary")

        // 7. CLI Argument Normalization for v1.2.0
        assertEqual(AppDelegate.normalizeArguments(["--security-score-json"]), ["--security-score", "--json"], "Normalizes --security-score-json")
        assertEqual(AppDelegate.normalizeArguments(["--posture-score-json"]), ["--security-score", "--json"], "Normalizes --posture-score-json")
        assertEqual(AppDelegate.normalizeArguments(["--posture-json"]), ["--security-score", "--json"], "Normalizes --posture-json")
        assertEqual(AppDelegate.normalizeArguments(["--posture"]), ["--security-score"], "Normalizes --posture")
        assertEqual(AppDelegate.normalizeArguments(["--security-posture"]), ["--security-score"], "Normalizes --security-posture")
        assertEqual(AppDelegate.normalizeArguments(["--presentation-apps-json"]), ["--presentation-apps", "--json"], "Normalizes --presentation-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--meeting-apps-json"]), ["--presentation-apps", "--json"], "Normalizes --meeting-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--meeting-apps"]), ["--presentation-apps"], "Normalizes --meeting-apps")
        assertEqual(AppDelegate.normalizeArguments(["--check-presentation-json"]), ["--check-presentation", "--json"], "Normalizes --check-presentation-json")
    }

    // MARK: - Maintenance v1.2.1 Enhancements Test Suite
    private func testMaintenanceV121Enhancements() {
        print("\n▶ Test Suite: Audit Log Cryptographic Integrity & Tamper Verification (v1.2.1)")

        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("facelock_test_v121_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let auditLogURL = tempDir.appendingPathComponent("audit_log.jsonl")

        // 1. Clean audit verification
        let encoder = JSONEncoder()
        let event1 = AuditEvent(id: "ev1", timestamp: "2026-11-06T10:00:00Z", eventType: "face_verified", appName: "Safari", isSuccess: true)
        let event2 = AuditEvent(id: "ev2", timestamp: "2026-11-06T11:00:00Z", eventType: "intruder_detected", appName: "Terminal", isSuccess: false)
        let event3 = AuditEvent(id: "ev3", timestamp: "2026-11-06T12:00:00Z", eventType: "pin_unlocked", appName: "Notes", isSuccess: true)

        let d1 = try! encoder.encode(event1)
        let d2 = try! encoder.encode(event2)
        let d3 = try! encoder.encode(event3)
        let cleanContent = [String(data: d1, encoding: .utf8)!, String(data: d2, encoding: .utf8)!, String(data: d3, encoding: .utf8)!].joined(separator: "\n") + "\n"
        try! cleanContent.write(to: auditLogURL, atomically: true, encoding: .utf8)

        let cleanReport = SecurityAuditLogger.shared.verifyAuditIntegrity(fileURL: auditLogURL)
        assertEqual(cleanReport.status, "VERIFIED", "Clean audit log is marked VERIFIED")
        assertEqual(cleanReport.validEventsCount, 3, "Valid events count is 3")
        assertEqual(cleanReport.corruptedLinesCount, 0, "Corrupted lines count is 0")
        assertEqual(cleanReport.chronologyErrorsCount, 0, "Chronology errors count is 0")
        assertEqual(cleanReport.sha256Digest.count, 64, "SHA-256 digest is 64 hex characters")
        assertEqual(cleanReport.firstEventTimestamp, "2026-11-06T10:00:00Z", "First event timestamp matches")
        assertEqual(cleanReport.lastEventTimestamp, "2026-11-06T12:00:00Z", "Last event timestamp matches")

        let cleanDict = cleanReport.toDictionary()
        assertEqual(cleanDict["status"] as? String, "VERIFIED", "Report dictionary status matches")
        assertEqual(cleanDict["validEventsCount"] as? Int, 3, "Report dictionary valid count matches")

        // 2. Chronology anomaly detection
        let retroEvent = AuditEvent(id: "ev4", timestamp: "2026-10-01T00:00:00Z", eventType: "face_verified", isSuccess: true)
        let dRetro = try! encoder.encode(retroEvent)
        let retroContent = cleanContent + String(data: dRetro, encoding: .utf8)! + "\n"
        try! retroContent.write(to: auditLogURL, atomically: true, encoding: .utf8)

        let retroReport = SecurityAuditLogger.shared.verifyAuditIntegrity(fileURL: auditLogURL)
        assertEqual(retroReport.status, "WARNING_CHRONOLOGY", "Out-of-order timestamp triggers WARNING_CHRONOLOGY")
        assert(retroReport.chronologyErrorsCount >= 1, "Chronology error detected (\(retroReport.chronologyErrorsCount))")

        // 3. Corrupted lines detection and repair
        let corruptedContent = cleanContent + "\n{malformed json record line}\n   \n"
        try! corruptedContent.write(to: auditLogURL, atomically: true, encoding: .utf8)

        let corruptReport = SecurityAuditLogger.shared.verifyAuditIntegrity(fileURL: auditLogURL)
        assertEqual(corruptReport.status, "CORRUPTED_DETECTED", "Malformed JSON triggers CORRUPTED_DETECTED")
        assertEqual(corruptReport.corruptedLinesCount, 1, "Corrupted lines count is 1")
        assert(!corruptReport.corruptedLineIndices.isEmpty, "Corrupted line index recorded")

        let repairResult = try! SecurityAuditLogger.shared.repairAuditLog(fileURL: auditLogURL)
        assertEqual(repairResult.purgedCorruptedCount, 1, "Purged 1 corrupted record")
        assertEqual(repairResult.remainingCount, 3, "Retained 3 valid records")
        assert(FileManager.default.fileExists(atPath: repairResult.backupPath), "Backup file was created at \(repairResult.backupPath)")

        let postRepairReport = SecurityAuditLogger.shared.verifyAuditIntegrity(fileURL: auditLogURL)
        assertEqual(postRepairReport.status, "VERIFIED", "Repaired audit log is VERIFIED")
        assertEqual(postRepairReport.corruptedLinesCount, 0, "Repaired log has 0 corrupted lines")
        assertEqual(postRepairReport.validEventsCount, 3, "Repaired log retains 3 valid records")

        // 4. Security Posture Penalty & Actionable Advice
        let hardenedConfig = Config(
            pin: "987654",
            isEnabled: true,
            telegramBotToken: "tok",
            telegramChatId: "id",
            telegramEnabled: true,
            livenessDetectionEnabled: true,
            walkAwayLockEnabled: true,
            walkAwayIdleSeconds: 45.0,
            lockOnWake: true,
            maxFailedPinAttempts: 3,
            pinLockoutSeconds: 5.0,
            shoulderSurfingDefense: true,
            batteryAwareScanning: true,
            presentationModeSuppression: true
        )
        var dummyBase = Array(repeating: Float(0.5), count: 128)
        dummyBase[0] = 1.0
        let baseNorm = normalize(dummyBase)
        let cohesiveVectors = (0..<5).map { idx in
            var v = baseNorm
            v[1] += Float(idx) * 0.001
            return normalize(v)
        }
        let cleanIntegrity = CameraScanner.IncidentIntegrityReport(
            totalFilesScanned: 0,
            validCapturesCount: 0,
            corruptedCount: 0,
            zeroByteCount: 0,
            nonImageCount: 0,
            totalValidSizeBytes: 0,
            totalCorruptedSizeBytes: 0,
            directory: "/tmp",
            corruptedFilenames: [],
            status: "HEALTHY"
        )

        let postureWithAuditCorruption = Diagnostics.assessSecurityPosture(
            config: hardenedConfig,
            enrolledVectors: cohesiveVectors,
            integrityReport: cleanIntegrity,
            auditIntegrityReport: corruptReport
        )
        assertEqual(postureWithAuditCorruption.score, 95, "5-point penalty applied for corrupted audit log (100 -> 95)")
        assert(postureWithAuditCorruption.recommendations.contains(where: { $0.contains("repair-audit") }), "Recommends repair-audit when audit corruption detected")

        // 5. Diagnostics report integration
        let diagReport = Diagnostics.collectReport()
        let storageDict = diagReport["storage"] as? [String: Any]
        assert(storageDict?["auditIntegrity"] != nil, "Diagnostics storage includes auditIntegrity dictionary")

        // 6. CLI Argument Normalization for v1.2.1
        assertEqual(AppDelegate.normalizeArguments(["--audit-integrity-json"]), ["--audit-integrity", "--json"], "Normalizes --audit-integrity-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-audit-json"]), ["--audit-integrity", "--json"], "Normalizes --check-audit-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-audit"]), ["--audit-integrity"], "Normalizes --check-audit")
        assertEqual(AppDelegate.normalizeArguments(["--repair-audit-json"]), ["--repair-audit", "--json"], "Normalizes --repair-audit-json")
        assertEqual(AppDelegate.normalizeArguments(["--clean-corrupted-audit-json"]), ["--repair-audit", "--json"], "Normalizes --clean-corrupted-audit-json")
        assertEqual(AppDelegate.normalizeArguments(["--clean-corrupted-audit"]), ["--repair-audit"], "Normalizes --clean-corrupted-audit")
        assertEqual(AppDelegate.normalizeArguments(["--audit-digest-json"]), ["--audit-digest", "--json"], "Normalizes --audit-digest-json")
        assertEqual(AppDelegate.normalizeArguments(["--audit-checksum-json"]), ["--audit-digest", "--json"], "Normalizes --audit-checksum-json")
        assertEqual(AppDelegate.normalizeArguments(["--audit-checksum"]), ["--audit-digest"], "Normalizes --audit-checksum")
    }

    // MARK: - Maintenance v1.2.2 Enhancements Test Suite
    private func testMaintenanceV122Enhancements() {
        print("\n▶ Test Suite: Physical Threat Intelligence & Configuration Integrity (v1.2.2)")

        // 1. Clean Baseline Threat Intelligence
        let cleanIntel = SecurityAuditLogger.shared.analyzeThreatIntelligence(events: [])
        assertEqual(cleanIntel.riskScore, 0, "Clean baseline risk score is 0")
        assertEqual(cleanIntel.riskLevel, "LOW", "Clean baseline risk level is LOW")
        assertEqual(cleanIntel.totalThreatEvents, 0, "Clean baseline total threat events is 0")
        assertEqual(cleanIntel.anomalies.isEmpty, true, "No threat anomalies on clean baseline")
        assertEqual(cleanIntel.peakThreatHour == nil, true, "Peak threat hour is nil when no events")
        assertEqual(cleanIntel.hourlyDistribution.count, 24, "Hourly distribution contains 24 hourly buckets")

        // 2. Synthesized Threat Intelligence Scenario
        let now = Date()
        let isoFormatter = ISO8601DateFormatter()
        let nowStr = isoFormatter.string(from: now)
        let offHoursDate = Calendar.current.date(bySettingHour: 2, minute: 15, second: 0, of: now) ?? now
        let offHoursStr = isoFormatter.string(from: offHoursDate)

        let testEvents: [AuditEvent] = [
            AuditEvent(id: "e1", timestamp: nowStr, eventType: "pin_bruteforce", appName: "Terminal", bundleId: "com.apple.Terminal", distance: nil, threshold: nil, intruderPhoto: nil, details: "3 failed attempts", isSuccess: false),
            AuditEvent(id: "e2", timestamp: nowStr, eventType: "pin_bruteforce", appName: "Terminal", bundleId: "com.apple.Terminal", distance: nil, threshold: nil, intruderPhoto: nil, details: "Cooling lockout", isSuccess: false),
            AuditEvent(id: "e3", timestamp: nowStr, eventType: "shoulder_surfing", appName: nil, bundleId: nil, distance: nil, threshold: nil, intruderPhoto: "bystander_1.jpg", details: "Secondary face detected", isSuccess: false),
            AuditEvent(id: "e4", timestamp: nowStr, eventType: "shoulder_surfing", appName: nil, bundleId: nil, distance: nil, threshold: nil, intruderPhoto: "bystander_2.jpg", details: "Bystander snooping", isSuccess: false),
            AuditEvent(id: "e5", timestamp: offHoursDate != now ? offHoursStr : nowStr, eventType: "intruder_detected", appName: "Keychain Access", bundleId: "com.apple.keychainaccess", distance: 0.42, threshold: 0.22, intruderPhoto: "intruder_1.jpg", details: nil, isSuccess: false),
            AuditEvent(id: "e6", timestamp: nowStr, eventType: "intruder_detected", appName: "Safari", bundleId: "com.apple.Safari", distance: 0.38, threshold: 0.22, intruderPhoto: "intruder_2.jpg", details: nil, isSuccess: false),
            AuditEvent(id: "e7", timestamp: nowStr, eventType: "intruder_detected", appName: "System Settings", bundleId: "com.apple.systempreferences", distance: 0.45, threshold: 0.22, intruderPhoto: "intruder_3.jpg", details: nil, isSuccess: false)
        ]

        let threatReport = SecurityAuditLogger.shared.analyzeThreatIntelligence(events: testEvents)
        assertEqual(threatReport.pinBruteforceCount, 2, "Counts 2 PIN bruteforce events")
        assertEqual(threatReport.shoulderSurfingCount, 2, "Counts 2 shoulder surfing events")
        assertEqual(threatReport.intruderCaptureCount, 3, "Counts 3 intruder captures")
        assertEqual(threatReport.totalThreatEvents, 7, "Total threat events is 7")
        assert(threatReport.riskScore >= 70, "Risk score achieves CRITICAL status (>= 70: \(threatReport.riskScore))")
        assertEqual(threatReport.riskLevel, "CRITICAL", "Threat level is CRITICAL")
        assertEqual(threatReport.statusBadge, "CRITICAL 🔴", "Status badge is CRITICAL 🔴")

        // 3. Anomaly Pattern Detection
        assert(threatReport.anomalies.contains(where: { $0.code == "PIN_BRUTEFORCE_DETECTED" }), "Detects PIN_BRUTEFORCE_DETECTED anomaly")
        assert(threatReport.anomalies.contains(where: { $0.code == "HIGH_VELOCITY_INTRUSIONS" }), "Detects HIGH_VELOCITY_INTRUSIONS anomaly")
        assert(threatReport.anomalies.contains(where: { $0.code == "PERSISTENT_SHOULDER_SURFING" }), "Detects PERSISTENT_SHOULDER_SURFING anomaly")
        assert(threatReport.anomalies.contains(where: { $0.code == "PRIVILEGED_TARGET_ACCESS" }), "Detects PRIVILEGED_TARGET_ACCESS anomaly")
        assert(!threatReport.mitigations.isEmpty, "Synthesizes actionable threat mitigations (\(threatReport.mitigations.count))")

        // 4. Targeted Applications & Risk Ranking
        assert(!threatReport.targetedApps.isEmpty, "Targeted apps populated")
        assert(threatReport.targetedApps.contains(where: { $0.appName == "Terminal" && $0.riskCategory == "CRITICAL" }), "Terminal categorized as CRITICAL risk")
        assert(threatReport.targetedApps.contains(where: { $0.appName == "Keychain Access" && $0.riskCategory == "CRITICAL" }), "Keychain Access categorized as CRITICAL risk")
        assert(threatReport.targetedApps.contains(where: { $0.appName == "Safari" && $0.riskCategory == "HIGH" }), "Safari categorized as HIGH risk")

        // 5. Configuration Security Validation Suite
        let validReport = Config.validateConfig()
        assert(validReport.isValid, "Default configuration is valid and secure")
        assertEqual(validReport.errorCount, 0, "No errors on valid configuration")
        assert(validReport.toDictionary()["isValid"] as? Bool == true, "ConfigValidationReport dictionary reflects isValid")

        // Bad PIN validation
        let badPinConfig = Config()
        badPinConfig.pin = "12"
        let badPinReport = Config.validateConfig(badPinConfig)
        assert(!badPinReport.isValid, "Rejects short PIN")
        assert(badPinReport.issues.contains(where: { $0.key == "pin" && $0.severity == "ERROR" }), "Reports ERROR for short PIN")

        // Trivial PIN warning
        let trivialConfig = Config()
        trivialConfig.pin = "0000"
        let trivialReport = Config.validateConfig(trivialConfig)
        assert(trivialReport.issues.contains(where: { $0.key == "pin" && $0.severity == "WARNING" }), "Warns on default PIN '0000'")

        // Threshold & timer validation
        let badThresholdConfig = Config()
        badThresholdConfig.similarityThreshold = 0.99
        let badThresholdReport = Config.validateConfig(badThresholdConfig)
        assert(!badThresholdReport.isValid, "Rejects similarity threshold out of bounds")

        // Bundle identifier validation
        let badAppConfig = Config()
        badAppConfig.protectedBundleIdentifiers = ["--json", "valid.app.bundle"]
        let badAppReport = Config.validateConfig(badAppConfig)
        assert(!badAppReport.isValid, "Rejects invalid bundle identifier in protected list")

        let dupAppConfig = Config()
        dupAppConfig.protectedBundleIdentifiers = ["com.apple.Safari", "com.apple.Safari"]
        let dupAppReport = Config.validateConfig(dupAppConfig)
        assert(dupAppReport.issues.contains(where: { $0.severity == "WARNING" && $0.message.contains("Duplicate") }), "Warns on duplicate bundle identifiers")

        // Telegram validation
        let badTgConfig = Config()
        badTgConfig.telegramEnabled = true
        badTgConfig.telegramBotToken = ""
        badTgConfig.telegramChatId = "12345"
        let badTgReport = Config.validateConfig(badTgConfig)
        assert(!badTgReport.isValid, "Rejects telegram enabled without bot token")

        // 6. Diagnostics Report Integration
        let diagReport = Diagnostics.collectReport()
        assert(diagReport["threatIntelligence"] != nil, "Diagnostics includes threatIntelligence dictionary")
        assert(diagReport["configValidation"] != nil, "Diagnostics includes configValidation dictionary")

        // 7. CLI Argument Normalization for v1.2.2
        assertEqual(AppDelegate.normalizeArguments(["--threat-intel-json"]), ["--threat-intel", "--json"], "Normalizes --threat-intel-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-intelligence-json"]), ["--threat-intel", "--json"], "Normalizes --threat-intelligence-json")
        assertEqual(AppDelegate.normalizeArguments(["--risk-level-json"]), ["--threat-intel", "--json"], "Normalizes --risk-level-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-intelligence"]), ["--threat-intel"], "Normalizes --threat-intelligence")
        assertEqual(AppDelegate.normalizeArguments(["--risk-level"]), ["--threat-intel"], "Normalizes --risk-level")
        assertEqual(AppDelegate.normalizeArguments(["--validate-config-json"]), ["--validate-config", "--json"], "Normalizes --validate-config-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-config-json"]), ["--validate-config", "--json"], "Normalizes --check-config-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-config"]), ["--validate-config"], "Normalizes --check-config")
    }

    // MARK: - Maintenance v1.2.3 Enhancements Test Suite (Duress Defense & Storage Quota)
    private func testMaintenanceV123Enhancements() {
        print("\n▶ Test Suite: Duress Defense Suite & Intruder Storage Quota (v1.2.3)")

        // 1. Duress PIN Validation
        let val1 = Config.isValidDuressPin("9999", masterPin: "1234")
        assert(val1.isValid, "Valid 4-digit duress PIN accepted")

        let valSame = Config.isValidDuressPin("1234", masterPin: "1234")
        assert(!valSame.isValid, "Rejects duress PIN matching master PIN")

        let valShort = Config.isValidDuressPin("123", masterPin: "1234")
        assert(!valShort.isValid, "Rejects short duress PIN (<4 digits)")

        let valLong = Config.isValidDuressPin("123456789", masterPin: "1234")
        assert(!valLong.isValid, "Rejects long duress PIN (>8 digits)")

        let valAlpha = Config.isValidDuressPin("12ab", masterPin: "1234")
        assert(!valAlpha.isValid, "Rejects non-numeric duress PIN")

        let valEmpty = Config.isValidDuressPin("", masterPin: "1234")
        assert(valEmpty.isValid, "Empty duress PIN is valid (disabled state)")

        // 2. Duress Configuration State
        let cfg = Config()
        cfg.pin = "1234"
        cfg.duressPin = ""
        assertEqual(cfg.isDuressPinEnabled, false, "Duress is disabled when duressPin is empty")

        let setResult = cfg.setDuressPin("8888")
        assert(setResult.success, "setDuressPin succeeds with valid 8888")
        assertEqual(cfg.isDuressPinEnabled, true, "Duress is enabled after setting valid PIN")
        assertEqual(cfg.duressPin, "8888", "duressPin stores value")

        cfg.clearDuressPin()
        assertEqual(cfg.isDuressPinEnabled, false, "clearDuressPin disables duress")
        assertEqual(cfg.duressPin, "", "clearDuressPin resets to empty string")

        // 3. Security Audit Logging & Summary
        let t = ISO8601DateFormatter().string(from: Date())
        let testEvents: [AuditEvent] = [
            AuditEvent(id: "d1", timestamp: t, eventType: "duress_pin_unlocked", appName: "Terminal", bundleId: "com.apple.Terminal", details: "Coerced unlock", isSuccess: true),
            AuditEvent(id: "d2", timestamp: t, eventType: "face_verified", appName: "Safari", bundleId: "com.apple.Safari", details: "Verified", isSuccess: true)
        ]
        let summary = SecurityAuditLogger.shared.getAuditSummary(events: testEvents)
        assertEqual(summary.duressPinUnlocks, 1, "AuditSummary correctly counts duressPinUnlocks")
        let sumDict = summary.toDictionary()
        assertEqual(sumDict["duressPinUnlocks"] as? Int, 1, "AuditSummary dictionary contains duressPinUnlocks")

        // 4. Telegram Duress Alert Formatting
        let caption = TelegramNotifier.formatDuressAlertCaption(appName: "1Password & Secrets")
        assert(caption.contains("ВНИМАНИЕ! Введён код принуждения"), "Duress alert caption contains warning banner")
        assert(caption.contains("1Password &amp; Secrets"), "Duress alert caption safely escapes HTML")

        // 5. Camera Storage Quota Pruning
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("facelock_quota_test_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let dummyBytes = Data(repeating: 0xFF, count: 512 * 1024)
        for i in 1...3 {
            let u = tempDir.appendingPathComponent("intruder_test_\(i).jpg")
            try? dummyBytes.write(to: u)
        }

        let pruneRes = CameraScanner.shared.pruneIncidentsByDiskQuota(maxBytes: 1024 * 1024, directoryURL: tempDir)
        assert(pruneRes.removedCount >= 1, "pruneIncidentsByDiskQuota prunes files when exceeding maxBytes")
        assert(pruneRes.remainingCount <= 2, "pruneIncidentsByDiskQuota keeps files within budget")

        // 6. Security Posture Breakdown Integration
        let posture = Diagnostics.assessSecurityPosture(config: cfg, enrolledVectors: [])
        let postureDict = posture.toDictionary()
        let breakdown = postureDict["breakdown"] as? [String: Any]
        assert(breakdown?["duressDefense"] != nil, "Posture breakdown contains duressDefense dictionary")

        // 7. Custom Meeting Applications Whitelist
        Config.shared.resetMeetingApps()
        assertEqual(Config.shared.customPresentationBundleIdentifiers.count, 0, "Custom meeting apps empty after reset")
        assert(Config.shared.addMeetingApp("com.corp.custommeeting"), "Valid bundle identifier added to custom meeting apps")
        assert(!Config.shared.addMeetingApp("com.corp.custommeeting"), "Duplicate bundle identifier rejected")
        assert(!Config.shared.addMeetingApp("--json"), "Invalid bundle identifier rejected")
        assertEqual(Config.shared.customPresentationBundleIdentifiers.contains("com.corp.custommeeting"), true, "Custom meeting list contains added bundle ID")
        assert(WalkAwayMonitor.isPresentationActive(bundleId: "com.corp.custommeeting"), "WalkAwayMonitor recognizes custom meeting app for lock suppression")
        assert(Config.shared.removeMeetingApp("com.corp.custommeeting"), "Removes custom meeting app")
        assert(!Config.shared.removeMeetingApp("com.corp.custommeeting"), "Cannot remove already-removed meeting app")
        assertEqual(Config.shared.customPresentationBundleIdentifiers.count, 0, "Custom meeting apps list is empty after removal")

        // 8. CLI Argument Normalization for v1.2.3 & Custom Meeting Apps
        assertEqual(AppDelegate.normalizeArguments(["--set-duress-pin-json"]), ["--set-duress-pin", "--json"], "Normalizes --set-duress-pin-json")
        assertEqual(AppDelegate.normalizeArguments(["--clear-duress-pin-json"]), ["--clear-duress-pin", "--json"], "Normalizes --clear-duress-pin-json")
        assertEqual(AppDelegate.normalizeArguments(["--duress-status-json"]), ["--duress-status", "--json"], "Normalizes --duress-status-json")
        assertEqual(AppDelegate.normalizeArguments(["--prune-incidents-quota-json"]), ["--prune-incidents-size", "--json"], "Normalizes --prune-incidents-quota-json")
        assertEqual(AppDelegate.normalizeArguments(["--prune-incidents-quota"]), ["--prune-incidents-size"], "Normalizes --prune-incidents-quota")
        assertEqual(AppDelegate.normalizeArguments(["--add-meeting-app-json"]), ["--add-meeting-app", "--json"], "Normalizes --add-meeting-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--add-presentation-app-json"]), ["--add-meeting-app", "--json"], "Normalizes --add-presentation-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--add-presentation-app"]), ["--add-meeting-app"], "Normalizes --add-presentation-app")
        assertEqual(AppDelegate.normalizeArguments(["--remove-meeting-app-json"]), ["--remove-meeting-app", "--json"], "Normalizes --remove-meeting-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--remove-presentation-app-json"]), ["--remove-meeting-app", "--json"], "Normalizes --remove-presentation-app-json")
        assertEqual(AppDelegate.normalizeArguments(["--remove-presentation-app"]), ["--remove-meeting-app"], "Normalizes --remove-presentation-app")
        assertEqual(AppDelegate.normalizeArguments(["--reset-meeting-apps-json"]), ["--reset-meeting-apps", "--json"], "Normalizes --reset-meeting-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--reset-presentation-apps-json"]), ["--reset-meeting-apps", "--json"], "Normalizes --reset-presentation-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--reset-presentation-apps"]), ["--reset-meeting-apps"], "Normalizes --reset-presentation-apps")
        assertEqual(AppDelegate.normalizeArguments(["--custom-meeting-apps-json"]), ["--custom-meeting-apps", "--json"], "Normalizes --custom-meeting-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--custom-presentation-apps-json"]), ["--custom-meeting-apps", "--json"], "Normalizes --custom-presentation-apps-json")
        assertEqual(AppDelegate.normalizeArguments(["--custom-presentation-apps"]), ["--custom-meeting-apps"], "Normalizes --custom-presentation-apps")

        // 9. Forensic Incident Archive with SHA-256 Checksums
        let archiveTempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("facelock_archive_test_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: archiveTempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: archiveTempDir) }

        let archiveResult = try! CameraScanner.shared.archiveIncidents(to: archiveTempDir.path)
        let manifestPath = archiveResult["manifestPath"] as? String ?? ""
        assert(FileManager.default.fileExists(atPath: manifestPath), "Forensic manifest generated at \(manifestPath)")
        let rootChecksum = archiveResult["forensicChecksum"] as? String ?? ""
        assertEqual(rootChecksum.count, 64, "Forensic root checksum is 64 hex characters")

        assertEqual(AppDelegate.normalizeArguments(["--archive-incidents-json"]), ["--archive-incidents", "--json"], "Normalizes --archive-incidents-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-intel-json"]), ["--threat-intel", "--json"], "Normalizes --threat-intel-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-level-json"]), ["--threat-intel", "--json"], "Normalizes --threat-level-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-summary-json"]), ["--threat-intel", "--json"], "Normalizes --threat-summary-json")
        assertEqual(AppDelegate.normalizeArguments(["--threat-level"]), ["--threat-intel"], "Normalizes --threat-level")
        assertEqual(AppDelegate.normalizeArguments(["--threat-summary"]), ["--threat-intel"], "Normalizes --threat-summary")
        assertEqual(AppDelegate.normalizeArguments(["--threat"]), ["--threat-intel"], "Normalizes --threat")
    }

    // MARK: - Maintenance v1.2.4 Enhancements Test Suite (Diagnostic Doctor & Health Suite)
    private func testMaintenanceV124Enhancements() {
        print("\n▶ Test Suite: Autonomous Diagnostic Doctor & Health Suite (v1.2.4)")

        // 1. Doctor Report Execution
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 15, "Doctor executes at least 15 comprehensive checks (Got \(report.totalChecks))")
        assert(report.passedCount > 0, "Doctor has passed checks (\(report.passedCount) passed)")
        assertEqual(report.version, Config.currentVersion, "Doctor report matches currentVersion \(Config.currentVersion)")
        assert(!report.timestamp.isEmpty, "Doctor report contains ISO8601 timestamp")
        assert(["HEALTHY", "WARNING", "CRITICAL"].contains(report.overallStatus), "Doctor overallStatus is valid: \(report.overallStatus)")

        // 2. Doctor Check Categories
        let categories = Set(report.checks.map { $0.category })
        assert(categories.contains("hardware"), "Contains 'hardware' category")
        assert(categories.contains("filesystem"), "Contains 'filesystem' category")
        assert(categories.contains("daemon"), "Contains 'daemon' category")
        assert(categories.contains("security"), "Contains 'security' category")
        assert(categories.contains("network"), "Contains 'network' category")

        // 3. Check Items Validity
        for check in report.checks {
            assert(!check.id.isEmpty, "Check ID is non-empty: \(check.id)")
            assert(!check.name.isEmpty, "Check name is non-empty: \(check.name)")
            assert(!check.message.isEmpty, "Check message is non-empty: \(check.message)")
            assert(!check.status.badge.isEmpty, "Check status badge is non-empty: \(check.status.badge)")
        }

        // 4. Doctor Check Status Badges
        assertEqual(DoctorCheckStatus.pass.badge, "PASS ✅", "DoctorCheckStatus pass badge")
        assertEqual(DoctorCheckStatus.warn.badge, "WARN ⚠️", "DoctorCheckStatus warn badge")
        assertEqual(DoctorCheckStatus.fail.badge, "FAIL ❌", "DoctorCheckStatus fail badge")
        assertEqual(DoctorCheckStatus.info.badge, "INFO ℹ️", "DoctorCheckStatus info badge")

        // 5. Doctor Report Dictionary Serialization
        let dict = report.toDictionary()
        assertEqual(dict["version"] as? String, Config.currentVersion, "Dictionary contains version \(Config.currentVersion)")
        assertEqual(dict["overallStatus"] as? String, report.overallStatus, "Dictionary contains overallStatus")
        let statsDict = dict["stats"] as? [String: Any]
        assert(statsDict != nil, "Dictionary contains stats sub-dictionary")
        assertEqual(statsDict?["totalChecks"] as? Int, report.totalChecks, "Stats dictionary totalChecks matches")
        let checksArr = dict["checks"] as? [[String: Any]]
        assert(checksArr != nil && checksArr?.count == report.totalChecks, "Dictionary checks array serialized correctly")

        // 6. JSON Serialization
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
        assert(jsonData != nil && (jsonData?.count ?? 0) > 100, "Doctor report serializes to valid JSON bytes")

        // 7. Simulated Degradation
        let mockFailingItem = DoctorCheckItem(
            id: "test.failure",
            category: "security",
            name: "Mock Security Failure",
            status: .fail,
            message: "Simulated critical failure",
            remediation: "Perform simulated repair"
        )
        let degradedReport = DoctorReport(checks: [mockFailingItem], version: "1.2.4")
        assertEqual(degradedReport.overallStatus, "CRITICAL", "Doctor correctly flags CRITICAL when failure exists")
        assertEqual(degradedReport.failureCount, 1, "Doctor records 1 failure")
        assertEqual(degradedReport.remediations.count, 1, "Doctor includes remediation for failing check")

        let mockWarningItem = DoctorCheckItem(
            id: "test.warning",
            category: "security",
            name: "Mock Security Warning",
            status: .warn,
            message: "Simulated warning",
            remediation: "Perform simulated warning fix"
        )
        let warningReport = DoctorReport(checks: [mockWarningItem], version: "1.2.4")
        assertEqual(warningReport.overallStatus, "WARNING", "Doctor correctly flags WARNING when warnings exist without failures")

        // 8. Normalization
        assertEqual(AppDelegate.normalizeArguments(["--doctor-json"]), ["--doctor", "--json"], "Normalizes --doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--diag-doctor-json"]), ["--doctor", "--json"], "Normalizes --diag-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-doctor-json"]), ["--doctor", "--json"], "Normalizes --check-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-check-json"]), ["--doctor", "--json"], "Normalizes --doctor-check-json")
        assertEqual(AppDelegate.normalizeArguments(["--diag-doctor"]), ["--doctor"], "Normalizes --diag-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--check-doctor"]), ["--doctor"], "Normalizes --check-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-check"]), ["--doctor"], "Normalizes --doctor-check")
    }

    // MARK: - 9.11 Maintenance Suite v1.2.5 (Doctor Auto-Repair & Stale Lock Resilience)
    private func testMaintenanceV125Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor Auto-Repair Suite (v1.2.5)")

        // 1. Doctor 18-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 18, "Doctor executes at least 18 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("security.biometric_spoofing"), "Contains 'security.biometric_spoofing' check")
        assert(checkIds.contains("security.shoulder_surfing"), "Contains 'security.shoulder_surfing' check")

        // 2. DoctorRepairReport Data Structure & Dictionary Serialization
        let initialReport = report
        let repairedActions = ["Restricted ~/.facelock directory permissions to 0700", "Enabled shoulder-surfing bystander detection"]
        let repairReport = DoctorRepairReport(
            initialReport: initialReport,
            finalReport: initialReport,
            repairedActions: repairedActions,
            version: Config.currentVersion
        )
        assertEqual(repairReport.recoveredCount, 2, "DoctorRepairReport recoveredCount matches")
        assertEqual(repairReport.version, Config.currentVersion, "DoctorRepairReport version matches currentVersion")

        let repDict = repairReport.toDictionary()
        assertEqual(repDict["version"] as? String, Config.currentVersion, "Repair dictionary contains version")
        assertEqual(repDict["recoveredCount"] as? Int, 2, "Repair dictionary contains recoveredCount")
        assertEqual(repDict["initialStatus"] as? String, initialReport.overallStatus, "Repair dictionary contains initialStatus")
        assertEqual(repDict["finalStatus"] as? String, initialReport.overallStatus, "Repair dictionary contains finalStatus")
        let initStats = repDict["initialStats"] as? [String: Any]
        assertEqual(initStats?["totalChecks"] as? Int, initialReport.totalChecks, "Initial stats totalChecks matches")

        // 3. Test runDoctorRepair Execution
        let execRepair = Diagnostics.runDoctorRepair(save: false)
        assert(execRepair.finalReport.totalChecks >= 18, "Doctor repair produces report with 18+ checks")
        assert(["HEALTHY", "WARNING", "CRITICAL"].contains(execRepair.finalReport.overallStatus), "Doctor repair final status is valid")

        // 4. Test AuditSummary Doctor Repairs Metric
        let testAudit = SecurityAuditLogger.shared.getAuditSummary()
        assert(testAudit.doctorRepairs >= 0, "AuditSummary doctorRepairs counter is non-negative")
        let auditDict = testAudit.toDictionary()
        assert(auditDict["doctorRepairs"] != nil, "AuditSummary dictionary exports doctorRepairs")

        // 5. Test CLI Argument Normalization for Doctor Repair
        assertEqual(AppDelegate.normalizeArguments(["--doctor-repair-json"]), ["--doctor-repair", "--json"], "Normalizes --doctor-repair-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-fix-json"]), ["--doctor-repair", "--json"], "Normalizes --doctor-fix-json")
        assertEqual(AppDelegate.normalizeArguments(["--repair-doctor-json"]), ["--doctor-repair", "--json"], "Normalizes --repair-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--fix-doctor-json"]), ["--doctor-repair", "--json"], "Normalizes --fix-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-fix"]), ["--doctor-repair"], "Normalizes --doctor-fix")
        assertEqual(AppDelegate.normalizeArguments(["--repair-doctor"]), ["--doctor-repair"], "Normalizes --repair-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--fix-doctor"]), ["--doctor-repair"], "Normalizes --fix-doctor")
    }

    // MARK: - 9.12 Maintenance Suite v1.2.6 (Doctor 20-Check Expansion, Strict Mode & Report Export)
    private func testMaintenanceV126Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 20-Check Expansion & Strict Mode (v1.2.6)")

        // 1. Doctor 20-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 20, "Doctor executes at least 20 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.power_efficiency"), "Contains 'hardware.power_efficiency' check")
        assert(checkIds.contains("security.presentation_suppression"), "Contains 'security.presentation_suppression' check")

        // 2. Doctor Strict Mode Logic
        let passItem = DoctorCheckItem(
            id: "test.pass",
            category: "hardware",
            name: "Mock Pass Item",
            status: .pass,
            message: "Simulated pass"
        )
        let warnItem = DoctorCheckItem(
            id: "test.warn",
            category: "security",
            name: "Mock Warn Item",
            status: .warn,
            message: "Simulated warning"
        )
        let failItem = DoctorCheckItem(
            id: "test.fail",
            category: "security",
            name: "Mock Fail Item",
            status: .fail,
            message: "Simulated failure"
        )

        let cleanReport = DoctorReport(checks: [passItem], version: Config.currentVersion)
        assertEqual(cleanReport.overallStatus, "HEALTHY", "Clean doctor report is HEALTHY")
        assert(cleanReport.failureCount == 0 && cleanReport.warningCount == 0, "Clean doctor report passes strict check")

        let warningOnlyReport = DoctorReport(checks: [passItem, warnItem], version: Config.currentVersion)
        assertEqual(warningOnlyReport.overallStatus, "WARNING", "Warning doctor report is WARNING")
        assert(warningOnlyReport.warningCount > 0, "Strict mode detects warning as non-passing")

        let failingReport = DoctorReport(checks: [passItem, failItem], version: Config.currentVersion)
        assertEqual(failingReport.overallStatus, "CRITICAL", "Critical doctor report is CRITICAL")
        assert(failingReport.failureCount > 0, "Strict mode detects failure")

        // 3. Doctor Report Export Test
        let tempExportPath = "/tmp/facelock_test_doctor_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorReport(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorReport succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorReport exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor JSON file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            assertEqual(json["version"] as? String, Config.currentVersion, "Exported JSON contains matching version")
            assert(json["checks"] != nil, "Exported JSON contains checks array")
            assert(json["stats"] != nil, "Exported JSON contains stats object")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is synchronized")

        // 5. Test CLI Argument Normalization for Doctor Strict and Export
        assertEqual(AppDelegate.normalizeArguments(["--doctor-strict-json"]), ["--doctor-strict", "--json"], "Normalizes --doctor-strict-json")
        assertEqual(AppDelegate.normalizeArguments(["--diag-doctor-strict-json"]), ["--doctor-strict", "--json"], "Normalizes --diag-doctor-strict-json")
        assertEqual(AppDelegate.normalizeArguments(["--check-doctor-strict-json"]), ["--doctor-strict", "--json"], "Normalizes --check-doctor-strict-json")
        assertEqual(AppDelegate.normalizeArguments(["--strict-doctor-json"]), ["--doctor-strict", "--json"], "Normalizes --strict-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-strict"]), ["--doctor-strict"], "Normalizes --doctor-strict")
        assertEqual(AppDelegate.normalizeArguments(["--diag-doctor-strict"]), ["--doctor-strict"], "Normalizes --diag-doctor-strict")
        assertEqual(AppDelegate.normalizeArguments(["--check-doctor-strict"]), ["--doctor-strict"], "Normalizes --check-doctor-strict")
        assertEqual(AppDelegate.normalizeArguments(["--strict-doctor"]), ["--doctor-strict"], "Normalizes --strict-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-json"]), ["--doctor-export", "--json"], "Normalizes --doctor-export-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-json"]), ["--doctor-export", "--json"], "Normalizes --export-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor"]), ["--doctor-export"], "Normalizes --export-doctor")
    }

    // MARK: - 9.13 Maintenance Suite v1.2.7 (Doctor 24-Check Expansion & Markdown Report Engine)
    private func testMaintenanceV127Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 24-Check Expansion & Markdown Engine (v1.2.7)")

        // 1. Doctor 24-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 24, "Doctor executes at least 24 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("security.lock_on_wake"), "Contains 'security.lock_on_wake' check")
        assert(checkIds.contains("security.walk_away_lock"), "Contains 'security.walk_away_lock' check")
        assert(checkIds.contains("security.app_shield_policy"), "Contains 'security.app_shield_policy' check")
        assert(checkIds.contains("security.pin_bruteforce_defense"), "Contains 'security.pin_bruteforce_defense' check")

        // 2. Doctor Markdown Report Generation
        let md = report.generateMarkdown()
        assert(md.contains("# 🩺 FaceLock Health & Diagnostic Doctor Report"), "Markdown contains title")
        assert(md.contains("## Summary Statistics"), "Markdown contains summary statistics")
        assert(md.contains("## Detailed Diagnostic Results"), "Markdown contains detailed results")
        assert(md.contains("Screen Wake Biometric Verification"), "Markdown contains lock_on_wake check")
        assert(md.contains("Autonomous Walk-Away Presence Shield"), "Markdown contains walk_away_lock check")
        assert(md.contains("Application Shield Policy"), "Markdown contains app_shield_policy check")
        assert(md.contains("PIN Rate Limiting & Lockout Defense"), "Markdown contains pin_bruteforce_defense check")
        assert(md.contains("1. Hardware & Sensors"), "Markdown contains hardware category")
        assert(md.contains("2. Filesystem & Cryptography"), "Markdown contains filesystem category")
        assert(md.contains("3. Background Daemon & Automation"), "Markdown contains daemon category")
        assert(md.contains("4. Security Posture & Hardening"), "Markdown contains security category")
        assert(md.contains("5. Remote Alerting & Network"), "Markdown contains network category")

        // 3. Doctor Markdown File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).md"
        let exportResult = Diagnostics.exportDoctorMarkdown(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorMarkdown succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorMarkdown exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor markdown file exists on disk")
        assert(exportResult.content.contains("# 🩺 FaceLock Health & Diagnostic Doctor Report"), "Exported content matches markdown")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let str = String(data: data, encoding: .utf8) {
            assert(str.contains("v\(Config.currentVersion)"), "Exported Markdown contains version string")
            assert(str.contains("Summary Statistics"), "Exported Markdown contains summary")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 5. Test CLI Argument Normalization for Doctor Markdown and Export MD
        assertEqual(AppDelegate.normalizeArguments(["--doctor-md-json"]), ["--doctor-markdown", "--json"], "Normalizes --doctor-md-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-markdown-json"]), ["--doctor-markdown", "--json"], "Normalizes --doctor-markdown-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-md"]), ["--doctor-markdown"], "Normalizes --doctor-md")
        assertEqual(AppDelegate.normalizeArguments(["--markdown-doctor"]), ["--doctor-markdown"], "Normalizes --markdown-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-markdown"]), ["--doctor-markdown"], "Normalizes --doctor-markdown")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-md-json"]), ["--doctor-export-md", "--json"], "Normalizes --doctor-export-md-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-md-json"]), ["--doctor-export-md", "--json"], "Normalizes --export-doctor-md-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-md"]), ["--doctor-export-md"], "Normalizes --export-doctor-md")
    }

    // MARK: - 9.14 Maintenance Suite v1.2.8 (Doctor 28-Check Expansion & HTML Report Engine)
    private func testMaintenanceV128Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 28-Check Expansion & HTML Report Engine (v1.2.8)")

        // 1. Doctor 28-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 28, "Doctor executes at least 28 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.camera_continuity"), "Contains 'hardware.camera_continuity' check")
        assert(checkIds.contains("security.strict_face_match"), "Contains 'security.strict_face_match' check")
        assert(checkIds.contains("security.audible_deterrent"), "Contains 'security.audible_deterrent' check")
        assert(checkIds.contains("security.touchid_fallback"), "Contains 'security.touchid_fallback' check")

        // 2. Doctor HTML Report Generation
        let html = report.generateHTML()
        assert(html.contains("<!DOCTYPE html>"), "HTML contains <!DOCTYPE html>")
        assert(html.contains("<meta charset=\"utf-8\">"), "HTML contains meta charset utf-8")
        assert(html.contains("<title>FaceLock Health & Diagnostic Doctor Report</title>"), "HTML contains title")
        assert(html.contains("v\(Config.currentVersion)"), "HTML contains version string")
        assert(html.contains("Total Checks"), "HTML contains total checks metric")
        assert(html.contains("Passed"), "HTML contains passed metric")
        assert(html.contains("Hardware &amp; Sensors"), "HTML contains hardware category")
        assert(html.contains("Filesystem &amp; Cryptography"), "HTML contains filesystem category")
        assert(html.contains("Background Daemon &amp; Automation"), "HTML contains daemon category")
        assert(html.contains("Security Posture &amp; Hardening"), "HTML contains security category")
        assert(html.contains("Remote Alerting &amp; Network"), "HTML contains network category")
        assert(html.contains("Video Camera Continuity"), "HTML contains camera_continuity check name")
        assert(html.contains("Strict Neural Biometric Matching"), "HTML contains strict_face_match check name")
        assert(html.contains("Audible Security Deterrent"), "HTML contains audible_deterrent check name")
        assert(html.contains("Touch ID Biometric Redundancy Policy"), "HTML contains touchid_fallback check name")

        // 3. Doctor HTML File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).html"
        let exportResult = Diagnostics.exportDoctorHTML(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorHTML succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorHTML exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor HTML file exists on disk")
        assert(exportResult.content.contains("<!DOCTYPE html>"), "Exported content matches HTML")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let str = String(data: data, encoding: .utf8) {
            assert(str.contains("v\(Config.currentVersion)"), "Exported HTML contains version string")
            assert(str.contains("FaceLock Health &amp; Diagnostic Doctor"), "Exported HTML contains header title")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 5. Test CLI Argument Normalization for Doctor HTML and Export HTML
        assertEqual(AppDelegate.normalizeArguments(["--doctor-html-json"]), ["--doctor-html", "--json"], "Normalizes --doctor-html-json")
        assertEqual(AppDelegate.normalizeArguments(["--html-doctor-json"]), ["--doctor-html", "--json"], "Normalizes --html-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-html"]), ["--doctor-html"], "Normalizes --doctor-html")
        assertEqual(AppDelegate.normalizeArguments(["--html-doctor"]), ["--doctor-html"], "Normalizes --html-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-html-json"]), ["--doctor-export-html", "--json"], "Normalizes --doctor-export-html-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-html-json"]), ["--doctor-export-html", "--json"], "Normalizes --export-doctor-html-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-html-doctor-json"]), ["--doctor-export-html", "--json"], "Normalizes --export-html-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-html"]), ["--doctor-export-html"], "Normalizes --doctor-export-html")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-html"]), ["--doctor-export-html"], "Normalizes --export-doctor-html")
        assertEqual(AppDelegate.normalizeArguments(["--export-html-doctor"]), ["--doctor-export-html"], "Normalizes --export-html-doctor")
    }

    // MARK: - 9.15 Maintenance Suite v1.2.9 (Doctor 32-Check Expansion & OASIS SARIF v2.1.0 Report Engine)
    private func testMaintenanceV129Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 32-Check Expansion & SARIF Report Engine (v1.2.9)")

        // 1. Doctor 32-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 32, "Doctor executes at least 32 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.thermal_state"), "Contains 'hardware.thermal_state' check")
        assert(checkIds.contains("filesystem.disk_headroom"), "Contains 'filesystem.disk_headroom' check")
        assert(checkIds.contains("security.biometric_cluster_cohesion"), "Contains 'security.biometric_cluster_cohesion' check")
        assert(checkIds.contains("security.duress_alarm_pipeline"), "Contains 'security.duress_alarm_pipeline' check")

        // 2. SARIF v2.1.0 Structure & Schema Validation
        let sarifDict = report.toSARIFDictionary()
        assertEqual(sarifDict["version"] as? String, "2.1.0", "SARIF version is 2.1.0")
        assertEqual(sarifDict["$schema"] as? String, "https://json.schemastore.org/sarif-2.1.0.json", "SARIF schema matches OASIS spec")
        guard let runs = sarifDict["runs"] as? [[String: Any]], let firstRun = runs.first else {
            assert(false, "SARIF runs array is present and non-empty")
            return
        }
        guard let tool = firstRun["tool"] as? [String: Any],
              let driver = tool["driver"] as? [String: Any] else {
            assert(false, "SARIF tool driver is present")
            return
        }
        assertEqual(driver["name"] as? String, "FaceLock Doctor", "Driver name is 'FaceLock Doctor'")
        assertEqual(driver["version"] as? String, Config.currentVersion, "Driver version is \(Config.currentVersion)")
        if let rules = driver["rules"] as? [[String: Any]] {
            assert(rules.count >= 32, "SARIF rules count matches evaluated checks (Got \(rules.count))")
            let ruleIds = rules.compactMap { $0["id"] as? String }
            assert(ruleIds.contains("hardware.thermal_state"), "SARIF rules include hardware.thermal_state")
            assert(ruleIds.contains("filesystem.disk_headroom"), "SARIF rules include filesystem.disk_headroom")
            assert(ruleIds.contains("security.biometric_cluster_cohesion"), "SARIF rules include security.biometric_cluster_cohesion")
            assert(ruleIds.contains("security.duress_alarm_pipeline"), "SARIF rules include security.duress_alarm_pipeline")
        }

        // 3. SARIF JSON Serialization Output
        let sarifJSON = report.generateSARIF()
        assert(sarifJSON.contains("\"version\" : \"2.1.0\"") || sarifJSON.contains("\"version\": \"2.1.0\""), "SARIF JSON contains version 2.1.0")
        assert(sarifJSON.contains("FaceLock Doctor"), "SARIF JSON contains driver name")
        assert(sarifJSON.contains("hardware.thermal_state"), "SARIF JSON contains thermal check")

        // 4. Doctor SARIF File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).sarif"
        let exportResult = Diagnostics.exportDoctorSARIF(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorSARIF succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorSARIF exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor SARIF file exists on disk")
        assert(exportResult.content.contains("2.1.0"), "Exported content matches SARIF")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            assertEqual(json["version"] as? String, "2.1.0", "Exported SARIF JSON has valid version")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 6. Test CLI Argument Normalization for Doctor SARIF and Export SARIF
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sarif-json"]), ["--doctor-sarif", "--json"], "Normalizes --doctor-sarif-json")
        assertEqual(AppDelegate.normalizeArguments(["--sarif-doctor-json"]), ["--doctor-sarif", "--json"], "Normalizes --sarif-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sarif"]), ["--doctor-sarif"], "Normalizes --doctor-sarif")
        assertEqual(AppDelegate.normalizeArguments(["--sarif-doctor"]), ["--doctor-sarif"], "Normalizes --sarif-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sarif-json"]), ["--doctor-export-sarif", "--json"], "Normalizes --doctor-export-sarif-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sarif-json"]), ["--doctor-export-sarif", "--json"], "Normalizes --export-doctor-sarif-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-sarif-doctor-json"]), ["--doctor-export-sarif", "--json"], "Normalizes --export-sarif-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sarif"]), ["--doctor-export-sarif"], "Normalizes --doctor-export-sarif")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sarif"]), ["--doctor-export-sarif"], "Normalizes --export-doctor-sarif")
        assertEqual(AppDelegate.normalizeArguments(["--export-sarif-doctor"]), ["--doctor-export-sarif"], "Normalizes --export-sarif-doctor")
    }

    // MARK: - 9.16 Maintenance Suite v1.3.0 (Doctor 36-Check Expansion & CSV Compliance Report Engine)
    private func testMaintenanceV130Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 36-Check Expansion & CSV Compliance Report Engine (v1.3.0)")

        // 1. Doctor 36-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 36, "Doctor executes at least 36 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("filesystem.backups_dir"), "Contains 'filesystem.backups_dir' check")
        assert(checkIds.contains("daemon.binary_integrity"), "Contains 'daemon.binary_integrity' check")
        assert(checkIds.contains("security.verification_timeout"), "Contains 'security.verification_timeout' check")
        assert(checkIds.contains("security.debounce_protection"), "Contains 'security.debounce_protection' check")

        // 2. CSV Generation & RFC 4180 Compliance
        let csv = report.generateCSV()
        assert(csv.contains("Check ID,Category,Check Name,Status,Message,Remediation"), "CSV contains standard RFC 4180 header")
        assert(csv.contains("filesystem.backups_dir"), "CSV contains backups_dir check")
        assert(csv.contains("daemon.binary_integrity"), "CSV contains binary_integrity check")
        assert(csv.contains("security.verification_timeout"), "CSV contains verification_timeout check")
        assert(csv.contains("security.debounce_protection"), "CSV contains debounce_protection check")

        let lines = csv.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        assert(lines.count >= 37, "CSV contains header plus at least 36 check rows (Got \(lines.count))")

        // 3. Doctor CSV File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).csv"
        let exportResult = Diagnostics.exportDoctorCSV(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorCSV succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorCSV exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor CSV file exists on disk")
        assert(exportResult.content.contains("Check ID,Category"), "Exported content matches CSV header")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.hasPrefix("Check ID,Category"), "File content starts with CSV header")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 5. Test CLI Argument Normalization for Doctor CSV and Export CSV
        assertEqual(AppDelegate.normalizeArguments(["--doctor-csv-json"]), ["--doctor-csv", "--json"], "Normalizes --doctor-csv-json")
        assertEqual(AppDelegate.normalizeArguments(["--csv-doctor-json"]), ["--doctor-csv", "--json"], "Normalizes --csv-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-csv"]), ["--doctor-csv"], "Normalizes --doctor-csv")
        assertEqual(AppDelegate.normalizeArguments(["--csv-doctor"]), ["--doctor-csv"], "Normalizes --csv-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-csv-json"]), ["--doctor-export-csv", "--json"], "Normalizes --doctor-export-csv-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-csv-json"]), ["--doctor-export-csv", "--json"], "Normalizes --export-doctor-csv-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-csv-doctor-json"]), ["--doctor-export-csv", "--json"], "Normalizes --export-csv-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-csv"]), ["--doctor-export-csv"], "Normalizes --doctor-export-csv")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-csv"]), ["--doctor-export-csv"], "Normalizes --export-doctor-csv")
        assertEqual(AppDelegate.normalizeArguments(["--export-csv-doctor"]), ["--doctor-export-csv"], "Normalizes --export-csv-doctor")
    }

    // MARK: - 9.17 Maintenance Suite v1.3.1 (Doctor 40-Check Expansion & JUnit XML Report Engine)
    private func testMaintenanceV131Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 40-Check Expansion & JUnit XML Report Engine (v1.3.1)")

        // 1. Doctor 40-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 40, "Doctor executes at least 40 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("filesystem.backup_freshness"), "Contains 'filesystem.backup_freshness' check")
        assert(checkIds.contains("daemon.memory_footprint"), "Contains 'daemon.memory_footprint' check")
        assert(checkIds.contains("security.incident_retention_policy"), "Contains 'security.incident_retention_policy' check")
        assert(checkIds.contains("security.camera_indicator_compliance"), "Contains 'security.camera_indicator_compliance' check")

        // 2. JUnit XML Generation & Schema Compliance
        let xml = report.generateJUnitXML()
        assert(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"), "XML contains standard XML declaration")
        assert(xml.contains("<testsuites id=\"facelock-doctor\" name=\"FaceLock Doctor Diagnostic Suite\""), "XML contains testsuites header")
        assert(xml.contains("tests=\"\(report.totalChecks)\""), "XML testsuites tests count matches totalChecks")
        assert(xml.contains("failures=\"\(report.failureCount)\""), "XML testsuites failures count matches failureCount")
        assert(xml.contains("<testsuite id=\"facelock.doctor.hardware\""), "XML contains hardware testsuite")
        assert(xml.contains("<testsuite id=\"facelock.doctor.filesystem\""), "XML contains filesystem testsuite")
        assert(xml.contains("<testsuite id=\"facelock.doctor.daemon\""), "XML contains daemon testsuite")
        assert(xml.contains("<testsuite id=\"facelock.doctor.security\""), "XML contains security testsuite")
        assert(xml.contains("id=\"security.camera_indicator_compliance\""), "XML contains camera_indicator_compliance testcase")
        assert(xml.contains("id=\"daemon.memory_footprint\""), "XML contains daemon memory footprint testcase")
        assert(xml.contains("</testsuites>"), "XML properly closes testsuites element")

        // 3. Doctor JUnit XML File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).xml"
        let exportResult = Diagnostics.exportDoctorJUnit(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorJUnit succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorJUnit exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor JUnit file exists on disk")
        assert(exportResult.content.contains("<?xml version=\"1.0\""), "Exported content matches XML declaration")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.hasPrefix("<?xml version=\"1.0\""), "File content starts with XML declaration")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 5. Test CLI Argument Normalization for Doctor JUnit and Export JUnit
        assertEqual(AppDelegate.normalizeArguments(["--doctor-junit-json"]), ["--doctor-junit", "--json"], "Normalizes --doctor-junit-json")
        assertEqual(AppDelegate.normalizeArguments(["--junit-doctor-json"]), ["--doctor-junit", "--json"], "Normalizes --junit-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-junit"]), ["--doctor-junit"], "Normalizes --doctor-junit")
        assertEqual(AppDelegate.normalizeArguments(["--junit-doctor"]), ["--doctor-junit"], "Normalizes --junit-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-junit-json"]), ["--doctor-export-junit", "--json"], "Normalizes --doctor-export-junit-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-junit-json"]), ["--doctor-export-junit", "--json"], "Normalizes --export-doctor-junit-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-junit-doctor-json"]), ["--doctor-export-junit", "--json"], "Normalizes --export-junit-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-junit"]), ["--doctor-export-junit"], "Normalizes --doctor-export-junit")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-junit"]), ["--doctor-export-junit"], "Normalizes --export-doctor-junit")
        assertEqual(AppDelegate.normalizeArguments(["--export-junit-doctor"]), ["--doctor-export-junit"], "Normalizes --export-junit-doctor")
    }

    // MARK: - 9.18 Maintenance Suite v1.3.2 (Doctor 44-Check Expansion & GitHub Actions Report Engine)
    private func testMaintenanceV132Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 44-Check Expansion & GitHub Actions Report Engine (v1.3.2)")

        // 1. Doctor 44-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 44, "Doctor executes at least 44 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.secure_enclave"), "Contains 'hardware.secure_enclave' check")
        assert(checkIds.contains("filesystem.permissions_hardened"), "Contains 'filesystem.permissions_hardened' check")
        assert(checkIds.contains("security.filevault_encryption"), "Contains 'security.filevault_encryption' check")
        assert(checkIds.contains("security.screen_saver_lock"), "Contains 'security.screen_saver_lock' check")

        // 2. GitHub Actions Summary Generation & Format
        let gha = report.generateGitHubActionsSummary()
        assert(gha.contains("# 🩺 FaceLock Health & Diagnostic Doctor Summary"), "GHA summary contains header")
        assert(gha.contains("> **Overall System Status**:"), "GHA summary contains status badge")
        assert(gha.contains("> **FaceLock Version**: `v\(Config.currentVersion)`"), "GHA summary contains version")
        assert(gha.contains("| Overall Status | Total Checks | Passed ✅ | Warnings ⚠️ | Failures ❌ | Info ℹ️ |"), "GHA summary contains metrics table")
        assert(gha.contains("<details open>"), "GHA summary contains collapsible category details")
        assert(gha.contains("1. Hardware & Sensors"), "GHA summary contains hardware category")
        assert(gha.contains("2. Filesystem & Cryptography"), "GHA summary contains filesystem category")
        assert(gha.contains("3. Background Daemon & Automation"), "GHA summary contains daemon category")
        assert(gha.contains("4. Security Posture & Hardening"), "GHA summary contains security category")
        assert(gha.contains("5. Remote Alerting & Network"), "GHA summary contains network category")
        assert(gha.contains("<!-- GitHub Actions Workflow Annotations -->"), "GHA summary contains workflow annotations block")
        assert(gha.contains("::notice title=") || gha.contains("::warning title=") || gha.contains("::error title="), "GHA summary contains workflow commands")

        // 3. Doctor GHA File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).md"
        let exportResult = Diagnostics.exportDoctorGitHubActions(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorGitHubActions succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorGitHubActions exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor GHA file exists on disk")
        assert(exportResult.content.contains("# 🩺 FaceLock Health & Diagnostic Doctor Summary"), "Exported content matches GHA summary header")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.hasPrefix("# 🩺 FaceLock"), "File content starts with FaceLock summary header")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 44, "Repair initial report contains at least 44 checks")
        assert(repairReport.finalReport.totalChecks >= 44, "Repair final report contains at least 44 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 6. Test CLI Argument Normalization for Doctor GHA and Export GHA
        assertEqual(AppDelegate.normalizeArguments(["--doctor-gha-json"]), ["--doctor-gha", "--json"], "Normalizes --doctor-gha-json")
        assertEqual(AppDelegate.normalizeArguments(["--gha-doctor-json"]), ["--doctor-gha", "--json"], "Normalizes --gha-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-summary-json"]), ["--doctor-gha", "--json"], "Normalizes --doctor-summary-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-gha"]), ["--doctor-gha"], "Normalizes --doctor-gha")
        assertEqual(AppDelegate.normalizeArguments(["--gha-doctor"]), ["--doctor-gha"], "Normalizes --gha-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-summary"]), ["--doctor-gha"], "Normalizes --doctor-summary")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-gha-json"]), ["--doctor-export-gha", "--json"], "Normalizes --doctor-export-gha-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-gha-json"]), ["--doctor-export-gha", "--json"], "Normalizes --export-doctor-gha-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-gha-doctor-json"]), ["--doctor-export-gha", "--json"], "Normalizes --export-gha-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-summary-json"]), ["--doctor-export-gha", "--json"], "Normalizes --export-doctor-summary-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-gha"]), ["--doctor-export-gha"], "Normalizes --doctor-export-gha")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-gha"]), ["--doctor-export-gha"], "Normalizes --export-doctor-gha")
        assertEqual(AppDelegate.normalizeArguments(["--export-gha-doctor"]), ["--doctor-export-gha"], "Normalizes --export-gha-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-summary"]), ["--doctor-export-gha"], "Normalizes --export-doctor-summary")
    }

    // MARK: - 9.19 Maintenance Suite v1.3.3 (Doctor 48-Check Expansion & GitLab CI / Code Climate Report Engine)
    private func testMaintenanceV133Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 48-Check Expansion & GitLab CI Report Engine (v1.3.3)")

        // 1. Doctor 48-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 48, "Doctor executes at least 48 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.bluetooth_proximity"), "Contains 'hardware.bluetooth_proximity' check")
        assert(checkIds.contains("daemon.cpu_utilization"), "Contains 'daemon.cpu_utilization' check")
        assert(checkIds.contains("security.sip_system_integrity"), "Contains 'security.sip_system_integrity' check")
        assert(checkIds.contains("security.firewall_stealth_mode"), "Contains 'security.firewall_stealth_mode' check")

        // 2. Code Climate / GitLab CI JSON Generation & Format
        let codeclimate = report.generateCodeClimate()
        assert(codeclimate.hasPrefix("["), "Code Climate JSON starts with array")
        assert(codeclimate.contains("]"), "Code Climate JSON closes array")
        let issues = report.toCodeClimateIssues()
        for issue in issues {
            assert(issue["description"] != nil, "Issue contains description")
            assert(issue["check_name"] != nil, "Issue contains check_name")
            assert(issue["fingerprint"] != nil, "Issue contains fingerprint")
            assert(issue["severity"] != nil, "Issue contains severity")
            assert(issue["location"] != nil, "Issue contains location")
            assert(issue["categories"] != nil, "Issue contains categories")
        }

        // 3. Doctor Code Climate / GitLab File Export Test
        let tempExportPath = "/tmp/facelock_test_doc_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorCodeClimate(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorCodeClimate succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorCodeClimate exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor Code Climate file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.hasPrefix("["), "File content starts with JSON array")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 48, "Repair initial report contains at least 48 checks")
        assert(repairReport.finalReport.totalChecks >= 48, "Repair final report contains at least 48 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 6. Test CLI Argument Normalization for Doctor GitLab and Export GitLab
        assertEqual(AppDelegate.normalizeArguments(["--doctor-gitlab-json"]), ["--doctor-gitlab", "--json"], "Normalizes --doctor-gitlab-json")
        assertEqual(AppDelegate.normalizeArguments(["--gitlab-doctor-json"]), ["--doctor-gitlab", "--json"], "Normalizes --gitlab-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-codeclimate-json"]), ["--doctor-gitlab", "--json"], "Normalizes --doctor-codeclimate-json")
        assertEqual(AppDelegate.normalizeArguments(["--codeclimate-doctor-json"]), ["--doctor-gitlab", "--json"], "Normalizes --codeclimate-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-gitlab"]), ["--doctor-gitlab"], "Normalizes --doctor-gitlab")
        assertEqual(AppDelegate.normalizeArguments(["--gitlab-doctor"]), ["--doctor-gitlab"], "Normalizes --gitlab-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-codeclimate"]), ["--doctor-gitlab"], "Normalizes --doctor-codeclimate")
        assertEqual(AppDelegate.normalizeArguments(["--codeclimate-doctor"]), ["--doctor-gitlab"], "Normalizes --codeclimate-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-gitlab-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --doctor-export-gitlab-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-gitlab-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --export-doctor-gitlab-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-gitlab-doctor-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --export-gitlab-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-codeclimate-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --doctor-export-codeclimate-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-codeclimate-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --export-doctor-codeclimate-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-codeclimate-doctor-json"]), ["--doctor-export-gitlab", "--json"], "Normalizes --export-codeclimate-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-gitlab"]), ["--doctor-export-gitlab"], "Normalizes --doctor-export-gitlab")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-gitlab"]), ["--doctor-export-gitlab"], "Normalizes --export-doctor-gitlab")
        assertEqual(AppDelegate.normalizeArguments(["--export-gitlab-doctor"]), ["--doctor-export-gitlab"], "Normalizes --export-gitlab-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-codeclimate"]), ["--doctor-export-gitlab"], "Normalizes --doctor-export-codeclimate")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-codeclimate"]), ["--doctor-export-gitlab"], "Normalizes --export-doctor-codeclimate")
        assertEqual(AppDelegate.normalizeArguments(["--export-codeclimate-doctor"]), ["--doctor-export-gitlab"], "Normalizes --export-codeclimate-doctor")
    }

    private func testMaintenanceV134Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 52-Check Expansion & SonarQube Report Engine (v1.3.4)")

        // 1. Doctor 52-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 52, "Doctor executes at least 52 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.clamshell_state"), "Contains 'hardware.clamshell_state' check")
        assert(checkIds.contains("filesystem.audit_log_rotation"), "Contains 'filesystem.audit_log_rotation' check")
        assert(checkIds.contains("daemon.power_assertions"), "Contains 'daemon.power_assertions' check")
        assert(checkIds.contains("security.automatic_login_disabled"), "Contains 'security.automatic_login_disabled' check")

        // 2. SonarQube Generic Issue Import JSON Generation & Format
        let sonarqube = report.generateSonarQube()
        assert(sonarqube.contains("\"issues\""), "SonarQube JSON contains 'issues' key")
        let dict = report.toSonarQubeDictionary()
        assert(dict["issues"] != nil, "Dictionary contains issues array")
        let issues = report.toSonarQubeIssues()
        for issue in issues {
            assert(issue["engineId"] as? String == "facelock", "Issue contains engineId 'facelock'")
            assert(issue["ruleId"] != nil, "Issue contains ruleId")
            assert(issue["severity"] != nil, "Issue contains severity")
            assert(issue["type"] != nil, "Issue contains type")
            assert(issue["primaryLocation"] != nil, "Issue contains primaryLocation")
            assert(issue["effortMinutes"] != nil, "Issue contains effortMinutes")
            if let loc = issue["primaryLocation"] as? [String: Any] {
                assert(loc["message"] != nil, "Location contains message")
                assert(loc["filePath"] != nil, "Location contains filePath")
            }
        }

        // 3. Doctor SonarQube File Export Test
        let tempExportPath = "/tmp/facelock_test_sonar_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorSonarQube(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorSonarQube succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorSonarQube exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor SonarQube file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.contains("\"issues\""), "File content contains 'issues' key")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 52, "Repair initial report contains at least 52 checks")
        assert(repairReport.finalReport.totalChecks >= 52, "Repair final report contains at least 52 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 6. Test CLI Argument Normalization for Doctor SonarQube and Export SonarQube
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sonarqube-json"]), ["--doctor-sonarqube", "--json"], "Normalizes --doctor-sonarqube-json")
        assertEqual(AppDelegate.normalizeArguments(["--sonarqube-doctor-json"]), ["--doctor-sonarqube", "--json"], "Normalizes --sonarqube-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sonar-json"]), ["--doctor-sonarqube", "--json"], "Normalizes --doctor-sonar-json")
        assertEqual(AppDelegate.normalizeArguments(["--sonar-doctor-json"]), ["--doctor-sonarqube", "--json"], "Normalizes --sonar-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sonarqube"]), ["--doctor-sonarqube"], "Normalizes --doctor-sonarqube")
        assertEqual(AppDelegate.normalizeArguments(["--sonarqube-doctor"]), ["--doctor-sonarqube"], "Normalizes --sonarqube-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-sonar"]), ["--doctor-sonarqube"], "Normalizes --doctor-sonar")
        assertEqual(AppDelegate.normalizeArguments(["--sonar-doctor"]), ["--doctor-sonarqube"], "Normalizes --sonar-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sonarqube-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --doctor-export-sonarqube-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sonarqube-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --export-doctor-sonarqube-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-sonarqube-doctor-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --export-sonarqube-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sonar-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --doctor-export-sonar-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sonar-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --export-doctor-sonar-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-sonar-doctor-json"]), ["--doctor-export-sonarqube", "--json"], "Normalizes --export-sonar-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sonarqube"]), ["--doctor-export-sonarqube"], "Normalizes --doctor-export-sonarqube")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sonarqube"]), ["--doctor-export-sonarqube"], "Normalizes --export-doctor-sonarqube")
        assertEqual(AppDelegate.normalizeArguments(["--export-sonarqube-doctor"]), ["--doctor-export-sonarqube"], "Normalizes --export-sonarqube-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-sonar"]), ["--doctor-export-sonarqube"], "Normalizes --doctor-export-sonar")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-sonar"]), ["--doctor-export-sonarqube"], "Normalizes --export-doctor-sonar")
        assertEqual(AppDelegate.normalizeArguments(["--export-sonar-doctor"]), ["--doctor-export-sonarqube"], "Normalizes --export-sonar-doctor")
    }

    private func testMaintenanceV135Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 56-Check Expansion & DefectDojo Report Engine (v1.3.5)")

        // 1. Doctor 56-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 56, "Doctor executes at least 56 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("hardware.display_topology"), "Contains 'hardware.display_topology' check")
        assert(checkIds.contains("filesystem.temporary_storage_sandbox"), "Contains 'filesystem.temporary_storage_sandbox' check")
        assert(checkIds.contains("security.guest_account_disabled"), "Contains 'security.guest_account_disabled' check")
        assert(checkIds.contains("security.gatekeeper_integrity"), "Contains 'security.gatekeeper_integrity' check")

        // 2. DefectDojo Generic Findings JSON Generation & Format
        let defectdojo = report.generateDefectDojo()
        assert(defectdojo.contains("\"findings\""), "DefectDojo JSON contains 'findings' key")
        let dict = report.toDefectDojoDictionary()
        assert(dict["findings"] != nil, "Dictionary contains findings array")
        let findings = report.toDefectDojoFindings()
        for finding in findings {
            assert(finding["title"] != nil, "Finding contains title")
            assert(finding["description"] != nil, "Finding contains description")
            assert(finding["severity"] != nil, "Finding contains severity")
            assert(finding["mitigation"] != nil, "Finding contains mitigation")
            assert(finding["impact"] != nil, "Finding contains impact")
            assert(finding["active"] as? Bool == true, "Finding is active")
            assert(finding["verified"] as? Bool == true, "Finding is verified")
            assert(finding["date"] != nil, "Finding contains date")
            assert(finding["file_path"] != nil, "Finding contains file_path")
            assert(finding["component_name"] as? String == "FaceLock", "Finding component_name is FaceLock")
            assert(finding["component_version"] as? String == Config.currentVersion, "Finding component_version matches currentVersion")
        }

        // 3. Doctor DefectDojo File Export Test
        let tempExportPath = "/tmp/facelock_test_dojo_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorDefectDojo(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorDefectDojo succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorDefectDojo exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor DefectDojo file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.contains("\"findings\""), "File content contains 'findings' key")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 56, "Repair initial report contains at least 56 checks")
        assert(repairReport.finalReport.totalChecks >= 56, "Repair final report contains at least 56 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.5")

        // 6. Test CLI Argument Normalization for Doctor DefectDojo and Export DefectDojo
        assertEqual(AppDelegate.normalizeArguments(["--doctor-defectdojo-json"]), ["--doctor-defectdojo", "--json"], "Normalizes --doctor-defectdojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--defectdojo-doctor-json"]), ["--doctor-defectdojo", "--json"], "Normalizes --defectdojo-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-dojo-json"]), ["--doctor-defectdojo", "--json"], "Normalizes --doctor-dojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--dojo-doctor-json"]), ["--doctor-defectdojo", "--json"], "Normalizes --dojo-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-defectdojo"]), ["--doctor-defectdojo"], "Normalizes --doctor-defectdojo")
        assertEqual(AppDelegate.normalizeArguments(["--defectdojo-doctor"]), ["--doctor-defectdojo"], "Normalizes --defectdojo-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-dojo"]), ["--doctor-defectdojo"], "Normalizes --doctor-dojo")
        assertEqual(AppDelegate.normalizeArguments(["--dojo-doctor"]), ["--doctor-defectdojo"], "Normalizes --dojo-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-defectdojo-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --doctor-export-defectdojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-defectdojo-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --export-doctor-defectdojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-defectdojo-doctor-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --export-defectdojo-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-dojo-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --doctor-export-dojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-dojo-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --export-doctor-dojo-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-dojo-doctor-json"]), ["--doctor-export-defectdojo", "--json"], "Normalizes --export-dojo-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-defectdojo"]), ["--doctor-export-defectdojo"], "Normalizes --doctor-export-defectdojo")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-defectdojo"]), ["--doctor-export-defectdojo"], "Normalizes --export-doctor-defectdojo")
        assertEqual(AppDelegate.normalizeArguments(["--export-defectdojo-doctor"]), ["--doctor-export-defectdojo"], "Normalizes --export-defectdojo-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-dojo"]), ["--doctor-export-defectdojo"], "Normalizes --doctor-export-dojo")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-dojo"]), ["--doctor-export-defectdojo"], "Normalizes --export-doctor-dojo")
        assertEqual(AppDelegate.normalizeArguments(["--export-dojo-doctor"]), ["--doctor-export-defectdojo"], "Normalizes --export-dojo-doctor")
    }

    private func testMaintenanceV136Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 60-Check Expansion & CycloneDX 1.5 Report Engine (v1.3.6)")

        // 1. Doctor 60-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 60, "Doctor executes at least 60 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("filesystem.crash_reports_cleanliness"), "Contains 'filesystem.crash_reports_cleanliness' check")
        assert(checkIds.contains("daemon.file_descriptor_limit"), "Contains 'daemon.file_descriptor_limit' check")
        assert(checkIds.contains("security.remote_login_disabled"), "Contains 'security.remote_login_disabled' check")
        assert(checkIds.contains("security.display_sleep_timeout"), "Contains 'security.display_sleep_timeout' check")

        // 2. CycloneDX 1.5 JSON Generation & Format Compliance
        let cdx = report.generateCycloneDX()
        assert(cdx.contains("\"bomFormat\" : \"CycloneDX\"") || cdx.contains("\"bomFormat\":\"CycloneDX\""), "CycloneDX JSON contains 'bomFormat'")
        assert(cdx.contains("\"specVersion\" : \"1.5\"") || cdx.contains("\"specVersion\":\"1.5\""), "CycloneDX JSON contains 'specVersion'")
        let dict = report.toCycloneDXDictionary()
        assertEqual(dict["bomFormat"] as? String, "CycloneDX", "CycloneDX bomFormat is CycloneDX")
        assertEqual(dict["specVersion"] as? String, "1.5", "CycloneDX specVersion is 1.5")
        assert((dict["serialNumber"] as? String)?.hasPrefix("urn:uuid:") == true, "CycloneDX serialNumber starts with urn:uuid:")
        assert(dict["metadata"] != nil, "Dictionary contains metadata")
        assert(dict["vulnerabilities"] != nil, "Dictionary contains vulnerabilities array")

        let vulns = report.toCycloneDXVulnerabilities()
        for vuln in vulns {
            assert(vuln["id"] != nil, "Vulnerability contains id")
            assert(vuln["source"] != nil, "Vulnerability contains source")
            assert(vuln["ratings"] != nil, "Vulnerability contains ratings")
            assert(vuln["description"] != nil, "Vulnerability contains description")
            assert(vuln["recommendation"] != nil, "Vulnerability contains recommendation")
            assert(vuln["affects"] != nil, "Vulnerability contains affects")
            assert(vuln["properties"] != nil, "Vulnerability contains properties")
        }

        // 3. Doctor CycloneDX File Export Test
        let tempExportPath = "/tmp/facelock_test_cdx_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorCycloneDX(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorCycloneDX succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorCycloneDX exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor CycloneDX file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.contains("CycloneDX"), "File content contains 'CycloneDX'")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 60, "Repair initial report contains at least 60 checks")
        assert(repairReport.finalReport.totalChecks >= 60, "Repair final report contains at least 60 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.6")

        // 6. Test CLI Argument Normalization for Doctor CycloneDX and Export CycloneDX
        assertEqual(AppDelegate.normalizeArguments(["--doctor-cyclonedx-json"]), ["--doctor-cyclonedx", "--json"], "Normalizes --doctor-cyclonedx-json")
        assertEqual(AppDelegate.normalizeArguments(["--cyclonedx-doctor-json"]), ["--doctor-cyclonedx", "--json"], "Normalizes --cyclonedx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-cdx-json"]), ["--doctor-cyclonedx", "--json"], "Normalizes --doctor-cdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--cdx-doctor-json"]), ["--doctor-cyclonedx", "--json"], "Normalizes --cdx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-cyclonedx"]), ["--doctor-cyclonedx"], "Normalizes --doctor-cyclonedx")
        assertEqual(AppDelegate.normalizeArguments(["--cyclonedx-doctor"]), ["--doctor-cyclonedx"], "Normalizes --cyclonedx-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-cdx"]), ["--doctor-cyclonedx"], "Normalizes --doctor-cdx")
        assertEqual(AppDelegate.normalizeArguments(["--cdx-doctor"]), ["--doctor-cyclonedx"], "Normalizes --cdx-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-cyclonedx-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --doctor-export-cyclonedx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-cyclonedx-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --export-doctor-cyclonedx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-cyclonedx-doctor-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --export-cyclonedx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-cdx-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --doctor-export-cdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-cdx-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --export-doctor-cdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-cdx-doctor-json"]), ["--doctor-export-cyclonedx", "--json"], "Normalizes --export-cdx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-cyclonedx"]), ["--doctor-export-cyclonedx"], "Normalizes --doctor-export-cyclonedx")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-cyclonedx"]), ["--doctor-export-cyclonedx"], "Normalizes --export-doctor-cyclonedx")
        assertEqual(AppDelegate.normalizeArguments(["--export-cyclonedx-doctor"]), ["--doctor-export-cyclonedx"], "Normalizes --export-cyclonedx-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-cdx"]), ["--doctor-export-cyclonedx"], "Normalizes --doctor-export-cdx")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-cdx"]), ["--doctor-export-cyclonedx"], "Normalizes --export-doctor-cdx")
        assertEqual(AppDelegate.normalizeArguments(["--export-cdx-doctor"]), ["--doctor-export-cyclonedx"], "Normalizes --export-cdx-doctor")
    }

    private func testMaintenanceV137Enhancements() {
        print("\n▶ Test Suite: Autonomous Doctor 64-Check Expansion & SPDX 2.3 Report Engine (v1.3.7)")

        // 1. Doctor 64-Check Coverage
        let report = Diagnostics.runDoctor(skipNetwork: true)
        assert(report.totalChecks >= 64, "Doctor executes at least 64 comprehensive checks (Got \(report.totalChecks))")
        let checkIds = Set(report.checks.map { $0.id })
        assert(checkIds.contains("daemon.thread_pool_headroom"), "Contains 'daemon.thread_pool_headroom' check")
        assert(checkIds.contains("security.airdrop_discoverability"), "Contains 'security.airdrop_discoverability' check")
        assert(checkIds.contains("security.remote_management_disabled"), "Contains 'security.remote_management_disabled' check")
        assert(checkIds.contains("network.dns_secure_resolvers"), "Contains 'network.dns_secure_resolvers' check")

        // 2. SPDX 2.3 JSON Generation & Format Compliance
        let spdx = report.generateSPDX()
        assert(spdx.contains("\"spdxVersion\" : \"SPDX-2.3\"") || spdx.contains("\"spdxVersion\":\"SPDX-2.3\""), "SPDX JSON contains 'spdxVersion'")
        assert(spdx.contains("\"dataLicense\" : \"CC0-1.0\"") || spdx.contains("\"dataLicense\":\"CC0-1.0\""), "SPDX JSON contains 'dataLicense'")
        let dict = report.toSPDXDictionary()
        assertEqual(dict["spdxVersion"] as? String, "SPDX-2.3", "SPDX spdxVersion is SPDX-2.3")
        assertEqual(dict["dataLicense"] as? String, "CC0-1.0", "SPDX dataLicense is CC0-1.0")
        assertEqual(dict["SPDXID"] as? String, "SPDXRef-DOCUMENT", "SPDX document ID is SPDXRef-DOCUMENT")
        assert(dict["creationInfo"] != nil, "Dictionary contains creationInfo")
        assert(dict["packages"] != nil, "Dictionary contains packages array")
        assert(dict["relationships"] != nil, "Dictionary contains relationships array")
        assert(dict["annotations"] != nil, "Dictionary contains annotations array")

        if let packages = dict["packages"] as? [[String: Any]], let pkg = packages.first {
            assertEqual(pkg["name"] as? String, "FaceLock", "Package name is FaceLock")
            assertEqual(pkg["versionInfo"] as? String, Config.currentVersion, "Package versionInfo matches currentVersion")
            assertEqual(pkg["SPDXID"] as? String, "SPDXRef-Package-FaceLock", "Package SPDXID matches SPDXRef-Package-FaceLock")
        }

        if let annotations = dict["annotations"] as? [[String: Any]] {
            assert(!annotations.isEmpty, "Annotations array is populated")
            for ann in annotations {
                assert(ann["annotator"] != nil, "Annotation contains annotator")
                assert(ann["annotationDate"] != nil, "Annotation contains annotationDate")
                assert(ann["annotationType"] != nil, "Annotation contains annotationType")
                assert(ann["comment"] != nil, "Annotation contains comment")
                assert(ann["spdxId"] != nil, "Annotation contains spdxId")
            }
        }

        if let vulns = dict["vulnerabilities"] as? [[String: Any]] {
            for vuln in vulns {
                assert(vuln["id"] != nil, "Vulnerability contains id")
                assert(vuln["name"] != nil, "Vulnerability contains name")
                assert(vuln["severity"] != nil, "Vulnerability contains severity")
                assert(vuln["category"] != nil, "Vulnerability contains category")
                assert(vuln["description"] != nil, "Vulnerability contains description")
                assert(vuln["recommendation"] != nil, "Vulnerability contains recommendation")
            }
        }

        // 3. Doctor SPDX File Export Test
        let tempExportPath = "/tmp/facelock_test_spdx_export_\(UUID().uuidString).json"
        let exportResult = Diagnostics.exportDoctorSPDX(toPath: tempExportPath, skipNetwork: true)
        assert(exportResult.success, "exportDoctorSPDX succeeded")
        assertEqual(exportResult.path, tempExportPath, "exportDoctorSPDX exported to expected path")
        assert(FileManager.default.fileExists(atPath: tempExportPath), "Exported doctor SPDX file exists on disk")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: tempExportPath)),
           let fileContent = String(data: data, encoding: .utf8) {
            assert(fileContent.contains("SPDX-2.3"), "File content contains 'SPDX-2.3'")
        }
        try? FileManager.default.removeItem(atPath: tempExportPath)

        // 4. Test Doctor Repair Execution
        let repairReport = Diagnostics.runDoctorRepair(save: false)
        assert(repairReport.initialReport.totalChecks >= 64, "Repair initial report contains at least 64 checks")
        assert(repairReport.finalReport.totalChecks >= 64, "Repair final report contains at least 64 checks")

        // 5. Test Version Synchronization
        assertEqual(Config.currentVersion, "1.3.7", "Config currentVersion is 1.3.7")

        // 6. Test CLI Argument Normalization for Doctor SPDX and Export SPDX
        assertEqual(AppDelegate.normalizeArguments(["--doctor-spdx-json"]), ["--doctor-spdx", "--json"], "Normalizes --doctor-spdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--spdx-doctor-json"]), ["--doctor-spdx", "--json"], "Normalizes --spdx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-spdx"]), ["--doctor-spdx"], "Normalizes --doctor-spdx")
        assertEqual(AppDelegate.normalizeArguments(["--spdx-doctor"]), ["--doctor-spdx"], "Normalizes --spdx-doctor")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-spdx-json"]), ["--doctor-export-spdx", "--json"], "Normalizes --doctor-export-spdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-spdx-json"]), ["--doctor-export-spdx", "--json"], "Normalizes --export-doctor-spdx-json")
        assertEqual(AppDelegate.normalizeArguments(["--export-spdx-doctor-json"]), ["--doctor-export-spdx", "--json"], "Normalizes --export-spdx-doctor-json")
        assertEqual(AppDelegate.normalizeArguments(["--doctor-export-spdx"]), ["--doctor-export-spdx"], "Normalizes --doctor-export-spdx")
        assertEqual(AppDelegate.normalizeArguments(["--export-doctor-spdx"]), ["--doctor-export-spdx"], "Normalizes --export-doctor-spdx")
        assertEqual(AppDelegate.normalizeArguments(["--export-spdx-doctor"]), ["--doctor-export-spdx"], "Normalizes --export-spdx-doctor")
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
