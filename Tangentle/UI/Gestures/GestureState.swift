import Foundation

// MARK: - Swipe State

/// Represents the current state of a swipe gesture.
/// Used to track swipe progress and determine which action to trigger.
enum SwipeState: Equatable {
    /// No swipe in progress
    case idle

    /// User is actively swiping
    /// - Parameter translation: Current horizontal translation in points
    case dragging(translation: CGFloat)

    /// User has crossed the threshold for an action
    /// - Parameter action: Which side the action is on
    case triggering(action: SwipeActionSide)

    /// Swipe action completed
    case completed

    /// Which side of the row the swipe action is on
    enum SwipeActionSide: Equatable {
        /// Left-to-right swipe (leading actions)
        case leading
        /// Right-to-left swipe (trailing actions)
        case trailing
    }

    /// Whether the swipe is currently active (not idle or completed)
    var isActive: Bool {
        switch self {
        case .idle, .completed:
            return false
        case .dragging, .triggering:
            return true
        }
    }

    /// Get the translation if in dragging state
    var translation: CGFloat? {
        if case .dragging(let t) = self {
            return t
        }
        return nil
    }
}

// MARK: - Long Press State

/// Represents the current state of a long press "charge" gesture.
/// Used for intentional, progressive actions like task completion.
enum LongPressState: Equatable {
    /// No press in progress
    case idle

    /// User is holding and charging
    /// - Parameter progress: Charge progress from 0.0 to 1.0
    case charging(progress: CGFloat)

    /// Charge completed (reached 1.0)
    case completed

    /// Press was released before completion
    case cancelled

    /// Whether a press is currently in progress
    var isActive: Bool {
        switch self {
        case .charging:
            return true
        case .idle, .completed, .cancelled:
            return false
        }
    }

    /// Get the progress if in charging state
    var progress: CGFloat? {
        if case .charging(let p) = self {
            return p
        }
        return nil
    }
}

// MARK: - Gesture Result

/// Result of a completed gesture, used for action dispatch.
enum GestureResult {
    /// Swipe completed with an action
    case swipe(side: SwipeState.SwipeActionSide, velocity: CGFloat)

    /// Long press completed successfully
    case longPress

    /// Gesture was cancelled
    case cancelled
}
