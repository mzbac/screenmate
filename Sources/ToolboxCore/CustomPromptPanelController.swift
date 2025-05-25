import Cocoa
import SwiftUI

class CustomPromptPanelController: NSWindowController {
    
    private var customPromptPanel: CustomPromptPanel {
        return window as! CustomPromptPanel
    }
    
    private var appSettings: AppSettings?
    private var screenMateEngine: ScreenMateEngine?
    
    convenience init(customPromptPanel: CustomPromptPanel) {
        self.init(window: customPromptPanel)
    }
    
    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCustomPromptView(appSettings: AppSettings, screenMateEngine: ScreenMateEngine) {
        self.appSettings = appSettings
        self.screenMateEngine = screenMateEngine
        
        let customPromptView = CustomPromptView()
            .environmentObject(appSettings)
            .environmentObject(screenMateEngine)
        
        let hostingView = NSHostingView(rootView: customPromptView)
        hostingView.frame = customPromptPanel.contentView?.frame ?? NSRect.zero
        
        customPromptPanel.contentView = hostingView
    }
    
    func showPanel() {
        customPromptPanel.show()
    }
    
    func hidePanel() {
        customPromptPanel.hide()
    }
    
    private func createCustomPromptView() -> some View {
        CustomPromptView()
    }
}