# Context

## Mode
Project

## Current Focus
FlashReader Phase 1 is complete with visible controls and polish. App is ready for daily use.

## State
- **Last action**: Added control bar, app icon, guide lines, muted red accent
- **Next step**: Use the app, iterate based on real usage
- **Blockers**: None
- **Uncommitted changes**: None

## What's Working
- ✅ Paste text and start reading
- ✅ ORP highlighting (muted red letter)
- ✅ Keyboard controls (Space, arrows, Escape, ?)
- ✅ Progress bar (hair-thin at bottom)
- ✅ Control bar with play/pause, skip, speed display
- ✅ Spritz-style guide lines (horizontal + vertical ticks)
- ✅ Help overlay (? key)
- ✅ App icon (black void with red accent)
- ✅ Installed to /Applications

## Key Decisions
- **Muted red (#CC4D4D) instead of bright red or amber**
  - Why: Easier on eyes in dark environment, matches Spritz aesthetic
- **Guide lines with 4px x-height offset**
  - Why: Centers visually on lowercase letters, which are most common
- **Control bar at 0.25 opacity, 0.7 on hover**
  - Why: Present but recedes into the void, brightens when needed
- **Removed seizure warning**
  - Why: Personal tool, unnecessary friction

## Dead Ends
- Pulsing ORP animation - caused weird stick/fade bugs, removed entirely

## Key Details
- **Plan file**: `/Users/justin/Developer/plans/flashreader-macos-rsvp-reader.md`
- **GitHub**: https://github.com/justinjlamb/FlashReader
- **Shell alias**: `flash` (in ~/.zshrc)
- **App location**: /Applications/FlashReader.app

---
*Last checkpoint: 2026-01-15 11:20*
