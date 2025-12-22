# Step 11: Today View Redesign

## Context
Today View is the primary screen users see. It needs to showcase all the new components working together: themed styling, swipeable task cards, animated checkboxes, and clear visual hierarchy. This is where the "living, breathing companion" vision comes to life.

## Goal
Completely redesign TodayView using all new UI components, creating a beautiful, functional, and ADHD-friendly task view.

## Prerequisites
- All previous steps (1-10) completed
- Theme system working
- SwipeableRow, TaskCard, AnimatedCheckbox ready
- Custom Tab Bar integrated

## High-Level Steps
1. Design Today View layout with time sections
2. Implement themed header with date/greeting
3. Create task list with SwipeableRow + TaskCard
4. Add empty state design
5. Implement pull-to-refresh with custom animation
6. Add floating action button for quick add
7. Wire up ViewModel actions for swipe gestures

## Detailed Requirements

### Today View Layout
```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  Good Morning, Danny ☀️                        Sat, Dec 21  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ ⚠️ OVERDUE (2)                                         │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  [TaskCard - Overdue styling]                          │  │
│  │  [TaskCard - Overdue styling]                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ TODAY (5)                                              │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  [TaskCard in SwipeableRow]                            │  │
│  │  [TaskCard in SwipeableRow]                            │  │
│  │  [TaskCard in SwipeableRow]                            │  │
│  │  ...                                                   │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│                                              ┌─────┐         │
│                                              │  +  │  FAB    │
│                                              └─────┘         │
└──────────────────────────────────────────────────────────────┘
```

### TodayView Redesign
```swift
struct TodayView: View {
    @Environment(\.container) var container
    @Environment(\.theme) var theme
    @State private var viewModel: TodayViewModel?
    @State private var showAddTask = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    TodayHeader()
                        .padding(.horizontal, Spacing.md)

                    if let vm = viewModel {
                        TodayContent(viewModel: vm)
                    } else {
                        LoadingView()
                    }
                }
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.xxxl) // Space for FAB and tab bar
            }
            .refreshable {
                await viewModel?.loadTasks()
            }
            .background(theme.backgroundPrimary)

            // Floating Action Button
            FloatingActionButton {
                showAddTask = true
            }
            .padding(.trailing, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .task {
            viewModel = TodayViewModel(
                taskService: container.taskService,
                scheduleService: container.scheduleService
            )
            await viewModel?.loadTasks()
        }
        .sheet(isPresented: $showAddTask) {
            // QuickAddTaskSheet() - future implementation
            Text("Add Task")
        }
    }
}
```

### Today Header
```swift
struct TodayHeader: View {
    @Environment(\.theme) var theme

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(greeting)
                    .font(Typography.titleLarge)
                    .foregroundStyle(theme.textPrimary)

                Text(formattedDate)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)
            }

            Spacer()

            // Weather or icon (optional)
            Image(systemName: timeOfDayIcon)
                .font(.system(size: 28))
                .foregroundStyle(theme.accentPrimary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var timeOfDayIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "sun.max.fill"
        case 12..<18: return "sun.min.fill"
        case 18..<21: return "sunset.fill"
        default: return "moon.fill"
        }
    }
}
```

### Today Content (Task List)
```swift
struct TodayContent: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics
    @Bindable var viewModel: TodayViewModel

    var body: some View {
        LazyVStack(spacing: Spacing.md) {
            // Overdue section
            if !viewModel.overdueTasks.isEmpty {
                TaskSection(
                    title: "Overdue",
                    icon: "exclamationmark.triangle.fill",
                    iconColor: theme.statusError,
                    count: viewModel.overdueTasks.count
                ) {
                    ForEach(viewModel.overdueTasks, id: \.id) { task in
                        taskRow(task)
                    }
                }
            }

            // Today section
            TaskSection(
                title: "Today",
                icon: "calendar",
                iconColor: theme.accentPrimary,
                count: viewModel.todaysTasks.count
            ) {
                if viewModel.todaysTasks.isEmpty && viewModel.overdueTasks.isEmpty {
                    TodayEmptyState()
                } else if viewModel.todaysTasks.isEmpty {
                    Text("All caught up for today!")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(theme.textSecondary)
                        .padding(.vertical, Spacing.lg)
                } else {
                    ForEach(viewModel.todaysTasks, id: \.id) { task in
                        taskRow(task)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func taskRow(_ task: TGTask) -> some View {
        SwipeableRow(
            leadingActions: leadingActions(for: task),
            trailingActions: trailingActions(for: task)
        ) {
            TaskCard(task: task) {
                // On tap - show detail
            }
        }
    }

    private func leadingActions(for task: TGTask) -> [SwipeAction] {
        [
            StandardSwipeActions.complete(task: task) {
                Task {
                    await viewModel.completeTask(task)
                }
            }
        ]
    }

    private func trailingActions(for task: TGTask) -> [SwipeAction] {
        var actions: [SwipeAction] = []

        if task.isBlocked {
            actions.append(StandardSwipeActions.unblock(task: task) {
                // Unblock action
            })
        }

        actions.append(contentsOf: [
            StandardSwipeActions.defer_ {
                // Defer action
            },
            StandardSwipeActions.delete {
                Task {
                    await viewModel.deleteTask(task)
                }
            }
        ])

        return actions
    }
}
```

### Task Section
```swift
struct TaskSection<Content: View>: View {
    @Environment(\.theme) var theme
    let title: String
    let icon: String
    let iconColor: Color
    let count: Int
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section header
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)

                Text(title.uppercased())
                    .font(Typography.labelMedium)
                    .foregroundStyle(theme.textSecondary)

                Text("(\(count))")
                    .font(Typography.labelMedium)
                    .foregroundStyle(theme.textTertiary)

                Spacer()
            }
            .padding(.horizontal, Spacing.xs)

            // Content
            content
        }
    }
}
```

### Empty State
```swift
struct TodayEmptyState: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(theme.statusSuccess.opacity(0.5))

            VStack(spacing: Spacing.xs) {
                Text("All Clear!")
                    .font(Typography.titleMedium)
                    .foregroundStyle(theme.textPrimary)

                Text("No tasks scheduled for today.\nEnjoy your free time!")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, Spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
```

### Floating Action Button
```swift
struct FloatingActionButton: View {
    @Environment(\.theme) var theme
    @Environment(\.hapticEngine) var haptics
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            haptics.trigger(.medium)
            action()
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(theme.accentPrimary)
                .clipShape(Circle())
                .shadow(
                    color: theme.accentPrimary.opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("Add task")
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(SpringConfig.snappy, value: configuration.isPressed)
    }
}
```

### ViewModel Updates
```swift
// Add to TodayViewModel
extension TodayViewModel {
    @MainActor
    func deleteTask(_ task: TGTask) async {
        do {
            try await taskService.deleteTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func deferTask(_ task: TGTask) async {
        do {
            try await taskService.updateTask(task, with: TaskChanges(
                status: .deferred
            ))
            await loadTasks()
        } catch {
            self.error = error
        }
    }
}
```

## Files to Create

### `Tangentle/Features/Tasks/TodayHeader.swift`
Header component with greeting and date.

### `Tangentle/Features/Tasks/TaskSection.swift`
Section container for task groups.

### `Tangentle/Features/Tasks/TodayEmptyState.swift`
Empty state design.

### `Tangentle/UI/Components/FloatingActionButton.swift`
FAB component.

### `Tangentle/UI/Components/ScaleButtonStyle.swift`
Reusable button style.

## Files to Modify

### `Tangentle/Features/Tasks/TodayView.swift`
Complete redesign with new layout.

### `Tangentle/Features/Tasks/TodayViewModel.swift`
Add delete, defer actions.

## Patterns to Follow
Reference: Existing `TodayView.swift` for ViewModel integration
Reference: Things 3 Today view for visual inspiration

## Acceptance Criteria
- [ ] Today View uses new theme colors
- [ ] Header shows greeting based on time of day
- [ ] Overdue section appears when needed
- [ ] Tasks display in SwipeableRow with TaskCard
- [ ] Swipe left for delete/defer, right for complete
- [ ] Contextual actions work (blocked shows unblock)
- [ ] Empty state is friendly and themed
- [ ] FAB appears for quick add
- [ ] Pull-to-refresh works
- [ ] All animations are smooth
- [ ] VoiceOver accessibility works
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Run tests
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -30
```

## Documentation Updates
- [ ] Update CLAUDE.md if significant patterns change

## Error Recovery
If verification fails:
1. Check all component imports
2. Verify environment objects are provided
3. Check SwipeableRow integration

## Do NOT
- Break existing ViewModel contract
- Remove functionality from current TodayView
- Skip error handling in async actions
