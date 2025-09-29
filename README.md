# KokoroTestApp

A SwiftUI test application for the Kokoro TTS (Text-to-Speech) model, demonstrating high-quality faster than real-time neural speech synthesis on macOS and iOS using Apple's MLX framework.

## Supported Platforms

- iOS 18.0+
- macOS 15.0+
- (Other Apple platforms may work as well)

*NOTE:* The application works only on iOS devices and it won't work on iOS emulator(s) because of lack of MLX support. 

## Installation

⚠️ **Important**: This repository uses Git LFS to store the large neural network model file (`kokoro-v1_0.safetensors`, ~600MB). You must have Git LFS installed and configured before cloning:

```bash
# Using Homebrew (macOS)
brew install git-lfs
git lfs install
```

Otherwise cloning and running the application is done as any other app:

1. **Clone the repository** (Git LFS will automatically download the model file):
   ```bash
   git clone https://github.com/yourusername/KokoroTestApp.git
   cd KokoroTestApp
   ```

2. **Verify model file**: Ensure the model file was downloaded correctly:
   ```bash
   ls -la Resources/kokoro-v1_0.safetensors
   # Should show a file of approximately 600MB
   ```

3. **Open in Xcode**:
   ```bash
   open KokoroTestApp.xcodeproj
   ```

4. **Build and run** the project in Xcode

## Features

- **High-Quality TTS**: Leverages the Kokoro neural TTS model for natural-sounding speech synthesis
- **Multiple voices**: Supports different voice options
- **Faster than real-time generation**: Fast audio generation with performance metrics 
- **MLX integration**: Optimized for Apple Silicon using the MLX machine learning framework

## Dependencies

This project uses Swift Package Manager with the following dependencies:

- **[kokoro-ios](https://github.com/mlalma/kokoro-ios)**: Kokoro TTS Swift wrapper
- **[mlx-swift](https://github.com/ml-explore/mlx-swift)**: Apple's MLX machine learning framework
- **[MisakiSwift](https://github.com/mlalma/MisakiSwift)**: Additional utilities
- **[swift-numerics](https://github.com/apple/swift-numerics)**: Numerical computing support

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
