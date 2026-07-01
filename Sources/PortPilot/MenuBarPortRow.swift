import AppKit
import Foundation
import SwiftUI

struct MenuBarPortRow: View {
    let entry: PortEntry
    let isSelected: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void

    @State private var isHovering = false

    private var showsActions: Bool {
        isHovering || isSelected
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Image(systemName: iconName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(scopeColor)
                        .frame(width: 16)
                    Text(verbatim: "\(entry.port)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }

                HStack(spacing: 5) {
                    Circle()
                        .fill(scopeColor)
                        .frame(width: 6, height: 6)
                    Text(entry.scopeLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(scopeColor)
                }
                .padding(.leading, 23)
            }
            .frame(width: 78, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.processName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Text(entry.runtimeLabel)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 5)

            ZStack(alignment: .trailing) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.cpuLabel)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(entry.cpuPercent >= 20 ? .orange : .secondary)
                    Text(entry.memoryLabel)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.purple)
                }
                .monospacedDigit()
                .opacity(showsActions ? 0 : 1)
                .blur(radius: showsActions ? Motion.smallBlur : 0)
                .scaleEffect(showsActions ? Motion.iconStartScale : 1, anchor: .trailing)

                MenuBarRowActions(
                    onOpen: onOpen,
                    onCopy: onCopy,
                    onTerminate: onTerminate
                )
                .opacity(showsActions ? 1 : 0)
                .blur(radius: showsActions ? 0 : Motion.smallBlur)
                .scaleEffect(showsActions ? 1 : Motion.iconStartScale, anchor: .trailing)
            }
            .frame(width: 84, alignment: .trailing)
            .animation(Motion.iconSwap(), value: showsActions)
        }
        .padding(.horizontal, 9)
        .frame(height: 50)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(scopeColor)
                .frame(width: 3, height: isSelected ? 26 : 0)
                .padding(.leading, 2)
        }
        .shadow(color: .black.opacity(isSelected ? 0.09 : 0.035), radius: isSelected ? 9 : 3, x: 0, y: isSelected ? 4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .onHover { hovering in
            withAnimation(Motion.smoothOut(Motion.quick)) {
                isHovering = hovering
            }
        }
        .animation(Motion.smoothOut(Motion.quick), value: isSelected)
    }

    private var rowBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.accentColor.opacity(0.15))
        }
        if isHovering {
            return AnyShapeStyle(Color.primary.opacity(0.055))
        }
        return AnyShapeStyle(.thinMaterial)
    }

    private var scopeColor: Color {
        switch entry.scope {
        case .local:
            return .green
        case .all:
            return .orange
        case .host:
            return .blue
        }
    }

    private var iconName: String {
        switch entry.appHint {
        case "Vite", "Next.js", "Nuxt", "Webpack":
            return "bolt.fill"
        case "Expo":
            return "iphone"
        case "Python", "Django", "Flask", "Uvicorn":
            return "terminal"
        case "Rails", "Ruby":
            return "diamond"
        default:
            return "network"
        }
    }
}

struct MenuBarRowActions: View {
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void

    @State private var didCopy = false
    @State private var copyFeedbackID = UUID()

    var body: some View {
        HStack(spacing: 2) {
            Button(action: onOpen) {
                Image(systemName: "safari")
                    .frame(width: 25, height: 26)
            }
            .buttonStyle(RowIconButtonStyle())
            .help(AppCopy.text("打开 localhost", "Open localhost"))

            Button(action: copyWithFeedback) {
                ZStack {
                    Image(systemName: "doc.on.doc")
                        .opacity(didCopy ? 0 : 1)
                        .blur(radius: didCopy ? Motion.smallBlur : 0)
                        .scaleEffect(didCopy ? Motion.iconStartScale : 1)

                    Image(systemName: "checkmark.circle.fill")
                        .opacity(didCopy ? 1 : 0)
                        .blur(radius: didCopy ? 0 : Motion.smallBlur)
                        .scaleEffect(didCopy ? 1 : Motion.iconStartScale)
                }
                .frame(width: 25, height: 26)
                .animation(Motion.iconSwap(), value: didCopy)
            }
            .buttonStyle(CopyFeedbackButtonStyle(isCopied: didCopy))
            .help(didCopy ? AppCopy.text("已复制", "Copied") : AppCopy.text("复制 URL", "Copy URL"))

            Button(action: onTerminate) {
                Image(systemName: "xmark.octagon")
                    .frame(width: 25, height: 26)
            }
            .buttonStyle(RowDangerIconButtonStyle())
            .help(AppCopy.text("结束进程（需确认）", "Terminate process (confirmation required)"))
        }
    }

    private func copyWithFeedback() {
        onCopy()
        let feedbackID = UUID()
        copyFeedbackID = feedbackID

        withAnimation(Motion.iconSwap()) {
            didCopy = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_050_000_000)
            await MainActor.run {
                guard copyFeedbackID == feedbackID else { return }
                withAnimation(Motion.iconSwap()) {
                    didCopy = false
                }
            }
        }
    }
}
