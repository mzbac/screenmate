import Cocoa
import SwiftUI

class PanelController: NSWindowController, NSWindowDelegate {
    
    private var panel: NSPanel {
        return window as! NSPanel
    }
    
    init() {
        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        super.init(window: panel)
        
        self.window?.delegate = self
        configurePanel()
        setupSwiftUIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePanel() {
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
        
        panel.acceptsMouseMovedEvents = true
        panel.becomesKeyOnlyIfNeeded = true
        
        setupWorkspaceNotifications()
    }
    
    private func setupSwiftUIView() {
        let appSettings = AppSettings.shared
        
        let contentView = MenubarContentView()
            .environmentObject(appSettings)
        
        let hostingView = NSHostingView(rootView: contentView)
        
        hostingView.frame = panel.contentView?.bounds ?? NSRect(x: 0, y: 0, width: 320, height: 450)
        hostingView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
        
        panel.contentView = hostingView
    }
    
    private func setupWorkspaceNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDeactivation),
            name: NSApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWorkspaceNotification),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDeactivation() {
        if panel.isVisible {
            close()
        }
    }
    
    @objc private func handleWorkspaceNotification() {
        if panel.isVisible && !panel.isKeyWindow {
            close()
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        close()
    }
    
    override func close() {
        super.close()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
