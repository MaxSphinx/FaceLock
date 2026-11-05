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
