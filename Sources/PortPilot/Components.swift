import AppKit
import SwiftUI

struct ResourceMini: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.76)
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct AppBackground: View {
    var body: some View {
        Rectangle()
            .fill(Color(nsColor: .windowBackgroundColor))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.thinMaterial)
                    .frame(height: 92)
            }
            .ignoresSafeArea()
    }
}

struct AppIconTile: View {
    let size: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .blue.opacity(0.22), radius: 12, x: 0, y: 6)
    }
}

struct SearchField: View {
    @Binding var text: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            TextField(AppCopy.text("搜索端口、PID、进程、命令", "Search port, PID, process, command"), text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.16)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .padding(.horizontal, 11)
        .frame(height: 38)
        .background(
            searchBackground,
            in: RoundedRectangle(cornerRadius: 8, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.055), lineWidth: 0.6)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.08 : 0.035), radius: 5, x: 0, y: 2)
    }

    private var searchBackground: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor)
            : Color(red: 0.992, green: 0.994, blue: 0.997)
    }
}

struct UpdateStatusInlineButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 10, weight: .semibold))
                    .frame(width: 11)
                Text(AppCopy.text("检查更新", "Check"))
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(Color.secondary)
            .padding(.horizontal, 5)
            .frame(height: 21)
            .background(background, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(AppCopy.text("检查并安装更新", "Check for and install updates"))
        .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var background: Color {
        Color.primary.opacity(0.028)
    }
}
