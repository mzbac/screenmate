# ScreenMate

ScreenMate is a powerful macOS menu bar application that allows you to analyze screenshots using local Vision Language Models (VLMs). It processes your screenshots entirely on-device using MLX Swift for optimal privacy and performance.

## Features

### 🖼️ Screenshot Analysis
- In-memory screenshot capture with system integration
- Real-time image processing using local VLMs
- OCR (Optical Character Recognition) capabilities
- Custom prompt support for specialized analysis

### 🤖 Vision Language Models
- Support for multiple VLM models
- Local processing - no data sent to external servers

### 🎯 Smart Analysis Modes
- Quick OCR mode with optimized prompts
- Custom analysis mode with user-defined prompts
- Interactive floating prompt panel
- Real-time preview of captured images

### 🔧 System Integration
- Clean menu bar interface (no Dock icon)
- Auto-start at login support
- Native macOS screenshot integration
- System notifications for processing status

## Requirements

- macOS 14.0 or later
- Apple Silicon Mac (M1/M2/M3)
- Internet connection (only for initial model downloads)
- Screen recording permission (for screenshot capture)

## Installation

### From Source

1. Clone the repository:
```bash
git clone <repository-url>
cd ScreenMate
```

2. Open the project in Xcode:
```bash
open ScreenMate.xcodeproj
```

3. Build and run the project
4. Grant screen recording permission when prompted

## Usage

### Initial Setup
1. Click the ScreenMate icon in your menu bar
2. Open Settings and select your preferred VLM model
3. Click "Load/Change VLM Model" and wait for initialization

### Basic Screenshot Analysis
1. Click "Process Screenshot" in the menu bar interface
2. Select the area you want to analyze
3. View the analysis results in the interface

### Custom Prompts
1. Click "Custom Prompt" to open the prompt panel
2. Enter your analysis instructions
3. Click "Take Screenshot & Process with This Prompt"
4. View custom analysis results

### Settings Configuration
- VLM model selection
- Auto-start preferences
- Default processing parameters

## Technical Details

### Core Components

- **ScreenMateEngine**: Core VLM processing using MLX Swift
- **MenuBarManager**: System menu bar integration
- **ScreenshotManager**: In-memory screenshot handling
- **CustomPromptPanel**: Floating prompt interface

### Technologies

- **UI**: SwiftUI + AppKit integration
- **ML**: MLX Swift framework
- **Image Processing**: Native macOS APIs
- **State Management**: SwiftUI Observable Objects

### Dependencies

- MLX Swift
- MLXLLM
- MLXLMCommon
- Tokenizers
- Hub

## Privacy & Security

ScreenMate prioritizes your privacy:

- All processing happens locally on your device
- Screenshots are processed in-memory
- No data collection or external API calls
- Internet access only needed for initial model downloads

## Development

### Project Structure
```
ScreenMate/
├── ScreenMate/           # App bundle
├── Sources/
│   └── ToolboxCore/     # Core functionality
│       ├── UI/          # SwiftUI views
│       ├── SystemIntegration/
│       └── Shared/      # Shared utilities
└── Package.swift        # Swift Package Manager
```

### Building from Source
1. Ensure Xcode 14.0+ is installed
2. Clone the repository
3. Open `ScreenMate.xcodeproj`
4. Build and run (⌘+R)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

ScreenMate relies on several excellent open-source projects:

- [MLX Swift](https://github.com/ml-explore/mlx-swift) 
- [Swift Transformers](https://github.com/huggingface/swift-transformers)

We are grateful to the teams behind these projects for making local AI processing possible on Apple Silicon.