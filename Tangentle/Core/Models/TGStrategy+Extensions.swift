import Foundation
import CoreData

extension TGStrategy {
    // MARK: - Computed Properties

    var problemTypesArray: [String] {
        get { problemTypes ?? [] }
        set { problemTypes = newValue }
    }

    var taskTypesArray: [String] {
        get { taskTypes ?? [] }
        set { taskTypes = newValue }
    }

    var tagsArray: [String] {
        get { tags ?? [] }
        set { tags = newValue }
    }

    var tweaksArray: [String] {
        get { tweaks ?? [] }
        set { tweaks = newValue }
    }

    var outcomesArray: [TGStrategyOutcome] {
        let set = outcomes as? Set<TGStrategyOutcome> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }

    var linkedTasksArray: [TGTask] {
        let set = linkedTasks as? Set<TGTask> ?? []
        return Array(set)
    }

    /// Calculate strategy score based on outcomes
    /// Formula: successRate × log(attempts + 1) × recencyFactor
    var score: Double {
        let outcomesList = outcomesArray
        guard !outcomesList.isEmpty else { return 0 }

        // Calculate success rate
        let successPoints = outcomesList.reduce(0) { sum, outcome in
            sum + (OutcomeResult(rawValue: outcome.result ?? "") ?? .failure).scoreValue
        }
        let maxPossiblePoints = outcomesList.count * 3
        let successRate = Double(successPoints) / Double(maxPossiblePoints)

        // Apply attempt multiplier (log scale)
        let attemptMultiplier = log(Double(outcomesList.count) + 1) + 1

        // Apply recency factor (recent outcomes weighted more)
        let recencyFactor = calculateRecencyFactor(outcomes: outcomesList)

        return successRate * attemptMultiplier * recencyFactor
    }

    var successRate: Double {
        let outcomesList = outcomesArray
        guard !outcomesList.isEmpty else { return 0 }

        let successCount = outcomesList.filter { $0.result == OutcomeResult.success.rawValue }.count
        return Double(successCount) / Double(outcomesList.count)
    }

    // MARK: - Private Methods

    private func calculateRecencyFactor(outcomes: [TGStrategyOutcome]) -> Double {
        guard let mostRecent = outcomes.first?.date else { return 1.0 }
        let daysSinceLastUse = Calendar.current.dateComponents(
            [.day],
            from: mostRecent,
            to: Date()
        ).day ?? 0

        // Decay factor: 1.0 for today, decreasing over 30 days to 0.5
        return max(0.5, 1.0 - (Double(daysSinceLastUse) / 60.0))
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        description: String,
        problemTypes: [String],
        source: String = "user"
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.strategyDescription = description
        self.problemTypesArray = problemTypes
        self.taskTypesArray = ["all"]
        self.source = source
        self.isActive = true
        self.usageCount = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func recordOutcome(
        result: OutcomeResult,
        problemType: String,
        taskTitle: String,
        taskType: String = "all",
        notes: String? = nil
    ) {
        guard let context = managedObjectContext else { return }

        let outcome = TGStrategyOutcome(context: context)
        outcome.id = UUID()
        outcome.strategy = self
        outcome.date = Date()
        outcome.result = result.rawValue
        outcome.problemType = problemType
        outcome.taskType = taskType
        outcome.taskTitle = taskTitle
        outcome.notes = notes

        usageCount += 1
        updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGStrategyOutcome Extension

extension TGStrategyOutcome {
    var outcomeResult: OutcomeResult {
        get { OutcomeResult(rawValue: result ?? "failure") ?? .failure }
        set { result = newValue.rawValue }
    }

    convenience init(
        context: NSManagedObjectContext,
        strategy: TGStrategy,
        result: OutcomeResult,
        problemType: String,
        taskTitle: String
    ) {
        self.init(context: context)
        self.id = UUID()
        self.strategy = strategy
        self.date = Date()
        self.outcomeResult = result
        self.problemType = problemType
        self.taskType = "all"
        self.taskTitle = taskTitle
    }
}
