# Step 10: App Shell

## Context
We now have all the backend pieces (repositories, services, DI). This step creates the app entry point, navigation structure, and minimal UI shell. The goal is a running app, not a polished UI - we're proving the architecture works end-to-end.

## Goal
Create the app entry point, tab-based navigation, and placeholder views for each feature area.

## Prerequisites
- Step 7 completed (DI container exists)
- Step 8-9 completed (Services exist)

## High-Level Steps
1. Create app entry point with DI setup
2. Create tab bar navigation
3. Create placeholder views for each feature
4. Wire up environment with container
5. Add basic view models

## Detailed Requirements

### App Entry Point
Update `App/TangentleApp.swift`:

```swift
import SwiftUI

@main
struct TangentleApp: App {
    let container: DIContainer

    init() {
        // Initialize DI container
        container = AppContainer.shared

        // Setup on first launch
        Task {
            await setupFirstLaunch()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withContainer(container)
                .environment(\.managedObjectContext, container.viewContext)
        }
    }

    private func setupFirstLaunch() async {
        // Seed default data on first launch
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            do {
                try await seedDefaultData()
                defaults.set(true, forKey: "hasLaunchedBefore")
            } catch {
                print("Failed to seed data: \(error)")
            }
        }
    }

    private func seedDefaultData() async throws {
        // Will be implemented in Step 11
    }
}
```

### Content View (Tab Navigation)
Update `App/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @Environment(\.container) var container
    @State private var selectedTab: Tab = .today

    enum Tab {
        case today
        case tasks
        case calendar
        case strategies
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
                .tag(Tab.today)

            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(Tab.tasks)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            StrategiesView()
                .tabItem {
                    Label("Strategies", systemImage: "lightbulb")
                }
                .tag(Tab.strategies)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .withContainer(TestContainer())
}
```

### Today View
Create `Features/Tasks/TodayView.swift`:

```swift
import SwiftUI

struct TodayView: View {
    @Environment(\.container) var container
    @State private var viewModel: TodayViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    TodayContent(viewModel: vm)
                } else {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Today")
        }
        .task {
            viewModel = TodayViewModel(
                taskService: container.taskService,
                scheduleService: container.scheduleService
            )
            await viewModel?.loadTasks()
        }
    }
}

struct TodayContent: View {
    @Bindable var viewModel: TodayViewModel

    var body: some View {
        List {
            if viewModel.overdueTasks.count > 0 {
                Section("Overdue") {
                    ForEach(viewModel.overdueTasks, id: \.id) { task in
                        TaskRow(task: task)
                    }
                }
            }

            Section("Today") {
                if viewModel.todaysTasks.isEmpty {
                    Text("No tasks scheduled for today")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.todaysTasks, id: \.id) { task in
                        TaskRow(task: task)
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadTasks()
        }
    }
}

#Preview {
    TodayView()
        .withContainer(TestContainer())
}
```

### Today ViewModel
Create `Features/Tasks/TodayViewModel.swift`:

```swift
import Foundation
import Observation

@Observable
final class TodayViewModel {
    var todaysTasks: [TGTask] = []
    var overdueTasks: [TGTask] = []
    var isLoading = false
    var error: Error?

    private let taskService: TaskServiceProtocol
    private let scheduleService: ScheduleServiceProtocol

    init(taskService: TaskServiceProtocol, scheduleService: ScheduleServiceProtocol) {
        self.taskService = taskService
        self.scheduleService = scheduleService
    }

    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let today = taskService.getTodaysTasks()
            async let overdue = taskService.getOverdueTasks()

            todaysTasks = try await today
            overdueTasks = try await overdue
        } catch {
            self.error = error
        }
    }

    func completeTask(_ task: TGTask) async {
        do {
            try await taskService.completeTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }
}
```

### Task Row Component
Create `UI/Components/TaskRow.swift`:

```swift
import SwiftUI

struct TaskRow: View {
    let task: TGTask

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled")
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {
                    if let project = task.project {
                        Text(project.name ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if task.estimatedDuration > 0 {
                        Label("\(task.estimatedDuration)m", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if task.priority > 0 {
                        PriorityBadge(priority: Int(task.priority))
                    }
                }
            }

            Spacer()

            if task.isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PriorityBadge: View {
    let priority: Int

    var body: some View {
        Text(priorityText)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }

    private var priorityText: String {
        switch priority {
        case 5: return "HIGH"
        case 3...4: return "MED"
        default: return "LOW"
        }
    }

    private var priorityColor: Color {
        switch priority {
        case 5: return .red
        case 3...4: return .orange
        default: return .blue
        }
    }
}

#Preview {
    List {
        TaskRow(task: previewTask)
    }
}

private var previewTask: TGTask {
    let context = PersistenceController.preview.viewContext
    let task = TGTask(context: context)
    task.title = "Sample Task"
    task.estimatedDuration = 30
    task.priority = 5
    return task
}
```

### Placeholder Views
Create placeholder views for remaining tabs:

**Tasks View** (`Features/Tasks/TasksView.swift`):
```swift
import SwiftUI

struct TasksView: View {
    var body: some View {
        NavigationStack {
            Text("All Tasks")
                .navigationTitle("Tasks")
        }
    }
}
```

**Calendar View** (`Features/Calendar/CalendarView.swift`):
```swift
import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            Text("Calendar View")
                .navigationTitle("Calendar")
        }
    }
}
```

**Strategies View** (`Features/Strategies/StrategiesView.swift`):
```swift
import SwiftUI

struct StrategiesView: View {
    var body: some View {
        NavigationStack {
            Text("Strategy Coaching")
                .navigationTitle("Strategies")
        }
    }
}
```

**Settings View** (`Features/Settings/SettingsView.swift`):
```swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Settings")
                .navigationTitle("Settings")
        }
    }
}
```

## Files to Create
- `Tangentle/App/TangentleApp.swift` (update)
- `Tangentle/App/ContentView.swift` (update)
- `Tangentle/Features/Tasks/TodayView.swift`
- `Tangentle/Features/Tasks/TodayViewModel.swift`
- `Tangentle/Features/Tasks/TasksView.swift`
- `Tangentle/Features/Calendar/CalendarView.swift`
- `Tangentle/Features/Strategies/StrategiesView.swift`
- `Tangentle/Features/Settings/SettingsView.swift`
- `Tangentle/UI/Components/TaskRow.swift`

## Files to Modify
- None (all new files)

## Patterns to Follow
- Use @Observable macro for view models (iOS 17+)
- Inject dependencies via environment
- Keep views small and focused
- Use NavigationStack for navigation
- Include #Preview for all views

## Acceptance Criteria
- [ ] App launches without crashes
- [ ] Tab bar shows all 5 tabs
- [ ] TodayView loads and displays tasks
- [ ] Navigation works between tabs
- [ ] Previews work in Xcode
- [ ] DI container properly injected

## Verification Commands
```bash
# Build and run on simulator
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run app on simulator
xcrun simctl boot "iPhone 15" 2>/dev/null || true
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' install
```

## Documentation Updates
- [ ] Update docs/README.md with app overview

## Error Recovery
If app crashes on launch:
1. Check DI container initialization
2. Verify Core Data stack loads correctly
3. Check for missing environment values
4. Look for nil force-unwraps

## Do NOT
- Add complex UI (this is foundation only)
- Skip DI injection in views
- Forget #Preview blocks
- Create circular view dependencies
