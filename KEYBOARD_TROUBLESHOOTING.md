# Keyboard Extension Troubleshooting Guide

## Current Issue: Keyboard showing nothing on iPhone

The current version includes both SwiftUI keyboard implementation AND a red "TEST BUTTON" fallback to help debug.

## Steps to Test:

### 1. Install & Enable Keyboard
```bash
# Build for your device
xcodebuild -scheme double-struck-keyboard -configuration Debug -sdk iphoneos build

# Or run from Xcode
open double-struck-keyboard.xcodeproj
# Use Cmd+R to run on device
```

### 2. Enable in iOS Settings
1. Go to Settings → General → Keyboard → Keyboards → Add New Keyboard
2. Find "double-struck-keyboard" in the list
3. Add it

### 3. Test the Keyboard
1. Open any app with text input (Notes, Messages, etc.)
2. Tap the text field to bring up keyboard
3. Tap the globe icon (🌐) to switch keyboards
4. Look for "double-struck-keyboard" or the red "TEST BUTTON"

## What You Should See:

### Success Case:
- A full QWERTY keyboard layout with 4 rows
- Keys for letters, numbers, backspace, space, return
- Mode toggle button (ABC/𝔻𝕊)
- Globe button to switch keyboards

### Debug Case:
- A red "TEST BUTTON" in center of keyboard area
- Tapping it should insert "TEST" into the text field

### Failure Case:
- Nothing appears (blank keyboard area)
- Keyboard doesn't appear in keyboard switcher

## Debug Information:

### Check Console Logs:
1. Connect iPhone to Mac
2. Open Console.app on Mac
3. Select your device
4. Filter for "KeyboardViewController" or "🎹"
5. Look for debug messages when switching to keyboard

### Expected Log Messages:
- "🎹 KeyboardViewController viewDidLoad called"
- "🔄 Setting up keyboard..."
- "✅ SwiftUI keyboard setup complete"
- "🚑 Fallback button added"

### Common Issues:

1. **Keyboard Not Listed**: Extension not properly included in main app bundle
2. **Blank Keyboard**: View controller setup issues or SwiftUI problems  
3. **Crashes**: Runtime errors (check Console for crash logs)
4. **No Touch Response**: Touch handling or constraints issues

### Quick Fixes to Try:

1. **Clean Build**:
   ```bash
   xcodebuild clean -project double-struck-keyboard.xcodeproj
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

2. **Reset Keyboard Settings**:
   - Remove keyboard from Settings
   - Restart iPhone
   - Re-add keyboard

3. **Check Code Signing**:
   - Ensure both app and extension have same team/signing
   - Check bundle identifiers are correct

## Current Implementation:

The keyboard now has:
- ✅ Complete SwiftUI implementation with QWERTY layout
- ✅ Double-struck character mapping
- ✅ Mode toggle functionality  
- ✅ Debug logging
- ✅ Fallback test button for debugging
- ✅ Proper view controller setup with constraints
- ✅ Height constraints for keyboard

If the red TEST BUTTON appears and works, then the issue is with the SwiftUI implementation.
If nothing appears at all, then there's a fundamental issue with the extension loading.
