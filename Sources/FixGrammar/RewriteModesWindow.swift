import AppKit
import SwiftUI

final class RewriteModesWindow {
    private static var window: NSWindow?

    static func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let view = RewriteModesView()
            .frame(minWidth: 460, minHeight: 400)
        let hosting = NSHostingController(rootView: view)
        hosting.preferredContentSize = NSSize(width: 460, height: 400)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        win.title = "Rewrite Modes"
        win.contentViewController = hosting
        win.setContentSize(NSSize(width: 460, height: 400))
        win.minSize = NSSize(width: 360, height: 300)
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        window = win
    }
}

struct RewriteModesView: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach($settings.rewriteModes) { $mode in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                TextField("Name", text: $mode.name)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(size: 13, weight: .medium))
                                    .frame(maxWidth: 160)
                                Spacer()
                                Button {
                                    settings.rewriteModes.removeAll { $0.id == mode.id }
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                            }
                            TextEditor(text: $mode.prompt)
                                .font(.system(size: 12))
                                .frame(minHeight: 50, maxHeight: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(12)
            }

            Divider()

            HStack {
                Button("Add Mode") {
                    settings.rewriteModes.append(
                        RewriteMode(id: UUID(), name: "", prompt: "")
                    )
                }
                .controlSize(.small)
                Spacer()
            }
            .padding(10)
        }
    }
}
