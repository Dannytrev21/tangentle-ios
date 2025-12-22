import SwiftUI

// MARK: - Tab Bar Container

/// Container view that manages tab content and the custom tab bar.
/// Provides the main navigation structure for the app with
/// support for hiding the tab bar via user settings.
struct TabBarContainer: View {
    @Environment(\.theme) var theme
    @Environment(\.container) var container

    @State private var selectedTab: AppTab = .today
    @AppStorage("hideTabBar") private var hideTabBar = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                isVisible: !hideTabBar
            )
        }
        .background(theme.backgroundPrimary)
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .today:
            TodayView()
        case .tasks:
            TasksView()
        case .calendar:
            CalendarView()
        case .strategies:
            StrategiesView()
        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TabBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        TabBarContainer()
            .themed(WarmLightTheme())
            .hapticEngine(NoOpHapticEngine())
            .withContainer(TestContainer())
    }
}
#endif
