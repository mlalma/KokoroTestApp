import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: TestAppModel
  @State private var inputText: String = ""

  var body: some View {
    VStack {
      Spacer()
      
      TextField("Type something to say...", text: $inputText)
        .padding()
        .background(Color(.systemGray))
        .cornerRadius(8)
        .padding(.horizontal)

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
