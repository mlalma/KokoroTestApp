import AVFoundation
import MLX
import SwiftUI
import KokoroSwift
import Combine
import MLXUtilsLibrary

/// The view model that manages text-to-speech functionality using the Kokoro TTS engine.
/// - Loading and managing the Kokoro TTS model
/// - Managing available voice options
/// - Audio playback using AVAudioEngine
/// - Converting text to speech audio
final class TestAppModel: ObservableObject {  
  /// The Kokoro text-to-speech engine instance
  let kokoroTTSEngine: KokoroTTS!
  
  /// The audio engine used for playback
  let audioEngine: AVAudioEngine!
  
  /// The audio player node attached to the audio engine
  let playerNode: AVAudioPlayerNode!
  
  /// Dictionary of available voices, mapped by voice name to MLX array data
  let voices: [String: MLXArray]
  
  /// Array of voice names available for selection in the UI
  @Published var voiceNames: [String] = []
  
  /// The currently selected voice name
  @Published var selectedVoice: String = ""

  /// Initializes the test app model with TTS engine, audio components, and voice data.
  init() {
    // Load the Kokoro TTS model from the app bundle
    let modelPath = Bundle.main.url(forResource: "kokoro-v1_0", withExtension: "safetensors")!    
    kokoroTTSEngine = KokoroTTS(modelPath: modelPath)
    
    // Initialize audio engine and player node
    audioEngine = AVAudioEngine()
    playerNode = AVAudioPlayerNode()
    audioEngine.attach(playerNode)  
    
    // Load voice data from NPZ file
    let voiceFilePath = Bundle.main.url(forResource: "voices", withExtension: "npz")!
    voices = NpyzReader.read(fileFromPath: voiceFilePath) ?? [:]
    
    // Extract voice names and sort them alphabetically
    voiceNames = voices.keys.map { String($0.split(separator: ".")[0]) }.sorted(by: <)
    selectedVoice = voiceNames[0]

    // Configure audio session for iOS
    #if os(iOS)
      do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
      } catch {
        logPrint("Failed to set up AVAudioSession: \(error.localizedDescription)")
      }
    #endif
  }

  /// Converts the provided text to speech and plays it through the audio engine.
  /// - Parameter text: The text to be converted to speech
  func say(_ text: String) {
    // Generate audio using the selected voice
    // Language is determined by voice name: 'a' prefix = US English, otherwise GB English
    let audio = try! kokoroTTSEngine.generateAudio(voice: voices[selectedVoice + ".npy"]!, language: selectedVoice.first! == "a" ? .enUS : .enGB, text: text)
    
    // Calculate audio length and performance metrics
    let sampleRate = Double(KokoroTTS.Constants.samplingRate)
    let audioLength = Double(audio.count) / sampleRate
    // Log performance metrics
    print("Audio Length: " + String(format: "%.4f", audioLength))
    print("Real Time Factor: " + String(format: "%.2f", audioLength / (BenchmarkTimer.getTimeInSec(KokoroTTS.Constants.bm_TTS) ?? 1.0)))

    // Create audio format (mono channel at the model's sample rate)
    let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
    
    // Create PCM buffer for the audio data
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(audio.count)) else {
      print("Couldn't create buffer")
      return
    }

    // Copy audio data into the buffer
    buffer.frameLength = buffer.frameCapacity
    let channels = buffer.floatChannelData!
    let dst: UnsafeMutablePointer<Float> = channels[0]
    
    // Safely copy audio samples to the buffer
    audio.withUnsafeBufferPointer { buf in
        precondition(buf.baseAddress != nil)
        let byteCount = buf.count * MemoryLayout<Float>.stride

        UnsafeMutableRawPointer(dst)
          .copyMemory(from: UnsafeRawPointer(buf.baseAddress!), byteCount: byteCount)
    }

    // Connect the player node to the audio engine's mixer
    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
    
    // Start the audio engine
    do {
      try audioEngine.start()
    } catch {
      print("Audio engine failed to start: \(error.localizedDescription)")
      return
    }

    // Schedule and play the audio buffer
    playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    playerNode.play()
  }
}
