import AppKit
import Combine
import Sparkle
import SwiftUI

@main
struct PortPilotApp: App {
    @NSApplicationDelegateAdaptor(PortPilotAppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appTermination) {
                Button(AppCopy.text("退出 PortPilot", "Quit PortPilot")) {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}

@MainActor
final class PortPilotAppDelegate: NSObject, NSApplicationDelegate {
    private enum PopoverPanelLayout {
        static let contentSize = NSSize(width: 408, height: 524)
        static let shadowInset: CGFloat = 10
        static let panelSize = NSSize(width: contentSize.width + shadowInset * 2, height: contentSize.height + shadowInset * 2)
    }

    private let model = PortListModel()
    private var statusItem: NSStatusItem?
    private var popoverPanel: NSPanel?
    private weak var popoverHostingView: NSView?
    private var updaterController: SPUStandardUpdaterController?
    private var cancellables = Set<AnyCancellable>()
    private var keyDownMonitor: Any?
    private var localMouseDownMonitor: Any?
    private var globalMouseDownMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureUpdater()
        configureStatusItem()
        configurePopoverPanel()
        configureKeyboardShortcuts()
        configureDismissalMonitors()
        bindModel()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }
        if let localMouseDownMonitor {
            NSEvent.removeMonitor(localMouseDownMonitor)
        }
        if let globalMouseDownMonitor {
            NSEvent.removeMonitor(globalMouseDownMonitor)
        }
        cancellables.removeAll()
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button, let panel = popoverPanel else { return }

        if panel.isVisible {
            closePopover()
        } else {
            model.refresh()
            showPopover(relativeTo: button)
        }
    }

    @objc private func checkForUpdates(_ sender: Any?) {
        updaterController?.checkForUpdates(sender)
    }

    private func configureUpdater() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: 28)
        statusItem = item

        guard let button = item.button else { return }
        button.image = NSImage(systemSymbolName: "dot.radiowaves.left.and.right", accessibilityDescription: "PortPilot") ?? NSImage.portPilotMenuBarIcon()
        button.image?.isTemplate = true
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.title = ""
        button.action = #selector(togglePopover(_:))
        button.target = self
        button.toolTip = "PortPilot"
    }

    private func configurePopoverPanel() {
        let panelSize = PopoverPanelLayout.panelSize
        let panel = MenuBarPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .transient, .ignoresCycle]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        let hostingController = NSHostingController(
            rootView: MenuBarPopoverView(
                model: model,
                checkForUpdates: { [weak self] in
                    self?.checkForUpdates(nil)
                },
                quit: {
                    NSApp.terminate(nil)
                }
            )
        )
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        popoverHostingView = hostingController.view
        panel.contentViewController = hostingController
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
        self.popoverPanel = panel
    }

    private func showPopover(relativeTo button: NSStatusBarButton) {
        guard let panel = popoverPanel,
              let window = button.window
        else { return }

        let buttonFrameInWindow = button.convert(button.bounds, to: nil)
        let buttonFrame = window.convertToScreen(buttonFrameInWindow)
        let screenFrame = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let panelSize = panel.frame.size
        let horizontalInset: CGFloat = 12
        let contentInset = PopoverPanelLayout.shadowInset
        let preferredX = buttonFrame.midX - panelSize.width / 2
        let minX = screenFrame.minX + horizontalInset
        let maxX = screenFrame.maxX - panelSize.width - horizontalInset
        let originX = min(max(preferredX, minX), maxX)
        let originY = buttonFrame.minY - panelSize.height + contentInset - 8

        panel.setFrameOrigin(NSPoint(x: originX, y: originY))
        panel.alphaValue = 0
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(popoverHostingView)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = Motion.fast
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
    }

    private func closePopover() {
        guard let panel = popoverPanel, panel.isVisible else { return }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = Motion.quick
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().alphaValue = 0
        } completionHandler: {
            panel.orderOut(nil)
            panel.alphaValue = 1
        }
    }

    private func configureKeyboardShortcuts() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                self.closePopover()
                return nil
            }

            guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
                  event.charactersIgnoringModifiers?.lowercased() == "q"
            else {
                return event
            }
            NSApp.terminate(nil)
            return nil
        }
    }

    private func configureDismissalMonitors() {
        localMouseDownMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
            if self.shouldClosePopover(for: event) {
                self.closePopover()
            }
            return event
        }

        globalMouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                if self?.shouldClosePopover(for: event) == true {
                    self?.closePopover()
                }
            }
        }
    }

    private func shouldClosePopover(for event: NSEvent) -> Bool {
        guard let panel = popoverPanel, panel.isVisible else { return false }

        if let eventWindow = event.window, eventWindow == panel {
            return false
        }

        let location = NSEvent.mouseLocation
        if panel.frame.contains(location) {
            return false
        }

        if let button = statusItem?.button,
           let window = button.window {
            let buttonFrameInWindow = button.convert(button.bounds, to: nil)
            let buttonFrame = window.convertToScreen(buttonFrameInWindow)
            if buttonFrame.contains(location) {
                return false
            }
        }

        return true
    }

    private func bindModel() {
        model.$entries
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        model.$isScanning
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)

        model.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItem()
            }
            .store(in: &cancellables)
    }

    private func updateStatusItem() {
        guard let button = statusItem?.button else { return }
        button.title = ""
        button.contentTintColor = nil
        button.toolTip = model.entries.isEmpty ? "PortPilot" : AppCopy.text("PortPilot · \(model.entries.count) 个监听端口", "PortPilot · \(model.entries.count) listening ports")
    }

}

private final class MenuBarPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
