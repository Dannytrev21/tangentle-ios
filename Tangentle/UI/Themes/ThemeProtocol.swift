import SwiftUI

// MARK: - Theme Protocol

/// Protocol defining all semantic color properties for a theme.
/// Implementations provide concrete colors for light and dark modes.
protocol ThemeProtocol {
    // MARK: - Backgrounds

    /// Primary background color (main canvas)
    var backgroundPrimary: Color { get }

    /// Secondary background color (sections, grouped content)
    var backgroundSecondary: Color { get }

    /// Tertiary background color (nested grouping)
    var backgroundTertiary: Color { get }

    // MARK: - Surfaces

    /// Elevated surface color (cards, modals)
    var surfaceElevated: Color { get }

    /// Pressed/active surface state
    var surfacePressed: Color { get }

    // MARK: - Text

    /// Primary text color (headings, body)
    var textPrimary: Color { get }

    /// Secondary text color (captions, metadata)
    var textSecondary: Color { get }

    /// Tertiary text color (hints, placeholders)
    var textTertiary: Color { get }

    /// Disabled text color
    var textDisabled: Color { get }

    /// Text on dark/accent backgrounds
    var textInverse: Color { get }

    // MARK: - Accent

    /// Primary accent color (buttons, links)
    var accentPrimary: Color { get }

    /// Secondary accent color (hover states)
    var accentSecondary: Color { get }

    /// Soft accent for backgrounds
    var accentSoft: Color { get }

    // MARK: - Status

    /// Success color (completed, positive)
    var statusSuccess: Color { get }

    /// Success tint for backgrounds
    var statusSuccessTint: Color { get }

    /// Warning color (attention needed)
    var statusWarning: Color { get }

    /// Warning tint for backgrounds
    var statusWarningTint: Color { get }

    /// Error color (failures, destructive)
    var statusError: Color { get }

    /// Error tint for backgrounds
    var statusErrorTint: Color { get }

    /// Info color (neutral information)
    var statusInfo: Color { get }

    /// Info tint for backgrounds
    var statusInfoTint: Color { get }

    // MARK: - Priority

    /// High priority color
    var priorityHigh: Color { get }

    /// Medium priority color
    var priorityMedium: Color { get }

    /// Low priority color
    var priorityLow: Color { get }

    /// No priority color
    var priorityNone: Color { get }

    // MARK: - Energy Levels

    /// High energy color
    var energyHigh: Color { get }

    /// Medium energy color
    var energyMedium: Color { get }

    /// Low energy color
    var energyLow: Color { get }

    // MARK: - Interactive

    /// Divider/separator color
    var divider: Color { get }

    /// Border color
    var border: Color { get }

    /// Focus ring color
    var focusRing: Color { get }
}
