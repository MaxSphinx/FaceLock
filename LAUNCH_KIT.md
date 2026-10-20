# FaceLock — Viral Launch & Star Growth Playbook 🚀

This kit contains ready-to-use launch templates to get **1,000+ stars** on GitHub across Hacker News, Reddit, Twitter/X, Product Hunt, and Telegram.

---

## 1. GitHub Repository Optimization (Do This First)

### Topics / Tags (Add these in "About" on your GitHub repo page)
Click the gear icon next to "About" on `https://github.com/MaxSphinx/FaceLock` and paste these exact tags:
```text
macos, apple-silicon, security, biometrics, face-recognition, faceid, touchid, appkit, swift, privacy, screen-lock, telegram-bot, computer-vision
```

### Short Description
```text
Native biometric application shield for macOS. Sub-second neural camera check on app-switch, intruder capture with night HDR, and Telegram alerts.
```

---

## 2. Hacker News — Show HN

**Where to post**: [news.ycombinator.com/submit](https://news.ycombinator.com/submit)  
**Best time**: Tuesday or Wednesday at 08:00–09:00 AM EST (15:00–16:00 MSK).

### Title
```text
Show HN: FaceLock – Biometric application shield and intruder defense for macOS
```

### Text Body
```text
Hey HN,

I built FaceLock because macOS doesn't have per-application Face ID protection, nor does it alert you if someone opens your laptop when you walk away.

FaceLock runs as a lightweight native daemon on Apple Silicon. Whenever an app gains focus (or when you step away from your Mac for 45s):
1. It activates the camera for ~0.8s and computes 128-dimensional facial embedding vectors using Apple's Vision framework (VNCreateFaceprintRequest) directly on the Apple Neural Engine.
2. It compares the face against owner templates using a dual-verification metric (min cosine distance <= 0.22 and top-3 ensemble <= 0.27) to prevent false matches.
3. If an unrecognized face is sitting at the screen, it engages an unbypassable fullscreen lock at the .screenSaver window level (blocking Cmd+Q, Cmd+W, Esc), enhances the intruder's photo with a low-light exposure lift (+1.3 EV), and dispatches the photo with timestamp to your private Telegram chat.

Key invariants:
- Zero external dependencies (pure AppKit, AVFoundation, Vision, LocalAuthentication).
- 100% on-device local storage. No cloud telemetry, no analytics.
- Unlocks with Touch ID or master PIN.

Repo: https://github.com/MaxSphinx/FaceLock
Pre-compiled release: https://github.com/MaxSphinx/FaceLock/releases/latest

Feedback and PRs welcome!
```

---

## 3. Reddit Posts

### A. Subreddit: `r/macapps`
**Title**: `[Free & Open Source] FaceLock: Biometric App Shield & Intruder Camera Defense for macOS`  
**Flair**: `Release` / `Open Source`

**Body**:
```markdown
Hey everyone!

I created **FaceLock**, a native macOS security utility that turns your Mac's camera into an active biometric shield.

### What it does:
- ⚡️ **Instant App Protection**: Switches to Safari, Telegram, or Terminal? The camera verifies your face in <1s and seamlessly unlocks.
- 📸 **Intruder Photo**: If someone else is sitting at your Mac, it snaps their photo, enhances it for low-light rooms, and displays it on the lock screen.
- 💬 **Telegram Alert**: You immediately receive their photo, timestamp, and the app they tried to open on your phone.
- 🚶 **Walk-Away Auto Lock**: Stepped away from your desk? If you're idle for 45s, it silently checks the camera and locks.
- 🔒 **Privacy**: 100% local, runs on Apple Neural Engine, zero tracking.

Install with 1 line:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MaxSphinx/FaceLock/main/scripts/install.sh)"
```

GitHub: https://github.com/MaxSphinx/FaceLock

Would love to hear your thoughts and feature requests!
```

### B. Subreddit: `r/swift`
**Title**: `FaceLock: Building a native zero-dependency macOS biometric shield with Vision ANFRv4 & AppKit`  
**Focus**: Deep dive into `VNCreateFaceprintRequest`, cosine clustering, and `.screenSaver` window level event interception.

---

## 4. Twitter / X Viral Demo Post

Attach a 10–15 second screen recording of FaceLock in action (switching to an app, HUD verifying green, then covering camera or someone else appearing -> lock screen triggering with glowing intruder photo).

**Tweet Text**:
```text
Ever wanted real Face ID and intruder defense on your MacBook? 🛡️

Introducing FaceLock:
• Sub-second biometric verification on app switch
• Captures intruder photos with night HDR lift
• Sends instant alerts to your Telegram
• 100% offline on Apple Neural Engine

Free & Open Source on GitHub:
👉 https://github.com/MaxSphinx/FaceLock

#macOS #SwiftLang #AppleSilicon #OpenSource
```

---

## 5. Habr & Russian Tech Telegram Channels

**Заголовок**: `FaceLock — открытая биометрическая защита для macOS: перехват фокуса, ANE нейросети и алерты в Telegram`

**Ключевые тезисы**:
1. Проблема: в macOS нет защиты отдельных приложений по Face ID.
2. Решение: Swift + Apple Vision (128-мерный эмбеддинг ANFRv4) + косинусное расстояние $d \le 0.22$.
3. Фичи: ночной HDR-буст фото нарушителя, Telegram-бот, авто-замок при уходе (Walk-away).
4. Установка в 1 клик через `curl` скрипт.
5. Ссылка на GitHub: https://github.com/MaxSphinx/FaceLock
