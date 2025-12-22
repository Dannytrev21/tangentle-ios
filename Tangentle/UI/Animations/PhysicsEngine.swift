import UIKit

// MARK: - Momentum Calculator

/// Physics calculations for gesture-driven animations.
/// Provides momentum-based endpoint calculation and rubber banding.
struct MomentumCalculator {
    // MARK: Decay Calculations

    /// Calculate the endpoint of a momentum-based decay animation.
    /// Uses the same physics as UIScrollView's deceleration.
    ///
    /// - Parameters:
    ///   - startValue: Current position/value
    ///   - velocity: Current velocity (points per second)
    ///   - decelerationRate: Deceleration rate (default: normal scroll deceleration)
    /// - Returns: The projected endpoint after momentum decay
    static func decayEndpoint(
        startValue: CGFloat,
        velocity: CGFloat,
        decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue
    ) -> CGFloat {
        // UIScrollView's deceleration formula
        let coefficient = 1000 * log(decelerationRate)
        return startValue - velocity / coefficient
    }

    /// Calculate 2D decay endpoint for gestures with both X and Y velocity.
    ///
    /// - Parameters:
    ///   - startPoint: Current position
    ///   - velocity: Current velocity as CGPoint
    ///   - decelerationRate: Deceleration rate
    /// - Returns: The projected endpoint
    static func decayEndpoint(
        startPoint: CGPoint,
        velocity: CGPoint,
        decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue
    ) -> CGPoint {
        CGPoint(
            x: decayEndpoint(startValue: startPoint.x, velocity: velocity.x, decelerationRate: decelerationRate),
            y: decayEndpoint(startValue: startPoint.y, velocity: velocity.y, decelerationRate: decelerationRate)
        )
    }

    /// Calculate the time to reach a threshold velocity during decay.
    ///
    /// - Parameters:
    ///   - velocity: Initial velocity
    ///   - threshold: Target velocity threshold (default: 0.5 points/sec)
    ///   - decelerationRate: Deceleration rate
    /// - Returns: Duration in seconds
    static func decayDuration(
        velocity: CGFloat,
        threshold: CGFloat = 0.5,
        decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue
    ) -> Double {
        guard abs(velocity) > threshold else { return 0 }
        let coefficient = 1000 * log(decelerationRate)
        return Double(log(threshold / abs(velocity)) / coefficient)
    }

    // MARK: Rubber Banding

    /// Apply rubber band resistance when a value exceeds its limit.
    /// Creates the elastic over-scroll effect seen in iOS scroll views.
    ///
    /// - Parameters:
    ///   - value: Current value (may exceed limit)
    ///   - limit: The boundary limit
    ///   - coefficient: Resistance coefficient (0.55 is iOS default)
    /// - Returns: The rubber-banded value
    static func rubberBand(
        value: CGFloat,
        limit: CGFloat,
        coefficient: CGFloat = 0.55
    ) -> CGFloat {
        guard limit > 0 else { return value }
        if abs(value) <= limit { return value }

        let excess = abs(value) - limit
        let damped = limit + (1 - (1 / ((excess * coefficient / limit) + 1))) * limit
        return value > 0 ? damped : -damped
    }

    /// Apply rubber banding with separate min/max limits.
    ///
    /// - Parameters:
    ///   - value: Current value
    ///   - minLimit: Minimum boundary
    ///   - maxLimit: Maximum boundary
    ///   - coefficient: Resistance coefficient
    /// - Returns: The rubber-banded value
    static func rubberBand(
        value: CGFloat,
        minLimit: CGFloat,
        maxLimit: CGFloat,
        coefficient: CGFloat = 0.55
    ) -> CGFloat {
        if value < minLimit {
            let excess = minLimit - value
            let range = maxLimit - minLimit
            guard range > 0 else { return value }
            let damped = (1 - (1 / ((excess * coefficient / range) + 1))) * range
            return minLimit - damped
        } else if value > maxLimit {
            let excess = value - maxLimit
            let range = maxLimit - minLimit
            guard range > 0 else { return value }
            let damped = (1 - (1 / ((excess * coefficient / range) + 1))) * range
            return maxLimit + damped
        }
        return value
    }

    // MARK: Snapping

    /// Calculate the nearest snap point from a set of targets.
    ///
    /// - Parameters:
    ///   - value: Current value
    ///   - velocity: Current velocity (influences snap direction)
    ///   - targets: Available snap points
    ///   - velocityThreshold: Minimum velocity to influence snapping
    /// - Returns: The target snap point
    static func snapTarget(
        value: CGFloat,
        velocity: CGFloat,
        targets: [CGFloat],
        velocityThreshold: CGFloat = 100
    ) -> CGFloat {
        guard !targets.isEmpty else { return value }
        guard targets.count > 1 else { return targets[0] }

        // If velocity is significant, project endpoint
        let projectedValue: CGFloat
        if abs(velocity) > velocityThreshold {
            projectedValue = decayEndpoint(startValue: value, velocity: velocity)
        } else {
            projectedValue = value
        }

        // Find nearest target
        return targets.min(by: { abs($0 - projectedValue) < abs($1 - projectedValue) }) ?? value
    }
}

// MARK: - Gesture Velocity Helpers

extension MomentumCalculator {
    /// Determine if a swipe gesture has sufficient velocity to trigger an action.
    ///
    /// - Parameters:
    ///   - velocity: Swipe velocity
    ///   - threshold: Minimum velocity threshold
    /// - Returns: True if the swipe is fast enough
    static func isSwipeFastEnough(velocity: CGFloat, threshold: CGFloat = 300) -> Bool {
        abs(velocity) > threshold
    }

    /// Determine if a gesture has moved far enough to trigger an action.
    ///
    /// - Parameters:
    ///   - translation: Total translation
    ///   - threshold: Distance threshold
    /// - Returns: True if moved far enough
    static func hasMovedFarEnough(translation: CGFloat, threshold: CGFloat = 50) -> Bool {
        abs(translation) > threshold
    }

    /// Calculate the progress (0-1) of a swipe gesture.
    ///
    /// - Parameters:
    ///   - translation: Current translation
    ///   - target: Target distance for 100% progress
    /// - Returns: Progress value (clamped 0-1)
    static func swipeProgress(translation: CGFloat, target: CGFloat) -> CGFloat {
        guard target != 0 else { return 0 }
        return min(1, max(0, abs(translation) / target))
    }
}
