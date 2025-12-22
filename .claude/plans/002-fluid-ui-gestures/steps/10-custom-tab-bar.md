# Step 10: Custom Tab Bar

## Context
The tab bar is always visible and needs to match the warm aesthetic while providing clear navigation. It should support configurable visibility for users who prefer minimal UI.

## Goal
Create a custom styled tab bar that uses the theme system, supports hiding/showing, and provides smooth transitions between tabs.

## Prerequisites
- Step 1 (Design Tokens) completed
- Step 2 (Theme System) completed
- Step 3 (Typography Scale) completed

## High-Level Steps
1. Design custom tab bar layout
2. Create TabBarItem component
3. Add selection animation
4. Implement hide/show functionality
5. Add haptic feedback on tab change
6. Update ContentView to use custom tab bar

## Detailed Requirements

### Tab Bar Design
```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   ☀️        ✅        📅        💡        ⚙️                  │
│  Today    Tasks   Calendar  Strategies Settings             │
│   ───                                                        │
│ (indicator)                                                  │
└──────────────────────────────────────────────────────────────┘

- Floating or docked (configurable)
- Semi-transparent background with blur
- Selected tab has indicator and filled icon
- Smooth slide animation for indicator
```

### Tab Definition
```swift
enum AppTab: String, CaseIterable, Identifiable {
    case today
    case tasks
    case calendar
    case strategies
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .tasks: return "Tasks"
        case .calendar: return "Calendar"
        case .strategies: return "Strategies"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .today: return "sun.max"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .strategies: return "lightbulb"
        case .settings: return "gear"
        }
    }

    var selectedIcon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .strategies: return "lightbulb.fill"
        case .settings: return "gear"
        }
    }
}
```

### Custom Tab Bar Component
```swift
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
        .background(
            tabBarBackground
        )
        .offset(y: isVisible ? 0 : 100)
        .animation(SpringConfig.snappy, value: isVisible)
    }

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

    private var safeAreaBottom: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows.first?
            .safeAreaInsets.bottom ?? 0
    }

    private func selectTab(_ tab: AppTab) {
        guard tab != selectedTab else { return }
        haptics.trigger(.selection)

        withAnimation(SpringConfig.snappy) {
            selectedTab = tab
        }
    }
}
```

### Tab Bar Item
```swift
struct TabBarItem: View {
    @Environment(\.theme) var theme
    let tab: AppTab
    let isSelected: Bool
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: Spacing.xxxs) {
            Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? theme.accentPrimary : theme.textSecondary)
                .frame(height: 24)

            Text(tab.title)
                .font(Typography.caption)
                .foregroundStyle(isSelected ? theme.accentPrimary : theme.textSecondary)

            // Selection indicator
            if isSelected {
                Capsule()
                    .fill(theme.accentPrimary)
                    .frame(width: 24, height: 3)
                    .matchedGeometryEffect(id: "tabIndicator", in: namespace)
            } else {
                Capsule()
                    .fill(.clear)
                    .frame(width: 24, height: 3)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
```

### Tab Bar Container (Main Content)
```swift
struct TabBarContainer: View {
    @Environment(\.theme) var theme
    @State private var selectedTab: AppTab = .today
    @AppStorage("hideTabBar") private var hideTabBar = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                isVisible: !hideTabBar
            )
        }
        .background(theme.backgroundPrimary)
        .ignoresSafeArea(.keyboard)
    }

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
```

### Tab Bar Visibility Toggle
```swift
// Add to Settings
struct TabBarSettingsSection: View {
    @AppStorage("hideTabBar") private var hideTabBar = false

    var body: some View {
        Section("Navigation") {
            Toggle("Hide Tab Bar", isOn: $hideTabBar)
        }
    }
}
```

### Gesture to Toggle (Optional)
```swift
// Add swipe up/down gesture to hide/show tab bar
extension TabBarContainer {
    var tabBarToggleGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                if value.translation.height > 50 && !hideTabBar {
                    withAnimation {
                        hideTabBar = true
                    }
                } else if value.translation.height < -50 && hideTabBar {
                    withAnimation {
                        hideTabBar = false
                    }
                }
            }
    }
}
```

## Files to Create

### `Tangentle/UI/Components/CustomTabBar.swift`
Main tab bar component.

### `Tangentle/UI/Components/TabBarItem.swift`
Individual tab item.

### `Tangentle/App/TabBarContainer.swift`
Container view managing tabs and content.

### `Tangentle/Core/Models/AppTab.swift`
Tab enum definition.

## Files to Modify

### `Tangentle/App/ContentView.swift`
Replace TabView with TabBarContainer.

### `Tangentle/Features/Settings/SettingsView.swift`
Add tab bar visibility toggle.

## Patterns to Follow
Reference: `Tangentle/App/ContentView.swift` for current tab structure
Reference: iOS tab bar behavior

## Acceptance Criteria
- [ ] Custom tab bar renders with 5 tabs
- [ ] Selected tab has filled icon and accent color
- [ ] Selection indicator slides smoothly (matchedGeometryEffect)
- [ ] Tab bar uses theme colors
- [ ] Tab bar can be hidden/shown
- [ ] Hide animation is smooth (slides down)
- [ ] Haptic feedback on tab change
- [ ] VoiceOver accessibility works
- [ ] Safe area handled correctly
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Components/*Tab*.swift
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/App/TabBarContainer.swift
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Check Namespace usage for matchedGeometryEffect
2. Verify safe area calculations
3. Ensure AppStorage key matches

## Do NOT
- Use UIKit tab bar controller
- Forget safe area for home indicator
- Skip accessibility labels
