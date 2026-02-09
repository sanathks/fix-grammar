import AppKit
import SwiftUI
import Combine

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var currentPanel: ResultPanel?
    private var cancellables = Set<AnyCancellable>()

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupHotkeys()
        observeShortcutChanges()

        if !AccessibilityService.isTrusted() {
            AccessibilityService.requestPermission()
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "text.badge.checkmark",
                accessibilityDescription: "FixGrammar"
            )
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: SettingsView())
    }

    private func setupHotkeys() {
        let settings = Settings.shared
        HotkeyManager.shared.register(
            grammar: settings.grammarShortcut,
            tone: settings.toneShortcut,
            onGrammar: { [weak self] in self?.handleHotkey(mode: .grammar) },
            onTone: { [weak self] in self?.handleHotkey(mode: .tone) }
        )
    }

    private func observeShortcutChanges() {
        let settings = Settings.shared
        Publishers.CombineLatest(
            settings.$grammarShortcut,
            settings.$toneShortcut
        )
        .dropFirst() // skip initial value
        .sink { grammar, tone in
            HotkeyManager.shared.updateShortcuts(grammar: grammar, tone: tone)
        }
        .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func handleHotkey(mode: PromptMode) {
        guard AccessibilityService.isTrusted() else {
            AccessibilityService.requestPermission()
            return
        }

        guard let text = AccessibilityService.shared.getSelectedText(), !text.isEmpty else {
            return
        }

        let title = mode == .grammar ? "Fix Grammar" : "Add My Tone"
        let prompt = Prompts.build(for: mode, text: text)
        let selectionRect = AccessibilityService.shared.getSelectionRect()

        currentPanel?.close()

        let panel = ResultPanel(title: title)
        currentPanel = panel

        panel.show(
            near: selectionRect,
            onReplace: { [weak self] result in
                self?.currentPanel = nil
                AccessibilityService.shared.replaceTextInSourceApp(result)
            },
            onCopy: { [weak self] result in
                self?.currentPanel = nil
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(result, forType: .string)
            }
        )

        OllamaService.shared.generate(prompt: prompt) { result in
            switch result {
            case .success(let corrected):
                panel.updateResult(corrected)
            case .failure(let err):
                panel.updateError(err.localizedDescription)
            }
        }
    }
}
