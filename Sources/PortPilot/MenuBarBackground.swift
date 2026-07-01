import SwiftUI

struct MenuBarPopoverBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor).opacity(0.82),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 0) {
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.55),
                        Color(nsColor: .selectedContentBackgroundColor).opacity(0.06),
                        Color.clear
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
                        Color.clear,
                        Color.black.opacity(0.025)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 96)
            }
        }
    }
}
