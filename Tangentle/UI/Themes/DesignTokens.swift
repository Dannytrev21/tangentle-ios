import SwiftUI

// MARK: - Color Extension

extension Color {
    /// Initialize a Color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Light Mode Colors

enum LightColors {
    // MARK: Backgrounds
    /// Warm off-white, primary background
    static let backgroundPrimary = Color(hex: "FFFDF7")
    /// Slightly warmer, secondary areas
    static let backgroundSecondary = Color(hex: "FBF8F3")
    /// Tertiary background for grouping
    static let backgroundTertiary = Color(hex: "F5F0E8")
    /// Elevated surface (cards, modals)
    static let surfaceElevated = Color(hex: "FFFFFF")

    // MARK: Text
    /// Primary text - warm black
    static let textPrimary = Color(hex: "1C1917")
    /// Secondary text - warm gray
    static let textSecondary = Color(hex: "78716C")
    /// Tertiary text - lighter gray
    static let textTertiary = Color(hex: "A8A29E")
    /// Disabled text
    static let textDisabled = Color(hex: "D6D3D1")

    // MARK: Accent
    /// Primary accent - amber/terracotta
    static let accentPrimary = Color(hex: "D97706")
    /// Secondary accent - softer amber
    static let accentSecondary = Color(hex: "F59E0B")
    /// Accent on dark backgrounds
    static let accentOnDark = Color(hex: "FBBF24")

    // MARK: Status
    /// Success green
    static let statusSuccess = Color(hex: "059669")
    /// Success background tint
    static let statusSuccessTint = Color(hex: "D1FAE5")
    /// Error red
    static let statusError = Color(hex: "DC2626")
    /// Error background tint
    static let statusErrorTint = Color(hex: "FEE2E2")
    /// Warning amber
    static let statusWarning = Color(hex: "D97706")
    /// Warning background tint
    static let statusWarningTint = Color(hex: "FEF3C7")
    /// Info blue
    static let statusInfo = Color(hex: "2563EB")
    /// Info background tint
    static let statusInfoTint = Color(hex: "DBEAFE")

    // MARK: Priority Colors
    /// High priority - coral red
    static let priorityHigh = Color(hex: "EF4444")
    /// Medium priority - amber
    static let priorityMedium = Color(hex: "F59E0B")
    /// Low priority - blue gray
    static let priorityLow = Color(hex: "6B7280")
    /// No priority - light gray
    static let priorityNone = Color(hex: "D1D5DB")

    // MARK: Energy Level Colors
    /// High energy - vibrant green
    static let energyHigh = Color(hex: "10B981")
    /// Medium energy - yellow
    static let energyMedium = Color(hex: "FBBF24")
    /// Low energy - muted purple
    static let energyLow = Color(hex: "8B5CF6")

    // MARK: Interactive
    /// Divider/separator
    static let divider = Color(hex: "E7E5E4")
    /// Border color
    static let border = Color(hex: "D6D3D1")
    /// Focus ring
    static let focusRing = Color(hex: "D97706").opacity(0.4)
}

// MARK: - Dark Mode Colors

enum DarkColors {
    // MARK: Backgrounds
    /// Warm charcoal, primary background
    static let backgroundPrimary = Color(hex: "1C1917")
    /// Secondary background
    static let backgroundSecondary = Color(hex: "292524")
    /// Tertiary background
    static let backgroundTertiary = Color(hex: "44403C")
    /// Elevated surface
    static let surfaceElevated = Color(hex: "292524")

    // MARK: Text
    /// Primary text - warm white
    static let textPrimary = Color(hex: "FAFAF9")
    /// Secondary text
    static let textSecondary = Color(hex: "A8A29E")
    /// Tertiary text
    static let textTertiary = Color(hex: "78716C")
    /// Disabled text
    static let textDisabled = Color(hex: "57534E")

    // MARK: Accent
    /// Primary accent - brighter amber for dark mode
    static let accentPrimary = Color(hex: "F59E0B")
    /// Secondary accent
    static let accentSecondary = Color(hex: "FBBF24")
    /// Accent on light elements
    static let accentOnLight = Color(hex: "D97706")

    // MARK: Status
    /// Success green
    static let statusSuccess = Color(hex: "10B981")
    /// Success background tint (muted)
    static let statusSuccessTint = Color(hex: "064E3B")
    /// Error red
    static let statusError = Color(hex: "EF4444")
    /// Error background tint
    static let statusErrorTint = Color(hex: "7F1D1D")
    /// Warning amber
    static let statusWarning = Color(hex: "F59E0B")
    /// Warning background tint
    static let statusWarningTint = Color(hex: "78350F")
    /// Info blue
    static let statusInfo = Color(hex: "3B82F6")
    /// Info background tint
    static let statusInfoTint = Color(hex: "1E3A8A")

    // MARK: Priority Colors
    /// High priority
    static let priorityHigh = Color(hex: "F87171")
    /// Medium priority
    static let priorityMedium = Color(hex: "FBBF24")
    /// Low priority
    static let priorityLow = Color(hex: "9CA3AF")
    /// No priority
    static let priorityNone = Color(hex: "57534E")

    // MARK: Energy Level Colors
    /// High energy
    static let energyHigh = Color(hex: "34D399")
    /// Medium energy
    static let energyMedium = Color(hex: "FCD34D")
    /// Low energy
    static let energyLow = Color(hex: "A78BFA")

    // MARK: Interactive
    /// Divider/separator
    static let divider = Color(hex: "44403C")
    /// Border color
    static let border = Color(hex: "57534E")
    /// Focus ring
    static let focusRing = Color(hex: "F59E0B").opacity(0.4)
}

// MARK: - Spacing Scale (4pt Grid)

enum Spacing {
    /// 2pt - Micro spacing
    static let xxxs: CGFloat = 2
    /// 4pt - Extra extra small
    static let xxs: CGFloat = 4
    /// 8pt - Extra small
    static let xs: CGFloat = 8
    /// 12pt - Small
    static let sm: CGFloat = 12
    /// 16pt - Medium (base)
    static let md: CGFloat = 16
    /// 20pt - Medium large
    static let lg: CGFloat = 20
    /// 24pt - Large
    static let xl: CGFloat = 24
    /// 32pt - Extra large
    static let xxl: CGFloat = 32
    /// 48pt - Extra extra large
    static let xxxl: CGFloat = 48
    /// 64pt - Macro spacing
    static let xxxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    /// 4pt - Subtle rounding
    static let xs: CGFloat = 4
    /// 8pt - Small elements
    static let sm: CGFloat = 8
    /// 12pt - Medium elements (buttons, cards)
    static let md: CGFloat = 12
    /// 16pt - Large elements (modals, sheets)
    static let lg: CGFloat = 16
    /// 20pt - Extra large
    static let xl: CGFloat = 20
    /// 24pt - Very rounded
    static let xxl: CGFloat = 24
    /// Full circle (use on equal width/height)
    static let full: CGFloat = 9999
}

// MARK: - Shadow Tokens

struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Apply this shadow to a view
    func apply(to view: some View) -> some View {
        view.shadow(color: color, radius: radius, x: x, y: y)
    }
}

enum Shadow {
    /// Subtle elevation for cards
    static let sm = ShadowToken(
        color: Color.black.opacity(0.05),
        radius: 4,
        x: 0,
        y: 2
    )

    /// Medium elevation for floating elements
    static let md = ShadowToken(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Large elevation for modals
    static let lg = ShadowToken(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )

    /// Extra large for popovers
    static let xl = ShadowToken(
        color: Color.black.opacity(0.15),
        radius: 24,
        x: 0,
        y: 12
    )

    // MARK: Colored Shadows

    /// Success glow
    static let successGlow = ShadowToken(
        color: LightColors.statusSuccess.opacity(0.3),
        radius: 12,
        x: 0,
        y: 4
    )

    /// Accent glow
    static let accentGlow = ShadowToken(
        color: LightColors.accentPrimary.opacity(0.3),
        radius: 12,
        x: 0,
        y: 4
    )
}

// MARK: - Animation Duration

enum Duration {
    /// 100ms - Very fast (button feedback)
    static let fast: Double = 0.1
    /// 200ms - Fast (micro-interactions)
    static let quick: Double = 0.2
    /// 300ms - Medium (standard transitions)
    static let medium: Double = 0.3
    /// 400ms - Slow (emphasized transitions)
    static let slow: Double = 0.4
    /// 500ms - Very slow (dramatic transitions)
    static let slower: Double = 0.5
}

// MARK: - Opacity Levels

enum Opacity {
    /// 5% - Barely visible
    static let ghost: Double = 0.05
    /// 10% - Very subtle
    static let subtle: Double = 0.1
    /// 25% - Light
    static let light: Double = 0.25
    /// 50% - Medium
    static let medium: Double = 0.5
    /// 75% - Heavy
    static let heavy: Double = 0.75
    /// 90% - Nearly opaque
    static let dense: Double = 0.9
}
