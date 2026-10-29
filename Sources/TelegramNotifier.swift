import AppKit
import Foundation

public final class TelegramNotifier {
    public static let shared = TelegramNotifier()

    private let session = URLSession(configuration: .default)

    private init() {}

    public func sendIntruderAlert(photo: NSImage, appName: String, completion: ((Bool, String?) -> Void)? = nil) {
        guard Config.shared.telegramEnabled else {
            completion?(false, "Telegram alerts disabled")
            return
        }

        let token = Config.shared.telegramBotToken.trimmingCharacters(in: .whitespacesAndNewlines)
        let chatId = Config.shared.telegramChatId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !token.isEmpty, !chatId.isEmpty else {
            completion?(false, "Bot Token or Chat ID is empty")
            return
        }

        guard let tiff = photo.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let jpegData = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else {
            completion?(false, "Failed to encode JPEG image")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss (dd.MM.yyyy)"
        let timeStr = formatter.string(from: Date())
        let safeAppName = TelegramNotifier.escapeHTML(appName)

        let caption = """
        🚨 <b>FaceLock: Обнаружен посторонний!</b>
        💻 <b>Приложение:</b> \(safeAppName)
        🕒 <b>Время:</b> \(timeStr)
        🔒 Экран MacBook заблокирован защитным замком.
        """

        sendPhotoRequest(token: token, chatId: chatId, photoData: jpegData, caption: caption, completion: completion)
    }

    public static func escapeHTML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    public func sendTestMessage(token: String, chatId: String, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "https://api.telegram.org/bot\(token)/sendMessage") else {
            completion(false, "Неверный URL бота")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "chat_id": chatId,
            "text": "🛡️ <b>FaceLock</b> успешно подключен к вашему Telegram!\nОповещения с фото посторонних активны.",
            "parse_mode": "HTML"
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(false, "Ошибка сериализации")
            return
        }
        request.httpBody = httpBody

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let err = error {
                    completion(false, "Ошибка сети: \(err.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let msg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Ошибка Telegram API"
                    completion(false, "Ошибка API: \(msg)")
                    return
                }

                completion(true, "Тестовое сообщение успешно доставлено!")
            }
        }
        task.resume()
    }

    private func sendPhotoRequest(token: String, chatId: String, photoData: Data, caption: String, completion: ((Bool, String?) -> Void)?) {
        guard let url = URL(string: "https://api.telegram.org/bot\(token)/sendPhoto") else {
            completion?(false, "Invalid URL")
            return
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(chatId)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"caption\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(caption)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"parse_mode\"\r\n\r\n".data(using: .utf8)!)
        body.append("HTML\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"intruder.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(photoData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let err = error {
                    print("[TelegramNotifier] Network error: \(err.localizedDescription)")
                    SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: false, details: "Photo network error: \(err.localizedDescription)")
                    completion?(false, err.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    print("[TelegramNotifier] API error: \(responseBody)")
                    SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: false, details: "Photo API error: \(responseBody)")
                    completion?(false, responseBody)
                    return
                }

                print("[TelegramNotifier] Intruder photo sent to Telegram successfully!")
                SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: true, details: "Intruder photo delivered to Telegram")
                completion?(true, nil)
            }
        }
        task.resume()
    }

    public func sendSecurityAlert(message: String, completion: ((Bool, String?) -> Void)? = nil) {
        guard Config.shared.telegramEnabled else {
            completion?(false, "Telegram alerts disabled")
            return
        }

        let token = Config.shared.telegramBotToken.trimmingCharacters(in: .whitespacesAndNewlines)
        let chatId = Config.shared.telegramChatId.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !token.isEmpty, !chatId.isEmpty else {
            completion?(false, "Bot Token or Chat ID is empty")
            return
        }

        guard let url = URL(string: "https://api.telegram.org/bot\(token)/sendMessage") else {
            completion?(false, "Invalid Telegram bot URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "chat_id": chatId,
            "text": message,
            "parse_mode": "HTML"
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion?(false, "JSON serialization error")
            return
        }
        request.httpBody = httpBody

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            _ = self
            DispatchQueue.main.async {
                if let err = error {
                    print("[TelegramNotifier] Security alert network error: \(err.localizedDescription)")
                    SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: false, details: "Network error: \(err.localizedDescription)")
                    completion?(false, err.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let responseBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    print("[TelegramNotifier] Security alert API error: \(responseBody)")
                    SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: false, details: "Telegram API error: \(responseBody)")
                    completion?(false, responseBody)
                    return
                }

                print("[TelegramNotifier] Security text alert delivered to Telegram successfully!")
                SecurityAuditLogger.shared.logTelegramAlert(appName: nil, isSuccess: true, details: "Security text alert delivered to Telegram")
                completion?(true, nil)
            }
        }
        task.resume()
    }
}
