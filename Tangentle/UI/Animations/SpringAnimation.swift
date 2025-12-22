import UIKit

// MARK: - UIKit Spring Configuration

/// UIKit-compatible spring configuration for gesture-driven animations.
/// Use these when animating with UIViewPropertyAnimator or UIKit dynamics.
struct UISpringConfig {
    let mass: CGFloat
    let stiffness: CGFloat
    let damping: CGFloat

    // MARK: Presets

    /// Quick, responsive - matches SpringConfig.snappy
    static let snappy = UISpringConfig(mass: 1, stiffness: 300, damping: 20)

    /// Smooth, calming - matches SpringConfig.gentle
    static let gentle = UISpringConfig(mass: 1, stiffness: 150, damping: 15)

    /// Playful, bouncy - matches SpringConfig.bouncy
    static let bouncy = UISpringConfig(mass: 1, stiffness: 200, damping: 10)

    /// Minimal overshoot - matches SpringConfig.stiff
    static let stiff = UISpringConfig(mass: 1, stiffness: 400, damping: 25)

    /// For gesture-driven interactions
    static let interactive = UISpringConfig(mass: 1, stiffness: 350, damping: 30)

    /// Settling after swipe
    static let settle = UISpringConfig(mass: 1, stiffness: 250, damping: 22)

    // MARK: Timing Parameters

    /// Create UISpringTimingParameters with zero initial velocity
    var timingParameters: UISpringTimingParameters {
        UISpringTimingParameters(
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: .zero
        )
    }

    /// Create UISpringTimingParameters with initial velocity from gesture
    /// - Parameter initialVelocity: Gesture velocity as CGVector
    func timingParameters(initialVelocity: CGVector) -> UISpringTimingParameters {
        UISpringTimingParameters(
            mass: mass,
            stiffness: stiffness,
            damping: damping,
            initialVelocity: initialVelocity
        )
    }

    // MARK: Animator Factory

    /// Create a UIViewPropertyAnimator with this spring configuration
    /// - Parameters:
    ///   - duration: Approximate duration (spring may override)
    ///   - velocity: Initial velocity from gesture
    /// - Returns: Configured animator
    func animator(duration: TimeInterval = 0, velocity: CGVector = .zero) -> UIViewPropertyAnimator {
        UIViewPropertyAnimator(
            duration: duration,
            timingParameters: timingParameters(initialVelocity: velocity)
        )
    }
}

// MARK: - Velocity Conversion

extension UISpringConfig {
    /// Convert a translation velocity (points/second) to a relative velocity for springs
    /// - Parameters:
    ///   - velocity: Velocity in points per second
    ///   - distance: Remaining distance to target
    /// - Returns: Relative velocity suitable for spring animations
    static func relativeVelocity(forVelocity velocity: CGFloat, distance: CGFloat) -> CGFloat {
        guard distance != 0 else { return 0 }
        return velocity / distance
    }

    /// Convert 2D velocity to CGVector for spring parameters
    /// - Parameters:
    ///   - velocity: 2D velocity in points per second
    ///   - distance: 2D remaining distance to target
    /// - Returns: Relative velocity as CGVector
    static func relativeVelocity(forVelocity velocity: CGPoint, distance: CGPoint) -> CGVector {
        CGVector(
            dx: relativeVelocity(forVelocity: velocity.x, distance: distance.x),
            dy: relativeVelocity(forVelocity: velocity.y, distance: distance.y)
        )
    }
}

// MARK: - Animation Duration Estimates

extension UISpringConfig {
    /// Approximate settling duration for this spring (time to reach 1% of target)
    var settlingDuration: TimeInterval {
        // Approximation based on damping ratio
        let dampingRatio = damping / (2 * sqrt(stiffness * mass))
        if dampingRatio >= 1 {
            // Overdamped
            return 4 / (dampingRatio * sqrt(stiffness / mass))
        } else {
            // Underdamped
            return -log(0.01) / (dampingRatio * sqrt(stiffness / mass))
        }
    }
}
