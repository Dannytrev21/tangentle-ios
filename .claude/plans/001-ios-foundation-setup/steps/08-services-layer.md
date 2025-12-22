# Step 8: Services Layer

## Context
Services contain business logic that orchestrates repository operations. They implement use cases like "create task with project" or "complete task and record strategy outcome". This layer keeps ViewModels thin and logic testable.

## Goal
Create service protocols and implementations for core business operations.

## Prerequisites
- Step 6 completed (Repositories exist)
- Step 7 completed (DI container exists)

## High-Level Steps
1. Create TaskService for task operations
2. Create StrategyService for strategy coaching
3. Create ScheduleService for scheduling logic
4. Create SettingsService for settings management
5. Wire services into DI container

## Detailed Requirements

### TaskService
Create `Core/Services/TaskService.swift`:

```swift
import Foundation

protocol TaskServiceProtocol {
    // CRUD
    func createTask(title: String, in project: TGProject?) async throws -> TGTask
    func updateTask(_ task: TGTask) async throws
    func deleteTask(_ task: TGTask) async throws
    func completeTask(_ task: TGTask) async throws

    // Queries
    func getTodaysTasks() async throws -> [TGTask]
    func getOverdueTasks() async throws -> [TGTask]
    func getTasksForProject(_ project: TGProject) async throws -> [TGTask]

    // ADHD-specific
    func breakDownTask(_ task: TGTask, into subtaskTitles: [String]) async throws -> [TGTask]
    func estimateWithBuffer(_ minutes: Int) -> Int
    func suggestEnergy(for task: TGTask, at time: Date) -> EnergyLevel
}

final class TaskService: TaskServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let projectRepository: ProjectRepositoryProtocol
    private let strategyRepository: StrategyRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        projectRepository: ProjectRepositoryProtocol,
        strategyRepository: StrategyRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.projectRepository = projectRepository
        self.strategyRepository = strategyRepository
    }

    func createTask(title: String, in project: TGProject? = nil) async throws -> TGTask {
        guard let repo = taskRepository as? TaskRepository else {
            throw RepositoryError.invalidData("Invalid repository type")
        }
        return try await repo.createTask(title: title, project: project, priority: 0)
    }

    func updateTask(_ task: TGTask) async throws {
        task.updatedAt = Date()
        try await taskRepository.save()
    }

    func deleteTask(_ task: TGTask) async throws {
        try await taskRepository.delete(task)
    }

    func completeTask(_ task: TGTask) async throws {
        task.markCompleted()
        try await taskRepository.save()
    }

    func getTodaysTasks() async throws -> [TGTask] {
        guard let repo = taskRepository as? TaskRepository else { return [] }
        return try await repo.fetchTodaysTasks()
    }

    func getOverdueTasks() async throws -> [TGTask] {
        guard let repo = taskRepository as? TaskRepository else { return [] }
        return try await repo.fetchOverdue()
    }

    func getTasksForProject(_ project: TGProject) async throws -> [TGTask] {
        guard let repo = taskRepository as? TaskRepository else { return [] }
        return try await repo.fetchByProject(project)
    }

    // ADHD-Specific: Break large task into small chunks
    func breakDownTask(_ task: TGTask, into subtaskTitles: [String]) async throws -> [TGTask] {
        var subtasks: [TGTask] = []
        for (index, title) in subtaskTitles.enumerated() {
            let subtask = taskRepository.create()
            subtask.id = UUID()
            subtask.title = title
            subtask.parentTask = task
            subtask.sortOrder = Int32(index)
            subtask.estimatedDuration = 15 // Default small chunk
            subtask.status = TaskStatus.pending.rawValue
            subtask.energyRequired = task.energyRequired
            subtask.createdAt = Date()
            subtask.updatedAt = Date()
            subtasks.append(subtask)
        }
        try await taskRepository.save()
        return subtasks
    }

    // ADHD-Specific: Add buffer to time estimates (Danny underestimates)
    func estimateWithBuffer(_ minutes: Int) -> Int {
        if minutes <= 5 {
            return 15 // 5 min → 15 min (3x)
        } else if minutes <= 30 {
            return Int(Double(minutes) * 1.5) // 1.5x buffer
        } else {
            return Int(Double(minutes) * 2.0) // 2x for longer tasks
        }
    }

    // ADHD-Specific: Match task energy to time of day
    func suggestEnergy(for task: TGTask, at time: Date) -> EnergyLevel {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)

        // Peak focus: 9am-12pm
        if hour >= 9 && hour < 12 {
            return .high
        }
        // Low energy: 2pm-4pm
        else if hour >= 14 && hour < 16 {
            return .low
        }
        // Medium otherwise
        else {
            return .medium
        }
    }
}
```

### StrategyService
Create `Core/Services/StrategyService.swift`:

```swift
import Foundation

protocol StrategyServiceProtocol {
    func getStrategies(for problemType: String, limit: Int) async throws -> [TGStrategy]
    func recordOutcome(strategy: TGStrategy, result: StrategyResult, context: StrategyContext) async throws
    func getTopStrategies(limit: Int) async throws -> [TGStrategy]
    func searchStrategies(query: String) async throws -> [TGStrategy]
}

struct StrategyContext {
    let problemType: String
    let taskType: String
    let taskTitle: String
    let notes: String?
}

final class StrategyService: StrategyServiceProtocol {
    private let strategyRepository: StrategyRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        strategyRepository: StrategyRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.strategyRepository = strategyRepository
        self.settingsRepository = settingsRepository
    }

    func getStrategies(for problemType: String, limit: Int = 5) async throws -> [TGStrategy] {
        guard let repo = strategyRepository as? StrategyRepository else { return [] }
        return try await repo.fetchTopStrategies(forProblem: problemType, limit: limit)
    }

    func recordOutcome(strategy: TGStrategy, result: StrategyResult, context: StrategyContext) async throws {
        guard let repo = strategyRepository as? StrategyRepository else { return }
        try await repo.recordOutcome(
            strategy: strategy,
            result: result,
            problemType: context.problemType,
            taskType: context.taskType,
            taskTitle: context.taskTitle,
            notes: context.notes
        )
    }

    func getTopStrategies(limit: Int = 10) async throws -> [TGStrategy] {
        let all = try await strategyRepository.fetchAll()
        // Sort by usage count as simple heuristic
        return Array(all.sorted { $0.usageCount > $1.usageCount }.prefix(limit))
    }

    func searchStrategies(query: String) async throws -> [TGStrategy] {
        let all = try await strategyRepository.fetchAll()
        let lowercaseQuery = query.lowercased()
        return all.filter {
            $0.name?.lowercased().contains(lowercaseQuery) == true ||
            $0.strategyDescription?.lowercased().contains(lowercaseQuery) == true
        }
    }
}
```

### ScheduleService
Create `Core/Services/ScheduleService.swift`:

```swift
import Foundation

protocol ScheduleServiceProtocol {
    func getSchedule(for date: Date) async throws -> DaySchedule
    func scheduleTask(_ task: TGTask, at time: Date) async throws
    func detectOverruns() async throws -> [TaskOverrun]
    func cascadeTasks(after task: TGTask, by minutes: Int) async throws
}

struct DaySchedule {
    let date: Date
    let tasks: [TGTask]
    let focusMode: TGFocusMode?
    let isWorkDay: Bool
}

struct TaskOverrun {
    let task: TGTask
    let minutesOver: Int
    let scheduledEnd: Date
}

final class ScheduleService: ScheduleServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.settingsRepository = settingsRepository
    }

    func getSchedule(for date: Date) async throws -> DaySchedule {
        guard let taskRepo = taskRepository as? TaskRepository else {
            return DaySchedule(date: date, tasks: [], focusMode: nil, isWorkDay: false)
        }

        let tasks = try await taskRepo.fetchScheduled(for: date)
        let settings = try await settingsRepository.getSettings()
        let schedule = settings.schedule

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayName = calendar.weekdaySymbols[weekday - 1].lowercased()
        let isWorkDay = schedule.workDays.contains(weekdayName)

        return DaySchedule(
            date: date,
            tasks: tasks,
            focusMode: nil, // TODO: Determine active focus mode
            isWorkDay: isWorkDay
        )
    }

    func scheduleTask(_ task: TGTask, at time: Date) async throws {
        let calendar = Calendar.current
        task.scheduledDate = calendar.startOfDay(for: time)
        task.scheduledTime = time
        task.updatedAt = Date()
        try await taskRepository.save()
    }

    func detectOverruns() async throws -> [TaskOverrun] {
        let today = try await getSchedule(for: Date())
        let now = Date()
        var overruns: [TaskOverrun] = []

        for task in today.tasks {
            guard let scheduledTime = task.scheduledTime,
                  task.statusEnum == .inProgress else { continue }

            let duration = Int(task.estimatedDuration)
            let expectedEnd = scheduledTime.addingTimeInterval(TimeInterval(duration * 60))

            if now > expectedEnd {
                let minutesOver = Int(now.timeIntervalSince(expectedEnd) / 60)
                overruns.append(TaskOverrun(
                    task: task,
                    minutesOver: minutesOver,
                    scheduledEnd: expectedEnd
                ))
            }
        }

        return overruns
    }

    func cascadeTasks(after task: TGTask, by minutes: Int) async throws {
        guard let taskRepo = taskRepository as? TaskRepository,
              let taskDate = task.scheduledDate else { return }

        let tasks = try await taskRepo.fetchScheduled(for: taskDate)

        // Find tasks after this one
        guard let taskTime = task.scheduledTime else { return }

        for otherTask in tasks {
            guard let otherTime = otherTask.scheduledTime,
                  otherTime > taskTime else { continue }

            // Shift forward
            otherTask.scheduledTime = otherTime.addingTimeInterval(TimeInterval(minutes * 60))
            otherTask.updatedAt = Date()
        }

        try await taskRepository.save()
    }
}
```

### SettingsService
Create `Core/Services/SettingsService.swift`:

```swift
import Foundation

protocol SettingsServiceProtocol {
    func getSettings() async throws -> TGSettings
    func updateSchedule(_ schedule: TGSettings.ScheduleConfig) async throws
    func isInPeakFocus(at time: Date) -> Bool
    func isInLowEnergy(at time: Date) -> Bool
    func isWorkDay(_ date: Date) async throws -> Bool
}

final class SettingsService: SettingsServiceProtocol {
    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    func getSettings() async throws -> TGSettings {
        try await settingsRepository.getSettings()
    }

    func updateSchedule(_ schedule: TGSettings.ScheduleConfig) async throws {
        try await settingsRepository.updateSettings { settings in
            settings.schedule = schedule
        }
    }

    func isInPeakFocus(at time: Date = Date()) -> Bool {
        // Simplified - would read from settings in real implementation
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        return hour >= 9 && hour < 12
    }

    func isInLowEnergy(at time: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        return hour >= 14 && hour < 16
    }

    func isWorkDay(_ date: Date) async throws -> Bool {
        let settings = try await getSettings()
        let schedule = settings.schedule

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let weekdayName = calendar.weekdaySymbols[weekday - 1].lowercased()

        return schedule.workDays.contains(weekdayName)
    }
}
```

## Files to Create
- `Tangentle/Core/Services/TaskService.swift`
- `Tangentle/Core/Services/StrategyService.swift`
- `Tangentle/Core/Services/ScheduleService.swift`
- `Tangentle/Core/Services/SettingsService.swift`

## Files to Modify
- `Tangentle/Core/DI/AppContainer.swift` - Wire in services

## Patterns to Follow
- Services depend on repository protocols, not concrete types
- Keep services focused on specific domains
- Use async/await throughout
- Include ADHD-specific business logic

## Acceptance Criteria
- [ ] All 4 services created with protocols
- [ ] TaskService implements ADHD-specific helpers
- [ ] StrategyService implements scoring retrieval
- [ ] ScheduleService handles cascade logic
- [ ] Services wired into DI container
- [ ] Project builds without warnings

## Verification Commands
```bash
# Build to verify services compile
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Check service files exist
ls -la tangentle-ios/Tangentle/Tangentle/Core/Services/
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with service layer details

## Error Recovery
If services don't compile:
1. Check protocol conformance
2. Verify async method signatures
3. Ensure repository protocols match

## Do NOT
- Put UI logic in services
- Create services with circular dependencies
- Skip protocol definitions (needed for testing)
- Access repositories not injected via constructor
