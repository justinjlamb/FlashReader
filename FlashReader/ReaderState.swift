import SwiftUI

@Observable
class ReaderState {
    // MARK: - Core State

    var words: [Word] = []
    var currentIndex: Int = 0
    var isPlaying: Bool = false
    var currentWPM: Int = 250

    // MARK: - UI State

    var showSpeedIndicator: Bool = false
    var hasShownSeizureWarning: Bool = UserDefaults.standard.bool(forKey: "hasShownSeizureWarning")
    var showHelpOverlay: Bool = false
    var inputText: String = ""

    // MARK: - Computed Properties

    var currentWord: Word? {
        guard currentIndex >= 0 && currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    var progress: Double {
        guard !words.isEmpty else { return 0.0 }
        return Double(currentIndex) / Double(words.count - 1)
    }

    var hasContent: Bool {
        !words.isEmpty
    }

    // MARK: - Timer

    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.flashreader.timer", qos: .userInteractive)
    private var speedIndicatorTask: DispatchWorkItem?

    // MARK: - Actions

    func loadText(_ text: String) {
        pause()
        words = tokenize(text)
        currentIndex = 0
    }

    func play() {
        guard hasContent && currentIndex < words.count else { return }

        // If at end, restart from beginning
        if currentIndex >= words.count - 1 {
            currentIndex = 0
        }

        isPlaying = true
        scheduleNextWord()
    }

    func pause() {
        isPlaying = false
        timer?.cancel()
        timer = nil
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func adjustSpeed(_ delta: Int) {
        let newWPM = currentWPM + delta
        currentWPM = min(1000, max(100, newWPM))

        // Show speed indicator briefly
        showSpeedIndicator = true

        // Cancel any pending hide task
        speedIndicatorTask?.cancel()

        // Schedule hide after 1.5 seconds
        let task = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                self?.showSpeedIndicator = false
            }
        }
        speedIndicatorTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: task)

        // If playing, reschedule with new timing
        if isPlaying {
            timer?.cancel()
            timer = nil
            scheduleNextWord()
        }
    }

    func skipBack() {
        pause()
        currentIndex = max(0, currentIndex - 10)
    }

    func skipForward() {
        pause()
        currentIndex = min(words.count - 1, currentIndex + 10)
    }

    func reset() {
        pause()
        words = []
        currentIndex = 0
        inputText = ""
    }

    func markSeizureWarningSeen() {
        hasShownSeizureWarning = true
        UserDefaults.standard.set(true, forKey: "hasShownSeizureWarning")
    }

    // MARK: - Private Methods

    private func scheduleNextWord() {
        guard isPlaying else { return }

        // Calculate interval from WPM
        // WPM = words per minute, so interval = 60 / WPM seconds
        let intervalSeconds = 60.0 / Double(currentWPM)
        let intervalNanoseconds = UInt64(intervalSeconds * 1_000_000_000)

        let newTimer = DispatchSource.makeTimerSource(queue: timerQueue)
        newTimer.schedule(deadline: .now() + .nanoseconds(Int(intervalNanoseconds)))
        newTimer.setEventHandler { [weak self] in
            self?.advance()
        }
        newTimer.resume()
        timer = newTimer
    }

    private func advance() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isPlaying else { return }

            if self.currentIndex < self.words.count - 1 {
                self.currentIndex += 1
                self.scheduleNextWord()
            } else {
                // Reached end
                self.pause()
            }
        }
    }

    // MARK: - Tokenization

    /// Tokenize text into words, preserving punctuation attached to words
    private func tokenize(_ text: String) -> [Word] {
        processText(text, wpm: currentWPM)
    }
}
