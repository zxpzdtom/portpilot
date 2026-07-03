import AppKit
import Foundation
import SwiftUI

struct MenuBarPortRow: View {
    let entry: PortEntry
    let isSelected: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void
    let tooltipPlacement: ActionTooltipPlacement

    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var iconStore = ProcessIconStore.shared

    private var showsActions: Bool {
        isHovering || isSelected
    }

    var body: some View {
        HStack(spacing: 8) {
            ProcessIconView(
                image: iconStore.image(for: entry)
            )
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                }
            }
            .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.processName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text(verbatim: "PID \(entry.pid)")
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(entry.runtimeLabel)
                        .lineLimit(1)
                }
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
                    onTerminate: onTerminate,
                    tooltipPlacement: tooltipPlacement
                )
                .opacity(showsActions ? 1 : 0)
                .blur(radius: showsActions ? 0 : Motion.smallBlur)
                .scaleEffect(showsActions ? 1 : Motion.iconStartScale, anchor: .trailing)
            }
            .frame(width: 72, alignment: .trailing)
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
        .overlay {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.045), lineWidth: 0.6)
        }
        .shadow(color: .black.opacity(isSelected ? 0.060 : 0.030), radius: isSelected ? 7 : 4, x: 0, y: isSelected ? 2 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .onHover { hovering in
            withAnimation(Motion.smoothOut(Motion.quick)) {
                isHovering = hovering
            }
        }
        .onAppear {
            iconStore.loadIconIfNeeded(for: entry)
        }
        .zIndex(isHovering ? 200 : (isSelected ? 100 : 0))
        .animation(Motion.smoothOut(Motion.quick), value: isSelected)
    }

    private var rowBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        selectedScopeSurface,
                        rowSelectedMidSurface,
                        rowSelectedEndSurface
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        if isHovering {
            return AnyShapeStyle(rowHoverSurface)
        }
        return AnyShapeStyle(rowSurface)
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

    private var rowSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor).opacity(0.90)
            : Color(red: 0.988, green: 0.990, blue: 0.994)
    }

    private var rowHoverSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor)
            : Color(red: 0.996, green: 0.997, blue: 0.999)
    }

    private var rowSelectedMidSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor)
            : Color(red: 0.982, green: 0.987, blue: 0.992)
    }

    private var rowSelectedEndSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor).opacity(0.92)
            : Color(red: 0.970, green: 0.978, blue: 0.987)
    }

    private var selectedScopeSurface: Color {
        if colorScheme == .dark {
            return scopeColor.opacity(0.18)
        }

        switch entry.scope {
        case .local:
            return Color(red: 0.914, green: 0.976, blue: 0.938)
        case .all:
            return Color(red: 1.000, green: 0.936, blue: 0.882)
        case .host:
            return Color(red: 0.910, green: 0.950, blue: 1.000)
        }
    }

}

struct ProcessIconView: View {
    let image: NSImage

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 28, height: 28)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.black.opacity(colorScheme == .dark ? 0 : 0.10), lineWidth: 0.5)
            }
            .frame(width: 32, height: 32)
            .animation(Motion.iconSwap(), value: ObjectIdentifier(image))
    }
}

struct MenuBarRowActions: View {
    let onOpen: () -> Void
    let onCopy: () -> Void
    let onTerminate: () -> Void
    let tooltipPlacement: ActionTooltipPlacement

    @State private var didCopy = false
    @State private var copyFeedbackID = UUID()

    var body: some View {
        HStack(spacing: 2) {
            ActionTooltip(title: AppCopy.text("打开", "Open"), placement: tooltipPlacement) {
                Button(action: onOpen) {
                    Image(systemName: "safari")
                        .frame(width: 25, height: 26)
                }
                .buttonStyle(RowIconButtonStyle())
                .accessibilityLabel(AppCopy.text("打开 localhost", "Open localhost"))
            }

            ActionTooltip(title: didCopy ? AppCopy.text("已复制", "Copied") : AppCopy.text("复制", "Copy"), placement: tooltipPlacement) {
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
                .accessibilityLabel(didCopy ? AppCopy.text("已复制", "Copied") : AppCopy.text("复制 URL", "Copy URL"))
            }

            ActionTooltip(title: AppCopy.text("结束", "Terminate"), placement: tooltipPlacement) {
                Button(action: onTerminate) {
                    Image(systemName: "xmark.octagon")
                        .frame(width: 25, height: 26)
                }
                .buttonStyle(RowDangerIconButtonStyle())
                .accessibilityLabel(AppCopy.text("结束进程（需确认）", "Terminate process (confirmation required)"))
            }
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

enum ActionTooltipPlacement {
    case above
    case below

    var alignment: Alignment {
        switch self {
        case .above:
            return .top
        case .below:
            return .bottom
        }
    }

    var offsetY: CGFloat {
        switch self {
        case .above:
            return -24
        case .below:
            return 24
        }
    }

    var scaleAnchor: UnitPoint {
        switch self {
        case .above:
            return .bottom
        case .below:
            return .top
        }
    }
}

struct ActionTooltip<Content: View>: View {
    let title: String
    let placement: ActionTooltipPlacement
    @ViewBuilder let content: Content

    @State private var isHovering = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .overlay(alignment: placement.alignment) {
                if isHovering {
                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 7)
                        .frame(height: 22)
                        .background(tooltipBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.07), lineWidth: 0.6)
                        }
                        .shadow(color: .black.opacity(colorScheme == .dark ? 0.18 : 0.08), radius: 8, x: 0, y: 4)
                        .offset(y: placement.offsetY)
                        .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: placement.scaleAnchor)))
                        .zIndex(2)
                }
            }
            .onHover { hovering in
                let animation = reduceMotion
                    ? Animation.linear(duration: 0.01)
                    : Motion.smoothOut(hovering ? Motion.quick : Motion.micro).delay(hovering ? Motion.micro : 0)
                withAnimation(animation) {
                    isHovering = hovering
                }
            }
    }

    private var tooltipBackground: some ShapeStyle {
        AnyShapeStyle(
            Color(nsColor: colorScheme == .dark ? .controlBackgroundColor : .windowBackgroundColor)
                .opacity(colorScheme == .dark ? 0.94 : 0.96)
        )
    }
}
