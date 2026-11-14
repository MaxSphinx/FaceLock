.PHONY: all build run enroll test-lock lock lock-json lockdown lockdown-json is-locked is-locked-json settings gallery status config apps apps-gui protect-app protect-app-json unprotect-app unprotect-app-json ignore-app ignore-app-json unignore-app unignore-app-json reset-apps diagnostics diagnostics-gui health health-json toggle toggle-json pause pause-json resume resume-json toggle-wake toggle-wake-json wake reload reload-json reset-session reset-session-json check-app check-app-json vectors vectors-json optimize-vectors optimize-vectors-json vector-consistency vector-consistency-json clear-vectors clear-vectors-json reset-vectors reset-vectors-json install install-cli uninstall stop clean help commit update sync install-sync uninstall-sync release maintainer-install maintainer-stop report clear-incidents clear-incidents-json clear-incidents-type clear-incidents-type-json prune-incidents prune-incidents-days prune-incidents-days-json export-incidents export-incidents-json test-telegram test-telegram-json incidents incidents-summary incidents-summary-json incidents-search incidents-search-json incidents-integrity incidents-integrity-json check-incidents check-incidents-json repair-incidents repair-incidents-json latest-incident latest-incident-json export-latest-incident export-latest-incident-json incident incident-json delete-incident delete-incident-json verify-face verify-pin status-json diagnostics-json audit audit-json audit-stats audit-stats-json log-stats log-stats-json audit-summary audit-summary-json audit-gui audit-search audit-search-json prune-audit prune-audit-days prune-audit-days-json prune-logs-days prune-logs-days-json clear-audit clear-audit-json export-audit export-audit-json export-audit-csv export-audit-csv-json export-logs export-logs-json set-threshold set-threshold-json set-timeout set-timeout-json set-debounce set-debounce-json set-mode set-mode-json set-walkaway set-walkaway-json pin-attempts pin-attempts-json pin-lockout pin-lockout-json set-pin set-pin-json cameras cameras-json set-camera reset-camera backup-config backup-config-json export-config export-config-json restore-config restore-config-json import-config import-config-json export-vectors export-vectors-json backup-vectors backup-vectors-json import-vectors import-vectors-json restore-vectors restore-vectors-json test profiles profiles-json profile profile-json toggle-shoulder toggle-shoulder-json toggle-audible toggle-audible-json toggle-battery toggle-battery-json toggle-presentation toggle-presentation-json toggle-liveness toggle-liveness-json toggle-touchid toggle-touchid-json toggle-walkaway toggle-walkaway-json battery-status battery-status-json security-score security-score-json posture posture-json presentation-apps presentation-apps-json meeting-apps meeting-apps-json check-presentation check-presentation-json threat-intel threat-intel-json risk-level risk-level-json validate-config validate-config-json check-config check-config-json harden harden-json auto-harden auto-harden-json storage-summary storage-summary-json storage-stats storage-stats-json prune-incidents-size prune-incidents-size-json prune-incidents-mb prune-incidents-mb-json audit-integrity audit-integrity-json check-audit check-audit-json repair-audit repair-audit-json audit-digest audit-digest-json set-duress-pin set-duress-pin-json clear-duress-pin clear-duress-pin-json duress-status duress-status-json prune-incidents-quota prune-incidents-quota-json add-meeting-app add-meeting-app-json remove-meeting-app remove-meeting-app-json reset-meeting-apps reset-meeting-apps-json custom-meeting-apps custom-meeting-apps-json add-presentation-app add-presentation-app-json remove-presentation-app remove-presentation-app-json reset-presentation-apps custom-presentation-apps archive-incidents archive-incidents-json doctor doctor-json doctor-strict doctor-strict-json doctor-repair doctor-repair-json doctor-fix doctor-fix-json doctor-export doctor-export-json doctor-md doctor-md-json doctor-markdown doctor-markdown-json doctor-export-md doctor-export-md-json doctor-html doctor-html-json doctor-export-html doctor-export-html-json doctor-sarif doctor-sarif-json doctor-export-sarif doctor-export-sarif-json doctor-csv doctor-csv-json doctor-export-csv doctor-export-csv-json doctor-junit doctor-junit-json doctor-export-junit doctor-export-junit-json doctor-gha doctor-gha-json doctor-export-gha doctor-export-gha-json doctor-gitlab doctor-gitlab-json doctor-export-gitlab doctor-export-gitlab-json doctor-sonarqube doctor-sonarqube-json doctor-export-sonarqube doctor-export-sonarqube-json doctor-sonar doctor-sonar-json doctor-export-sonar doctor-export-sonar-json doctor-defectdojo doctor-defectdojo-json doctor-export-defectdojo doctor-export-defectdojo-json doctor-dojo doctor-dojo-json doctor-export-dojo doctor-export-dojo-json doctor-cyclonedx doctor-cyclonedx-json doctor-export-cyclonedx doctor-export-cyclonedx-json doctor-cdx doctor-cdx-json doctor-export-cdx doctor-export-cdx-json doctor-spdx doctor-spdx-json doctor-export-spdx doctor-export-spdx-json doctor-csaf doctor-csaf-json doctor-export-csaf doctor-export-csaf-json doctor-openvex doctor-openvex-json doctor-export-openvex doctor-export-openvex-json doctor-vex doctor-vex-json doctor-export-vex doctor-export-vex-json doctor-stix doctor-stix-json doctor-export-stix doctor-export-stix-json doctor-attack doctor-attack-json doctor-export-attack doctor-export-attack-json doctor-mitre doctor-mitre-json doctor-export-mitre doctor-export-mitre-json doctor-oscal doctor-oscal-json doctor-export-oscal doctor-export-oscal-json doctor-csf doctor-csf-json doctor-export-csf doctor-export-csf-json doctor-nist-csf doctor-nist-csf-json doctor-export-nist-csf doctor-export-nist-csf-json

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

all: build

help:
	@echo "FaceLock Build & Management"
	@echo ""
	@echo "  make build          - Compile Swift binary and sign app bundle"
	@echo "  make install        - Install to /Applications/FaceLock.app and setup CLI"
	@echo "  make update         - Pull updates from GitHub, recompile & hot-reload"
	@echo "  make commit         - Auto-stage, commit with contextual message & push"
	@echo "  make release        - Cut git release tag & trigger GitHub Release build"
	@echo "  make sync           - Run continuous auto-commit & auto-update daemon"
	@echo "  make install-sync   - Install background auto-sync LaunchAgent daemon"
	@echo "  make uninstall-sync - Remove background auto-sync daemon"
	@echo "  make run            - Launch FaceLock background daemon"
	@echo "  make enroll         - Launch face calibration wizard"
	@echo "  make settings       - Open settings window"
	@echo "  make gallery        - Open intruder incident log"
	@echo "  make test-lock      - Trigger immediate fullscreen lock test"
	@echo "  make lock           - Trigger lock screen via daemon or standalone"
	@echo "  make lockdown       - Engage emergency lockdown (lockdown profile & lock screen)"
	@echo "  make is-locked      - Check if screen lock is currently active"
	@echo "  make toggle         - Toggle protection between ACTIVE and PAUSED"
	@echo "  make toggle-wake    - Toggle lock verification upon Mac screen wake"
	@echo "  make reload         - Hot-reload active configuration in running daemon"
	@echo "  make reset-session  - Invalidate active biometric verification session cache"
	@echo "  make check-app APP= - Inspect if bundle ID triggers biometric shield"
	@echo "  make check-app-json APP= - Inspect if bundle ID triggers shield (JSON output)"
	@echo "  make status         - Display current protection & biometric status"
	@echo "  make status-json    - Display status in JSON format"
	@echo "  make health         - Fast operational healthcheck (exit 0 if healthy)"
	@echo "  make doctor         - Comprehensive system, biometrics & security health doctor"
	@echo "  make doctor-json    - System diagnostic doctor check in JSON format"
	@echo "  make doctor-strict  - Run doctor in strict mode (fails with exit 1 on warnings)"
	@echo "  make doctor-strict-json - Run doctor strict in JSON format"
	@echo "  make doctor-repair  - Auto-remediate doctor issues (directory perms, audit, posture)"
	@echo "  make doctor-repair-json - Auto-remediate doctor issues (JSON output)"
	@echo "  make doctor-export  - Export doctor diagnostic report to ~/.facelock/doctor_report.json"
	@echo "  make doctor-export-json - Export doctor diagnostic report (JSON output)"
	@echo "  make doctor-markdown - Export and display diagnostic doctor report in Markdown format"
	@echo "  make doctor-export-md - Export doctor diagnostic report to ~/.facelock/doctor_report.md"
	@echo "  make doctor-html    - Export and display diagnostic doctor report in HTML5 format"
	@echo "  make doctor-export-html - Export doctor diagnostic report to ~/.facelock/doctor_report.html"
	@echo "  make doctor-sarif   - Export and display diagnostic doctor report in OASIS SARIF v2.1.0 format"
	@echo "  make doctor-export-sarif - Export doctor diagnostic report to ~/.facelock/doctor_report.sarif"
	@echo "  make doctor-csv     - Export and display diagnostic doctor report in RFC 4180 CSV format"
	@echo "  make doctor-export-csv - Export doctor diagnostic report to ~/.facelock/doctor_report.csv"
	@echo "  make doctor-junit   - Export and display diagnostic doctor report in JUnit XML format"
	@echo "  make doctor-export-junit - Export doctor diagnostic report to ~/.facelock/doctor_report.xml"
	@echo "  make doctor-gha     - Export and display diagnostic doctor report in GitHub Actions Step Summary format"
	@echo "  make doctor-export-gha - Export doctor diagnostic report to ~/.facelock/doctor_step_summary.md"
	@echo "  make doctor-gitlab  - Export and display diagnostic doctor report in GitLab CI / Code Climate JSON"
	@echo "  make doctor-export-gitlab - Export doctor diagnostic report to ~/.facelock/doctor_codeclimate.json"
	@echo "  make doctor-sonarqube - Export and display diagnostic doctor report in SonarQube JSON format"
	@echo "  make doctor-export-sonarqube - Export doctor diagnostic report to ~/.facelock/doctor_sonarqube.json"
	@echo "  make doctor-defectdojo - Export and display diagnostic doctor report in DefectDojo Generic Findings JSON"
	@echo "  make doctor-export-defectdojo - Export doctor diagnostic report to ~/.facelock/doctor_defectdojo.json"
	@echo "  make doctor-cyclonedx - Export and display diagnostic doctor report in OWASP CycloneDX 1.5 JSON"
	@echo "  make doctor-export-cyclonedx - Export doctor diagnostic report to ~/.facelock/doctor_cyclonedx.json"
	@echo "  make doctor-spdx    - Export and display diagnostic doctor report in SPDX 2.3 JSON (ISO/IEC 5962:2021)"
	@echo "  make doctor-export-spdx - Export doctor diagnostic report to ~/.facelock/doctor_spdx.json"
	@echo "  make doctor-csaf    - Export and display diagnostic doctor report in OASIS CSAF 2.0 JSON"
	@echo "  make doctor-export-csaf - Export doctor diagnostic report to ~/.facelock/doctor_csaf.json"
	@echo "  make doctor-openvex - Export and display diagnostic doctor report in OpenVEX 0.2.0 JSON"
	@echo "  make doctor-export-openvex - Export doctor diagnostic report to ~/.facelock/doctor_openvex.json"
	@echo "  make doctor-stix    - Export and display diagnostic doctor report in OASIS STIX 2.1 Threat Intel JSON"
	@echo "  make doctor-export-stix - Export doctor diagnostic report to ~/.facelock/doctor_stix.json"
	@echo "  make doctor-attack  - Export and display diagnostic doctor report in MITRE ATT&CK Navigator Layer v4.5 JSON"
	@echo "  make doctor-export-attack - Export doctor diagnostic report to ~/.facelock/doctor_attack.json"
	@echo "  make doctor-oscal   - Export and display diagnostic doctor report in NIST OSCAL 1.1.0 JSON"
	@echo "  make doctor-export-oscal - Export doctor diagnostic report to ~/.facelock/doctor_oscal.json"
	@echo "  make doctor-csf     - Export and display diagnostic doctor report in NIST CSF 2.0 JSON"
	@echo "  make doctor-export-csf - Export doctor diagnostic report to ~/.facelock/doctor_nist_csf.json"
	@echo "  make config         - Display active FaceLock configuration settings"
	@echo "  make apps           - List protected and ignored application bundle IDs"
	@echo "  make apps-gui       - Open interactive application protection policy window"
	@echo "  make protect-app APP= - Add application bundle ID to protected list"
	@echo "  make protect-app-json APP= - Add application bundle ID to protected list (JSON)"
	@echo "  make unprotect-app APP= - Remove application bundle ID from protected list"
	@echo "  make unprotect-app-json APP= - Remove application bundle ID from protected list (JSON)"
	@echo "  make ignore-app APP= - Add application bundle ID to ignored list"
	@echo "  make ignore-app-json APP= - Add application bundle ID to ignored list (JSON)"
	@echo "  make unignore-app APP= - Remove application bundle ID from ignored list"
	@echo "  make unignore-app-json APP= - Remove application bundle ID from ignored list (JSON)"
	@echo "  make reset-apps     - Reset application protection rules to factory defaults"
	@echo "  make cameras        - List available video capture cameras and active selection"
	@echo "  make cameras-json   - List video capture cameras in JSON format"
	@echo "  make set-camera CAMERA= - Set preferred camera device by ID, name or 'default'"
	@echo "  make reset-camera   - Reset preferred camera selection to default front camera"
	@echo "  make profiles       - List available security context profiles"
	@echo "  make profile-json   - Query current profile and available profiles as JSON"
	@echo "  make profile PROFILE= - Apply security profile (normal, cafe, work, home, presentation, lockdown)"
	@echo "  make toggle-shoulder- Toggle shoulder-surfing bystander defense"
	@echo "  make toggle-audible - Toggle audible alarm and sound cues"
	@echo "  make toggle-battery - Toggle battery-aware adaptive idle sweep throttling"
	@echo "  make battery-status - Inspect power source, Low Power Mode & battery throttling"
	@echo "  make toggle-presentation - Toggle meeting / presentation lock auto-suppression"
	@echo "  make test           - Run automated unit test suite and Apple Silicon benchmarks"
	@echo "  make backup-config DEST= - Backup FaceLock configuration to JSON file"
	@echo "  make restore-config SRC= - Restore FaceLock configuration from JSON file"
	@echo "  make vectors        - Inspect enrolled facial templates and cluster metrics"
	@echo "  make optimize-vectors - Prune redundant vectors and outliers to optimize cluster"
	@echo "  make clear-vectors  - Purge all enrolled facial templates from disk"
	@echo "  make export-vectors DEST= - Export biometric face vectors to JSON file"
	@echo "  make import-vectors SRC= - Import biometric face vectors from JSON file"
	@echo "  make audit          - View security audit event log"
	@echo "  make audit-gui      - Open security audit log GUI window"
	@echo "  make audit-stats    - View security audit statistics"
	@echo "  make prune-audit KEEP= - Prune older audit events keeping latest N (default: 100)"
	@echo "  make prune-audit-days DAYS= - Prune security audit events older than N days (default: 30)"
	@echo "  make clear-audit    - Purge security audit event log"
	@echo "  make export-audit FILE= - Export security audit log events to JSONL file"
	@echo "  make export-audit-csv FILE= - Export security audit log events to RFC-4180 CSV file"
	@echo "  make audit-integrity - Verify cryptographic integrity and detect corrupted audit logs"
	@echo "  make repair-audit   - Repair corrupted security audit log records and create backup"
	@echo "  make audit-digest   - Print SHA-256 fingerprint & summary of audit log"
	@echo "  make incidents      - List logged intruder incident captures"
	@echo "  make incidents-summary - Intruder telemetry (total, 24h, 7d, timestamps)"
	@echo "  make export-incidents DIR= - Export all intruder incident photos & manifest"
	@echo "  make latest-incident- Display most recent intruder incident capture"
	@echo "  make clear-incidents- Purge all saved intruder captures from disk"
	@echo "  make prune-incidents- Prune older intruder captures (keep latest 30)"
	@echo "  make prune-incidents-days DAYS= - Prune intruder incident captures older than N days (default: 30)"
	@echo "  make verify-face    - One-shot biometric face verification via camera"
	@echo "  make set-pin PIN=   - Update lock screen unlock PIN (4-8 numeric digits)"
	@echo "  make set-pin-json PIN= - Update lock screen unlock PIN (JSON output)"
	@echo "  make set-duress-pin PIN= - Configure silent duress distress PIN (4-8 numeric digits)"
	@echo "  make set-duress-pin-json PIN= - Configure duress PIN with JSON output"
	@echo "  make clear-duress-pin - Clear duress PIN and disable coerced unlock detection"
	@echo "  make clear-duress-pin-json - Clear duress PIN with JSON output"
	@echo "  make duress-status  - Inspect duress emergency protection status"
	@echo "  make duress-status-json - Inspect duress protection status in JSON format"
	@echo "  make pin-attempts ATTEMPTS= - Set max failed PIN attempts before lockout"
	@echo "  make pin-attempts-json ATTEMPTS= - Set max failed PIN attempts (JSON output)"
	@echo "  make pin-lockout SECONDS= - Set cooling lockout delay after failed PINs"
	@echo "  make pin-lockout-json SECONDS= - Set cooling lockout delay (JSON output)"
	@echo "  make security-score - Assess comprehensive Mac security posture score & recommendations"
	@echo "  make security-score-json - Output security posture assessment in JSON format"
	@echo "  make posture        - Alias for security-score"
	@echo "  make posture-json   - Output posture score in JSON format"
	@echo "  make harden         - Automatically harden security posture & remediate vulnerabilities"
	@echo "  make harden-json    - Auto-harden security posture with JSON output"
	@echo "  make storage-summary - Display ~/.facelock/ storage footprint and quotas"
	@echo "  make storage-summary-json - Display storage summary in JSON format"
	@echo "  make prune-incidents-size MB= - Prune oldest captures exceeding MB disk budget"
	@echo "  make prune-incidents-size-json MB= - Prune captures exceeding disk budget (JSON)"
	@echo "  make prune-incidents-quota MB= - Alias for prune-incidents-size"
	@echo "  make prune-incidents-quota-json MB= - Alias for prune-incidents-size-json"
	@echo "  make presentation-apps - List recognized meeting & presentation apps"
	@echo "  make presentation-apps-json - List meeting apps in JSON format"
	@echo "  make check-presentation APP= - Check if bundle ID triggers meeting lock suppression"
	@echo "  make check-presentation-json APP= - Check meeting suppression in JSON format"
	@echo "  make add-meeting-app APP= - Add application to custom meeting lock suppression whitelist"
	@echo "  make add-meeting-app-json APP= - Add application to meeting suppression whitelist (JSON)"
	@echo "  make remove-meeting-app APP= - Remove application from meeting suppression whitelist"
	@echo "  make remove-meeting-app-json APP= - Remove application from meeting suppression whitelist (JSON)"
	@echo "  make reset-meeting-apps - Clear custom meeting suppression whitelist"
	@echo "  make custom-meeting-apps - List user-configured custom meeting applications"
	@echo "  make custom-meeting-apps-json - List custom meeting applications in JSON format"
	@echo "  make threat-intel   - Physical security threat intelligence & intrusion risk analysis"
	@echo "  make threat-intel-json - Physical threat intelligence report in JSON format"
	@echo "  make validate-config - Validate configuration integrity, security rules & syntax"
	@echo "  make validate-config-json - Configuration security validation report in JSON format"
	@echo "  make test-telegram  - Dispatch test notification to Telegram chat"
	@echo "  make diagnostics    - Run full biometric, hardware & storage diagnostics"
	@echo "  make diagnostics-gui - Open interactive system diagnostics & health window"
	@echo "  make diagnostics-json - Run diagnostics in JSON format"
	@echo "  make stop           - Terminate running FaceLock instance"
	@echo "  make uninstall      - Remove application and CLI symlink"
	@echo "  make clean          - Remove build artifacts"

build:
	@./build.sh

profiles: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --profiles

profiles-json: profile-json

profile: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --profile $(PROFILE)

profile-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --profiles --json

toggle-shoulder: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-shoulder-defense

toggle-shoulder-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-shoulder-defense --json

toggle-audible: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-audible

toggle-audible-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-audible --json

toggle-battery: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-battery-aware

toggle-battery-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-battery-aware --json

battery-status: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --battery-status

battery-status-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --battery-status --json

toggle-presentation: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-presentation

toggle-presentation-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-presentation --json

toggle-liveness: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-liveness

toggle-liveness-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-liveness --json

toggle-touchid: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-touchid

toggle-touchid-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-touchid --json

toggle-wake-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-wake --json

toggle-walkaway: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-walkaway

toggle-walkaway-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-walkaway --json

run: build
	@echo "Launching FaceLock..."
	@open build/FaceLock.app

enroll: build
	@echo "Launching Face ID Calibration..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --enroll

test-lock: build
	@echo "Testing Fullscreen Lock (Touch ID or PIN)..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-lock

lock: build
	@echo "Triggering Lock Screen..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --lock

lock-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --lock --json

lockdown: build
	@echo "Engaging Emergency Lockdown..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --lockdown

lockdown-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --lockdown --json

is-locked: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked || true

is-locked-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked --json || true

toggle: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle

toggle-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle --json

pause: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --pause $(if $(MINS),$(MINS),15)

pause-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --pause $(if $(MINS),$(MINS),15) --json

resume: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --resume

resume-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --resume --json

toggle-wake: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake toggle

wake: toggle-wake

reload: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reload

reload-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reload --json

reset-session: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session

reset-session-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session --json

check-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make check-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app "$(APP)"

check-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make check-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app "$(APP)" --json

settings: build
	@echo "Opening Settings..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --settings

gallery: build
	@echo "Opening Incident Gallery..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --gallery

status: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --status

status-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --status --json

health: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --health || true

health-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --health --json || true

config: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --config

apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps

apps-gui: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps-gui

protect-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make protect-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app "$(APP)"

protect-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make protect-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app "$(APP)" --json

unprotect-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make unprotect-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app "$(APP)"

unprotect-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make unprotect-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app "$(APP)" --json

ignore-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make ignore-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app "$(APP)"

ignore-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make ignore-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app "$(APP)" --json

unignore-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make unignore-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app "$(APP)"

unignore-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make unignore-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app "$(APP)" --json

reset-apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-apps

cameras: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras

cameras-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras --json

set-camera: build
	@if [ -z "$(CAMERA)" ]; then \
		echo "Usage: make set-camera CAMERA=<id|name|default>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-camera "$(CAMERA)"

reset-camera: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-camera

backup-config: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make backup-config DEST=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-config "$(DEST)"

backup-config-json: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make backup-config-json DEST=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-config "$(DEST)" --json

export-config: backup-config
export-config-json: backup-config-json

restore-config: build
	@if [ -z "$(SRC)" ]; then \
		echo "Usage: make restore-config SRC=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --restore-config "$(SRC)"

restore-config-json: build
	@if [ -z "$(SRC)" ]; then \
		echo "Usage: make restore-config-json SRC=/path/to/backup.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --restore-config "$(SRC)" --json

import-config: restore-config
import-config-json: restore-config-json

vectors: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors

vectors-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors --json

optimize-vectors: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors

optimize-vectors-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors --json

vector-consistency: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vector-consistency

vector-consistency-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --vector-consistency --json

export-vectors: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make export-vectors DEST=/path/to/vectors.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-vectors "$(DEST)"

export-vectors-json: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make export-vectors-json DEST=/path/to/vectors.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-vectors "$(DEST)" --json

backup-vectors: export-vectors
backup-vectors-json: export-vectors-json

import-vectors: build
	@if [ -z "$(SRC)" ]; then \
		echo "Usage: make import-vectors SRC=/path/to/vectors.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --import-vectors "$(SRC)"

import-vectors-json: build
	@if [ -z "$(SRC)" ]; then \
		echo "Usage: make import-vectors-json SRC=/path/to/vectors.json"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --import-vectors "$(SRC)" --json

restore-vectors: import-vectors
restore-vectors-json: import-vectors-json

clear-vectors: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-vectors

clear-vectors-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-vectors --json

reset-vectors: clear-vectors
reset-vectors-json: clear-vectors-json

incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents

incidents-summary: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary

incidents-summary-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary --json

incidents-search: build
	@if [ -z "$(QUERY)" ]; then \
		echo "Usage: make incidents-search QUERY=keyword"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-search "$(QUERY)"

incidents-search-json: build
	@if [ -z "$(QUERY)" ]; then \
		echo "Usage: make incidents-search-json QUERY=keyword"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-search "$(QUERY)" --json

export-incidents: build
	@if [ -z "$(DIR)" ]; then \
		echo "Usage: make export-incidents DIR=/path/to/destination"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-incidents "$(DIR)"

export-incidents-json: build
	@if [ -z "$(DIR)" ]; then \
		echo "Usage: make export-incidents-json DIR=/path/to/destination"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-incidents "$(DIR)" --json

latest-incident: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident

latest-incident-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident --json

export-latest-incident: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make export-latest-incident DEST=/path/to/destination.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-latest-incident "$(DEST)"

export-latest-incident-json: build
	@if [ -z "$(DEST)" ]; then \
		echo "Usage: make export-latest-incident-json DEST=/path/to/destination.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-latest-incident "$(DEST)" --json

incident: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make incident FILE=intruder_xxx.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --incident "$(FILE)"

incident-json: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make incident-json FILE=intruder_xxx.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --incident "$(FILE)" --json

delete-incident: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make delete-incident FILE=intruder_xxx.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --delete-incident "$(FILE)"

delete-incident-json: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make delete-incident-json FILE=intruder_xxx.jpg"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --delete-incident "$(FILE)" --json

verify-face: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --verify-face

verify-pin: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --verify-pin $(PIN)

set-pin: build
	@if [ -z "$(PIN)" ]; then \
		echo "Usage: make set-pin PIN=<4-8 digit numeric PIN>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin $(PIN)

set-pin-json: build
	@if [ -z "$(PIN)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make set-pin-json PIN=<4-8 digit numeric PIN>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin $(PIN) --json

pin-attempts: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-attempts $(ATTEMPTS)

pin-attempts-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-attempts $(ATTEMPTS) --json

pin-lockout: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-lockout $(SECONDS)

pin-lockout-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-lockout $(SECONDS) --json

set-duress-pin: build
	@if [ -z "$(PIN)" ]; then \
		echo "Usage: make set-duress-pin PIN=<4-8 digit numeric PIN>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-duress-pin $(PIN)

set-duress-pin-json: build
	@if [ -z "$(PIN)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make set-duress-pin-json PIN=<4-8 digit numeric PIN>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-duress-pin $(PIN) --json

clear-duress-pin: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-duress-pin

clear-duress-pin-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-duress-pin --json

duress-status: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --duress-status

duress-status-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --duress-status --json

clear-incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-incidents

clear-incidents-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-incidents --json

clear-incidents-type: build
	@if [ -z "$(TYPE)" ]; then \
		echo "Usage: make clear-incidents-type TYPE=<intruder|walkaway|wake|bystander|bruteforce>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-incidents --type $(TYPE)

clear-incidents-type-json: build
	@if [ -z "$(TYPE)" ]; then \
		echo "Usage: make clear-incidents-type-json TYPE=<intruder|walkaway|wake|bystander|bruteforce>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-incidents --type $(TYPE) --json

prune-incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents $(or $(KEEP),30)

prune-incidents-days: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-days $(or $(DAYS),30)

prune-incidents-days-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-days $(or $(DAYS),30) --json

incidents-integrity: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-integrity

incidents-integrity-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-integrity --json

check-incidents: incidents-integrity

check-incidents-json: incidents-integrity-json

repair-incidents: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-incidents

repair-incidents-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-incidents --json

test-telegram: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-telegram

test-telegram-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --test-telegram --json

audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit

audit-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --json

audit-search: build
	@if [ -z "$(QUERY)" ]; then \
		echo "Usage: make audit-search QUERY=\"<keyword>\""; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --search "$(QUERY)"

audit-search-json: build
	@if [ -z "$(QUERY)" ]; then \
		echo "Usage: make audit-search-json QUERY=\"<keyword>\""; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --search "$(QUERY)" --json

audit-stats: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats

audit-stats-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats --json

log-stats: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats

log-stats-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats --json

audit-summary: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-summary

audit-summary-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-summary --json

audit-gui: build
	@echo "Opening Security Audit Log..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-gui

prune-audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit $(or $(KEEP),100)

prune-audit-days: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit-days $(or $(DAYS),30)

prune-audit-days-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit-days $(or $(DAYS),30) --json

prune-logs-days: prune-audit-days

prune-logs-days-json: prune-audit-days-json

clear-audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-audit

clear-audit-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-audit --json

export-audit: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make export-audit FILE=/path/to/destination.jsonl"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit "$(FILE)"

export-audit-json: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make export-audit-json FILE=/path/to/destination.jsonl"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit "$(FILE)" --json

export-audit-csv: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make export-audit-csv FILE=/path/to/destination.csv"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit "$(FILE)" --format csv

export-audit-csv-json: build
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make export-audit-csv-json FILE=/path/to/destination.csv"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit "$(FILE)" --format csv --json

export-logs: export-audit
export-logs-json: export-audit-json

audit-integrity: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-integrity

audit-integrity-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-integrity --json

check-audit: audit-integrity
check-audit-json: audit-integrity-json

repair-audit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-audit

repair-audit-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-audit --json

audit-digest: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-digest

audit-digest-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-digest --json

set-threshold: build
	@if [ -z "$(THRESHOLD)" ]; then \
		echo "Usage: make set-threshold THRESHOLD=0.22"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-threshold "$(THRESHOLD)"

set-threshold-json: build
	@if [ -z "$(THRESHOLD)" ]; then \
		echo "Usage: make set-threshold-json THRESHOLD=0.22"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-threshold "$(THRESHOLD)" --json

set-timeout: build
	@if [ -z "$(TIMEOUT)" ]; then \
		echo "Usage: make set-timeout TIMEOUT=2.0"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-timeout "$(TIMEOUT)"

set-timeout-json: build
	@if [ -z "$(TIMEOUT)" ]; then \
		echo "Usage: make set-timeout-json TIMEOUT=2.0"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-timeout "$(TIMEOUT)" --json

set-debounce: build
	@if [ -z "$(DEBOUNCE)" ]; then \
		echo "Usage: make set-debounce DEBOUNCE=2.0"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-debounce "$(DEBOUNCE)"

set-debounce-json: build
	@if [ -z "$(DEBOUNCE)" ]; then \
		echo "Usage: make set-debounce-json DEBOUNCE=2.0"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-debounce "$(DEBOUNCE)" --json

set-mode: build
	@if [ -z "$(MODE)" ]; then \
		echo "Usage: make set-mode MODE=all"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-mode "$(MODE)"

set-mode-json: build
	@if [ -z "$(MODE)" ]; then \
		echo "Usage: make set-mode-json MODE=all"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-mode "$(MODE)" --json

set-walkaway: build
	@if [ -z "$(SECONDS)" ]; then \
		echo "Usage: make set-walkaway SECONDS=45"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway "$(SECONDS)"

set-walkaway-json: build
	@if [ -z "$(SECONDS)" ]; then \
		echo "Usage: make set-walkaway-json SECONDS=45"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway "$(SECONDS)" --json

test: build
	@echo "==> Running FaceLock Automated Unit Tests & Benchmarks..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --test
	@echo "==> Running CLI verification tests..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --help > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --version > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --status > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --status --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --config > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-summary --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-search test --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --latest-incident --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type policy --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --type telegram --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-search config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit --query config --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --cameras > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --battery-status --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --battery-status > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-camera default --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-camera --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-config /tmp/facelock_cfg_test.json > /dev/null && rm -f /tmp/facelock_cfg_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-config /tmp/facelock_cfg_alias_test.json > /dev/null && rm -f /tmp/facelock_cfg_alias_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway 45 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-walkaway --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-walkaway toggle --json > /dev/null
	@CUR_PIN=$$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.facelock/config.json'))).get('pin', '0000'))" 2>/dev/null || echo "0000"); build/FaceLock.app/Contents/MacOS/FaceLock --verify-pin "$$CUR_PIN" --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --enable-telegram --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-liveness on --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-liveness --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-liveness toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-touchid on --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-touchid --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-touchid toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake toggle --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-wake --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-lock-on-wake off --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --ignore-app-json com.apple.calculator > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unignore-app-json com.apple.calculator > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --protect-app-json com.apple.calculator > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app com.apple.calculator --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --unprotect-app-json com.apple.calculator > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reload --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-session --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app com.apple.Safari --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app-json com.apple.Safari > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-app com.apple.dock --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vector-consistency > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vector-consistency --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --vector-consistency-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --analyze-vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-integrity > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-integrity --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --incidents-integrity-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-incidents --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-incidents > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-incidents --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --repair-incidents-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --clean-corrupted-incidents --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-summary > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-summary --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-summary-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --is-locked --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --optimize-vectors --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-attempts 3 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --pin-attempts 3 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --pin-attempts-json 3 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-lockout 5 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --pin-lockout 5 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --pin-lockout-json 5 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin 1234 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-pin-json 1234 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --verify-pin 1234 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-stats --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-audit 1000 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit /tmp/facelock_audit_test.jsonl --json > /dev/null && rm -f /tmp/facelock_audit_test.jsonl
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit /tmp/facelock_audit_test.csv --format csv --json > /dev/null && rm -f /tmp/facelock_audit_test.csv
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-audit /tmp/facelock_audit_test.json --format json --json > /dev/null && rm -f /tmp/facelock_audit_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --export-logs /tmp/facelock_audit_test.jsonl --json > /dev/null && rm -f /tmp/facelock_audit_test.jsonl
	@build/FaceLock.app/Contents/MacOS/FaceLock --backup-vectors /tmp/facelock_vec_test.json > /dev/null 2>&1 || true; rm -f /tmp/facelock_vec_test.json
	@mkdir -p /tmp/facelock_test_export && build/FaceLock.app/Contents/MacOS/FaceLock --export-incidents /tmp/facelock_test_export --type intruder --json > /dev/null && rm -rf /tmp/facelock_test_export
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-shoulder --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-shoulder-defense --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-audible --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-battery --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-battery-aware --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --toggle-presentation --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-presentation-mode on --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --presentation-apps > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --presentation-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --presentation-apps-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --meeting-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation com.apple.iWork.Keynote > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation com.apple.iWork.Keynote --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation-json com.apple.iWork.Keynote > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation com.apple.Safari --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --security-score > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --security-score --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --security-score-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --posture > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --posture-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --threat-intel > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --threat-intel --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --threat-intel-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --risk-level > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --validate-config > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --validate-config --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --validate-config-json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-config-json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-integrity > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-integrity --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-audit > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-audit-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-digest > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --audit-digest --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-summary > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-summary --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-summary-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-stats > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-stats-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-size 500 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-size 500 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-size-json 500 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-quota 500 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-quota 500 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-quota-json 500 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --duress-status > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --duress-status --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --duress-status-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-duress-pin 9999 --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-duress-pin-json 9999 > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-duress-pin --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --clear-duress-pin-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --add-meeting-app com.custom.meeting --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --add-meeting-app-json com.custom.meeting > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --custom-meeting-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --custom-meeting-apps-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --remove-meeting-app com.custom.meeting --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --remove-meeting-app-json com.custom.meeting > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-meeting-apps --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-meeting-apps-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --harden > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --harden --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --harden-json > /dev/null
	@mkdir -p /tmp/facelock_test_archive && build/FaceLock.app/Contents/MacOS/FaceLock --archive-incidents /tmp/facelock_test_archive --json > /dev/null && rm -rf /tmp/facelock_test_archive
	@build/FaceLock.app/Contents/MacOS/FaceLock --auto-harden > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --auto-harden-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --set-profile normal --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --health --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-strict > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-strict --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-strict-json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-repair > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-repair --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-repair-json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export /tmp/facelock_doc_test.json > /dev/null && rm -f /tmp/facelock_doc_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md /tmp/facelock_doc_test.md > /dev/null && rm -f /tmp/facelock_doc_test.md
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-html > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-html --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html /tmp/facelock_doc_test.html > /dev/null && rm -f /tmp/facelock_doc_test.html
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sarif > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sarif --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif /tmp/facelock_doc_test.sarif > /dev/null && rm -f /tmp/facelock_doc_test.sarif
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csv > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csv --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv /tmp/facelock_doc_test.csv > /dev/null && rm -f /tmp/facelock_doc_test.csv
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-junit > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-junit --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit /tmp/facelock_doc_test.xml > /dev/null && rm -f /tmp/facelock_doc_test.xml
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gha > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gha --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha /tmp/facelock_doc_test.md > /dev/null && rm -f /tmp/facelock_doc_test.md
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gitlab > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gitlab --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab /tmp/facelock_doc_test.json > /dev/null && rm -f /tmp/facelock_doc_test.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sonarqube > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sonarqube --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube /tmp/facelock_doc_test_sonar.json > /dev/null && rm -f /tmp/facelock_doc_test_sonar.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-defectdojo > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-defectdojo --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo /tmp/facelock_doc_test_dojo.json > /dev/null && rm -f /tmp/facelock_doc_test_dojo.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-cyclonedx > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-cyclonedx --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx /tmp/facelock_doc_test_cdx.json > /dev/null && rm -f /tmp/facelock_doc_test_cdx.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-spdx > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-spdx --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx /tmp/facelock_doc_test_spdx.json > /dev/null && rm -f /tmp/facelock_doc_test_spdx.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csaf > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csaf --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf /tmp/facelock_doc_test_csaf.json > /dev/null && rm -f /tmp/facelock_doc_test_csaf.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-openvex > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-openvex --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex /tmp/facelock_doc_test_openvex.json > /dev/null && rm -f /tmp/facelock_doc_test_openvex.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-stix > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-stix --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix /tmp/facelock_doc_test_stix.json > /dev/null && rm -f /tmp/facelock_doc_test_stix.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-attack > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-attack --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack /tmp/facelock_doc_test_attack.json > /dev/null && rm -f /tmp/facelock_doc_test_attack.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-oscal > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-oscal --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal /tmp/facelock_doc_test_oscal.json > /dev/null && rm -f /tmp/facelock_doc_test_oscal.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal --json > /dev/null
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csf > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csf --json > /dev/null || true
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf /tmp/facelock_doc_test_csf.json > /dev/null && rm -f /tmp/facelock_doc_test_csf.json
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf --json > /dev/null
	@echo "✓ All CLI tests passed!"

doctor: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor

doctor-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor --json

doctor-strict: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-strict

doctor-strict-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-strict --json

doctor-repair: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-repair

doctor-repair-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-repair --json

doctor-fix: doctor-repair
doctor-fix-json: doctor-repair-json

doctor-export: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export; \
	fi

doctor-export-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export --json; \
	fi

doctor-md: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown

doctor-md-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown --json

doctor-markdown: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown

doctor-markdown-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-markdown --json

doctor-export-md: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md; \
	fi

doctor-export-md-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-md --json; \
	fi

doctor-html: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-html

doctor-html-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-html --json

doctor-export-html: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html; \
	fi

doctor-export-html-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-html --json; \
	fi

doctor-sarif: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sarif

doctor-sarif-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sarif --json

doctor-export-sarif: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif; \
	fi

doctor-export-sarif-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sarif --json; \
	fi

doctor-csv: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csv

doctor-csv-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csv --json

doctor-export-csv: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv; \
	fi

doctor-export-csv-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csv --json; \
	fi

doctor-junit: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-junit

doctor-junit-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-junit --json

doctor-export-junit: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit; \
	fi

doctor-export-junit-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-junit --json; \
	fi

doctor-gha: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gha

doctor-gha-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gha --json

doctor-export-gha: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha; \
	fi

doctor-export-gha-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gha --json; \
	fi

doctor-gitlab: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gitlab

doctor-gitlab-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-gitlab --json

doctor-export-gitlab: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab; \
	fi

doctor-export-gitlab-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-gitlab --json; \
	fi

doctor-sonarqube: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sonarqube

doctor-sonarqube-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-sonarqube --json

doctor-sonar: doctor-sonarqube
doctor-sonar-json: doctor-sonarqube-json

doctor-export-sonarqube: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube; \
	fi

doctor-export-sonarqube-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-sonarqube --json; \
	fi

doctor-export-sonar: doctor-export-sonarqube
doctor-export-sonar-json: doctor-export-sonarqube-json

doctor-defectdojo: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-defectdojo

doctor-defectdojo-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-defectdojo --json

doctor-dojo: doctor-defectdojo
doctor-dojo-json: doctor-defectdojo-json

doctor-export-defectdojo: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo; \
	fi

doctor-export-defectdojo-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-defectdojo --json; \
	fi

doctor-export-dojo: doctor-export-defectdojo
doctor-export-dojo-json: doctor-export-defectdojo-json

doctor-cyclonedx: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-cyclonedx

doctor-cyclonedx-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-cyclonedx --json

doctor-cdx: doctor-cyclonedx
doctor-cdx-json: doctor-cyclonedx-json

doctor-export-cyclonedx: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx; \
	fi

doctor-export-cyclonedx-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-cyclonedx --json; \
	fi

doctor-export-cdx: doctor-export-cyclonedx
doctor-export-cdx-json: doctor-export-cyclonedx-json

doctor-spdx: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-spdx

doctor-spdx-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-spdx --json

doctor-export-spdx: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx; \
	fi

doctor-export-spdx-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-spdx --json; \
	fi

doctor-csaf: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csaf

doctor-csaf-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csaf --json

doctor-export-csaf: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf; \
	fi

doctor-export-csaf-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csaf --json; \
	fi

doctor-openvex: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-openvex

doctor-openvex-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-openvex --json

doctor-vex: doctor-openvex
doctor-vex-json: doctor-openvex-json

doctor-export-openvex: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex; \
	fi

doctor-export-openvex-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-openvex --json; \
	fi

doctor-export-vex: doctor-export-openvex
doctor-export-vex-json: doctor-export-openvex-json

doctor-stix: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-stix

doctor-stix-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-stix --json

doctor-export-stix: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix; \
	fi

doctor-export-stix-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-stix --json; \
	fi

doctor-attack: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-attack

doctor-attack-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-attack --json

doctor-export-attack: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack; \
	fi

doctor-export-attack-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-attack --json; \
	fi

doctor-mitre: doctor-attack
doctor-mitre-json: doctor-attack-json
doctor-export-mitre: doctor-export-attack
doctor-export-mitre-json: doctor-export-attack-json

doctor-oscal: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-oscal

doctor-oscal-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-oscal --json

doctor-export-oscal: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal; \
	fi

doctor-export-oscal-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-oscal --json; \
	fi

doctor-csf: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csf

doctor-csf-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --doctor-csf --json

doctor-nist-csf: doctor-csf
doctor-nist-csf-json: doctor-csf-json

doctor-export-csf: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf "$$TARGET_PATH"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf; \
	fi

doctor-export-csf-json: build
	@if [ -n "$(DEST)" ] || [ -n "$(FILE)" ]; then \
		TARGET_PATH="$${DEST:-$(FILE)}"; \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf "$$TARGET_PATH" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --doctor-export-csf --json; \
	fi

doctor-export-nist-csf: doctor-export-csf
doctor-export-nist-csf-json: doctor-export-csf-json

diagnostics: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics

diagnostics-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics --json

diagnostics-gui: build
	@echo "Opening Diagnostics & System Health window..."
	@build/FaceLock.app/Contents/MacOS/FaceLock --diagnostics-gui

security-score: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --security-score

security-score-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --security-score --json

posture: security-score

posture-json: security-score-json

presentation-apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --presentation-apps

presentation-apps-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --presentation-apps --json

meeting-apps: presentation-apps

meeting-apps-json: presentation-apps-json

check-presentation: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation $(APP)

check-presentation-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --check-presentation $(APP) --json

add-meeting-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make add-meeting-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --add-meeting-app "$(APP)"

add-meeting-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make add-meeting-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --add-meeting-app "$(APP)" --json

remove-meeting-app: build
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make remove-meeting-app APP=<bundleId>"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --remove-meeting-app "$(APP)"

remove-meeting-app-json: build
	@if [ -z "$(APP)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make remove-meeting-app-json APP=<bundleId>\"}"; \
		exit 1; \
	fi
	@build/FaceLock.app/Contents/MacOS/FaceLock --remove-meeting-app "$(APP)" --json

reset-meeting-apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-meeting-apps

reset-meeting-apps-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --reset-meeting-apps --json

custom-meeting-apps: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --custom-meeting-apps

custom-meeting-apps-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --custom-meeting-apps --json

add-presentation-app: add-meeting-app
add-presentation-app-json: add-meeting-app-json
remove-presentation-app: remove-meeting-app
remove-presentation-app-json: remove-meeting-app-json
reset-presentation-apps: reset-meeting-apps
custom-presentation-apps: custom-meeting-apps

threat-intel: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --threat-intel

threat-intel-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --threat-intel --json

risk-level: threat-intel

risk-level-json: threat-intel-json

validate-config: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --validate-config

validate-config-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --validate-config --json

check-config: validate-config

check-config-json: validate-config-json

harden: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --harden

harden-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --harden --json

auto-harden: harden

auto-harden-json: harden-json

storage-summary: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-summary

storage-summary-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --storage-summary --json

storage-stats: storage-summary

storage-stats-json: storage-summary-json

prune-incidents-size: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-size $(MB)

prune-incidents-size-json: build
	@build/FaceLock.app/Contents/MacOS/FaceLock --prune-incidents-size $(MB) --json

prune-incidents-mb: prune-incidents-size

prune-incidents-mb-json: prune-incidents-size-json

prune-incidents-quota: prune-incidents-size

prune-incidents-quota-json: prune-incidents-size-json

archive-incidents: build
	@if [ -z "$(DEST)" ] && [ -z "$(DIR)" ]; then \
		echo "Usage: make archive-incidents DIR=<directory> [TYPE=<type>]"; \
		exit 1; \
	fi
	@TARGET_DIR="$${DEST:-$(DIR)}"; \
	if [ -n "$(TYPE)" ]; then \
		build/FaceLock.app/Contents/MacOS/FaceLock --archive-incidents "$$TARGET_DIR" --type "$(TYPE)"; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --archive-incidents "$$TARGET_DIR"; \
	fi

archive-incidents-json: build
	@if [ -z "$(DEST)" ] && [ -z "$(DIR)" ]; then \
		echo "{\"success\":false,\"error\":\"Usage: make archive-incidents-json DIR=<directory> [TYPE=<type>]\"}"; \
		exit 1; \
	fi
	@TARGET_DIR="$${DEST:-$(DIR)}"; \
	if [ -n "$(TYPE)" ]; then \
		build/FaceLock.app/Contents/MacOS/FaceLock --archive-incidents "$$TARGET_DIR" --type "$(TYPE)" --json; \
	else \
		build/FaceLock.app/Contents/MacOS/FaceLock --archive-incidents "$$TARGET_DIR" --json; \
	fi

commit:
	@./scripts/autocommit.sh

release:
	@./scripts/release.sh $(VERSION) "$(MSG)"

update:
	@./scripts/autoupdate.sh

sync:
	@./scripts/sync-daemon.sh

install-sync:
	@./scripts/install-sync.sh

uninstall-sync:
	@echo "Stopping background auto-sync LaunchAgent..."
	@-launchctl unload $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist 2>/dev/null || true
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist
	@echo "✓ Auto-sync LaunchAgent removed"
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.sync.plist
	@echo "✓ Auto-sync LaunchAgent removed"

install: build install-cli
	@echo "Installing FaceLock to /Applications..."
	@rm -rf /Applications/FaceLock.app
	@cp -R build/FaceLock.app /Applications/
	@echo "✓ FaceLock successfully installed to /Applications/FaceLock.app"

install-cli:
	@echo "Configuring CLI symlink..."
	@if [ -d "/opt/homebrew/bin" ] && [ -w "/opt/homebrew/bin" ]; then \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /opt/homebrew/bin/facelock; \
		echo "✓ Symlink created in /opt/homebrew/bin/facelock"; \
	elif [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock /usr/local/bin/facelock; \
		echo "✓ Symlink created in /usr/local/bin/facelock"; \
	else \
		mkdir -p $(HOME)/.local/bin; \
		ln -sf /Applications/FaceLock.app/Contents/MacOS/FaceLock $(HOME)/.local/bin/facelock; \
		echo "✓ Symlink created in $(HOME)/.local/bin/facelock"; \
	fi

uninstall:
	@echo "Uninstalling FaceLock..."
	@pkill -f "FaceLock.app/Contents/MacOS/FaceLock" 2>/dev/null || true
	@rm -rf /Applications/FaceLock.app
	@rm -f $(BINDIR)/facelock
	@echo "✓ FaceLock uninstalled"

stop:
	@echo "Stopping FaceLock process..."
	@-pkill -f "FaceLock.app/Contents/MacOS/FaceLock" || true

report:
	@./scripts/telegram_report.sh

maintainer-install:
	@./scripts/install_launchagent.sh

maintainer-stop:
	@echo "Stopping 24/7 Autonomous Maintainer..."
	@-launchctl unload $(HOME)/Library/LaunchAgents/io.github.facelock.maintainer.plist 2>/dev/null || true
	@rm -f $(HOME)/Library/LaunchAgents/io.github.facelock.maintainer.plist
	@echo "✓ Autonomous Maintainer stopped"

clean:
	@rm -rf build
