import SwiftUI

// MARK: - Animated Checkbox

/// A satisfying animated checkbox with physics-based animation, particle burst,
/// and haptic feedback for task completion. Designed to provide positive reinforcement
/// for ADHD users - making task completion feel rewarding.
///
/// Animation sequence: Press → Fill → Checkmark draws → Bounce → Particles
/// Total duration: ~450ms
struct AnimatedCheckbox: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    @Binding var isCompleted: Bool
    let priority: Priority
    let onComplete: () -> Void

    // Animation state
    @State private var fillProgress: CGFloat = 0
    @State private var checkmarkProgress: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var showParticles = false
    @State private var particleKey = UUID()

    // Configuration
    private let size: CGFloat = 28
    private let lineWidth: CGFloat = 2.5

    var body: some View {
        ZStack {
            // Particles layer (behind checkbox)
            if showParticles {
                ParticleBurst(color: theme.statusSuccess)
                    .id(particleKey)
            }

            // Circle background (fills on completion)
            Circle()
                .fill(fillColor)

            // Circle border
            Circle()
                .strokeBorder(borderColor, lineWidth: lineWidth)

            // Checkmark (draws in with trim animation)
            if isCompleted || checkmarkProgress > 0 {
                CheckmarkShape()
                    .trim(from: 0, to: checkmarkProgress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(
                            lineWidth: 2.5,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .padding(6)
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(scale)
        .contentShape(Circle())
        .onTapGesture {
            if !isCompleted {
                complete()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isCompleted {
                        withAnimation(SpringConfig.snappy) {
                            scale = 0.9
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(SpringConfig.snappy) {
                        scale = 1
                    }
                }
        )
        .accessibilityLabel(isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to \(isCompleted ? "uncomplete" : "complete")")
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
        .onChange(of: isCompleted) { _, newValue in
            // Handle external state changes (e.g., from swipe-to-complete)
            if newValue && checkmarkProgress == 0 {
                // Complete was triggered externally, animate to match
                animateToCompleted()
            } else if !newValue {
                // Reset animation state when uncompleted
                resetAnimationState()
            }
        }
    }

    // MARK: - Computed Properties

    private var fillColor: Color {
        if isCompleted || fillProgress > 0 {
            return theme.statusSuccess.opacity(Double(max(fillProgress, isCompleted ? 1 : 0)))
        }
        return .clear
    }

    private var borderColor: Color {
        if isCompleted || fillProgress > 0 {
            return theme.statusSuccess
        }
        switch priority {
        case .high, .mediumHigh: return theme.priorityHigh
        case .medium, .mediumLow: return theme.priorityMedium
        case .low: return theme.priorityLow
        case .none: return theme.textTertiary
        }
    }

    // MARK: - Animation Methods

    private func complete() {
        // Trigger haptic immediately for responsive feel
        haptics.trigger(.completion)

        // Phase 1: Quick scale down (press feedback)
        withAnimation(.easeIn(duration: 0.08)) {
            scale = 0.85
        }

        // Phase 2: Fill circle and draw checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.12)) {
                fillProgress = 1
                isCompleted = true
            }

            withAnimation(.easeOut(duration: 0.18).delay(0.04)) {
                checkmarkProgress = 1
            }
        }

        // Phase 3: Bouncy scale back + particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(SpringConfig.bouncy) {
                scale = 1
            }

            // Show particles
            particleKey = UUID()
            showParticles = true

            // Hide particles after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                showParticles = false
            }

            // Callback
            onComplete()
        }
    }

    /// Animate to completed state (for external triggers like swipe-to-complete)
    private func animateToCompleted() {
        withAnimation(.easeOut(duration: 0.15)) {
            fillProgress = 1
        }

        withAnimation(.easeOut(duration: 0.2).delay(0.05)) {
            checkmarkProgress = 1
        }

        // Show particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            particleKey = UUID()
            showParticles = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                showParticles = false
            }
        }
    }

    /// Reset animation state when task is uncompleted
    private func resetAnimationState() {
        withAnimation(.easeOut(duration: 0.2)) {
            fillProgress = 0
            checkmarkProgress = 0
        }
        showParticles = false
    }

    /// Trigger completion programmatically (e.g., from swipe gesture).
    /// Call this instead of directly setting isCompleted for animated completion.
    func triggerCompletion() {
        guard !isCompleted else { return }
        complete()
    }
}

// MARK: - Preview

#if DEBUG
struct AnimatedCheckbox_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCheckboxDemo()
            .themed(WarmLightTheme())
            .hapticEngine(NoOpHapticEngine())
    }
}

private struct AnimatedCheckboxDemo: View {
    @State private var completedHigh = false
    @State private var completedMedium = false
    @State private var completedLow = false
    @State private var completedNone = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Text("Animated Checkbox Demo")
                .font(Typography.titleMedium)

            HStack(spacing: Spacing.lg) {
                VStack(spacing: Spacing.sm) {
                    AnimatedCheckbox(
                        isCompleted: $completedHigh,
                        priority: .high,
                        onComplete: {}
                    )
                    Text("High")
                        .font(Typography.caption)
                }

                VStack(spacing: Spacing.sm) {
                    AnimatedCheckbox(
                        isCompleted: $completedMedium,
                        priority: .medium,
                        onComplete: {}
                    )
                    Text("Medium")
                        .font(Typography.caption)
                }

                VStack(spacing: Spacing.sm) {
                    AnimatedCheckbox(
                        isCompleted: $completedLow,
                        priority: .low,
                        onComplete: {}
                    )
                    Text("Low")
                        .font(Typography.caption)
                }

                VStack(spacing: Spacing.sm) {
                    AnimatedCheckbox(
                        isCompleted: $completedNone,
                        priority: .none,
                        onComplete: {}
                    )
                    Text("None")
                        .font(Typography.caption)
                }
            }

            Button("Reset All") {
                completedHigh = false
                completedMedium = false
                completedLow = false
                completedNone = false
            }
            .buttonStyle(.bordered)

            Text("Tap checkboxes to see animation")
                .font(Typography.caption)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.xl)
        .previewLayout(.sizeThatFits)
    }
}
#endif
