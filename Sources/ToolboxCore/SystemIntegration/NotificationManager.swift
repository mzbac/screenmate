import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    @Published var notificationsEnabled: Bool = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkNotificationPermission()
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.notificationsEnabled = granted
            }
            return granted
        } catch {
            await MainActor.run {
                self.notificationsEnabled = false
            }
            return false
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func showOCRSuccessNotification(textLength: Int) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "OCR Complete"
        content.body = "Extracted \(textLength) characters of text"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "ocr_success_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
        }
    }
    
    func showOCRErrorNotification(error: String) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "OCR Failed"
        content.body = "Error: \(error)"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "ocr_error_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
        }
    }
    
    func showModelLoadNotification(modelName: String, success: Bool) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        if success {
            content.title = "Model Loaded"
            content.body = "\(modelName) is ready for OCR"
        } else {
            content.title = "Model Load Failed"
            content.body = "Failed to load \(modelName)"
        }
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "model_load_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
        }
    }
    
    func showInfoNotification(title: String, message: String) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "info_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
        }
    }
    
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}