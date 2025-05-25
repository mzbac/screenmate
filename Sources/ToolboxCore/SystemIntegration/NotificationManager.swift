import Foundation
import UserNotifications
import Combine

@MainActor
public class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published public var notificationsEnabled: Bool = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    public override init() {
        super.init()
        notificationCenter.delegate = self
        checkNotificationPermission()
    }
    
    public func requestNotificationPermission() async -> Bool {
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
    
    /// Shows notifications even when the app is in the foreground
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handles notification interactions
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    public func showOCRSuccessNotification(textLength: Int) {
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
            if let error = error {
                print("Failed to add OCR success notification: \(error)")
            }
        }
    }
    
    public func showOCRErrorNotification(error: String) {
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
            if let error = error {
                print("Failed to add OCR error notification: \(error)")
            }
        }
    }
    
    public func showModelLoadNotification(modelName: String, success: Bool) {
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
            if let error = error {
                print("Failed to add model load notification: \(error)")
            }
        }
    }
    
    public func showInfoNotification(title: String, message: String) {
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
            if let error = error {
                print("Failed to add info notification: \(error)")
            }
        }
    }
    
    public func showScreenshotSuccessNotification() {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Screenshot Captured"
        content.body = "Screenshot has been saved to clipboard"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "screenshot_success_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add screenshot success notification: \(error)")
            }
        }
    }
    
    public func showScreenshotErrorNotification(error: String) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Screenshot Failed"
        content.body = "Error: \(error)"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "screenshot_error_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add screenshot error notification: \(error)")
            }
        }
    }
    
    public func showScreenshotProcessCompleteNotification(success: Bool, textLength: Int = 0, errorMessage: String? = nil) {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        
        if success {
            content.title = "Screenshot Process Complete"
            if textLength > 0 {
                content.body = "Successfully extracted \(textLength) characters of text"
            } else {
                content.body = "Screenshot processed successfully"
            }
        } else {
            content.title = "Screenshot Process Failed"
            content.body = errorMessage ?? "An error occurred during processing"
        }
        
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: "screenshot_process_complete_\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add screenshot process complete notification: \(error)")
            }
        }
    }
    
    public func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}