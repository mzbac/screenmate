import Combine
import Foundation
import Cocoa

class ScreenshotManager: ObservableObject {
    
    @Published var isCapturing: Bool = false
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func takeScreenshotToImage(playSound: Bool = false, completion: @escaping (NSImage?) -> Void) {
        guard !isCapturing else {
            completion(nil)
            return
        }
        
        isCapturing = true
        
        let currentKeyWindow = NSApp.keyWindow
        
        self.minimizeAppPresence()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.performScreenCaptureToClipboard(playSound: playSound) { nsImage in
                self.restoreAppPresence(keyWindow: currentKeyWindow)
                self.isCapturing = false
                
                // Only notify about screenshot failures, not successes
                // Success notifications will be handled after processing completes
                if nsImage == nil {
                    self.notificationManager.showScreenshotErrorNotification(error: "Failed to capture screenshot")
                }
                
                completion(nsImage)
            }
        }
    }
    
    private func performScreenCaptureToClipboard(playSound: Bool, completion: @escaping (NSImage?) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        
        var arguments = ["-i"]
        arguments.append("-c")
        
        if !playSound {
            arguments.append("-x")
        }
        
        process.arguments = arguments
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try process.run()
                process.waitUntilExit()
                
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        let nsImage = self.readImageFromClipboard()
                        completion(nsImage)
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func readImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general
        
        guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else {
            return nil
        }
        
        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }
        
        for imageType in NSImage.imageTypes {
            if let imageData = pasteboard.data(forType: NSPasteboard.PasteboardType(imageType)),
               let image = NSImage(data: imageData) {
                return image
            }
        }
        
        return nil
    }
    
    private func minimizeAppPresence() {
        for window in NSApp.windows {
            if window.isVisible && window.canBecomeKey {
                window.setFrame(NSRect(x: -10000, y: -10000, width: window.frame.width, height: window.frame.height), display: false)
            }
        }
    }
    
    private func restoreAppPresence(keyWindow: NSWindow?) {
        for window in NSApp.windows {
            if window.frame.origin.x == -10000 {
                let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
                let newFrame = NSRect(
                    x: (screenFrame.width - window.frame.width) / 2,
                    y: (screenFrame.height - window.frame.height) / 2,
                    width: window.frame.width,
                    height: window.frame.height
                )
                window.setFrame(newFrame, display: true)
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        if let keyWindow = keyWindow {
            keyWindow.makeKey()
        }
    }
}
