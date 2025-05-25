import Cocoa
import ScreenCaptureKit

class ScreenRecordingPermission {
    
    public static func hasPermission() -> Bool {
        return checkScreenCapturePermission()
    }
    
    private static func checkScreenCapturePermission() -> Bool {
        var result = false
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            do {
                let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                result = !availableContent.displays.isEmpty
            } catch {
                result = false
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    public static func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @discardableResult
    public static func showPermissionAlert() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "ScreenMate needs screen recording permission to capture screenshots for text extraction.\n\nPlease grant permission in System Settings > Privacy & Security > Screen Recording."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            openSystemPreferences()
        }
        
        return response
    }
    
    public static func checkAndRequestIfNeeded() -> Bool {
        if hasPermission() {
            return true
        } else {
            showPermissionAlert()
            return false
        }
    }
}
