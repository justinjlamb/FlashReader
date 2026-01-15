import XCTest
@testable import FlashReader

final class TextProcessingTests: XCTestCase {

    // MARK: - ORP Index Tests

    func testORPIndex_singleCharacter_returnsZero() {
        XCTAssertEqual(calculateORPIndex(for: "I"), 0)
        XCTAssertEqual(calculateORPIndex(for: "a"), 0)
        XCTAssertEqual(calculateORPIndex(for: "x"), 0)
    }

    func testORPIndex_twoToFiveChars_returnsOne() {
        XCTAssertEqual(calculateORPIndex(for: "to"), 1)
        XCTAssertEqual(calculateORPIndex(for: "the"), 1)
        XCTAssertEqual(calculateORPIndex(for: "word"), 1)
        XCTAssertEqual(calculateORPIndex(for: "hello"), 1)
    }

    func testORPIndex_sixToNineChars_returnsTwo() {
        XCTAssertEqual(calculateORPIndex(for: "speedy"), 2)
        XCTAssertEqual(calculateORPIndex(for: "reading"), 2)
        XCTAssertEqual(calculateORPIndex(for: "chapters"), 2)
        XCTAssertEqual(calculateORPIndex(for: "wonderful"), 2)
    }

    func testORPIndex_tenToThirteenChars_returnsThree() {
        XCTAssertEqual(calculateORPIndex(for: "incredible"), 3) // 10 chars
        XCTAssertEqual(calculateORPIndex(for: "programming"), 3) // 11 chars
        XCTAssertEqual(calculateORPIndex(for: "professional"), 3) // 12 chars
        XCTAssertEqual(calculateORPIndex(for: "understanding"), 3) // 13 chars
    }

    func testORPIndex_fourteenPlusChars_returnsMinOfFourOrLengthDividedByThree() {
        // 14 chars: length/3 = 4, min(4, 4) = 4
        XCTAssertEqual(calculateORPIndex(for: "accomplishment"), 4) // 14 chars

        // 15 chars: length/3 = 5, min(4, 5) = 4
        XCTAssertEqual(calculateORPIndex(for: "representations"), 4) // 15 chars

        // 18 chars: length/3 = 6, min(4, 6) = 4
        XCTAssertEqual(calculateORPIndex(for: "misunderstanding's"), 4) // 18 chars

        // 21 chars: length/3 = 7, min(4, 7) = 4
        XCTAssertEqual(calculateORPIndex(for: "internationalization"), 4) // 20 chars
    }

    // MARK: - Duration Tests

    func testDuration_baseDurationAt250WPM() {
        // 60 / 250 = 0.24 seconds
        let duration = calculateDisplayDuration(for: "test", wpm: 250)
        XCTAssertEqual(duration, 0.24, accuracy: 0.001)
    }

    func testDuration_baseDurationAt300WPM() {
        // 60 / 300 = 0.2 seconds
        let duration = calculateDisplayDuration(for: "test", wpm: 300)
        XCTAssertEqual(duration, 0.2, accuracy: 0.001)
    }

    func testDuration_baseDurationAt500WPM() {
        // 60 / 500 = 0.12 seconds
        let duration = calculateDisplayDuration(for: "test", wpm: 500)
        XCTAssertEqual(duration, 0.12, accuracy: 0.001)
    }

    func testDuration_longWordMultiplier() {
        // 11+ chars get 1.3x multiplier
        // Base at 250 WPM: 0.24 * 1.3 = 0.312
        let duration = calculateDisplayDuration(for: "programming", wpm: 250) // 11 chars
        XCTAssertEqual(duration, 0.312, accuracy: 0.001)
    }

    func testDuration_mediumWordMultiplier() {
        // 7-10 chars get 1.15x multiplier
        // Base at 250 WPM: 0.24 * 1.15 = 0.276
        let duration = calculateDisplayDuration(for: "reading", wpm: 250) // 7 chars
        XCTAssertEqual(duration, 0.276, accuracy: 0.001)
    }

    func testDuration_sentenceEndingPunctuation() {
        // .!? get 1.5x multiplier
        // Base at 250 WPM: 0.24 * 1.5 = 0.36
        let periodDuration = calculateDisplayDuration(for: "end.", wpm: 250)
        let exclamationDuration = calculateDisplayDuration(for: "wow!", wpm: 250)
        let questionDuration = calculateDisplayDuration(for: "why?", wpm: 250)

        XCTAssertEqual(periodDuration, 0.36, accuracy: 0.001)
        XCTAssertEqual(exclamationDuration, 0.36, accuracy: 0.001)
        XCTAssertEqual(questionDuration, 0.36, accuracy: 0.001)
    }

    func testDuration_clausePunctuation() {
        // ,;: get 1.25x multiplier
        // Base at 250 WPM: 0.24 * 1.25 = 0.30
        let commaDuration = calculateDisplayDuration(for: "hey,", wpm: 250)
        let semicolonDuration = calculateDisplayDuration(for: "here;", wpm: 250)
        let colonDuration = calculateDisplayDuration(for: "note:", wpm: 250)

        XCTAssertEqual(commaDuration, 0.30, accuracy: 0.001)
        XCTAssertEqual(semicolonDuration, 0.30, accuracy: 0.001)
        XCTAssertEqual(colonDuration, 0.30, accuracy: 0.001)
    }

    func testDuration_combinedMultipliers() {
        // Long word (11 chars) with period: 1.3 * 1.5 = 1.95
        // Base at 250 WPM: 0.24 * 1.95 = 0.468
        let duration = calculateDisplayDuration(for: "programming.", wpm: 250) // 12 chars including period
        XCTAssertEqual(duration, 0.468, accuracy: 0.001)
    }

    func testDuration_mediumWordWithPunctuation() {
        // Medium word (7 chars including punctuation) with comma: 1.15 * 1.25 = 1.4375
        // Base at 250 WPM: 0.24 * 1.4375 = 0.345
        let duration = calculateDisplayDuration(for: "longer,", wpm: 250) // 7 chars
        XCTAssertEqual(duration, 0.345, accuracy: 0.001)
    }

    func testDuration_minimumDuration() {
        // At very high WPM, should never go below 80ms
        // At 2000 WPM: 60/2000 = 0.03 seconds, but minimum is 0.08
        let duration = calculateDisplayDuration(for: "hi", wpm: 2000)
        XCTAssertEqual(duration, 0.08, accuracy: 0.001)
    }

    func testDuration_minimumDurationEnforced() {
        // Even higher WPM to ensure minimum is enforced
        let duration = calculateDisplayDuration(for: "a", wpm: 5000)
        XCTAssertGreaterThanOrEqual(duration, 0.08)
    }

    // MARK: - processText Tests

    func testProcessText_emptyString_returnsEmptyArray() {
        let result = processText("", wpm: 250)
        XCTAssertTrue(result.isEmpty)
    }

    func testProcessText_whitespaceOnly_returnsEmptyArray() {
        let result = processText("   \n\t  ", wpm: 250)
        XCTAssertTrue(result.isEmpty)
    }

    func testProcessText_singleWord_returnsOneWord() {
        let result = processText("hello", wpm: 250)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.text, "hello")
    }

    func testProcessText_multipleWords_splitsCorrectly() {
        let result = processText("hello world today", wpm: 250)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].text, "hello")
        XCTAssertEqual(result[1].text, "world")
        XCTAssertEqual(result[2].text, "today")
    }

    func testProcessText_wordsWithNewlines_splitsCorrectly() {
        let result = processText("hello\nworld\ntoday", wpm: 250)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].text, "hello")
        XCTAssertEqual(result[1].text, "world")
        XCTAssertEqual(result[2].text, "today")
    }

    func testProcessText_wordsWithTabs_splitsCorrectly() {
        let result = processText("hello\tworld\ttoday", wpm: 250)
        XCTAssertEqual(result.count, 3)
    }

    func testProcessText_multipleSpaces_handlesCorrectly() {
        let result = processText("hello    world", wpm: 250)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].text, "hello")
        XCTAssertEqual(result[1].text, "world")
    }

    func testProcessText_wordsHaveCorrectORPIndices() {
        let result = processText("I am reading", wpm: 250)
        XCTAssertEqual(result[0].orpIndex, 0)  // "I" - 1 char
        XCTAssertEqual(result[1].orpIndex, 1)  // "am" - 2 chars
        XCTAssertEqual(result[2].orpIndex, 2)  // "reading" - 7 chars
    }

    func testProcessText_wordsHaveCorrectDurations() {
        let result = processText("hi programming.", wpm: 250)

        // "hi" - 2 chars, no punctuation: 0.24
        XCTAssertEqual(result[0].duration, 0.24, accuracy: 0.001)

        // "programming." - 12 chars (long word 1.3x) with period (1.5x): 0.24 * 1.3 * 1.5 = 0.468
        XCTAssertEqual(result[1].duration, 0.468, accuracy: 0.001)
    }

    func testProcessText_preservesPunctuation() {
        let result = processText("Hello, world!", wpm: 250)
        XCTAssertEqual(result[0].text, "Hello,")
        XCTAssertEqual(result[1].text, "world!")
    }

    func testProcessText_mixedWhitespace() {
        let result = processText("  hello \n\n world \t test  ", wpm: 250)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].text, "hello")
        XCTAssertEqual(result[1].text, "world")
        XCTAssertEqual(result[2].text, "test")
    }

    // MARK: - Word Struct Integration Tests

    func testWord_beforeORPComputed() {
        let words = processText("hello", wpm: 250)
        let word = words[0]
        // "hello" has ORP at index 1, so beforeORP is "h"
        XCTAssertEqual(word.beforeORP, "h")
    }

    func testWord_orpCharacterComputed() {
        let words = processText("hello", wpm: 250)
        let word = words[0]
        // "hello" has ORP at index 1, so ORP char is "e"
        XCTAssertEqual(word.orpCharacter, "e")
    }

    func testWord_afterORPComputed() {
        let words = processText("hello", wpm: 250)
        let word = words[0]
        // "hello" has ORP at index 1, so afterORP is "llo"
        XCTAssertEqual(word.afterORP, "llo")
    }

    func testWord_singleCharacterWord() {
        let words = processText("I", wpm: 250)
        let word = words[0]
        XCTAssertEqual(word.beforeORP, "")
        XCTAssertEqual(word.orpCharacter, "I")
        XCTAssertEqual(word.afterORP, "")
    }

    // MARK: - Edge Cases

    func testORPIndex_emptyString() {
        // Edge case: empty string should return 0
        let index = calculateORPIndex(for: "")
        XCTAssertEqual(index, 0)
    }

    func testDuration_zeroWPM() {
        // Edge case: division by zero protection
        // This depends on implementation - may need to handle gracefully
        // At 1 WPM: 60/1 = 60 seconds
        let duration = calculateDisplayDuration(for: "test", wpm: 1)
        XCTAssertEqual(duration, 60.0, accuracy: 0.001)
    }

    func testProcessText_realSentence() {
        let text = "The quick brown fox jumps over the lazy dog."
        let result = processText(text, wpm: 300)

        XCTAssertEqual(result.count, 9)
        XCTAssertEqual(result.first?.text, "The")
        XCTAssertEqual(result.last?.text, "dog.")

        // Last word has period, so should have 1.5x multiplier
        let baseAt300 = 60.0 / 300.0 // 0.2 seconds
        let expectedLastDuration = baseAt300 * 1.5 // 0.3 seconds
        XCTAssertEqual(result.last?.duration ?? 0, expectedLastDuration, accuracy: 0.001)
    }
}
