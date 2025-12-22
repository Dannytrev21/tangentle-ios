import SwiftUI

// MARK: - Completion Indicator

/// A circular checkbox that indicates task completion status.
/// The border color reflects the task's priority level.
struct CompletionIndicator: View {
    @Environment(\.theme) var theme

    let isCompleted: Bool
    let priority: Priority

    var body: some View {
        Circle()
            .strokeBorder(borderColor, lineWidth: 2)
            .background(
                Circle()
                    .fill(isCompleted ? theme.statusSuccess : .clear)
            )
            .overlay {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 24, height: 24)
            .accessibilityLabel(isCompleted ? "Completed" : "Not completed")
            .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }

    private var borderColor: Color {
        if isCompleted { return theme.statusSuccess }
        switch priority {
        case .high, .mediumHigh: return theme.priorityHigh
        case .medium, .mediumLow: return theme.priorityMedium
        case .low: return theme.priorityLow
        case .none: return theme.textTertiary
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CompletionIndicator_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: Spacing.md) {
            CompletionIndicator(isCompleted: false, priority: .high)
            CompletionIndicator(isCompleted: false, priority: .medium)
            CompletionIndicator(isCompleted: false, priority: .low)
            CompletionIndicator(isCompleted: false, priority: .none)
            CompletionIndicator(isCompleted: true, priority: .high)
        }
        .padding()
        .themed(WarmLightTheme())
        .previewLayout(.sizeThatFits)
    }
}
#endif
