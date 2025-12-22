# Step 3: Typography Scale

## Context
Typography is crucial for readability and hierarchy, especially for ADHD users who benefit from clear visual organization. We'll use SF Pro (system font) with a custom type scale for consistency.

## Goal
Define a semantic typography system with consistent sizing, weights, and line heights that creates clear visual hierarchy.

## Prerequisites
- Step 1 (Design Tokens) completed

## High-Level Steps
1. Define type scale with semantic names
2. Create Font extensions for easy access
3. Define line height/spacing standards
4. Add SF Rounded variant for softer elements
5. Create text style view modifiers

## Detailed Requirements

### Type Scale Definition
```swift
enum Typography {
    // Display - Hero text
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)

    // Title - Section headers
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)

    // Body - Main content
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // Label - UI elements
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // Caption - Secondary info
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)

    // Rounded variants (for friendly elements like buttons, badges)
    static let roundedBody = Font.system(size: 15, weight: .medium, design: .rounded)
    static let roundedLabel = Font.system(size: 13, weight: .semibold, design: .rounded)
}
```

### Line Height Standards
```swift
enum LineHeight {
    static let tight: CGFloat = 1.1      // Headlines
    static let normal: CGFloat = 1.4     // Body text
    static let relaxed: CGFloat = 1.6    // Long-form reading
}
```

### Text Style View Modifier
```swift
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
    func textStyle(_ style: Font, color: Color, lineSpacing: CGFloat = 0) -> some View {
        modifier(TextStyle(font: style, color: color, lineSpacing: lineSpacing))
    }
}
```

### Usage Pattern
```swift
struct SomeView: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Section Title")
                .font(Typography.titleMedium)
                .foregroundStyle(theme.textPrimary)

            Text("Body content here...")
                .font(Typography.bodyMedium)
                .foregroundStyle(theme.textSecondary)
        }
    }
}
```

## Files to Create

### `Tangentle/UI/Themes/Typography.swift`
Type scale definitions, line heights, and text style modifiers.

## Files to Modify
- None

## Patterns to Follow
Reference: System SF font sizes from Apple HIG

## Acceptance Criteria
- [ ] All type styles defined with semantic names
- [ ] Font sizes follow iOS conventions (17pt body)
- [ ] Weights are appropriate for hierarchy
- [ ] SF Rounded variant available for friendly elements
- [ ] Line height constants defined
- [ ] Text style view modifier works
- [ ] **Dynamic Type supported** - Use `.font()` modifier (not fixed sizes in UIFont)
- [ ] Text scales appropriately with accessibility text sizes
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check file exists
cat /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Themes/Typography.swift | head -30
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Check Font.system syntax
2. Ensure CGFloat types for sizes
3. Verify import SwiftUI

## Do NOT
- Use custom fonts (SF Pro only for MVP)
- Create font assets
- Deviate significantly from iOS standard sizes
