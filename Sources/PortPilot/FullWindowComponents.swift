import SwiftUI

struct SummaryStrip: View {
    let entries: [PortEntry]

    private var localCount: Int {
        entries.filter { $0.scope == .local }.count
    }

    private var uniqueProcessEntries: [PortEntry] {
        var seen = Set<Int32>()
        return entries.filter { entry in
            guard !seen.contains(entry.pid) else { return false }
            seen.insert(entry.pid)
            return true
        }
    }

    private var totalCPU: Double {
        uniqueProcessEntries.reduce(0) { $0 + $1.cpuPercent }
    }

    private var totalMemory: Int64 {
        uniqueProcessEntries.reduce(0) { $0 + $1.memoryBytes }
    }

    var body: some View {
        HStack(spacing: 8) {
            SummaryMetric(title: AppCopy.text("监听中", "Listening"), value: "\(entries.count)", systemImage: "dot.radiowaves.left.and.right", tint: .blue)
            SummaryMetric(title: AppCopy.text("仅本机", "Local only"), value: "\(localCount)", systemImage: "lock", tint: .green)
            SummaryMetric(title: "CPU", value: String(format: "%.1f%%", totalCPU), systemImage: "speedometer", tint: .orange)
            SummaryMetric(title: AppCopy.text("内存", "Memory"), value: ByteCountFormatter.string(fromByteCount: totalMemory, countStyle: .memory), systemImage: "memorychip", tint: .purple)
        }
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .contentTransition(.numericText())
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .frame(height: 54)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 2)
    }
}

struct PortRow: View {
    let entry: PortEntry
    let isSelected: Bool
    let onOpen: () -> Void
    let onCopy: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(scopeColor)
                        .frame(width: 18)
                    Text(verbatim: "\(entry.port)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .contentTransition(.numericText())
                }
                HStack(spacing: 5) {
                    Circle()
                        .fill(scopeColor)
                        .frame(width: 6, height: 6)
                    Text(entry.scopeLabel)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(scopeColor)
                }
                .padding(.leading, 25)
            }
            .frame(width: 96, alignment: .leading)

            Text(entry.processName)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)

            Text(verbatim: "\(entry.pid)")
                .font(.system(.body, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .foregroundStyle(.secondary)
                .frame(width: 72, alignment: .leading)

            LabelValuePill(value: entry.runtimeLabel, tint: .blue)
                .frame(width: 96, alignment: .leading)

            LabelValuePill(value: entry.cpuLabel, tint: entry.cpuPercent >= 20 ? .orange : .secondary)
                .frame(width: 62, alignment: .leading)

            LabelValuePill(value: entry.memoryLabel, tint: .purple)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Button(action: onOpen) {
                    Image(systemName: "safari")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(RowIconButtonStyle())
                .help(AppCopy.text("打开 localhost", "Open localhost"))

                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(RowIconButtonStyle())
                .help(AppCopy.text("复制 URL", "Copy URL"))
            }
            .opacity(isHovering || isSelected ? 1 : 0)
            .scaleEffect(isHovering || isSelected ? 1 : 0.96)
            .animation(.easeOut(duration: 0.16), value: isHovering)
            .animation(.easeOut(duration: 0.16), value: isSelected)
        }
        .padding(.horizontal, 10)
        .frame(height: 52)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(scopeColor)
                .frame(width: 3, height: isSelected ? 28 : 0)
                .padding(.leading, 2)
                .animation(.easeOut(duration: 0.18), value: isSelected)
        }
        .shadow(color: .black.opacity(isSelected ? 0.10 : 0.04), radius: isSelected ? 10 : 3, x: 0, y: isSelected ? 4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.16)) {
                isHovering = hovering
            }
        }
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

struct LabelValuePill: View {
    let value: String
    let tint: Color

    var body: some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .foregroundStyle(tint)
            .padding(.horizontal, 7)
            .frame(height: 26)
            .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

struct DetailLine: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 46, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 28)
    }
}

struct DetailHero: View {
    let entry: PortEntry
    let isScanning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: ":\(entry.port)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .contentTransition(.numericText())
                    Text(entry.appHint)
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                ScopeBadge(scope: entry.scope)
            }

            HStack(spacing: 8) {
                PulseDot(isActive: isScanning, hasError: false)
                Text(entry.url)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .textSelection(.enabled)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
    }
}

struct ScopeBadge: View {
    let scope: PortScope

    private var tint: Color {
        switch scope {
        case .local:
            return .green
        case .all:
            return .orange
        case .host:
            return .blue
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
            Text(scope.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

struct InfoGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 7) {
            content
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 2)
    }
}

struct CommandBlock: View {
    let command: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                    Label(AppCopy.text("启动命令", "Launch command"), systemImage: "terminal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(command.isEmpty ? AppCopy.text("不可用", "Unavailable") : command)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(11)
                .background(Color.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 7, x: 0, y: 2)
    }
}

