# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Security & Privacy Invariants

FaceLock is built with privacy-by-design principles:

1. **100% On-Device Processing**:
   - All facial embeddings are computed locally on the Apple Neural Engine via Apple's Vision framework (`VNCreateFaceprintRequest`).
   - Camera video frames are processed in memory and never written to disk during regular verification.
   - Only when an unauthorized intruder triggers a verification failure is an encrypted JPEG snapshot recorded to `~/.facelock/intruders/` for local security audit logs.

2. **No Cloud Telemetry or Tracking**:
   - FaceLock contains zero telemetry, zero analytics SDKs, and zero background network calls.
   - Outbound network requests occur exclusively if you explicitly configure Telegram Bot alerts to send intruder notifications to your personal Telegram Bot token.

3. **Biometric Representations**:
   - FaceLock stores mathematical 128-dimensional float vectors (`~/.facelock/owner_face_vectors.json`). Raw face photos are discarded immediately after calibration.

## Reporting a Vulnerability

If you discover a security vulnerability within FaceLock, please submit an advisory via GitHub Security Advisories or contact the repository maintainers directly. Please allow reasonable time for remediation before any public disclosure.
