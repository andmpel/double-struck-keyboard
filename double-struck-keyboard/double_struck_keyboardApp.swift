//
//  double_struck_keyboardApp.swift
//  double-struck-keyboard
//
//  Created by Andrew Pelletier on 8/26/25.
//

import SwiftUI

// MARK: - Unicode Mapping (shared with keyboard extension)
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

@main
struct double_struck_keyboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

