//
//  KeyboardViewController.swift
//  DSKeyboard
//
//  Created by Andrew Pelletier on 8/26/25.
//

import UIKit
import SwiftUI
import Combine

// MARK: - Unicode Mapping
struct DoubleStruckMapper {
    static func map(_ input: String) -> String {
        String(input.map { mapChar($0) })
    }

    static func mapChar(_ ch: Character) -> Character {
        if let mapped = mapCharToString(ch).first { return mapped }
        return ch
    }

    static func mapCharToString(_ ch: Character) -> String {
        // Uppercase exceptions that use legacy code points
        let exceptions: [Character: String] = [
            "C": "\u{2102}", // ℂ
            "H": "\u{210D}", // ℍ
            "N": "\u{2115}", // ℕ
            "P": "\u{2119}", // ℙ
            "Q": "\u{211A}", // ℚ
            "R": "\u{211D}", // ℝ
            "Z": "\u{2124}"  // ℤ
        ]

        if let special = exceptions[ch] { return special }

        // A..Z → U+1D538..U+1D551 (except the exceptions above)
        if let ascii = ch.asciiValue, ascii >= 65, ascii <= 90 { // 'A'..'Z'
            let base: UInt32 = 0x1D538
            let offset = UInt32(ascii - 65)
            if let scalar = UnicodeScalar(base + offset) { return String(Character(scalar)) }
        }

        // a..z → U+1D552..U+1D56B
        if let ascii = ch.asciiValue, ascii >= 97, ascii <= 122 { // 'a'..'z'
            let base: UInt32 = 0x1D552
            let offset = UInt32(ascii - 97)
            if let scalar = UnicodeScalar(base + offset) { return String(Character(scalar)) }
        }

        // 0..9 → U+1D7D8..U+1D7E1
        if let ascii = ch.asciiValue, ascii >= 48, ascii <= 57 { // '0'..'9'
            let base: UInt32 = 0x1D7D8
            let offset = UInt32(ascii - 48)
            if let scalar = UnicodeScalar(base + offset) { return String(Character(scalar)) }
        }

        // Leave punctuation/whitespace unchanged
        return String(ch)
    }
}

// MARK: - Keyboard Modes
enum KeyboardMode {
    case letters
    case numbers
    case symbols
}

// MARK: - Keyboard Key Model
enum Key: Hashable {
    case char(String)         // visible text key (always inserts double‑struck)
    case number(String)       // number key (inserts double‑struck numbers)
    case symbol(String)       // symbol key
    case backspace
    case space
    case `return`
    case shift                // shift/caps
    case numberMode           // "123" button
    case symbolMode           // "#+="" button
    case letterMode           // "ABC" button
}

// MARK: - SwiftUI Keyboard View
struct KeyboardView: View {
    @ObservedObject var ctx: KeyboardContext

    var body: some View {
        VStack(spacing: 6) {
            switch ctx.currentMode {
            case .letters:
                lettersLayout
            case .numbers:
                numbersLayout
            case .symbols:
                symbolsLayout
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Letters Layout
    private var lettersLayout: some View {
        VStack(spacing: 8) {
            // Row 1: QWERTY
            HStack(spacing: 4) {
                ForEach(topRowLetters, id: \.self) { letter in
                    KeyButton(key: .char(letter), ctx: ctx) { 
                        handleKey(.char(letter))
                    }
                }
            }
            
            // Row 2: ASDF
            HStack(spacing: 4) {
                Spacer(minLength: 20)
                ForEach(middleRowLetters, id: \.self) { letter in
                    KeyButton(key: .char(letter), ctx: ctx) { 
                        handleKey(.char(letter))
                    }
                }
                Spacer(minLength: 20)
            }
            
            // Row 3: ZXCV with shift and backspace
            HStack(spacing: 4) {
                KeyButton(key: .shift, ctx: ctx, isWide: true) { 
                    handleKey(.shift)
                }
                ForEach(bottomRowLetters, id: \.self) { letter in
                    KeyButton(key: .char(letter), ctx: ctx) { 
                        handleKey(.char(letter))
                    }
                }
                KeyButton(key: .backspace, ctx: ctx, isWide: true) { 
                    handleKey(.backspace)
                }
            }
            
            // Row 4: Bottom controls
            HStack(spacing: 4) {
                KeyButton(key: .numberMode, ctx: ctx) { 
                    handleKey(.numberMode)
                }
                KeyButton(key: .space, ctx: ctx, isWide: true) { 
                    handleKey(.space)
                }
                KeyButton(key: .return, ctx: ctx, isWide: true) { 
                    handleKey(.return)
                }
            }
        }
    }
    
    // MARK: - Numbers Layout
    private var numbersLayout: some View {
        VStack(spacing: 8) {
            // Row 1: Numbers 1-0
            HStack(spacing: 4) {
                ForEach(["1","2","3","4","5","6","7","8","9","0"], id: \.self) { number in
                    KeyButton(key: .number(number), ctx: ctx) { 
                        handleKey(.number(number))
                    }
                }
            }
            
            // Row 2: Special characters
            HStack(spacing: 4) {
                ForEach(["-","/",":",";","(",")","$","&","@","\""], id: \.self) { symbol in
                    KeyButton(key: .symbol(symbol), ctx: ctx) { 
                        handleKey(.symbol(symbol))
                    }
                }
            }
            
            // Row 3: More symbols with backspace
            HStack(spacing: 4) {
                KeyButton(key: .symbolMode, ctx: ctx, isWide: true) { 
                    handleKey(.symbolMode)
                }
                ForEach([".",",","?","!","'"], id: \.self) { symbol in
                    KeyButton(key: .symbol(symbol), ctx: ctx) { 
                        handleKey(.symbol(symbol))
                    }
                }
                KeyButton(key: .backspace, ctx: ctx, isWide: true) { 
                    handleKey(.backspace)
                }
            }
            
            // Row 4: Bottom controls
            HStack(spacing: 4) {
                KeyButton(key: .letterMode, ctx: ctx) { 
                    handleKey(.letterMode)
                }
                KeyButton(key: .space, ctx: ctx, isWide: true) { 
                    handleKey(.space)
                }
                KeyButton(key: .return, ctx: ctx, isWide: true) { 
                    handleKey(.return)
                }
            }
        }
    }
    
    // MARK: - Symbols Layout
    private var symbolsLayout: some View {
        VStack(spacing: 8) {
            // Row 1: Top symbols
            HStack(spacing: 4) {
                ForEach(["[","]","{","}","#","%","^","*","+","="], id: \.self) { symbol in
                    KeyButton(key: .symbol(symbol), ctx: ctx) { 
                        handleKey(.symbol(symbol))
                    }
                }
            }
            
            // Row 2: More symbols
            HStack(spacing: 4) {
                ForEach(["_","\\","|","~","<",">","€","£","¥","•"], id: \.self) { symbol in
                    KeyButton(key: .symbol(symbol), ctx: ctx) { 
                        handleKey(.symbol(symbol))
                    }
                }
            }
            
            // Row 3: Final symbols with backspace
            HStack(spacing: 4) {
                KeyButton(key: .numberMode, ctx: ctx, isWide: true) { 
                    handleKey(.numberMode)
                }
                ForEach([".",",","?","!","'"], id: \.self) { symbol in
                    KeyButton(key: .symbol(symbol), ctx: ctx) { 
                        handleKey(.symbol(symbol))
                    }
                }
                KeyButton(key: .backspace, ctx: ctx, isWide: true) { 
                    handleKey(.backspace)
                }
            }
            
            // Row 4: Bottom controls
            HStack(spacing: 4) {
                KeyButton(key: .letterMode, ctx: ctx) { 
                    handleKey(.letterMode)
                }
                KeyButton(key: .space, ctx: ctx, isWide: true) { 
                    handleKey(.space)
                }
                KeyButton(key: .return, ctx: ctx, isWide: true) { 
                    handleKey(.return)
                }
            }
        }
    }
    
    // MARK: - Letter arrays based on shift state
    private var topRowLetters: [String] {
        if ctx.isShifted {
            return ["Q","W","E","R","T","Y","U","I","O","P"]
        } else {
            return ["q","w","e","r","t","y","u","i","o","p"]
        }
    }
    
    private var middleRowLetters: [String] {
        if ctx.isShifted {
            return ["A","S","D","F","G","H","J","K","L"]
        } else {
            return ["a","s","d","f","g","h","j","k","l"]
        }
    }
    
    private var bottomRowLetters: [String] {
        if ctx.isShifted {
            return ["Z","X","C","V","B","N","M"]
        } else {
            return ["z","x","c","v","b","n","m"]
        }
    }

    private func handleKey(_ key: Key) {
        print("🔥 Key tapped: \(key)")
        switch key {
        case .char(let s):
            let text = DoubleStruckMapper.map(s) // Always convert to double-struck
            ctx.textDocumentProxy.insertText(text)
            // Auto-unshift after typing a character (unless caps lock is on)
            if ctx.isShifted && !ctx.isCapsLock {
                ctx.isShifted = false
            }
        case .number(let n):
            let text = DoubleStruckMapper.map(n) // Convert numbers to double-struck
            ctx.textDocumentProxy.insertText(text)
        case .symbol(let s):
            ctx.textDocumentProxy.insertText(s) // Symbols inserted as-is
        case .backspace:
            ctx.textDocumentProxy.deleteBackward()
        case .space:
            ctx.textDocumentProxy.insertText(" ")
        case .return:
            ctx.textDocumentProxy.insertText("\n")
        case .shift:
            ctx.handleShift()
            print("Shift state: \(ctx.isShifted), Caps lock: \(ctx.isCapsLock)")
        case .numberMode:
            ctx.currentMode = .numbers
            print("Switched to numbers mode")
        case .symbolMode:
            ctx.currentMode = .symbols
            print("Switched to symbols mode")
        case .letterMode:
            ctx.currentMode = .letters
            print("Switched to letters mode")
        }
    }
}

struct KeyButton: View {
    let key: Key
    let ctx: KeyboardContext
    let isWide: Bool
    let action: () -> Void
    
    init(key: Key, ctx: KeyboardContext, isWide: Bool = false, action: @escaping () -> Void) {
        self.key = key
        self.ctx = ctx
        self.isWide = isWide
        self.action = action
    }

    var label: String {
        switch key {
        case .char(let s): return s
        case .number(let n): return n
        case .symbol(let s): return s
        case .backspace: return "⌫"
        case .space: return "space"
        case .return: return "return"
        case .shift: return ctx.isCapsLock ? "⇪" : (ctx.isShifted ? "⇧" : "⇧")
        case .numberMode: return "123"
        case .symbolMode: return "#+=" 
        case .letterMode: return "ABC"
        }
    }
    
    var keyWidth: CGFloat? {
        if isWide {
            switch key {
            case .shift, .backspace: return 1.5
            case .space: return 4.0  // Make space even wider since we removed other buttons
            case .return: return 2.0
            default: return nil
            }
        }
        return nil
    }
    
    var backgroundColor: Color {
        switch key {
        case .shift:
            if ctx.isCapsLock {
                return Color.blue.opacity(0.3)
            } else if ctx.isShifted {
                return Color.gray.opacity(0.4)
            } else {
                return Color(UIColor.secondarySystemBackground)
            }
        case .numberMode, .symbolMode, .letterMode:
            return Color(UIColor.tertiarySystemBackground)
        default:
            return Color(UIColor.secondarySystemBackground)
        }
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: fontSize, weight: .medium))
                .frame(maxWidth: keyWidth.map { _ in .infinity } ?? .infinity, 
                       minHeight: 50)
                .frame(width: keyWidth.map { $0 * 50 })
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var fontSize: CGFloat {
        switch key {
        case .char, .number, .symbol: return 20
        case .space, .return: return 16
        case .numberMode, .symbolMode, .letterMode: return 14
        default: return 18
        }
    }
}

// MARK: - Shared Keyboard Context
final class KeyboardContext: ObservableObject {
    @Published var isShifted = false
    @Published var isCapsLock = false
    @Published var currentMode: KeyboardMode = .letters
    
    let textDocumentProxy: UITextDocumentProxy
    private var shiftTapCount = 0
    private var lastShiftTap: Date = Date()

    init(proxy: UITextDocumentProxy) {
        self.textDocumentProxy = proxy
    }
    
    func handleShift() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastShiftTap)
        
        // Reset tap count if too much time has passed
        if timeSinceLastTap > 0.3 {
            shiftTapCount = 0
        }
        
        shiftTapCount += 1
        lastShiftTap = now
        
        if shiftTapCount >= 2 {
            // Double tap = caps lock toggle
            isCapsLock.toggle()
            isShifted = isCapsLock
            shiftTapCount = 0
        } else {
            // Single tap = shift toggle (unless caps lock is on)
            if !isCapsLock {
                isShifted.toggle()
            }
        }
    }
}

// MARK: - Keyboard View Controller
final class KeyboardViewController: UIInputViewController {
    private var host: UIHostingController<KeyboardView>?
    private var ctx: KeyboardContext!
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🎹 KeyboardViewController viewDidLoad called")
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        print("🔄 Setting up keyboard...")
        setupSwiftUIKeyboard()
    }
    
    private func setupSwiftUIKeyboard() {
        ctx = KeyboardContext(proxy: textDocumentProxy)

        let rootView = KeyboardView(ctx: ctx)
        let hosting = UIHostingController(rootView: rootView)
        
        // Configure the hosting controller
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)

        // Set up constraints
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set explicit height for the keyboard - larger for better usability
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 280)
        heightConstraint?.isActive = true

        self.host = hosting
        
        // Configure view appearance
        view.backgroundColor = UIColor.systemBackground
        print("✅ SwiftUI keyboard setup complete")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure the keyboard has proper dimensions
        if heightConstraint?.constant != 280 {
            heightConstraint?.constant = 280
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Force a layout pass to ensure everything is visible
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        
        // Update appearance based on keyboard appearance
        let isDark = textDocumentProxy.keyboardAppearance == .dark
        view.backgroundColor = isDark ? UIColor.systemBackground : UIColor.systemBackground
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // Handle orientation changes if needed
        }, completion: nil)
    }
}
