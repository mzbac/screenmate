import Foundation
import Combine
import AppKit

public class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    @Published public var selectedVLMModelIdentifier: String {
        didSet {
            UserDefaults.standard.set(selectedVLMModelIdentifier, forKey: "selectedVLMModelIdentifier")
        }
    }
    
    @Published public var lastCustomPrompt: String = "" {
        didSet {
            UserDefaults.standard.set(lastCustomPrompt, forKey: "lastCustomPrompt")
        }
    }
    
    @Published public var lastCustomSystemPrompt: String = "" {
        didSet {
            UserDefaults.standard.set(lastCustomSystemPrompt, forKey: "lastCustomSystemPrompt")
        }
    }
    
    @Published public var maxTokens: Int = 2048 {
        didSet {
            UserDefaults.standard.set(maxTokens, forKey: "maxTokens")
        }
    }
    
    @Published public var temperature: Float = 0.0 {
        didSet {
            UserDefaults.standard.set(temperature, forKey: "temperature")
        }
    }
    
    @Published public var topP: Float = 0.95 {
        didSet {
            UserDefaults.standard.set(topP, forKey: "topP")
        }
    }
    
    @Published public var repetitionPenalty: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(repetitionPenalty, forKey: "repetitionPenalty")
        }
    }
    
    @Published public var repetitionContextSize: Int = 20 {
        didSet {
            UserDefaults.standard.set(repetitionContextSize, forKey: "repetitionContextSize")
        }
    }
    
    @Published public var selectedPromptSet: PromptSet = .ocr {
        didSet {
            UserDefaults.standard.set(selectedPromptSet.rawValue, forKey: "selectedPromptSet")
        }
    }

    @Published public var lastCustomPromptResult: String = ""
    @Published public var lastCustomPromptScreenshot: NSImage?
    @Published public var lastProcessingSource: ProcessingSource = .none
    
    public let panelWidth: CGFloat = 400
    public let panelHeight: CGFloat = 500
    public let spacing: CGFloat = 8
    
    public enum ProcessingSource {
        case none
        case defaultOCR
        case customPrompt
    }
    
    public enum PromptSet: String, CaseIterable, Identifiable {
        case ocr = "ocr"
        case analysis = "analysis"
        
        public var id: String { rawValue }
        
        public var displayName: String {
            switch self {
            case .ocr:
                return "OCR (Text Extraction)"
            case .analysis:
                return "Image Analysis"
            }
        }
        
        public var description: String {
            switch self {
            case .ocr:
                return "Specialized for extracting text from images"
            case .analysis:
                return "General image analysis and description"
            }
        }
    }
    
    private init() {
        if let savedModelId = UserDefaults.standard.string(forKey: "selectedVLMModelIdentifier") {
            self.selectedVLMModelIdentifier = savedModelId
        } else {
            if let firstKey = ScreenMateEngine.supportedVLMModels.keys.sorted().first,
               let firstIdentifier = ScreenMateEngine.supportedVLMModels[firstKey] {
                self.selectedVLMModelIdentifier = firstIdentifier
            } else {
                self.selectedVLMModelIdentifier = "mlx-community/Qwen2-VL-2B-Instruct-8bit"
            }
        }
        
        self.lastCustomPrompt = UserDefaults.standard.string(forKey: "lastCustomPrompt") ?? ""
        
        self.lastCustomSystemPrompt = UserDefaults.standard.string(forKey: "lastCustomSystemPrompt") ?? ""
        
        if let savedPromptSet = UserDefaults.standard.string(forKey: "selectedPromptSet"),
           let promptSet = PromptSet(rawValue: savedPromptSet) {
            self.selectedPromptSet = promptSet
        } else {
            self.selectedPromptSet = .ocr
        }
        
        self.maxTokens = UserDefaults.standard.object(forKey: "maxTokens") as? Int ?? 2048
        self.temperature = UserDefaults.standard.object(forKey: "temperature") as? Float ?? 0.0
        self.topP = UserDefaults.standard.object(forKey: "topP") as? Float ?? 0.95
        self.repetitionPenalty = UserDefaults.standard.object(forKey: "repetitionPenalty") as? Float ?? 1.0
        self.repetitionContextSize = UserDefaults.standard.object(forKey: "repetitionContextSize") as? Int ?? 20
    }
}
