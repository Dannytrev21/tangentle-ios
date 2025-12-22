import SwiftUI

// MARK: - Duration Badge

/// A badge displaying the task's estimated duration in minutes.
struct DurationBadge: View {
    @Environment(\.theme) var theme

    let minutes: Int

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "clock")
                .font(.system(size: 10, weight: .medium))
            Text(formattedDuration)
                .font(Typography.labelSmall)
                .fontWeight(.medium)
        }
        .foregroundStyle(theme.textSecondary)
        .accessibilityLabel(accessibilityDuration)
    }

    private var formattedDuration: String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins > 0 {
                return "\(hours)h \(mins)m"
            }
            return "\(hours)h"
        }
        return "\(minutes)m"
    }

    private var accessibilityDuration: String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins > 0 {
                return "\(hours) hours \(mins) minutes"
            }
            return "\(hours) hours"
        }
        return "\(minutes) minutes"
    }
}

// MARK: - Preview

#if DEBUG
struct DurationBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.sm) {
            DurationBadge(minutes: 15)
            DurationBadge(minutes: 30)
            DurationBadge(minutes: 60)
            DurationBadge(minutes: 90)
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }
}
#endif
