import AppKit
import AVFoundation

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public static let commandNotificationName = NSNotification.Name("io.github.facelock.command")

    public static func notifyDaemonReload() {
        DistributedNotificationCenter.default().postNotificationName(
            AppDelegate.commandNotificationName,
            object: nil,
            userInfo: ["action": "reload-config"],
            deliverImmediately: true
        )
    }

    public static func normalizeArguments(_ rawArgs: [String]) -> [String] {
        var args: [String] = []
        for arg in rawArgs {
            switch arg {
            case "--status-json":
                args.append(contentsOf: ["--status", "--json"])
            case "--config-json":
                args.append(contentsOf: ["--config", "--json"])
            case "--health-json":
                args.append(contentsOf: ["--health", "--json"])
            case "--diagnostics-json":
                args.append(contentsOf: ["--diagnostics", "--json"])
            case "--diagnostics-gui-json", "--diagnostics-ui-json", "--diagnostics-window-json":
                args.append(contentsOf: ["--diagnostics-gui", "--json"])
            case "--vectors-json":
                args.append(contentsOf: ["--vectors", "--json"])
            case "--optimize-vectors-json":
                args.append(contentsOf: ["--optimize-vectors", "--json"])
            case "--incidents-summary-json":
                args.append(contentsOf: ["--incidents-summary", "--json"])
            case "--incidents-json":
                args.append(contentsOf: ["--incidents", "--json"])
            case "--latest-incident-json":
                args.append(contentsOf: ["--latest-incident", "--json"])
            case "--is-locked-json":
                args.append(contentsOf: ["--is-locked", "--json"])
            case "--audit-json":
                args.append(contentsOf: ["--audit", "--json"])
            case "--apps-json":
                args.append(contentsOf: ["--apps", "--json"])
            case "--protect-app-json":
                args.append(contentsOf: ["--protect-app", "--json"])
            case "--unprotect-app-json":
                args.append(contentsOf: ["--unprotect-app", "--json"])
            case "--ignore-app-json":
                args.append(contentsOf: ["--ignore-app", "--json"])
            case "--unignore-app-json":
                args.append(contentsOf: ["--unignore-app", "--json"])
            case "--check-app-json":
                args.append(contentsOf: ["--check-app", "--json"])
            case "--version-json":
                args.append(contentsOf: ["--version", "--json"])
            case "--toggle-walkaway-json":
                args.append(contentsOf: ["--toggle-walkaway", "--json"])
            case "--toggle-wake-json":
                args.append(contentsOf: ["--toggle-wake", "--json"])
            case "--toggle-liveness-json":
                args.append(contentsOf: ["--toggle-liveness", "--json"])
            case "--toggle-touchid-json":
                args.append(contentsOf: ["--toggle-touchid", "--json"])
            case "--cameras-json":
                args.append(contentsOf: ["--cameras", "--json"])
            case "--reset-camera-json":
                args.append(contentsOf: ["--reset-camera", "--json"])
            case "--reset-apps-json":
                args.append(contentsOf: ["--reset-apps", "--json"])
            case "--profiles-json":
                args.append(contentsOf: ["--profiles", "--json"])
            case "--toggle-shoulder-json", "--toggle-shoulder-defense-json":
                args.append(contentsOf: ["--toggle-shoulder-defense", "--json"])
            case "--toggle-audible-json":
                args.append(contentsOf: ["--toggle-audible", "--json"])
            case "--toggle-battery-aware-json", "--toggle-battery-json":
                args.append(contentsOf: ["--toggle-battery-aware", "--json"])
            case "--battery-status-json", "--power-status-json":
                args.append(contentsOf: ["--battery-status", "--json"])
            case "--toggle-presentation-json", "--toggle-presentation-mode-json", "--presentation-mode-json":
                args.append(contentsOf: ["--toggle-presentation", "--json"])
            case "--lockdown-json", "--emergency-lockdown-json":
                args.append(contentsOf: ["--lockdown", "--json"])
            case "--toggle-json":
                args.append(contentsOf: ["--toggle", "--json"])
            case "--pause-json":
                args.append(contentsOf: ["--pause", "--json"])
            case "--resume-json", "--unpause-json":
                args.append(contentsOf: ["--resume", "--json"])
            case "--lock-json", "--test-lock-json":
                args.append(contentsOf: ["--lock", "--json"])
            case "--reload-json", "--reload-config-json":
                args.append(contentsOf: ["--reload", "--json"])
            case "--reset-session-json":
                args.append(contentsOf: ["--reset-session", "--json"])
            case "--profile-json", "--set-profile-json":
                args.append(contentsOf: ["--profiles", "--json"])
            case "--verify-face-json":
                args.append(contentsOf: ["--verify-face", "--json"])
            case "--audit-stats-json", "--log-stats-json":
                args.append(contentsOf: ["--audit-stats", "--json"])
            case "--audit-gui-json", "--audit-ui-json", "--audit-window-json":
                args.append(contentsOf: ["--audit-gui", "--json"])
            case "--apps-gui-json", "--apps-ui-json", "--apps-window-json":
                args.append(contentsOf: ["--apps-gui", "--json"])
            case "--clear-audit-json", "--clear-logs-json":
                args.append(contentsOf: ["--clear-audit", "--json"])
            case "--clear-incidents-json", "--clear-incidents-type-json":
                args.append(contentsOf: ["--clear-incidents", "--json"])
            case "--audit-search-json", "--search-audit-json":
                args.append(contentsOf: ["--audit-search", "--json"])
            case "--incidents-search-json", "--search-incidents-json", "--incident-search-json":
                args.append(contentsOf: ["--incidents-search", "--json"])
            case "--set-threshold-json":
                args.append(contentsOf: ["--set-threshold", "--json"])
            case "--set-timeout-json":
                args.append(contentsOf: ["--set-timeout", "--json"])
            case "--set-debounce-json":
                args.append(contentsOf: ["--set-debounce", "--json"])
            case "--set-mode-json":
                args.append(contentsOf: ["--set-mode", "--json"])
            case "--set-walkaway-json":
                args.append(contentsOf: ["--set-walkaway", "--json"])
            case "--test-telegram-json":
                args.append(contentsOf: ["--test-telegram", "--json"])
            case "--settings-json":
                args.append(contentsOf: ["--settings", "--json"])
            case "--gallery-json":
                args.append(contentsOf: ["--gallery", "--json"])
            case "--enroll-json":
                args.append(contentsOf: ["--enroll", "--json"])
            case "--backup-config-json", "--export-config-json":
                args.append(contentsOf: ["--backup-config", "--json"])
            case "--restore-config-json", "--import-config-json":
                args.append(contentsOf: ["--restore-config", "--json"])
            case "--backup-vectors-json", "--export-vectors-json":
                args.append(contentsOf: ["--export-vectors", "--json"])
            case "--restore-vectors-json", "--import-vectors-json":
                args.append(contentsOf: ["--import-vectors", "--json"])
            case "--export-incidents-json":
                args.append(contentsOf: ["--export-incidents", "--json"])
            case "--export-audit-json", "--export-logs-json":
                args.append(contentsOf: ["--export-audit", "--json"])
            case "--export-audit-csv", "--export-logs-csv":
                args.append(contentsOf: ["--export-audit", "--format", "csv"])
            case "--export-audit-array", "--export-logs-array":
                args.append(contentsOf: ["--export-audit", "--format", "json"])
            case "--prune-incidents-json":
                args.append(contentsOf: ["--prune-incidents", "--json"])
            case "--prune-incidents-days-json":
                args.append(contentsOf: ["--prune-incidents-days", "--json"])
            case "--prune-audit-json", "--prune-logs-json":
                args.append(contentsOf: ["--prune-audit", "--json"])
            case "--prune-audit-days-json", "--prune-logs-days-json":
                args.append(contentsOf: ["--prune-audit-days", "--json"])
            case "--vector-consistency-json", "--analyze-vectors-json":
                args.append(contentsOf: ["--vector-consistency", "--json"])
            case "--incidents-integrity-json", "--check-incidents-json":
                args.append(contentsOf: ["--incidents-integrity", "--json"])
            case "--repair-incidents-json", "--clean-corrupted-incidents-json":
                args.append(contentsOf: ["--repair-incidents", "--json"])
            case "--audit-summary-json":
                args.append(contentsOf: ["--audit-summary", "--json"])
            case "--prune-logs-days":
                args.append("--prune-audit-days")
            case "--verify-pin-json":
                args.append(contentsOf: ["--verify-pin", "--json"])
            case "--set-pin-attempts-json", "--pin-attempts-json":
                args.append(contentsOf: ["--set-pin-attempts", "--json"])
            case "--set-pin-lockout-json", "--pin-lockout-json":
                args.append(contentsOf: ["--set-pin-lockout", "--json"])
            case "--set-pin-json":
                args.append(contentsOf: ["--set-pin", "--json"])
            case "--pin-attempts":
                args.append("--set-pin-attempts")
            case "--pin-lockout":
                args.append("--set-pin-lockout")
            case "--export-latest-incident-json":
                args.append(contentsOf: ["--export-latest-incident", "--json"])
            case "--export-incident-json":
                args.append(contentsOf: ["--export-incident", "--json"])
            case "--incident-json":
                args.append(contentsOf: ["--incident", "--json"])
            case "--delete-incident-json":
                args.append(contentsOf: ["--delete-incident", "--json"])
            case "--clear-vectors-json", "--reset-vectors-json", "--reset-json":
                args.append(contentsOf: ["--clear-vectors", "--json"])
            case "--export-config":
                args.append("--backup-config")
            case "--import-config":
                args.append("--restore-config")
            case "--backup-vectors":
                args.append("--export-vectors")
            case "--restore-vectors":
                args.append("--import-vectors")
            case "--reset-vectors", "--reset":
                args.append("--clear-vectors")
            case "--export-logs":
                args.append("--export-audit")
            case "--search-audit":
                args.append("--audit-search")
            case "--search-incidents", "--incident-search":
                args.append("--incidents-search")
            case "--analyze-vectors":
                args.append("--vector-consistency")
            case "--check-incidents":
                args.append("--incidents-integrity")
            case "--clean-corrupted-incidents":
                args.append("--repair-incidents")
            case "--prune-logs":
                args.append("--prune-audit")
            case "--log-stats":
                args.append("--audit-stats")
            case "--toggle-battery":
                args.append("--toggle-battery-aware")
            case "--toggle-shoulder":
                args.append("--toggle-shoulder-defense")
            case "--toggle-presentation-mode":
                args.append("--toggle-presentation")
            case "--security-score-json", "--posture-score-json", "--posture-json", "--security-posture-json":
                args.append(contentsOf: ["--security-score", "--json"])
            case "--posture", "--posture-score", "--security-posture":
                args.append("--security-score")
            case "--presentation-apps-json", "--meeting-apps-json", "--meetings-apps-json":
                args.append(contentsOf: ["--presentation-apps", "--json"])
            case "--meeting-apps", "--meetings-apps":
                args.append("--presentation-apps")
            case "--check-presentation-json":
                args.append(contentsOf: ["--check-presentation", "--json"])
            case "--prune-incidents-quota-json", "--prune-incidents-size-json", "--prune-incidents-mb-json":
                args.append(contentsOf: ["--prune-incidents-size", "--json"])
            case "--prune-incidents-quota", "--prune-incidents-mb", "--trim-incidents-size":
                args.append("--prune-incidents-size")
            case "--set-duress-pin-json":
                args.append(contentsOf: ["--set-duress-pin", "--json"])
            case "--clear-duress-pin-json":
                args.append(contentsOf: ["--clear-duress-pin", "--json"])
            case "--duress-status-json":
                args.append(contentsOf: ["--duress-status", "--json"])
            case "--add-meeting-app-json", "--add-presentation-app-json":
                args.append(contentsOf: ["--add-meeting-app", "--json"])
            case "--add-presentation-app":
                args.append("--add-meeting-app")
            case "--remove-meeting-app-json", "--remove-presentation-app-json":
                args.append(contentsOf: ["--remove-meeting-app", "--json"])
            case "--remove-presentation-app":
                args.append("--remove-meeting-app")
            case "--reset-meeting-apps-json", "--reset-presentation-apps-json":
                args.append(contentsOf: ["--reset-meeting-apps", "--json"])
            case "--reset-presentation-apps":
                args.append("--reset-meeting-apps")
            case "--custom-meeting-apps-json", "--custom-presentation-apps-json":
                args.append(contentsOf: ["--custom-meeting-apps", "--json"])
            case "--custom-presentation-apps":
                args.append("--custom-meeting-apps")
            case "--archive-incidents-json":
                args.append(contentsOf: ["--archive-incidents", "--json"])
            case "--threat-intel-json", "--threat-intelligence-json", "--risk-level-json", "--threat-level-json", "--threat-summary-json", "--threat-assessment-json", "--threat-json":
                args.append(contentsOf: ["--threat-intel", "--json"])
            case "--threat-intelligence", "--risk-level", "--threat-level", "--threat-summary", "--threat-assessment", "--threat":
                args.append("--threat-intel")
            case "--validate-config-json", "--check-config-json":
                args.append(contentsOf: ["--validate-config", "--json"])
            case "--check-config":
                args.append("--validate-config")
            case "--harden-json", "--auto-harden-json", "--harden-security-json":
                args.append(contentsOf: ["--harden", "--json"])
            case "--auto-harden", "--harden-security":
                args.append("--harden")
            case "--storage-summary-json", "--storage-stats-json":
                args.append(contentsOf: ["--storage-summary", "--json"])
            case "--storage-stats":
                args.append("--storage-summary")
            case "--audit-integrity-json", "--check-audit-json":
                args.append(contentsOf: ["--audit-integrity", "--json"])
            case "--check-audit":
                args.append("--audit-integrity")
            case "--repair-audit-json", "--clean-corrupted-audit-json":
                args.append(contentsOf: ["--repair-audit", "--json"])
            case "--clean-corrupted-audit":
                args.append("--repair-audit")
            case "--audit-digest-json", "--audit-checksum-json":
                args.append(contentsOf: ["--audit-digest", "--json"])
            case "--audit-checksum":
                args.append("--audit-digest")
            case "--doctor-json", "--diag-doctor-json", "--check-doctor-json", "--doctor-check-json":
                args.append(contentsOf: ["--doctor", "--json"])
            case "--diag-doctor", "--check-doctor", "--doctor-check":
                args.append("--doctor")
            case "--doctor-repair-json", "--doctor-fix-json", "--repair-doctor-json", "--fix-doctor-json":
                args.append(contentsOf: ["--doctor-repair", "--json"])
            case "--doctor-fix", "--repair-doctor", "--fix-doctor":
                args.append("--doctor-repair")
            case "--doctor-strict-json", "--diag-doctor-strict-json", "--check-doctor-strict-json", "--strict-doctor-json":
                args.append(contentsOf: ["--doctor-strict", "--json"])
            case "--doctor-strict", "--diag-doctor-strict", "--check-doctor-strict", "--strict-doctor":
                args.append("--doctor-strict")
            case "--doctor-export-json", "--export-doctor-json":
                args.append(contentsOf: ["--doctor-export", "--json"])
            case "--export-doctor":
                args.append("--doctor-export")
            case "--doctor-md-json", "--doctor-markdown-json":
                args.append(contentsOf: ["--doctor-markdown", "--json"])
            case "--doctor-md", "--markdown-doctor", "--doctor-markdown":
                args.append("--doctor-markdown")
            case "--doctor-export-md-json", "--export-doctor-md-json":
                args.append(contentsOf: ["--doctor-export-md", "--json"])
            case "--export-doctor-md":
                args.append("--doctor-export-md")
            case "--doctor-html-json", "--html-doctor-json":
                args.append(contentsOf: ["--doctor-html", "--json"])
            case "--doctor-html", "--html-doctor":
                args.append("--doctor-html")
            case "--doctor-export-html-json", "--export-doctor-html-json", "--export-html-doctor-json":
                args.append(contentsOf: ["--doctor-export-html", "--json"])
            case "--doctor-export-html", "--export-doctor-html", "--export-html-doctor":
                args.append("--doctor-export-html")
            case "--doctor-sarif-json", "--sarif-doctor-json":
                args.append(contentsOf: ["--doctor-sarif", "--json"])
            case "--doctor-sarif", "--sarif-doctor":
                args.append("--doctor-sarif")
            case "--doctor-export-sarif-json", "--export-doctor-sarif-json", "--export-sarif-doctor-json":
                args.append(contentsOf: ["--doctor-export-sarif", "--json"])
            case "--doctor-export-sarif", "--export-doctor-sarif", "--export-sarif-doctor":
                args.append("--doctor-export-sarif")
            case "--doctor-csv-json", "--csv-doctor-json":
                args.append(contentsOf: ["--doctor-csv", "--json"])
            case "--doctor-csv", "--csv-doctor":
                args.append("--doctor-csv")
            case "--doctor-export-csv-json", "--export-doctor-csv-json", "--export-csv-doctor-json":
                args.append(contentsOf: ["--doctor-export-csv", "--json"])
            case "--doctor-export-csv", "--export-doctor-csv", "--export-csv-doctor":
                args.append("--doctor-export-csv")
            case "--doctor-junit-json", "--junit-doctor-json":
                args.append(contentsOf: ["--doctor-junit", "--json"])
            case "--doctor-junit", "--junit-doctor":
                args.append("--doctor-junit")
            case "--doctor-export-junit-json", "--export-doctor-junit-json", "--export-junit-doctor-json":
                args.append(contentsOf: ["--doctor-export-junit", "--json"])
            case "--doctor-export-junit", "--export-doctor-junit", "--export-junit-doctor":
                args.append("--doctor-export-junit")
            case "--doctor-gha-json", "--gha-doctor-json", "--doctor-summary-json":
                args.append(contentsOf: ["--doctor-gha", "--json"])
            case "--doctor-gha", "--gha-doctor", "--doctor-summary":
                args.append("--doctor-gha")
            case "--doctor-export-gha-json", "--export-doctor-gha-json", "--export-gha-doctor-json", "--export-doctor-summary-json":
                args.append(contentsOf: ["--doctor-export-gha", "--json"])
            case "--doctor-export-gha", "--export-doctor-gha", "--export-gha-doctor", "--export-doctor-summary":
                args.append("--doctor-export-gha")
            case "--doctor-gitlab-json", "--gitlab-doctor-json", "--doctor-codeclimate-json", "--codeclimate-doctor-json":
                args.append(contentsOf: ["--doctor-gitlab", "--json"])
            case "--doctor-gitlab", "--gitlab-doctor", "--doctor-codeclimate", "--codeclimate-doctor":
                args.append("--doctor-gitlab")
            case "--doctor-export-gitlab-json", "--export-doctor-gitlab-json", "--export-gitlab-doctor-json", "--doctor-export-codeclimate-json", "--export-doctor-codeclimate-json", "--export-codeclimate-doctor-json":
                args.append(contentsOf: ["--doctor-export-gitlab", "--json"])
            case "--doctor-export-gitlab", "--export-doctor-gitlab", "--export-gitlab-doctor", "--doctor-export-codeclimate", "--export-doctor-codeclimate", "--export-codeclimate-doctor":
                args.append("--doctor-export-gitlab")
            case "--doctor-sonarqube-json", "--sonarqube-doctor-json", "--doctor-sonar-json", "--sonar-doctor-json":
                args.append(contentsOf: ["--doctor-sonarqube", "--json"])
            case "--doctor-sonarqube", "--sonarqube-doctor", "--doctor-sonar", "--sonar-doctor":
                args.append("--doctor-sonarqube")
            case "--doctor-export-sonarqube-json", "--export-doctor-sonarqube-json", "--export-sonarqube-doctor-json", "--doctor-export-sonar-json", "--export-doctor-sonar-json", "--export-sonar-doctor-json":
                args.append(contentsOf: ["--doctor-export-sonarqube", "--json"])
            case "--doctor-export-sonarqube", "--export-doctor-sonarqube", "--export-sonarqube-doctor", "--doctor-export-sonar", "--export-doctor-sonar", "--export-sonar-doctor":
                args.append("--doctor-export-sonarqube")
            case "--doctor-defectdojo-json", "--defectdojo-doctor-json", "--doctor-dojo-json", "--dojo-doctor-json":
                args.append(contentsOf: ["--doctor-defectdojo", "--json"])
            case "--doctor-defectdojo", "--defectdojo-doctor", "--doctor-dojo", "--dojo-doctor":
                args.append("--doctor-defectdojo")
            case "--doctor-export-defectdojo-json", "--export-doctor-defectdojo-json", "--export-defectdojo-doctor-json", "--doctor-export-dojo-json", "--export-doctor-dojo-json", "--export-dojo-doctor-json":
                args.append(contentsOf: ["--doctor-export-defectdojo", "--json"])
            case "--doctor-export-defectdojo", "--export-doctor-defectdojo", "--export-defectdojo-doctor", "--doctor-export-dojo", "--export-doctor-dojo", "--export-dojo-doctor":
                args.append("--doctor-export-defectdojo")
            case "--doctor-cyclonedx-json", "--cyclonedx-doctor-json", "--doctor-cdx-json", "--cdx-doctor-json":
                args.append(contentsOf: ["--doctor-cyclonedx", "--json"])
            case "--doctor-cyclonedx", "--cyclonedx-doctor", "--doctor-cdx", "--cdx-doctor":
                args.append("--doctor-cyclonedx")
            case "--doctor-export-cyclonedx-json", "--export-doctor-cyclonedx-json", "--export-cyclonedx-doctor-json", "--doctor-export-cdx-json", "--export-doctor-cdx-json", "--export-cdx-doctor-json":
                args.append(contentsOf: ["--doctor-export-cyclonedx", "--json"])
            case "--doctor-export-cyclonedx", "--export-doctor-cyclonedx", "--export-cyclonedx-doctor", "--doctor-export-cdx", "--export-doctor-cdx", "--export-cdx-doctor":
                args.append("--doctor-export-cyclonedx")
            case "--doctor-spdx-json", "--spdx-doctor-json":
                args.append(contentsOf: ["--doctor-spdx", "--json"])
            case "--doctor-spdx", "--spdx-doctor":
                args.append("--doctor-spdx")
            case "--doctor-export-spdx-json", "--export-doctor-spdx-json", "--export-spdx-doctor-json":
                args.append(contentsOf: ["--doctor-export-spdx", "--json"])
            case "--doctor-export-spdx", "--export-doctor-spdx", "--export-spdx-doctor":
                args.append("--doctor-export-spdx")
            case "--doctor-csaf-json", "--csaf-doctor-json":
                args.append(contentsOf: ["--doctor-csaf", "--json"])
            case "--doctor-csaf", "--csaf-doctor":
                args.append("--doctor-csaf")
            case "--doctor-export-csaf-json", "--export-doctor-csaf-json", "--export-csaf-doctor-json":
                args.append(contentsOf: ["--doctor-export-csaf", "--json"])
            case "--doctor-export-csaf", "--export-doctor-csaf", "--export-csaf-doctor":
                args.append("--doctor-export-csaf")
            default:
                args.append(arg)
            }
        }
        return args
    }

    public static func valueForOption(_ option: String, in args: [String]) -> String? {
        guard let idx = args.firstIndex(of: option) else { return nil }
        var targetIdx = idx + 1
        while targetIdx < args.count && args[targetIdx].hasPrefix("--") {
            targetIdx += 1
        }
        guard targetIdx < args.count else { return nil }
        let val = args[targetIdx].trimmingCharacters(in: .whitespacesAndNewlines)
        return val.isEmpty ? nil : val
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Handle command-line arguments and normalize --*-json alias flags
        let args = AppDelegate.normalizeArguments(CommandLine.arguments)

        if args.contains("--help") || args.contains("-h") {
            print("""
            FaceLock - Biometric Application Shield for macOS

            USAGE:
              facelock [options]

            OPTIONS:
              --enroll                   Launch camera face enrollment wizard
              --settings                 Open configuration and alert settings
              --gallery                  Open intruder incident log gallery
              --incidents [--json]       List logged intruder incident captures
              --incidents-search <query> Search logged intruder captures by keyword or date
              --incidents-summary [--json] Incident telemetry, classification breakdown & 24h count
              --incident <filename>      Inspect a specific logged intruder incident
              --delete-incident <file>   Delete a specific intruder incident photo from disk
              --latest-incident [--json] Inspect the most recent intruder photo capture
              --export-latest-incident <p> Copy latest intruder photo capture to destination path
              --export-incident <f> <p>  Copy specific intruder photo capture to destination path
              --clear-incidents [--type T] Purge saved intruder incident captures (optionally by type)
              --incidents-integrity, --check-incidents [--json] Verify intruder capture file headers & detect corruption
              --repair-incidents [--json] Prune corrupted or zero-byte intruder photo captures
              --prune-incidents <count>  Prune intruder captures keeping latest N photos
              --prune-incidents-days <d> Prune intruder captures older than N days
              --prune-incidents-quota <MB> Prune oldest intruder captures exceeding disk budget (in MB)
              --diagnostics [--json]     Run full biometric, hardware & storage diagnostics
              --diagnostics-gui, --diagnostics-ui Open system hardware and biometrics diagnostics window
              --logs, --audit [--tail N] [--type T] [--query Q] [--json] View security audit event log
              --audit-search <query> [--tail N] [--type T] [--json] Search audit events by keyword or bundle
              --audit-ui, --audit-window Open security audit log viewer window
              --clear-logs, --clear-audit Purge all recorded security audit log events
              --prune-logs, --prune-audit <count> Prune older audit events keeping latest N
              --prune-audit-days, --prune-logs-days <d> Prune audit log events older than N days
              --export-logs, --export-audit <path> [--type T] [--format <jsonl|json|csv>] Export security audit log
              --audit-summary [--json]   Analytical audit digest (verification rate & app challenge metrics)
              --verify-face [--timeout]  One-shot face biometric check without locking
              --verify-pin <pin>         Verify whether given PIN matches lock screen PIN
              --lock, --test-lock        Trigger immediate fullscreen lock screen
              --lockdown, --emergency-lockdown [--json] Engage emergency lockdown (lockdown profile & lock screen)
              --is-locked [--json]       Check whether lock screen is currently engaged
              --export-incidents <dir> [--type T] Export captured intruder incident photos and manifest to directory
              --toggle                   Toggle protection between ACTIVE and PAUSED
              --pause [mins]             Pause protection for N minutes (default: 15)
              --resume                   Resume protection immediately
              --reload, --reload-config  Hot-reload active configuration in running daemon
              --reset-session            Invalidate active biometric session and force re-authentication
              --check-app <bundleId>     Inspect whether bundle ID triggers biometric shield
              --config [--json]          Display active FaceLock configuration
              --backup-config, --export-config <path> Export active FaceLock configuration to JSON file
              --restore-config, --import-config <path> Import and apply FaceLock configuration from JSON file
              --apps [--json]            List protected and ignored application bundle IDs
              --apps-gui, --apps-window  Open interactive application protection policy window
              --protect-app <bundleId>   Add application bundle ID to protected list
              --unprotect-app <bundleId> Remove application bundle ID from protected list
              --ignore-app <bundleId>    Add application bundle ID to ignored list
              --unignore-app <bundleId>  Remove application bundle ID from ignored list
              --reset-apps [--json]      Reset protected and ignored application lists to defaults
              --set-liveness <on|off|toggle> Enable, disable or toggle anti-spoofing verification
              --toggle-liveness          Toggle anti-spoofing 3D liveness detection
              --set-touchid <on|off|toggle> Enable, disable or toggle Touch ID fallback
              --toggle-touchid           Toggle Touch ID fallback on lock screen
              --set-lock-on-wake <on|off|toggle> Enable, disable or toggle lock verification upon Mac screen wake
              --toggle-wake              Toggle lock verification upon Mac screen wake
              --vectors [--json]         Inspect enrolled biometric facial vectors & cluster metrics
              --optimize-vectors [--json] Prune redundant templates & outliers to optimize cluster compactness
              --vector-consistency [--json] Analyze enrolled faceprint cluster cohesion & medoid
              --export-vectors, --backup-vectors <path> Export enrolled facial biometric vectors to JSON file
              --import-vectors, --restore-vectors <path> Import facial biometric vectors from JSON file
              --clear-vectors, --reset   Purge all enrolled facial templates from disk
              --profiles [--json]        List available security profiles and current active profile
              --profile <name>           Activate security profile (normal, cafe, work, home, presentation, lockdown)
              --toggle-shoulder-defense  Toggle shoulder-surfing bystander defense
              --set-shoulder-defense <on|off> Enable or disable shoulder-surfing defense
              --toggle-audible           Toggle audible alarm & sound cues
              --set-audible <on|off>     Enable or disable audible alarm & sound cues
              --toggle-battery-aware     Toggle battery-aware adaptive idle sweep throttling
              --set-battery-aware <on|off> Enable or disable battery-aware adaptive scanning
              --battery-status [--json]  Inspect battery power source & adaptive throttling state
              --toggle-presentation, --toggle-presentation-mode Toggle meeting / presentation lock auto-suppression
              --set-presentation-mode <on|off|toggle> Enable or disable meeting lock auto-suppression
              --presentation-apps, --meeting-apps [--json] List recognized meeting & presentation apps
              --check-presentation [bundleId] [--json] Check if bundle ID or active app triggers meeting lock suppression
              --add-meeting-app <bundleId> Add custom application to meeting suppression whitelist
              --remove-meeting-app <bundleId> Remove custom application from meeting suppression whitelist
              --reset-meeting-apps       Clear all custom meeting suppression applications
              --custom-meeting-apps [--json] List user-configured custom meeting applications
              --security-score, --posture [--json] Assess comprehensive Mac security posture score & recommendations
              --test, --run-tests        Execute automated unit test suite and benchmarks
              --health [--json]          Fast operational healthcheck (exit 0 if healthy)
              --set-pin <pin>            Update lock screen unlock PIN
              --set-duress-pin <pin>     Configure silent duress distress PIN (4-8 digits)
              --clear-duress-pin         Clear duress PIN and disable coerced unlock detection
              --duress-status [--json]   Inspect duress emergency protection status
              --set-pin-attempts <count> Set allowed failed PIN attempts before lockout (1-10, default: 3)
              --set-pin-lockout <sec>    Set cooling lockout delay after failed PIN attempts (1-60s, default: 5s)
              --set-telegram <tok> <id>  Configure Telegram bot credentials and enable alerts
              --enable-telegram          Enable Telegram notifications
              --disable-telegram         Disable Telegram notifications
              --set-walkaway <sec|off|toggle> Configure walk-away timeout (10-600s), 'off', or 'toggle'
              --toggle-walkaway          Toggle walk-away auto-lock detection
              --set-threshold <val>      Set similarity threshold (0.05 - 0.60, default: 0.22)
              --set-timeout <seconds>    Set camera verification timeout (0.5 - 10.0s, default: 2.0s)
              --set-debounce <seconds>   Set app switch debounce interval (0.5 - 30.0s, default: 2.0s)
              --set-mode <mode>          Set mode: 'all' (every app) or 'selective' (secret apps)
              --cameras [--json]         List available video capture cameras and active selection
              --set-camera <id|name|default> Set preferred camera device by ID, name substring, or 'default'
              --reset-camera [--json]    Reset preferred camera selection to default front/built-in camera
              --diagnostics, -d [--json] Run complete biometric & hardware system diagnostics
              --doctor [--json]          Run comprehensive pre-flight & runtime health diagnostic doctor
              --doctor-strict [--json]   Run health doctor in strict mode (fails with exit 1 on any warning)
              --doctor-repair [--json]   Auto-remediate issues detected by diagnostic doctor (permissions, audit, posture)
              --doctor-export [path] [--json] Export doctor diagnostic report to JSON file
              --doctor-markdown [--json] Generate health doctor diagnostic report in GitHub-flavored Markdown
              --doctor-export-md [path] [--json] Export doctor diagnostic report to Markdown file
              --doctor-html [--json]     Generate health doctor diagnostic report as standalone HTML5 page
              --doctor-export-html [path] [--json] Export doctor diagnostic report to HTML5 dashboard file
              --doctor-sarif [--json]    Generate health doctor diagnostic report in OASIS SARIF v2.1.0 format
              --doctor-export-sarif [path] [--json] Export doctor diagnostic report to SARIF v2.1.0 file
              --doctor-csv [--json]      Generate health doctor diagnostic report in RFC 4180 CSV format
              --doctor-export-csv [path] [--json] Export doctor diagnostic report to CSV file
              --doctor-junit [--json]    Generate health doctor diagnostic report in JUnit XML format
              --doctor-export-junit [path] [--json] Export doctor diagnostic report to JUnit XML file
              --doctor-gha [--json]      Generate health doctor diagnostic report as GitHub Actions Step Summary
              --doctor-export-gha [path] [--json] Export doctor diagnostic report to GitHub Actions Step Summary file
              --doctor-gitlab [--json]   Generate health doctor diagnostic report in GitLab CI / Code Climate JSON format
              --doctor-export-gitlab [path] [--json] Export doctor diagnostic report to GitLab CI Code Quality file
              --doctor-sonarqube, --doctor-sonar [--json] Generate doctor report in SonarQube Generic Issue Import JSON
              --doctor-export-sonarqube, --doctor-export-sonar [path] [--json] Export doctor report to SonarQube Generic Issue Import file
              --doctor-defectdojo, --doctor-dojo [--json] Generate doctor report in DefectDojo Generic Findings JSON
              --doctor-export-defectdojo, --doctor-export-dojo [path] [--json] Export doctor report to DefectDojo Generic Findings file
              --doctor-cyclonedx, --doctor-cdx [--json] Generate doctor report in OWASP CycloneDX 1.5 JSON
              --doctor-export-cyclonedx, --doctor-export-cdx [path] [--json] Export doctor report to CycloneDX 1.5 BOM file
              --doctor-spdx [--json]     Generate doctor report in SPDX 2.3 JSON (ISO/IEC 5962:2021)
              --doctor-export-spdx [path] [--json] Export doctor report to SPDX 2.3 SBOM file
              --doctor-csaf [--json]     Generate doctor report in OASIS CSAF 2.0 JSON
              --doctor-export-csaf [path] [--json] Export doctor report to OASIS CSAF 2.0 file
              --status [--json]          Print current daemon status and vector metrics
              --security-score [--json]  Evaluate macOS security posture and hardening score
              --harden [--json]          Auto-remediate vulnerabilities & harden macOS security posture
              --test-telegram            Dispatch a verification alert to configured Telegram chat
              --reset                    Purge all enrolled facial vectors
              --update                   Check GitHub for updates, pull, recompile & reload
              --version, -v              Print version information
              --help, -h                 Show this help guide
            """)
            exit(0)
        }

        if args.contains("--version") || args.contains("-v") {
            if args.contains("--json") {
                print("{\"name\":\"FaceLock\",\"version\":\"\(Config.currentVersion)\",\"platform\":\"darwin-arm64\"}")
            } else {
                print("FaceLock v\(Config.currentVersion) (darwin-arm64)")
            }
            exit(0)
        }

        if args.contains("--test") || args.contains("--run-tests") {
            let suite = FaceLockTestSuite()
            let passed = suite.runAll()
            exit(passed ? 0 : 1)
        }

        // Inter-process command dispatching if instance is already running
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.facelock")
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        let isAlreadyRunning = !runningApps.isEmpty

        if args.contains("--diagnostics") || args.contains("-d") {
            Diagnostics.run(jsonOutput: args.contains("--json"))
            exit(0)
        }

        if args.contains("--doctor-repair") {
            let repairReport = Diagnostics.runDoctorRepair()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: repairReport.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                repairReport.printSummary()
            }
            exit(repairReport.finalReport.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor") {
            let report = Diagnostics.runDoctor()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                report.printDoctorSummary()
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-strict") {
            let report = Diagnostics.runDoctor()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                report.printDoctorSummary()
            }
            let isStrictFailing = report.failureCount > 0 || report.warningCount > 0
            exit(isStrictFailing ? 1 : 0)
        }

        if args.contains("--doctor-export") {
            let customPath = AppDelegate.valueForOption("--doctor-export", in: args)
            let result = Diagnostics.exportDoctorReport(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-markdown") {
            let report = Diagnostics.runDoctor()
            let md = report.generateMarkdown()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "markdown": md
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(md)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-md") {
            let customPath = AppDelegate.valueForOption("--doctor-export-md", in: args)
            let result = Diagnostics.exportDoctorMarkdown(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to Markdown: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to Markdown: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-html") {
            let report = Diagnostics.runDoctor()
            let html = report.generateHTML()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "html": html
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(html)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-html") {
            let customPath = AppDelegate.valueForOption("--doctor-export-html", in: args)
            let result = Diagnostics.exportDoctorHTML(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to HTML: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to HTML: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-sarif") {
            let report = Diagnostics.runDoctor()
            let sarif = report.generateSARIF()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "sarif": sarif
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(sarif)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-sarif") {
            let customPath = AppDelegate.valueForOption("--doctor-export-sarif", in: args)
            let result = Diagnostics.exportDoctorSARIF(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to SARIF: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to SARIF: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-csv") {
            let report = Diagnostics.runDoctor()
            let csv = report.generateCSV()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "csv": csv
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(csv)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-csv") {
            let customPath = AppDelegate.valueForOption("--doctor-export-csv", in: args)
            let result = Diagnostics.exportDoctorCSV(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to CSV: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to CSV: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-junit") {
            let report = Diagnostics.runDoctor()
            let junit = report.generateJUnitXML()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "junitXml": junit
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(junit)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-junit") {
            let customPath = AppDelegate.valueForOption("--doctor-export-junit", in: args)
            let result = Diagnostics.exportDoctorJUnit(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to JUnit XML: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to JUnit XML: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-gha") {
            let report = Diagnostics.runDoctor()
            let gha = report.generateGitHubActionsSummary()
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "githubActionsSummary": gha
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(gha)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-gha") {
            let customPath = AppDelegate.valueForOption("--doctor-export-gha", in: args)
            let result = Diagnostics.exportDoctorGitHubActions(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to GitHub Actions summary: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to GitHub Actions summary: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-gitlab") || args.contains("--doctor-codeclimate") {
            let report = Diagnostics.runDoctor()
            let codeclimate = report.generateCodeClimate()
            if args.contains("--json") {
                let issues = report.toCodeClimateIssues()
                let jsonDict: [String: Any] = [
                    "version": report.version,
                    "overallStatus": report.overallStatus,
                    "totalChecks": report.totalChecks,
                    "passed": report.passedCount,
                    "warnings": report.warningCount,
                    "failures": report.failureCount,
                    "issueCount": issues.count,
                    "issues": issues
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(codeclimate)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-gitlab") || args.contains("--doctor-export-codeclimate") {
            let customPath = AppDelegate.valueForOption("--doctor-export-gitlab", in: args) ?? AppDelegate.valueForOption("--doctor-export-codeclimate", in: args)
            let result = Diagnostics.exportDoctorCodeClimate(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to GitLab CI / Code Climate file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-sonarqube") || args.contains("--doctor-sonar") {
            let report = Diagnostics.runDoctor()
            let sonarqube = report.generateSonarQube()
            if args.contains("--json") {
                let dict = report.toSonarQubeDictionary()
                var jsonDict: [String: Any] = dict
                jsonDict["version"] = report.version
                jsonDict["overallStatus"] = report.overallStatus
                jsonDict["totalChecks"] = report.totalChecks
                jsonDict["passed"] = report.passedCount
                jsonDict["warnings"] = report.warningCount
                jsonDict["failures"] = report.failureCount
                if let issues = dict["issues"] as? [[String: Any]] {
                    jsonDict["issueCount"] = issues.count
                }
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(sonarqube)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-sonarqube") || args.contains("--doctor-export-sonar") {
            let customPath = AppDelegate.valueForOption("--doctor-export-sonarqube", in: args) ?? AppDelegate.valueForOption("--doctor-export-sonar", in: args)
            let result = Diagnostics.exportDoctorSonarQube(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to SonarQube file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-defectdojo") || args.contains("--doctor-dojo") {
            let report = Diagnostics.runDoctor()
            let defectdojo = report.generateDefectDojo()
            if args.contains("--json") {
                let dict = report.toDefectDojoDictionary()
                var jsonDict: [String: Any] = dict
                jsonDict["version"] = report.version
                jsonDict["overallStatus"] = report.overallStatus
                jsonDict["totalChecks"] = report.totalChecks
                jsonDict["passed"] = report.passedCount
                jsonDict["warnings"] = report.warningCount
                jsonDict["failures"] = report.failureCount
                if let findings = dict["findings"] as? [[String: Any]] {
                    jsonDict["findingsCount"] = findings.count
                }
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(defectdojo)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-defectdojo") || args.contains("--doctor-export-dojo") {
            let customPath = AppDelegate.valueForOption("--doctor-export-defectdojo", in: args) ?? AppDelegate.valueForOption("--doctor-export-dojo", in: args)
            let result = Diagnostics.exportDoctorDefectDojo(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to DefectDojo file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-cyclonedx") || args.contains("--doctor-cdx") {
            let report = Diagnostics.runDoctor()
            let cdx = report.generateCycloneDX()
            if args.contains("--json") {
                let dict = report.toCycloneDXDictionary()
                var jsonDict: [String: Any] = dict
                jsonDict["version"] = report.version
                jsonDict["overallStatus"] = report.overallStatus
                jsonDict["totalChecks"] = report.totalChecks
                jsonDict["passed"] = report.passedCount
                jsonDict["warnings"] = report.warningCount
                jsonDict["failures"] = report.failureCount
                if let vulns = dict["vulnerabilities"] as? [[String: Any]] {
                    jsonDict["vulnerabilitiesCount"] = vulns.count
                }
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(cdx)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-cyclonedx") || args.contains("--doctor-export-cdx") {
            let customPath = AppDelegate.valueForOption("--doctor-export-cyclonedx", in: args) ?? AppDelegate.valueForOption("--doctor-export-cdx", in: args)
            let result = Diagnostics.exportDoctorCycloneDX(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to CycloneDX BOM file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-spdx") {
            let report = Diagnostics.runDoctor()
            let spdx = report.generateSPDX()
            if args.contains("--json") {
                let dict = report.toSPDXDictionary()
                var jsonDict: [String: Any] = dict
                jsonDict["version"] = report.version
                jsonDict["overallStatus"] = report.overallStatus
                jsonDict["totalChecks"] = report.totalChecks
                jsonDict["passed"] = report.passedCount
                jsonDict["warnings"] = report.warningCount
                jsonDict["failures"] = report.failureCount
                if let vulns = dict["vulnerabilities"] as? [[String: Any]] {
                    jsonDict["vulnerabilitiesCount"] = vulns.count
                }
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(spdx)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-spdx") {
            let customPath = AppDelegate.valueForOption("--doctor-export-spdx", in: args)
            let result = Diagnostics.exportDoctorSPDX(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to SPDX 2.3 file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--doctor-csaf") {
            let report = Diagnostics.runDoctor()
            let csaf = report.generateCSAF()
            if args.contains("--json") {
                let dict = report.toCSAFDictionary()
                var jsonDict: [String: Any] = dict
                jsonDict["version"] = report.version
                jsonDict["overallStatus"] = report.overallStatus
                jsonDict["totalChecks"] = report.totalChecks
                jsonDict["passed"] = report.passedCount
                jsonDict["warnings"] = report.warningCount
                jsonDict["failures"] = report.failureCount
                if let vulns = dict["vulnerabilities"] as? [[String: Any]] {
                    jsonDict["vulnerabilitiesCount"] = vulns.count
                }
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print(csaf)
            }
            exit(report.failureCount > 0 ? 1 : 0)
        }

        if args.contains("--doctor-export-csaf") {
            let customPath = AppDelegate.valueForOption("--doctor-export-csaf", in: args)
            let result = Diagnostics.exportDoctorCSAF(toPath: customPath)
            if args.contains("--json") {
                let jsonDict: [String: Any] = [
                    "success": result.success,
                    "path": result.path,
                    "overallStatus": result.report.overallStatus,
                    "totalChecks": result.report.totalChecks,
                    "passed": result.report.passedCount,
                    "warnings": result.report.warningCount,
                    "failures": result.report.failureCount,
                    "version": result.report.version,
                    "bytesWritten": result.content.utf8.count
                ]
                if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if result.success {
                    print("✓ Doctor diagnostic health report exported to OASIS CSAF 2.0 file: \(result.path)")
                    print("  Status: \(result.report.overallStatus) (\(result.report.passedCount)/\(result.report.totalChecks) passed)")
                } else {
                    print("✗ Failed to export doctor diagnostic report to: \(result.path)")
                }
            }
            exit(result.success ? 0 : 1)
        }

        if args.contains("--security-score") || args.contains("--posture") {
            let report = Diagnostics.assessSecurityPosture()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let badge: String
                switch report.score {
                case 90...100: badge = "EXCELLENT 🛡️"
                case 80...89:  badge = "HARDENED 🛡️"
                case 70...79:  badge = "STANDARD ⚖️"
                case 55...69:  badge = "MODERATE ⚠️"
                default:       badge = "VULNERABLE ❌"
                }
                print("=======================================================")
                print("       🛡️  FaceLock Security Posture Assessment       ")
                print("=======================================================")
                print("  • Score: \(report.score)/\(report.maxScore) (Grade: \(report.grade) - \(badge))")
                let shieldDict = report.breakdown["shieldState"] as? [String: Any]
                let isShieldActive = (shieldDict?["isActive"] as? Bool) == true
                print("  • Shield: \(isShieldActive ? "ACTIVE (15/15 pts) ✅" : "PAUSED (0/15 pts) ⏸️")")
                let pinPts = (report.breakdown["pinSecurity"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Master PIN: \(pinPts)/15 pts")
                let bioPts = (report.breakdown["biometrics"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Biometric Templates: \(bioPts)/20 pts")
                let walkPts = (report.breakdown["walkAwayLock"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Walk-Away Lock: \(walkPts)/10 pts")
                let shoulderPts = (report.breakdown["shoulderSurfingDefense"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Shoulder-Surfing: \(shoulderPts)/10 pts")
                let livenessPts = (report.breakdown["livenessDetection"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Liveness Detection: \(livenessPts)/10 pts")
                let wakePts = (report.breakdown["lockOnWake"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Lock-on-Wake: \(wakePts)/5 pts")
                let batteryPts = (report.breakdown["batteryAwareScanning"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Battery-Aware: \(batteryPts)/5 pts")
                let tgPts = (report.breakdown["telegramAlerts"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Telegram Alerts: \(tgPts)/5 pts")
                let presPts = (report.breakdown["presentationSuppression"] as? [String: Any])?["points"] as? Int ?? 0
                print("  • Meeting Auto-Suppression: \(presPts)/5 pts")
                if let penalty = (report.breakdown["incidentIntegrity"] as? [String: Any])?["penalty"] as? Int, penalty > 0 {
                    print("  • Integrity Penalty: -\(penalty) pts (Corrupted captures detected ⚠️)")
                }
                if let auditPen = (report.breakdown["auditIntegrity"] as? [String: Any])?["penalty"] as? Int, auditPen > 0 {
                    print("  • Audit Integrity Penalty: -\(auditPen) pts (Corrupted audit records detected ⚠️)")
                }
                if report.recommendations.isEmpty {
                    print("\n  🎉 Optimal security posture: Mac is fully hardened.")
                } else {
                    print("\n  📋 Actionable Recommendations (\(report.recommendations.count)):")
                    for (idx, rec) in report.recommendations.enumerated() {
                        print("    \(idx + 1). \(rec)")
                    }
                }
                print("=======================================================\n")
            }
            exit(0)
        }

        if args.contains("--harden") {
            let result = Diagnostics.autoHardenSecurity()
            if isAlreadyRunning {
                AppDelegate.notifyDaemonReload()
            }
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: result.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("=======================================================")
                print("       🛡️  FaceLock Autonomous Security Hardening      ")
                print("=======================================================")
                print("  • Previous Score: \(result.previousScore)/100 (Grade: \(result.previousGrade) - \(result.previousStatus))")
                let deltaStr = result.scoreDelta >= 0 ? "+\(result.scoreDelta)" : "\(result.scoreDelta)"
                print("  • Hardened Score: \(result.newScore)/100 (Grade: \(result.newGrade) - \(result.newStatus)) (\(deltaStr) pts)")
                if result.appliedFixes.isEmpty {
                    print("  • Status: All automated hardening policies are already fully applied! ✅")
                } else {
                    print("  • Applied Hardening Fixes (\(result.appliedFixes.count)):")
                    for fix in result.appliedFixes {
                        print("    ✓ \(fix)")
                    }
                }
                if !result.remainingRecommendations.isEmpty {
                    print("\n  • Remaining User Actions (\(result.remainingRecommendations.count)):")
                    for (idx, rec) in result.remainingRecommendations.enumerated() {
                        print("    \(idx + 1). \(rec)")
                    }
                }
                print("=======================================================\n")
            }
            exit(0)
        }

        if args.contains("--presentation-apps") {
            let catalog = WalkAwayMonitor.presentationCatalog
            let customApps = Config.shared.customPresentationBundleIdentifiers
            if args.contains("--json") {
                let dicts = catalog.map { $0.toDictionary() }
                let payload: [String: Any] = [
                    "count": dicts.count,
                    "apps": dicts,
                    "customApps": customApps,
                    "customAppsCount": customApps.count,
                    "totalAppsCount": dicts.count + customApps.count,
                    "suppressionEnabled": Config.shared.presentationModeSuppression
                ]
                if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("   🎯  FaceLock Presentation & Meeting Suppression Catalog   ")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("Suppression Active: \(Config.shared.presentationModeSuppression ? "YES ✅" : "NO ⏸️")")
                print("Recognized Catalog Applications (\(catalog.count)):")
                for app in catalog {
                    print("  • [\(app.category)] \(app.name) — \(app.bundleId)")
                }
                if !customApps.isEmpty {
                    print("\nCustom Registered Meeting Applications (\(customApps.count)):")
                    for app in customApps {
                        print("  ★ [Custom] \(app)")
                    }
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
            exit(0)
        }

        if args.contains("--check-presentation") {
            let bundle = AppDelegate.valueForOption("--check-presentation", in: args)
            let status = WalkAwayMonitor.checkPresentationStatus(bundleId: bundle)
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: status, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let isPres = status["isPresentationApp"] as? Bool ?? false
                let name = status["matchedName"] as? String ?? "N/A"
                let cat = status["matchedCategory"] as? String ?? "N/A"
                let isSupp = status["isLockSuppressed"] as? Bool ?? false
                let target = bundle ?? (status["frontmostBundleId"] as? String ?? "Frontmost Application")

                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("        🎯  FaceLock Presentation Mode Inspection           ")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("  • Target App: \(target)")
                print("  • Presentation/Meeting App: \(isPres ? "YES (\(name) - \(cat)) ✅" : "NO ❌")")
                print("  • Frontmost Application: \(status["frontmostName"] as? String ?? "") [\(status["frontmostBundleId"] as? String ?? "")]")
                print("  • Display Sleep Assertion: \((status["hasDisplaySleepAssertion"] as? Bool == true) ? "ACTIVE (Presentation in progress) ⚡️" : "None")")
                print("  • Suppression Configured: \((status["presentationModeSuppressionConfigured"] as? Bool == true) ? "Enabled" : "Disabled")")
                print("  • Walk-Away Auto-Lock Suppressed: \(isSupp ? "YES (Will not lock screen) 🛡️" : "NO (Normal lock active) 🔒")")
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
            exit(0)
        }

        if args.contains("--threat-intel") {
            let report = SecurityAuditLogger.shared.analyzeThreatIntelligence()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("=======================================================")
                print("    🛡️  FaceLock Physical Threat Intelligence & Risk   ")
                print("=======================================================")
                print("  • Risk Level:        \(report.riskLevel) \(report.statusBadge) (Score: \(report.riskScore)/100)")
                print("  • 24h Threat Events: \(report.past24HoursCount)")
                print("  • 7d Threat Events:  \(report.past7DaysCount)")
                print("  • Total Incidents:   \(report.totalThreatEvents)")
                print("  • Intruder Captures: \(report.intruderCaptureCount)")
                print("  • Shoulder Snooping: \(report.shoulderSurfingCount)")
                print("  • PIN Bruteforce:    \(report.pinBruteforceCount)")
                print("  • Emergency Locks:   \(report.emergencyLockdownCount)")
                if let peak = report.peakThreatHour {
                    print("  • Peak Threat Hour:  \(peak):00 - \(peak + 1):00")
                }
                if !report.anomalies.isEmpty {
                    print("\n  ⚠️ Detected Anomalies (\(report.anomalies.count)):")
                    for a in report.anomalies {
                        print("    - [\(a.severity)] \(a.code): \(a.description)")
                    }
                }
                if report.mitigations.isEmpty {
                    print("\n  🎉 Threat posture optimal: No anomalies or active attack patterns detected.")
                } else {
                    print("\n  📋 Recommended Mitigations (\(report.mitigations.count)):")
                    for (idx, m) in report.mitigations.enumerated() {
                        print("    \(idx + 1). \(m)")
                    }
                }
                print("=======================================================\n")
            }
            exit(0)
        }

        if args.contains("--validate-config") {
            let report = Config.validateConfig()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("=======================================================")
                print("       🛡️  FaceLock Configuration Validation           ")
                print("=======================================================")
                print("  • Status:      \(report.isValid ? "VALID ✅" : "ISSUES DETECTED ⚠️")")
                print("  • Errors:      \(report.errorCount)")
                print("  • Warnings:    \(report.warningCount)")
                print("  • Info Items:  \(report.infoCount)")
                if !report.issues.isEmpty {
                    print("\n  📋 Detected Issues (\(report.issues.count)):")
                    for issue in report.issues {
                        let badge = issue.severity == "ERROR" ? "❌" : (issue.severity == "WARNING" ? "⚠️" : "ℹ️")
                        print("    [\(issue.severity)] \(badge) [\(issue.key)]: \(issue.message)")
                    }
                }
                if !report.suggestions.isEmpty {
                    print("\n  💡 Optimization Suggestions (\(report.suggestions.count)):")
                    for s in report.suggestions {
                        print("    - \(s)")
                    }
                }
                if report.issues.isEmpty && report.suggestions.isEmpty {
                    print("\n  🎉 Configuration is clean and fully optimized.")
                }
                print("=======================================================\n")
            }
            exit(report.errorCount == 0 ? 0 : 1)
        }

        if args.contains("--storage-summary") {
            let summary = CameraScanner.shared.getStorageSummary()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: summary, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("=======================================================")
                print("          🛡️  FaceLock Local Storage Summary          ")
                print("=======================================================")
                let totalMB = Double(summary["totalStorageBytes"] as? UInt64 ?? 0) / (1024.0 * 1024.0)
                let incMB = Double(summary["intrudersSizeBytes"] as? UInt64 ?? 0) / (1024.0 * 1024.0)
                let auditMB = Double(summary["auditSizeBytes"] as? UInt64 ?? 0) / (1024.0 * 1024.0)
                print("  • Total Footprint:   \(String(format: "%.2f", totalMB)) MB")
                print("  • Intruder Captures: \(summary["intrudersCount"] ?? 0) captures (\(String(format: "%.2f", incMB)) MB)")
                print("  • Security Audit:    \(summary["auditEventsCount"] ?? 0) events (\(String(format: "%.2f", auditMB)) MB)")
                print("  • Enrolled Templates:\(summary["vectorsCount"] ?? 0) vectors")
                print("=======================================================\n")
            }
            exit(0)
        }

        if args.contains("--audit-integrity") {
            let report = SecurityAuditLogger.shared.verifyAuditIntegrity()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: report.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("=======================================================")
                print("       🛡️  FaceLock Security Audit Log Integrity       ")
                print("=======================================================")
                print("  • Status:           \(report.status)")
                print("  • Scanned Lines:    \(report.totalLinesScanned)")
                print("  • Valid Events:     \(report.validEventsCount)")
                print("  • Corrupted Lines:  \(report.corruptedLinesCount)")
                print("  • Empty Lines:      \(report.emptyLinesCount)")
                print("  • Chronology Gaps:  \(report.chronologyErrorsCount)")
                print("  • SHA-256 Digest:   \(report.sha256Digest)")
                print("=======================================================\n")
            }
            exit(report.corruptedLinesCount == 0 ? 0 : 1)
        }

        if args.contains("--repair-audit") {
            do {
                let res = try SecurityAuditLogger.shared.repairAuditLog()
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "repairedCount": res.repairedCount,
                        "purgedCorruptedCount": res.purgedCorruptedCount,
                        "remainingCount": res.remainingCount,
                        "backupPath": res.backupPath
                    ]
                    if let data = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let str = String(data: data, encoding: .utf8) {
                        print(str)
                    }
                } else {
                    print("✓ Audit log repair complete:")
                    print("  • Preserved valid events: \(res.remainingCount)")
                    print("  • Purged corrupted lines: \(res.purgedCorruptedCount)")
                    print("  • Backup saved to:        \(res.backupPath)")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error repairing audit log: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--audit-digest") {
            let report = SecurityAuditLogger.shared.verifyAuditIntegrity()
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "sha256Digest": report.sha256Digest,
                    "validEvents": report.validEventsCount,
                    "fileSizeBytes": report.fileSizeBytes,
                    "status": report.status,
                    "firstEvent": report.firstEventTimestamp ?? "",
                    "lastEvent": report.lastEventTimestamp ?? ""
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("Audit Log SHA-256: \(report.sha256Digest)")
                print("Events: \(report.validEventsCount), Size: \(report.fileSizeBytes) bytes, Status: \(report.status)")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--prune-incidents-size"), idx + 1 < args.count {
            let mbStr = args[idx + 1]
            let maxMB = Double(mbStr) ?? 500.0
            let res = CameraScanner.shared.pruneIncidentsExceedingSize(maxMegabytes: maxMB)
            if args.contains("--json") {
                let out: [String: Any] = [
                    "success": true,
                    "targetMaxMB": maxMB,
                    "removedCount": res.removedCount,
                    "remainingCount": res.remainingCount,
                    "freedBytes": res.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedMB = Double(res.freedBytes) / (1024.0 * 1024.0)
                print("✓ Pruned \(res.removedCount) incident photos to stay within \(Int(maxMB)) MB quota (freed \(String(format: "%.2f", freedMB)) MB, \(res.remainingCount) remaining).")
            }
            exit(0)
        } else if args.contains("--prune-incidents-size") {
            let res = CameraScanner.shared.pruneIncidentsExceedingSize(maxMegabytes: 500.0)
            if args.contains("--json") {
                let out: [String: Any] = [
                    "success": true,
                    "targetMaxMB": 500.0,
                    "removedCount": res.removedCount,
                    "remainingCount": res.remainingCount,
                    "freedBytes": res.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedMB = Double(res.freedBytes) / (1024.0 * 1024.0)
                print("✓ Pruned \(res.removedCount) incident photos to stay within 500 MB quota (freed \(String(format: "%.2f", freedMB)) MB, \(res.remainingCount) remaining).")
            }
            exit(0)
        }

        if args.contains("--add-meeting-app") {
            guard let bundleId = AppDelegate.valueForOption("--add-meeting-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --add-meeting-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --add-meeting-app <bundleId>")
                }
                exit(1)
            }
            let added = Config.shared.addMeetingApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added custom meeting application", bundleId: bundleId)
                if isAlreadyRunning { AppDelegate.notifyDaemonReload() }
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to meeting suppression list.")
                } else {
                    print("ℹ️ '\(bundleId)' is already in meeting suppression list.")
                }
            }
            exit(0)
        }

        if args.contains("--remove-meeting-app") {
            guard let bundleId = AppDelegate.valueForOption("--remove-meeting-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --remove-meeting-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --remove-meeting-app <bundleId>")
                }
                exit(1)
            }
            let removed = Config.shared.removeMeetingApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed custom meeting application", bundleId: bundleId)
                if isAlreadyRunning { AppDelegate.notifyDaemonReload() }
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from custom meeting suppression list.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in custom meeting suppression list.")
                }
            }
            exit(0)
        }

        if args.contains("--reset-meeting-apps") {
            Config.shared.resetMeetingApps()
            SecurityAuditLogger.shared.logPolicyChanged(action: "Reset custom meeting applications to defaults", bundleId: "all")
            if isAlreadyRunning { AppDelegate.notifyDaemonReload() }
            if args.contains("--json") {
                print("{\"success\":true,\"message\":\"Custom meeting applications reset to defaults\"}")
            } else {
                print("✓ Custom meeting applications reset to defaults.")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--archive-incidents"), idx + 1 < args.count {
            let dest = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !dest.isEmpty else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Usage: facelock --archive-incidents <destinationDirectory> [--type <type>]\"}")
                } else {
                    print("Error: Usage: facelock --archive-incidents <destinationDirectory> [--type <type>]")
                }
                exit(1)
            }
            var filterType: String? = nil
            if let fIdx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), fIdx + 1 < args.count {
                filterType = args[fIdx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            do {
                let res = try CameraScanner.shared.archiveIncidents(to: dest, filterType: filterType)
                if args.contains("--json") {
                    if let d = try? JSONSerialization.data(withJSONObject: res, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let count = res["count"] as? Int ?? 0
                    let totalBytes = res["totalBytes"] as? UInt64 ?? 0
                    let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
                    let appliedFilter = res["filter"] as? String ?? "all"
                    let filterMsg = appliedFilter != "all" ? " [Type: \(appliedFilter)]" : ""
                    let checksum = res["forensicChecksum"] as? String ?? "N/A"
                    print("✓ Archived \(count) intruder captures (\(String(format: "%.2f", sizeMB)) MB)\(filterMsg) to: \(dest)")
                    print("  Forensic SHA-256 Root Checksum: \(checksum)")
                    print("  Forensic manifest generated at: \(res["manifestPath"] ?? "")")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error archiving incidents: \(error.localizedDescription)")
                }
                exit(1)
            }
        } else if args.contains("--archive-incidents") {
            if args.contains("--json") {
                print("{\"success\":false,\"error\":\"Usage: facelock --archive-incidents <destinationDirectory> [--type <type>]\"}")
            } else {
                print("Error: Usage: facelock --archive-incidents <destinationDirectory> [--type <type>]")
            }
            exit(1)
        }

        // Inter-process command dispatching if instance is already running
        if args.contains("--diagnostics-gui") || args.contains("--diagnostics-ui") || args.contains("--diagnostics-window") {
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "diagnostics-gui"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Diagnostics window via running FaceLock daemon\"}")
                } else {
                    print("✓ Opened Diagnostics window via running FaceLock daemon.")
                }
                exit(0)
            }
        }

        if args.contains("--reload") || args.contains("--reload-config") {
            if isAlreadyRunning {
                AppDelegate.notifyDaemonReload()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Dispatched reload signal to daemon\"}")
                } else {
                    print("✓ Dispatched configuration reload signal to running FaceLock daemon.")
                }
            } else {
                Config.shared.reload()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":false,\"message\":\"Config on disk reloaded\"}")
                } else {
                    print("✓ FaceLock daemon is not running; configuration reloaded from disk.")
                }
            }
            exit(0)
        }

        if args.contains("--is-locked") || args.contains("--locked") {
            let state = Config.getLockState()
            let isLocked = (state["isLocked"] as? Bool) ?? false
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: state, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if isLocked {
                    print("🔒 FaceLock screen is currently LOCKED.")
                } else {
                    print("🔓 FaceLock screen is UNLOCKED.")
                }
            }
            exit(isLocked ? 0 : 1)
        }

        if args.contains("--reset-session") {
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "reset-session"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Dispatched reset-session signal to daemon\"}")
                } else {
                    print("✓ Dispatched verification session reset signal to running FaceLock daemon.")
                }
            } else {
                AppMonitor.shared.resetVerificationSession()
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":false,\"message\":\"Verification session cache cleared\"}")
                } else {
                    print("✓ Verification session cache cleared offline.")
                }
            }
            exit(0)
        }

        if args.contains("--check-app") {
            guard let bundleId = AppDelegate.valueForOption("--check-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --check-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --check-app <bundleId>")
                }
                exit(1)
            }
            let config = Config.shared
            let isIgnored = config.isIgnored(bundleId: bundleId)
            let isSelf = (bundleId.caseInsensitiveCompare("io.github.facelock") == .orderedSame || bundleId == Bundle.main.bundleIdentifier)
            let isProtected: Bool
            let willTrigger: Bool

            if isSelf || isIgnored {
                isProtected = false
                willTrigger = false
            } else if config.protectionMode == "selective" {
                isProtected = config.isProtected(bundleId: bundleId)
                willTrigger = isProtected && config.isEnabled
            } else {
                isProtected = true
                willTrigger = config.isEnabled
            }

            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "bundleId": bundleId,
                    "shieldActive": config.isEnabled,
                    "mode": config.protectionMode,
                    "isIgnored": isIgnored || isSelf,
                    "isProtected": isProtected,
                    "willLockOnSwitch": willTrigger
                ]
                if let d = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                let statusEmoji = willTrigger ? "🛡️ ACTIVE (Will verify)" : "⚪ PASS (Bypassed)"
                print("""
                FaceLock App Security Inspection:
                  Bundle ID: \(bundleId)
                  Status: \(statusEmoji)
                  Shield Enabled: \(config.isEnabled ? "Yes" : "No")
                  Protection Mode: \(config.protectionMode)
                  Ignored List: \(isIgnored ? "Yes (Ignored)" : "No")
                  Protected List: \(isProtected ? "Yes (Protected)" : "No")
                  Triggers Biometrics: \(willTrigger ? "Yes (Biometric Challenge Required)" : "No (Pass-through)")
                """)
            }
            exit(0)
        }

        if args.contains("--status") {
            let enrolledCount = Config.shared.loadEnrolledVectors().count
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)
            let incidentCount = files.count

            var recent24hCount = 0
            var latestIncidentTimestamp: String? = nil
            let oneDayAgo = Date().addingTimeInterval(-86400)

            for f in files {
                let p = dir.appendingPathComponent(f).path
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p),
                   let modDate = attrs[.modificationDate] as? Date {
                    if latestIncidentTimestamp == nil {
                        latestIncidentTimestamp = ISO8601DateFormatter().string(from: modDate)
                    }
                    if modDate >= oneDayAgo {
                        recent24hCount += 1
                    }
                }
            }

            if args.contains("--json") {
                let statusDict: [String: Any] = [
                    "version": Config.currentVersion,
                    "daemon": isAlreadyRunning ? "running" : "stopped",
                    "shieldState": Config.shared.isEnabled ? "active" : "paused",
                    "protectionMode": Config.shared.protectionMode,
                    "activeProfile": Config.shared.activeProfile,
                    "shoulderSurfingDefense": Config.shared.shoulderSurfingDefense,
                    "batteryAwareScanning": Config.shared.batteryAwareScanning,
                    "audibleAlerts": Config.shared.audibleAlerts,
                    "presentationModeSuppression": Config.shared.presentationModeSuppression,
                    "enrolledTemplates": enrolledCount,
                    "incidentCaptures": incidentCount,
                    "recentIncidents24h": recent24hCount,
                    "latestIncidentTimestamp": latestIncidentTimestamp as Any,
                    "similarityThreshold": Double(Config.shared.similarityThreshold),
                    "walkAwayLockEnabled": Config.shared.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": Config.shared.walkAwayIdleSeconds,
                    "lockOnWake": Config.shared.lockOnWake,
                    "maxFailedPinAttempts": Config.shared.maxFailedPinAttempts,
                    "pinLockoutSeconds": Config.shared.pinLockoutSeconds,
                    "livenessDetectionEnabled": Config.shared.livenessDetectionEnabled,
                    "autoTriggerTouchID": Config.shared.autoTriggerTouchID,
                    "telegramEnabled": Config.shared.telegramEnabled
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: statusDict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            let recent24hStr = recent24hCount > 0 ? " (\(recent24hCount) in past 24h)" : ""
            print("""
            FaceLock Status:
              Version: \(Config.currentVersion) (darwin-arm64)
              Daemon: \(isAlreadyRunning ? "RUNNING" : "STOPPED")
              Shield: \(Config.shared.isEnabled ? "ACTIVE" : "PAUSED")
              Mode: \(Config.shared.protectionMode)
              Security Profile: \(Config.shared.activeProfile.uppercased()) (\(Config.SecurityProfile(rawValue: Config.shared.activeProfile)?.title ?? Config.shared.activeProfile))
              Shoulder-Surfing Defense: \(Config.shared.shoulderSurfingDefense ? "Enabled" : "Disabled")
              Battery-Aware Polling: \(Config.shared.batteryAwareScanning ? "Enabled" : "Disabled")
              Audible Alerts: \(Config.shared.audibleAlerts ? "Enabled" : "Disabled")
              Meeting Auto-Suppression: \(Config.shared.presentationModeSuppression ? "Enabled" : "Disabled")
              Enrolled Templates: \(enrolledCount) (\(enrolledCount > 0 ? "Strict Neural Biometrics" : "Presence Detection Fallback"))
              Intruder Captures: \(incidentCount) logged\(recent24hStr)
              Decision Threshold: \(Config.shared.similarityThreshold)
              Anti-Spoofing Liveness: \(Config.shared.livenessDetectionEnabled ? "Enabled" : "Disabled")
              Auto-Trigger Touch ID: \(Config.shared.autoTriggerTouchID ? "Enabled" : "Disabled")
              Walk-Away Auto Lock: \(Config.shared.walkAwayLockEnabled ? "Enabled (\(Int(Config.shared.walkAwayIdleSeconds))s)" : "Disabled")
              Lock On Screen Wake: \(Config.shared.lockOnWake ? "Enabled" : "Disabled")
              Telegram Notifications: \(Config.shared.telegramEnabled ? "Configured" : "Disabled")
            """)
            exit(0)
        }

        if args.contains("--health") || args.contains("--ping") {
            let enrolledCount = Config.shared.loadEnrolledVectors().count
            let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
            let camOk = (camAuth == .authorized || camAuth == .notDetermined)
            let isHealthy = isAlreadyRunning && Config.shared.isEnabled && (enrolledCount > 0) && camOk
            var issues: [String] = []
            if !isAlreadyRunning { issues.append("Daemon is stopped") }
            if !Config.shared.isEnabled { issues.append("Shield protection is paused") }
            if enrolledCount == 0 { issues.append("No face templates enrolled") }
            if !camOk { issues.append("Camera access is restricted or denied") }

            let incStats = CameraScanner.shared.getDetailedIncidentStats()
            let logStats = SecurityAuditLogger.shared.getLogStats()

            if args.contains("--json") {
                let out: [String: Any] = [
                    "healthy": isHealthy,
                    "version": Config.currentVersion,
                    "daemonRunning": isAlreadyRunning,
                    "shieldActive": Config.shared.isEnabled,
                    "activeProfile": Config.shared.activeProfile,
                    "enrolledTemplates": enrolledCount,
                    "cameraAuthorized": camAuth == .authorized,
                    "totalIncidents": incStats.totalCaptures,
                    "recentIncidents24h": incStats.past24HoursCount,
                    "totalAuditEvents": logStats.totalCount,
                    "issues": issues
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                if isHealthy {
                    print("✓ FaceLock is HEALTHY (Daemon running, shield active, \(enrolledCount) templates calibrated, \(incStats.totalCaptures) incidents, \(logStats.totalCount) audit events).")
                } else {
                    print("⚠️ FaceLock HEALTH WARNING:")
                    for issue in issues {
                        print("  • \(issue)")
                    }
                }
            }
            exit(isHealthy ? 0 : 1)
        }

        if args.contains("--config") {
            let config = Config.shared
            if args.contains("--json") {
                let configDict: [String: Any] = [
                    "similarityThreshold": Double(config.similarityThreshold),
                    "verificationTimeout": config.verificationTimeout,
                    "debounceSeconds": config.debounceSeconds,
                    "isEnabled": config.isEnabled,
                    "strictFaceMatch": config.strictFaceMatch,
                    "protectionMode": config.protectionMode,
                    "activeProfile": config.activeProfile,
                    "shoulderSurfingDefense": config.shoulderSurfingDefense,
                    "batteryAwareScanning": config.batteryAwareScanning,
                    "audibleAlerts": config.audibleAlerts,
                    "presentationModeSuppression": config.presentationModeSuppression,
                    "walkAwayLockEnabled": config.walkAwayLockEnabled,
                    "walkAwayIdleSeconds": config.walkAwayIdleSeconds,
                    "telegramEnabled": config.telegramEnabled,
                    "livenessDetectionEnabled": config.livenessDetectionEnabled,
                    "autoTriggerTouchID": config.autoTriggerTouchID,
                    "lockOnWake": config.lockOnWake,
                    "maxFailedPinAttempts": config.maxFailedPinAttempts,
                    "pinLockoutSeconds": config.pinLockoutSeconds,
                    "preferredCameraID": config.preferredCameraID.isEmpty ? "default" : config.preferredCameraID,
                    "protectedAppsCount": config.protectedBundleIdentifiers.count,
                    "ignoredAppsCount": config.ignoredBundleIdentifiers.count,
                    "hasEnrolledFace": config.hasEnrolledFace
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: configDict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("""
            FaceLock Configuration:
              Protection State: \(config.isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")
              Protection Mode: \(config.protectionMode)
              Active Profile: \(config.activeProfile.uppercased()) (\(Config.SecurityProfile(rawValue: config.activeProfile)?.title ?? config.activeProfile))
              Shoulder-Surfing Defense: \(config.shoulderSurfingDefense ? "Enabled" : "Disabled")
              Battery-Aware Polling: \(config.batteryAwareScanning ? "Enabled" : "Disabled")
              Audible Alerts: \(config.audibleAlerts ? "Enabled" : "Disabled")
              Meeting Auto-Suppression: \(config.presentationModeSuppression ? "Enabled" : "Disabled")
              Decision Threshold: \(config.similarityThreshold)
              Verification Timeout: \(config.verificationTimeout)s
              Switch Debounce: \(config.debounceSeconds)s
              Walk-Away Auto Lock: \(config.walkAwayLockEnabled ? "Enabled (\(Int(config.walkAwayIdleSeconds))s idle)" : "Disabled")
              Anti-Spoofing Liveness: \(config.livenessDetectionEnabled ? "Enabled" : "Disabled")
              Touch ID Fallback: \(config.autoTriggerTouchID ? "Enabled" : "Disabled")
              Lock On Screen Wake: \(config.lockOnWake ? "Enabled" : "Disabled")
              Max Failed PIN Attempts: \(config.maxFailedPinAttempts)
              PIN Lockout Delay: \(Int(config.pinLockoutSeconds))s
              Preferred Camera: \(config.preferredCameraID.isEmpty ? "Default (Automatic)" : config.preferredCameraID)
              Telegram Alerts: \(config.telegramEnabled ? "Enabled" : "Disabled")
              Protected Apps: \(config.protectedBundleIdentifiers.count) applications
              Enrolled Face Vectors: \(config.loadEnrolledVectors().count) templates
            """)
            exit(0)
        }

        if args.contains("--apps") {
            let config = Config.shared
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "mode": config.protectionMode,
                    "protectedApps": config.protectedBundleIdentifiers,
                    "ignoredApps": config.ignoredBundleIdentifiers
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("FaceLock Protected Applications (Mode: \(config.protectionMode)):")
            for app in config.protectedBundleIdentifiers {
                print("  • \(app)")
            }
            print("\nIgnored System Applications:")
            for app in config.ignoredBundleIdentifiers {
                print("  - \(app)")
            }
            exit(0)
        }

        let notifyDaemonIfRunning = {
            if isAlreadyRunning {
                AppDelegate.notifyDaemonReload()
            }
        }

        if args.contains("--protect-app") {
            guard let bundleId = AppDelegate.valueForOption("--protect-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --protect-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --protect-app <bundleId>")
                }
                exit(1)
            }
            let added = Config.shared.addProtectedApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added protected application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to protected applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' is already in protected applications list.")
                }
            }
            exit(0)
        }

        if args.contains("--unprotect-app") {
            guard let bundleId = AppDelegate.valueForOption("--unprotect-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --unprotect-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --unprotect-app <bundleId>")
                }
                exit(1)
            }
            let removed = Config.shared.removeProtectedApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed protected application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from protected applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in protected applications list.")
                }
            }
            exit(0)
        }

        if args.contains("--ignore-app") {
            guard let bundleId = AppDelegate.valueForOption("--ignore-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --ignore-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --ignore-app <bundleId>")
                }
                exit(1)
            }
            let added = Config.shared.addIgnoredApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added ignored application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to ignored applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' is already in ignored applications list.")
                }
            }
            exit(0)
        }

        if args.contains("--unignore-app") {
            guard let bundleId = AppDelegate.valueForOption("--unignore-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --unignore-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --unignore-app <bundleId>")
                }
                exit(1)
            }
            let removed = Config.shared.removeIgnoredApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed ignored application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\"}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from ignored applications list.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in ignored applications list.")
                }
            }
            exit(0)
        }

        if args.contains("--reset-apps") {
            Config.shared.resetAllAppLists()
            SecurityAuditLogger.shared.logPolicyChanged(action: "Reset application policy to defaults", bundleId: "all")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "protectedAppsCount": Config.shared.protectedBundleIdentifiers.count,
                    "ignoredAppsCount": Config.shared.ignoredBundleIdentifiers.count,
                    "message": "Reset application lists to factory defaults"
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
            } else {
                print("✓ Reset protected (\(Config.shared.protectedBundleIdentifiers.count)) and ignored (\(Config.shared.ignoredBundleIdentifiers.count)) application lists to factory defaults.")
            }
            exit(0)
        }

        if args.contains("--add-meeting-app") {
            guard let bundleId = AppDelegate.valueForOption("--add-meeting-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --add-meeting-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --add-meeting-app <bundleId>")
                }
                exit(1)
            }
            let added = Config.shared.addMeetingApp(bundleId)
            if added {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Added custom meeting application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(added ? "added" : "already_present")\",\"bundleId\":\"\(bundleId)\",\"totalCustomMeetingApps\":\(Config.shared.customPresentationBundleIdentifiers.count)}")
            } else {
                if added {
                    print("✓ Added '\(bundleId)' to custom meeting suppression whitelist.")
                } else {
                    print("ℹ️ '\(bundleId)' is already present in custom meeting whitelist.")
                }
            }
            exit(0)
        }

        if args.contains("--remove-meeting-app") {
            guard let bundleId = AppDelegate.valueForOption("--remove-meeting-app", in: args), Config.isValidBundleIdentifier(bundleId) else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Invalid or missing bundle identifier for --remove-meeting-app\"}")
                } else {
                    print("Error: Invalid or missing bundle identifier. Usage: facelock --remove-meeting-app <bundleId>")
                }
                exit(1)
            }
            let removed = Config.shared.removeMeetingApp(bundleId)
            if removed {
                SecurityAuditLogger.shared.logPolicyChanged(action: "Removed custom meeting application", bundleId: bundleId)
                notifyDaemonIfRunning()
            }
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"\(removed ? "removed" : "not_found")\",\"bundleId\":\"\(bundleId)\",\"totalCustomMeetingApps\":\(Config.shared.customPresentationBundleIdentifiers.count)}")
            } else {
                if removed {
                    print("✓ Removed '\(bundleId)' from custom meeting whitelist.")
                } else {
                    print("ℹ️ '\(bundleId)' was not found in custom meeting applications.")
                }
            }
            exit(0)
        }

        if args.contains("--reset-meeting-apps") {
            let previousCount = Config.shared.customPresentationBundleIdentifiers.count
            Config.shared.resetMeetingApps()
            SecurityAuditLogger.shared.logPolicyChanged(action: "Reset custom meeting applications", bundleId: "all")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"action\":\"reset\",\"clearedCount\":\(previousCount)}")
            } else {
                print("✓ Reset custom meeting applications (\(previousCount) app(s) cleared).")
            }
            exit(0)
        }

        if args.contains("--custom-meeting-apps") {
            let custom = Config.shared.customPresentationBundleIdentifiers
            if args.contains("--json") {
                let payload: [String: Any] = [
                    "success": true,
                    "count": custom.count,
                    "customMeetingApps": custom
                ]
                if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("FaceLock Custom Meeting Applications (\(custom.count)):")
                if custom.isEmpty {
                    print("  (None configured. Add with 'facelock --add-meeting-app <bundleId>')")
                } else {
                    for app in custom {
                        print("  • \(app)")
                    }
                }
            }
            exit(0)
        }

        if args.contains("--toggle-liveness") || (args.firstIndex(of: "--set-liveness").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.livenessDetectionEnabled
            Config.shared.livenessDetectionEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "livenessDetectionEnabled", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"livenessDetectionEnabled\":\(enabled)}")
            } else {
                print("✓ Anti-spoofing liveness verification \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-liveness"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
            Config.shared.livenessDetectionEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "livenessDetectionEnabled", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"livenessDetectionEnabled\":\(enabled)}")
            } else {
                print("✓ Anti-spoofing liveness verification \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-touchid") || (args.firstIndex(of: "--set-touchid").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.autoTriggerTouchID
            Config.shared.autoTriggerTouchID = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "autoTriggerTouchID", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"autoTriggerTouchID\":\(enabled)}")
            } else {
                print("✓ Touch ID fallback on lock screen \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-touchid"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
            Config.shared.autoTriggerTouchID = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "autoTriggerTouchID", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"autoTriggerTouchID\":\(enabled)}")
            } else {
                print("✓ Touch ID fallback on lock screen \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-wake") {
            let enabled = !Config.shared.lockOnWake
            Config.shared.lockOnWake = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "lockOnWake", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"lockOnWake\":\(enabled)}")
            } else {
                print("✓ Lock verification upon Mac screen wake \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--set-lock-on-wake") ?? args.firstIndex(of: "--lock-on-wake")) {
            let enabled: Bool
            if idx + 1 < args.count && !args[idx + 1].starts(with: "--") {
                let val = args[idx + 1].lowercased()
                if val == "toggle" {
                    enabled = !Config.shared.lockOnWake
                } else {
                    enabled = (val == "on" || val == "true" || val == "1" || val == "enable" || val == "yes")
                }
            } else {
                enabled = !Config.shared.lockOnWake
            }
            Config.shared.lockOnWake = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "lockOnWake", value: "\(enabled)")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"lockOnWake\":\(enabled)}")
            } else {
                print("✓ Lock verification upon Mac screen wake \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--backup-config") ?? args.firstIndex(of: "--export-config")), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --backup-config <path>")
                exit(1)
            }
            do {
                let savedPath = try Config.shared.backupConfig(to: path)
                SecurityAuditLogger.shared.logConfigChanged(setting: "backupConfig", value: savedPath, details: "Exported configuration to \(savedPath)")
                if args.contains("--json") {
                    print("{\"success\":true,\"path\":\"\(savedPath)\"}")
                } else {
                    print("✓ Exported FaceLock configuration to '\(savedPath)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error backing up config: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = (args.firstIndex(of: "--restore-config") ?? args.firstIndex(of: "--import-config")), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --restore-config <path>")
                exit(1)
            }
            do {
                try Config.shared.restoreConfig(from: path)
                SecurityAuditLogger.shared.logConfigChanged(setting: "restoreConfig", value: path, details: "Imported configuration from \(path)")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"path\":\"\(path)\"}")
                } else {
                    print("✓ Restored and applied FaceLock configuration from '\(path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error restoring config: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--vectors") || args.contains("--vector-metrics") {
            let metrics = Config.shared.getVectorMetrics()
            if args.contains("--json") {
                if let jsonData = try? JSONSerialization.data(withJSONObject: metrics, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
            } else {
                let count = metrics["count"] as? Int ?? 0
                let dims = metrics["dimensions"] as? Int ?? 0
                let quality = metrics["quality"] as? String ?? "N/A"
                let filePath = metrics["filePath"] as? String ?? ""
                let fileSizeBytes = metrics["fileSizeBytes"] as? UInt64 ?? 0
                let lastMod = metrics["lastModified"] as? String ?? "N/A"

                print("""
                FaceLock Biometric Face Vectors:
                  Enrolled Templates: \(count)
                  Embedding Dimension: \(dims > 0 ? "\(dims)-d (Apple Neural Vision Faceprint)" : "None")
                  Cluster Quality: \(quality)
                  Storage Location: \(filePath) (\(fileSizeBytes) bytes)
                  Last Modified: \(lastMod)
                """)
                if count >= 2,
                   let minVal = metrics["minPairwiseDistance"] as? Double,
                   let avgVal = metrics["avgPairwiseDistance"] as? Double,
                   let maxVal = metrics["maxPairwiseDistance"] as? Double,
                   let stdDev = metrics["standardDeviation"] as? Double {
                    print("""
                  Pairwise Cosine Distances:
                    • Minimum: \(String(format: "%.4f", minVal))
                    • Average: \(String(format: "%.4f", avgVal))
                    • Maximum: \(String(format: "%.4f", maxVal))
                    • Std Dev: \(String(format: "%.4f", stdDev))
                """)
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--export-vectors"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --export-vectors <path>")
                exit(1)
            }
            do {
                let count = try Config.shared.exportVectors(to: path)
                if args.contains("--json") {
                    print("{\"success\":true,\"exportedCount\":\(count),\"path\":\"\(path)\"}")
                } else {
                    print("✓ Exported \(count) facial template vectors to '\(path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting vectors: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--import-vectors"), idx + 1 < args.count {
            let path = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Error: Usage: facelock --import-vectors <path>")
                exit(1)
            }
            let replace = args.contains("--replace")
            do {
                let total = try Config.shared.importVectors(from: path, merge: !replace)
                SecurityAuditLogger.shared.logVectorsModified(action: "Imported facial vectors", count: total, details: "Imported from \(path)")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"totalVectors\":\(total),\"path\":\"\(path)\",\"merged\":\(!replace)}")
                } else {
                    print("✓ Imported vectors from '\(path)'. Total enrolled templates: \(total).")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error importing vectors: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--optimize-vectors") || args.contains("--prune-vectors") {
            let result = Config.shared.optimizeVectors(maxVectors: 15)
            SecurityAuditLogger.shared.logVectorsModified(
                action: "Optimized facial vectors cluster",
                count: result["optimizedCount"] as? Int ?? 0,
                details: "Pruned \(result["prunedRedundant"] as? Int ?? 0) redundant vectors and \(result["prunedOutliers"] as? Int ?? 0) outliers"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let initial = result["initialCount"] as? Int ?? 0
                let optimized = result["optimizedCount"] as? Int ?? 0
                let red = result["prunedRedundant"] as? Int ?? 0
                let out = result["prunedOutliers"] as? Int ?? 0
                let initQuality = result["initialQuality"] as? String ?? ""
                let optQuality = result["optimizedQuality"] as? String ?? ""
                print("""
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                       🧬  FaceLock Neural Vector Cluster Optimizer         
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                • Enrolled Templates: \(initial) -> \(optimized)
                • Redundant vectors pruned: \(red)
                • Outlier samples removed: \(out)
                • Initial Cluster Quality: \(initQuality)
                • Optimized Cluster Quality: \(optQuality)
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                ✓ Enrolled facial template cluster optimized successfully.
                """)
            }
            exit(0)
        }

        if args.contains("--vector-consistency") || args.contains("--analyze-vectors") {
            let res = Config.shared.analyzeTemplateConsistency()
            if args.contains("--json") {
                if let data = try? JSONSerialization.data(withJSONObject: res, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let count = res["count"] as? Int ?? 0
                let status = res["status"] as? String ?? "UNKNOWN"
                let cohesion = res["cohesionScore"] as? Double ?? 0.0
                let diversity = res["diversityScore"] as? Double ?? 0.0
                let medoid = res["medoidIndex"] as? Int ?? -1
                let minPair = res["minPairwiseDistance"] as? Double ?? 0.0
                let avgPair = res["avgPairwiseDistance"] as? Double ?? 0.0
                let maxPair = res["maxPairwiseDistance"] as? Double ?? 0.0
                let avgCentroid = res["avgDistanceToCentroid"] as? Double ?? 0.0
                let rec = res["recommendation"] as? String ?? ""

                print("""
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                       🧬  FaceLock Neural Vector Consistency Analysis       
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                • Enrolled Templates: \(count)
                • Cluster Status: \(status)
                • Cluster Cohesion Score: \(String(format: "%.3f", cohesion)) (1.0 = compact)
                • Angle/Pose Diversity Score: \(String(format: "%.3f", diversity))
                • Cluster Medoid Template: \(medoid >= 0 ? "Index #\(medoid)" : "N/A")
                • Avg Distance to Centroid: \(String(format: "%.4f", avgCentroid))
                • Cosine Distance Range: [\(String(format: "%.4f", minPair)) .. \(String(format: "%.4f", avgPair)) .. \(String(format: "%.4f", maxPair))]
                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                💡 Recommendation: \(rec)
                """)
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-threshold"), idx + 1 < args.count {
            if let val = Float(args[idx + 1]), Config.isValidThreshold(val) {
                Config.shared.similarityThreshold = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "similarityThreshold", value: "\(val)")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"similarityThreshold\":\(val)}")
                } else {
                    print("✓ Similarity decision threshold updated to \(val).")
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Threshold must be a floating point value between 0.05 and 0.60.\"}")
                } else {
                    print("Error: Threshold must be a floating point value between 0.05 and 0.60.")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-timeout"), idx + 1 < args.count {
            if let val = Double(args[idx + 1]), Config.isValidTimeout(val) {
                Config.shared.verificationTimeout = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "verificationTimeout", value: "\(val)s")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"verificationTimeout\":\(val)}")
                } else {
                    print("✓ Verification timeout updated to \(val)s.")
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Timeout must be between 0.5 and 10.0 seconds.\"}")
                } else {
                    print("Error: Timeout must be between 0.5 and 10.0 seconds. Usage: facelock --set-timeout <seconds>")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-debounce"), idx + 1 < args.count {
            if let val = Double(args[idx + 1]), Config.isValidDebounce(val) {
                Config.shared.debounceSeconds = val
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "debounceSeconds", value: "\(val)s")
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"debounceSeconds\":\(val)}")
                } else {
                    print("✓ Switch debounce interval updated to \(val)s.")
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Debounce must be between 0.5 and 30.0 seconds.\"}")
                } else {
                    print("Error: Debounce must be between 0.5 and 30.0 seconds. Usage: facelock --set-debounce <seconds>")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--set-mode"), idx + 1 < args.count {
            let mode = args[idx + 1].lowercased()
            if Config.isValidProtectionMode(mode) {
                Config.shared.protectionMode = mode
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(setting: "protectionMode", value: mode)
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"protectionMode\":\"\(mode)\"}")
                } else {
                    print("✓ Protection mode updated to '\(mode)'.")
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Mode must be either 'all' or 'selective'.\"}")
                } else {
                    print("Error: Mode must be either 'all' or 'selective'.")
                }
                exit(1)
            }
        }

        if args.contains("--set-pin") {
            if let newPin = AppDelegate.valueForOption("--set-pin", in: args) {
                if Config.isValidPin(newPin) {
                    Config.shared.pin = newPin
                    Config.shared.save()
                    SecurityAuditLogger.shared.logConfigChanged(setting: "pin", value: "****", details: "Lock screen unlock PIN updated")
                    notifyDaemonIfRunning()
                    if args.contains("--json") {
                        print("{\"success\":true,\"message\":\"Lock screen PIN updated\",\"pinLength\":\(newPin.count)}")
                    } else {
                        print("✓ Lock screen PIN successfully updated.")
                    }
                    exit(0)
                } else {
                    if args.contains("--json") {
                        print("{\"success\":false,\"error\":\"PIN must be between 4 and 8 digits (numeric only).\"}")
                    } else {
                        print("Error: PIN must be between 4 and 8 digits (numeric only).")
                    }
                    exit(1)
                }
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Missing PIN value. Usage: facelock --set-pin <pin>\"}")
                } else {
                    print("Error: Missing PIN value. Usage: facelock --set-pin <pin>")
                }
                exit(1)
            }
        }

        if args.contains("--set-pin-attempts") {
            if let str = AppDelegate.valueForOption("--set-pin-attempts", in: args) {
                if let count = Int(str), Config.isValidPinAttempts(count) {
                    Config.shared.maxFailedPinAttempts = count
                    Config.shared.save()
                    SecurityAuditLogger.shared.logConfigChanged(setting: "maxFailedPinAttempts", value: "\(count)")
                    notifyDaemonIfRunning()
                    if args.contains("--json") {
                        print("{\"success\":true,\"maxFailedPinAttempts\":\(count)}")
                    } else {
                        print("✓ Max failed PIN attempts updated to \(count).")
                    }
                    exit(0)
                } else {
                    if args.contains("--json") {
                        print("{\"success\":false,\"error\":\"Failed attempts threshold must be between 1 and 10.\"}")
                    } else {
                        print("Error: Failed attempts threshold must be between 1 and 10.")
                    }
                    exit(1)
                }
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Missing count value. Usage: facelock --set-pin-attempts <count>\"}")
                } else {
                    print("Error: Missing count value. Usage: facelock --set-pin-attempts <count>")
                }
                exit(1)
            }
        }

        if args.contains("--set-pin-lockout") {
            if let str = AppDelegate.valueForOption("--set-pin-lockout", in: args) {
                if let secs = Double(str), Config.isValidPinLockout(secs) {
                    Config.shared.pinLockoutSeconds = secs
                    Config.shared.save()
                    SecurityAuditLogger.shared.logConfigChanged(setting: "pinLockoutSeconds", value: "\(Int(secs))s")
                    notifyDaemonIfRunning()
                    if args.contains("--json") {
                        print("{\"success\":true,\"pinLockoutSeconds\":\(secs)}")
                    } else {
                        print("✓ PIN lockout delay updated to \(Int(secs))s.")
                    }
                    exit(0)
                } else {
                    if args.contains("--json") {
                        print("{\"success\":false,\"error\":\"PIN lockout delay must be between 1.0 and 60.0 seconds.\"}")
                    } else {
                        print("Error: PIN lockout delay must be between 1.0 and 60.0 seconds.")
                    }
                    exit(1)
                }
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Missing seconds value. Usage: facelock --set-pin-lockout <seconds>\"}")
                } else {
                    print("Error: Missing seconds value. Usage: facelock --set-pin-lockout <seconds>")
                }
                exit(1)
            }
        }

        if args.contains("--verify-pin") {
            if let candidatePin = AppDelegate.valueForOption("--verify-pin", in: args) {
                let isValid = (candidatePin == Config.shared.pin)
                SecurityAuditLogger.shared.logVerificationCheck(type: "pin_verification", success: isValid, details: "CLI PIN verification test: \(isValid ? "Match" : "Mismatch")")
                if args.contains("--json") {
                    print("{\"valid\":\(isValid),\"length\":\(candidatePin.count)}")
                } else {
                    if isValid {
                        print("✓ PIN matches configured lock screen PIN.")
                    } else {
                        print("❌ PIN does not match.")
                    }
                }
                exit(isValid ? 0 : 1)
            } else {
                if args.contains("--json") {
                    print("{\"valid\":false,\"error\":\"Missing PIN argument. Usage: facelock --verify-pin <pin>\"}")
                } else {
                    print("Error: Missing PIN argument. Usage: facelock --verify-pin <pin>")
                }
                exit(1)
            }
        }

        if args.contains("--set-duress-pin") {
            if let newDuress = AppDelegate.valueForOption("--set-duress-pin", in: args) {
                let validation = Config.isValidDuressPin(newDuress, masterPin: Config.shared.pin)
                if validation.isValid {
                    let result = Config.shared.setDuressPin(newDuress)
                    SecurityAuditLogger.shared.logConfigChanged(setting: "duressPin", value: "****", details: "Lock screen duress PIN updated")
                    notifyDaemonIfRunning()
                    if args.contains("--json") {
                        print("{\"success\":true,\"duressPinConfigured\":true,\"length\":\(newDuress.count),\"message\":\"\(result.message)\"}")
                    } else {
                        print("✓ Duress PIN configured (\(newDuress.count) digits). Coerced unlock alerts enabled.")
                    }
                    exit(0)
                } else {
                    let err = validation.error ?? "Invalid duress PIN."
                    if args.contains("--json") {
                        print("{\"success\":false,\"error\":\"\(err)\"}")
                    } else {
                        print("Error: \(err)")
                    }
                    exit(1)
                }
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Missing PIN value. Usage: facelock --set-duress-pin <pin>\"}")
                } else {
                    print("Error: Missing PIN value. Usage: facelock --set-duress-pin <pin>")
                }
                exit(1)
            }
        }

        if args.contains("--clear-duress-pin") {
            Config.shared.clearDuressPin()
            SecurityAuditLogger.shared.logConfigChanged(setting: "duressPin", value: "<cleared>", details: "Duress PIN cleared")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"duressPinConfigured\":false,\"message\":\"Код принуждения сброшен\"}")
            } else {
                print("✓ Duress PIN cleared. Coerced unlock detection disabled.")
            }
            exit(0)
        }

        if args.contains("--duress-status") {
            let isConfigured = Config.shared.isDuressPinEnabled
            let length = Config.shared.duressPin.count
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "enabled": isConfigured,
                    "isConfigured": isConfigured,
                    "length": length
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                if isConfigured {
                    print("Duress Defense: ACTIVE (\(length) digits configured) 🔏")
                } else {
                    print("Duress Defense: NOT CONFIGURED (Run 'facelock --set-duress-pin <pin>' to enable)")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-telegram"), idx + 2 < args.count {
            let token = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let chatId = args[idx + 2].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !token.isEmpty && !chatId.isEmpty else {
                print("Error: Usage: facelock --set-telegram <token> <chatId>")
                exit(1)
            }
            Config.shared.telegramBotToken = token
            Config.shared.telegramChatId = chatId
            Config.shared.telegramEnabled = true
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"chatId\":\"\(chatId)\",\"telegramEnabled\":true}")
            } else {
                print("✓ Telegram credentials configured and alerts enabled for chat \(chatId).")
            }
            exit(0)
        }

        if args.contains("--enable-telegram") {
            Config.shared.telegramEnabled = true
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"telegramEnabled\":true}")
            } else {
                print("✓ Telegram intruder alerts enabled.")
            }
            exit(0)
        }

        if args.contains("--disable-telegram") {
            Config.shared.telegramEnabled = false
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"telegramEnabled\":false}")
            } else {
                print("✓ Telegram intruder alerts disabled.")
            }
            exit(0)
        }

        if args.contains("--toggle-walkaway") || (args.firstIndex(of: "--set-walkaway").map { $0 + 1 < args.count && args[$0 + 1].lowercased() == "toggle" } ?? false) {
            let enabled = !Config.shared.walkAwayLockEnabled
            Config.shared.walkAwayLockEnabled = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "walkAwayLockEnabled", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"walkAwayLockEnabled\":\(enabled),\"walkAwayIdleSeconds\":\(Config.shared.walkAwayIdleSeconds)}")
            } else {
                print("✓ Walk-away auto-lock \(enabled ? "enabled (\(Int(Config.shared.walkAwayIdleSeconds))s idle timeout)" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-walkaway"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            if val == "off" || val == "disable" || val == "0" {
                Config.shared.walkAwayLockEnabled = false
                Config.shared.save()
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"walkAwayLockEnabled\":false}")
                } else {
                    print("✓ Walk-away auto-lock disabled.")
                }
            } else if let secs = Double(val), Config.isValidWalkAwayTimeout(secs) {
                Config.shared.walkAwayLockEnabled = true
                Config.shared.walkAwayIdleSeconds = secs
                Config.shared.save()
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"walkAwayLockEnabled\":true,\"walkAwayIdleSeconds\":\(secs)}")
                } else {
                    print("✓ Walk-away auto-lock enabled with \(Int(secs))s idle timeout.")
                }
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Walk-away timeout must be between 10 and 600 seconds, or 'off'.\"}")
                } else {
                    print("Error: Invalid timeout. Provide seconds (10 - 600) or 'off'.")
                }
                exit(1)
            }
            exit(0)
        }

        if args.contains("--profiles") {
            if args.contains("--json") {
                let profiles = Config.SecurityProfile.allCases.map { p -> [String: Any] in
                    return [
                        "id": p.rawValue,
                        "title": p.title,
                        "summary": p.summary,
                        "isActive": (Config.shared.activeProfile == p.rawValue)
                    ]
                }
                let dict: [String: Any] = [
                    "activeProfile": Config.shared.activeProfile,
                    "profiles": profiles
                ]
                if let d = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("FaceLock Security Profiles:")
                for p in Config.SecurityProfile.allCases {
                    let active = (Config.shared.activeProfile == p.rawValue) ? " [ACTIVE] ✅" : ""
                    print("  • \(p.rawValue): \(p.title)\(active)")
                    print("    \(p.summary)")
                }
                print("\n  Active Profile: \(Config.shared.activeProfile)")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--profile") ?? args.firstIndex(of: "--set-profile")),
           idx + 1 < args.count,
           !args[idx + 1].starts(with: "-") {
            let targetName = args[idx + 1].lowercased()
            if Config.shared.setProfile(targetName) {
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"activeProfile\":\"\(targetName)\"}")
                } else {
                    print("✓ Applied security profile '\(targetName)': \(Config.SecurityProfile(rawValue: targetName)?.title ?? targetName)")
                }
            } else {
                let valid = Config.SecurityProfile.allCases.map { $0.rawValue }.joined(separator: ", ")
                print("Error: Unknown profile '\(targetName)'. Available profiles: \(valid)")
                exit(1)
            }
            exit(0)
        } else if args.contains("--profile") || args.contains("--set-profile") {
            let valid = Config.SecurityProfile.allCases.map { $0.rawValue }.joined(separator: ", ")
            if args.contains("--json") {
                let profiles = Config.SecurityProfile.allCases.map { $0.rawValue }
                let dict: [String: Any] = [
                    "activeProfile": Config.shared.activeProfile,
                    "availableProfiles": profiles
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                print("Current Active Profile: \(Config.shared.activeProfile)")
                print("Available profiles: \(valid)")
                print("Usage: facelock --profile <name>")
            }
            exit(0)
        }

        if args.contains("--toggle-shoulder-defense") || args.contains("--toggle-shoulder") {
            let enabled = !Config.shared.shoulderSurfingDefense
            Config.shared.shoulderSurfingDefense = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "shoulderSurfingDefense", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"shoulderSurfingDefense\":\(enabled)}")
            } else {
                print("✓ Shoulder-surfing defense \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-shoulder-defense"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            Config.shared.shoulderSurfingDefense = enabled
            Config.shared.save()
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"shoulderSurfingDefense\":\(enabled)}")
            } else {
                print("✓ Shoulder-surfing defense set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-audible") {
            let enabled = !Config.shared.audibleAlerts
            Config.shared.audibleAlerts = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "audibleAlerts", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"audibleAlerts\":\(enabled)}")
            } else {
                print("✓ Audible sound alerts \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-audible"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.audibleAlerts
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.audibleAlerts = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "audibleAlerts", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"audibleAlerts\":\(enabled)}")
            } else {
                print("✓ Audible sound alerts set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--toggle-battery-aware") || args.contains("--toggle-battery") {
            let enabled = !Config.shared.batteryAwareScanning
            Config.shared.batteryAwareScanning = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "batteryAwareScanning", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"batteryAwareScanning\":\(enabled)}")
            } else {
                print("✓ Battery-aware adaptive scanning \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-battery-aware"), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.batteryAwareScanning
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.batteryAwareScanning = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "batteryAwareScanning", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"batteryAwareScanning\":\(enabled)}")
            } else {
                print("✓ Battery-aware adaptive scanning set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--battery-status") || args.contains("--power-status") {
            let onBattery = WalkAwayMonitor.isOnBatteryPower()
            let lowPower = WalkAwayMonitor.isLowPowerModeEnabled()
            let constrained = WalkAwayMonitor.isPowerConstrained()
            let batteryAware = Config.shared.batteryAwareScanning
            let adaptiveInterval: Double = (batteryAware && constrained) ? 10.0 : 5.0
            let idleDebounce: Double = (batteryAware && constrained) ? 45.0 : 20.0

            if args.contains("--json") {
                let dict: [String: Any] = [
                    "onBattery": onBattery,
                    "lowPowerMode": lowPower,
                    "powerConstrained": constrained,
                    "batteryAwareScanning": batteryAware,
                    "adaptiveIntervalSeconds": adaptiveInterval,
                    "idleDebounceSeconds": idleDebounce
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let jsonStr = String(data: jsonData, encoding: .utf8) {
                    print(jsonStr)
                }
                exit(0)
            }
            print("""
            FaceLock Battery & Power Telemetry:
              Power Source: \(onBattery ? "Battery Power 🔋" : "AC Power (Plugged In) 🔌")
              Low Power Mode: \(lowPower ? "Enabled ⚡" : "Disabled")
              Power Constrained: \(constrained ? "Yes" : "No")
              Battery-Aware Scanning: \(batteryAware ? "Enabled" : "Disabled")
              Adaptive Walk-Away Polling Interval: \(Int(adaptiveInterval))s
              Adaptive Idle Debounce: \(Int(idleDebounce))s
            """)
            exit(0)
        }

        if args.contains("--toggle-presentation") || args.contains("--toggle-presentation-mode") {
            let enabled = !Config.shared.presentationModeSuppression
            Config.shared.presentationModeSuppression = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "presentationModeSuppression", value: "\(enabled)", details: "Toggled via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"presentationModeSuppression\":\(enabled)}")
            } else {
                print("✓ Meeting / presentation lock auto-suppression \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--set-presentation-mode") ?? args.firstIndex(of: "--set-presentation")), idx + 1 < args.count {
            let val = args[idx + 1].lowercased()
            let enabled: Bool
            if val == "toggle" {
                enabled = !Config.shared.presentationModeSuppression
            } else {
                enabled = (val == "1" || val == "true" || val == "on" || val == "enable")
            }
            Config.shared.presentationModeSuppression = enabled
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(setting: "presentationModeSuppression", value: "\(enabled)", details: "Configured via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"presentationModeSuppression\":\(enabled)}")
            } else {
                print("✓ Meeting / presentation lock auto-suppression set to \(enabled ? "enabled" : "disabled").")
            }
            exit(0)
        }

        if args.contains("--cameras") {
            let devices = CameraScanner.availableCaptureDevices()
            let preferredID = Config.shared.preferredCameraID
            let activeDevice = CameraScanner.selectDevice(preferredID: preferredID)

            if args.contains("--json") {
                let list = devices.map { dev -> [String: Any] in
                    let isPreferred = (!preferredID.isEmpty && (dev.uniqueID == preferredID || dev.localizedName.localizedCaseInsensitiveContains(preferredID)))
                    let isActive = (dev.uniqueID == activeDevice?.uniqueID)
                    return [
                        "id": dev.uniqueID,
                        "name": dev.localizedName,
                        "isBuiltIn": dev.deviceType == .builtInWideAngleCamera,
                        "isPreferred": isPreferred,
                        "isActive": isActive
                    ]
                }
                let dict: [String: Any] = [
                    "preferredCameraID": preferredID.isEmpty ? "default" : preferredID,
                    "activeCamera": activeDevice?.localizedName ?? "None",
                    "activeCameraID": activeDevice?.uniqueID ?? "None",
                    "cameras": list
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: data, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("FaceLock Detected Video Cameras (\(devices.count)):")
                for (i, dev) in devices.enumerated() {
                    let isPreferred = (!preferredID.isEmpty && (dev.uniqueID == preferredID || dev.localizedName.localizedCaseInsensitiveContains(preferredID)))
                    let isActive = (dev.uniqueID == activeDevice?.uniqueID)
                    var badge = ""
                    if isPreferred && isActive {
                        badge = " [SELECTED & ACTIVE] ✅"
                    } else if isActive {
                        badge = " [ACTIVE DEFAULT] 🎯"
                    } else if isPreferred {
                        badge = " [PREFERRED] ⭐️"
                    }
                    print("  [\(i + 1)] \(dev.localizedName)\(badge)")
                    print("      ID: \(dev.uniqueID)")
                }
                if preferredID.isEmpty {
                    print("\n  Preferred Camera: Automatic (Front / Built-in camera default)")
                } else {
                    print("\n  Preferred Camera ID: \(preferredID)")
                }
            }
            exit(0)
        }

        if let idx = args.firstIndex(of: "--set-camera"), idx + 1 < args.count {
            let target = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let devices = CameraScanner.availableCaptureDevices()
            var selectedID = ""
            var selectedName = "Default (Auto)"

            if target.lowercased() == "default" || target.lowercased() == "auto" || target == "0" {
                Config.shared.preferredCameraID = ""
                Config.shared.save()
                SecurityAuditLogger.shared.logConfigChanged(
                    setting: "preferredCameraID",
                    value: "default",
                    details: "Reset to default automatic camera selection"
                )
                notifyDaemonIfRunning()
                if args.contains("--json") {
                    print("{\"success\":true,\"preferredCameraID\":\"default\",\"name\":\"Default (Auto)\"}")
                } else {
                    print("✓ Reset preferred camera to Default (Automatic front camera).")
                }
                exit(0)
            } else if let num = Int(target), num >= 1 && num <= devices.count {
                let dev = devices[num - 1]
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else if let dev = devices.first(where: { $0.uniqueID == target }) {
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else if let dev = devices.first(where: { $0.localizedName.localizedCaseInsensitiveContains(target) }) {
                selectedID = dev.uniqueID
                selectedName = dev.localizedName
            } else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Camera not found matching '\(target)'\"}")
                } else {
                    print("Error: Camera not found matching '\(target)'. Use 'facelock --cameras' to list available devices.")
                }
                exit(1)
            }

            Config.shared.preferredCameraID = selectedID
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: selectedID,
                details: "Preferred camera selected: \(selectedName)"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"preferredCameraID\":\"\(selectedID)\",\"name\":\"\(selectedName)\"}")
            } else {
                print("✓ Preferred camera set to: \(selectedName) [\(selectedID)]")
            }
            exit(0)
        }

        if args.contains("--reset-camera") {
            Config.shared.preferredCameraID = ""
            Config.shared.save()
            SecurityAuditLogger.shared.logConfigChanged(
                setting: "preferredCameraID",
                value: "default",
                details: "Reset to default automatic camera selection"
            )
            notifyDaemonIfRunning()
            if args.contains("--json") {
                print("{\"success\":true,\"preferredCameraID\":\"default\",\"name\":\"Default (Auto)\"}")
            } else {
                print("✓ Reset preferred camera to Default (Automatic front camera).")
            }
            exit(0)
        }

        if args.contains("--incidents") || args.contains("--incidents-search") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            var files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            let totalCount = files.count
            var filterType: String? = nil
            if let idx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), idx + 1 < args.count {
                filterType = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }

            var searchQuery: String? = nil
            if let idx = (args.firstIndex(of: "--query") ?? args.firstIndex(of: "--search")) {
                for i in (idx + 1)..<args.count {
                    if !args[i].hasPrefix("-") {
                        searchQuery = args[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        break
                    }
                }
            } else if let idx = args.firstIndex(of: "--incidents-search") {
                for i in (idx + 1)..<args.count {
                    if !args[i].hasPrefix("-") {
                        searchQuery = args[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        break
                    }
                }
            }

            if let filter = filterType, !filter.isEmpty && filter != "all" {
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

            if let q = searchQuery, !q.isEmpty {
                files = files.filter { CameraScanner.matchesIncidentQuery(filename: $0, query: q) }
            }

            if let idx = (args.firstIndex(of: "--tail") ?? args.firstIndex(of: "--limit")), idx + 1 < args.count, let val = Int(args[idx + 1]), val > 0 {
                files = Array(files.prefix(val))
            }

            var totalBytes: UInt64 = 0
            var incidentsData: [[String: Any]] = []

            for f in files {
                let p = dir.appendingPathComponent(f).path
                var sz: UInt64 = 0
                var modDateStr = ""
                if let attrs = try? FileManager.default.attributesOfItem(atPath: p) {
                    if let s = attrs[.size] as? UInt64 {
                        sz = s
                        totalBytes += s
                    }
                    if let mod = attrs[.modificationDate] as? Date {
                        modDateStr = ISO8601DateFormatter().string(from: mod)
                    }
                }
                let incType = CameraScanner.incidentType(for: f)
                incidentsData.append([
                    "filename": f,
                    "path": p,
                    "sizeBytes": sz,
                    "type": incType,
                    "timestamp": modDateStr
                ])
            }

            if args.contains("--json") {
                var outputDict: [String: Any] = [
                    "totalCaptures": totalCount,
                    "retrievedCount": files.count,
                    "filter": filterType ?? "all",
                    "totalSizeBytes": totalBytes,
                    "directory": dir.path,
                    "incidents": incidentsData
                ]
                if let q = searchQuery { outputDict["query"] = q }
                if let d = try? JSONSerialization.data(withJSONObject: outputDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
            var filterDesc = ""
            if let q = searchQuery { filterDesc += " [Query: '\(q)']" }
            if let f = filterType { filterDesc += " [Filter: \(f)]" }
            print("""
            FaceLock Intruder Incident Log\(filterDesc):
              Retrieved Captures: \(files.count) of \(totalCount) (\(String(format: "%.2f", sizeMB)) MB)
              Storage Directory: \(dir.path)
            """)
            if files.isEmpty {
                if let q = searchQuery, let f = filterType {
                    print("  ✓ No intruder events found matching query '\(q)' and filter '\(f)'.")
                } else if let q = searchQuery {
                    print("  ✓ No intruder events found matching query '\(q)'.")
                } else if let f = filterType {
                    print("  ✓ No intruder events found matching filter '\(f)'.")
                } else {
                    print("  ✓ No intruder events logged.")
                }
            } else {
                print("  Incidents (showing \(min(5, files.count))):")
                for item in incidentsData.prefix(5) {
                    let f = item["filename"] as? String ?? ""
                    let t = item["type"] as? String ?? "intruder"
                    let sz = item["sizeBytes"] as? UInt64 ?? 0
                    let szKB = Double(sz) / 1024.0
                    print("    - \(f) [\(t)] (\(String(format: "%.1f", szKB)) KB)")
                }
            }
            exit(0)
        }

        if args.contains("--incidents-summary") || args.contains("--incident-summary") {
            let stats = CameraScanner.shared.getDetailedIncidentStats()

            if args.contains("--json") {
                if let d = try? JSONSerialization.data(withJSONObject: stats.toDictionary(), options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let sizeMB = Double(stats.totalSizeBytes) / (1024.0 * 1024.0)
            let avgKB = stats.averageSizeBytes / 1024.0
            let largestStr = stats.largestIncidentFilename != nil
                ? "  Largest Incident: \(stats.largestIncidentFilename!) (\(String(format: "%.1f", Double(stats.largestIncidentSizeBytes) / 1024.0)) KB)\n"
                : ""
            print("""
            FaceLock Intruder Incident Telemetry:
              Total Captures: \(stats.totalCaptures) (\(String(format: "%.2f", sizeMB)) MB, avg: \(String(format: "%.1f", avgKB)) KB/capture)
              Storage Directory: \(stats.directory)
              Today: \(stats.todayCount) captures
              Past 24 Hours: \(stats.past24HoursCount) captures
              Past 7 Days: \(stats.past7DaysCount) captures
              Incident Classification:
                • Intruders: \(stats.typeBreakdown["intruder", default: 0])
                • Bystanders (Shoulder): \(stats.typeBreakdown["bystander", default: 0])
                • Walk-Away Locks: \(stats.typeBreakdown["walkaway", default: 0])
                • Wake Locks: \(stats.typeBreakdown["wake", default: 0])
                • Brute-Force PIN: \(stats.typeBreakdown["bruteforce", default: 0])
            \(largestStr)  Newest Incident: \(stats.newestIncidentTimestamp ?? "None")
              Oldest Incident: \(stats.oldestIncidentTimestamp ?? "None")
            """)
            exit(0)
        }

        if args.contains("--clear-incidents") {
            var filterType: String? = nil
            if let idx = (args.firstIndex(of: "--type") ?? args.firstIndex(of: "--filter")), idx + 1 < args.count {
                filterType = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                if !CameraScanner.isValidIncidentType(filterType!) {
                    let validList = (CameraScanner.supportedIncidentTypes + ["shoulder", "all"]).joined(separator: ", ")
                    if args.contains("--json") {
                        print("{\"success\":false,\"error\":\"Invalid incident type '\(filterType!)'. Supported: \(validList)\"}")
                    } else {
                        print("Error: Invalid incident type '\(filterType!)'. Supported types: \(validList)")
                    }
                    exit(1)
                }
            }

            let result = CameraScanner.shared.clearIncidents(filterType: filterType)
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)

            if args.contains("--json") {
                let outDict: [String: Any] = [
                    "success": true,
                    "deletedCount": result.deletedCount,
                    "freedSizeBytes": result.freedBytes,
                    "filter": filterType ?? "all",
                    "directory": dir.path
                ]
                if let d = try? JSONSerialization.data(withJSONObject: outDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }

            let freedMB = Double(result.freedBytes) / (1024.0 * 1024.0)
            let typeLabel = filterType != nil ? "(\(filterType!)) " : ""
            print("[FaceLock] Cleared \(result.deletedCount) \(typeLabel)incident captures (\(String(format: "%.2f", freedMB)) MB freed) from \(dir.path).")
            exit(0)
        }

        if let idx = args.firstIndex(of: "--prune-incidents"), idx + 1 < args.count {
            if let keepCount = Int(args[idx + 1]), keepCount >= 0 {
                let removed = CameraScanner.shared.pruneIntruderPhotos(maxRetained: keepCount)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Pruned intruder incident captures via CLI", count: removed, details: "Kept latest \(keepCount) photos")
                if args.contains("--json") {
                    print("{\"success\":true,\"prunedCount\":\(removed),\"maxRetained\":\(keepCount)}")
                } else {
                    print("✓ Pruned \(removed) older intruder captures (retained latest \(keepCount)).")
                }
                exit(0)
            } else {
                print("Error: Count must be a non-negative integer. Usage: facelock --prune-incidents <count>")
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--prune-incidents-days"), idx + 1 < args.count {
            if let days = Int(args[idx + 1]), days >= 0 {
                let res = CameraScanner.shared.pruneIncidentsOlderThan(days: days)
                if args.contains("--json") {
                    let dict: [String: Any] = [
                        "success": true,
                        "prunedCount": res.removedCount,
                        "remainingCount": res.remainingCount,
                        "freedSizeBytes": res.freedBytes,
                        "days": days
                    ]
                    if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                       let str = String(data: data, encoding: .utf8) {
                        print(str)
                    }
                } else {
                    let freedMB = Double(res.freedBytes) / (1024.0 * 1024.0)
                    print("✓ Pruned \(res.removedCount) incident photos older than \(days) day(s) (\(res.remainingCount) retained, \(String(format: "%.2f", freedMB)) MB freed).")
                }
                exit(0)
            } else {
                print("Error: Days must be a non-negative integer. Usage: facelock --prune-incidents-days <days>")
                exit(1)
            }
        }

        if args.contains("--incidents-integrity") || args.contains("--check-incidents") {
            let report = CameraScanner.shared.verifyIncidentsIntegrity()
            if args.contains("--json") {
                let dict = report.toDictionary()
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let validKB = Double(report.totalValidSizeBytes) / 1024.0
                let statusIcon = report.status == "HEALTHY" ? "✓ HEALTHY" : "⚠️ ATTENTION NEEDED"
                print("""
                FaceLock Intruder Captures Integrity Report:
                  Status: \(statusIcon)
                  Total Files Scanned: \(report.totalFilesScanned)
                  Valid Captures: \(report.validCapturesCount) (\(String(format: "%.2f", validKB)) KB)
                  Corrupted Files: \(report.corruptedCount)
                  Zero-Byte Captures: \(report.zeroByteCount)
                  Non-Image Files: \(report.nonImageCount)
                  Directory: \(report.directory)
                """)
                if !report.corruptedFilenames.isEmpty {
                    print("  Corrupted / Invalid Files:")
                    for f in report.corruptedFilenames.prefix(10) {
                        print("    • \(f)")
                    }
                    print("  💡 Tip: Run 'facelock --repair-incidents' to purge corrupted captures.")
                }
            }
            exit(0)
        }

        if args.contains("--repair-incidents") || args.contains("--clean-corrupted-incidents") {
            let res = CameraScanner.shared.repairCorruptedIncidents()
            if args.contains("--json") {
                let outDict: [String: Any] = [
                    "success": true,
                    "repairedCount": res.repairedCount,
                    "freedSizeBytes": res.freedBytes,
                    "remainingValidCaptures": res.remainingValid
                ]
                if let data = try? JSONSerialization.data(withJSONObject: outDict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedKB = Double(res.freedBytes) / 1024.0
                if res.repairedCount > 0 {
                    print("✓ Successfully repaired intruder captures: purged \(res.repairedCount) corrupted file(s) (\(String(format: "%.2f", freedKB)) KB freed). \(res.remainingValid) valid captures retained.")
                } else {
                    print("✓ Intruder captures directory is completely healthy. 0 corrupted files found (\(res.remainingValid) valid captures).")
                }
            }
            exit(0)
        }

        if args.contains("--latest-incident") {
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            if let latest = files.first {
                let path = dir.appendingPathComponent(latest).path
                var sz: UInt64 = 0
                var modDate: Date? = nil
                if let attrs = try? FileManager.default.attributesOfItem(atPath: path) {
                    sz = (attrs[.size] as? UInt64) ?? 0
                    modDate = attrs[.modificationDate] as? Date
                }
                let dateStr = modDate != nil ? ISO8601DateFormatter().string(from: modDate!) : ""

                let incType = CameraScanner.incidentType(for: latest)
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "hasIncident": true,
                        "filename": latest,
                        "path": path,
                        "type": incType,
                        "sizeBytes": sz,
                        "timestamp": dateStr
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let sizeKB = Double(sz) / 1024.0
                    print("""
                    Latest FaceLock Intruder Incident:
                      Filename: \(latest)
                      Type: \(incType)
                      Timestamp: \(dateStr.isEmpty ? "Unknown" : dateStr)
                      Size: \(String(format: "%.1f", sizeKB)) KB
                      File Path: \(path)
                    """)
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"hasIncident\":false,\"message\":\"No intruder incidents logged\"}")
                } else {
                    print("✓ No intruder incidents logged in \(dir.path).")
                }
                exit(0)
            }
        }

        if let idx = args.firstIndex(of: "--export-latest-incident"), idx + 1 < args.count {
            let destPath = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !destPath.isEmpty else {
                print("Error: Usage: facelock --export-latest-incident <path>")
                exit(1)
            }
            let home = FileManager.default.homeDirectoryForCurrentUser
            let dir = home.appendingPathComponent(".facelock/intruders", isDirectory: true)
            let files = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
                .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") }
                .sorted(by: >)

            guard let latest = files.first else {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"No intruder incident captures available to export\"}")
                } else {
                    print("Error: No intruder captures found to export.")
                }
                exit(1)
            }

            let srcURL = dir.appendingPathComponent(latest)
            let expandedDest = NSString(string: destPath).expandingTildeInPath
            let destURL = URL(fileURLWithPath: expandedDest)

            do {
                let parentDir = destURL.deletingLastPathComponent()
                if !FileManager.default.fileExists(atPath: parentDir.path) {
                    try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
                }
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident capture via CLI", count: 1, details: "\(latest) exported to \(destURL.path)")
                if args.contains("--json") {
                    print("{\"success\":true,\"source\":\"\(latest)\",\"destination\":\"\(destURL.path)\"}")
                } else {
                    print("✓ Exported latest incident (\(latest)) to '\(destURL.path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incident photo: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if let idx = args.firstIndex(of: "--export-incident"), idx + 2 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let destPath = args[idx + 2].trimmingCharacters(in: .whitespacesAndNewlines)

            do {
                let res = try CameraScanner.shared.exportIncident(filename: filename, to: destPath)
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident capture via CLI", count: 1, details: "\(res.source) exported to \(res.destination)")
                if args.contains("--json") {
                    print("{\"success\":true,\"source\":\"\(res.source)\",\"destination\":\"\(res.destination)\",\"sizeBytes\":\(res.sizeBytes)}")
                } else {
                    print("✓ Exported incident (\(res.source)) to '\(res.destination)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incident photo: \(error.localizedDescription)")
                }
                exit(1)
            }
        } else if args.contains("--export-incident") {
            if args.contains("--json") {
                print("{\"success\":false,\"error\":\"Missing parameters. Usage: facelock --export-incident <filename> <destinationPath>\"}")
            } else {
                print("Error: Missing parameters. Usage: facelock --export-incident <filename> <destinationPath>")
            }
            exit(1)
        }

        if let idx = args.firstIndex(of: "--export-incidents"), idx + 1 < args.count {
            let dest = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !dest.isEmpty else {
                print("Error: Usage: facelock --export-incidents <destinationDirectory> [--type <type>]")
                exit(1)
            }
            var filterType: String? = nil
            if let fIdx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), fIdx + 1 < args.count {
                filterType = args[fIdx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            do {
                let res = try CameraScanner.shared.exportIncidents(to: dest, filterType: filterType)
                let count = res["count"] as? Int ?? 0
                let appliedFilter = res["filter"] as? String ?? "all"
                let filterDetail = appliedFilter != "all" ? " (type: \(appliedFilter))" : ""
                SecurityAuditLogger.shared.logIncidentsAction(action: "Exported intruder incident archive via CLI", count: count, details: "Exported to \(dest)\(filterDetail)")
                if args.contains("--json") {
                    if let d = try? JSONSerialization.data(withJSONObject: res, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let totalBytes = res["totalBytes"] as? UInt64 ?? 0
                    let sizeMB = Double(totalBytes) / (1024.0 * 1024.0)
                    let filterMsg = appliedFilter != "all" ? " [Type: \(appliedFilter)]" : ""
                    print("✓ Exported \(count) intruder captures (\(String(format: "%.2f", sizeMB)) MB)\(filterMsg) to: \(dest)")
                    print("  Manifest generated at: \(res["manifestPath"] ?? "")")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting incidents: \(error.localizedDescription)")
                }
                exit(1)
            }
        } else if args.contains("--export-incidents") {
            if args.contains("--json") {
                print("{\"success\":false,\"error\":\"Usage: facelock --export-incidents <destinationDirectory> [--type <type>]\"}")
            } else {
                print("Error: Usage: facelock --export-incidents <destinationDirectory> [--type <type>]")
            }
            exit(1)
        }

        if let idx = args.firstIndex(of: "--incident"), idx + 1 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            if let rec = CameraScanner.shared.getIncidentDetails(filename: filename) {
                if args.contains("--json") {
                    var out = rec.toDictionary()
                    out["found"] = true
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let sizeKB = Double(rec.sizeBytes) / 1024.0
                    print("""
                    FaceLock Intruder Incident:
                      Filename: \(rec.filename)
                      Type: \(rec.type)
                      Timestamp: \(rec.timestamp.isEmpty ? "Unknown" : rec.timestamp)
                      Size: \(String(format: "%.1f", sizeKB)) KB
                      Path: \(rec.path)
                    """)
                }
                exit(0)
            } else {
                if args.contains("--json") {
                    print("{\"found\":false,\"error\":\"Incident '\(filename)' not found\"}")
                } else {
                    print("Error: Incident capture '\(filename)' not found.")
                }
                exit(1)
            }
        } else if args.contains("--incident") {
            if args.contains("--json") {
                print("{\"found\":false,\"error\":\"Missing incident filename. Usage: facelock --incident <filename>\"}")
            } else {
                print("Error: Missing incident filename. Usage: facelock --incident <filename>")
            }
            exit(1)
        }

        if let idx = args.firstIndex(of: "--delete-incident"), idx + 1 < args.count {
            let filename = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            let res = CameraScanner.shared.deleteIncident(filename: filename)
            if res.success {
                SecurityAuditLogger.shared.logIncidentsAction(action: "Deleted intruder capture via CLI", count: 1, details: "Deleted \(filename) (freed \(res.freedBytes) bytes)")
                if args.contains("--json") {
                    print("{\"success\":true,\"deleted\":\"\(filename)\",\"freedBytes\":\(res.freedBytes)}")
                } else {
                    let sizeKB = Double(res.freedBytes) / 1024.0
                    print("✓ Deleted intruder incident capture: \(filename) (freed \(String(format: "%.1f", sizeKB)) KB)")
                }
                exit(0)
            } else {
                let errMsg = res.error ?? "Failed to delete incident capture."
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(errMsg)\"}")
                } else {
                    print("Error: \(errMsg)")
                }
                exit(1)
            }
        } else if args.contains("--delete-incident") {
            if args.contains("--json") {
                print("{\"success\":false,\"error\":\"Missing incident filename. Usage: facelock --delete-incident <filename>\"}")
            } else {
                print("Error: Missing incident filename. Usage: facelock --delete-incident <filename>")
            }
            exit(1)
        }

        if args.contains("--logs") || args.contains("--audit") || args.contains("--audit-logs") || args.contains("--audit-search") {
            var tailCount = 20
            if let idx = args.firstIndex(of: "--tail"), idx + 1 < args.count, let val = Int(args[idx + 1]), val > 0 {
                tailCount = val
            }
            var filterType: String? = nil
            if let idx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), idx + 1 < args.count {
                filterType = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            var searchQuery: String? = nil
            if let idx = (args.firstIndex(of: "--query") ?? args.firstIndex(of: "--search")) {
                for i in (idx + 1)..<args.count {
                    if !args[i].hasPrefix("-") {
                        searchQuery = args[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        break
                    }
                }
            } else if let idx = args.firstIndex(of: "--audit-search") {
                for i in (idx + 1)..<args.count {
                    if !args[i].hasPrefix("-") {
                        searchQuery = args[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        break
                    }
                }
            }

            let events = SecurityAuditLogger.shared.searchEvents(query: searchQuery, filterType: filterType, tail: tailCount)
            let stats = SecurityAuditLogger.shared.getLogStats()

            if args.contains("--json") {
                var dict: [String: Any] = [
                    "totalLoggedEvents": stats.totalCount,
                    "retrievedCount": events.count,
                    "filter": filterType ?? "all",
                    "events": events.map { event in
                        var d: [String: Any] = [
                            "id": event.id,
                            "timestamp": event.timestamp,
                            "eventType": event.eventType,
                            "isSuccess": event.isSuccess
                        ]
                        if let app = event.appName { d["appName"] = app }
                        if let b = event.bundleId { d["bundleId"] = b }
                        if let dist = event.distance { d["distance"] = Double(dist) }
                        if let th = event.threshold { d["threshold"] = Double(th) }
                        if let photo = event.intruderPhoto { d["intruderPhoto"] = photo }
                        if let det = event.details { d["details"] = det }
                        return d
                    }
                ]
                if let q = searchQuery { dict["query"] = q }
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }

            var header = "FaceLock Security Audit Log"
            if let q = searchQuery {
                header += " (query: '\(q)')"
            }
            if let f = filterType {
                header += " (filter: '\(f)')"
            }
            header += " (showing latest \(events.count) of \(stats.totalCount) events):"
            print(header)
            if events.isEmpty {
                if let q = searchQuery, let f = filterType {
                    print("  ✓ No audit events found matching query '\(q)' and filter '\(f)'.")
                } else if let q = searchQuery {
                    print("  ✓ No audit events found matching query '\(q)'.")
                } else if let f = filterType {
                    print("  ✓ No audit events found matching filter '\(f)'.")
                } else {
                    print("  ✓ No security audit events recorded.")
                }
            } else {
                for event in events {
                    let icon: String
                    switch event.eventType {
                    case "face_verified", "wake_verified": icon = "✅"
                    case "intruder_detected", "wake_locked": icon = "🚨"
                    case "walkaway_lock": icon = "🚶"
                    case "touchid_unlocked": icon = "👆"
                    case "pin_unlocked": icon = "🔑"
                    case "pin_failed": icon = "❌"
                    case "pin_bruteforce_attempt", "pin_bruteforce_intruder": icon = "🚫"
                    case "face_retry_success": icon = "🔄✅"
                    case "face_retry_failed": icon = "🔄❌"
                    case "shield_enabled": icon = "🛡️"
                    case "shield_paused": icon = "⏸️"
                    case "policy_changed": icon = "📋"
                    case "config_changed": icon = "⚙️"
                    case "vectors_modified", "vectors_enrolled": icon = "🧬"
                    case "enrollment_cancelled": icon = "🧬⚠️"
                    case "telegram_alert_sent": icon = "📲"
                    case "telegram_alert_failed": icon = "⚠️📲"
                    case "audit_cleared", "audit_pruned", "audit_exported": icon = "🧹"
                    case "incidents_action": icon = "📸"
                    case "pin_check": icon = "🔐"
                    case "face_check": icon = "👤"
                    default: icon = event.isSuccess ? "✓" : "⚠️"
                    }

                    var line = "  [\(event.timestamp)] \(icon) \(event.eventType.uppercased())"
                    if let app = event.appName { line += " | App: \(app)" }
                    if let dist = event.distance {
                        line += " | Dist: \(String(format: "%.4f", dist))"
                        if let th = event.threshold {
                            line += " (Th: \(String(format: "%.2f", th)))"
                        }
                    }
                    if let photo = event.intruderPhoto { line += " | Photo: \(photo)" }
                    if let det = event.details { line += " | \(det)" }
                    print(line)
                }
            }
            exit(0)
        }

        if args.contains("--audit-stats") || args.contains("--log-stats") {
            let stats = SecurityAuditLogger.shared.getAuditStats()
            if args.contains("--json") {
                let dict = stats.toDictionary()
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }
            let sizeKB = Double(stats.fileSizeBytes) / 1024.0
            print("""
            FaceLock Security Audit Log Statistics:
              Total Logged Events: \(stats.totalEvents) (\(stats.successCount) success, \(stats.failureCount) failure/alert)
              Events Today: \(stats.todayCount) | Past 24h: \(stats.past24HoursCount)
              Log File Size: \(String(format: "%.2f", sizeKB)) KB (~/.facelock/audit_log.jsonl)
              Last Event Timestamp: \(stats.lastEventTime ?? "None")
            """)
            if !stats.typeBreakdown.isEmpty {
                let sortedTypes = stats.typeBreakdown.sorted { $0.value > $1.value }.prefix(6)
                print("  Top Event Types:")
                for (type, cnt) in sortedTypes {
                    print("    • \(type): \(cnt)")
                }
            }
            exit(0)
        }

        if args.contains("--audit-summary") {
            let summary = SecurityAuditLogger.shared.getAuditSummary()
            if args.contains("--json") {
                let dict = summary.toDictionary()
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let sizeKB = Double(summary.fileSizeBytes) / 1024.0
                let successPct = summary.verificationSuccessRate * 100.0
                print("""
                FaceLock Security Audit Analytical Digest:
                  Total Audit Events: \(summary.totalEvents) (\(String(format: "%.2f", sizeKB)) KB)
                  Time Span: \(String(format: "%.1f", summary.timeSpanHours)) hours (Avg \(String(format: "%.1f", summary.averageDailyEvents)) events/day)
                  Active Span: [\(summary.firstEventTime ?? "None") .. \(summary.lastEventTime ?? "None")]
                  Biometric Verification Success Rate: \(String(format: "%.1f", successPct))%
                  Successful Unlocks: \(summary.successfulVerifications)
                  Intruder / Security Breaches: \(summary.intruderDetections)
                  PIN Fallbacks: \(summary.pinUnlocks) | Touch ID Fallbacks: \(summary.touchIdUnlocks)
                  Shoulder Surfing Alerts: \(summary.shoulderSurfingIncidents)
                  Emergency Lockdowns: \(summary.emergencyLockdowns)
                  PIN Lockouts: \(summary.pinLockouts)
                """)
                if !summary.topChallengedApplications.isEmpty {
                    print("  Top Challenged Applications:")
                    let sortedApps = summary.topChallengedApplications.sorted { $0.value > $1.value }
                    for (app, count) in sortedApps {
                        print("    • \(app): \(count)")
                    }
                }
            }
            exit(0)
        }

        if args.contains("--clear-logs") || args.contains("--clear-audit") {
            let result = SecurityAuditLogger.shared.clearLogs()
            SecurityAuditLogger.shared.log(
                eventType: "audit_cleared",
                appName: "FaceLock CLI",
                details: "Purged security audit event log (\(result.deletedCount) events)",
                isSuccess: true
            )
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "deletedCount": result.deletedCount,
                    "freedSizeBytes": result.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                exit(0)
            }
            let freedKB = Double(result.freedBytes) / 1024.0
            print("✓ Cleared \(result.deletedCount) security audit events (\(String(format: "%.2f", freedKB)) KB freed).")
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--prune-logs") ?? args.firstIndex(of: "--prune-audit")), idx + 1 < args.count {
            guard let keep = Int(args[idx + 1]), keep >= 0 else {
                print("Error: Keep count must be a non-negative integer.")
                exit(1)
            }
            let res = SecurityAuditLogger.shared.pruneLogs(keeping: keep)
            SecurityAuditLogger.shared.log(
                eventType: "audit_pruned",
                appName: "FaceLock CLI",
                details: "Pruned \(res.prunedCount) older audit events (kept \(res.remainingCount))",
                isSuccess: true
            )
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "prunedCount": res.prunedCount,
                    "remainingCount": res.remainingCount,
                    "freedSizeBytes": res.freedBytes
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedKB = Double(res.freedBytes) / 1024.0
                print("✓ Pruned \(res.prunedCount) older audit log events (kept latest \(res.remainingCount), \(String(format: "%.2f", freedKB)) KB freed).")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--prune-audit-days") ?? args.firstIndex(of: "--prune-logs-days")), idx + 1 < args.count {
            guard let days = Int(args[idx + 1]), days >= 0 else {
                print("Error: Days must be a non-negative integer. Usage: facelock --prune-audit-days <days>")
                exit(1)
            }
            let res = SecurityAuditLogger.shared.pruneLogs(olderThanDays: days)
            SecurityAuditLogger.shared.log(
                eventType: "audit_pruned",
                appName: "FaceLock CLI",
                details: "Pruned \(res.prunedCount) audit events older than \(days) day(s) (kept \(res.remainingCount))",
                isSuccess: true
            )
            if args.contains("--json") {
                let dict: [String: Any] = [
                    "success": true,
                    "prunedCount": res.prunedCount,
                    "remainingCount": res.remainingCount,
                    "freedSizeBytes": res.freedBytes,
                    "days": days
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                   let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
            } else {
                let freedKB = Double(res.freedBytes) / 1024.0
                print("✓ Pruned \(res.prunedCount) audit log events older than \(days) day(s) (kept \(res.remainingCount), \(String(format: "%.2f", freedKB)) KB freed).")
            }
            exit(0)
        }

        if let idx = (args.firstIndex(of: "--export-logs") ?? args.firstIndex(of: "--export-audit")), idx + 1 < args.count {
            let destPath = args[idx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !destPath.isEmpty else {
                print("Error: Usage: facelock --export-logs <path> [--type <type>] [--format <jsonl|json|csv>]")
                exit(1)
            }
            var filterType: String? = nil
            if let fIdx = (args.firstIndex(of: "--filter") ?? args.firstIndex(of: "--type")), fIdx + 1 < args.count {
                filterType = args[fIdx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            var format: String? = nil
            if let fmtIdx = args.firstIndex(of: "--format"), fmtIdx + 1 < args.count {
                format = args[fmtIdx + 1].trimmingCharacters(in: .whitespacesAndNewlines)
            } else if args.contains("--csv") {
                format = "csv"
            }

            do {
                let res = try SecurityAuditLogger.shared.exportAudit(to: destPath, filterType: filterType, format: format)
                SecurityAuditLogger.shared.log(
                    eventType: "audit_exported",
                    appName: "FaceLock CLI",
                    details: "Exported \(res.exportedCount) security audit log events (\(res.format.uppercased())) to \(res.path)",
                    isSuccess: true
                )
                if args.contains("--json") {
                    let dict: [String: Any] = [
                        "success": true,
                        "exportedCount": res.exportedCount,
                        "path": res.path,
                        "format": res.format,
                        "fileSizeBytes": res.fileSizeBytes,
                        "filter": filterType ?? "all"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    let sizeKB = Double(res.fileSizeBytes) / 1024.0
                    let filterMsg = filterType != nil ? " [Filter: \(filterType!)]" : ""
                    print("✓ Exported \(res.exportedCount) security audit log events (\(res.format.uppercased())\(filterMsg), \(String(format: "%.2f", sizeKB)) KB) to '\(res.path)'.")
                }
                exit(0)
            } catch {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"\(error.localizedDescription)\"}")
                } else {
                    print("Error exporting audit logs: \(error.localizedDescription)")
                }
                exit(1)
            }
        }

        if args.contains("--test-telegram") {
            let token = Config.shared.telegramBotToken.trimmingCharacters(in: .whitespacesAndNewlines)
            let chatId = Config.shared.telegramChatId.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !token.isEmpty && !chatId.isEmpty else {
                if args.contains("--json") {
                    let errDict: [String: Any] = [
                        "success": false,
                        "error": "Telegram Bot Token or Chat ID not configured in ~/.facelock/config.json"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: errDict, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Telegram Bot Token or Chat ID is not configured.")
                    print("To configure, open 'facelock --settings' or edit ~/.facelock/config.json.")
                }
                exit(1)
            }

            if !args.contains("--json") {
                print("[FaceLock] Dispatching verification alert to Telegram (chat: \(chatId))...")
            }
            var done = false
            var testSuccess = false
            var testMessage = ""

            TelegramNotifier.shared.sendTestMessage(token: token, chatId: chatId) { success, msg in
                testSuccess = success
                testMessage = msg
                done = true
            }

            let timeoutDate = Date().addingTimeInterval(10.0)
            while !done && Date() < timeoutDate {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
            }

            if args.contains("--json") {
                let outDict: [String: Any] = [
                    "success": testSuccess,
                    "chatId": chatId,
                    "message": testMessage
                ]
                if let d = try? JSONSerialization.data(withJSONObject: outDict, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                if testSuccess {
                    print("✓ Telegram test notification successfully sent to chat \(chatId)!")
                } else {
                    print("⚠️ Telegram test notification failed: \(testMessage.isEmpty ? "Request timed out" : testMessage)")
                }
            }
            exit(testSuccess ? 0 : 1)
        }

        if args.contains("--verify-face") || args.contains("--test-face") {
            let camAuth = AVCaptureDevice.authorizationStatus(for: .video)
            if camAuth == .denied || camAuth == .restricted {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"Camera access is denied or restricted in System Settings\",\"exitCode\":3}")
                } else {
                    print("Error: Camera access is denied or restricted in macOS System Settings > Privacy & Security > Camera.")
                }
                exit(3)
            }

            let enrolledCount = Config.shared.loadEnrolledVectors().count
            if enrolledCount == 0 {
                if args.contains("--json") {
                    print("{\"success\":false,\"error\":\"No face templates enrolled. Run 'facelock --enroll' first.\",\"exitCode\":3}")
                } else {
                    print("Error: No enrolled face templates found. Run 'facelock --enroll' first to calibrate your face.")
                }
                exit(3)
            }

            var timeout = Config.shared.verificationTimeout
            if let idx = args.firstIndex(of: "--timeout"), idx + 1 < args.count, let val = Double(args[idx + 1]), val >= 0.5 && val <= 10.0 {
                timeout = val
            }

            let saveIntruder = args.contains("--save-intruder")
            CameraScanner.shared.autoSaveIntruders = saveIntruder

            if !args.contains("--json") {
                print("==> Initializing camera sensor and scanning face (timeout: \(timeout)s)...")
            }

            var done = false
            var matchSuccess = false
            var matchDistance: Float?
            var faceDetected = false

            CameraScanner.shared.scanFace(timeout: timeout) { success, distance, intruderImg in
                matchSuccess = success
                matchDistance = distance
                faceDetected = success || (intruderImg != nil)
                done = true
            }

            let deadline = Date().addingTimeInterval(timeout + 3.0)
            while !done && Date() < deadline {
                RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
            }

            let threshold = Config.shared.similarityThreshold

            if matchSuccess {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: true, distance: matchDistance, details: "CLI face check: Owner recognized (dist: \(matchDistance != nil ? String(format: "%.4f", matchDistance!) : "0.0000"), threshold: \(threshold))")
                let distStr = matchDistance != nil ? String(format: "%.4f", matchDistance!) : "0.0000"
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "matched": true,
                        "faceDetected": true,
                        "distance": Double(matchDistance ?? 0.0),
                        "threshold": Double(threshold),
                        "enrolledTemplates": enrolledCount,
                        "status": "owner_verified"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("✓ Face verified! Owner recognized ✅ (distance: \(distStr), threshold: \(threshold), templates: \(enrolledCount))")
                }
                exit(0)
            } else if faceDetected {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: false, distance: matchDistance, details: "CLI face check: Face does not match enrolled owner (dist: \(matchDistance != nil ? String(format: "%.4f", matchDistance!) : "N/A"), threshold: \(threshold))")
                let distStr = matchDistance != nil ? String(format: "%.4f", matchDistance!) : "N/A"
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": false,
                        "matched": false,
                        "faceDetected": true,
                        "distance": Double(matchDistance ?? 1.0),
                        "threshold": Double(threshold),
                        "enrolledTemplates": enrolledCount,
                        "status": "intruder_rejected"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("❌ Face verification failed: Face does not match enrolled owner 🛡️ (best distance: \(distStr), threshold: \(threshold))")
                }
                exit(1)
            } else {
                SecurityAuditLogger.shared.logVerificationCheck(type: "face_verification", success: false, details: "CLI face check timed out: No face detected in camera field of view")
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": false,
                        "matched": false,
                        "faceDetected": false,
                        "status": "no_face_detected",
                        "error": "No face detected in camera view within timeout"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("⚠️ Face verification timed out: No face detected in camera field of view within \(timeout)s.")
                }
                exit(2)
            }
        }

        if args.contains("--update") {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            proc.arguments = ["pull", "--rebase", "origin", "main"]
            try? proc.run()
            proc.waitUntilExit()

            print("[FaceLock] Rebuilding latest binary...")
            let buildProc = Process()
            buildProc.executableURL = URL(fileURLWithPath: "/usr/bin/make")
            buildProc.arguments = ["install"]
            try? buildProc.run()
            buildProc.waitUntilExit()
            exit(0)
        }

        if args.contains("--clear-vectors") || args.contains("--reset") {
            let clearedCount = Config.shared.clearEnrolledVectors()
            SecurityAuditLogger.shared.logVectorsCleared(count: clearedCount, details: "Reset via CLI")
            notifyDaemonIfRunning()
            if args.contains("--json") {
                let out: [String: Any] = [
                    "success": true,
                    "action": "clear-vectors",
                    "clearedCount": clearedCount,
                    "message": "All enrolled facial vector templates have been cleared"
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("[FaceLock] Cleared all enrolled faces (\(clearedCount) templates removed).")
            }
            exit(0)
        }

        if let pauseIdx = args.firstIndex(of: "--pause") {
            var mins = 15.0
            if pauseIdx + 1 < args.count, let val = Double(args[pauseIdx + 1]) {
                mins = val
            }
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "pause", "minutes": mins],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": true,
                        "shieldActive": false,
                        "pauseMinutes": mins,
                        "message": "Dispatched pause command (\(Int(mins)) min) to running instance"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Dispatched pause command (\(Int(mins)) min) to running instance.")
                }
            } else {
                Config.shared.isEnabled = false
                Config.shared.save()
                SecurityAuditLogger.shared.logShieldStateChanged(enabled: false, reason: "Protection paused offline via CLI (\(Int(mins)) min)")
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": false,
                        "shieldActive": false,
                        "pauseMinutes": mins,
                        "message": "Protection paused offline (\(Int(mins)) min)"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Protection paused offline.")
                }
            }
            exit(0)
        }

        if args.contains("--resume") || args.contains("--unpause") {
            if isAlreadyRunning {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "resume"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": true,
                        "shieldActive": true,
                        "message": "Dispatched resume command to running instance"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Dispatched resume command to running instance.")
                }
            } else {
                Config.shared.isEnabled = true
                Config.shared.save()
                SecurityAuditLogger.shared.logShieldStateChanged(enabled: true, reason: "Protection resumed offline via CLI")
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": false,
                        "shieldActive": true,
                        "message": "Protection resumed: ACTIVE 🛡️"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Protection resumed: ACTIVE 🛡️")
                }
            }
            exit(0)
        }

        if isAlreadyRunning {
            if args.contains("--lockdown") || args.contains("--emergency-lockdown") {
                Config.shared.applyProfile(.lockdown)
                TelegramNotifier.shared.sendLockdownAlert(reason: "Экстренная блокировка запущена через CLI")
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "lockdown"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "status": "lockdown_engaged",
                        "activeProfile": "lockdown",
                        "walkAwayIdleSeconds": Config.shared.walkAwayIdleSeconds,
                        "similarityThreshold": Double(Config.shared.similarityThreshold),
                        "shoulderSurfingDefense": Config.shared.shoulderSurfingDefense,
                        "audibleAlerts": Config.shared.audibleAlerts,
                        "screenLocked": true
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] 🚨 Emergency Lockdown dispatched to running instance.")
                }
                exit(0)
            } else if args.contains("--toggle") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "toggle"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": true,
                        "message": "Sent toggle signal to running instance"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Sent toggle signal to running instance.")
                }
                exit(0)
            } else if args.contains("--lock") || args.contains("--test-lock") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "lock"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    let out: [String: Any] = [
                        "success": true,
                        "daemonRunning": true,
                        "screenLocked": true,
                        "message": "Dispatched lock command to running instance"
                    ]
                    if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                       let s = String(data: d, encoding: .utf8) {
                        print(s)
                    }
                } else {
                    print("[FaceLock] Dispatched lock command to running instance.")
                }
                exit(0)
            } else if args.contains("--settings") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "settings"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Settings window via running FaceLock daemon\"}")
                } else {
                    print("[FaceLock] Dispatched settings command to running instance.")
                }
                exit(0)
            } else if args.contains("--enroll") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "enroll"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Face Enrollment wizard via running FaceLock daemon\"}")
                } else {
                    print("[FaceLock] Dispatched enrollment command to running instance.")
                }
                exit(0)
            } else if args.contains("--gallery") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "gallery"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Incident Gallery via running FaceLock daemon\"}")
                } else {
                    print("[FaceLock] Dispatched gallery command to running instance.")
                }
                exit(0)
            } else if args.contains("--audit-gui") || args.contains("--audit-ui") || args.contains("--audit-window") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "audit-log"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Security Audit window via running FaceLock daemon\"}")
                } else {
                    print("[FaceLock] Dispatched audit log command to running instance.")
                }
                exit(0)
            } else if args.contains("--apps-gui") || args.contains("--apps-window") {
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "apps-gui"],
                    deliverImmediately: true
                )
                if args.contains("--json") {
                    print("{\"success\":true,\"daemonRunning\":true,\"message\":\"Opened Applications Manager via running FaceLock daemon\"}")
                } else {
                    print("[FaceLock] Dispatched applications manager command to running instance.")
                }
                exit(0)
            } else if !args.contains("--reset") {
                let unhandledArgs = args.dropFirst().filter { $0.starts(with: "-") }
                if let unknown = unhandledArgs.first {
                    print("Error: Unrecognized option '\(unknown)'. See 'facelock --help' for available commands.")
                    exit(1)
                }
                DistributedNotificationCenter.default().postNotificationName(
                    AppDelegate.commandNotificationName,
                    object: nil,
                    userInfo: ["action": "settings"],
                    deliverImmediately: true
                )
                print("[FaceLock] Instance is already running in background (PID: \(runningApps.first?.processIdentifier ?? 0)).")
                print("[FaceLock] Dispatched settings command to running instance.")
                exit(0)
            }
        }

        // Handle offline toggle if daemon is not currently active
        if args.contains("--toggle") {
            Config.shared.isEnabled.toggle()
            Config.shared.save()
            SecurityAuditLogger.shared.logShieldStateChanged(enabled: Config.shared.isEnabled, reason: "Protection toggled offline via CLI")
            if args.contains("--json") {
                let out: [String: Any] = [
                    "success": true,
                    "daemonRunning": false,
                    "shieldActive": Config.shared.isEnabled,
                    "message": "Toggled protection state: \(Config.shared.isEnabled ? "ACTIVE" : "PAUSED")"
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
            } else {
                print("[FaceLock] Toggled protection state: \(Config.shared.isEnabled ? "ACTIVE 🛡️" : "PAUSED ⏸️")")
            }
            exit(0)
        }

        if (args.contains("--lock") || args.contains("--test-lock")) && args.contains("--json") {
            let out: [String: Any] = [
                "success": true,
                "status": "lock_screen_triggered",
                "daemonRunning": false,
                "message": "Starting standalone FaceLock lock screen"
            ]
            if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
               let s = String(data: d, encoding: .utf8) {
                print(s)
            }
            exit(0)
        }

        if args.contains("--lockdown") || args.contains("--emergency-lockdown") {
            Config.shared.applyProfile(.lockdown)
            TelegramNotifier.shared.sendLockdownAlert(reason: "Экстренная блокировка запущена через CLI")
            SecurityAuditLogger.shared.logEmergencyLockdown(details: "Emergency lockdown profile activated via CLI")
            if args.contains("--json") {
                let out: [String: Any] = [
                    "success": true,
                    "status": "lockdown_engaged",
                    "activeProfile": "lockdown",
                    "walkAwayIdleSeconds": Config.shared.walkAwayIdleSeconds,
                    "similarityThreshold": Double(Config.shared.similarityThreshold),
                    "shoulderSurfingDefense": Config.shared.shoulderSurfingDefense,
                    "audibleAlerts": Config.shared.audibleAlerts,
                    "daemonRunning": false
                ]
                if let d = try? JSONSerialization.data(withJSONObject: out, options: [.prettyPrinted, .sortedKeys]),
                   let s = String(data: d, encoding: .utf8) {
                    print(s)
                }
                exit(0)
            }
        }

        // Request camera permission if needed
        checkCameraAuthorization()

        // Setup distributed IPC listener
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleDistributedCommand(_:)),
            name: AppDelegate.commandNotificationName,
            object: nil
        )

        // Setup UI and Monitors
        StatusBarController.shared.setup()
        AppMonitor.shared.start()
        WalkAwayMonitor.shared.start()

        if args.contains("--enroll") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                EnrollmentController.shared.show()
            }
        } else if args.contains("--test-lock") || args.contains("--lock") || args.contains("--lockdown") || args.contains("--emergency-lockdown") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                LockScreenController.shared.showLock()
            }
        } else if args.contains("--settings") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SettingsController.shared.show()
            }
        } else if args.contains("--gallery") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                IncidentGalleryController.shared.show()
            }
        } else if args.contains("--audit-gui") || args.contains("--audit-ui") || args.contains("--audit-window") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AuditLogController.shared.show()
            }
        } else if args.contains("--apps-gui") || args.contains("--apps-window") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ApplicationsManagerController.shared.show()
            }
        } else if args.contains("--diagnostics-gui") || args.contains("--diagnostics-ui") || args.contains("--diagnostics-window") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DiagnosticsController.shared.show()
            }
        } else {
            let unhandledArgs = args.dropFirst().filter { $0.starts(with: "-") && $0 != "--daemon" && $0 != "--background" }
            if let unknown = unhandledArgs.first {
                print("Error: Unrecognized option '\(unknown)'. See 'facelock --help' for available commands.")
                exit(1)
            }
            if !Config.shared.hasEnrolledFace {
                print("[FaceLock] Note: No face enrolled yet. Running in face detection mode.")
                print("[FaceLock] Open Menu Bar icon -> «Запомнить моё лицо» to train your specific face.")
            }
            if !args.contains("--daemon") && !args.contains("--background") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    SettingsController.shared.show()
                }
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
        WalkAwayMonitor.shared.stop()
        AppMonitor.shared.stop()
        CameraScanner.shared.stop()
    }

    @objc private func handleDistributedCommand(_ notif: Notification) {
        guard let action = notif.userInfo?["action"] as? String else { return }
        DispatchQueue.main.async {
            switch action {
            case "settings":
                SettingsController.shared.show()
            case "enroll":
                EnrollmentController.shared.show()
            case "gallery":
                IncidentGalleryController.shared.show()
            case "audit-log", "audit", "audit-window", "audit-ui":
                AuditLogController.shared.show()
            case "apps-gui", "apps-window", "apps":
                ApplicationsManagerController.shared.show()
            case "diagnostics", "diagnostics-gui", "diagnostics-window", "diagnostics-ui":
                DiagnosticsController.shared.show()
            case "lockdown":
                StatusBarController.shared.triggerLockdown()
            case "profile", "set-profile":
                if let prof = notif.userInfo?["profile"] as? String,
                   let p = Config.SecurityProfile(rawValue: prof) {
                    Config.shared.applyProfile(p)
                    StatusBarController.shared.updateIcon()
                }
            case "toggle-shoulder":
                StatusBarController.shared.toggleShoulderSurfing()
            case "toggle-audible":
                StatusBarController.shared.toggleAudibleAlerts()
            case "toggle-battery":
                StatusBarController.shared.toggleBatteryAware()
            case "toggle-presentation":
                StatusBarController.shared.togglePresentationSuppression()
            case "lock", "test-lock":
                LockScreenController.shared.showLock()
            case "toggle":
                StatusBarController.shared.toggleEnabled()
            case "toggle-lock-on-wake":
                StatusBarController.shared.toggleLockOnWake()
            case "toggle-walkaway":
                StatusBarController.shared.toggleWalkAwayLock()
            case "pause":
                let minutes = notif.userInfo?["minutes"] as? Double ?? 15.0
                StatusBarController.shared.pauseFor(minutes: minutes)
            case "resume":
                StatusBarController.shared.resumeProtection()
            case "reload-config":
                Config.shared.reload()
                CameraScanner.shared.reconfigureDeviceIfNeeded()
                StatusBarController.shared.updateIcon()
                print("[FaceLock] Distributed reload signal received: Configuration refreshed.")
            case "reset-session":
                AppMonitor.shared.resetVerificationSession()
                print("[FaceLock] Distributed signal received: Verification session reset.")
            default:
                break
            }
        }
    }

    private func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("[FaceLock] Camera permission granted.")
                } else {
                    print("[FaceLock] Camera permission denied.")
                }
            }
        case .denied, .restricted:
            print("[FaceLock] WARNING: Camera permission is denied/restricted in System Settings!")
        case .authorized:
            print("[FaceLock] Camera authorized.")
        @unknown default:
            break
        }
    }
}
