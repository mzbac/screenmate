import Foundation
import SwiftUI

class AutostartManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            if isEnabled {
                enableAutostartLaunchAgent()
            } else {
                disableAutostartLaunchAgent()
            }
        }
    }
    
    private let appBundleIdentifier: String
    private let appName: String
    
    init() {
        self.appBundleIdentifier = Bundle.main.bundleIdentifier ?? "com.github.mzbac.toolbox"
        
        self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                      Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                      Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ??
                      "toolbox"
        
        let launchAgentPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("LaunchAgents")
            .appendingPathComponent("\(appBundleIdentifier).plist")
        
        self.isEnabled = FileManager.default.fileExists(atPath: launchAgentPath.path)
    }
    
    private var launchAgentPath: URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        return homeDirectory
            .appendingPathComponent("Library")
            .appendingPathComponent("LaunchAgents")
            .appendingPathComponent("\(appBundleIdentifier).plist")
    }
    
    private func enableAutostartLaunchAgent() {
        let plistContent = createLaunchAgentPlist()
        
        do {
            let launchAgentsDir = launchAgentPath.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: launchAgentsDir.path) {
                try FileManager.default.createDirectory(at: launchAgentsDir, withIntermediateDirectories: true, attributes: nil)
            }
            
            try plistContent.write(to: launchAgentPath, atomically: true, encoding: .utf8)
            isEnabled = true
        } catch {
            isEnabled = false
        }
    }
    
    private func disableAutostartLaunchAgent() {
        do {
            if FileManager.default.fileExists(atPath: launchAgentPath.path) {
                try FileManager.default.removeItem(at: launchAgentPath)
            }
        } catch {
            isEnabled = true
        }
    }
    
    private func createLaunchAgentPlist() -> String {
        let appPath = Bundle.main.bundlePath
        let executablePath = "\(appPath)/Contents/MacOS/\(appName)"
        
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(appBundleIdentifier)</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(executablePath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
        </dict>
        </plist>
        """
        
        return plistContent
    }
}