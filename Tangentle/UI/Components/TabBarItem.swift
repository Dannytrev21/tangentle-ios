import SwiftUI

// MARK: - Tab Bar Item

/// Individual tab item for the custom tab bar.
/// Displays icon, title, and selection indicator.
struct TabBarItem: View {
    @Environment(\.theme) var theme

    let tab: AppTab
    let isSelected: Bool
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: Spacing.xxxs) {
            // Tab icon
            Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? theme.accentPrimary : theme.textSecondary)
                .frame(height: 24)

            // Tab title
            Text(tab.title)
                .font(Typography.caption)
                .foregroundStyle(isSelected ? theme.accentPrimary : theme.textSecondary)

            // Selection indicator - slides between tabs
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
        .accessibilityIdentifier("Tab_\(tab.rawValue)")
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Preview

#if DEBUG
struct TabBarItem_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        HStack(spacing: 0) {
            TabBarItem(
                tab: .today,
                isSelected: true,
                namespace: namespace
            )

            TabBarItem(
                tab: .tasks,
                isSelected: false,
                namespace: namespace
            )

            TabBarItem(
                tab: .calendar,
                isSelected: false,
                namespace: namespace
            )
        }
        .padding()
        .background(WarmLightTheme().backgroundPrimary)
        .themed(WarmLightTheme())
    }
}
#endif
