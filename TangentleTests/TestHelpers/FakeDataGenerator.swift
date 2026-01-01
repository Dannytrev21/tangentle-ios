import Foundation
@testable import Tangentle

/// Faker-style utility for generating test data
struct FakeData {

    // MARK: - Tasks

    static func taskTitle() -> String {
        let verbs = ["Review", "Complete", "Write", "Update", "Fix", "Create", "Design", "Plan", "Research", "Organize"]
        let nouns = ["documentation", "feature", "bug", "report", "presentation", "email", "code", "tests", "design", "meeting notes"]
        return "\(verbs.randomElement()!) \(nouns.randomElement()!)"
    }

    static func taskDescription() -> String {
        let descriptions = [
            "This task needs to be completed as soon as possible.",
            "Important task for the project deadline.",
            "Follow up from yesterday's meeting.",
            "Part of the sprint goals.",
            "Quick task that should take minimal effort."
        ]
        return descriptions.randomElement()!
    }

    // MARK: - Projects

    static func projectName() -> String {
        let adjectives = ["Personal", "Work", "Home", "Side", "Main", "Important", "Urgent"]
        let nouns = ["Project", "Initiative", "Task List", "Goal", "Plan"]
        return "\(adjectives.randomElement()!) \(nouns.randomElement()!)"
    }

    static func emoji() -> String {
        let emojis = ["📝", "🎯", "💼", "🏠", "⭐️", "🚀", "💡", "📊", "🔧", "📚"]
        return emojis.randomElement()!
    }

    // MARK: - Dates

    static func pastDate(within days: Int = 30) -> Date {
        let randomDays = Int.random(in: 1...days)
        return Calendar.current.date(byAdding: .day, value: -randomDays, to: Date())!
    }

    static func futureDate(within days: Int = 30) -> Date {
        let randomDays = Int.random(in: 1...days)
        return Calendar.current.date(byAdding: .day, value: randomDays, to: Date())!
    }

    static func dateInRange(start: Date, end: Date) -> Date {
        let interval = end.timeIntervalSince(start)
        let randomInterval = TimeInterval.random(in: 0...interval)
        return start.addingTimeInterval(randomInterval)
    }

    // MARK: - Task Properties

    static func duration() -> Int16 {
        let durations: [Int16] = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120]
        return durations.randomElement()!
    }

    static func priority() -> Priority {
        return Priority.allCases.randomElement()!
    }

    static func energyLevel() -> EnergyLevel {
        return EnergyLevel.allCases.randomElement()!
    }

    static func taskStatus() -> TaskStatus {
        return [TaskStatus.pending, .inProgress, .done].randomElement()!
    }

    // MARK: - Strategies

    static func strategyName() -> String {
        let names = [
            "2-Minute Version", "First Step Only", "Body Doubling",
            "Reward After", "Permission to Suck", "Phone Away",
            "Brain Dump", "Pomodoro", "Energy Matching"
        ]
        return names.randomElement()!
    }

    static func problemType() -> String {
        let types = ["too_big", "unclear", "boring", "scary", "blocked", "distracted", "low_energy", "overwhelmed"]
        return types.randomElement()!
    }

    // MARK: - Strings

    static func email() -> String {
        let names = ["john", "jane", "test", "user", "dev", "admin"]
        let domains = ["example.com", "test.com", "mail.com"]
        return "\(names.randomElement()!)@\(domains.randomElement()!)"
    }

    static func sentence(wordCount: Int = 10) -> String {
        let words = ["the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog", "and", "runs", "fast", "through", "forest"]
        return (0..<wordCount).map { _ in words.randomElement()! }.joined(separator: " ").capitalized + "."
    }
}
