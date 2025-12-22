import Foundation

/// Production AI service with stub implementations
/// Real API integration will be added in a future plan
final class AIService: AIServiceProtocol {
    private let strategyService: StrategyServiceProtocol

    init(strategyService: StrategyServiceProtocol) {
        self.strategyService = strategyService
    }

    // MARK: - Coaching (Claude - stub)

    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String {
        // Stub: Return strategy-based advice without calling API
        let strategies = context.pastStrategies
            .sorted { $0.score > $1.score }
            .prefix(3)

        if strategies.isEmpty {
            return generateDefaultAdvice(for: problemType)
        }

        let strategyNames = strategies.map { $0.name }.joined(separator: ", ")
        return "Based on what's worked for you before, try: \(strategyNames). " +
               "Remember, you just need to start - even 2 minutes counts."
    }

    func getCoachingResponse(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        let advice = try await getCoachingAdvice(for: problemType, context: context)

        let suggestedStrategies = context.pastStrategies
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0.name }

        return CoachingResponse(
            advice: advice,
            suggestedStrategies: Array(suggestedStrategies),
            followUpQuestions: [
                "Which of these strategies resonates most right now?",
                "What's making this task feel hard to start?"
            ]
        )
    }

    private func generateDefaultAdvice(for problemType: String) -> String {
        switch problemType {
        case "too_big":
            return "This task might feel overwhelming. Try the 2-minute version - just commit to 2 minutes of work. Often starting is the hardest part."
        case "unclear":
            return "Not sure where to start? Try defining 'done' first. What's the specific deliverable that would make this complete?"
        case "boring":
            return "Tedious tasks need extra motivation. Set up a specific reward for after you finish, or try body doubling with someone."
        case "scary":
            return "Fear of failure is normal. Give yourself permission to do this badly first. A bad draft beats no draft."
        case "blocked":
            return "What specifically is blocking you? Identify the one thing you're waiting on and address that first."
        case "distracted":
            return "Put your phone in another room. Do a 5-minute brain dump to clear mental clutter before starting."
        case "low_energy":
            return "Have you eaten? Hydrated? Sometimes 'lazy' is actually depleted. Take care of basic needs first."
        case "overwhelmed":
            return "Pick ONE thing that matters most right now. Deliberately ignore everything else. You can only do one thing at a time."
        case "forgot":
            return "Set a specific time and place for this task. Add it to your calendar with an alert. External memory beats internal memory."
        case "interruptions":
            return "Block out focused time on your calendar. Let others know you're unavailable. Close Slack, email, everything."
        default:
            return "Try the 2-minute version - commit to just 2 minutes of work on this task."
        }
    }

    // MARK: - Scheduling (Gemini - stub)

    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask] {
        // Stub: Sort by priority and due date
        return tasks.sorted { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority > task2.priority
            }
            if let due1 = task1.dueDate, let due2 = task2.dueDate {
                return due1 < due2
            }
            return task1.dueDate != nil
        }
    }

    func suggestSchedule(for tasks: [TGTask], settings: ScheduleSettings) async throws -> [TGTask] {
        // Stub: Simple scheduling based on energy and priority
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let peakStart = formatter.date(from: settings.peakFocusStart) else {
            return tasks
        }

        var currentTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: peakStart),
            minute: calendar.component(.minute, from: peakStart),
            second: 0,
            of: today
        )!

        // Sort: high energy/priority first (for morning)
        let sortedTasks = tasks.sorted { task1, task2 in
            let score1 = Int(task1.priority) + (task1.energy == .high ? 2 : 0)
            let score2 = Int(task2.priority) + (task2.energy == .high ? 2 : 0)
            return score1 > score2
        }

        for task in sortedTasks {
            task.scheduledDate = currentTime
            currentTime = calendar.date(
                byAdding: .minute,
                value: Int(task.estimatedDuration),
                to: currentTime
            )!
        }

        return sortedTasks
    }

    func generateSchedule(request: ScheduleRequest) async throws -> ScheduleResponse {
        // Stub: Simple time-based scheduling
        var scheduledTasks: [ScheduleResponse.ScheduledTask] = []
        var currentTime = request.date

        for task in request.tasks.sorted(by: { $0.priority > $1.priority }) {
            let reason: String?
            if task.priority >= 4 {
                reason = "High priority - scheduled during peak focus"
            } else if task.energyRequired == "high" {
                reason = "High energy task - scheduled in morning"
            } else {
                reason = nil
            }

            scheduledTasks.append(ScheduleResponse.ScheduledTask(
                taskId: task.id,
                scheduledTime: currentTime,
                reason: reason
            ))

            currentTime = Calendar.current.date(
                byAdding: .minute,
                value: task.estimatedDuration,
                to: currentTime
            )!
        }

        return ScheduleResponse(scheduledTasks: scheduledTasks)
    }
}
