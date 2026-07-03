import SwiftUI

struct MenuBarPopoverBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    baseSurface,
                    midSurface,
                    baseSurface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        topHighlight,
                        topTint,
                        baseSurface
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 132)

                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    colors: [
                        baseSurface,
                        bottomShade
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 96)
            }
        }
    }

    private var baseSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .windowBackgroundColor)
            : Color(red: 0.965, green: 0.972, blue: 0.980)
    }

    private var midSurface: Color {
        colorScheme == .dark
            ? Color(nsColor: .controlBackgroundColor)
            : Color(red: 0.948, green: 0.958, blue: 0.968)
    }

    private var topHighlight: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color(red: 0.990, green: 0.994, blue: 1.000)
    }

    private var topTint: Color {
        colorScheme == .dark
            ? Color(nsColor: .selectedContentBackgroundColor).opacity(0.10)
            : Color(red: 0.936, green: 0.960, blue: 0.982)
    }

    private var bottomShade: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.08)
            : Color(red: 0.925, green: 0.934, blue: 0.944)
    }
}
