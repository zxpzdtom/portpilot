import AppKit
import Foundation

@MainActor
final class ProcessIconStore: ObservableObject {
    static let shared = ProcessIconStore()

    @Published private var iconsByPID: [Int32: NSImage] = [:]
    private var inFlightPIDs = Set<Int32>()
    private var fallbackPIDs = Set<Int32>()
    private var fallbackImagesByKey: [ProcessFallbackIcon: NSImage] = [:]

    private init() {}

    func image(for entry: PortEntry) -> NSImage {
        iconsByPID[entry.pid] ?? fallbackImage(for: entry)
    }

    func loadIconIfNeeded(for entry: PortEntry) {
        guard iconsByPID[entry.pid] == nil,
              !fallbackPIDs.contains(entry.pid),
              !inFlightPIDs.contains(entry.pid)
        else { return }
        inFlightPIDs.insert(entry.pid)

        let pid = entry.pid
        let command = entry.command

        Task {
            let image = await ProcessIconResolver.icon(pid: pid, command: command)
            await MainActor.run {
                if let image {
                    iconsByPID[pid] = image
                } else {
                    fallbackPIDs.insert(pid)
                }
                inFlightPIDs.remove(pid)
            }
        }
    }

    private func fallbackImage(for entry: PortEntry) -> NSImage {
        let fallback = ProcessFallbackIcon(entry: entry)
        if let image = fallbackImagesByKey[fallback] {
            return image
        }

        let image = ProcessIconRenderer.fallbackImage(fallback)
        fallbackImagesByKey[fallback] = image
        return image
    }
}

enum ProcessIconResolver {
    static func icon(pid: Int32, command: String) async -> NSImage? {
        await MainActor.run {
            if let appPath = appBundlePath(in: command) {
                return preparedImage(NSWorkspace.shared.icon(forFile: appPath))
            }

            if let runningApp = NSRunningApplication(processIdentifier: pid) {
                if let hostAppPath = hostAppBundlePath(for: runningApp) {
                    return preparedImage(NSWorkspace.shared.icon(forFile: hostAppPath))
                }

                if let runningIcon = runningApp.icon {
                    return preparedImage(runningIcon)
                }
            }

            return nil
        }
    }

    private static func appBundlePath(in command: String) -> String? {
        guard let range = command.range(of: ".app", options: [.caseInsensitive]) else { return nil }

        let prefix = command[..<range.upperBound]
        let pathStart: String.Index
        if let spacedPathStart = prefix.range(of: " /", options: .backwards) {
            pathStart = prefix.index(after: spacedPathStart.lowerBound)
        } else if let slashStart = prefix.firstIndex(of: "/") {
            pathStart = slashStart
        } else {
            return nil
        }

        let path = String(prefix[pathStart..<range.upperBound])
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }

    private static func hostAppBundlePath(for runningApp: NSRunningApplication) -> String? {
        for path in [runningApp.bundleURL, runningApp.executableURL].compactMap({ $0?.path }) {
            if let appPath = enclosingAppBundlePath(in: path) {
                return appPath
            }
        }
        return nil
    }

    private static func enclosingAppBundlePath(in path: String) -> String? {
        guard let range = path.range(of: ".app", options: [.caseInsensitive]) else { return nil }

        let appPath = String(path[..<range.upperBound])
        guard FileManager.default.fileExists(atPath: appPath) else { return nil }
        return appPath
    }

    private static func preparedImage(_ image: NSImage) -> NSImage {
        let copy = image.copy() as? NSImage ?? image
        copy.size = NSSize(width: 30, height: 30)
        return copy
    }
}

struct ProcessFallbackIcon: Hashable {
    let label: String
    let tintName: String

    init(entry: PortEntry) {
        let text = "\(entry.processName) \(entry.command) \(entry.appHint)".lowercased()

        if text.contains("node") {
            label = "node"
            tintName = "green"
        } else if text.contains("python") || text.contains("django") || text.contains("flask") || text.contains("uvicorn") {
            label = "py"
            tintName = "blue"
        } else if text.contains("ruby") || text.contains("rails") {
            label = "rb"
            tintName = "red"
        } else if text.contains("java") {
            label = "java"
            tintName = "orange"
        } else if text.contains("bun") {
            label = "bun"
            tintName = "orange"
        } else if text.contains("deno") {
            label = "deno"
            tintName = "green"
        } else {
            label = "exec"
            tintName = "green"
        }
    }

    var tint: NSColor {
        switch tintName {
        case "blue":
            return .systemBlue
        case "red":
            return .systemRed
        case "orange":
            return .systemOrange
        case "gray":
            return .secondaryLabelColor
        default:
            return .systemGreen
        }
    }
}

enum ProcessIconRenderer {
    static func fallbackImage(_ fallback: ProcessFallbackIcon) -> NSImage {
        let size = NSSize(width: 30, height: 30)
        let image = NSImage(size: size)

        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(origin: .zero, size: size)
        let shape = NSBezierPath(roundedRect: rect.insetBy(dx: 3, dy: 3), xRadius: 7.5, yRadius: 7.5)
        NSColor(calibratedWhite: 0.075, alpha: 1).setFill()
        shape.fill()

        NSColor.white.withAlphaComponent(0.08).setStroke()
        shape.lineWidth = 0.6
        shape.stroke()

        let label = fallback.label
        let fontSize: CGFloat = label.count > 3 ? 5.9 : 6.7
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: fallback.tint
        ]
        let attributed = NSAttributedString(string: label, attributes: attributes)
        let textSize = attributed.size()
        attributed.draw(
            at: NSPoint(
                x: 7.1,
                y: size.height - textSize.height - 9.0
            )
        )

        image.size = size
        return image
    }
}
