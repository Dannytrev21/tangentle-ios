import SwiftUI

// MARK: - Today Empty State

/// Friendly empty state shown when no tasks are scheduled for today.
/// ADHD-friendly: celebrates the win of having no tasks rather than
/// showing a stark "no data" message.
struct TodayEmptyState: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(theme.statusSuccess.opacity(0.5))
                .accessibilityHidden(true)

            VStack(spacing: Spacing.xs) {
                Text("All Clear!")
                    .font(Typography.titleMedium)
                    .foregroundStyle(theme.textPrimary)

                Text("No tasks scheduled for today.\nEnjoy your free time!")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.xxl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("All clear! No tasks scheduled for today. Enjoy your free time!")
    }
}

// MARK: - Preview

#if DEBUG
struct TodayEmptyState_Previews: PreviewProvider {
    static var previews: some View {
        TodayEmptyState()
            .background(WarmLightTheme().backgroundPrimary)
            .themed(WarmLightTheme())
    }
}
#endif
