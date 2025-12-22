# Step 4: Animation Library

## Context
Physics-based animations are core to the "living, breathing" feel of the UI. This step creates reusable animation utilities that provide spring physics, momentum, and bounce effects.

## Goal
Create a comprehensive animation library with standard curves, spring configurations, and physics utilities that can be used throughout the app.

## Prerequisites
- Step 1 (Design Tokens) completed - for timing values
- Step 2 (Theme System) completed - animations may reference theme

## High-Level Steps
1. Define animation timing tokens
2. Create spring animation configurations
3. Build momentum calculation utilities
4. Create SwiftUI animation extensions
5. Add UIKit spring timing parameters for gestures
6. Create animation view modifiers

## Detailed Requirements

### Animation Timing Tokens
```swift
enum AnimationTiming {
    // Durations
    static let instant: Double = 0.1
    static let quick: Double = 0.15
    static let normal: Double = 0.3
    static let slow: Double = 0.5
    static let dramatic: Double = 0.8

    // Delays
    static let staggerBase: Double = 0.05
    static let staggerSmall: Double = 0.03
}
```

### Spring Configurations
```swift
enum SpringConfig {
    // Snappy - Quick, responsive feedback
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)

    // Gentle - Smooth, calming transitions
    static let gentle = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    // Bouncy - Playful, celebratory
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.5, blendDuration: 0)

    // Stiff - Minimal overshoot, professional
    static let stiff = Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0)

    // Interactive - For gesture-driven animations
    static let interactive = Animation.interactiveSpring(response: 0.15, dampingFraction: 0.86, blendDuration: 0.25)
}
```

### UIKit Spring Parameters
```swift
struct UISpringConfig {
    let mass: CGFloat
    let stiffness: CGFloat
    let damping: CGFloat

    static let snappy = UISpringConfig(mass: 1, stiffness: 300, damping: 20)
    static let gentle = UISpringConfig(mass: 1, stiffness: 150, damping: 15)
    static let bouncy = UISpringConfig(mass: 1, stiffness: 200, damping: 10)

    var timingParameters: UISpringTimingParameters {
        UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: .zero)
    }
}
```

### Momentum Calculator
```swift
struct MomentumCalculator {
    /// Calculate decay endpoint given initial velocity
    static func decayEndpoint(
        startValue: CGFloat,
        velocity: CGFloat,
        decelerationRate: CGFloat = 0.998
    ) -> CGFloat {
        // Physics: x = v * (1 - d^t) / (1 - d) where d is deceleration
        let coefficient = 1000 * log(decelerationRate)
        return startValue - velocity / coefficient
    }

    /// Calculate time to reach threshold velocity
    static func decayDuration(
        velocity: CGFloat,
        threshold: CGFloat = 0.5,
        decelerationRate: CGFloat = 0.998
    ) -> Double {
        guard abs(velocity) > threshold else { return 0 }
        let coefficient = 1000 * log(decelerationRate)
        return Double(log(threshold / abs(velocity)) / coefficient)
    }
}
```

### Animation View Modifiers
```swift
extension View {
    /// Apply spring animation on value change
    func springAnimation<V: Equatable>(value: V, config: Animation = SpringConfig.snappy) -> some View {
        self.animation(config, value: value)
    }

    /// Staggered appearance animation
    func staggeredAppear(index: Int, baseDelay: Double = AnimationTiming.staggerBase) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .animation(
                SpringConfig.gentle.delay(Double(index) * baseDelay),
                value: true
            )
    }
}
```

### Gesture Animation Bridge
```swift
/// Bridges UIKit gesture animations to SwiftUI
final class GestureAnimator {
    private var displayLink: CADisplayLink?
    private var animationProgress: CGFloat = 0
    private var targetValue: CGFloat = 0
    private var onUpdate: ((CGFloat) -> Void)?

    func animate(
        to value: CGFloat,
        spring: UISpringConfig,
        onUpdate: @escaping (CGFloat) -> Void
    ) {
        self.targetValue = value
        self.onUpdate = onUpdate
        // Implementation using CADisplayLink for 120fps
    }

    func cancel() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
```

## Files to Create

### `Tangentle/UI/Animations/AnimationTokens.swift`
Timing values and spring configurations.

### `Tangentle/UI/Animations/SpringAnimation.swift`
UIKit spring parameters and bridge to SwiftUI.

### `Tangentle/UI/Animations/PhysicsEngine.swift`
Momentum calculator and physics utilities.

### `Tangentle/UI/Animations/AnimationModifiers.swift`
SwiftUI view modifiers for common animations.

## Files to Modify
- None

## Patterns to Follow
Reference: `UISpringTimingParameters` from UIKit
Reference: SwiftUI `.spring()` animation

## Acceptance Criteria
- [ ] Animation timing tokens defined
- [ ] Spring configurations for snappy, gentle, bouncy, stiff
- [ ] UIKit spring parameters compatible with UIViewPropertyAnimator
- [ ] Momentum calculator works for gesture velocity
- [ ] View modifiers compile and are usable
- [ ] **Reduce Motion respected** - Check `UIAccessibility.isReduceMotionEnabled` and provide simpler animations
- [ ] Fallback to `.none` animation when Reduce Motion enabled
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check files exist
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Animations/
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Ensure UIKit import for UISpringTimingParameters
2. Check CGFloat vs Double types
3. Verify Animation return types

## Do NOT
- Use external animation libraries
- Create overly complex physics simulations
- Add CADisplayLink loops that don't clean up properly
