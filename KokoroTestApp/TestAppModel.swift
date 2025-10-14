import AVFoundation
import MLX
import SwiftUI
import KokoroSwift
import Combine
import MLXUtilsLibrary

class TestAppModel: ObservableObject {  
  let kokoroTTSEngine: KokoroTTS!
  let audioEngine: AVAudioEngine!
  let playerNode: AVAudioPlayerNode!
  let voices: [String: MLXArray]
  
  @Published var voiceNames: [String] = []
  @Published var selectedVoice: String = ""

  init() {
    let modelPath = Bundle.main.url(forResource: "kokoro-v1_0", withExtension: "safetensors")!    
    kokoroTTSEngine = KokoroTTS(modelPath: modelPath)
    audioEngine = AVAudioEngine()
    playerNode = AVAudioPlayerNode()
    audioEngine.attach(playerNode)  
    
    let voiceFilePath = Bundle.main.url(forResource: "voices", withExtension: "npz")!
    voices = NpyzReader.read(fileFromPath: voiceFilePath) ?? [:]
    voiceNames = voices.keys.map { String($0.split(separator: ".")[0]) }.sorted(by: <)
    selectedVoice = voiceNames[0]

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
    let audio = try! kokoroTTSEngine.generateAudio(voice: voices[selectedVoice + ".npy"]!, language: selectedVoice.first! == "a" ? .enUS : .enGB, text: text)
    
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
    let dst: UnsafeMutablePointer<Float> = channels[0]
    audio.withUnsafeBufferPointer { buf in
        precondition(buf.baseAddress != nil)
        let byteCount = buf.count * MemoryLayout<Float>.stride

        UnsafeMutableRawPointer(dst)
          .copyMemory(from: UnsafeRawPointer(buf.baseAddress!), byteCount: byteCount)
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
