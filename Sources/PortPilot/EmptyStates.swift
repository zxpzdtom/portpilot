import SwiftUI

struct EmptyListState: View {
    let hasQuery: Bool
    var queryText: String = ""
    var compact = false
    var onClear: (() -> Void)?

    @State private var didAppear = false

    var body: some View {
        VStack(spacing: compact ? 12 : 14) {
            emptyIcon
                .scaleEffect(didAppear ? 1 : 0.94)
                .opacity(didAppear ? 1 : 0)
                .animation(Motion.smoothOut(Motion.fast), value: didAppear)

            VStack(spacing: compact ? 4 : 5) {
                Text(hasQuery ? AppCopy.text("没有匹配结果", "No matches") : AppCopy.text("当前没有监听端口", "No listening ports"))
                    .font(.system(size: compact ? 13 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.system(size: compact ? 11 : 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)
            }
            .offset(y: didAppear ? 0 : 4)
            .opacity(didAppear ? 1 : 0)
            .animation(Motion.smoothOut(Motion.fast).delay(0.04), value: didAppear)

            if hasQuery, let onClear {
                Button(action: onClear) {
                    Label(AppCopy.text("清除搜索", "Clear search"), systemImage: "xmark.circle")
                        .font(.system(size: compact ? 11 : 12, weight: .semibold))
                        .frame(height: compact ? 28 : 32)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(CompactClearButtonStyle())
                .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .padding(.horizontal, compact ? 16 : 22)
        .padding(.vertical, compact ? 18 : 24)
        .frame(maxWidth: compact ? 260 : 320)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous))
        .shadow(color: .black.opacity(0.055), radius: 12, x: 0, y: 5)
        .overlay {
            RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous)
                .stroke(Color.primary.opacity(0.035), lineWidth: 1)
        }
        .onAppear {
            withAnimation(Motion.smoothOut(Motion.fast)) {
                didAppear = true
            }
        }
    }

    private var emptyIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: compact ? 12 : 14, style: .continuous)
                .fill(Color.accentColor.opacity(0.10))
                .frame(width: compact ? 44 : 54, height: compact ? 44 : 54)

            RoundedRectangle(cornerRadius: compact ? 8 : 10, style: .continuous)
                .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
                .frame(width: compact ? 28 : 34, height: compact ? 28 : 34)

            Image(systemName: hasQuery ? "magnifyingglass" : "dot.radiowaves.left.and.right")
                .font(.system(size: compact ? 18 : 22, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse, value: didAppear)
        }
    }

    private var message: String {
        if hasQuery {
            let trimmed = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return AppCopy.text("没有端口匹配当前搜索", "No ports match the current search") }
            return AppCopy.text("“\(trimmed)” 未匹配任何监听端口", "\"\(trimmed)\" did not match any listening port")
        }
        return AppCopy.text("本机没有可显示的 LISTEN 端口", "No visible LISTEN ports on this Mac")
    }
}
