# FaceLock: Как я написал Face ID для приложений на macOS и ловлю взломщиков с отправкой фото в Telegram

Привет, Хабр!

Наверняка многие владельцы MacBook сталкивались с ситуацией: оставил ноутбук на столе в офисе, коворкинге или дома, отошёл на пару минут за кофе — и любой проходящий мимо человек может открыть Safari, Telegram или Терминал. Встроенная блокировка macOS срабатывает только через несколько минут простоя, а Touch ID встроена в кнопку, до которой злоумышленнику даже не нужно дотрагиваться.

Я задался вопросом: **почему камера MacBook со встроенным чипом Apple Silicon и Neural Engine не может работать как постоянный биометрический щит?** 

Так родился **[FaceLock](https://github.com/MaxSphinx/FaceLock)** — легковесный нативный демон для macOS на чистом Swift без единой внешней зависимости, который проверяет лицо пользователя при каждом переключении окон менее чем за 0.8 секунды, а при обнаружении чужака блокирует экран, делает снимок злоумышленника с ночной коррекцией экспозиции и отправляет его вам в Telegram.

В этой статье разберём, как устроена архитектура демона, как заставить Apple Vision framework работать субсекундно прямо на Neural Engine и как безопасно блокировать экран на уровне Cocoa без возможности закрытия через `Cmd + Q`.

---

## 1. Архитектура и требования

Перед началом разработки я зафиксировал несколько строгих ограничений:
1. **Zero External Dependencies**: Никаких сторонних библиотек, CocoaPods или SPM-пакетов. Только системные фреймворки Apple (`AVFoundation`, `Vision`, `LocalAuthentication`, `AppKit`).
2. **100% On-Device**: Никаких облачных API распознавания лиц. Все эмбеддинги вычисляются локально на Neural Engine. Фотографии владельца хранятся на диске в виде 128-мерных математических векторов.
3. **Sub-second Latency**: Проверка не должна раздражать владельца. Задержка между кликом на иконку Safari и разблокировкой — менее 800 мс.
4. **Unbypassable Lock**: Окно блокировки не должно сворачиваться, закрываться комбинациями `Cmd+Q`, `Cmd+W`, `Esc` или перекрываться другими окнами.

---

## 2. Перехват переключения приложений

Для отслеживания перехода в защищённые приложения (`Safari`, `Telegram`, `Terminal`, `Notes` и др.) демон подписывается на системные события `NSWorkspace`:

```swift
NSWorkspace.shared.notificationCenter.addObserver(
    self,
    selector: #selector(applicationDidActivate(_:)),
    name: NSWorkspace.didActivateApplicationNotification,
    object: nil
)
```

При активации приложения мы проверяем, входит ли его `bundleIdentifier` в список защищённых (`Config.shared.protectedBundleIDs`). Если да — немедленно запрашиваем один кадр с камеры для биометрической проверки.

---

## 3. Субсекундное извлечение эмбеддингов лица через Apple Vision

Для распознавания лиц в macOS встроен мощный фреймворк `Vision`. Вместо тяжелых моделей OpenCV или dlib мы используем нативный запрос `VNCreateFaceprintRequest`:

```swift
let request = VNCreateFaceprintRequest()
let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
try handler.perform([request])

guard let observation = request.results?.first as? VNFaceObservation,
      let faceprint = observation.faceprint else {
    // Лицо не обнаружено в кадре
    return nil
}
```

Фреймворк Apple возвращает объект `VNFaceprint`, содержащий 128-мерный вектор признаков. На Apple Silicon M1/M2/M3/M4 весь инференс выполняется аппаратно на Apple Neural Engine и занимает от 15 до 40 мс.

### Двойная метрика верификации (Cosine Distance + Top-3 Ensemble)
Чтобы исключить ложные срабатывания (False Positives), мы сравниваем полученный вектор с базой векторов владельца с помощью ансамблевой косинусной метрики:

$$\text{distance} = 1.0 - \frac{\mathbf{u} \cdot \mathbf{v}}{\|\mathbf{u}\| \|\mathbf{v}\|}$$

Для успешного прохода должны выполняться два инварианта:
1. Минимальная дистанция до ближайшего сохранённого вектора владельца: $d_{\min} \le 0.22$.
2. Средняя дистанция по топ-3 ближайшим шаблонам: $\bar{d}_{\text{top3}} \le 0.27$.

Если метрики не укладываются в порог — перед экраном сидит посторонний.

---

## 4. Захват взломщика и ночной HDR-лифтинг

Если лицо в кадре не совпадает с владельцем, демон выполняет захват кадра с камеры. Однако в тёмной комнате лицо злоумышленника часто оказывается недоэкспонированным из-за света от экрана.

FaceLock применяет на лету программный лифтинг экспозиции (`+1.3 EV`) и коррекцию гаммы через `CoreImage`:

```swift
let ciImage = CIImage(cvPixelBuffer: intruderBuffer)
let filter = CIFilter(name: "CIExposureAdjust")!
filter.setValue(ciImage, forKey: kCIInputImageKey)
filter.setValue(1.3, forKey: kCIInputEVKey)
```

Обработанный кадр сохраняется в локальную галерею инцидентов (`~/.facelock/incidents/`) и немедленно отправляется через фоновый `URLSession` в Telegram Bot API.

---

## 5. Непробиваемый экран блокировки на AppKit

Обычное окно `NSWindow` можно закрыть через `Cmd + Q`, скрыть через `Cmd + H` или перекрыть другим окном. Чтобы сделать блокировку действительно надёжной:

1. Уровень окна выставляется в `.screenSaver`:
```swift
self.level = NSWindow.Level(Int(CGWindowLevelForKey(.screenSaverWindow)))
self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
```
2. Перехватываются системные горячие клавиши:
```swift
override func performKeyEquivalent(with event: NSEvent) -> Bool {
    let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
    if flags.contains(.command) {
        return true // Поглощаем любые сочетания с Cmd
    }
    return super.performKeyEquivalent(with: event)
}
```

На экране блокировки отображается затемнённый матовый блюр (`NSVisualEffectView`), статус инцидента, поле ввода мастер-PIN и кнопка для мгновенной разблокировки через Touch ID.

---

## 6. Защита от ухода (Walk-Away Auto Lock)

Если вы встали из-за стола и отошли, FaceLock запускает таймер отсутствия активности пользователя (`CGEventSource.secondsSinceLastEventType`). Через 45 секунд бездействия камера незаметно активируется на 0.5 секунды. Если перед экраном никого нет — экран мгновенно гасится и блокируется.

---

## 7. Как попробовать

Проект полностью открыт под лицензией MIT. Исходный код, архитектурные схемы и готовые бинарники для Apple Silicon:

👉 **GitHub: [https://github.com/MaxSphinx/FaceLock](https://github.com/MaxSphinx/FaceLock)**

Установка в одну команду через терминал:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/MaxSphinx/FaceLock/main/scripts/install.sh)"
```

Буду рад вашим звёздам на GitHub, фидбеку и PR-ам!
