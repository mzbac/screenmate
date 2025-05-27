import SwiftUI
import AppKit

import Foundation

struct MenubarContentView: View {
    @ObservedObject private var appSettings = AppSettings.shared
    @StateObject private var screenshotManager: ScreenshotManager
    @StateObject private var autostartManager = AutostartManager()
    
    @ObservedObject private var screenMateEngine: ScreenMateEngine
    
    private var notificationManager: NotificationManager? {
        return AppDelegate.shared?.sharedNotificationManager
    }
    
    init() {
        let sharedNotificationManager = AppDelegate.shared?.sharedNotificationManager ?? NotificationManager()
        self._screenshotManager = StateObject(wrappedValue: ScreenshotManager(notificationManager: sharedNotificationManager))
        self._screenMateEngine = ObservedObject(wrappedValue: AppDelegate.shared?.sharedScreenMateEngine ?? ScreenMateEngine())
    }
    
    @State private var processedTextResult: String = "Select a VLM model in Settings and click Load."
    @State private var showingSettings = false
    @State private var lastScreenshotPreviewImage: NSImage?
    @State private var isProcessing = false
    
    private var displayText: String {
        switch appSettings.lastProcessingSource {
        case .customPrompt:
            return appSettings.lastCustomPromptResult.isEmpty ? processedTextResult : appSettings.lastCustomPromptResult
        case .defaultOCR:
            return processedTextResult
        case .none:
            return processedTextResult
        }
    }
    
    private var displayImage: NSImage? {
        switch appSettings.lastProcessingSource {
        case .customPrompt:
            return appSettings.lastCustomPromptScreenshot ?? lastScreenshotPreviewImage
        case .defaultOCR:
            return lastScreenshotPreviewImage
        case .none:
            return lastScreenshotPreviewImage
        }
    }
    
    private var resultSourceIndicator: String {
        switch appSettings.lastProcessingSource {
        case .customPrompt:
            return "Custom Prompt Result"
        case .defaultOCR:
            return "Image Processing Result"
        case .none:
            return "Image Processing Result"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("ScreenMate")
                .font(.headline)
                .padding(.top, 8)
            
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(screenMateEngine.currentStatusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text("Model: \(screenMateEngine.loadedModelNameDisplay)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: loadSelectedModel) {
                Label("Load/Change VLM Model", systemImage: "arrow.down.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(screenMateEngine.isLoadingModel)
            
            VStack(spacing: 4) {
                Button(action: processScreenshotWithDefaultPrompt) {
                    HStack {
                        Label("Process Screenshot", systemImage: "camera.viewfinder")
                        if screenMateEngine.hasActiveCustomPrompt(from: appSettings) {
                            Image(systemName: "text.bubble.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!screenMateEngine.isModelReady || screenMateEngine.imageProcessingInProgress || isProcessing)
                
                if screenMateEngine.hasActiveCustomPrompt(from: appSettings) {
                    Text("Using custom prompt")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 12) {
                VStack {
                    Text("Screenshot")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let screenshotImage = displayImage {
                        Image(nsImage: screenshotImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Text("No screenshot")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text(resultSourceIndicator)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        Text(displayText)
                            .textSelection(.enabled)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 11))
                    }
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .frame(minHeight: 200, maxHeight: 300)
            
            HStack(spacing: 12) {
                Button(action: copyResultToClipboard) {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }
                .buttonStyle(.bordered)
                .disabled(displayText.isEmpty || displayText == "Select a VLM model in Settings and click Load." || displayText == "Click button to start.")
                
                Button(action: { showingSettings.toggle() }) {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.bordered)
                .popover(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(appSettings)
                        .environmentObject(autostartManager)
                }
                
                Button(action: showCustomPromptPanel) {
                    Label("Custom Prompt", systemImage: "text.bubble")
                }
                .buttonStyle(.bordered)
                
                Button(action: quitApp) {
                    Label("Quit", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 500, height: 500)
        .background(Material.regular)
        .cornerRadius(12)
        .shadow(radius: 10)
        .onReceive(screenMateEngine.$isLoadingModel) { isLoading in
            if isLoading {
                processedTextResult = "Model is downloading, please wait..."
            } else if screenMateEngine.isModelReady && processedTextResult == "Model is downloading, please wait..." {
                processedTextResult = "Click button to start."
            }
        }
        .onChange(of: appSettings.selectedVLMModelIdentifier) { _, newIdentifier in
            Task {
                await screenMateEngine.loadModel(modelIdentifier: newIdentifier)
            }
        }
        .onAppear {
            loadSelectedModel()
        }
    }
    
    private var statusColor: Color {
        if screenMateEngine.isLoadingModel {
            return .orange
        } else if screenMateEngine.imageProcessingInProgress {
            return .blue
        } else if screenMateEngine.isModelReady {
            return .green
        } else {
            return .red
        }
    }
    
    private func loadSelectedModel() {
        Task {
            await screenMateEngine.loadModel(modelIdentifier: appSettings.selectedVLMModelIdentifier)
        }
    }
    
    private func processScreenshotWithDefaultPrompt() {
        guard screenMateEngine.isModelReady && !screenMateEngine.imageProcessingInProgress else {
            processedTextResult = "Cannot process image: \(screenMateEngine.currentStatusMessage)"
            return
        }
        
        AppDelegate.shared?.closeMenuBar()
        
        isProcessing = true
        processedTextResult = "Taking screenshot..."
        lastScreenshotPreviewImage = nil
        
        screenshotManager.takeScreenshotToImage { nsImage in
            DispatchQueue.main.async {
                guard let image = nsImage else {
                    self.processedTextResult = "Screenshot failed or cancelled."
                    self.isProcessing = false
                    return
                }
                
                self.lastScreenshotPreviewImage = image
                self.processedTextResult = "Processing image..."
                
                let effectiveSystemPrompt = self.screenMateEngine.getEffectiveSystemPrompt(from: self.appSettings)
                let effectivePrompt = self.screenMateEngine.getEffectivePrompt(from: self.appSettings)
                
                screenMateEngine.processImage(
                    onNSImage: image,
                    prompt: effectivePrompt,
                    customSystemPrompt: effectiveSystemPrompt
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let text):
                            self.processedTextResult = text.isEmpty ? "No text detected in image." : text
                            
                            // Auto-copy to clipboard if enabled
                            if self.appSettings.autoCopyToClipboard && !text.isEmpty {
                                ClipboardHelper.copyToClipboard(text)
                            }
                            
                            self.appSettings.lastCustomPromptResult = ""
                            self.appSettings.lastCustomPromptScreenshot = image
                            self.appSettings.lastProcessingSource = .defaultOCR
                            
                            // Send notification for complete screenshot process
                            if let notificationManager = self.notificationManager {
                                notificationManager.showScreenshotProcessCompleteNotification(
                                    success: true,
                                    textLength: text.count
                                )
                            }
                        case .failure(let error):
                            self.processedTextResult = "Image processing failed: \(error.localizedDescription)"
                            
                            self.appSettings.lastCustomPromptResult = ""
                            self.appSettings.lastCustomPromptScreenshot = image
                            self.appSettings.lastProcessingSource = .defaultOCR
                            
                            // Send notification for failed screenshot process
                            if let notificationManager = self.notificationManager {
                                notificationManager.showScreenshotProcessCompleteNotification(
                                    success: false,
                                    errorMessage: error.localizedDescription
                                )
                            }
                        }
                        self.isProcessing = false
                    }
                }
            }
        }
    }
    
    private func showCustomPromptPanel() {
        guard let appDelegate = AppDelegate.shared else {
            return
        }
        
        appDelegate.showCustomPromptPanel()
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func copyResultToClipboard() {
        ClipboardHelper.copyToClipboard(displayText)
    }
}

struct MenubarContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenubarContentView()
    }
}
