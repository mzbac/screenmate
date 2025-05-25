// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "toolbox",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "ToolboxCore",
      targets: ["ToolboxCore"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift-examples/", branch: "main"),
    .package(
      url: "https://github.com/huggingface/swift-transformers", .upToNextMinor(from: "0.1.20")
    ),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "ToolboxCore",
      dependencies: [
        .product(name: "MLXLLM", package: "mlx-swift-examples"),
        .product(name: "MLXLMCommon", package: "mlx-swift-examples"),
        .product(name: "MLXVLM", package: "mlx-swift-examples"),
        .product(name: "Transformers", package: "swift-transformers"),
        .product(name: "Logging", package: "swift-log"),
      ],
      path: "Sources/ToolboxCore"
    )
  ]
)
