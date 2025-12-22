import Foundation

// MARK: - Haptic Types

/// Types of haptic feedback available in the app.
/// Each type maps to a specific feedback pattern optimized for its use case.
enum HapticType {
    // MARK: Standard Feedback

    /// Light tick for selections (list items, toggles)
    case selection

    /// Subtle interaction feedback
    case light

    /// Standard confirmation feedback
    case medium

    /// Strong feedback for emphasis
    case heavy

    // MARK: Notification Types

    /// Task completed successfully
    case success

    /// Caution or attention needed
    case warning

    /// Something went wrong
    case error

    // MARK: Custom Patterns

    /// Satisfying thunk for task completion - the reward moment
    case completion

    /// Crossed swipe action threshold - confirms action will trigger
    case swipeThreshold

    /// Beginning a long press charge
    case longPressStart

    /// Completing a long press charge - action will fire
    case longPressEnd

    /// Tab bar item selected
    case tabSelection

    /// Pull-to-refresh crossed threshold
    case refreshThreshold
}

// MARK: - Haptic Intensity Settings

/// User preference for haptic feedback intensity.
/// Defaults to "selective" which provides feedback only at key moments,
/// reducing sensory overload for ADHD users while still confirming actions.
enum HapticIntensity: String, Codable, CaseIterable, Identifiable {
    /// No haptic feedback
    case off = "off"

    /// Key moments only (completion, swipe threshold, errors)
    case selective = "selective"

    /// Most interactions get haptic feedback
    case rich = "rich"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .selective: return "Selective"
        case .rich: return "Rich"
        }
    }

    var description: String {
        switch self {
        case .off:
            return "No haptic feedback"
        case .selective:
            return "Key moments only"
        case .rich:
            return "Most interactions"
        }
    }
}
