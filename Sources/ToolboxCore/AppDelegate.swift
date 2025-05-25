import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate {
    
    public static var shared: AppDelegate?
    
    private var menuBarManager: MenuBarManager?
    private var autostartManager: AutostartManager?
    private var customPromptPanelController: CustomPromptPanelController?
    private var appSettings: AppSettings?
    private var screenMateEngine: ScreenMateEngine?
    
    public override init() {
        super.init()
        AppDelegate.shared = self
    }
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        let sharedAppSettings = AppSettings.shared
        screenMateEngine = ScreenMateEngine()
        autostartManager = AutostartManager()
        menuBarManager = MenuBarManager()
        
        appSettings = sharedAppSettings
        
        menuBarManager?.setAutostartManager(autostartManager)
    }
    
    public func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    public func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    public var sharedScreenMateEngine: ScreenMateEngine? {
        return self.screenMateEngine
    }
    
    public var sharedAppSettings: AppSettings? {
        return self.appSettings
    }
    
    public func showCustomPromptPanel() {
        if customPromptPanelController == nil {
            let customPromptPanel = CustomPromptPanel()
            customPromptPanelController = CustomPromptPanelController(customPromptPanel: customPromptPanel)
            
            if let appSettings = appSettings, let screenMateEngine = screenMateEngine {
                customPromptPanelController?.setupCustomPromptView(
                    appSettings: appSettings,
                    screenMateEngine: screenMateEngine
                )
            }
        }
        
        customPromptPanelController?.showPanel()
    }
}