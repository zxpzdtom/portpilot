import SwiftUI

struct SortControl: View {
    let sortMode: SortMode
    let sortDirection: SortDirection
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: sortDirection.systemImage)
                    .font(.system(size: 9, weight: .bold))
                    .frame(width: 10)
                Text(sortMode.label)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 8)
            .frame(height: 24)
        }
        .buttonStyle(SortControlButtonStyle(isExpanded: isExpanded))
        .help(AppCopy.text("排序", "Sort"))
    }
}

struct SortOptionsPanel: View {
    let selectedMode: SortMode
    let selectedDirection: SortDirection
    let onSelectMode: (SortMode) -> Void
    let onSelectDirection: (SortDirection) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 3) {
                ForEach(SortMode.allCases) { mode in
                    Button {
                        onSelectMode(mode)
                    } label: {
                        SortOptionRow(
                            mode: mode,
                            isSelected: selectedMode == mode
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .overlay(Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.055))

            HStack(spacing: 5) {
                ForEach(SortDirection.allCases) { direction in
                    Button {
                        onSelectDirection(direction)
                    } label: {
                        Label(direction.label, systemImage: direction.systemImage)
                            .font(.system(size: 11, weight: .semibold))
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                            .frame(height: 27)
                    }
                    .buttonStyle(SortDirectionButtonStyle(isSelected: selectedDirection == direction))
                }
            }
        }
        .padding(7)
        .frame(width: 170)
        .background(panelBackground, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.060), lineWidth: 0.7)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.20 : 0.075), radius: 14, x: 0, y: 8)
    }

    private var panelBackground: some ShapeStyle {
        LinearGradient(
            colors: [
                colorScheme == .dark
                    ? Color(nsColor: .controlBackgroundColor)
                    : Color(red: 0.984, green: 0.989, blue: 0.995),
                colorScheme == .dark
                    ? Color(nsColor: .controlBackgroundColor).opacity(0.92)
                    : Color(red: 0.958, green: 0.966, blue: 0.974)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct SortOptionRow: View {
    let mode: SortMode
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.045))
                Image(systemName: mode.systemImage)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .frame(width: 24, height: 24)

            Text(mode.label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)

            Spacer(minLength: 6)

            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.accentColor)
                .opacity(isSelected ? 1 : 0)
                .scaleEffect(isSelected ? 1 : Motion.iconStartScale)
                .blur(radius: isSelected ? 0 : Motion.smallBlur)
                .animation(Motion.iconSwap(), value: isSelected)
        }
        .padding(.leading, 5)
        .padding(.trailing, 8)
        .frame(height: 32)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var rowBackground: Color {
        if isSelected {
            return colorScheme == .dark
                ? Color.accentColor.opacity(0.18)
                : Color(red: 0.900, green: 0.940, blue: 1.000)
        }
        return .clear
    }
}
