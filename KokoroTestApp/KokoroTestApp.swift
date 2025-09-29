import SwiftUI
import MLX

@main
struct KokoroTestApp: App {
  let model = TestAppModel()
    
  init() {
    MLX.GPU.set(cacheLimit: 50 * 1024 * 1024)
    MLX.GPU.set(memoryLimit: 900 * 1024 * 1024)
  }

  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: model)
    }
  }
}
