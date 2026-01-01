import SwiftUI

// MARK: - Floating Action Button

/// A Material Design-style FAB for quick actions.
/// Uses theme colors, haptic feedback, and scale animation on press.
struct FloatingActionButton: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    let icon: String
    let action: () -> Void

    init(
        icon: String = "plus",
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: {
            haptics.trigger(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(theme.accentPrimary)
                .clipShape(Circle())
                .shadow(
                    color: theme.accentPrimary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityIdentifier("AddTaskButton")
        .accessibilityLabel("Add task")
    }
}

// MARK: - Scale Button Style

/// Button style that applies a press-down scale effect
/// with spring animation for a tactile feel.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(SpringConfig.snappy, value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
struct FloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(WarmLightTheme().backgroundPrimary)
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton { }
                        .padding()
                }
            }
        }
        .themed(WarmLightTheme())
        .hapticEngine(NoOpHapticEngine())
    }
}
#endif
