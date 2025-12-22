import SwiftUI

// MARK: - SwipeableRow

/// A generic container that enables swipe-to-reveal actions like iOS Mail.
/// Supports leading (right swipe) and trailing (left swipe) actions with
/// physics-based animations and haptic feedback.
///
/// Usage:
/// ```swift
/// SwipeableRow(
///     leadingActions: [StandardSwipeActions.complete { }],
///     trailingActions: [StandardSwipeActions.delete { }]
/// ) {
///     TaskRowContent(task: task)
/// }
/// ```
struct SwipeableRow<Content: View>: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    let content: () -> Content
    let leadingActions: [SwipeAction]
    let trailingActions: [SwipeAction]

    // MARK: - State

    @State private var offset: CGFloat = 0
    @State private var crossedThreshold = false
    @GestureState private var isDragging = false

    // MARK: - Configuration

    private let actionButtonWidth: CGFloat = 80
    private let swipeThreshold: CGFloat = 60
    private var maxLeadingOffset: CGFloat { CGFloat(leadingActions.count) * actionButtonWidth }
    private var maxTrailingOffset: CGFloat { CGFloat(trailingActions.count) * actionButtonWidth }

    // MARK: - Initializers

    init(
        leadingActions: [SwipeAction] = [],
        trailingActions: [SwipeAction] = [],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background with actions
            HStack(spacing: 0) {
                // Leading actions (visible when swiping right)
                if !leadingActions.isEmpty {
                    leadingActionsView
                        .frame(width: maxLeadingOffset)
                }

                Spacer()

                // Trailing actions (visible when swiping left)
                if !trailingActions.isEmpty {
                    trailingActionsView
                        .frame(width: maxTrailingOffset)
                }
            }

            // Main content
            content()
                .frame(maxWidth: .infinity)
                .background(theme.surfaceElevated)
                .offset(x: offset)
                .gesture(swipeGesture)
        }
        .clipped()
    }

    // MARK: - Action Views

    @ViewBuilder
    private var leadingActionsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(leadingActions.enumerated()), id: \.element.id) { index, action in
                SwipeActionButton(
                    action: action,
                    isActive: offset > swipeThreshold && index == 0,
                    width: actionButtonWidth
                )
            }
        }
    }

    @ViewBuilder
    private var trailingActionsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(trailingActions.enumerated()), id: \.element.id) { index, action in
                SwipeActionButton(
                    action: action,
                    isActive: offset < -swipeThreshold && index == 0,
                    width: actionButtonWidth
                )
            }
        }
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                handleSwipeChange(translation: value.translation.width)
            }
            .onEnded { value in
                handleSwipeEnd(
                    translation: value.translation.width,
                    velocity: value.predictedEndTranslation.width - value.translation.width
                )
            }
    }

    private func handleSwipeChange(translation: CGFloat) {
        // Determine bounds based on available actions
        let maxRight = leadingActions.isEmpty ? 0 : maxLeadingOffset
        let maxLeft = trailingActions.isEmpty ? 0 : -maxTrailingOffset

        // Apply rubber band effect beyond bounds
        if translation > maxRight && maxRight > 0 {
            offset = MomentumCalculator.rubberBand(
                value: translation,
                limit: maxRight,
                coefficient: 0.55
            )
        } else if translation < maxLeft && maxLeft < 0 {
            // For negative values, we need to handle differently
            offset = -MomentumCalculator.rubberBand(
                value: -translation,
                limit: -maxLeft,
                coefficient: 0.55
            )
        } else if translation > 0 && leadingActions.isEmpty {
            // No leading actions, rubber band from zero
            offset = MomentumCalculator.rubberBand(
                value: translation,
                limit: 0,
                coefficient: 0.3
            )
        } else if translation < 0 && trailingActions.isEmpty {
            // No trailing actions, rubber band from zero
            offset = -MomentumCalculator.rubberBand(
                value: -translation,
                limit: 0,
                coefficient: 0.3
            )
        } else {
            offset = translation
        }

        // Haptic on threshold crossing
        checkThresholdCrossing(translation: translation)
    }

    private func checkThresholdCrossing(translation: CGFloat) {
        let wasOver = crossedThreshold
        let isOver = abs(translation) >= swipeThreshold

        if !wasOver && isOver {
            crossedThreshold = true
            haptics.trigger(.swipeThreshold)
        } else if wasOver && !isOver {
            crossedThreshold = false
            haptics.trigger(.selection)
        }
    }

    private func handleSwipeEnd(translation: CGFloat, velocity: CGFloat) {
        crossedThreshold = false

        // Determine if should trigger action or snap back
        let shouldTrigger = abs(translation) >= swipeThreshold || abs(velocity) > 500

        if shouldTrigger {
            if translation > swipeThreshold && !leadingActions.isEmpty {
                executeAction(leadingActions[0])
            } else if translation < -swipeThreshold && !trailingActions.isEmpty {
                executeAction(trailingActions[0])
            } else {
                snapBack()
            }
        } else {
            snapBack()
        }
    }

    private func executeAction(_ action: SwipeAction) {
        haptics.trigger(action.isDestructive ? .warning : .success)

        withAnimation(SpringConfig.bouncy) {
            offset = 0
        }

        // Execute after animation settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            action.action()
        }
    }

    private func snapBack() {
        withAnimation(SpringConfig.snappy) {
            offset = 0
        }
    }
}

// MARK: - Convenience Initializer

extension SwipeableRow {
    /// Creates a swipeable row with just trailing actions (most common case)
    init(
        trailingActions: [SwipeAction],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(leadingActions: [], trailingActions: trailingActions, content: content)
    }
}

// MARK: - Preview

#if DEBUG
struct SwipeableRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            SwipeableRow(
                leadingActions: [StandardSwipeActions.complete { }],
                trailingActions: [
                    StandardSwipeActions.defer_ { },
                    StandardSwipeActions.delete { }
                ]
            ) {
                HStack {
                    Text("Swipe me left or right")
                        .padding()
                    Spacer()
                }
                .frame(height: 60)
            }

            Divider()

            SwipeableRow(
                trailingActions: [StandardSwipeActions.delete { }]
            ) {
                HStack {
                    Text("Swipe left only")
                        .padding()
                    Spacer()
                }
                .frame(height: 60)
            }
        }
        .themed(WarmLightTheme())
    }
}
#endif
