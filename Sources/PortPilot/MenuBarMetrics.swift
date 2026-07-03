import SwiftUI

struct MenuBarStatsStrip: View {
    let entries: [PortEntry]

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
        HStack(spacing: 6) {
            CompactMetric(title: AppCopy.text("端口", "Ports"), value: "\(entries.count)", systemImage: "dot.radiowaves.left.and.right", tint: .blue)
            CompactMetric(title: "CPU", value: String(format: "%.1f%%", totalCPU), systemImage: "speedometer", tint: .orange)
            CompactMetric(title: AppCopy.text("内存", "Memory"), value: ByteCountFormatter.string(fromByteCount: totalMemory, countStyle: .memory), systemImage: "memorychip", tint: .purple)
        }
    }
}

struct CompactMetric: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(metricBackground, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.045), lineWidth: 0.6)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.10 : 0.040), radius: 7, x: 0, y: 2)
    }

    private var metricBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                metricTopSurface,
                metricBottomSurface
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var metricTopSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor)
            : Color(red: 0.990, green: 0.993, blue: 0.997)
    }

    private var metricBottomSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor).opacity(0.86)
            : Color(red: 0.972, green: 0.977, blue: 0.984)
    }
}
