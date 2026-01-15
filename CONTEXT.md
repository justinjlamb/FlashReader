# Context

## Mode
Project

## Current Focus
Building FlashReader - a Spritz-style RSVP speed reading app for macOS. Personal tool for Justin to help with focus/attention challenges when reading. Displays one word at a time with highlighted ORP (Optimal Recognition Point) letter. Ready to start implementation.

## State
- **Last action**: Completed plan review with 3 agents (DHH, Kieran, Simplicity). Finalized architecture decisions. Cut all "user" features since this is a personal tool.
- **Next step**: Create Xcode project and start building Phase 1
- **Blockers**: None

## Open Questions
- None remaining for Phase 1

## Key Decisions
- **SwiftUI with @Observable (not ObservableObject)**
  - Why: Modern pattern, cleaner syntax, required for macOS 14+ anyway
- **DispatchSourceTimer instead of Timer**
  - Why: Timer has 5-15ms jitter from RunLoop coalescing. At 1000 WPM (60ms intervals), this creates uneven rhythm. DispatchSourceTimer with `.userInteractive` QoS gives sub-2ms precision.
- **4 files total, no folders**
  - Why: Reviewed by 3 agents. Original 18-file plan was over-engineered. Single @Observable class, pure functions inlined.
- **Warm amber ORP (#FF9500) not red**
  - Why: Red feels urgent/alarming. Amber feels like a warm reading lamp.
- **True black background (#000000)**
  - Why: "Theatrical void" aesthetic - word is the only thing that exists
- **No SwiftData in Phase 1**
  - Why: Ship faster. Add persistence only if actually needed.
- **No seizure warnings, VoiceOver mode, accessibility features**
  - Why: Personal tool for Justin only. Not distributing to others.
- **Pre-compute Word ORP segments at init**
  - Why: String indexing is O(n). Computing beforeORP/orpCharacter/afterORP on each render wastes cycles at high WPM.

## Dead Ends
- **3 ViewModels approach** - Over-engineered for single-window app
- **Service classes for ORP/timing** - Pure functions are simpler, no state needed
- **Timer (NSTimer)** - Insufficient precision for RSVP display
- **DisplayUnit protocol for "future" multi-word mode** - YAGNI, cut by all 3 reviewers
- **Separate TextProcessing.swift** - Merge into ReaderState, only one caller

## Key Details
- **Plan file**: `/Users/justin/Developer/plans/flashreader-macos-rsvp-reader.md`
- **Project directory**: `/Users/justin/Developer/FlashReader/`
- **Target**: macOS 14.0+ (Sonoma) - required for `onKeyPress`
- **No paid Apple Developer account** - building for local use only

### Final 4-File Structure
```
FlashReader/
├── FlashReaderApp.swift
├── ReaderState.swift       # @Observable + Word struct + tokenize functions
└── Views/
    ├── ReaderView.swift    # Paste area + word display
    └── WordDisplayView.swift
```

### Phase 1 Scope (Minimal)
- Paste text (Cmd+V)
- See words flash with ORP highlight (amber on black)
- Space play/pause
- Up/Down arrows: speed (+/- 25 WPM)
- Left/Right arrows: navigate words (auto-pauses)
- Progress bar (hair-thin, amber, no percentage)
- Speed indicator (static text, no animation)

### ORP Algorithm
```
Word Length → ORP Index
1 char      → 0
2-5 chars   → 1
6-9 chars   → 2
10-13 chars → 3
14+ chars   → min(4, length/3)
```

### Keyboard Controls
| Key | Action |
|-----|--------|
| Space | Play/Pause |
| ↑ | +25 WPM |
| ↓ | -25 WPM |
| ← | Back 1 word (pauses) |
| → | Forward 1 word (pauses) |
| Escape | Stop reading |

### Defaults
- WPM: 250 (range 100-1000)
- Font: 48pt
- Colors: #000000 bg, #FFFFFF text, #FF9500 ORP

---
*Last checkpoint: 2026-01-15 17:45*
