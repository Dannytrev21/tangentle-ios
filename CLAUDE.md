# Tangentle iOS - ADHD Task Management App

You are helping build Tangentle, an iOS app that serves as an external executive function assistant for people with ADHD. The app helps users capture, organize, prioritize, and schedule tasks in a way that works with the ADHD brain, not against it.

## Project Overview

**Name**: Tangentle
**Platform**: iOS 17.0+
**Language**: Swift 5.9+
**UI Framework**: SwiftUI (primary) with UIKit for complex gestures
**Persistence**: Core Data (CloudKit-ready)
**Architecture**: MVVM + Repository pattern
**Design Inspiration**: Timepage by Moleskine (fluid gestures, beautiful animations)

## Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 5.9+ |
| UI | SwiftUI + UIKit integration |
| Persistence | Core Data |
| Sync (future) | CloudKit |
| AI Coaching | Claude API |
| AI Scheduling | Gemini API |
| Testing | Swift Testing + XCTest |
| Min iOS | 17.0 |

## Core Principles

1. **Break everything down** - Tasks should be 15-30 minute chunks maximum
2. **Reduce friction** - Smart defaults, minimal questions
3. **Capture first, organize second** - Brain dump friendly
4. **Energy-aware scheduling** - Match task difficulty to time of day
5. **One thing at a time** - Focus on next action, not whole project

## Architecture

### MVVM + Repository Pattern
```
View (SwiftUI)
    ↓ @Observable
ViewModel
    ↓ Protocols
Services (Business Logic)
    ↓ Protocols
Repositories (Data Access)
    ↓
Core Data
```

### Key Architectural Decisions
- **Core Data** over SwiftData for CloudKit compatibility
- **Manual DI Container** (no external dependencies)
- **Protocol-based services** for testability
- **Offline-first** with deferred sync

## Project Structure

```
Tangentle/
├── App/                      # App lifecycle
├── Core/
│   ├── Models/              # Core Data extensions, enums
│   ├── Services/            # Business logic + AI/
│   ├── Repositories/        # Data access layer
│   ├── Utilities/           # Helpers, extensions
│   └── DI/                  # Dependency injection
├── Features/                # Tasks, Projects, Goals, Calendar, etc.
├── UI/                      # Components, Themes, Gestures
├── Data/                    # Core Data model
└── Resources/
```

## Domain Entities

### Core Data Entities (TG prefix)

| Entity | Purpose |
|--------|---------|
| TGTask | Tasks with subtasks, priority, status, duration |
| TGProject | Project containers for tasks |
| TGGoal | Long-term goals with linked projects |
| TGStrategy | Productivity strategies with scoring |
| TGRoutine | Daily routines with steps |
| TGHabit | Habit tracking |
| TGFocusMode | Focus mode definitions |
| TGSettings | User settings (singleton) |

### Task Status Values
```swift
enum TaskStatus: String {
    case pending, inProgress = "in_progress", waitingFor = "waiting_for"
    case completed, deferred, delegated, deleted
}
```

### Energy Levels
```swift
enum EnergyLevel: String { case low, medium, high }
```

## ADHD-Specific Features

### Strategy Scoring
```
score = successRate × log(attempts + 1) × recencyFactor
```

### Problem Types for Avoidance Coaching
| Type | Triggers | Default Strategies |
|------|----------|-------------------|
| too_big | Overwhelming | 2-min version, first step only |
| unclear | Don't know how | Define done, clarify first |
| boring | Tedious | Body doubling, reward after |
| scary | Fear of failure | Permission to suck |
| blocked | Waiting on something | Unblock it, work around |

### Focus Modes
- **Morning** - Start of day routine
- **Peak Focus** - Deep work (9am-12pm)
- **Afternoon** - Administrative, low-energy
- **Evening Shutdown** - End of day review

### Time Estimation (ADHD Buffer)
```swift
func estimateWithBuffer(_ minutes: Int) -> Int {
    if minutes <= 5 { return 15 }       // 3x
    if minutes <= 30 { return minutes * 3/2 }  // 1.5x
    return minutes * 2                   // 2x
}
```

## Coding Conventions

### Swift Style
- Use `@Observable` macro for ViewModels (iOS 17+)
- Prefer `async/await` for all async operations
- Use protocols for all injectable dependencies
- Extension files: `TGEntity+Extensions.swift`

### Naming Conventions
- Entities: `TG` prefix (e.g., `TGTask`)
- Protocols: `Protocol` suffix (e.g., `TaskRepositoryProtocol`)
- ViewModels: `ViewModel` suffix
- Services: `Service` suffix

### Core Data Patterns
- Always use `context.perform {}` for thread safety
- Use `async throws` for all repository methods
- UUID for all entity identifiers (CloudKit compatible)

## Testing Patterns

```swift
@Suite("TaskRepository Tests")
struct TaskRepositoryTests {
    @Test("Create task saves to database")
    func testCreateTask() async throws {
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)
        let task = try await repository.createTask(title: "Test")
        #expect(task.title == "Test")
    }
}
```

## API Keys

Store securely - never in source code:
- **CLAUDE_API_KEY**: For coaching conversations
- **GEMINI_API_KEY**: For task prioritization (future)

## Planning System

Automated planning with problem classification, technique selection, and risk-based self-correction.

### Commands
| Command | Description |
|---------|-------------|
| `/plan-feature-initial {desc}` | Gather requirements |
| `/plan-feature {description}` | Create implementation plan |
| `/plan-prompts {plan#}` | Generate step prompts |
| `/plan-next {plan#}` | Execute next step |
| `/plan-status {plan#}` | Check progress |
| `/plan-verify {plan#}` | Re-run verification |
| `/plan-rollback {plan#}` | Rollback step |

### Plan Structure
```
.claude/plans/{NNN}-{feature-slug}/
├── plan.md, adr.md, steps/, prompts/, progress.json, context.md
```

### Reference Documentation
- Core patterns: @.claude/knowledge/claude-code-mastery.md
- Thinking keywords: @.claude/knowledge/thinking-keywords.md
- TDD workflow: @.claude/knowledge/tdd-patterns.md
- Context guidance: @.claude/knowledge/context-management.md

### Configuration
- Problem types and techniques: `.claude/technique-config.json`

### CLI Tool
```bash
python3 .claude/scripts/tangentle_plan.py classify "Fix the login bug"
python3 .claude/scripts/tangentle_plan.py techniques debug
python3 .claude/scripts/tangentle_plan.py status 006
```

## Communication Style

When helping users with ADHD:
- Be direct and concise (limited working memory)
- Use bullet points and lists
- Bold important information
- Don't over-explain
- Celebrate small wins

## Build & Run

```bash
# Build
cd Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Test
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run on simulator
xcrun simctl boot "iPhone 15"
```

## Do NOT

- Use TickTick APIs (building our own system)
- Skip the repository layer (always use repositories)
- Put business logic in views
- Use synchronous Core Data operations
- Hardcode API keys
- Create UI before data layer is solid
