import SwiftUI

// MARK: - Blocked Badge

/// A badge indicating the task is blocked by another task.
struct BlockedBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 10))
            Text("Blocked")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.statusWarning)
        .accessibilityLabel("Task is blocked")
    }
}

// MARK: - Overdue Badge

/// A badge indicating the task is past its due date.
struct OverdueBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text("Overdue")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.statusError)
        .accessibilityLabel("Task is overdue")
    }
}

// MARK: - In Progress Badge

/// A badge indicating the task is currently in progress.
struct InProgressBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 10))
            Text("In Progress")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.statusInfo)
        .accessibilityLabel("Task is in progress")
    }
}

// MARK: - Waiting Badge

/// A badge indicating the task is waiting for something.
struct WaitingBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "hourglass")
                .font(.system(size: 10))
            Text("Waiting")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.textSecondary)
        .accessibilityLabel("Task is waiting for something")
    }
}

// MARK: - Preview

#if DEBUG
struct StatusBadges_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.sm) {
            BlockedBadge()
            OverdueBadge()
            InProgressBadge()
            WaitingBadge()
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }
}
#endif
