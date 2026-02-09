import AppKit
import Carbon
import Foundation
import Combine

struct Shortcut: Equatable {
    var keyCode: UInt32
    var modifiers: UInt32 // Carbon modifier flags

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("\u{2303}") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("\u{2325}") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("\u{21E7}") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("\u{2318}") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }
}

final class Settings: ObservableObject {
    static let shared = Settings()

    @Published var ollamaURL: String {
        didSet { UserDefaults.standard.set(ollamaURL, forKey: "ollamaURL") }
    }

    @Published var modelName: String {
        didSet { UserDefaults.standard.set(modelName, forKey: "modelName") }
    }

    @Published var toneDescription: String {
        didSet { UserDefaults.standard.set(toneDescription, forKey: "toneDescription") }
    }

    @Published var grammarShortcut: Shortcut {
        didSet {
            UserDefaults.standard.set(grammarShortcut.keyCode, forKey: "grammarKeyCode")
            UserDefaults.standard.set(grammarShortcut.modifiers, forKey: "grammarModifiers")
        }
    }

    @Published var toneShortcut: Shortcut {
        didSet {
            UserDefaults.standard.set(toneShortcut.keyCode, forKey: "toneKeyCode")
            UserDefaults.standard.set(toneShortcut.modifiers, forKey: "toneModifiers")
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        self.ollamaURL = defaults.string(forKey: "ollamaURL") ?? "http://localhost:11434"
        self.modelName = defaults.string(forKey: "modelName") ?? "gemma3"
        self.toneDescription = defaults.string(forKey: "toneDescription")
            ?? "casual and friendly, like texting a close colleague"

        // Default: Ctrl+Shift+G for grammar
        let gCode = defaults.object(forKey: "grammarKeyCode") as? UInt32
            ?? UInt32(kVK_ANSI_G)
        let gMods = defaults.object(forKey: "grammarModifiers") as? UInt32
            ?? UInt32(controlKey | shiftKey)
        self.grammarShortcut = Shortcut(keyCode: gCode, modifiers: gMods)

        // Default: Ctrl+Shift+T for tone
        let tCode = defaults.object(forKey: "toneKeyCode") as? UInt32
            ?? UInt32(kVK_ANSI_T)
        let tMods = defaults.object(forKey: "toneModifiers") as? UInt32
            ?? UInt32(controlKey | shiftKey)
        self.toneShortcut = Shortcut(keyCode: tCode, modifiers: tMods)
    }
}

// Map virtual key codes to display strings
func keyCodeToString(_ keyCode: UInt32) -> String {
    let map: [UInt32: String] = [
        UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
        UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
        UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
        UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
        UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
        UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
        UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
        UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
        UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
        UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
        UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
        UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
        UInt32(kVK_ANSI_9): "9",
        UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3",
        UInt32(kVK_F4): "F4", UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6",
        UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8", UInt32(kVK_F9): "F9",
        UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12",
        UInt32(kVK_Space): "Space", UInt32(kVK_Return): "Return",
        UInt32(kVK_Tab): "Tab", UInt32(kVK_Escape): "Esc",
        UInt32(kVK_ANSI_Minus): "-", UInt32(kVK_ANSI_Equal): "=",
        UInt32(kVK_ANSI_LeftBracket): "[", UInt32(kVK_ANSI_RightBracket): "]",
        UInt32(kVK_ANSI_Semicolon): ";", UInt32(kVK_ANSI_Quote): "'",
        UInt32(kVK_ANSI_Comma): ",", UInt32(kVK_ANSI_Period): ".",
        UInt32(kVK_ANSI_Slash): "/", UInt32(kVK_ANSI_Backslash): "\\",
    ]
    return map[keyCode] ?? "?"
}

// Convert NSEvent modifier flags to Carbon modifier flags
func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
    var mods: UInt32 = 0
    if flags.contains(.command) { mods |= UInt32(cmdKey) }
    if flags.contains(.option) { mods |= UInt32(optionKey) }
    if flags.contains(.control) { mods |= UInt32(controlKey) }
    if flags.contains(.shift) { mods |= UInt32(shiftKey) }
    return mods
}
