import SwiftUI

/// This view provides a simple interface for text-to-speech generation.
struct ContentView: View {
  /// The view model that manages the TTS engine and audio playback
  @ObservedObject var viewModel: TestAppModel
  
  /// The text input from the user that will be converted to speech
  @State private var inputText: String = ""

  var body: some View {
    VStack {
      Spacer()
      
      // Text input field for entering speech content
      TextField("Type something to say...", text: $inputText)
        .padding()
        .background(Color(.systemGray))
        .cornerRadius(8)
        .padding(.horizontal)

      // Voice selection picker
      Picker("Selected Voice: ", selection: $viewModel.selectedVoice) {
        ForEach(viewModel.voiceNames, id: \.self) { voice in
          Text(voice)
            .foregroundStyle(Color.black)
            .tag(voice)
        }
      }
      .accentColor(.black)
      .foregroundColor(.black)
      .pickerStyle(.menu)
      .padding(.horizontal)
      .tint(.accentColor)
      .background(.gray)
      
      // Button to trigger text-to-speech synthesis
      Button {
        if !inputText.isEmpty {
          viewModel.say(inputText)
        } else {
          viewModel.say("Please type something first")
        }
      } label: {
        HStack(alignment: .center) {
          Spacer()
          Text("Say something")
            .foregroundColor(.white)
            .frame(height: 50)
          Spacer()
        }
        .background(.black)
        .padding(.horizontal)
      }

      Spacer()
    }
    .background(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  ContentView(viewModel: TestAppModel())
}
