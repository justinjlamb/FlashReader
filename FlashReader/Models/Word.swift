import Foundation

/// Represents a single word with its ORP (Optimal Recognition Point) calculated
struct Word {
    let text: String
    let orpIndex: Int  // Index of the letter to highlight
    let duration: TimeInterval  // How long to display this word

    /// Initialize with just text at default WPM - ORP and duration auto-calculated
    init(_ text: String, wpm: Int = 250) {
        self.text = text
        self.orpIndex = Word.calculateORP(for: text)
        self.duration = Word.calculateDuration(for: text, wpm: wpm)
    }

    /// Initialize with explicit values (for testing/previews)
    init(text: String, orpIndex: Int, duration: TimeInterval) {
        self.text = text
        self.orpIndex = orpIndex
        self.duration = duration
    }

    // MARK: - Computed Properties for Display

    /// Characters before the ORP letter
    var beforeORP: String {
        String(text.prefix(orpIndex))
    }

    /// The ORP character to highlight
    var orpCharacter: String {
        guard orpIndex < text.count else { return "" }
        return String(text[text.index(text.startIndex, offsetBy: orpIndex)])
    }

    /// Characters after the ORP letter
    var afterORP: String {
        guard orpIndex + 1 < text.count else { return "" }
        return String(text.dropFirst(orpIndex + 1))
    }

    // MARK: - ORP Calculation

    /// Calculate ORP position based on word length
    /// ORP is slightly left of center, where the eye naturally fixates
    private static func calculateORP(for text: String) -> Int {
        let length = text.count
        guard length > 0 else { return 0 }

        // ORP positioning based on word length:
        // 1 char: position 0
        // 2-5 chars: position 1
        // 6-9 chars: position 2
        // 10-13 chars: position 3
        // 14+ chars: position 4
        switch length {
        case 1:
            return 0
        case 2...5:
            return 1
        case 6...9:
            return 2
        case 10...13:
            return 3
        default:
            return min(4, length / 3)
        }
    }

    /// Calculate display duration based on word length and punctuation
    private static func calculateDuration(for text: String, wpm: Int) -> TimeInterval {
        let baseInterval = 60.0 / Double(wpm)
        var multiplier = 1.0

        // Long word multiplier
        let length = text.count
        if length > 10 {
            multiplier *= 1.3
        } else if length > 6 {
            multiplier *= 1.15
        }

        // Punctuation pause
        if let lastChar = text.last {
            if ".!?".contains(lastChar) {
                multiplier *= 1.5
            } else if ",;:".contains(lastChar) {
                multiplier *= 1.25
            }
        }

        // Minimum 80ms
        return max(0.08, baseInterval * multiplier)
    }
}
