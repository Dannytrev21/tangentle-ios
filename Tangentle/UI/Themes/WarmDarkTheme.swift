import SwiftUI

// MARK: - Warm Dark Theme

/// Warm dark theme with charcoal backgrounds and amber accents.
/// Never uses pure black - maintains warmth for comfortable night reading.
struct WarmDarkTheme: ThemeProtocol {
    // MARK: - Backgrounds

    var backgroundPrimary: Color { DarkColors.backgroundPrimary }
    var backgroundSecondary: Color { DarkColors.backgroundSecondary }
    var backgroundTertiary: Color { DarkColors.backgroundTertiary }

    // MARK: - Surfaces

    var surfaceElevated: Color { DarkColors.surfaceElevated }
    var surfacePressed: Color { DarkColors.backgroundTertiary }

    // MARK: - Text

    var textPrimary: Color { DarkColors.textPrimary }
    var textSecondary: Color { DarkColors.textSecondary }
    var textTertiary: Color { DarkColors.textTertiary }
    var textDisabled: Color { DarkColors.textDisabled }
    var textInverse: Color { LightColors.textPrimary }

    // MARK: - Accent

    var accentPrimary: Color { DarkColors.accentPrimary }
    var accentSecondary: Color { DarkColors.accentSecondary }
    var accentSoft: Color { DarkColors.accentPrimary.opacity(0.2) }

    // MARK: - Status

    var statusSuccess: Color { DarkColors.statusSuccess }
    var statusSuccessTint: Color { DarkColors.statusSuccessTint }
    var statusWarning: Color { DarkColors.statusWarning }
    var statusWarningTint: Color { DarkColors.statusWarningTint }
    var statusError: Color { DarkColors.statusError }
    var statusErrorTint: Color { DarkColors.statusErrorTint }
    var statusInfo: Color { DarkColors.statusInfo }
    var statusInfoTint: Color { DarkColors.statusInfoTint }

    // MARK: - Priority

    var priorityHigh: Color { DarkColors.priorityHigh }
    var priorityMedium: Color { DarkColors.priorityMedium }
    var priorityLow: Color { DarkColors.priorityLow }
    var priorityNone: Color { DarkColors.priorityNone }

    // MARK: - Energy Levels

    var energyHigh: Color { DarkColors.energyHigh }
    var energyMedium: Color { DarkColors.energyMedium }
    var energyLow: Color { DarkColors.energyLow }

    // MARK: - Interactive

    var divider: Color { DarkColors.divider }
    var border: Color { DarkColors.border }
    var focusRing: Color { DarkColors.focusRing }
}
