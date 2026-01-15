# FlashReader

A Spritz-style RSVP (Rapid Serial Visual Presentation) speed reading app for macOS.

![macOS](https://img.shields.io/badge/macOS-14.0+-black)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## What It Does

Displays text one word at a time with a highlighted **ORP (Optimal Recognition Point)** letter. This technique reduces eye movement and can help with focus and reading speed.

## Features

- Clean, distraction-free reading interface
- Adjustable speed (100-1000 WPM)
- Keyboard-driven controls
- Spritz-style guide lines for eye positioning
- Progress indicator

## Install

1. Download `FlashReader-1.0.0.zip` from [Releases](https://github.com/justinjlamb/FlashReader/releases)
2. Unzip and drag `FlashReader.app` to Applications
3. On first launch, right-click → Open (to bypass Gatekeeper for unsigned apps)

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Play / Pause |
| ↑ | Increase speed (+25 WPM) |
| ↓ | Decrease speed (-25 WPM) |
| ← | Back 10 words |
| → | Forward 10 words |
| Esc | Stop and reset |
| ? | Show help |

## Build from Source

Requires macOS 14.0+ (Sonoma) and Xcode 15+.

```bash
git clone https://github.com/justinjlamb/FlashReader.git
cd FlashReader
xcodebuild -scheme FlashReader -configuration Release build
```

The built app will be in `~/Library/Developer/Xcode/DerivedData/FlashReader-*/Build/Products/Release/`.

Or open `FlashReader.xcodeproj` in Xcode and build from there.

## Usage

1. Launch FlashReader
2. Paste or type text into the input area
3. Press **Cmd+Return** or click "Start Reading"
4. Use **Space** to pause/resume, **arrows** to adjust speed

## License

MIT
