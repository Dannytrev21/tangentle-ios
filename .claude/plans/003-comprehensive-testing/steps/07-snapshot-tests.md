# Step 7: Snapshot Tests

## Context
Snapshot tests capture visual representations of UI components and compare them against baselines. This catches visual regressions automatically. We're using swift-snapshot-testing (Point-Free) which supports SwiftUI out of the box.

## Goal
Create snapshot tests for all 17 UI components covering various states, themes, and configurations.

## Prerequisites
- Step 1 completed (swift-snapshot-testing added as dependency)

## High-Level Steps
1. Set up snapshot test infrastructure
2. Create component snapshot tests
3. Create screen snapshot tests
4. Generate baselines for light and dark themes
5. Verify snapshots detect intentional changes

## Detailed Requirements

### Snapshot Test Pattern
```swift
import XCTest
import SnapshotTesting
@testable import Tangentle

final class ComponentSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset snapshot testing settings
        // isRecording = true // Uncomment to record new baselines
    }

    func testComponent_defaultState() {
        let view = ComponentView()
            .frame(width: 300, height: 100)
            .environment(\.colorScheme, .light)

        assertSnapshot(of: view, as: .image)
    }

    func testComponent_darkMode() {
        let view = ComponentView()
            .frame(width: 300, height: 100)
            .environment(\.colorScheme, .dark)

        assertSnapshot(of: view, as: .image)
    }
}
```

### Snapshot Configuration
```swift
extension Snapshotting where Value: SwiftUI.View, Format == UIImage {
    static func standardImage(
        precision: Float = 0.99,
        size: CGSize? = nil,
        traits: UITraitCollection = .init()
    ) -> Snapshotting {
        // Configure snapshot settings for consistency
    }
}
```

### Components to Snapshot

#### 1. AnimatedCheckbox
- Default unchecked state (light/dark)
- Checked state (light/dark)
- Each priority color variant
- Large and small sizes

#### 2. TaskCard
- Default state with all badges visible
- Minimal state (title only)
- Completed state (crossed out)
- Overdue state (red badge)
- Blocked state (gray overlay)
- Different priority colors
- With/without project badge
- Light and dark themes

#### 3. TaskRow
- Default state
- Swiped state (showing actions)
- Selected state
- Light and dark themes

#### 4. CustomTabBar
- All tabs, each selected
- Hidden state
- Light and dark themes

#### 5. TabBarItem
- Selected state
- Unselected state
- Each tab icon

#### 6. PriorityBadge
- All priority levels (none, low, medium-low, medium, medium-high, high)
- Light and dark themes

#### 7. EnergyBadge
- All energy levels (low, medium, high)
- Light and dark themes

#### 8. DurationBadge
- Various durations (5, 15, 30, 60, 120 min)
- Light and dark themes

#### 9. ProjectBadge
- With emoji
- Without emoji
- Various name lengths
- Light and dark themes

#### 10. StatusBadges (Blocked, Overdue, WaitingFor)
- Each status type
- Light and dark themes

#### 11. CompletionIndicator
- Incomplete state (each priority)
- Complete state
- Light and dark themes

#### 12. SwipeableRow
- Default state
- Left swipe revealed
- Right swipe revealed
- Light and dark themes

#### 13. SwipeActionButton
- Each action type (complete, delete, defer)
- Light and dark themes

#### 14. FloatingActionButton
- Default state
- Pressed state
- Light and dark themes

#### 15. CheckmarkShape
- Various sizes
- Animation frame captures (0%, 50%, 100%)

#### 16. ParticleBurst
- Initial burst state
- Mid-animation state

### Screen Snapshots

#### TodayView
- Empty state
- With tasks (few)
- With tasks (many)
- With overdue section
- Light and dark themes
- iPhone SE (small)
- iPhone 15 Pro Max (large)

#### TodayHeader
- Default date display
- Light and dark themes

#### TodayEmptyState
- Default empty message
- Light and dark themes

#### TaskSection
- With tasks
- Collapsed state
- Light and dark themes

### Device Size Matrix
Test key screens on:
- iPhone SE (375 × 667) - smallest supported
- iPhone 15 (390 × 844) - standard
- iPhone 15 Pro Max (430 × 932) - largest

### Theme Matrix
All components tested in:
- Light mode (WarmLightTheme)
- Dark mode (WarmDarkTheme)

## Files to Create
- `TangentleTests/Snapshots/SnapshotTestCase.swift` - Base class with common setup
- `TangentleTests/Snapshots/Components/CheckboxSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/TaskCardSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/TaskRowSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/TabBarSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/BadgeSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/SwipeableRowSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/FloatingActionButtonSnapshotTests.swift`
- `TangentleTests/Snapshots/Screens/TodayViewSnapshotTests.swift`
- `TangentleTests/Snapshots/__Snapshots__/` - Generated baseline images

## Files to Modify
- None

## Patterns to Follow
Reference: swift-snapshot-testing documentation
Reference: `Tangentle/UI/Components/` for component implementations
Reference: `Tangentle/UI/Themes/` for theme injection

## Acceptance Criteria
- [ ] All 17 components have snapshot tests
- [ ] Light and dark modes tested for each component
- [ ] Key screens tested at multiple device sizes
- [ ] Baselines generated and committed
- [ ] Snapshot precision set appropriately (0.99 typical)
- [ ] Tests detect visual changes correctly
- [ ] All tests pass

## Testing Requirements

### Snapshot Tests
- Test files: See "Files to Create" above
- Minimum: 100+ snapshot assertions (components × states × themes)

### What to Test
- Visual appearance at rest
- Key interaction states
- Theme variations
- Size variations for responsive components
- Accessibility text sizes (if applicable)

## Verification Commands
```bash
# Record new baselines (run once initially)
# Set isRecording = true in test setUp, then:
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Snapshots

# Run snapshot tests (compare against baselines)
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Snapshots

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- Document how to update baselines when intentional changes are made

## Error Recovery
If verification fails:
1. Check if failure is due to intentional visual change
2. Set `isRecording = true` to capture new baseline
3. Run test once to record
4. Set `isRecording = false`
5. Commit new baseline images
6. Verify test passes with new baseline

## Do NOT
- Test animations frame-by-frame (too many images)
- Snapshot every possible permutation (strategic selection)
- Include timestamps or dynamic data in snapshots
- Forget to commit baseline images to git
- Set precision too low (allows visual regressions)
