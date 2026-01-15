# FlashReader

Spritz-style RSVP speed reading app for macOS. Personal tool - not for distribution.

## What This Is

Displays text one word at a time with highlighted ORP (Optimal Recognition Point) letter. Helps with focus/attention when reading.

## Tech Stack

- SwiftUI with @Observable
- macOS 14.0+ (Sonoma)
- No external dependencies for Phase 1

## Architecture

4 files, no folders:
- `FlashReaderApp.swift` - App entry
- `ReaderState.swift` - All state + Word struct + tokenize functions
- `Views/ReaderView.swift` - Main view
- `Views/WordDisplayView.swift` - ORP rendering

## Critical: Timer Precision

**Use DispatchSourceTimer, NOT Timer.** Timer has 5-15ms jitter. At 1000 WPM that ruins the reading rhythm.

```swift
private let timerQueue = DispatchQueue(label: "com.flashreader.timer", qos: .userInteractive)
```

## Design

- True black background (#000000)
- White text (#FFFFFF)
- Warm amber ORP (#FF9500)
- 48pt monospace font
- Hair-thin amber progress bar at bottom

## Plan

Full implementation details: `/Users/justin/Developer/plans/flashreader-macos-rsvp-reader.md`
