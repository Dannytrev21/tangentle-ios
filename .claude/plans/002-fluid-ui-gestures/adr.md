# ADR: Fluid UI & Gesture System

## Status
Proposed

## Context

Tangentle is an ADHD task management app that currently has a functional but utilitarian UI built with standard SwiftUI components (List, TabView, basic rows). The vision is to create a premium, delightful experience inspired by apps like Timepage, Things 3, Bear, and Clear.

**Current State:**
- Basic `List` with `TaskRow` components
- Standard `TabView` navigation
- No custom animations or gestures
- No theme system (using system defaults)
- No haptic feedback integration

**Desired State:**
- Warm, calming aesthetic (cream/ivory light, warm dark)
- Physics-based animations that feel alive
- Gesture-driven interactions (swipe to complete, contextual actions)
- Satisfying haptic feedback on key interactions
- ADHD-friendly: one focus at a time, clear visual hierarchy

**Why This Matters for ADHD Users:**
1. **Aesthetics affect motivation** - Beautiful tools are more likely to be used
2. **Gestures reduce decision fatigue** - Swipe is easier than find-and-tap
3. **Physics feedback confirms actions** - Reduces anxiety about "did it work?"
4. **Warmth reduces overwhelm** - Cool sterile UIs can feel hostile

## Tree of Thought Analysis

### Decision 1: Task Completion Mechanism

#### Options Considered

**Option A: Swipe-to-Complete**
```
[Task Row] ──swipe right──► [Reveals Checkmark] ──release──► [Completed]
```
- **Pros**: Familiar (iOS Mail), reversible, shows progress visually
- **Cons**: May conflict with other swipe actions, requires careful gesture design
- **ADHD Impact**: Quick, low-friction, satisfying

**Option B: Long-Press Charge**
```
[Task Row] ──hold──► [Circle fills] ──release──► [Completed with celebration]
```
- **Pros**: Very satisfying, prevents accidental completion, unique feel
- **Cons**: Slower (500ms+), may feel heavy for many quick tasks
- **ADHD Impact**: More intentional, may help with impulsive mis-taps

**Option C: Tap Checkbox**
```
[Checkbox] ──tap──► [Completed]
```
- **Pros**: Fast, familiar, accessible
- **Cons**: Easy to mis-tap, boring, no feedback
- **ADHD Impact**: Can feel unsatisfying, no reward moment

#### Decision
**Hybrid: Swipe-to-complete (default) + Long-press (optional setting) + Tap (always available)**

Rationale:
- Swipe is the best balance of speed and satisfaction
- Long-press available for users who want it (sensory-seeking)
- Tap checkbox always works for accessibility

---

### Decision 2: Animation Implementation

#### Options Considered

**Option A: Pure SwiftUI**
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7))
```
- **Pros**: Simple, declarative, no bridging
- **Cons**: Limited gesture control, can't easily do 120fps, some animations choppy

**Option B: UIKit Integration**
```swift
UIViewRepresentable + UIPanGestureRecognizer + UISpringTimingParameters
```
- **Pros**: Full gesture control, native 120fps on ProMotion, precise physics
- **Cons**: More code, UIKit/SwiftUI bridging complexity

**Option C: Custom CADisplayLink Engine**
```swift
class PhysicsAnimator { CADisplayLink, custom spring math }
```
- **Pros**: Maximum control, custom physics
- **Cons**: Over-engineering, reinventing UIKit, maintenance burden

#### Decision
**Option B: UIKit Integration**

Rationale:
- CLAUDE.md explicitly recommends "UIKit for complex gestures"
- 120fps on ProMotion devices is a stated goal
- UIKit gesture recognizers are battle-tested
- SwiftUI handles layout; UIKit handles gesture physics

---

### Decision 3: Theme System Architecture

#### Options Considered

**Option A: Static Colors**
```swift
extension Color {
    static let background = Color("Background")
}
```
- **Pros**: Simple, uses asset catalog
- **Cons**: No runtime switching, no user themes

**Option B: Theme Protocol**
```swift
protocol Theme {
    var background: Color { get }
    var surface: Color { get }
    var accent: Color { get }
}
```
- **Pros**: Swappable themes, testable, extensible
- **Cons**: More indirection, environment injection needed

**Option C: Dynamic Time-Based**
```swift
TimeBasedTheme: adjusts colors based on time of day
```
- **Pros**: Ambient, Timepage-like
- **Cons**: Complex, may distract, not always appropriate

#### Decision
**Option B: Theme Protocol**

Rationale:
- User explicitly wants future ability to change color schemes
- Protocol allows `WarmLightTheme`, `WarmDarkTheme`, future `OceanTheme`, etc.
- Environment-based injection (`@Environment(\.theme)`) is SwiftUI-native
- Can add time-based variations within a theme later

---

### Decision 4: Swipe Action Configuration

#### Options Considered

**Option A: Fixed Actions**
```
Left swipe: Delete
Right swipe: Complete
```
- **Pros**: Simple, predictable
- **Cons**: Inflexible, doesn't adapt to context

**Option B: Contextual Actions**
```
Blocked task right swipe: "Unblock"
Deferred task left swipe: "Reschedule"
```
- **Pros**: Smart, reduces friction, feels intelligent
- **Cons**: More logic, users may be confused initially

**Option C: User-Configurable**
```
Settings > Swipe Actions > Configure...
```
- **Pros**: Maximum flexibility
- **Cons**: Settings complexity, ADHD users may never configure

#### Decision
**All three, layered**

```
[Base Actions] ──overridden by──► [Contextual] ──overridden by──► [User Config]
```

MVP: Base + Contextual
v1.1: Add user configuration

Rationale:
- Smart defaults reduce cognitive load (ADHD-friendly)
- Contextual actions make the app feel intelligent
- User config is power-user feature for later

---

### Decision 5: Haptic Feedback Strategy

#### Options Considered

**Option A: Rich Haptics**
- Every tap, swipe, transition
- **Risk**: Overwhelming, sensory overload for some ADHD users

**Option B: Selective Haptics**
- Task completion, major actions only
- **Balance**: Meaningful feedback without fatigue

**Option C: User-Configurable**
- Off, Selective, Rich modes
- **Best of both worlds**

#### Decision
**Option C: User-Configurable with Selective as Default**

Rationale:
- ADHD users may be sensory-sensitive (under- or over-responsive)
- Default to selective (key moments only)
- Allow users to increase or disable in settings
- Store preference in `TGSettings.display.hapticFeedbackIntensity`

---

---

### Decision 6: Accessibility Approach

#### Options Considered

**Option A: Basic Accessibility**
- VoiceOver labels only
- Standard system behaviors

**Option B: Comprehensive Accessibility**
- VoiceOver with meaningful labels
- Dynamic Type support
- Reduce Motion support
- High Contrast support

**Option C: ADHD-Specific Accessibility**
- All of Option B plus
- Sensory settings (haptics, sounds)
- Focus mode considerations

#### Decision
**Option C: ADHD-Specific Accessibility**

Rationale:
- ADHD users may have co-occurring conditions (dyslexia, sensory processing)
- Sensory customization (haptics off/selective/rich) already planned
- Dynamic Type helps with focus and readability
- Reduce Motion prevents overstimulation
- Aligns with Apple's accessibility guidelines

---

## Decision Summary

| Decision | Selected | Rationale |
|----------|----------|-----------|
| Task Completion | Swipe (default) + Long-press (option) + Tap | Balance of speed and satisfaction |
| Animation | UIKit for complex gestures, SwiftUI for simple | Hybrid approach per use case |
| Theme System | Protocol-based | Extensible, user themes later |
| Swipe Actions | Base + Contextual + Config | Smart defaults, power-user config |
| Haptics | Configurable, Selective default | Respects sensory differences |
| Accessibility | ADHD-Specific (comprehensive) | Supports co-occurring conditions |

## Consequences

### Positive
1. **Premium feel** - App will feel polished and intentional
2. **ADHD-optimized** - Reduced friction, clear feedback
3. **Future-proof** - Theme and gesture systems are extensible
4. **Performance** - 120fps animations on capable devices
5. **Accessibility maintained** - Tap always works, VoiceOver supported

### Negative
1. **Implementation complexity** - UIKit bridging adds code
2. **Testing complexity** - Gesture tests are harder than tap tests
3. **Maintenance burden** - Custom components need upkeep
4. **Learning curve** - New patterns for future contributors

### Mitigations
1. **Complexity**: Encapsulate UIKit in dedicated gesture handlers
2. **Testing**: Create gesture simulation helpers for tests
3. **Maintenance**: Document patterns thoroughly, use protocols
4. **Learning**: Code comments explaining why UIKit is used

## Implementation Notes

### Animation Timing Reference
```swift
// Standard animations
static let quick = 0.15   // Button presses
static let normal = 0.3   // View transitions
static let slow = 0.5     // Major state changes

// Spring configurations
static let snappy = (response: 0.25, damping: 0.7)
static let gentle = (response: 0.4, damping: 0.8)
static let bouncy = (response: 0.3, damping: 0.5)
```

### Color Philosophy
```
Light Mode: Warm, inviting, like a cozy notebook
- Background: Cream/off-white (#FFFDF7)
- Surface: Pure white with warm shadow
- Accent: Terracotta/amber for energy

Dark Mode: Warm, not cold, like candlelight
- Background: Not pure black, warm charcoal (#1C1917)
- Surface: Slightly lighter warm gray
- Accent: Soft amber/gold
```

### Haptic Moments
```
Completion: .success (satisfying thunk)
Delete: .warning (cautionary)
Swipe threshold: .selection (subtle click)
Long-press charge: .rigid at start, .success at complete
```
