import Cocoa

class CustomPromptPanel: NSPanel {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        setupPanel()
    }
    
    convenience init() {
        let contentRect = NSRect(x: 0, y: 0, width: 500, height: 600)
        let styleMask: NSWindow.StyleMask = [.titled, .closable, .resizable]
        
        self.init(contentRect: contentRect, styleMask: styleMask, backing: .buffered, defer: false)
    }
    
    private func setupPanel() {
        title = "Custom Prompt"
        isFloatingPanel = true
        level = .floating
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        
        minSize = NSSize(width: 400, height: 500)
        maxSize = NSSize(width: 800, height: 1000)
        
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    func show() {
        center()
        
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
        
        setIsVisible(true)
    }
    
    func hide() {
        orderOut(nil)
    }
}