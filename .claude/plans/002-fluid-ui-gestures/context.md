# Plan 002 Context: Fluid UI & Gesture System

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: Fluid UI & Gesture System
- **Current Step**: 7 - SwipeableRow (next)
- **Last Updated**: 2025-12-22

## Overview
Creating a beautiful, modern, warm UI with fluid physics-based gestures for Tangentle. Inspired by Timepage, Things 3, Bear, Clear, and Apple Design Award winners. The goal is to make the app feel like a "living, breathing companion" that responds naturally to touch.

## What's Been Done
- Plan created with 12 implementation steps
- Architecture Decision Record (ADR) completed
- All step specification files created
- All prompts generated for each step
- **Step 1 Complete**: Design Tokens
- **Step 2 Complete**: Theme System
- **Step 3 Complete**: Typography Scale
- **Step 4 Complete**: Animation Library
- **Step 5 Complete**: Haptic Engine
- **Step 6 Complete**: Gesture Foundation

## Key Decisions Made

### 1. Task Completion Gesture
**Decision**: Hybrid - Swipe-to-complete (default) + Long-press (optional) + Tap (always works)
- Swipe is familiar and quick
- Long-press available for users who want more intentional completion
- Tap always works for accessibility

### 2. Animation Implementation
**Decision**: UIKit Integration
- SwiftUI for layout and simple animations
- UIKit gesture recognizers for complex gestures
- Enables 120fps on ProMotion devices
- Per CLAUDE.md guidance

### 3. Theme System
**Decision**: Protocol-based with WarmLightTheme and WarmDarkTheme
- Extensible for future custom themes (like Timepage)
- Environment-based injection (`@Environment(\.theme)`)
- Semantic color names

### 4. Color Direction
- **Light Mode**: Warm neutrals (cream #FFFDF7, terracotta accents)
- **Dark Mode**: Warm charcoal (#1C1917, amber accents)
- Never pure black or white for backgrounds

### 5. Haptic Feedback
**Decision**: Selective by default, user-configurable
- Default: Only key moments (completion, major actions)
- Settings: Off, Selective, Rich
- Respects ADHD sensory differences

### 6. Swipe Actions
**Decision**: Layered approach
- Base: Complete, Delete, Defer, Edit
- Contextual: Blocked shows "Unblock", etc.
- Future: User-configurable (v1.1)

## Files Structure

### To Create
```
Tangentle/
├── UI/
│   ├── Themes/
│   │   ├── DesignTokens.swift
│   │   ├── ThemeProtocol.swift
│   │   ├── WarmLightTheme.swift
│   │   ├── WarmDarkTheme.swift
│   │   ├── ThemeEnvironment.swift
│   │   ├── ThemeManager.swift
│   │   └── Typography.swift
│   ├── Animations/
│   │   ├── AnimationTokens.swift
│   │   ├── SpringAnimation.swift
│   │   ├── PhysicsEngine.swift
│   │   └── AnimationModifiers.swift
│   ├── Gestures/
│   │   ├── SwipeGestureHandler.swift
│   │   ├── LongPressChargeHandler.swift
│   │   ├── GestureViewRepresentable.swift
│   │   └── GestureState.swift
│   ├── Haptics/
│   │   ├── HapticEngine.swift
│   │   └── HapticType.swift
│   └── Components/
│       ├── SwipeableRow.swift
│       ├── SwipeAction.swift
│       ├── TaskCard.swift
│       ├── AnimatedCheckbox.swift
│       ├── CustomTabBar.swift
│       ├── FloatingActionButton.swift
│       └── [various badge components]
```

### To Modify
- `TangentleApp.swift` - Theme/environment integration
- `ContentView.swift` - Replace TabView with custom tab bar
- `Container.swift` - Add HapticEngine
- `TodayView.swift` - Complete redesign
- `TodayViewModel.swift` - Add gesture action methods
- `TGSettings+Extensions.swift` - Add UI settings
- `SettingsView.swift` - Add appearance section

## Implementation Order

```
Step 1 (Tokens) ─┬─► Step 2 (Theme) ─┬─► Step 4 (Animations)
                 │                   │
                 └─► Step 3 (Typography)
                                     │
                 ┌───────────────────┘
                 │
                 ▼
Step 4 ─┬─► Step 5 (Haptics)
        │
        ├─► Step 6 (Gestures) ──► Step 7 (SwipeableRow)
        │
        └─► Step 8 (TaskCard) + Step 9 (Checkbox)
                                     │
                 ┌───────────────────┘
                 ▼
Step 2 + 3 ──► Step 10 (Tab Bar)
                                     │
                 ┌───────────────────┘
                 ▼
Step 7 + 8 + 9 + 10 ──► Step 11 (Today View)
                                     │
                 ┌───────────────────┘
                 ▼
All Steps ──► Step 12 (Integration)
```

## Next Actions
1. Run `/plan-next 002` to begin Step 7 (SwipeableRow)

## Things to Remember
- iOS 17.0 minimum - can use `@Observable` and modern SwiftUI features
- Must maintain VoiceOver accessibility throughout
- All animations should be <500ms for responsiveness
- Never use pure black (#000000) or pure white (#FFFFFF) for backgrounds
- Test on both light and dark mode continuously
- Existing test suite must continue to pass

## Reference Apps
- **Timepage**: Fluid gestures, gradients, ambient feel
- **Things 3**: Task interaction polish, swipe actions, completion animation
- **Bear**: Warm typography, subtle animations, calming colors
- **Linear**: Modern minimalism, fluid transitions
- **Clear**: Gesture-heavy, physics-based

## Success Metrics
- 60fps animations on iPhone 12+ (120fps on ProMotion)
- <16ms gesture response latency
- VoiceOver labels on all interactive elements
- Full dark mode support
- Existing tests pass
- Design feels cohesive and premium

## Blockers
None currently.

## Learnings
- Warm off-white (#FFFDF7) provides excellent readability while feeling inviting
- 92 design tokens defined covering colors, spacing, radius, shadows, durations, and opacities
- Color extension for hex initialization works well across both color enums

---

## Step 1 Complete - 2025-12-21

### Summary
Created comprehensive DesignTokens.swift with all foundational design values for the UI system.

### Files Created
- `Tangentle/UI/Themes/DesignTokens.swift`: 323 lines with all design tokens

### Verification Results
- [x] AC1: Build succeeds
- [x] AC2: 92 static let declarations (>30 required)
- [x] AC3: DarkColors enum present
- [x] AC4: Spacing scale uses 4pt grid
- [x] AC5: No pure black/white in backgrounds
- [x] AC6: 22 MARK comments for organization

### Key Decisions
- Used warm off-white (#FFFDF7) as light background
- Used warm charcoal (#1C1917) as dark background
- Added Duration and Opacity enums as bonus utilities

### Ready for Next Step
Step 2: Theme System
Prerequisites met: Yes (DesignTokens.swift complete)

---

## Step 2 Complete - 2025-12-21

### Summary
Created complete theme system with ThemeProtocol, WarmLightTheme, WarmDarkTheme, environment integration, and ThemeManager.

### Files Created
- `Tangentle/UI/Themes/ThemeProtocol.swift`: Theme contract with 31 color properties
- `Tangentle/UI/Themes/WarmLightTheme.swift`: Light mode implementation
- `Tangentle/UI/Themes/WarmDarkTheme.swift`: Dark mode implementation
- `Tangentle/UI/Themes/ThemeEnvironment.swift`: SwiftUI environment key and View extension
- `Tangentle/UI/Themes/ThemeManager.swift`: @Observable manager for mode switching

### Verification Results
- [x] AC1: 31 color properties in ThemeProtocol (>21 required)
- [x] AC2: WarmLightTheme implements ThemeProtocol
- [x] AC3: WarmDarkTheme implements ThemeProtocol
- [x] AC4: Theme accessible via @Environment(\.theme)
- [x] AC5: ThemeManager uses @Observable
- [x] AC6: BUILD SUCCEEDED

### Key Decisions
- Added surfacePressed for pressed states
- Added tint colors for all status states (success, warning, error, info)
- ThemeManager persists preference to UserDefaults
- Added .themed() View extension for convenience

### Usage Pattern
```swift
@Environment(\.theme) var theme
Text("Hello").foregroundStyle(theme.textPrimary)
```

### Ready for Next Step
Step 3: Typography Scale
Prerequisites met: Yes (Theme system complete)

---

## Step 3 Complete - 2025-12-21

### Summary
Created Typography.swift with semantic type scale using SF Pro, supporting Dynamic Type accessibility.

### Files Created
- `Tangentle/UI/Themes/Typography.swift`: Type scale with 22 font styles

### Verification Results
- [x] AC1: BUILD SUCCEEDED
- [x] AC2: 22 static let declarations (>14 required)
- [x] AC3: 17pt body size follows iOS HIG
- [x] AC4: SF Rounded variants (3 styles)
- [x] AC5: LineHeight enum defined
- [x] AC6: ViewModifier implementation
- [x] AC7: Uses Font.system for Dynamic Type

### Key Decisions
- Used SF Pro system font for optimal rendering
- Added monospaced variants for timestamps/code
- Created TextStyles helper enum for common patterns
- 17pt body size follows iOS conventions

### Ready for Next Step
Step 4: Animation Library
Prerequisites met: Yes (Typography complete)

---

## Step 4 Complete - 2025-12-21

### Summary
Created comprehensive animation library with physics-based spring configurations, momentum calculations, and accessibility support for Reduce Motion and Low Power Mode.

### Files Created
- `Tangentle/UI/Animations/AnimationTokens.swift`: Timing durations and spring configs (21 tokens)
- `Tangentle/UI/Animations/SpringAnimation.swift`: UIKit spring parameters for gesture-driven animations
- `Tangentle/UI/Animations/PhysicsEngine.swift`: Momentum calculator with decay, rubber band, and snap
- `Tangentle/UI/Animations/AnimationModifiers.swift`: View modifiers with accessibility support

### Verification Results
- [x] AC1: AnimationTiming defines instant, quick, normal, slow durations
- [x] AC2: 21 static let declarations (>9 required)
- [x] AC3: UISpringTimingParameters present in SpringAnimation.swift
- [x] AC4: decayEndpoint and rubberBand functions present
- [x] AC5: isReduceMotionEnabled checked throughout AnimationModifiers.swift
- [x] AC6: BUILD SUCCEEDED

### Key Decisions
- Reduce Motion always returns .none animation (no motion, just instant state changes)
- Low Power Mode also disables animations via adaptiveAnimation modifier
- Rubber band uses 0.55 coefficient (iOS standard)
- UISpringConfig provides velocity-aware spring timing for gestures
- Added specialized springs: celebration, settle, toggle

### Usage Patterns
```swift
// Spring animation with Reduce Motion support
Circle()
    .springAnimation(value: isExpanded)

// Staggered list appearance
ForEach(items.indices, id: \.self) { index in
    TaskRow(task: items[index])
        .staggeredAppear(index: index)
}

// Press scale effect
Button("Tap") { }
    .pressScale(isPressed)

// UIKit gesture spring
let animator = UISpringConfig.snappy.animator(velocity: gestureVelocity)
```

### Ready for Next Step
Step 5: Haptic Engine
Prerequisites met: Yes (Animation Library complete)

---

## Step 5 Complete - 2025-12-22

### Summary
Created haptic feedback engine with configurable intensity levels and 13 haptic patterns.

### Files Created
- `Tangentle/UI/Haptics/HapticType.swift`: 13 haptic patterns and 3 intensity levels
- `Tangentle/UI/Haptics/HapticEngine.swift`: Service with protocol and NoOpHapticEngine

### Verification Results
- [x] AC1: HapticType enum with 13 patterns
- [x] AC2: HapticIntensity enum (off, selective, rich)
- [x] AC3: HapticEngine implements protocol
- [x] AC4: NoOpHapticEngine for testing
- [x] AC5: Environment key integration
- [x] AC6: BUILD SUCCEEDED

### Key Decisions
- Default intensity is "selective" for ADHD sensory considerations
- Key moments: success, error, completion, swipe threshold
- Protocol marked AnyObject for weak references

### Ready for Next Step
Step 6: Gesture Foundation
Prerequisites met: Yes (Haptic Engine complete)

---

## Step 6 Complete - 2025-12-22

### Summary
Created UIKit-based gesture handlers with precise velocity tracking, 120fps updates on ProMotion, and SwiftUI bridging via UIViewRepresentable.

### Files Created
- `Tangentle/UI/Gestures/GestureState.swift`: SwipeState and LongPressState enums
- `Tangentle/UI/Gestures/SwipeGestureHandler.swift`: Pan gesture with velocity tracking and haptic feedback
- `Tangentle/UI/Gestures/LongPressChargeHandler.swift`: Long press with CADisplayLink 120fps updates
- `Tangentle/UI/Gestures/GestureViewRepresentable.swift`: SwiftUI wrappers (SwipeGestureView, LongPressChargeView)

### Verification Results
- [x] AC1: SwipeGestureHandler tracks translation and velocity
- [x] AC2: Swipe triggers haptic at threshold crossing
- [x] AC3: LongPressChargeHandler provides 0-1 progress
- [x] AC4: 120fps via CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
- [x] AC5: CADisplayLink cleanup in deinit
- [x] AC6: UIViewRepresentable bridge exists
- [x] AC7: BUILD SUCCEEDED

### Key Decisions
- HapticEngineProtocol requires AnyObject constraint for weak delegate references
- CADisplayLink added to .main runloop with .common mode
- SwiftUI View extensions (.onSwipeGesture, .onChargeGesture) for convenience

### Usage Patterns
```swift
// SwiftUI swipe gesture with velocity
SwipeGestureView(threshold: 80) { translation, velocity in
    offset = translation
} onSwipeEnd: { translation, velocity in
    // Handle completion
} content: {
    TaskRow(task: task)
}

// Long press charge gesture
LongPressChargeView(chargeDuration: 0.5) { progress in
    chargeProgress = progress
} onChargeComplete: {
    completeTask()
} content: {
    Checkbox(isComplete: task.isComplete)
}
```

### Ready for Next Step
Step 7: SwipeableRow
Prerequisites met: Yes (Gesture Foundation complete)
