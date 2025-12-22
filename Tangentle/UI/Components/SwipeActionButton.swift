import SwiftUI

// MARK: - Swipe Action Button

/// A button displayed in the revealed area of a SwipeableRow.
/// Shows an icon and title with consistent styling.
struct SwipeActionButton: View {
    @Environment(\.theme) var theme

    let action: SwipeAction
    let isActive: Bool
    let width: CGFloat

    var body: some View {
        Button(action: action.action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: action.icon)
                    .font(.system(size: 22, weight: .medium))

                Text(action.title)
                    .font(Typography.labelSmall)
            }
            .foregroundStyle(.white)
            .frame(width: width)
            .frame(maxHeight: .infinity)
            .background(action.color)
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(SpringConfig.snappy, value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.title)
        .accessibilityHint(action.isDestructive ? "Double tap to \(action.title.lowercased()). This action cannot be undone." : "Double tap to \(action.title.lowercased())")
    }
}

// MARK: - Preview

#if DEBUG
struct SwipeActionButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 0) {
            SwipeActionButton(
                action: StandardSwipeActions.complete { },
                isActive: false,
                width: 80
            )
            SwipeActionButton(
                action: StandardSwipeActions.delete { },
                isActive: true,
                width: 80
            )
        }
        .frame(height: 60)
        .previewLayout(.sizeThatFits)
    }
}
#endif
