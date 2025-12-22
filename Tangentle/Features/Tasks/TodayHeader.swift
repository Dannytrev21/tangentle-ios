import SwiftUI

// MARK: - Today Header

/// Header component for the Today view with time-based greeting,
/// formatted date, and decorative icon that changes throughout the day.
struct TodayHeader: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(greeting)
                    .font(Typography.titleLarge)
                    .foregroundStyle(theme.textPrimary)

                Text(formattedDate)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            Image(systemName: timeOfDayIcon)
                .font(.system(size: 28))
                .foregroundStyle(theme.accentPrimary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(greeting), \(formattedDate)")
    }

    // MARK: - Computed Properties

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var timeOfDayIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "sun.max.fill"
        case 12..<18:
            return "sun.min.fill"
        case 18..<21:
            return "sunset.fill"
        default:
            return "moon.fill"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TodayHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TodayHeader()
                .padding()
        }
        .background(WarmLightTheme().backgroundPrimary)
        .themed(WarmLightTheme())
    }
}
#endif
