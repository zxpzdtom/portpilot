import AppKit
import Foundation
import SwiftUI

enum AppCopy {
    static var isChinese: Bool {
        Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true
    }

    static func text(_ zh: String, _ en: String) -> String {
        isChinese ? zh : en
    }
}

enum AppLinks {
    static let repository = "https://github.com/zxpzdtom/portpilot"
    static let releases = "https://github.com/zxpzdtom/portpilot/releases"
    static let latestReleaseAPI = "https://api.github.com/repos/zxpzdtom/portpilot/releases/latest"
}

enum Motion {
    static let micro = 0.08
    static let quick = 0.15
    static let fast = 0.25
    static let medium = 0.35
    static let verySlow = 0.50
    static let stagger = 0.04
    static let iconStartScale: CGFloat = 0.25
    static let dropdownPreScale: CGFloat = 0.97
    static let dropdownCloseScale: CGFloat = 0.99
    static let pressScale: CGFloat = 0.96
    static let smallBlur: CGFloat = 2
    static let mediumBlur: CGFloat = 3

    static func smoothOut(_ duration: Double = fast) -> Animation {
        .timingCurve(0.22, 1, 0.36, 1, duration: duration)
    }

    static func iconSwap(_ duration: Double = fast) -> Animation {
        .easeInOut(duration: duration)
    }

    static func linear(_ duration: Double) -> Animation {
        .linear(duration: duration)
    }
}


extension NSImage {
    static func portPilotMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            let path = NSBezierPath()
            path.lineWidth = 1.9
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.move(to: NSPoint(x: 5.2, y: 12.6))
            path.line(to: NSPoint(x: 8.7, y: 9.0))
            path.line(to: NSPoint(x: 12.8, y: 9.0))
            path.move(to: NSPoint(x: 5.2, y: 5.4))
            path.line(to: NSPoint(x: 8.7, y: 9.0))
            path.stroke()

            let nodeRadius: CGFloat = 1.9
            for point in [NSPoint(x: 5.2, y: 12.6), NSPoint(x: 5.2, y: 5.4), NSPoint(x: 12.8, y: 9.0)] {
                let nodeRect = NSRect(
                    x: point.x - nodeRadius,
                    y: point.y - nodeRadius,
                    width: nodeRadius * 2,
                    height: nodeRadius * 2
                )
                NSBezierPath(ovalIn: nodeRect).fill()
            }

            let pilotRect = NSRect(x: 10.8, y: 7.0, width: 4.0, height: 4.0)
            NSBezierPath(ovalIn: pilotRect).stroke()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "PortPilot"
        return image
    }
}
