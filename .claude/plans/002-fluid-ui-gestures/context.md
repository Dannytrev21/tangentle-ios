# Plan 002 Context: Fluid UI & Gesture System

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: Fluid UI & Gesture System
- **Current Step**: 8 - TaskCard (next)
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
- **Step 7 Complete**: SwipeableRow

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
1. Run `/plan-next 002` to begin Step 8 (TaskCard)

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

---

## Step 7 Complete - 2025-12-22

### Summary
Created SwipeableRow component with physics-based swipe gestures, rubber-band resistance, haptic feedback, and configurable leading/trailing actions.

### Files Created
- `Tangentle/UI/Components/SwipeAction.swift`: SwipeAction model and StandardSwipeActions factory
- `Tangentle/UI/Components/SwipeActionButton.swift`: Action button with icon and label
- `Tangentle/UI/Components/SwipeableRow.swift`: Generic swipe container component

### Verification Results
- [x] AC1: SwipeableRow reveals actions on swipe
- [x] AC2: Rubber band effect via MomentumCalculator.rubberBand
- [x] AC3: Haptic feedback on threshold crossing
- [x] AC4: Spring animation on release (SpringConfig.bouncy/snappy)
- [x] AC5: Supports leading and trailing actions
- [x] AC6: StandardSwipeActions factory exists (complete, delete, defer, edit, unblock, duplicate)
- [x] AC7: Build succeeded

### Key Decisions
- Used SwiftUI DragGesture instead of UIKit for simpler integration
- Action executed after 0.2s delay for animation to settle
- Rubber band coefficient 0.55 matches iOS standard
- Velocity threshold 500 for fast swipes to trigger action
- First action in array is the "primary" action that triggers on swipe completion

### Learnings
- SwiftUI DragGesture works well for swipe actions
- predictedEndTranslation - translation gives approximate velocity
- StandardSwipeActions factory ensures consistent action styling
- .themed() requires explicit theme parameter in previews

### Ready for Next Step
Step 8: TaskCard
Prerequisites met: Yes (SwipeableRow complete)

---

## Step 8 Complete - 2025-12-22

### Summary
Created TaskCard component with warm aesthetics, visual hierarchy, badge components for metadata, and full VoiceOver accessibility. Also created 7 supporting component files.

### Files Created
- `Tangentle/UI/Components/CompletionIndicator.swift`: Circular checkbox with priority-colored border
- `Tangentle/UI/Components/PriorityBadge.swift`: Priority level badge with theme colors
- `Tangentle/UI/Components/EnergyBadge.swift`: Energy level badge with lightning bolt icon
- `Tangentle/UI/Components/DurationBadge.swift`: Time estimate badge with clock icon
- `Tangentle/UI/Components/ProjectBadge.swift`: Project name with emoji prefix
- `Tangentle/UI/Components/StatusBadges.swift`: BlockedBadge, OverdueBadge, InProgressBadge, WaitingBadge
- `Tangentle/UI/Components/TaskCard.swift`: Main task display component

### Files Modified
- `Tangentle/UI/Components/TaskRow.swift`: Removed old Int-based PriorityBadge (now uses enum-based)
- `Tangentle.xcodeproj/project.pbxproj`: Added 7 new files to Xcode project

### Verification Results
- [x] AC1: TaskCard displays title, project, duration, priority, energy
- [x] AC2: Visual hierarchy clear (Typography.bodyLarge for title)
- [x] AC3: Overdue tasks have red title (statusError)
- [x] AC4: Completed tasks muted with strikethrough (textTertiary)
- [x] AC5: All colors use theme (@Environment(\.theme))
- [x] AC6: VoiceOver accessibility labels present
- [x] AC7: All badge files created (5 badge files + StatusBadges)
- [x] AC8: Build succeeded

### Key Decisions
- Only show energy badge when energy != .medium (default)
- CompletionIndicator border color reflects priority level
- StatusBadges file combines multiple small status indicators
- TaskCard background changes to backgroundTertiary when completed

### Learnings
- Old TaskRow had Int-based PriorityBadge that conflicted - replaced with Priority enum version
- Badge components share consistent pattern: @Environment(\.theme), spacing tokens, accessibility labels
- Combining related small components (status badges) in single file reduces file count without hurting readability

### Ready for Next Step
Step 9: AnimatedCheckbox
Prerequisites met: Yes (TaskCard complete)

---

## Step 9 Complete - 2025-12-22

### Summary
Created AnimatedCheckbox with physics-based animation, particle burst effect, and haptic feedback for satisfying task completion experience. Designed to provide positive reinforcement for ADHD users.

### Files Created
- `Tangentle/UI/Components/CheckmarkShape.swift`: Animatable checkmark path for trim animation
- `Tangentle/UI/Components/ParticleBurst.swift`: 8-particle celebration burst effect
- `Tangentle/UI/Components/AnimatedCheckbox.swift`: Main component with multi-phase animation

### Files Modified
- `Tangentle.xcodeproj/project.pbxproj`: Added 3 new files

### Verification Results
- [x] AC1: Checkbox animates from empty to filled (fillProgress)
- [x] AC2: Checkmark draws in with trim animation (checkmarkProgress)
- [x] AC3: Scale bounces on completion (SpringConfig.bouncy)
- [x] AC4: Particle burst appears (ParticleBurst + showParticles)
- [x] AC5: Haptic feedback triggers (haptics.trigger(.completion))
- [x] AC6: Animation under 500ms (~450ms total)
- [x] AC7: VoiceOver accessibility (accessibilityLabel + accessibilityHint)
- [x] AC8: Build succeeded

### Key Decisions
- Animation sequence: Press (0.9 scale) → Fill → Checkmark draws → Bounce → Particles
- Total animation ~450ms for snappy, responsive feel
- DragGesture with minimumDistance: 0 for press-down feedback
- onChange(of: isCompleted) handles external state changes (swipe-to-complete)
- ParticleBurst uses random offsets for organic, not mechanical feel

### Learnings
- CheckmarkShape uses animatable trim(from: 0, to: progress) for draw-in effect
- Particles with slight random angle offsets feel more natural
- Multi-phase animation with DispatchQueue.asyncAfter sequences each phase
- .simultaneousGesture allows tap and drag to coexist
- triggerCompletion() method enables programmatic animation from external triggers

### Ready for Next Step
Step 10: Custom Tab Bar
Prerequisites met: Yes (AnimatedCheckbox complete)

---

## Step 10 Complete - 2025-12-22

### Summary
Created custom tab bar with themed styling, matchedGeometryEffect for sliding selection indicator, haptic feedback on tab change, and hide/show functionality via settings.

### Files Created
- `Tangentle/Core/Models/AppTab.swift`: Tab enum with title, icon, selectedIcon
- `Tangentle/UI/Components/TabBarItem.swift`: Individual tab item with selection indicator
- `Tangentle/UI/Components/CustomTabBar.swift`: Main tab bar with haptics and hide/show
- `Tangentle/App/TabBarContainer.swift`: Container managing tab content and tab bar

### Files Modified
- `Tangentle.xcodeproj/project.pbxproj`: Added 4 new files

### Verification Results
- [x] AC1: Custom tab bar renders with 5 tabs (AppTab.allCases)
- [x] AC2: Selected tab has filled icon and accent color (selectedIcon + accentPrimary)
- [x] AC3: Selection indicator slides with matchedGeometryEffect
- [x] AC4: Tab bar can be hidden/shown (isVisible + @AppStorage)
- [x] AC5: Haptic feedback on tab change (haptics.trigger(.selection))
- [x] AC6: VoiceOver accessibility (accessibilityLabel + accessibilityAddTraits)
- [x] AC7: Safe area handled (safeAreaBottom from UIWindowScene)
- [x] AC8: Build succeeded

### Key Decisions
- Used matchedGeometryEffect for smooth selection indicator animation
- @AppStorage("hideTabBar") for persistent hide/show preference
- .ultraThinMaterial + semi-transparent overlay for frosted glass effect
- Safe area bottom from UIWindowScene for home indicator spacing
- Separate AppTab enum in Core/Models for reuse across app

### Learnings
- matchedGeometryEffect with @Namespace creates smooth shared element transitions
- @AppStorage provides easy UserDefaults persistence for simple settings
- Tab bar background uses layered approach: material + color overlay + top border
- UIWindowScene is the modern way to access safe area insets

### Ready for Next Step
Step 11: Today View Redesign
Prerequisites met: Yes (Custom Tab Bar complete)

---

## Step 11 Complete - 2025-12-22

### Summary
Completely redesigned TodayView using all new UI components - TodayHeader, TaskSection, TodayEmptyState, FloatingActionButton, and integration of SwipeableRow with TaskCard. Created an ADHD-friendly interface with time-based greetings and friendly empty states.

### Files Created
- `Tangentle/Features/Tasks/TodayHeader.swift`: Time-based greeting with date and decorative icon
- `Tangentle/Features/Tasks/TaskSection.swift`: Reusable section component for Overdue/Today
- `Tangentle/Features/Tasks/TodayEmptyState.swift`: Friendly "All Clear!" empty state
- `Tangentle/UI/Components/FloatingActionButton.swift`: Material-style FAB with ScaleButtonStyle

### Files Modified
- `Tangentle/Features/Tasks/TodayView.swift`: Complete rewrite with new components
- `Tangentle/Features/Tasks/TodayViewModel.swift`: Added deleteTask, deferTask methods
- `Tangentle.xcodeproj/project.pbxproj`: Added 4 new files

### Verification Results
- [x] AC1: Today View uses theme colors (@Environment(\.theme))
- [x] AC2: Header shows time-based greeting (Good Morning/Afternoon/Evening)
- [x] AC3: Tasks in SwipeableRow with TaskCard
- [x] AC4: Swipe actions work (StandardSwipeActions.complete/defer_/delete/unblock)
- [x] AC5: Empty state shows (TodayEmptyState)
- [x] AC6: FAB present (FloatingActionButton)
- [x] AC7: Pull-to-refresh works (.refreshable)
- [x] AC8: Build succeeded

### Key Decisions
- TodayView uses ZStack with FloatingActionButton overlay for proper positioning
- TaskSection is a generic reusable component for task groupings
- TodayEmptyState celebrates "All Clear!" rather than showing stark "no data"
- Defer task uses updateTask with deferred status and tomorrow's date (no deferTask method in protocol)

### Learnings
- TodayHeader time-based greeting uses Calendar.current.component(.hour) for hour detection
- FloatingActionButton uses ScaleButtonStyle for tactile press-down effect
- TaskServiceProtocol doesn't have deferTask method - use updateTask with TaskChanges instead
- LazyVStack with ForEach provides smooth scrolling for task lists

### Ready for Next Step
Step 12: Integration & Polish
Prerequisites met: Yes (Today View Redesign complete)
