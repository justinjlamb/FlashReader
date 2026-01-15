import SwiftUI

struct ContentView: View {
    @Environment(ReaderState.self) private var state
    @State private var inputText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.void
                .ignoresSafeArea()

            if state.hasContent {
                ReaderView()
            } else {
                TextInputView(inputText: $inputText, isTextFieldFocused: $isTextFieldFocused)
            }
        }
    }
}

// MARK: - Text Input View

struct TextInputView: View {
    @Environment(ReaderState.self) private var state
    @Binding var inputText: String
    var isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("FlashReader")
                    .font(.system(size: 32, weight: .light, design: .monospaced))
                    .foregroundStyle(.white)

                Text("Paste or type text to begin")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }

            VStack(spacing: 16) {
                TextEditor(text: $inputText)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .background(Color(white: 0.08))
                    .tint(Color.orpAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orpAccent.opacity(0.3), lineWidth: 1)
                    )
                    .frame(maxWidth: 600, maxHeight: 300)
                    .focused(isTextFieldFocused)

                HStack(spacing: 16) {
                    Button(action: pasteFromClipboard) {
                        Label("Paste", systemImage: "doc.on.clipboard")
                            .font(.system(size: 13, design: .monospaced))
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.orpAccent)
                    .keyboardShortcut("v", modifiers: .command)

                    Button(action: startReading) {
                        Label("Start Reading", systemImage: "play.fill")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.orpAccent)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }

            Text("Cmd+V to paste  |  Cmd+Return to start")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(48)
        .onAppear {
            isTextFieldFocused.wrappedValue = true
        }
    }

    private func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            inputText = string
        }
    }

    private func startReading() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        state.loadText(trimmed)
    }
}

#Preview("Text Input") {
    ContentView()
        .environment(ReaderState())
        .frame(width: 800, height: 600)
}
