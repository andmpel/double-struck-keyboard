# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is an iOS application project that implements a custom keyboard extension for double-struck mathematical symbols. The project consists of two main targets:

1. **double-struck-keyboard** - The main iOS app (SwiftUI-based)
2. **DSKeyboard** - The keyboard extension target (UIKit-based)

## Architecture

### App Structure
- **Main App (`double-struck-keyboard/`)**: SwiftUI-based iOS app with basic UI structure
  - `double_struck_keyboardApp.swift` - App entry point
  - `ContentView.swift` - Main view (currently placeholder)

### Keyboard Extension (`DSKeyboard/`)
- **KeyboardViewController.swift** - Core keyboard logic inheriting from `UIInputViewController`
- **Info.plist** - Extension configuration defining keyboard service capabilities

The keyboard extension is configured as:
- ASCII capable: false
- Primary language: en-US  
- Open access: false (restricted permissions)
- Right-to-left: false

## Common Development Commands

### Building
```bash
# Build main app for iOS Simulator
xcodebuild -scheme double-struck-keyboard -configuration Debug -sdk iphonesimulator build

# Build keyboard extension only
xcodebuild -scheme DSKeyboard -configuration Debug -sdk iphonesimulator build

# Build for device
xcodebuild -scheme double-struck-keyboard -configuration Debug -sdk iphoneos build

# Build for release
xcodebuild -scheme double-struck-keyboard -configuration Release -sdk iphonesimulator build
```

### Running
```bash
# Run in iOS Simulator (requires Xcode)
open double-struck-keyboard.xcodeproj
# Use Xcode's run button or Cmd+R

# List available simulators
xcrun simctl list devices available

# Install on specific simulator
xcrun simctl install <device-id> <path-to-built-app>
```

### Project Information
```bash
# List all targets and schemes  
xcodebuild -list -project double-struck-keyboard.xcodeproj

# Show build settings
xcodebuild -showBuildSettings -project double-struck-keyboard.xcodeproj -target double-struck-keyboard
```

### Cleaning
```bash
# Clean build folder
xcodebuild clean -project double-struck-keyboard.xcodeproj

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

## Development Notes

### Keyboard Extension Development
- The keyboard extension (`DSKeyboard`) runs in a separate process with limited system access
- Extension communicates with host app through shared containers or app groups (if configured)
- Keyboard appearance adapts to system dark/light mode via `UIKeyboardAppearance`
- Input mode switching handled by `handleInputModeList(from:with:)` method

### Key Files for Double-Struck Implementation
The actual double-struck character implementation will likely be added to:
- `KeyboardViewController.swift` - Character input logic
- Additional view controllers or SwiftUI views for keyboard UI
- Character mapping/conversion utilities

### Xcode Project Structure
- Uses standard iOS app + extension architecture
- Two separate targets with independent build configurations
- Extension target references main app's bundle identifier as prefix
- No external dependencies or package managers currently configured
