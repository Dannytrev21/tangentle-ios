import Foundation
import CoreData

/// Service to seed default data on first launch
final class SeedDataService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func seedIfNeeded() async throws {
        let strategyCount = try await countStrategies()
        if strategyCount > 0 {
            return // Already seeded
        }

        try await seedStrategies()
        try await seedProblemTypes()
        try await seedFocusModes()
        try await seedSettings()

        try await context.perform {
            try self.context.save()
        }
    }

    private func countStrategies() async throws -> Int {
        try await context.perform {
            let request = TGStrategy.fetchRequest()
            return try self.context.count(for: request)
        }
    }

    // MARK: - Strategies

    private func seedStrategies() async throws {
        try await context.perform {
            for def in Self.defaultStrategies {
                let strategy = TGStrategy(context: self.context)
                strategy.id = UUID()
                strategy.name = def.name
                strategy.strategyDescription = def.description
                strategy.problemTypes = def.problemTypes
                strategy.taskTypes = def.taskTypes
                strategy.tags = def.tags
                strategy.tweaks = def.tweaks
                strategy.source = "default"
                strategy.isActive = true
                strategy.usageCount = 0
                strategy.createdAt = Date()
                strategy.updatedAt = Date()
            }
        }
    }

    static let defaultStrategies: [(name: String, description: String, problemTypes: [String], taskTypes: [String], tags: [String], tweaks: [String])] = [
        (
            name: "2-Minute Version",
            description: "Commit to working on the task for just 2 minutes. Often, starting is the hardest part, and once you begin, momentum takes over.",
            problemTypes: ["too_big", "scary", "boring"],
            taskTypes: ["all"],
            tags: ["quick-start", "momentum", "low-commitment"],
            tweaks: ["Physical timer > phone timer", "Do the worst 2 minutes first"]
        ),
        (
            name: "First Step Only",
            description: "Identify the absolute first physical action needed. Don't think about step 2 - just do step 1.",
            problemTypes: ["too_big", "overwhelmed", "unclear"],
            taskTypes: ["all"],
            tags: ["clarity", "focus", "simplify"],
            tweaks: ["Write the step down", "Make it embarrassingly small"]
        ),
        (
            name: "Break It Down Further",
            description: "If a task feels overwhelming, it's probably too big. Split it into 5-10 minute chunks until each piece feels manageable.",
            problemTypes: ["too_big", "overwhelmed"],
            taskTypes: ["all"],
            tags: ["planning", "chunking"],
            tweaks: ["Use bullet points", "Time-box each chunk"]
        ),
        (
            name: "Define 'Done' First",
            description: "Before starting, write down exactly what 'done' looks like. What's the specific deliverable? What makes it complete?",
            problemTypes: ["unclear", "scary"],
            taskTypes: ["all"],
            tags: ["clarity", "planning"],
            tweaks: ["Be very specific", "Include quality bar"]
        ),
        (
            name: "Body Doubling",
            description: "Work alongside someone else (in-person or video call). Their presence helps maintain focus and accountability.",
            problemTypes: ["boring", "distracted"],
            taskTypes: ["all"],
            tags: ["social", "accountability"],
            tweaks: ["Focusmate.com for strangers", "Silent co-working works too"]
        ),
        (
            name: "Reward After",
            description: "Set up a specific reward you'll get immediately after completing the task. Make it something you actually want.",
            problemTypes: ["boring", "low_energy"],
            taskTypes: ["all"],
            tags: ["motivation", "incentive"],
            tweaks: ["Reward should be immediate", "Match reward size to task"]
        ),
        (
            name: "Permission to Suck",
            description: "Give yourself explicit permission to do the task badly. A bad first draft beats no draft. Lower the bar to just 'exists'.",
            problemTypes: ["scary", "unclear"],
            taskTypes: ["all"],
            tags: ["perfectionism", "lower-bar"],
            tweaks: ["Say it out loud", "Embrace crappy first versions"]
        ),
        (
            name: "Brain Dump First",
            description: "Before starting, spend 5 minutes writing down everything on your mind. Clear the mental clutter so you can focus.",
            problemTypes: ["distracted", "overwhelmed"],
            taskTypes: ["all"],
            tags: ["clarity", "mental-reset"],
            tweaks: ["Paper > digital", "Don't organize, just dump"]
        ),
        (
            name: "Phone in Another Room",
            description: "Physically remove your phone from your workspace. Put it in another room or give it to someone else.",
            problemTypes: ["distracted"],
            taskTypes: ["all"],
            tags: ["environment", "focus"],
            tweaks: ["Lock it in drawer", "Use app blockers as backup"]
        ),
        (
            name: "Pomodoro (25/5)",
            description: "Work for 25 minutes, then take a 5-minute break. Repeat. The timer creates artificial urgency and built-in breaks.",
            problemTypes: ["too_big", "boring", "distracted"],
            taskTypes: ["all"],
            tags: ["time-boxing", "structure"],
            tweaks: ["Use physical timer", "Actually take the breaks"]
        ),
        (
            name: "Shorter Pomodoro (10/2)",
            description: "Work for 10 minutes, break for 2. Better for high-resistance tasks or low-energy days.",
            problemTypes: ["too_big", "low_energy", "boring"],
            taskTypes: ["all"],
            tags: ["time-boxing", "low-energy"],
            tweaks: ["Good for starting", "Increase time as you warm up"]
        ),
        (
            name: "Basic Needs Check",
            description: "Before forcing yourself: Have you eaten? Hydrated? Slept? Sometimes 'lazy' is actually depleted.",
            problemTypes: ["low_energy"],
            taskTypes: ["all"],
            tags: ["self-care", "energy"],
            tweaks: ["Snack + water first", "5-minute walk"]
        ),
        (
            name: "Match Energy to Task",
            description: "If energy is low, do a low-energy task instead. Save high-focus work for high-energy times.",
            problemTypes: ["low_energy", "overwhelmed"],
            taskTypes: ["all"],
            tags: ["energy-management", "scheduling"],
            tweaks: ["Make a low-energy task list", "Know your peak hours"]
        ),
        (
            name: "Ruthless Triage",
            description: "When overwhelmed, pick ONE thing that matters most. Deliberately ignore everything else for now.",
            problemTypes: ["overwhelmed"],
            taskTypes: ["all"],
            tags: ["prioritization", "focus"],
            tweaks: ["Write 'NOT TODAY' on others", "Only one priority"]
        ),
        (
            name: "Unblock It",
            description: "Identify the specific blocker. Is it information, a decision, another person? Address that one thing first.",
            problemTypes: ["blocked"],
            taskTypes: ["all"],
            tags: ["problem-solving", "clarity"],
            tweaks: ["Ask for help", "Make a partial decision"]
        ),
        (
            name: "Work Around the Block",
            description: "If blocked on part A, start on part B. Progress on anything related builds momentum.",
            problemTypes: ["blocked"],
            taskTypes: ["all"],
            tags: ["flexibility", "momentum"],
            tweaks: ["Find the unblocked piece", "Document what you can"]
        ),
        (
            name: "Change Environment",
            description: "Move to a different room, café, or outdoor space. Novel environments can reset focus.",
            problemTypes: ["distracted", "boring", "low_energy"],
            taskTypes: ["all"],
            tags: ["environment", "novelty"],
            tweaks: ["Library = focus mode", "Coffee shop for energy"]
        ),
        (
            name: "Accountability Partner",
            description: "Tell someone specific what you'll do and when. Check in with them after.",
            problemTypes: ["scary", "boring"],
            taskTypes: ["all"],
            tags: ["social", "accountability"],
            tweaks: ["Be specific about deliverable", "Daily check-ins work best"]
        )
    ]

    // MARK: - Problem Types

    private func seedProblemTypes() async throws {
        try await context.perform {
            for (index, def) in Self.defaultProblemTypes.enumerated() {
                let type = TGProblemType(context: self.context)
                type.id = UUID()
                type.identifier = def.id
                type.label = def.label
                type.problemTypeDescription = def.description
                type.isDefault = true
                type.sortOrder = Int32(index)
            }
        }
    }

    static let defaultProblemTypes: [(id: String, label: String, description: String)] = [
        ("too_big", "Too Big", "Task feels overwhelming or too large to start"),
        ("unclear", "Unclear", "Not sure how to approach or what to do"),
        ("boring", "Boring", "Task is tedious and uninteresting"),
        ("scary", "Scary", "Worried about failure or doing it wrong"),
        ("blocked", "Blocked", "Waiting on something or someone"),
        ("distracted", "Distracted", "Mind keeps wandering to other things"),
        ("low_energy", "Low Energy", "Too tired or depleted right now"),
        ("overwhelmed", "Overwhelmed", "Too many competing priorities"),
        ("forgot", "Forgot", "Simply forgot about it"),
        ("interruptions", "Interruptions", "Kept getting interrupted"),
        ("other", "Other", "Something else")
    ]

    // MARK: - Focus Modes

    private func seedFocusModes() async throws {
        try await context.perform {
            for (index, def) in Self.defaultFocusModes.enumerated() {
                let mode = TGFocusMode(context: self.context)
                mode.id = UUID()
                mode.name = def.name
                mode.focusModeDescription = def.description
                mode.isActive = true
                mode.isAutomatic = def.isAutomatic
                mode.daysOfWeek = def.days
                mode.sortOrder = Int32(index)
                mode.createdAt = Date()
                mode.updatedAt = Date()
            }
        }
    }

    static let defaultFocusModes: [(name: String, description: String, isAutomatic: Bool, days: [Int])] = [
        (
            name: "Morning",
            description: "Start of day routine and warm-up",
            isAutomatic: true,
            days: [2, 3, 4, 5, 6]  // Monday-Friday (Calendar weekday: 1=Sunday, 2=Monday...)
        ),
        (
            name: "Peak Focus",
            description: "Deep work time when medication is most effective",
            isAutomatic: true,
            days: [2, 3, 4, 5, 6]
        ),
        (
            name: "Afternoon",
            description: "Post-lunch, lower energy administrative tasks",
            isAutomatic: true,
            days: [2, 3, 4, 5, 6]
        ),
        (
            name: "Weekend",
            description: "Personal time, no work tasks",
            isAutomatic: true,
            days: [1, 7]  // Sunday, Saturday
        ),
        (
            name: "Evening Shutdown",
            description: "End of day review and planning",
            isAutomatic: true,
            days: [2, 3, 4, 5, 6]
        )
    ]

    // MARK: - Settings

    private func seedSettings() async throws {
        try await context.perform {
            let settings = TGSettings(context: self.context)
            settings.id = UUID()
            settings.schedule = .default
            settings.tasks = .default
            settings.display = .default
            settings.coaching = .default
            settings.updatedAt = Date()
        }
    }
}
