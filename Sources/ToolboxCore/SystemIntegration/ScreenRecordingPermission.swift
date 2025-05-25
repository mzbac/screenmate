import Cocoa
import AVFoundation

class ScreenRecordingPermission {
    
    public static func hasPermission() -> Bool {
        if #available(macOS 10.15, *) {
            let displayID = CGMainDisplayID()
            
            guard let displayStream = CGDisplayStream(
                dispatchQueueDisplay: displayID,
                outputWidth: 1,
                outputHeight: 1,
                pixelFormat: Int32(kCVPixelFormatType_32BGRA),
                properties: nil,
                queue: DispatchQueue.global(),
                handler: { _, _, _, _ in }
            ) else {
                return false
            }
            
            displayStream.stop()
            
            return true
        } else {
            return true
        }
    }
    
    public static func openSystemPreferences() {
        if #available(macOS 10.15, *) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                NSWorkspace.shared.open(url)
            }
        } else {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    @discardableResult
    public static func showPermissionAlert() -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission Required"
        alert.informativeText = "OCRToolbox needs screen recording permission to capture screenshots for text extraction.\n\nPlease grant permission in System Preferences > Security & Privacy > Privacy > Screen Recording."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
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
