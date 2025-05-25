import SwiftUI
import AppKit

struct CustomPromptView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var screenMateEngine: ScreenMateEngine
    
    @State private var userPrompt: String = ""
    @State private var systemPrompt: String = ""
    @State private var showingSaveConfirmation: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack {
                    Text("Custom Prompt Setup")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Close") {
                        if let window = NSApplication.shared.keyWindow {
                            window.orderOut(nil)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Divider()
                
                HStack {
                    Circle()
                        .fill(modelStatusColor)
                        .frame(width: 8, height: 8)
                    Text(screenMateEngine.currentStatusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    Text("Model: \(screenMateEngine.loadedModelNameDisplay)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to use:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. Enter your custom prompt below")
                            Text("2. Click 'Save Custom Prompt'")
                            Text("3. Close this panel and use the main 'Process Screenshot' button")
                            Text("4. Your custom prompt will be used automatically")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Prompt Sets")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 12) {
                                Button(action: { applyPromptSet(.ocr) }) {
                                    HStack {
                                        Image(systemName: "doc.text.viewfinder")
                                        Text("OCR")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(appSettings.selectedPromptSet == .ocr ? .blue : .primary)
                                
                                Button(action: { applyPromptSet(.analysis) }) {
                                    HStack {
                                        Image(systemName: "eye")
                                        Text("Analysis")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(appSettings.selectedPromptSet == .analysis ? .blue : .primary)
                                
                                Spacer()
                            }
                            
                            Text("Click to apply predefined prompt sets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("System Prompt (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $systemPrompt)
                                .font(.system(.body, design: .monospaced))
                                .padding(8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                                .frame(minHeight: 80, maxHeight: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                            
                            Text("Define the AI's role and behavior. Leave empty to use default system prompt.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("User Prompt")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            TextEditor(text: $userPrompt)
                                .font(.system(.body, design: .monospaced))
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .frame(minHeight: 120, maxHeight: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            
                            Text("Enter your custom prompt here. For example: 'Extract all text and translate to Spanish' or 'Describe the image in detail'.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: saveCustomPrompt) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save Custom Prompt")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(
                            userPrompt.trimmingCharacters(in: .whitespacesAndNewlines) == appSettings.lastCustomPrompt.trimmingCharacters(in: .whitespacesAndNewlines) &&
                            systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines) == appSettings.lastCustomSystemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        
                        if screenMateEngine.hasActiveCustomPrompt(from: appSettings) {
                            Button(action: clearCustomPrompt) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear")
                                }
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                    }
                    
                    if screenMateEngine.hasActiveCustomPrompt(from: appSettings) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Currently Active Prompts:")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            if !appSettings.lastCustomSystemPrompt.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("System Prompt:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.orange)
                                    
                                    ScrollView {
                                        Text(appSettings.lastCustomSystemPrompt)
                                            .textSelection(.enabled)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 11, design: .monospaced))
                                    }
                                    .frame(maxHeight: 80)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            if !appSettings.lastCustomPrompt.isEmpty {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("User Prompt:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    ScrollView {
                                        Text(appSettings.lastCustomPrompt)
                                            .textSelection(.enabled)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 11, design: .monospaced))
                                    }
                                    .frame(maxHeight: 80)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    if showingSaveConfirmation {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Custom prompt saved! Use the main Process Screenshot button to apply it.")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showingSaveConfirmation = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .onAppear {
            userPrompt = appSettings.lastCustomPrompt
            systemPrompt = appSettings.lastCustomSystemPrompt
        }
    }
    
    private var modelStatusColor: Color {
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
    
    private func saveCustomPrompt() {
        let trimmedUserPrompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSystemPrompt = systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        appSettings.lastCustomPrompt = trimmedUserPrompt
        appSettings.lastCustomSystemPrompt = trimmedSystemPrompt
        
        showingSaveConfirmation = true
        
        let notificationManager = NotificationManager()
        if trimmedUserPrompt.isEmpty && trimmedSystemPrompt.isEmpty {
            notificationManager.showInfoNotification(
                title: "Custom Prompts Cleared",
                message: "Reverted to default image processing behavior"
            )
        } else {
            notificationManager.showInfoNotification(
                title: "Custom Prompts Saved",
                message: "Use the main Process Screenshot button to apply your custom prompts"
            )
        }
    }
    
    private func clearCustomPrompt() {
        userPrompt = ""
        systemPrompt = ""
        
        appSettings.lastCustomPrompt = ""
        appSettings.lastCustomSystemPrompt = ""
        appSettings.lastCustomPromptResult = ""
        appSettings.lastCustomPromptScreenshot = nil
        appSettings.lastProcessingSource = .none
        
        showingSaveConfirmation = true
        
        let notificationManager = NotificationManager()
        notificationManager.showInfoNotification(
            title: "Custom Prompts Cleared",
            message: "Reset to default image processing behavior"
        )
    }
    
    private func applyPromptSet(_ promptSet: AppSettings.PromptSet) {
        appSettings.selectedPromptSet = promptSet
        
        systemPrompt = screenMateEngine.getPredefinedSystemPrompt(for: promptSet)
        userPrompt = screenMateEngine.getPredefinedUserPrompt(for: promptSet)
        
        let notificationManager = NotificationManager()
        notificationManager.showInfoNotification(
            title: "Applied \(promptSet.displayName)",
            message: "Predefined prompts loaded. Save to apply them."
        )
    }
}