import SwiftUI

// MARK: - Typography Scale

/// Semantic typography system using SF Pro with consistent sizing and weights.
/// Supports Dynamic Type accessibility automatically through Font.system.
enum Typography {
    // MARK: - Display
    /// Hero text, splash screens (34pt bold)
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
    /// Large display, section heroes (28pt bold)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)

    // MARK: - Title
    /// Primary section headers (22pt semibold)
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    /// Secondary headers (18pt semibold)
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)
    /// Tertiary headers, card titles (16pt semibold)
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Body
    /// Primary body text (17pt regular - iOS standard)
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    /// Secondary body text (15pt regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    /// Small body text (13pt regular)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Label
    /// Large UI labels, buttons (15pt medium)
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    /// Standard UI labels (13pt medium)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    /// Small UI labels, badges (11pt medium)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Caption
    /// Captions, footnotes (12pt regular)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    /// Emphasized captions (12pt semibold)
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)

    // MARK: - Rounded Variants
    /// Friendly body text (15pt medium, rounded)
    static let roundedBody = Font.system(size: 15, weight: .medium, design: .rounded)
    /// Friendly labels, badges (13pt semibold, rounded)
    static let roundedLabel = Font.system(size: 13, weight: .semibold, design: .rounded)
    /// Large rounded for emphasis (17pt semibold, rounded)
    static let roundedLarge = Font.system(size: 17, weight: .semibold, design: .rounded)

    // MARK: - Monospaced
    /// Code, timestamps (13pt regular, monospaced)
    static let mono = Font.system(size: 13, weight: .regular, design: .monospaced)
    /// Code with emphasis (13pt medium, monospaced)
    static let monoBold = Font.system(size: 13, weight: .medium, design: .monospaced)
}

// MARK: - Line Height

/// Line height multipliers for different text contexts.
enum LineHeight {
    /// Tight spacing for headlines (1.1x)
    static let tight: CGFloat = 1.1
    /// Normal spacing for body text (1.4x)
    static let normal: CGFloat = 1.4
    /// Relaxed spacing for long-form reading (1.6x)
    static let relaxed: CGFloat = 1.6
    /// Extra spacing for accessibility (1.8x)
    static let spacious: CGFloat = 1.8
}

// MARK: - Text Style Modifier

/// View modifier for applying consistent text styling.
struct TextStyle: ViewModifier {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .lineSpacing(lineSpacing)
    }
}

extension View {
    /// Apply a consistent text style with font, color, and line spacing.
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .textStyle(Typography.bodyMedium, color: theme.textPrimary)
    /// ```
    func textStyle(_ font: Font, color: Color, lineSpacing: CGFloat = 0) -> some View {
        modifier(TextStyle(font: font, color: color, lineSpacing: lineSpacing))
    }
}

// MARK: - Semantic Text Styles

/// Pre-built text style configurations for common use cases.
enum TextStyles {
    /// Title style with theme colors
    static func title(_ theme: ThemeProtocol) -> some ViewModifier {
        TextStyle(font: Typography.titleMedium, color: theme.textPrimary, lineSpacing: 2)
    }

    /// Body style with theme colors
    static func body(_ theme: ThemeProtocol) -> some ViewModifier {
        TextStyle(font: Typography.bodyMedium, color: theme.textPrimary, lineSpacing: 4)
    }

    /// Caption style with theme colors
    static func caption(_ theme: ThemeProtocol) -> some ViewModifier {
        TextStyle(font: Typography.caption, color: theme.textSecondary, lineSpacing: 2)
    }

    /// Label style with theme colors
    static func label(_ theme: ThemeProtocol) -> some ViewModifier {
        TextStyle(font: Typography.labelMedium, color: theme.textSecondary, lineSpacing: 0)
    }
}
