import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var autostartManager: AutostartManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Divider()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("General")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "power")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Start at Login")
                                    .font(.body)
                                Text("Automatically start ScreenMate when you log in")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { autostartManager.isEnabled },
                                set: { newValue in
                                    autostartManager.isEnabled = newValue
                                }
                            ))
                        }
                        .padding(.vertical, 4)
                        
                        Divider()
                        
                        HStack {
                            Image(systemName: "clipboard")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Auto Copy Result to Clipboard")
                                    .font(.body)
                                Text("Automatically copy the processed text to the clipboard after successful analysis.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $appSettings.autoCopyToClipboard)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("VLM Model")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "cpu")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Select VLM Model")
                                    .font(.body)
                                Text("Choose the Vision Language Model for image processing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Picker("", selection: $appSettings.selectedVLMModelIdentifier) {
                                ForEach(Array(ScreenMateEngine.supportedVLMModels.keys.sorted()), id: \.self) { displayName in
                                    Text(displayName)
                                        .tag(ScreenMateEngine.supportedVLMModels[displayName]!)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 200)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Prompt Set")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "text.bubble")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Select Default Prompt Set")
                                    .font(.body)
                                Text("Choose between OCR text extraction or general image analysis")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Picker("", selection: $appSettings.selectedPromptSet) {
                                ForEach(AppSettings.PromptSet.allCases) { promptSet in
                                    Text(promptSet.displayName)
                                        .tag(promptSet)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 200)
                        }
                        .padding(.vertical, 4)
                        
                        if !appSettings.selectedPromptSet.description.isEmpty {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                Text(appSettings.selectedPromptSet.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 4)
                        }
                    }

                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Model Parameters")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "number")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Max Tokens")
                                        .font(.body)
                                    Text("Maximum number of tokens to generate (128-4096)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                TextField("", value: $appSettings.maxTokens, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .onSubmit {
                                        appSettings.maxTokens = max(128, min(4096, appSettings.maxTokens))
                                    }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "thermometer")
                                    .foregroundColor(.orange)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Temperature: \(appSettings.temperature, specifier: "%.2f")")
                                        .font(.body)
                                    Text("Controls randomness (0.0 = deterministic, 1.0 = very random)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            Slider(value: $appSettings.temperature, in: 0.0...1.0, step: 0.01)
                                .frame(maxWidth: .infinity)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "percent")
                                    .foregroundColor(.purple)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Top P: \(appSettings.topP, specifier: "%.2f")")
                                        .font(.body)
                                    Text("Nucleus sampling threshold (0.1-1.0)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            Slider(value: $appSettings.topP, in: 0.1...1.0, step: 0.01)
                                .frame(maxWidth: .infinity)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "repeat")
                                    .foregroundColor(.red)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Repetition Penalty: \(appSettings.repetitionPenalty, specifier: "%.2f")")
                                        .font(.body)
                                    Text("Penalty for repeating tokens (1.0 = no penalty, >1.0 = discourage repetition)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            Slider(value: $appSettings.repetitionPenalty, in: 1.0...2.0, step: 0.01)
                                .frame(maxWidth: .infinity)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "text.word.spacing")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Repetition Context Size")
                                        .font(.body)
                                    Text("Number of recent tokens to consider for repetition penalty (10-100)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                TextField("", value: $appSettings.repetitionContextSize, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 80)
                                    .onSubmit {
                                        appSettings.repetitionContextSize = max(10, min(100, appSettings.repetitionContextSize))
                                    }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button("Reset to Defaults") {
                                appSettings.maxTokens = 2048
                                appSettings.temperature = 0.0
                                appSettings.topP = 0.95
                                appSettings.repetitionPenalty = 1.0
                                appSettings.repetitionContextSize = 20
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ScreenMate")
                                    .font(.body)
                                Text("Capture screenshots and analyze images with AI")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 450, height: 600)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings.shared)
        .environmentObject(AutostartManager())
}
