import AVFoundation
import MLX
import SwiftUI
import KokoroSwift
import Combine

class TestAppModel: ObservableObject {
  var objectWillChange: ObservableObjectPublisher
  
  let kokoroTTSEngine: KokoroTTS!
  let audioEngine: AVAudioEngine!
  let playerNode: AVAudioPlayerNode!

  init() {
    let modelPath = Bundle.main.url(forResource: "kokoro-v1_0", withExtension: "safetensors")!    
    kokoroTTSEngine = KokoroTTS(modelPath: modelPath)
    audioEngine = AVAudioEngine()
    playerNode = AVAudioPlayerNode()
    audioEngine.attach(playerNode)  
    objectWillChange = ObservableObjectPublisher()

    #if os(iOS)
      do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
      } catch {
        logPrint("Failed to set up AVAudioSession: \(error.localizedDescription)")
        // Handle the error appropriately
      }
    #endif
  }

  func say(_ text: String) {
    let audio = try! kokoroTTSEngine.generateAudio(voice: .afHeart, language: .enUS, text: text)
    
    let sampleRate = Double(KokoroTTS.Constants.samplingRate)
    let audioLength = Double(audio.count) / sampleRate
    print("Audio Length: " + String(format: "%.4f", audioLength))
    print("Real Time Factor: " + String(format: "%.2f", audioLength / (BenchmarkTimer.getTimeInSec(KokoroTTS.Constants.bm_TTS) ?? 1.0)))

    let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(audio.count)) else {
      print("Couldn't create buffer")
      return
    }

    buffer.frameLength = buffer.frameCapacity
    let channels = buffer.floatChannelData!
    for i in 0 ..< audio.count {
      channels[0][i] = audio[i]
    }

    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
    do {
      try audioEngine.start()
    } catch {
      print("Audio engine failed to start: \(error.localizedDescription)")
      return
    }

    playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    playerNode.play()
  }
}
