import AppKit
import SwiftUI

final class ResultPanel: NSObject, NSPopoverDelegate {
    private var popover: NSPopover?
    private var anchorWindow: NSWindow?
    private var keyMonitor: Any?
    private var clickMonitor: Any?
    private var deactivationObserver: Any?
    private let state: PopupState

    // Temporary strong refs so AppKit animations can finish before dealloc.
    private var retainedPopover: NSPopover?
    private var retainedAnchor: NSWindow?

    init(title: String) {
        self.state = PopupState(title: title)
        super.init()
    }

    func show(near selectionRect: NSRect, onReplace: @escaping (String) -> Void, onCopy: @escaping (String) -> Void) {
        state.onReplace = { [weak self] text in
            self?.close()
            onReplace(text)
        }
        state.onCopy = { [weak self] text in
            self?.close()
            onCopy(text)
        }
        state.onCancel = { [weak self] in
            self?.close()
        }

        let view = PopupView(state: state)
        let hosting = NSHostingController(rootView: view)

        let pop = NSPopover()
        pop.contentViewController = hosting
        pop.contentSize = NSSize(width: 340, height: 160)
        pop.behavior = .applicationDefined
        pop.animates = false
        pop.appearance = NSAppearance(named: .darkAqua)
        pop.delegate = self
        popover = pop

        let anchorFrame: NSRect
        if selectionRect.width > 0 && selectionRect.height > 0 {
            anchorFrame = selectionRect
        } else {
            anchorFrame = NSRect(
                x: selectionRect.origin.x - 1,
                y: selectionRect.origin.y - 1,
                width: 2, height: 2
            )
        }

        let anchor = NSWindow(
            contentRect: anchorFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        anchor.isOpaque = false
        anchor.backgroundColor = .clear
        anchor.level = .floating
        anchor.hasShadow = false
        anchor.ignoresMouseEvents = true
        anchor.collectionBehavior = [.canJoinAllSpaces, .stationary]
        anchor.orderFront(nil)
        anchorWindow = anchor

        pop.show(
            relativeTo: anchor.contentView!.bounds,
            of: anchor.contentView!,
            preferredEdge: .minY
        )

        NSApp.activate(ignoringOtherApps: true)

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            if event.keyCode == 53 {
                self.close()
                return nil
            }
            if event.keyCode == 36 {
                if !self.state.isLoading && self.state.errorMessage == nil {
                    self.state.onReplace?(self.state.resultText)
                }
                return nil
            }
            return event
        }

        clickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.close()
        }

        deactivationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.close()
        }
    }

    func updateResult(_ text: String) {
        DispatchQueue.main.async {
            self.state.isLoading = false
            self.state.resultText = text
        }
    }

    func updateError(_ message: String) {
        DispatchQueue.main.async {
            self.state.isLoading = false
            self.state.errorMessage = message
        }
    }

    func close() {
        removeMonitors()

        let pop = popover
        let anchor = anchorWindow
        popover = nil
        anchorWindow = nil

        // Keep strong refs so AppKit's internal _NSWindowTransformAnimation
        // can finish deallocating before these objects disappear.
        retainedPopover = pop
        retainedAnchor = anchor

        pop?.close()
        anchor?.orderOut(nil)

        DispatchQueue.main.async { [weak self] in
            self?.retainedPopover = nil
            self?.retainedAnchor = nil
        }
    }

    private func removeMonitors() {
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        if let observer = deactivationObserver {
            NotificationCenter.default.removeObserver(observer)
            deactivationObserver = nil
        }
    }

    func popoverDidClose(_ notification: Notification) {
        removeMonitors()
        popover = nil
        if let anchor = anchorWindow {
            anchorWindow = nil
            retainedAnchor = anchor
            anchor.orderOut(nil)
            DispatchQueue.main.async { [weak self] in
                self?.retainedAnchor = nil
            }
        }
    }
}
