# Step 8: TaskCard

## Context
TaskCard is the redesigned task row component that replaces the current basic TaskRow. It incorporates the theme system, improved visual hierarchy, and works with SwipeableRow for gesture interactions.

## Goal
Create a beautiful, informative task card that displays task information clearly with ADHD-friendly visual hierarchy, warm aesthetics, and accessibility support.

## Prerequisites
- Step 1 (Design Tokens) completed
- Step 2 (Theme System) completed
- Step 3 (Typography Scale) completed

**Note:** TaskCard does NOT require SwipeableRow. They compose together in Step 11 - TaskCard is the content, SwipeableRow is the gesture container.

## High-Level Steps
1. Design TaskCard layout with visual hierarchy
2. Create PriorityIndicator component
3. Create EnergyBadge component
4. Create DurationBadge component
5. Implement project color indicator
6. Add overdue and blocked state styling
7. Ensure VoiceOver accessibility

## Detailed Requirements

### TaskCard Layout
```
┌──────────────────────────────────────────────────────────────┐
│ ┌────┐                                                       │
│ │ ○  │  Task Title                                    ⚡ 15m │
│ │    │  📁 Project Name                               🔴 HIGH │
│ └────┘                                                       │
└──────────────────────────────────────────────────────────────┘
   │                                                      │
   └─ Completion indicator                    Metadata row ┘
      (circle, fills on complete)
```

### TaskCard Component
```swift
struct TaskCard: View {
    @Environment(\.theme) var theme
    let task: TGTask
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Completion indicator
                CompletionIndicator(
                    isCompleted: task.isCompleted,
                    priority: task.taskPriority
                )

                // Content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    // Title
                    Text(task.title ?? "Untitled")
                        .font(Typography.bodyLarge)
                        .foregroundStyle(titleColor)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)

                    // Metadata row
                    HStack(spacing: Spacing.sm) {
                        if let project = task.project {
                            ProjectBadge(project: project)
                        }

                        if task.isBlocked {
                            BlockedBadge()
                        }

                        if task.isOverdue {
                            OverdueBadge()
                        }
                    }
                }

                Spacer(minLength: Spacing.sm)

                // Right side: duration and priority
                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                    if task.estimatedDuration > 0 {
                        DurationBadge(minutes: Int(task.estimatedDuration))
                    }

                    if task.taskPriority != .none {
                        PriorityBadge(priority: task.taskPriority)
                    }

                    if task.energy != .medium {
                        EnergyBadge(energy: task.energy)
                    }
                }
            }
            .padding(.vertical, Spacing.sm)
            .padding(.horizontal, Spacing.md)
            .background(cardBackground)
            .cornerRadius(CornerRadius.md)
            .shadow(
                color: theme.textPrimary.opacity(0.05),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
    }

    private var titleColor: Color {
        if task.isCompleted {
            return theme.textTertiary
        } else if task.isOverdue {
            return theme.statusError
        } else {
            return theme.textPrimary
        }
    }

    private var cardBackground: Color {
        task.isCompleted
            ? theme.backgroundTertiary
            : theme.surfaceElevated
    }

    private var accessibilityLabel: String {
        var parts: [String] = []
        parts.append(task.title ?? "Untitled task")
        if task.isCompleted { parts.append("completed") }
        if task.isOverdue { parts.append("overdue") }
        if task.isBlocked { parts.append("blocked") }
        if let project = task.project?.name {
            parts.append("in project \(project)")
        }
        if task.estimatedDuration > 0 {
            parts.append("\(task.estimatedDuration) minutes")
        }
        return parts.joined(separator: ", ")
    }
}
```

### Completion Indicator
```swift
struct CompletionIndicator: View {
    @Environment(\.theme) var theme
    let isCompleted: Bool
    let priority: Priority

    var body: some View {
        Circle()
            .strokeBorder(borderColor, lineWidth: 2)
            .background(
                Circle()
                    .fill(isCompleted ? theme.statusSuccess : .clear)
            )
            .overlay {
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 24, height: 24)
    }

    private var borderColor: Color {
        if isCompleted {
            return theme.statusSuccess
        }
        switch priority {
        case .high, .mediumHigh:
            return theme.priorityHigh
        case .medium, .mediumLow:
            return theme.priorityMedium
        default:
            return theme.textTertiary
        }
    }
}
```

### Priority Badge
```swift
struct PriorityBadge: View {
    @Environment(\.theme) var theme
    let priority: Priority

    var body: some View {
        Text(priority.displayName.uppercased())
            .font(Typography.labelSmall)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxxs)
            .background(color.opacity(0.15))
            .cornerRadius(CornerRadius.sm)
    }

    private var color: Color {
        switch priority {
        case .high, .mediumHigh: return theme.priorityHigh
        case .medium, .mediumLow: return theme.priorityMedium
        case .low: return theme.priorityLow
        case .none: return theme.priorityNone
        }
    }
}
```

### Energy Badge
```swift
struct EnergyBadge: View {
    @Environment(\.theme) var theme
    let energy: EnergyLevel

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(energy.displayName)
                .font(Typography.labelSmall)
        }
        .foregroundStyle(color)
    }

    private var icon: String {
        switch energy {
        case .high: return "bolt.fill"
        case .medium: return "bolt"
        case .low: return "leaf.fill"
        }
    }

    private var color: Color {
        switch energy {
        case .high: return theme.energyHigh
        case .medium: return theme.energyMedium
        case .low: return theme.energyLow
        }
    }
}
```

### Duration Badge
```swift
struct DurationBadge: View {
    @Environment(\.theme) var theme
    let minutes: Int

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "clock")
                .font(.system(size: 10))
            Text(formattedDuration)
                .font(Typography.labelSmall)
        }
        .foregroundStyle(theme.textSecondary)
    }

    private var formattedDuration: String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }
}
```

### Project Badge
```swift
struct ProjectBadge: View {
    @Environment(\.theme) var theme
    let project: TGProject

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            if let emoji = project.emoji {
                Text(emoji)
                    .font(.system(size: 12))
            }
            Text(project.name ?? "")
                .font(Typography.caption)
                .foregroundStyle(theme.textSecondary)
        }
    }
}
```

### Blocked/Overdue Badges
```swift
struct BlockedBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 10))
            Text("Blocked")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.statusWarning)
    }
}

struct OverdueBadge: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: Spacing.xxxs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text("Overdue")
                .font(Typography.caption)
        }
        .foregroundStyle(theme.statusError)
    }
}
```

## Files to Create

### `Tangentle/UI/Components/TaskCard.swift`
Main task card component.

### `Tangentle/UI/Components/CompletionIndicator.swift`
Completion circle component.

### `Tangentle/UI/Components/PriorityBadge.swift`
Priority indicator (replacing old PriorityBadge).

### `Tangentle/UI/Components/EnergyBadge.swift`
Energy level indicator.

### `Tangentle/UI/Components/DurationBadge.swift`
Time estimate badge.

### `Tangentle/UI/Components/ProjectBadge.swift`
Project indicator with emoji.

### `Tangentle/UI/Components/StatusBadges.swift`
Blocked and Overdue badges.

## Files to Modify

### `Tangentle/UI/Components/TaskRow.swift`
Keep for backward compatibility, but mark as deprecated or redirect to TaskCard.

## Patterns to Follow
Reference: `Tangentle/UI/Components/TaskRow.swift` for data access patterns
Reference: Things 3 task row for visual inspiration

## Acceptance Criteria
- [ ] TaskCard displays title, project, duration, priority, energy
- [ ] Visual hierarchy is clear (title most prominent)
- [ ] Overdue tasks have red title
- [ ] Blocked tasks show blocked badge
- [ ] Completed tasks are muted with strikethrough
- [ ] All text uses Typography scale
- [ ] All colors use theme
- [ ] VoiceOver accessibility labels are meaningful
- [ ] Card has subtle shadow elevation
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check component files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Components/*Badge*.swift
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Ensure TGTask extension properties exist
2. Check theme environment access
3. Verify Typography references

## Do NOT
- Hard-code any colors
- Skip accessibility labels
- Create overly complex layouts
