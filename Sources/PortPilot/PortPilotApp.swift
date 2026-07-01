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
final class PortPilotAppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private let model = PortListModel()
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var updaterController: SPUStandardUpdaterController?
    private var cancellables = Set<AnyCancellable>()
    private var keyDownMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureUpdater()
        configureStatusItem()
        configurePopover()
        configureKeyboardShortcuts()
        bindModel()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }
        cancellables.removeAll()
    }

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button, let popover else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            model.refresh()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
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

    private func configurePopover() {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 408, height: 524)
        popover.delegate = self
        popover.contentViewController = NSHostingController(
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
        self.popover = popover
    }

    private func configureKeyboardShortcuts() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command),
                  event.charactersIgnoringModifiers?.lowercased() == "q"
            else {
                return event
            }
            NSApp.terminate(nil)
            return nil
        }
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
