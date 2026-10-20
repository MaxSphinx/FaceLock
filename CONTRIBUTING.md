# Contributing to FaceLock

Thank you for your interest in contributing to FaceLock!

## Architecture & Code Philosophy

1. **Zero External Dependencies**:
   FaceLock deliberately avoids CocoaPods, Carthage, and external Swift packages. All features are built directly on native macOS Apple frameworks (`AppKit`, `AVFoundation`, `Vision`, `LocalAuthentication`, `QuartzCore`, `CoreImage`).

2. **Performance First**:
   - Camera scans must remain under 1.5–2 seconds.
   - Background idling must consume < 0.1% CPU.
   - Windows must use standard AppKit rendering and Core Animation layers.

3. **Modern Swift**:
   - Strict concurrency safety and memory hygiene.
   - Clean, idiomatic code without artificial boilerplate.

## Development Workflow

```bash
# 1. Fork and clone the repository
git clone https://github.com/MaxSphinx/FaceLock.git
cd FaceLock

# 2. Build the project
make build

# 3. Test your build
make run

# 4. Check CLI options
make status
```

## Pull Request Guidelines

- Branch naming: `feature/my-feature` or `fix/issue-description`.
- Ensure `make build` completes with zero compiler warnings.
- Keep commits atomic and descriptive (`feat: ...`, `fix: ...`, `docs: ...`).
- Verify that your changes run smoothly on macOS 14.0+ (Sonoma & Sequoia).
