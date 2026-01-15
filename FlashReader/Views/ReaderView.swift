import SwiftUI

struct ReaderView: View {
    @Environment(ReaderState.self) private var state
    @State private var showSpeedIndicator = false
    @State private var displayedWPM: Int = 250
    @State private var showHelp = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.void
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main reading area
                ZStack {
                    if let word = state.currentWord {
                        WordDisplayView(word: word, isPaused: !state.isPlaying)
                    } else {
                        Text("No content")
                            .font(.system(size: 24, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    // Speed indicator - top right
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(displayedWPM) wpm")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundStyle(Color.orpAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.void.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .opacity(showSpeedIndicator ? 1 : 0)
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                        Spacer()
                    }
                }

                // Progress bar - hair-thin at bottom
                ProgressBar(progress: state.progress)
                    .frame(height: 2)
            }

            // Help overlay
            if showHelp {
                HelpOverlay(isPresented: $showHelp)
            }
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress(.space) {
            state.togglePlayPause()
            return .handled
        }
        .onKeyPress(.upArrow) {
            state.adjustSpeed(25)
            showSpeedChange()
            return .handled
        }
        .onKeyPress(.downArrow) {
            state.adjustSpeed(-25)
            showSpeedChange()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            state.skipBack()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            state.skipForward()
            return .handled
        }
        .onKeyPress(.escape) {
            state.reset()
            return .handled
        }
        .onKeyPress(characters: CharacterSet(charactersIn: "?")) { _ in
            showHelp.toggle()
            return .handled
        }
        .onAppear {
            isFocused = true
            displayedWPM = state.currentWPM
        }
    }

    private func showSpeedChange() {
        displayedWPM = state.currentWPM
        withAnimation(.easeIn(duration: 0.15)) {
            showSpeedIndicator = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSpeedIndicator = false
            }
        }
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.orpAccentDim)

                // Filled portion with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orpAccentDim, Color.orpAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
    }
}

// MARK: - Help Overlay

struct HelpOverlay: View {
    @Binding var isPresented: Bool

    private let shortcuts: [(key: String, action: String)] = [
        ("Space", "Play / Pause"),
        ("Up", "Increase speed (+25 WPM)"),
        ("Down", "Decrease speed (-25 WPM)"),
        ("Left", "Previous word (pauses)"),
        ("Right", "Next word (pauses)"),
        ("Esc", "Stop and reset"),
        ("?", "Toggle this help")
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(alignment: .leading, spacing: 16) {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)

                Divider()
                    .background(Color.orpAccent.opacity(0.5))

                ForEach(shortcuts, id: \.key) { shortcut in
                    HStack {
                        Text(shortcut.key)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.orpAccent)
                            .frame(width: 80, alignment: .leading)

                        Text(shortcut.action)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Divider()
                    .background(Color.orpAccent.opacity(0.5))
                    .padding(.top, 8)

                Text("Press ? or click anywhere to close")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orpAccent.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    ReaderView()
        .environment(ReaderState())
        .frame(width: 800, height: 600)
}
