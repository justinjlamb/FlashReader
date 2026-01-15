# Context

## Mode
Project

## Current Focus
FlashReader Phase 1 is built and working. Now addressing UX issue: the reading view is too minimal - user can't see speed, play/pause state, or any controls. Need to add visible UI controls while keeping the focused aesthetic.

## State
- **Last action**: Completed Phase 1 build. App runs, 34 tests pass, pushed to GitHub.
- **Next step**: Add visible controls to ReaderView (speed display, play/pause, navigation buttons)
- **Blockers**: None
- **Uncommitted changes**: None

## Open Questions
- How prominent should controls be? Always visible vs. fade on hover?
- Position: bottom bar, top bar, or floating?

## Key Decisions
- **SwiftUI with @Observable (not ObservableObject)**
  - Why: Modern pattern, cleaner syntax, required for macOS 14+ anyway
- **DispatchSourceTimer instead of Timer**
  - Why: Timer has 5-15ms jitter from RunLoop coalescing. At 1000 WPM (60ms intervals), this creates uneven rhythm. DispatchSourceTimer with `.userInteractive` QoS gives sub-2ms precision.
- **6 files (not 4 originally planned)**
  - Why: Ended up with separate TextProcessing.swift and Word.swift for cleaner separation and testability
- **Warm amber ORP (#FF9500) not red**
  - Why: Red feels urgent/alarming. Amber feels like a warm reading lamp.
- **True black background (#000000)**
  - Why: "Theatrical void" aesthetic - word is the only thing that exists
- **Added seizure warning back**
  - Why: Justin decided to make this sharable/open source for teaching AI students
- **Pre-compute Word ORP segments at init**
  - Why: String indexing is O(n). Computing beforeORP/orpCharacter/afterORP on each render wastes cycles at high WPM.

## Dead Ends
- **3 ViewModels approach** - Over-engineered for single-window app
- **Service classes for ORP/timing** - Pure functions are simpler, no state needed
- **Timer (NSTimer)** - Insufficient precision for RSVP display
- **DisplayUnit protocol for "future" multi-word mode** - YAGNI
- **Pure "theatrical void" with zero visible controls** - Too minimal, user can't tell current speed or state

## Key Details
- **Plan file**: `/Users/justin/Developer/plans/flashreader-macos-rsvp-reader.md`
- **GitHub**: https://github.com/justinjlamb/FlashReader
- **Shell alias**: `flash` (added to ~/.zshrc)
- **Target**: macOS 14.0+ (Sonoma) - required for `onKeyPress`

### Current File Structure
```
FlashReader/
├── FlashReaderApp.swift         # App entry + menu commands
├── ContentView.swift            # Container: seizure warning → text input → reader
├── ReaderState.swift            # @Observable state + DispatchSourceTimer
├── TextProcessing.swift         # Pure functions: processText, calculateORPIndex, calculateDisplayDuration
├── Models/
│   └── Word.swift               # Word struct with ORP calculation built-in
└── Views/
    ├── ReaderView.swift         # Main reading view + keyboard controls
    └── WordDisplayView.swift    # ORP-highlighted word display
```

### What's Working
- ✅ Paste text and start reading
- ✅ ORP highlighting (amber letter)
- ✅ Keyboard controls (Space, arrows, Escape, ?)
- ✅ Progress bar (hair-thin amber)
- ✅ Speed indicator (only shows when changed, then fades)
- ✅ Seizure warning (first launch)
- ✅ Help overlay (? key)
- ✅ 34 unit tests

### What Needs Work
- ❌ No persistent speed display (only flashes briefly when changed)
- ❌ No visible play/pause indicator
- ❌ No visible skip/navigation buttons
- User feedback: "I just see the word with an orange letter"

### Keyboard Controls (already working)
| Key | Action |
|-----|--------|
| Space | Play/Pause |
| ↑ | +25 WPM |
| ↓ | -25 WPM |
| ← | Back 10 words (pauses) |
| → | Forward 10 words (pauses) |
| Escape | Reset/stop |
| ? | Help overlay |

---
*Last checkpoint: 2026-01-15 10:22*
