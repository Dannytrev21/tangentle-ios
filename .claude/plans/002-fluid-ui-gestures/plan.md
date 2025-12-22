# Plan 002: Fluid UI & Gesture System

## Overview
Create a beautiful, modern, warm UI with fluid physics-based gestures inspired by Timepage, Things 3, Bear, Clear, and Apple Design Award winners. The interface should feel like a living, breathing companion that responds naturally to touch - not a rigid task manager. Every interaction should feel like touching something real, with momentum, weight, and delight.

## Status
- **Created**: 2025-12-21
- **Status**: Not Started
- **Current Step**: 0 of 12

## Tree of Thought Analysis

### What are we building?
A comprehensive UI system for Tangentle that includes:
1. **Design Token System** - Colors, typography, spacing, radii
2. **Theme Engine** - Warm light mode (Bear-like) + dark mode (Linear-like) with future palette switching
3. **Physics Animation Library** - Spring, momentum, bounce animations
4. **Haptic Feedback System** - Selective by default, user-configurable
5. **Custom Gesture System** - Swipe-to-complete, contextual swipe actions
6. **Redesigned Today View** - The primary screen with time-based task display
7. **Custom Tab Bar** - Styled tab bar with configurable visibility
8. **Reusable Components** - TaskCard, SwipeableRow, AnimatedCheckbox, etc.

### Why are we building it?
- **ADHD users deserve beautiful tools** - Aesthetics affect motivation
- **Gesture-driven interaction reduces cognitive load** - Less thinking about where to tap
- **Physics animations provide feedback** - Makes the app feel responsive and alive
- **Warmth reduces anxiety** - Cool sterile UIs can feel hostile to ADHD brains
- **Consistency creates trust** - A cohesive design language feels professional

### Key Decisions

#### Decision 1: Task Completion Gesture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Swipe-to-complete** | Swipe right reveals checkmark, release confirms | Familiar (iOS Mail), reversible, shows progress | May conflict with other swipe actions |
| **B: Long-press charge** | Hold to charge up, release to complete | Very satisfying, prevents accidents, unique | Slower, may feel heavy for many tasks |
| **C: Tap checkbox** | Simple tap on checkbox | Fastest, familiar | Boring, easy to mis-tap, no feedback |

**Recommendation: Hybrid Approach**
- Primary: **Swipe-to-complete** for individual tasks (familiar, reversible)
- Secondary: **Long-press charge** available as user setting for those who want it
- Checkbox tap also works for accessibility

This gives users choice while defaulting to the most intuitive option.

---

#### Decision 2: Animation Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Pure SwiftUI** | All animations via `.animation()` modifiers | Simple, no UIKit bridge | Limited gesture control, 60fps cap on some animations |
| **B: UIKit Integration** | UIKitRepresentable for gestures, SwiftUI for layout | Full control, 120fps capable | More complex, bridging overhead |
| **C: CADisplayLink custom** | Custom animation engine | Maximum control | Over-engineering, maintenance burden |

**Selected: Option B - UIKit Integration**
- Use SwiftUI for layout and simple animations
- UIKit `UIPanGestureRecognizer` for swipe gestures (as per CLAUDE.md guidance)
- Custom spring animations via `UISpringTimingParameters`
- CADisplayLink only where needed for 120fps on ProMotion

---

#### Decision 3: Color System Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Static palette** | Fixed light/dark colors | Simple, predictable | No future customization |
| **B: Theme protocol** | `ThemeProtocol` with swappable palettes | Extensible, user themes later | More code, indirection |
| **C: Dynamic system** | Time-of-day gradients like Timepage | Beautiful, ambient | Complex, may distract |

**Selected: Option B - Theme Protocol**
- Start with two palettes: `WarmLightTheme` and `WarmDarkTheme`
- `ThemeProtocol` allows future palette additions (Timepage-style themes)
- Colors accessed via `@Environment(\.theme)` for consistency
- Semantic color names (`.background`, `.surface`, `.accent`, `.textPrimary`)

---

#### Decision 4: Swipe Actions Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: Fixed actions** | Same swipe actions for all tasks | Simple, predictable | Inflexible |
| **B: Contextual** | Different actions based on task state | Smart, reduces friction | More complex logic |
| **C: User-configurable** | User chooses swipe actions | Maximum flexibility | Settings complexity |

**Selected: All three, layered**
- **Base**: Standard actions (Complete, Delete, Defer, Edit)
- **Contextual overlay**: Blocked tasks show "Unblock", Deferred show "Reschedule"
- **Future**: User-configurable via Settings (v1.1)

---

#### Decision 5: Typography Approach

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **A: SF Pro only** | System fonts with custom scale | Optimized, free, accessible | Less unique |
| **B: Custom fonts** | Licensed typefaces | Distinctive | Cost, licensing, file size |
| **C: Mixed** | Custom for headings, SF for body | Balance of unique + readable | Complexity |

**Selected: Option A - SF Pro with Custom Scale**
- SF Pro is beautifully designed and optimized for iOS
- Define custom type scale with semantic names (`.largeTitle`, `.headline`, `.body`, `.caption`)
- Use SF Rounded for softer, warmer feel in some elements
- Leaves door open for custom fonts later without architecture change

---

## Implementation Steps

| Step | Name | Description | Status |
|------|------|-------------|--------|
| 1 | Design Tokens | Create color, spacing, radius, and shadow tokens | Pending |
| 2 | Theme System | Build ThemeProtocol and light/dark implementations | Pending |
| 3 | Typography Scale | Define semantic type styles with SF Pro | Pending |
| 4 | Animation Library | Physics-based spring and momentum animations | Pending |
| 5 | Haptic Engine | Haptic feedback service with user preferences | Pending |
| 6 | Gesture Foundation | Base gesture handlers for swipe and long-press | Pending |
| 7 | SwipeableRow | Reusable swipe action component | Pending |
| 8 | TaskCard | Redesigned task display component | Pending |
| 9 | AnimatedCheckbox | Physics-based completion animation | Pending |
| 10 | Custom Tab Bar | Styled tab bar with configurable visibility | Pending |
| 11 | Today View Redesign | Complete Today screen with new components | Pending |
| 12 | Integration & Polish | Wire up all components, add microinteractions | Pending |

## Files to Create

### Theme System (`UI/Themes/`)
- `DesignTokens.swift` - Raw color values, spacing, radii
- `ThemeProtocol.swift` - Theme abstraction
- `WarmLightTheme.swift` - Cream/ivory/terracotta palette
- `WarmDarkTheme.swift` - Dark warm palette
- `ThemeEnvironment.swift` - Environment key for theme access
- `Typography.swift` - Type scale definitions

### Animation System (`UI/Animations/`)
- `SpringAnimation.swift` - Configurable spring physics
- `PhysicsEngine.swift` - Momentum and velocity calculations
- `AnimationTokens.swift` - Standard animation curves and durations

### Gesture System (`UI/Gestures/`)
- `SwipeGestureHandler.swift` - UIKit-bridged swipe recognition
- `LongPressChargeGesture.swift` - Charge-to-complete gesture

### Haptics (`UI/Haptics/`)
- `HapticEngine.swift` - Centralized haptic feedback service

### Components (`UI/Components/`)
- `SwipeableRow.swift` - Generic swipe action container
- `TaskCard.swift` - Redesigned task row
- `AnimatedCheckbox.swift` - Satisfying completion animation
- `PriorityIndicator.swift` - Visual priority display
- `EnergyBadge.swift` - Energy level indicator
- `TimeBlock.swift` - Time-based task display
- `CustomTabBar.swift` - Styled tab bar component

### Feature Updates
- `Features/Tasks/TodayView.swift` - Complete redesign
- `Features/Tasks/TodayViewModel.swift` - Add gesture action methods
- `App/ContentView.swift` - Integrate custom tab bar

### Settings Updates
- `Core/Models/TGSettings+Extensions.swift` - Add UI settings
- `Features/Settings/AppearanceSettingsView.swift` - New settings screen

## Files to Modify

| File | Changes |
|------|---------|
| `TGSettings+Extensions.swift` | Add `UISettings` struct for haptics, swipe preferences |
| `Container.swift` | Add HapticEngine to DI container |
| `ContentView.swift` | Replace TabView with custom tab bar |
| `TodayView.swift` | Complete UI overhaul |
| `TodayViewModel.swift` | Add gesture action handlers |
| `TaskRow.swift` | Replace with TaskCard |

## Dependencies

```
Step 1 (Tokens) ─┬─► Step 2 (Theme) ─┬─► Step 4 (Animations) ─┬─► Step 5 (Haptics)
                 │                   │                        │
                 └─► Step 3 (Typography)                      ├─► Step 6 (Gestures) ─► Step 7 (SwipeableRow)
                                     │                        │
                                     └─► Step 8 (TaskCard)    └─► Step 9 (Checkbox)
                                     │
                                     └─► Step 10 (Tab Bar)

Step 7 + Step 8 + Step 9 + Step 10 ──► Step 11 (Today View)

All Steps ──► Step 12 (Integration)
```

**Parallel Opportunities:**
- Steps 8 (TaskCard) and 10 (Tab Bar) can run in parallel with Steps 4-9
- Step 5 (Haptics) and Step 6 (Gestures) can run in parallel after Step 4

## Revision History
- **2025-12-21**: Initial plan created
- **2025-12-21**: Review applied - Fixed TaskCard dependencies, added accessibility criteria

## Success Criteria
- [ ] 60fps animations on iPhone 12+, 120fps on ProMotion devices
- [ ] All gestures respond in <16ms
- [ ] Dark mode fully supported and beautiful
- [ ] VoiceOver labels on all interactive elements
- [ ] Dynamic Type accessibility sizes supported
- [ ] Reduce Motion preference respected
- [ ] Existing test suite still passes
- [ ] Swipe actions work contextually based on task state
- [ ] Haptic feedback works and respects user settings
- [ ] Tab bar can be hidden/shown via settings
- [ ] Theme can be toggled between light/dark/system
- [ ] Design feels cohesive across all touched screens

## Rollback Plan

Each step is designed to be additive and non-destructive:

1. **Theme System**: Falls back to system colors if theme isn't applied
2. **Gestures**: Keep tap-to-complete as fallback
3. **Animations**: All animations have `.animation(.none)` fallback
4. **Tab Bar**: Standard TabView remains available

If major issues:
- Revert to commit before Step 11 (Today View Redesign)
- Individual components can be disabled via feature flags in settings

## Testing Strategy

### Unit Tests
- Animation calculation accuracy
- Theme color resolution
- Gesture state machine logic

### UI Tests
- Swipe gesture completion
- Haptic feedback triggers (mocked)
- Tab bar visibility toggle

### Manual Testing
- Animation smoothness on various devices
- Accessibility with VoiceOver
- Dark mode appearance
- Gesture feel and responsiveness
