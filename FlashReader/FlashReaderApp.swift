import SwiftUI

@main
struct FlashReaderApp: App {
    @State private var readerState = ReaderState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(readerState)
                .frame(minWidth: 600, minHeight: 400)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .commands {
            // File menu
            CommandGroup(replacing: .newItem) {
                Button("New Reading") {
                    readerState.reset()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            // Playback menu
            CommandMenu("Playback") {
                Button(readerState.isPlaying ? "Pause" : "Play") {
                    readerState.togglePlayPause()
                }
                .keyboardShortcut(.space, modifiers: [])
                .disabled(!readerState.hasContent)

                Divider()

                Button("Increase Speed") {
                    readerState.adjustSpeed(25)
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                .disabled(!readerState.hasContent)

                Button("Decrease Speed") {
                    readerState.adjustSpeed(-25)
                }
                .keyboardShortcut(.downArrow, modifiers: [])
                .disabled(!readerState.hasContent)

                Divider()

                Button("Previous Word") {
                    readerState.skipBack()
                }
                .keyboardShortcut(.leftArrow, modifiers: [])
                .disabled(!readerState.hasContent)

                Button("Next Word") {
                    readerState.skipForward()
                }
                .keyboardShortcut(.rightArrow, modifiers: [])
                .disabled(!readerState.hasContent)

                Divider()

                Button("Reset") {
                    readerState.reset()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }
}
