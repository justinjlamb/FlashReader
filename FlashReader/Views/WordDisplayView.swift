import SwiftUI

extension Color {
    static let void = Color(red: 0, green: 0, blue: 0)
    static let orpAccent = Color(red: 1.0, green: 0.584, blue: 0)  // #FF9500
    static let orpAccentDim = Color(red: 1.0, green: 0.584, blue: 0).opacity(0.2)
}

struct WordDisplayView: View {
    let word: Word
    let isPaused: Bool

    @State private var pulseScale: CGFloat = 1.15

    private let font = Font.system(size: 48, design: .monospaced)

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Before ORP - right-aligned
                Text(word.beforeORP)
                    .font(font)
                    .foregroundStyle(.white)
                    .frame(width: geometry.size.width / 2 - orpOffset, alignment: .trailing)

                // ORP character - centered
                Text(word.orpCharacter)
                    .font(font)
                    .foregroundStyle(Color.orpAccent)
                    .scaleEffect(isPaused ? pulseScale : 1.0)
                    .animation(
                        isPaused ? .easeInOut(duration: 2.0).repeatForever(autoreverses: true) : .default,
                        value: isPaused
                    )

                // After ORP - left-aligned
                Text(word.afterORP)
                    .font(font)
                    .foregroundStyle(.white)
                    .frame(width: geometry.size.width / 2 - orpOffset, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.void)
        .onChange(of: isPaused) { _, newValue in
            if newValue {
                pulseScale = 1.15
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                }
            } else {
                withAnimation(.default) {
                    pulseScale = 1.0
                }
            }
        }
    }

    /// Offset to account for ORP character width centering
    private var orpOffset: CGFloat {
        // Half the width of a monospace character at 48pt
        // SF Mono at 48pt is approximately 29pt wide
        14.5
    }
}

#Preview("Playing") {
    WordDisplayView(
        word: Word("reading"),
        isPaused: false
    )
    .frame(width: 600, height: 400)
}

#Preview("Paused - Pulsing") {
    WordDisplayView(
        word: Word("understanding"),
        isPaused: true
    )
    .frame(width: 600, height: 400)
}
