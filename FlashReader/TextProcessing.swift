import Foundation

/// Process text into an array of Word structs with ORP indices and durations
/// - Parameters:
///   - text: The input text to process
///   - wpm: Words per minute for duration calculation
/// - Returns: Array of Word structs ready for display
func processText(_ text: String, wpm: Int = 250) -> [Word] {
    text.components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .map { Word($0, wpm: wpm) }
}

/// Calculate the Optimal Recognition Point index for a word
/// The ORP is the character the eye should focus on for fastest recognition
/// - Parameter word: The word to calculate ORP for
/// - Returns: Zero-based index of the ORP character
func calculateORPIndex(for word: String) -> Int {
    let length = word.count

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

/// Calculate how long a word should be displayed based on WPM and word characteristics
/// - Parameters:
///   - word: The word to calculate duration for
///   - wpm: Base words per minute
/// - Returns: Display duration in seconds
func calculateDisplayDuration(for word: String, wpm: Int) -> TimeInterval {
    let baseInterval = 60.0 / Double(wpm)
    var multiplier = 1.0

    // Long word multiplier
    let length = word.count
    if length > 10 {
        multiplier *= 1.3
    } else if length > 6 {
        multiplier *= 1.15
    }

    // Punctuation pause - check if word ends with punctuation
    if let lastChar = word.last {
        if ".!?".contains(lastChar) {
            multiplier *= 1.5
        } else if ",;:".contains(lastChar) {
            multiplier *= 1.25
        }
    }

    let duration = baseInterval * multiplier

    // Minimum 80ms to ensure readability
    return max(0.08, duration)
}
