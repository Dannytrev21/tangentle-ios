import SwiftUI

// MARK: - Warm Light Theme

/// Warm light theme with cream/ivory backgrounds and terracotta accents.
/// Designed to feel inviting and ADHD-friendly with excellent readability.
struct WarmLightTheme: ThemeProtocol {
    // MARK: - Backgrounds

    var backgroundPrimary: Color { LightColors.backgroundPrimary }
    var backgroundSecondary: Color { LightColors.backgroundSecondary }
    var backgroundTertiary: Color { LightColors.backgroundTertiary }

    // MARK: - Surfaces

    var surfaceElevated: Color { LightColors.surfaceElevated }
    var surfacePressed: Color { LightColors.backgroundTertiary }

    // MARK: - Text

    var textPrimary: Color { LightColors.textPrimary }
    var textSecondary: Color { LightColors.textSecondary }
    var textTertiary: Color { LightColors.textTertiary }
    var textDisabled: Color { LightColors.textDisabled }
    var textInverse: Color { DarkColors.textPrimary }

    // MARK: - Accent

    var accentPrimary: Color { LightColors.accentPrimary }
    var accentSecondary: Color { LightColors.accentSecondary }
    var accentSoft: Color { LightColors.accentPrimary.opacity(0.15) }

    // MARK: - Status

    var statusSuccess: Color { LightColors.statusSuccess }
    var statusSuccessTint: Color { LightColors.statusSuccessTint }
    var statusWarning: Color { LightColors.statusWarning }
    var statusWarningTint: Color { LightColors.statusWarningTint }
    var statusError: Color { LightColors.statusError }
    var statusErrorTint: Color { LightColors.statusErrorTint }
    var statusInfo: Color { LightColors.statusInfo }
    var statusInfoTint: Color { LightColors.statusInfoTint }

    // MARK: - Priority

    var priorityHigh: Color { LightColors.priorityHigh }
    var priorityMedium: Color { LightColors.priorityMedium }
    var priorityLow: Color { LightColors.priorityLow }
    var priorityNone: Color { LightColors.priorityNone }

    // MARK: - Energy Levels

    var energyHigh: Color { LightColors.energyHigh }
    var energyMedium: Color { LightColors.energyMedium }
    var energyLow: Color { LightColors.energyLow }

    // MARK: - Interactive

    var divider: Color { LightColors.divider }
    var border: Color { LightColors.border }
    var focusRing: Color { LightColors.focusRing }
}
