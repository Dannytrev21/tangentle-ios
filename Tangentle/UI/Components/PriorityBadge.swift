import SwiftUI

// MARK: - Priority Badge

/// A badge displaying the task's priority level with appropriate color coding.
struct PriorityBadge: View {
    @Environment(\.theme) var theme

    let priority: Priority

    var body: some View {
        Text(priority.displayName.uppercased())
            .font(Typography.labelSmall)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxxs)
            .background(color.opacity(0.15))
            .cornerRadius(CornerRadius.sm)
            .accessibilityLabel("\(priority.displayName) priority")
    }

    private var color: Color {
        switch priority {
        case .high, .mediumHigh: return theme.priorityHigh
        case .medium, .mediumLow: return theme.priorityMedium
        case .low: return theme.priorityLow
        case .none: return theme.priorityNone
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PriorityBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.sm) {
            PriorityBadge(priority: .high)
            PriorityBadge(priority: .medium)
            PriorityBadge(priority: .low)
            PriorityBadge(priority: .none)
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }
}
#endif
