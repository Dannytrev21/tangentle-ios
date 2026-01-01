import SwiftUI

// MARK: - Task Section

/// A section container for grouping tasks with a header showing
/// icon, title, and count. Used for Overdue and Today sections.
struct TaskSection<Content: View>: View {
    @Environment(\.theme) var theme

    let title: String
    let icon: String
    let iconColor: Color
    let count: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section header
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)

                Text(title.uppercased())
                    .font(Typography.labelMedium)
                    .foregroundStyle(theme.textSecondary)

                Text("(\(count))")
                    .font(Typography.labelMedium)
                    .foregroundStyle(theme.textTertiary)

                Spacer()
            }
            .padding(.horizontal, Spacing.xs)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("\(title)Section")
            .accessibilityLabel("\(title) section, \(count) \(count == 1 ? "task" : "tasks")")

            // Section content
            content
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TaskSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.lg) {
            TaskSection(
                title: "Overdue",
                icon: "exclamationmark.triangle.fill",
                iconColor: WarmLightTheme().statusError,
                count: 2
            ) {
                Text("Task items would go here")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(WarmLightTheme().surfaceElevated)
                    .cornerRadius(CornerRadius.md)
            }

            TaskSection(
                title: "Today",
                icon: "calendar",
                iconColor: WarmLightTheme().accentPrimary,
                count: 5
            ) {
                Text("Task items would go here")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(WarmLightTheme().surfaceElevated)
                    .cornerRadius(CornerRadius.md)
            }
        }
        .padding()
        .background(WarmLightTheme().backgroundPrimary)
        .themed(WarmLightTheme())
    }
}
#endif
