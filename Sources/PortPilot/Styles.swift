import SwiftUI

struct CompactClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.accentColor)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.16 : 0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct SortControlButtonStyle: ButtonStyle {
    let isExpanded: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isExpanded ? Color.accentColor : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.smoothOut(Motion.fast), value: isExpanded)
    }

    private func background(configuration: Configuration) -> Color {
        if isExpanded {
            return Color.accentColor.opacity(configuration.isPressed ? 0.16 : 0.10)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.09 : 0.045)
    }
}

struct SortDirectionButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.smoothOut(Motion.quick), value: isSelected)
    }

    private func background(configuration: Configuration) -> Color {
        if isSelected {
            return Color.accentColor.opacity(configuration.isPressed ? 0.17 : 0.11)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.08 : 0.035)
    }
}

struct EmptyDetailState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sidebar.right")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(AppCopy.text("选择一个端口", "Select a port"))
                .font(.headline)
            Text(AppCopy.text("这里会显示 PID、命令和快捷操作。", "PID, command, and quick actions appear here."))
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PulseDot: View {
    let isActive: Bool
    let hasError: Bool

    private var tint: Color {
        if hasError { return .red }
        return isActive ? .blue : .green
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(isActive ? 0.20 : 0))
                .frame(width: 18, height: 18)
                .scaleEffect(isActive ? 1.18 : 0.8)
                .opacity(isActive ? 1 : 0)
                .animation(isActive ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true) : .easeOut(duration: 0.16), value: isActive)
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
        }
        .frame(width: 18, height: 18)
    }
}

struct RefreshIcon: View {
    let isScanning: Bool

    var body: some View {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 14, weight: .semibold))
            .rotationEffect(.degrees(isScanning ? 360 : 0))
            .animation(isScanning ? Motion.linear(0.8).repeatForever(autoreverses: false) : Motion.smoothOut(Motion.quick), value: isScanning)
    }
}

enum AppButtonKind {
    case primary
    case quiet
    case danger
}

struct AppButtonStyle: ButtonStyle {
    let kind: AppButtonKind
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14)
            .frame(minHeight: 38)
            .foregroundStyle(foreground)
            .background(background(isPressed: configuration.isPressed), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: shadowColor, radius: configuration.isPressed ? 2 : 7, x: 0, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .opacity(isEnabled ? 1 : 0.55)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            return .white
        case .quiet:
            return .primary
        case .danger:
            return .red
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .primary:
            return .accentColor.opacity(0.22)
        case .danger:
            return .red.opacity(0.10)
        case .quiet:
            return .black.opacity(0.07)
        }
    }

    private func background(isPressed: Bool) -> some ShapeStyle {
        switch kind {
        case .primary:
            return AnyShapeStyle(Color.accentColor.opacity(isPressed ? 0.82 : 1))
        case .quiet:
            return AnyShapeStyle(Color.primary.opacity(isPressed ? 0.10 : 0.065))
        case .danger:
            return AnyShapeStyle(Color.red.opacity(isPressed ? 0.16 : 0.10))
        }
    }
}

struct RowIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .background(Color.primary.opacity(configuration.isPressed ? 0.10 : 0.045), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct CopyFeedbackButtonStyle: ButtonStyle {
    let isCopied: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(isCopied ? Color.green : Color.secondary)
            .background(background(configuration: configuration), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
            .animation(Motion.iconSwap(), value: isCopied)
    }

    private func background(configuration: Configuration) -> Color {
        if isCopied {
            return Color.green.opacity(configuration.isPressed ? 0.20 : 0.12)
        }
        return Color.primary.opacity(configuration.isPressed ? 0.10 : 0.045)
    }
}

struct RowDangerIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.red)
            .background(Color.red.opacity(configuration.isPressed ? 0.16 : 0.085), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct FooterQuitButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(Color.primary.opacity(configuration.isPressed ? 0.09 : 0.032), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .scaleEffect(configuration.isPressed ? Motion.pressScale : 1)
            .animation(Motion.smoothOut(Motion.quick), value: configuration.isPressed)
    }
}

struct StaggeredAppear: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 12))
            .blur(radius: reduceMotion ? 0 : (isVisible ? 0 : Motion.mediumBlur))
            .onAppear {
                guard !isVisible else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(reduceMotion ? .linear(duration: 0.01) : Motion.smoothOut(Motion.verySlow)) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    func staggeredAppear(delay: Double) -> some View {
        modifier(StaggeredAppear(delay: delay))
    }
}
