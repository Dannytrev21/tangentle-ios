# Step 1: Design Tokens

## Context
Design tokens are the atomic building blocks of the visual design system. They define the raw values (colors, spacing, radii, shadows) that will be used throughout the app. This is the foundation that all other UI work builds upon.

## Goal
Create a comprehensive design token system with semantic naming that supports both light and dark modes, warm aesthetic, and future theme extensibility.

## Prerequisites
- None (this is the first step)

## High-Level Steps
1. Create the `UI/Themes/` directory structure
2. Define color tokens for light mode (warm neutrals)
3. Define color tokens for dark mode (warm darks)
4. Define spacing scale (4pt grid)
5. Define corner radius scale
6. Define shadow tokens
7. Create Swift constants/extensions

## Detailed Requirements

### Color Tokens (Light Mode - Warm Neutrals)
```
Background:
- .backgroundPrimary: #FFFDF7 (warm off-white, like aged paper)
- .backgroundSecondary: #FBF8F3 (slightly warmer for cards)
- .backgroundTertiary: #F5F0E8 (dividers, subtle separators)

Surface:
- .surfaceElevated: #FFFFFF (pure white for elevated cards)
- .surfacePressed: #F0EBE3 (pressed state)

Text:
- .textPrimary: #1C1917 (warm black, not pure black)
- .textSecondary: #78716C (warm gray)
- .textTertiary: #A8A29E (muted)
- .textInverse: #FFFDF7 (for dark backgrounds)

Accent:
- .accentPrimary: #D97706 (amber/terracotta - energizing)
- .accentSecondary: #92400E (darker amber for pressed)
- .accentSoft: #FEF3C7 (light amber for backgrounds)

Status:
- .statusSuccess: #059669 (green - completed)
- .statusWarning: #D97706 (amber - attention)
- .statusError: #DC2626 (red - overdue/delete)
- .statusInfo: #0891B2 (teal - info)

Priority:
- .priorityHigh: #DC2626 (red)
- .priorityMedium: #D97706 (amber)
- .priorityLow: #0891B2 (teal)
- .priorityNone: #78716C (gray)

Energy:
- .energyHigh: #DC2626 (red - demanding)
- .energyMedium: #D97706 (amber)
- .energyLow: #059669 (green - easy)
```

### Color Tokens (Dark Mode - Warm Darks)
```
Background:
- .backgroundPrimary: #1C1917 (warm charcoal, not pure black)
- .backgroundSecondary: #292524 (slightly lighter)
- .backgroundTertiary: #44403C (dividers)

Surface:
- .surfaceElevated: #292524 (elevated cards)
- .surfacePressed: #44403C (pressed state)

Text:
- .textPrimary: #FAFAF9 (warm white)
- .textSecondary: #A8A29E (warm gray)
- .textTertiary: #78716C (muted)
- .textInverse: #1C1917 (for light backgrounds)

Accent:
- .accentPrimary: #F59E0B (brighter amber for dark mode)
- .accentSecondary: #D97706 (pressed)
- .accentSoft: #451A03 (dark amber for backgrounds)

(Status, Priority, Energy same values, adjusted if needed for contrast)
```

### Spacing Scale (4pt Grid)
```swift
enum Spacing {
    static let xxxs: CGFloat = 2   // Micro adjustments
    static let xxs: CGFloat = 4    // Tight spacing
    static let xs: CGFloat = 8     // Small gaps
    static let sm: CGFloat = 12    // Standard small
    static let md: CGFloat = 16    // Standard medium
    static let lg: CGFloat = 24    // Large gaps
    static let xl: CGFloat = 32    // Section spacing
    static let xxl: CGFloat = 48   // Major sections
    static let xxxl: CGFloat = 64  // Screen margins
}
```

### Corner Radius Scale
```swift
enum CornerRadius {
    static let none: CGFloat = 0
    static let sm: CGFloat = 4     // Subtle rounding
    static let md: CGFloat = 8     // Cards, buttons
    static let lg: CGFloat = 12    // Larger cards
    static let xl: CGFloat = 16    // Modal sheets
    static let full: CGFloat = 999 // Pills, circles
}
```

### Shadow Tokens
```swift
struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum Shadow {
    static let sm = ShadowToken(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let md = ShadowToken(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let lg = ShadowToken(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
}
```

## Files to Create

### `Tangentle/UI/Themes/DesignTokens.swift`
Contains all raw token values organized into enums/structs.

## Files to Modify
- None (new file only)

## Patterns to Follow
Reference: `Tangentle/Core/Models/Enums.swift` for enum style

## Acceptance Criteria
- [ ] `DesignTokens.swift` compiles without errors
- [ ] All color tokens defined for both light and dark
- [ ] Spacing scale uses 4pt grid
- [ ] Corner radius scale defined
- [ ] Shadow tokens defined with opacity, radius, offset
- [ ] Colors use warm palette (no pure black/white in backgrounds)
- [ ] File is well-organized with MARK comments

## Verification Commands
```bash
# Build to verify compilation
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check file exists and has content
wc -l /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Themes/DesignTokens.swift
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Check for typos in color hex values
2. Ensure `import SwiftUI` is at top of file
3. Verify file is added to Xcode project

## Do NOT
- Use pure black (#000000) or pure white (#FFFFFF) for backgrounds
- Create Color assets in asset catalog (we're using code-defined colors)
- Add any preview code yet (that comes with components)
