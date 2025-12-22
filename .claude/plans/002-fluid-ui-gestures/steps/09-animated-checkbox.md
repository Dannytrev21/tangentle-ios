# Step 9: AnimatedCheckbox

## Context
The task completion animation is the most frequent celebratory moment in the app. A satisfying animated checkbox provides positive reinforcement for ADHD users, making task completion feel rewarding.

## Goal
Create a physics-based animated checkbox that provides a satisfying "pop" animation with optional haptic feedback when completing tasks.

## Prerequisites
- Step 4 (Animation Library) completed
- Step 5 (Haptic Engine) completed
- Step 8 (TaskCard) completed - for integration

## High-Level Steps
1. Design completion animation sequence
2. Create AnimatedCheckbox component
3. Add confetti/burst effect option
4. Integrate haptic feedback
5. Support both tap and swipe-triggered completion
6. Add accessibility support

## Detailed Requirements

### Animation Sequence
```
Unchecked → Pressed → Completing → Completed

1. Unchecked: Empty circle with priority-colored border
2. Pressed: Scale down slightly (0.95), border thickens
3. Completing: Circle fills with green, checkmark draws in
4. Completed: Bounce overshoot, particles burst outward
```

### AnimatedCheckbox Component
```swift
struct AnimatedCheckbox: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics

    @Binding var isCompleted: Bool
    let priority: Priority
    let onComplete: () -> Void

    // Animation state
    @State private var isPressed = false
    @State private var fillProgress: CGFloat = 0
    @State private var checkmarkProgress: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var showParticles = false

    // Configuration
    let size: CGFloat = 28
    let lineWidth: CGFloat = 2.5

    var body: some View {
        ZStack {
            // Particles layer (behind)
            if showParticles {
                ParticleBurst(color: theme.statusSuccess)
            }

            // Circle background
            Circle()
                .fill(
                    isCompleted
                        ? theme.statusSuccess
                        : .clear
                )

            // Circle border
            Circle()
                .strokeBorder(borderColor, lineWidth: lineWidth)

            // Checkmark
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
        .onTapGesture {
            if !isCompleted {
                complete()
            }
        }
        .onLongPressGesture(
            minimumDuration: 0.01,
            pressing: { pressing in
                withAnimation(SpringConfig.snappy) {
                    isPressed = pressing
                    scale = pressing ? 0.9 : 1
                }
            },
            perform: {}
        )
        .accessibilityLabel(isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to \(isCompleted ? "uncomplete" : "complete")")
        .accessibilityAddTraits(isCompleted ? .isSelected : [])
    }

    private var borderColor: Color {
        if isCompleted {
            return theme.statusSuccess
        }
        switch priority {
        case .high, .mediumHigh:
            return theme.priorityHigh
        case .medium, .mediumLow:
            return theme.priorityMedium
        default:
            return theme.textTertiary
        }
    }

    private func complete() {
        haptics.trigger(.completion)

        // Phase 1: Quick scale down
        withAnimation(.easeIn(duration: 0.1)) {
            scale = 0.85
        }

        // Phase 2: Fill and draw checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.2)) {
                fillProgress = 1
            }

            withAnimation(.easeOut(duration: 0.25).delay(0.1)) {
                checkmarkProgress = 1
            }
        }

        // Phase 3: Bounce back with overshoot
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(SpringConfig.bouncy) {
                scale = 1
                isCompleted = true
            }

            // Particles
            showParticles = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showParticles = false
            }

            onComplete()
        }
    }
}
```

### Checkmark Shape
```swift
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Checkmark proportions
        let startX = rect.width * 0.2
        let startY = rect.height * 0.5
        let midX = rect.width * 0.4
        let midY = rect.height * 0.7
        let endX = rect.width * 0.8
        let endY = rect.height * 0.3

        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        return path
    }
}
```

### Particle Burst Effect
```swift
struct ParticleBurst: View {
    let color: Color
    let particleCount = 8

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var angle: Double
        var distance: CGFloat = 0
        var opacity: Double = 1
        var scale: CGFloat = 1
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .offset(
                        x: cos(particle.angle) * particle.distance,
                        y: sin(particle.angle) * particle.distance
                    )
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }

    private func createParticles() {
        particles = (0..<particleCount).map { i in
            Particle(
                angle: Double(i) * (2 * .pi / Double(particleCount))
            )
        }
    }

    private func animateParticles() {
        withAnimation(.easeOut(duration: 0.4)) {
            for i in particles.indices {
                particles[i].distance = CGFloat.random(in: 20...35)
                particles[i].opacity = 0
                particles[i].scale = 0.5
            }
        }
    }
}
```

### Programmatic Completion (for swipe)
```swift
extension AnimatedCheckbox {
    /// Trigger completion animation programmatically (e.g., from swipe gesture)
    func triggerCompletion() {
        guard !isCompleted else { return }
        complete()
    }
}
```

## Files to Create

### `Tangentle/UI/Components/AnimatedCheckbox.swift`
Main animated checkbox component.

### `Tangentle/UI/Components/CheckmarkShape.swift`
Animatable checkmark path.

### `Tangentle/UI/Components/ParticleBurst.swift`
Celebratory particle effect.

## Files to Modify

### `Tangentle/UI/Components/TaskCard.swift`
Replace CompletionIndicator with AnimatedCheckbox for interactive cards.

## Patterns to Follow
Reference: Things 3 completion animation
Reference: iOS Reminders checkmark

## Acceptance Criteria
- [ ] Checkbox animates from empty to filled
- [ ] Checkmark draws in with animation
- [ ] Scale bounces on completion
- [ ] Particle burst appears briefly
- [ ] Haptic feedback triggers on complete
- [ ] Animation completes in <500ms
- [ ] Works for both tap and programmatic trigger
- [ ] VoiceOver accessibility works
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Components/*Checkbox*.swift
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Components/*Particle*.swift
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Check Shape protocol conformance
2. Verify animation timing sequencing
3. Ensure haptic engine is in environment

## Do NOT
- Create animation longer than 500ms total
- Skip haptic feedback
- Make particles too prominent
