# Step 9: AI Service Protocol

## Context
Tangentle uses AI for two purposes: Claude for coaching conversations and Gemini for task prioritization. We define a protocol-based architecture that abstracts the AI provider, enabling easy testing and provider switching.

## Goal
Create AI service protocol with implementations for Claude (coaching) and Gemini (scheduling), plus a mock for testing.

## Prerequisites
- Step 8 completed (Service layer exists)
- Claude API key available

## High-Level Steps
1. Define AIService protocol
2. Create Claude implementation for coaching
3. Create Gemini implementation for scheduling (stub)
4. Create mock implementation for testing
5. Wire into DI container

## Detailed Requirements

### AI Service Protocol
Create `Core/Services/AI/AIServiceProtocol.swift`:

```swift
import Foundation

/// Context for AI coaching requests
struct AIContext {
    let task: TGTask?
    let problemType: String?
    let recentStrategies: [TGStrategy]
    let userProfile: UserProfile

    struct UserProfile {
        let peakFocusWindow: String
        let preferredTaskSize: String
        let lowEnergyPeriod: String
        let medicationTiming: String
    }
}

/// Result of AI coaching
struct CoachingResponse {
    let message: String
    let suggestedStrategies: [String]
    let followUpQuestions: [String]
}

/// Result of AI prioritization
struct PrioritizationResult {
    let tasks: [TGTask]
    let reasoning: String?
}

/// Protocol for AI services
protocol AIServiceProtocol {
    /// Check if AI is available
    var isAvailable: Bool { get }

    /// Get coaching advice for a problem
    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> CoachingResponse

    /// Have a coaching conversation
    func chat(message: String, context: AIContext) async throws -> CoachingResponse

    /// Prioritize tasks for the day
    func prioritizeTasks(_ tasks: [TGTask], for date: Date) async throws -> PrioritizationResult

    /// Break down a large task
    func breakDownTask(_ task: TGTask) async throws -> [String]
}
```

### Claude Coaching Service
Create `Core/Services/AI/ClaudeCoachingService.swift`:

```swift
import Foundation

/// Claude API client for coaching conversations
final class ClaudeCoachingService {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-20250514"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    var isAvailable: Bool {
        !apiKey.isEmpty
    }

    func sendMessage(system: String, userMessage: String) async throws -> String {
        guard isAvailable else {
            throw AIError.notConfigured
        }

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 500,
            "system": system,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.requestFailed
        }

        let result = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        return result.content.first?.text ?? ""
    }

    private struct ClaudeResponse: Codable {
        let content: [ContentBlock]

        struct ContentBlock: Codable {
            let text: String
        }
    }
}

enum AIError: Error, LocalizedError {
    case notConfigured
    case requestFailed
    case invalidResponse
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "AI service not configured"
        case .requestFailed: return "AI request failed"
        case .invalidResponse: return "Invalid AI response"
        case .rateLimited: return "AI rate limit exceeded"
        }
    }
}
```

### Composite AI Service
Create `Core/Services/AI/AIService.swift`:

```swift
import Foundation

/// Main AI service that combines Claude and Gemini
final class AIService: AIServiceProtocol {
    private let claudeService: ClaudeCoachingService?
    private let strategyService: StrategyServiceProtocol

    var isAvailable: Bool {
        claudeService?.isAvailable ?? false
    }

    init(strategyService: StrategyServiceProtocol) {
        // Get API key from environment or secure storage
        if let apiKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"],
           !apiKey.isEmpty {
            self.claudeService = ClaudeCoachingService(apiKey: apiKey)
        } else {
            self.claudeService = nil
        }
        self.strategyService = strategyService
    }

    /// For testing with injected client
    init(claudeService: ClaudeCoachingService?, strategyService: StrategyServiceProtocol) {
        self.claudeService = claudeService
        self.strategyService = strategyService
    }

    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        let systemPrompt = buildSystemPrompt(context: context)
        let userMessage = "I'm struggling with a task because it feels \(problemType). What strategy should I try?"

        if let claude = claudeService {
            let response = try await claude.sendMessage(system: systemPrompt, userMessage: userMessage)
            return CoachingResponse(
                message: response,
                suggestedStrategies: context.recentStrategies.map { $0.name ?? "" },
                followUpQuestions: []
            )
        } else {
            // Fallback to local strategies
            return try await getLocalAdvice(for: problemType, context: context)
        }
    }

    func chat(message: String, context: AIContext) async throws -> CoachingResponse {
        guard let claude = claudeService else {
            return CoachingResponse(
                message: "AI coaching unavailable. Try one of these strategies: \(context.recentStrategies.map { $0.name ?? "" }.joined(separator: ", "))",
                suggestedStrategies: [],
                followUpQuestions: []
            )
        }

        let systemPrompt = buildSystemPrompt(context: context)
        let response = try await claude.sendMessage(system: systemPrompt, userMessage: message)

        return CoachingResponse(
            message: response,
            suggestedStrategies: [],
            followUpQuestions: []
        )
    }

    func prioritizeTasks(_ tasks: [TGTask], for date: Date) async throws -> PrioritizationResult {
        // TODO: Implement Gemini integration
        // For now, sort by priority and due date
        let sorted = tasks.sorted { t1, t2 in
            if t1.priority != t2.priority {
                return t1.priority > t2.priority
            }
            if let d1 = t1.dueDate, let d2 = t2.dueDate {
                return d1 < d2
            }
            return t1.dueDate != nil
        }

        return PrioritizationResult(tasks: sorted, reasoning: "Sorted by priority and due date")
    }

    func breakDownTask(_ task: TGTask) async throws -> [String] {
        guard let claude = claudeService else {
            // Default breakdown
            return [
                "Review what needs to be done",
                "Identify first small action",
                "Complete first action",
                "Move to next step"
            ]
        }

        let prompt = """
        Break down this task into 3-5 small, actionable steps (each 15 minutes or less):
        Task: \(task.title ?? "Unknown")
        \(task.taskDescription.map { "Description: \($0)" } ?? "")

        Return only the steps, one per line, no numbering.
        """

        let response = try await claude.sendMessage(
            system: "You help break down tasks into small, ADHD-friendly steps. Keep each step under 15 minutes. Be specific and actionable.",
            userMessage: prompt
        )

        return response.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    // MARK: - Private

    private func buildSystemPrompt(context: AIContext) -> String {
        """
        You are an ADHD-aware strategy coach. Be supportive, direct, and practical.

        ## YOUR ROLE
        - Help understand WHY tasks feel hard
        - Suggest strategies based on what's worked before
        - Keep responses SHORT (ADHD = limited working memory)
        - End with a clear question or next step

        ## USER PROFILE
        - Peak focus: \(context.userProfile.peakFocusWindow)
        - Preferred tasks: \(context.userProfile.preferredTaskSize)
        - Energy dips: \(context.userProfile.lowEnergyPeriod)
        - Medication: \(context.userProfile.medicationTiming)

        ## STRATEGIES THAT HAVE WORKED
        \(context.recentStrategies.map { "- \($0.name ?? ""): \($0.strategyDescription ?? "")" }.joined(separator: "\n"))

        ## GUIDELINES
        1. ONE question at a time
        2. Explain WHY a strategy might help
        3. Keep responses under 200 words
        4. Use bullet points and bold for key points
        """
    }

    private func getLocalAdvice(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        let strategies = try await strategyService.getStrategies(for: problemType, limit: 3)

        let message: String
        if let top = strategies.first {
            message = """
            **Try: \(top.name ?? "Unknown")**

            \(top.strategyDescription ?? "")

            \(strategies.count > 1 ? "Other options: \(strategies.dropFirst().compactMap { $0.name }.joined(separator: ", "))" : "")
            """
        } else {
            message = "Break the task into the smallest possible first step. Just focus on that one step."
        }

        return CoachingResponse(
            message: message,
            suggestedStrategies: strategies.compactMap { $0.name },
            followUpQuestions: ["What's making this feel hard?", "Want to try a 2-minute version?"]
        )
    }
}
```

### Mock AI Service (for testing)
Create `Core/Services/AI/MockAIService.swift`:

```swift
import Foundation

/// Mock AI service for testing and previews
final class MockAIService: AIServiceProtocol {
    var isAvailable: Bool { true }

    var mockCoachingResponse: CoachingResponse?
    var mockPrioritization: PrioritizationResult?
    var mockBreakdown: [String]?

    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        mockCoachingResponse ?? CoachingResponse(
            message: "Try the 2-minute version: commit to just 2 minutes of work.",
            suggestedStrategies: ["2-Minute Version", "First Step Only"],
            followUpQuestions: ["What's the very first step?"]
        )
    }

    func chat(message: String, context: AIContext) async throws -> CoachingResponse {
        mockCoachingResponse ?? CoachingResponse(
            message: "That's a great observation. \(message)",
            suggestedStrategies: [],
            followUpQuestions: []
        )
    }

    func prioritizeTasks(_ tasks: [TGTask], for date: Date) async throws -> PrioritizationResult {
        mockPrioritization ?? PrioritizationResult(tasks: tasks, reasoning: "Mock prioritization")
    }

    func breakDownTask(_ task: TGTask) async throws -> [String] {
        mockBreakdown ?? [
            "Open the file/document",
            "Read for 2 minutes",
            "Write one sentence",
            "Review what you wrote"
        ]
    }
}
```

## Files to Create
- `Tangentle/Core/Services/AI/AIServiceProtocol.swift`
- `Tangentle/Core/Services/AI/ClaudeCoachingService.swift`
- `Tangentle/Core/Services/AI/AIService.swift`
- `Tangentle/Core/Services/AI/MockAIService.swift`

## Files to Modify
- `Tangentle/Core/DI/AppContainer.swift` - Wire in AI service

## Patterns to Follow
- Protocol-first design for testability
- Graceful fallback when AI unavailable
- Keep API keys secure (environment/keychain)
- Async/await for all network calls

## Acceptance Criteria
- [ ] AIServiceProtocol defines all AI operations
- [ ] ClaudeCoachingService makes real API calls
- [ ] AIService combines Claude with fallback logic
- [ ] MockAIService enables testing
- [ ] Services wired into DI container
- [ ] Project builds without warnings

## Verification Commands
```bash
# Build to verify AI services compile
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Check files exist
ls -la tangentle-ios/Tangentle/Tangentle/Core/Services/AI/
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with AI service architecture

## Error Recovery
If API calls fail:
1. Check API key is set correctly
2. Verify network connectivity
3. Check Claude API status
4. Fall back to local strategies

## Do NOT
- Hardcode API keys in source code
- Skip the fallback logic
- Make synchronous network calls
- Forget error handling for rate limits
