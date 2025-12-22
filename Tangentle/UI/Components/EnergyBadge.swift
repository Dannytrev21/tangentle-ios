import SwiftUI

// MARK: - Energy Badge

/// A badge displaying the task's energy level requirement.
/// Shows a lightning bolt icon with color-coded level.
struct EnergyBadge: View {
    @Environment(\.theme) var theme

    let energy: EnergyLevel

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(energy.displayName)
                .font(Typography.labelSmall)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxxs)
        .background(color.opacity(0.15))
        .cornerRadius(CornerRadius.sm)
        .accessibilityLabel("\(energy.displayName) energy required")
    }

    private var icon: String {
        switch energy {
        case .high: return "bolt.fill"
        case .medium: return "bolt"
        case .low: return "bolt.slash"
        }
    }

    private var color: Color {
        switch energy {
        case .high: return theme.energyHigh
        case .medium: return theme.energyMedium
        case .low: return theme.energyLow
        }
    }
}

// MARK: - Preview

#if DEBUG
struct EnergyBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.sm) {
            EnergyBadge(energy: .high)
            EnergyBadge(energy: .medium)
            EnergyBadge(energy: .low)
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }
}
#endif
