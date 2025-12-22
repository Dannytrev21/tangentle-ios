import SwiftUI

// MARK: - Animation Timing

/// Timing tokens for consistent animation durations across the app.
enum AnimationTiming {
    // MARK: Durations

    /// 100ms - Instant feedback (button press, toggle)
    static let instant: Double = 0.1

    /// 150ms - Quick response (hover states, micro-interactions)
    static let quick: Double = 0.15

    /// 300ms - Normal transitions (page changes, modal appearance)
    static let normal: Double = 0.3

    /// 500ms - Slow, emphasized transitions
    static let slow: Double = 0.5

    /// 800ms - Dramatic, celebratory animations
    static let dramatic: Double = 0.8

    // MARK: Delays

    /// 50ms - Base delay for staggered animations
    static let staggerBase: Double = 0.05

    /// 30ms - Small stagger for tight groups
    static let staggerSmall: Double = 0.03

    /// 80ms - Large stagger for dramatic reveals
    static let staggerLarge: Double = 0.08
}

// MARK: - Spring Configurations

/// Pre-configured spring animations for common use cases.
/// All springs are carefully tuned for a premium, responsive feel.
enum SpringConfig {
    // MARK: Interactive Springs

    /// Quick, responsive feedback - perfect for button presses and toggles
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)

    /// Smooth, calming transitions - ideal for page transitions and modals
    static let gentle = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)

    /// Playful, celebratory - use for completion animations and celebrations
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.5, blendDuration: 0)

    /// Minimal overshoot, professional - for subtle state changes
    static let stiff = Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0)

    /// For gesture-driven animations - responds to velocity
    static let interactive = Animation.interactiveSpring(response: 0.15, dampingFraction: 0.86, blendDuration: 0.25)

    // MARK: Specialized Springs

    /// Extra bouncy for achievement/celebration moments
    static let celebration = Animation.spring(response: 0.45, dampingFraction: 0.4, blendDuration: 0)

    /// Ultra-smooth for swipe actions settling
    static let settle = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)

    /// Responsive for checkbox/toggle animations
    static let toggle = Animation.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0)
}

// MARK: - Easing Curves

/// Standard easing curves for non-spring animations.
enum EasingCurve {
    /// Ease out - starts fast, slows down (most common)
    static let easeOut = Animation.easeOut(duration: AnimationTiming.normal)

    /// Ease in - starts slow, speeds up (for exits)
    static let easeIn = Animation.easeIn(duration: AnimationTiming.normal)

    /// Ease in-out - smooth start and end
    static let easeInOut = Animation.easeInOut(duration: AnimationTiming.normal)

    /// Linear - constant speed (rare, use for progress indicators)
    static let linear = Animation.linear(duration: AnimationTiming.normal)

    /// Custom ease out with longer duration for emphasis
    static let emphasisEaseOut = Animation.easeOut(duration: AnimationTiming.slow)
}
