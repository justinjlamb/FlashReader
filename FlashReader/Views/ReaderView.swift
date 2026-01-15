import SwiftUI

struct ReaderView: View {
    @Environment(ReaderState.self) private var state
    @State private var showHelp = false
    @State private var controlBarHovered = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.void
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main reading area
                if let word = state.currentWord {
                    WordDisplayView(word: word, isPaused: !state.isPlaying)
                } else {
                    Text("No content")
                        .font(.system(size: 24, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Control bar
                ControlBar(isHovered: $controlBarHovered)
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.15)) {
                            controlBarHovered = hovering
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
            return .handled
        }
        .onKeyPress(.downArrow) {
            state.adjustSpeed(-25)
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
        }
    }
}

// MARK: - Control Bar

struct ControlBar: View {
    @Environment(ReaderState.self) private var state
    @Binding var isHovered: Bool

    private var baseOpacity: Double { isHovered ? 0.7 : 0.25 }

    var body: some View {
        HStack(spacing: 0) {
            // Left: Position counter
            Text("\(state.currentIndex + 1) / \(state.words.count)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.white.opacity(baseOpacity))
                .frame(width: 100, alignment: .leading)

            Spacer()

            // Center: Navigation controls
            HStack(spacing: 20) {
                ControlButton(
                    icon: "backward.fill",
                    action: { state.skipBack() },
                    baseOpacity: baseOpacity
                )

                // Play/Pause - slightly larger
                Button(action: { state.togglePlayPause() }) {
                    Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(state.isPlaying ? Color.orpAccent : .white.opacity(baseOpacity))
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                ControlButton(
                    icon: "forward.fill",
                    action: { state.skipForward() },
                    baseOpacity: baseOpacity
                )
            }

            Spacer()

            // Right: Speed controls
            HStack(spacing: 8) {
                ControlButton(
                    icon: "minus",
                    action: { state.adjustSpeed(-25) },
                    baseOpacity: baseOpacity
                )

                Text("\(state.currentWPM)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(baseOpacity))
                    .frame(width: 36, alignment: .center)

                ControlButton(
                    icon: "plus",
                    action: { state.adjustSpeed(25) },
                    baseOpacity: baseOpacity
                )

                Text("wpm")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.white.opacity(baseOpacity * 0.6))
            }
            .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.void)
    }
}

// MARK: - Control Button

struct ControlButton: View {
    let icon: String
    let action: () -> Void
    let baseOpacity: Double

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isPressed ? Color.orpAccent : .white.opacity(baseOpacity))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
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
