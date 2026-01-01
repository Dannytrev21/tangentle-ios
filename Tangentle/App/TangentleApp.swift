import SwiftUI

@main
struct TangentleApp: App {
    @State private var themeManager = ThemeManager()
    @Environment(\.colorScheme) private var systemColorScheme
    private let container: DIContainer = AppContainer.shared

    /// Whether we are running in UI testing mode
    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
    }

    init() {
        if Self.isUITesting {
            setupUITesting()
        }
    }

    var body: some Scene {
        WindowGroup {
            TabBarContainer()
                .environment(\.theme, themeManager.currentTheme)
                .environment(\.themeManager, themeManager)
                .environment(\.hapticEngine, container.hapticEngine)
                .environment(\.container, container)
                .environment(\.managedObjectContext, container.viewContext)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    container.hapticEngine.prepare()
                    themeManager.updateSystemColorScheme(systemColorScheme)
                }
                .onChange(of: systemColorScheme) { _, newScheme in
                    themeManager.updateSystemColorScheme(newScheme)
                }
                .task {
                    if Self.isUITesting {
                        await Self.setupUITestData()
                    } else {
                        await Self.setupFirstLaunch()
                    }
                }
        }
    }

    // MARK: - UI Testing Setup

    private func setupUITesting() {
        // Disable animations for faster, more reliable tests
        UIView.setAnimationsEnabled(false)

        // Clear UserDefaults to ensure clean state
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }

    private static func setupUITestData() async {
        let arguments = ProcessInfo.processInfo.arguments

        // Find the test scenario argument
        let scenarioArg = arguments.first { $0.hasPrefix("-SeedData_") }
        let scenario = scenarioArg?.replacingOccurrences(of: "-SeedData_", with: "") ?? "multipleTasks"

        do {
            try await seedTestData(scenario: scenario)
        } catch {
            print("Failed to seed UI test data: \(error)")
        }
    }

    private static func seedTestData(scenario: String) async throws {
        let context = AppContainer.shared.viewContext

        switch scenario {
        case "empty":
            // Do nothing - leave database empty
            break

        case "singleTask":
            let task = TGTask(context: context)
            task.id = UUID()
            task.title = "Test Task"
            task.status = "pending"
            task.createdAt = Date()
            task.scheduledDate = Date()
            task.taskPriority = .medium
            try context.save()

        case "multipleTasks":
            for i in 1...5 {
                let task = TGTask(context: context)
                task.id = UUID()
                task.title = "Test Task \(i)"
                task.status = "pending"
                task.createdAt = Date()
                task.scheduledDate = Date()
                task.taskPriority = i == 1 ? .high : (i == 2 ? .medium : .low)
                task.estimatedDuration = Int16(15 * i)
            }
            try context.save()

        case "withOverdue":
            // Create an overdue task
            let overdueTask = TGTask(context: context)
            overdueTask.id = UUID()
            overdueTask.title = "Overdue Task"
            overdueTask.status = "pending"
            overdueTask.createdAt = Date()
            overdueTask.dueDate = Date().addingTimeInterval(-86400) // Yesterday
            overdueTask.taskPriority = .high

            // Create a today task
            let todayTask = TGTask(context: context)
            todayTask.id = UUID()
            todayTask.title = "Today Task"
            todayTask.status = "pending"
            todayTask.createdAt = Date()
            todayTask.scheduledDate = Date()
            todayTask.taskPriority = .medium

            try context.save()

        case "strategyCoaching":
            // Seed strategies and problem types for coaching flow tests
            let seedService = SeedDataService(context: context)
            try await seedService.seedIfNeeded()

        default:
            // Default to multipleTasks
            try await seedTestData(scenario: "multipleTasks")
        }
    }

    // MARK: - First Launch Setup

    private static func setupFirstLaunch() async {
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

    private static func seedDefaultData() async throws {
        let seedService = SeedDataService(context: AppContainer.shared.viewContext)
        try await seedService.seedIfNeeded()
    }
}
