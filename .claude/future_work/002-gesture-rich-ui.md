# Plan 002: Gesture-Rich UI

## Overview

Create a beautiful, modern, warm UI with fluid gestures inspired by Timepage by Moleskine. The interface should feel like a living, breathing companion that responds naturally to touch - not a rigid task manager. It should be clean and not overwhelming, but feature rich. 

**Philosophy**: Every interaction should feel like touching something real. Swipes should have momentum, taps should have weight, and the whole experience should be delightful enough that users *want* to interact with their tasks. It should be smooth, use physics animations. 

---

## Design Inspiration

### Reference Apps
| App | What to Learn |
|-----|---------------|
| **Timepage** | Fluid calendar gestures, beautiful gradients, weather-like ambient feel |
| **Things 3** | Task interaction polish, swipe actions, satisfying completion animation |
| **Bear** | Warm typography, subtle animations, calming color palette |
| **Linear** | Modern minimalism, keyboard shortcuts, fluid transitions |
| **Notion Calendar** | Clean task cards, smart time blocks |
| **Tiimo** | time based viewing, ADHD friendly | 
| **Clear** | gesture heavy | 
 
Others: (Not Boring) Weather, Gentler streaker, streaks, Dawn - Minimal Calendar, any other apple design winners

### Core Principles
1. **Warmth over sterility** - Soft shadows, rounded corners, gradient accents
2. **Motion with purpose** - Every animation communicates state change
3. **Touch-first** - Designed for thumbs, not cursors
4. **Calm productivity** - Reduce visual noise, highlight what matters
5. **ADHD-friendly** - One focus at a time, clear visual hierarchy

---

## Color System

### Warm Neutral Palette

```swift
extension Color {
    // MARK: - Background Layers
    static let bgPrimary = Color("BgPrimary")       // #FAF8F5 (warm white)
    static let bgSecondary = Color("BgSecondary")   // #F5F2ED (warm cream)
    static let bgTertiary = Color("BgTertiary")     // #EDE9E3 (warm tan)
    static let bgElevated = Color("BgElevated")     // #FFFFFF (pure white for cards)

    // MARK: - Text
    static let textPrimary = Color("TextPrimary")   // #2C2825 (warm charcoal)
    static let textSecondary = Color("TextSecondary") // #6B6560 (warm gray)
    static let textTertiary = Color("TextTertiary") // #9A958F (muted)

    // MARK: - Accent Colors (Energy-Coded)
    static let accentHigh = Color("AccentHigh")     // #E85D4C (warm coral) - high energy
    static let accentMedium = Color("AccentMedium") // #E8A84C (warm amber) - medium energy
    static let accentLow = Color("AccentLow")       // #4CA8E8 (calm blue) - low energy
    static let accentFocus = Color("AccentFocus")   // #7C5CE8 (soft purple) - focus mode

    // MARK: - Priority Colors
    static let priorityUrgent = Color("PriorityUrgent") // #E85D4C (coral)
    static let priorityHigh = Color("PriorityHigh")     // #E8884C (orange)
    static let priorityMedium = Color("PriorityMedium") // #E8C84C (gold)
    static let priorityLow = Color("PriorityLow")       // #8CE84C (sage)

    // MARK: - Semantic
    static let success = Color("Success")           // #4CE88A (mint green)
    static let warning = Color("Warning")           // #E8C84C (gold)
    static let destructive = Color("Destructive")   // #E85D4C (coral)

    // MARK: - Surfaces
    static let cardShadow = Color.black.opacity(0.06)
    static let divider = Color("Divider")           // #E8E4DE
}
```

### Dark Mode Adaptation
- Invert luminosity, preserve warmth
- Backgrounds: #1C1A18, #242220, #2C2A28
- Accent colors remain vibrant but slightly muted
- Shadows become subtle glows

### Gradient Presets

```swift
struct Gradients {
    // Time of day gradients (for Today view header)
    static let morning = LinearGradient(
        colors: [Color(hex: "#FFE5D9"), Color(hex: "#FFCAB8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let afternoon = LinearGradient(
        colors: [Color(hex: "#E8F4FF"), Color(hex: "#CCE5FF")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let evening = LinearGradient(
        colors: [Color(hex: "#E8DFF5"), Color(hex: "#D4C4E8")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Energy gradients
    static let highEnergy = LinearGradient(
        colors: [.accentHigh.opacity(0.15), .accentHigh.opacity(0.05)],
        startPoint: .top, endPoint: .bottom
    )
}
```

---

## Typography System

### Font Stack

```swift
extension Font {
    // MARK: - Display (for large headers)
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let displaySmall = Font.system(size: 22, weight: .semibold, design: .rounded)

    // MARK: - Headlines
    static let headlineLarge = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 15, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Labels
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Mono (for time, durations)
    static let monoMedium = Font.system(size: 15, weight: .medium, design: .monospaced)
    static let monoSmall = Font.system(size: 13, weight: .regular, design: .monospaced)
}
```

### Typography Guidelines
- **Rounded** for display/headlines (friendly, approachable)
- **Default** for body text (legibility)
- **Monospaced** for time/duration (alignment, precision)
- Line height: 1.4 for body, 1.2 for headlines
- Letter spacing: Slightly loose for small text

---

## Gesture System

### 1. Task Row Gestures

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ← SWIPE LEFT                    SWIPE RIGHT →         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  [Complete ✓]    Task Title              [More] │   │
│  │                  Project • 30min • ⚡️           │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  LONG PRESS: Drag to reorder                           │
│  TAP: Expand/show details                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

| Gesture | Action | Visual Feedback |
|---------|--------|-----------------|
| Swipe right (short) | Complete task | Green checkmark reveals, haptic tick |
| Swipe right (full) | Complete + celebrate | Confetti burst, satisfying animation |
| Swipe left (short) | Show actions menu | Coral buttons slide in |
| Swipe left (medium) | Defer to tomorrow | Calendar icon, date slides in |
| Swipe left (full) | Delete (with confirm) | Red background, shake to confirm |
| Long press | Enter reorder mode | Task lifts with shadow, haptic |
| Tap | Expand inline | Smooth height animation |
| Double tap | Quick edit title | Cursor blinks at end of title |

### 2. Today View Gestures

```
┌─────────────────────────────────────────────────────────┐
│  ◉ Today                                    [+] [⚙️]   │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  PULL DOWN: Reveal time-of-day header + greeting       │
│  ↓                                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Good morning, Danny ☀️                         │   │
│  │  3 tasks • ~2h 15m of work                      │   │
│  │  Peak focus: 9am - 12pm                         │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  HORIZONTAL SWIPE: Navigate days                        │
│  ←  Yesterday  |  TODAY  |  Tomorrow  →                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

| Gesture | Action | Visual Feedback |
|---------|--------|-----------------|
| Pull down | Reveal ambient header | Gradient header stretches, greeting fades in |
| Swipe left | Go to tomorrow | Page curl transition, date changes |
| Swipe right | Go to yesterday | Page curl transition |
| Pinch | Toggle between day/week view | Smooth zoom transition |
| Two-finger swipe down | Collapse all expanded tasks | Accordion animation |

### 3. Calendar View Gestures

```
┌─────────────────────────────────────────────────────────┐
│  December 2025                              [Week/Mo]  │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  VERTICAL SCROLL: Month navigation                      │
│  HORIZONTAL SWIPE: Week navigation                      │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  S   M   T   W   T   F   S                       │  │
│  │              1   2   3   4                        │  │
│  │  5   6  [7]  8   9  10  11   ← Today highlighted │  │
│  │  •       ••     •           ← Task indicators    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  TAP date: Show day's tasks inline                     │
│  LONG PRESS date: Quick add task for that day          │
│  DRAG task: Reschedule by dragging to new date         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

| Gesture | Action | Visual Feedback |
|---------|--------|-----------------|
| Tap date | Expand day's tasks below | Smooth accordion |
| Long press date | Quick add to that day | Sheet slides up with date pre-filled |
| Drag task to date | Reschedule | Task shrinks to dot, moves to date |
| Pinch out | Zoom to week view | Smooth scale transition |
| Pinch in | Zoom to month view | Smooth scale transition |

### 4. Strategy Coaching Gestures

```
┌─────────────────────────────────────────────────────────┐
│  What's blocking you?                                   │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │ Too Big │ │ Unclear │ │  Scary  │ │ Boring  │       │
│  │   😰    │ │   🤔    │ │   😨    │ │   😑    │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
│                                                         │
│  TAP: Select and get strategies                        │
│  SWIPE UP on strategy: "This worked!"                  │
│  SWIPE DOWN on strategy: "Didn't help"                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 5. Quick Capture Gestures

```
┌─────────────────────────────────────────────────────────┐
│  SHAKE DEVICE: Quick capture anywhere                   │
│  3D TOUCH / LONG PRESS app icon: Quick add menu        │
│                                                         │
│  In-app floating button:                                │
│  ┌────────────────────────────────────────────────┐    │
│  │                                           [+]  │    │
│  │  DRAG to edge: Dismiss                         │    │
│  │  TAP: Open quick capture                       │    │
│  │  LONG PRESS: Voice capture                     │    │
│  └────────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Animation Specifications

### Timing Curves

```swift
extension Animation {
    // Quick, responsive feedback
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.8)

    // Smooth, natural movement
    static let smooth = Animation.spring(response: 0.35, dampingFraction: 0.85)

    // Bouncy, playful (for completion)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    // Slow, ambient (for background changes)
    static let ambient = Animation.easeInOut(duration: 0.8)

    // Micro-interactions
    static let micro = Animation.easeOut(duration: 0.15)
}
```

### Key Animations

#### Task Completion
```
1. Checkbox fills with green (150ms, ease-out)
2. Checkmark draws in (200ms, spring)
3. Task title strikes through (left to right, 300ms)
4. Row shrinks height to 0 (350ms, spring)
5. Haptic: success pattern
6. Optional: Confetti burst for milestone completions
```

#### Task Expansion
```
1. Card lifts slightly (shadow increases)
2. Height animates to show content (spring, 350ms)
3. Content fades in (150ms delay, 200ms duration)
4. Other cards dim slightly
```

#### Day Transition
```
1. Current day slides out (direction based on gesture)
2. New day slides in from opposite side
3. Tasks stagger-animate in (50ms delay between each)
4. Header gradient shifts to match time of day
```

#### Pull-to-Refresh Header
```
1. User pulls down, resistance increases
2. At threshold: haptic bump
3. Greeting text scales from 0.8 to 1.0
4. Weather/time info fades in
5. Release: content bounces back with spring
```

### Haptic Patterns

```swift
enum TangentleHaptics {
    case taskComplete      // .success
    case taskDelete        // .warning
    case pullThreshold     // .medium impact
    case buttonTap         // .light impact
    case errorShake        // .error (3x light)
    case dragStart         // .rigid
    case dropComplete      // .soft
    case swipeAction       // .selection changed
}
```

---

## Component Designs

### 1. Task Card

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────┐   │
│  │ ○  Buy groceries for dinner party               │   │
│  │    ┌──────┐ ┌────────┐ ┌───┐                    │   │
│  │    │🏠 Home│ │30 min  │ │⚡️│                    │   │
│  │    └──────┘ └────────┘ └───┘                    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  States:                                                │
│  • Default: Warm white card, subtle shadow              │
│  • Hovered: Slight lift, shadow deepens                 │
│  • Pressed: Scale 0.98, shadow flattens                 │
│  • Completed: Green tint, strikethrough                 │
│  • Overdue: Coral left border accent                    │
│  • In Progress: Pulsing amber dot                       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 2. Time Block Card

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────┐   │
│  │ 9:00 AM                                         │   │
│  │ ┌─────────────────────────────────────────────┐ │   │
│  │ │ ████████░░░░░░░░░░░░░░░░░░░░  Deep work     │ │   │
│  │ │ Focus on design specs                       │ │   │
│  │ │ 2 hours • High Energy                       │ │   │
│  │ └─────────────────────────────────────────────┘ │   │
│  │                                                 │   │
│  │ 11:00 AM                                        │   │
│  │ ┌─────────────────────────────────────────────┐ │   │
│  │ │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░  Email review  │ │   │
│  │ │ 30 min • Low Energy                         │ │   │
│  │ └─────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  • Progress bar shows time elapsed during task          │
│  • Drag edges to resize duration                        │
│  • Drag entire block to reschedule                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 3. Strategy Card

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎯  2-Minute Version                            │   │
│  │                                                 │   │
│  │ Just commit to 2 minutes. That's it.           │   │
│  │ Starting is the hardest part.                  │   │
│  │                                                 │   │
│  │ ┌──────────────────────────────────────────┐   │   │
│  │ │ ████████████████░░░░  85% success rate   │   │   │
│  │ └──────────────────────────────────────────┘   │   │
│  │                                                 │   │
│  │ ↑ This helped        ↓ Didn't work            │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  • Cards stack, swipe to see more options              │
│  • Success rate bar fills based on user's history      │
│  • Gentle coaching tone, not demanding                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 4. Focus Mode Indicator

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  ◉ Peak Focus Mode                              │   │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │   │
│  │  9:00 AM ───────────●──────────── 12:00 PM     │   │
│  │           1h 23m remaining                      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  • Subtle gradient background matching mode             │
│  • Progress indicator shows time remaining              │
│  • Tap to see mode-specific tasks only                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 5. Quick Add Sheet

```
┌─────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────┐   │
│  │  ═══════════════════                            │   │  ← Drag handle
│  │                                                 │   │
│  │  What needs to be done?                         │   │
│  │  ┌─────────────────────────────────────────┐   │   │
│  │  │ Buy milk _                              │   │   │  ← Auto-focus
│  │  └─────────────────────────────────────────┘   │   │
│  │                                                 │   │
│  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐      │   │
│  │  │Today│ │ Tom │ │ Sat │ │ 🗓️ │ │ ∞  │       │   │
│  │  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘      │   │
│  │                                                 │   │
│  │  ┌───────┐ ┌───────┐ ┌───────┐                │   │
│  │  │🏠 Home │ │💼 Work│ │ + New │                │   │
│  │  └───────┘ └───────┘ └───────┘                │   │
│  │                                                 │   │
│  │  ┌──────────────────────────────────────────┐  │   │
│  │  │              Add Task                    │  │   │  ← Primary action
│  │  └──────────────────────────────────────────┘  │   │
│  │                                                 │   │
│  │  🎤 Voice input    📋 Paste from clipboard     │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  • Sheet height adjusts to content                      │
│  • Keyboard avoidance built-in                          │
│  • Dismiss with swipe down or tap outside               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## View Hierarchy

```
TangentleApp
├── ContentView (TabView)
│   ├── TodayTab
│   │   ├── TodayHeader (ambient, pull-to-reveal)
│   │   ├── FocusModeIndicator
│   │   ├── OverdueSection (collapsible)
│   │   ├── TaskList
│   │   │   └── TaskRow (swipeable)
│   │   │       ├── CompletionButton
│   │   │       ├── TaskContent
│   │   │       └── QuickActions
│   │   └── FloatingAddButton
│   │
│   ├── TasksTab
│   │   ├── FilterBar (projects, status, energy)
│   │   ├── TaskList (grouped by project/date)
│   │   └── FloatingAddButton
│   │
│   ├── CalendarTab
│   │   ├── CalendarHeader
│   │   ├── CalendarGrid (gesture-enabled)
│   │   ├── DayDetail (expandable)
│   │   └── TimeBlockList
│   │
│   ├── StrategiesTab
│   │   ├── ActiveStrategyCard
│   │   ├── ProblemTypeSelector
│   │   ├── StrategyCardStack
│   │   └── HistorySection
│   │
│   └── SettingsTab
│       ├── ProfileSection
│       ├── ScheduleSettings
│       ├── FocusModeSettings
│       ├── NotificationSettings
│       └── AppearanceSettings
│
└── Sheets
    ├── QuickAddSheet
    ├── TaskDetailSheet
    ├── StrategyDetailSheet
    └── CoachingSheet
```

---

## Implementation Steps

### Phase 1: Foundation (Steps 1-4)
Build the design system and core components.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 1 | Design Tokens | Colors, typography, spacing, shadows as SwiftUI extensions | - |
| 2 | Base Components | TGCard, TGButton, TGTextField, TGLabel | - |
| 3 | Haptic Manager | Centralized haptic feedback system | - |
| 4 | Animation Extensions | Reusable animation presets | - |

### Phase 2: Task Components (Steps 5-8)
Interactive task UI elements.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 5 | TaskRow | Swipeable task row with actions | - |
| 6 | SwipeActionsView | Generic swipe actions handler (UIKit bridge) | - |
| 7 | CompletionAnimation | Checkmark, strikethrough, confetti | - |
| 8 | TaskDetailSheet | Expandable task details | - |

### Phase 3: Today View (Steps 9-12)
Main productivity screen.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 9 | TodayHeader | Ambient header with time-of-day gradients | - |
| 10 | FocusModeIndicator | Current mode display with progress | - |
| 11 | TodayTaskList | Grouped tasks with overdue section | - |
| 12 | PullToReveal | Custom pull gesture for header reveal | - |

### Phase 4: Calendar View (Steps 13-16)
Time-based task visualization.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 13 | CalendarGrid | Month/week grid with gestures | - |
| 14 | DayExpansion | Inline day detail expansion | - |
| 15 | TimeBlockView | Scheduled task blocks | - |
| 16 | DragToReschedule | Drag tasks between dates | - |

### Phase 5: Strategy Coaching (Steps 17-19)
ADHD strategy interface.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 17 | ProblemTypeSelector | Chip-based problem type picker | - |
| 18 | StrategyCardStack | Swipeable strategy recommendations | - |
| 19 | OutcomeSwipe | Swipe up/down for outcome recording | - |

### Phase 6: Quick Capture (Steps 20-22)
Fast task entry.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 20 | QuickAddSheet | Bottom sheet with smart defaults | - |
| 21 | FloatingAddButton | Draggable FAB with long-press voice | - |
| 22 | ShakeToCapture | Device shake gesture handler | - |

### Phase 7: Polish (Steps 23-26)
Final refinements.

| Step | Name | Description | Estimate |
|------|------|-------------|----------|
| 23 | Dark Mode | Complete dark theme implementation | - |
| 24 | Accessibility | VoiceOver, Dynamic Type, Reduce Motion | - |
| 25 | Onboarding Flow | First-launch experience | - |
| 26 | Micro-interactions | Button presses, loading states, transitions | - |

---

## Technical Considerations

### UIKit Integration
Some gestures require UIKit for proper handling:

```swift
// SwipeActionsView using UIViewRepresentable
struct SwipeActionsView: UIViewRepresentable {
    // UISwipeActionsConfiguration for table-like swipe
}

// Custom pull-to-reveal using UIPanGestureRecognizer
struct PullToRevealModifier: ViewModifier {
    // Tracks pan gesture state
}
```

### Performance Optimizations
- Use `LazyVStack` for task lists
- Implement view recycling for calendar
- Preload adjacent days for smooth swiping
- Use `drawingGroup()` for complex animations
- Cache gradient renders

### State Management
- `@Observable` for ViewModels
- Environment injection for theme
- Combine for gesture state coordination

---

## Accessibility

### VoiceOver
- All gestures have tap alternatives
- Custom rotor for task navigation
- Meaningful labels for all interactive elements

### Dynamic Type
- All text scales with system settings
- Layouts adapt to larger sizes
- Minimum touch targets: 44pt

### Reduce Motion
- Respect `accessibilityReduceMotion`
- Provide cross-dissolve alternatives
- Disable parallax effects

---

## Success Metrics

### Qualitative
- "It feels delightful to complete tasks"
- "The gestures feel natural"
- "I actually want to open the app"

### Quantitative
- Task completion rate increase
- Session duration increase
- Gesture discovery rate (analytics)
- Crash-free rate > 99.9%

---

## Dependencies

- iOS 17.0+ (for `@Observable`, new SwiftUI features)
- No external UI libraries (pure SwiftUI + UIKit bridges)
- SF Symbols 5 for icons
- Core Haptics for advanced haptic patterns

---

## Open Questions

1. **Landscape support?** - Probably defer to later
2. **iPad layout?** - Consider column-based for larger screens
3. **Widget design?** - Small/medium widgets for Today view
4. **Watch companion?** - Minimal task completion interface
5. **Siri integration?** - Quick add via voice

---

## Related Plans

- **Plan 003**: Claude AI API integration (coaching conversations)
- **Plan 004**: CloudKit sync (multi-device)
- **Plan 005**: Widgets & Watch app

---

*Created: 2025-12-21*
*Status: Ready for planning*
