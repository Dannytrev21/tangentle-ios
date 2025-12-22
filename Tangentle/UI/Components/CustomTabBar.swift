import SwiftUI

// MARK: - Custom Tab Bar

/// Custom styled tab bar with theme integration, haptic feedback,
/// and hide/show functionality. Uses matchedGeometryEffect for
/// smooth selection indicator animation.
struct CustomTabBar: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    @Binding var selectedTab: AppTab
    let isVisible: Bool

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: namespace
                )
                .onTapGesture {
                    selectTab(tab)
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs + safeAreaBottom)
        .background(tabBarBackground)
        .offset(y: isVisible ? 0 : 100)
        .animation(SpringConfig.snappy, value: isVisible)
    }

    // MARK: - Tab Bar Background

    private var tabBarBackground: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .fill(theme.backgroundPrimary.opacity(0.8))
            )
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.backgroundTertiary)
                    .frame(height: 0.5)
            }
    }

    // MARK: - Safe Area

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows.first?
            .safeAreaInsets.bottom ?? 0
    }

    // MARK: - Actions

    private func selectTab(_ tab: AppTab) {
        guard tab != selectedTab else { return }

        haptics.trigger(.selection)

        withAnimation(SpringConfig.snappy) {
            selectedTab = tab
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()

            CustomTabBar(
                selectedTab: .constant(.today),
                isVisible: true
            )
        }
        .background(WarmLightTheme().backgroundPrimary)
        .themed(WarmLightTheme())
        .hapticEngine(NoOpHapticEngine())
    }
}
#endif
