# Step 7: SwipeableRow

## Context
SwipeableRow is a key component that provides swipe-to-reveal actions for list items. It needs to be generic enough to work with tasks, habits, and other list items, while providing smooth physics-based animations.

## Goal
Create a reusable SwipeableRow component that reveals action buttons on swipe, supports both left and right directions, and provides satisfying physics-based interactions.

## Prerequisites
- Step 4 (Animation Library) completed
- Step 5 (Haptic Engine) completed
- Step 6 (Gesture Foundation) completed

## High-Level Steps
1. Design SwipeableRow with configurable actions
2. Implement swipe gesture integration
3. Create action button components
4. Add spring-back animation on release
5. Handle action execution with haptic feedback
6. Support contextual action configuration

## Detailed Requirements

### Swipe Action Model
```swift
struct SwipeAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String  // SF Symbol name
    let color: Color
    let isDestructive: Bool
    let action: () -> Void
}

enum SwipeActionSet {
    case leading([SwipeAction])
    case trailing([SwipeAction])
    case both(leading: [SwipeAction], trailing: [SwipeAction])
}
```

### SwipeableRow Component
```swift
struct SwipeableRow<Content: View>: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    let content: Content
    let leadingActions: [SwipeAction]
    let trailingActions: [SwipeAction]
    let swipeThreshold: CGFloat

    // State
    @State private var offset: CGFloat = 0
    @State private var activeAction: SwipeAction?
    @GestureState private var isDragging = false

    // Configuration
    private let actionButtonWidth: CGFloat = 80
    private let maxSwipeRatio: CGFloat = 0.4  // Max 40% of row width

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background actions
                HStack(spacing: 0) {
                    // Leading actions (shown when swiping right)
                    leadingActionsView
                    Spacer()
                    // Trailing actions (shown when swiping left)
                    trailingActionsView
                }

                // Main content
                content
                    .offset(x: offset)
                    .gesture(swipeGesture)
            }
        }
    }

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
        // Apply resistance at edges
        let maxOffset = /* calculated based on actions */
        offset = rubberBand(translation, limit: maxOffset)

        // Check for threshold crossing
        checkThresholdCrossing()
    }

    private func handleSwipeEnd(translation: CGFloat, velocity: CGFloat) {
        // Determine if action should trigger or snap back
        if let action = activeAction, shouldTriggerAction(velocity: velocity) {
            executeAction(action)
        } else {
            snapBack()
        }
    }

    private func rubberBand(_ value: CGFloat, limit: CGFloat) -> CGFloat {
        // Rubber band effect beyond limits
        if abs(value) <= limit { return value }
        let excess = abs(value) - limit
        let damped = limit + (1 - (1 / ((excess * 0.55 / limit) + 1))) * limit
        return value > 0 ? damped : -damped
    }

    private func snapBack() {
        withAnimation(SpringConfig.snappy) {
            offset = 0
            activeAction = nil
        }
    }

    private func executeAction(_ action: SwipeAction) {
        haptics.trigger(action.isDestructive ? .warning : .success)

        withAnimation(SpringConfig.bouncy) {
            offset = 0
        }

        // Execute after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action.action()
        }
    }
}
```

### Action Button Component
```swift
struct SwipeActionButton: View {
    let action: SwipeAction
    let isActive: Bool
    @Environment(\.theme) var theme

    var body: some View {
        Button(action: action.action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: action.icon)
                    .font(.system(size: 22, weight: .medium))
                Text(action.title)
                    .font(Typography.labelSmall)
            }
            .foregroundStyle(.white)
            .frame(width: 80)
            .frame(maxHeight: .infinity)
            .background(action.color)
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(SpringConfig.snappy, value: isActive)
        }
        .buttonStyle(.plain)
    }
}
```

### Standard Actions Factory
```swift
enum StandardSwipeActions {
    static func complete(task: TGTask, onComplete: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Done",
            icon: "checkmark.circle.fill",
            color: .statusSuccess,
            isDestructive: false,
            action: onComplete
        )
    }

    static func delete(onDelete: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Delete",
            icon: "trash.fill",
            color: .statusError,
            isDestructive: true,
            action: onDelete
        )
    }

    static func defer_(onDefer: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Defer",
            icon: "clock.arrow.circlepath",
            color: .statusWarning,
            isDestructive: false,
            action: onDefer
        )
    }

    static func edit(onEdit: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Edit",
            icon: "pencil",
            color: .statusInfo,
            isDestructive: false,
            action: onEdit
        )
    }

    // Contextual actions
    static func unblock(task: TGTask, onUnblock: @escaping () -> Void) -> SwipeAction {
        SwipeAction(
            title: "Unblock",
            icon: "arrow.uturn.forward",
            color: .accentPrimary,
            isDestructive: false,
            action: onUnblock
        )
    }
}
```

## Files to Create

### `Tangentle/UI/Components/SwipeableRow.swift`
Main swipeable container component.

### `Tangentle/UI/Components/SwipeAction.swift`
Action model and standard actions factory.

### `Tangentle/UI/Components/SwipeActionButton.swift`
Individual action button component.

## Files to Modify
- None

## Patterns to Follow
Reference: iOS Mail app swipe actions
Reference: Things 3 swipe completion

## Acceptance Criteria
- [ ] SwipeableRow reveals actions on swipe
- [ ] Rubber band effect at swipe limits
- [ ] Haptic feedback on threshold crossing
- [ ] Spring animation on release
- [ ] Actions execute with confirmation haptic
- [ ] Supports leading and trailing actions
- [ ] Destructive actions have distinct styling
- [ ] Works with variable content heights
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check component files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Components/Swipe*
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Check GeometryReader usage
2. Verify gesture state handling
3. Ensure theme environment is available

## Do NOT
- Allow swipe conflicts with scroll view
- Create jarring non-spring animations
- Forget to handle action cleanup
