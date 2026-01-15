import SwiftUI

extension Color {
    static let void = Color(red: 0, green: 0, blue: 0)
    static let orpAccent = Color(red: 0.8, green: 0.3, blue: 0.3)  // Muted red, easier on eyes
    static let orpAccentDim = Color(red: 0.8, green: 0.3, blue: 0.3).opacity(0.2)
    static let guideLine = Color.white.opacity(0.25)  // Match control bar opacity
}

struct WordDisplayView: View {
    let word: Word
    let isPaused: Bool

    private let font = Font.system(size: 48, design: .monospaced)
    private let guideLineWidth: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let textHeight: CGFloat = 58  // Approximate height for 48pt text
            let verticalGap: CGFloat = 48  // Gap between text and guide lines
            let xHeightOffset: CGFloat = 4  // Shift down to center on lowercase x-height

            ZStack {
                // Guide lines
                GuideLines(
                    centerX: centerX,
                    centerY: centerY + xHeightOffset,
                    textHeight: textHeight,
                    verticalGap: verticalGap,
                    lineWidth: guideLineWidth
                )

                // Word display
                HStack(spacing: 0) {
                    // Before ORP - right-aligned
                    Text(word.beforeORP)
                        .font(font)
                        .foregroundStyle(.white)
                        .frame(width: centerX - orpOffset, alignment: .trailing)

                    // ORP character - centered
                    Text(word.orpCharacter)
                        .font(font)
                        .foregroundStyle(Color.orpAccent)

                    // After ORP - left-aligned
                    Text(word.afterORP)
                        .font(font)
                        .foregroundStyle(.white)
                        .frame(width: centerX - orpOffset, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.void)
    }

    /// Offset to account for ORP character width centering
    private var orpOffset: CGFloat {
        // Half the width of a monospace character at 48pt
        // SF Mono at 48pt is approximately 29pt wide
        14.5
    }
}

// MARK: - Guide Lines

struct GuideLines: View {
    let centerX: CGFloat
    let centerY: CGFloat
    let textHeight: CGFloat
    let verticalGap: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        Canvas { context, size in
            let topLineY = centerY - textHeight / 2 - verticalGap
            let bottomLineY = centerY + textHeight / 2 + verticalGap
            let verticalTickHeight: CGFloat = 32

            // Top horizontal line
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: topLineY))
                    path.addLine(to: CGPoint(x: size.width, y: topLineY))
                },
                with: .color(Color.guideLine),
                lineWidth: lineWidth
            )

            // Bottom horizontal line
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: bottomLineY))
                    path.addLine(to: CGPoint(x: size.width, y: bottomLineY))
                },
                with: .color(Color.guideLine),
                lineWidth: lineWidth
            )

            // Top vertical tick at ORP position
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: topLineY))
                    path.addLine(to: CGPoint(x: centerX, y: topLineY + verticalTickHeight))
                },
                with: .color(Color.guideLine),
                lineWidth: lineWidth
            )

            // Bottom vertical tick at ORP position
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: bottomLineY))
                    path.addLine(to: CGPoint(x: centerX, y: bottomLineY - verticalTickHeight))
                },
                with: .color(Color.guideLine),
                lineWidth: lineWidth
            )
        }
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
