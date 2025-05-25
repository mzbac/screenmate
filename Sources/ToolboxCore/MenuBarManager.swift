import Cocoa
import SwiftUI

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private var panelController: PanelController?
    private var autostartManager: AutostartManager?
    private var menubarPanel: NSPanel? {
        return panelController?.window as? NSPanel
    }
    
    override init() {
        super.init()
        setupStatusItem()
        setupPanelController()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "viewfinder.circle.fill", accessibilityDescription: "ScreenMate")
            button.image?.isTemplate = true
            button.action = #selector(togglePanel)
            button.target = self
        }
    }
    
    private func setupPanelController() {
        panelController = PanelController()
        panelController?.loadWindow()
    }
    
    func setAutostartManager(_ manager: AutostartManager?) {
        self.autostartManager = manager
    }
    
    func closePanel() {
        panelController?.close()
    }
    
    @objc private func togglePanel() {
        guard let panel = panelController?.window as? NSPanel else {
            return
        }
        
        if panel.isVisible {
            panelController?.close()
        } else {
            showPanel()
        }
    }
    
    private func showPanel() {
        positionPanelRelativeToMenuBar()
        panelController?.showWindow(self)
        menubarPanel?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func positionPanelRelativeToMenuBar() {
        guard let statusButton = statusItem?.button,
              let panel = menubarPanel else { return }
        
        let buttonFrame = statusButton.frame
        guard let statusWindow = statusButton.window else { return }
        
        let buttonFrameInWindow = statusButton.convert(buttonFrame, to: nil)
        let buttonFrameInScreen = statusWindow.convertToScreen(buttonFrameInWindow)
        
        guard let screen = statusWindow.screen ?? NSScreen.main else { return }
        
        let panelWidth = AppSettings.shared.panelWidth
        let panelHeight = AppSettings.shared.panelHeight
        let spacing = AppSettings.shared.spacing
        
        let xPosition = buttonFrameInScreen.midX - (panelWidth / 2)
        
        let yPosition = buttonFrameInScreen.minY - panelHeight - spacing
        
        let adjustedX = max(10, min(xPosition, screen.frame.maxX - panelWidth - 10))
        let adjustedY = max(10, yPosition)
        
        let panelFrame = NSRect(x: adjustedX, y: adjustedY, width: panelWidth, height: panelHeight)
        panel.setFrame(panelFrame, display: true)
    }
}
