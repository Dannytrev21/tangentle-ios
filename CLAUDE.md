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
│   ├── TangentleApp.swift
│   └── ContentView.swift
├── Core/
│   ├── Models/              # Core Data extensions, enums
│   ├── Services/            # Business logic
│   │   └── AI/             # Claude + Gemini integration
│   ├── Repositories/        # Data access layer
│   ├── Utilities/           # Helpers, extensions
│   └── DI/                  # Dependency injection
├── Features/
│   ├── Tasks/              # Task management
│   ├── Projects/           # Project containers
│   ├── Goals/              # Long-term goals
│   ├── Calendar/           # Calendar view
│   ├── Routines/           # Daily routines
│   ├── Habits/             # Habit tracking
│   ├── Strategies/         # ADHD strategy coaching
│   ├── FocusModes/         # Focus mode filters
│   ├── Modes/              # App configuration modes
│   └── Settings/           # User settings
├── UI/
│   ├── Components/         # Reusable components
│   ├── Themes/             # Colors, typography
│   └── Gestures/           # Custom gesture handlers
├── Data/
│   ├── Tangentle.xcdatamodeld
│   └── Persistence.swift
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
| TGStrategyOutcome | Strategy usage tracking |
| TGRoutine | Daily routines with steps |
| TGRoutineStep | Individual routine steps |
| TGHabit | Habit tracking |
| TGHabitCompletion | Habit completion records |
| TGFocusMode | Focus mode definitions |
| TGMode | App mode configurations |
| TGProblemType | Avoidance problem types |
| TGTag | Task tags |
| TGSettings | User settings (singleton) |

### Task Status Values
```swift
enum TaskStatus: String {
    case pending
    case inProgress = "in_progress"
    case waitingFor = "waiting_for"
    case completed
    case deferred
    case delegated
    case deleted
}
```

### Energy Levels
```swift
enum EnergyLevel: String {
    case low, medium, high
}
```

## ADHD-Specific Features

### Strategy Scoring System
Strategies are tracked and scored based on effectiveness:

```
score = successRate × log(attempts + 1) × recencyFactor
```

- **Success**: +1.0 to successes
- **Partial**: +0.5 to successes
- **Failure**: +0 to successes

### Problem Types for Avoidance Coaching
| Type | Triggers | Default Strategies |
|------|----------|-------------------|
| too_big | Overwhelming | 2-min version, first step only |
| unclear | Don't know how | Define done, clarify first |
| boring | Tedious | Body doubling, reward after |
| scary | Fear of failure | Permission to suck |
| blocked | Waiting on something | Unblock it, work around |
| distracted | Mind wandering | Phone away, brain dump |
| low_energy | Too tired | Basic needs check |
| overwhelmed | Too many things | Ruthless triage |

### Focus Modes
Focus modes filter tasks based on time and energy:
- **Morning** - Start of day routine
- **Peak Focus** - Deep work (9am-12pm)
- **Afternoon** - Administrative, low-energy
- **Weekend** - Personal time only
- **Evening Shutdown** - End of day review

### Time Estimation (ADHD Buffer)
Danny (and most ADHD folks) underestimates time:
```swift
func estimateWithBuffer(_ minutes: Int) -> Int {
    if minutes <= 5 { return 15 }      // 3x
    if minutes <= 30 { return minutes * 3/2 }  // 1.5x
    return minutes * 2                  // 2x
}
```

## Coding Conventions

### Swift Style
- Use `@Observable` macro for ViewModels (iOS 17+)
- Prefer `async/await` for all async operations
- Use protocols for all injectable dependencies
- Extension files named: `TGEntity+Extensions.swift`
- Group imports: Foundation, SwiftUI, Core Data, then local

### Naming Conventions
- Entities: `TG` prefix (e.g., `TGTask`)
- Protocols: `Protocol` suffix (e.g., `TaskRepositoryProtocol`)
- ViewModels: `ViewModel` suffix (e.g., `TodayViewModel`)
- Services: `Service` suffix (e.g., `TaskService`)

### File Organization
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Protocol Conformance
```

### Core Data Patterns
- Always use `context.perform {}` for thread safety
- Use `async throws` for all repository methods
- UUID for all entity identifiers (CloudKit compatible)
- `Transformable` with `NSSecureUnarchiveFromData` for arrays

## Testing Patterns

### Unit Tests (Swift Testing)
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

### In-Memory Core Data for Tests
```swift
final class TestCoreDataStack {
    static func createInMemory() -> NSManagedObjectContext {
        PersistenceController(inMemory: true).viewContext
    }
}
```

## API Keys

Store securely - never in source code:
- **CLAUDE_API_KEY**: For coaching conversations
- **GEMINI_API_KEY**: For task prioritization (future)

## Automated Planning System

This project uses an automated planning system for complex features.

### Commands
| Command | Description |
|---------|-------------|
| `/plan-feature-initial {desc}` | Gather requirements (auto-detects problem type) |
| `/plan-feature {description}` | Create full implementation plan |
| `/plan-prompts {plan#}` | Generate AI prompts for steps |
| `/plan-next {plan#}` | Execute next step (phase-based) |
| `/plan-status {plan#}` | Check progress |
| `/plan-verify {plan#}` | Re-run verification (technique-aware) |
| `/plan-rollback {plan#}` | Rollback step (preserves memory bank) |
| `/plan-feature-review {plan#}` | Review plan quality |

### Plan Structure
```
.claude/plans/{NNN}-{feature-slug}/
├── plan.md           # Main plan with technique matrix
├── adr.md            # Architecture Decision Record
├── steps/            # Step specifications (with techniques)
├── prompts/          # AI prompts (technique-embedded)
├── progress.json     # Progress tracking (with technique metadata)
└── context.md        # Session context
```

## Intelligent Planning System v2

The planning system automatically selects optimal prompt engineering techniques based on problem type and workflow phase.

### Problem Type Taxonomy

| Category | Problem Types |
|----------|---------------|
| FOUNDATION | infrastructure, scaffolding, configuration |
| DATA | data-modeling, data-access, migration, state-mgmt |
| ARCHITECTURE | system-design, protocol-design, di-setup, service-impl, refactor |
| UI/UX | ui, component-lib, design-tokens, animation, gesture, accessibility, polish |
| TESTING | test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test |
| LOGIC | algorithm, validation, api-integration, debug |
| DOCUMENTATION | documentation, changelog |
| META | ideation, new-feature |

### Prompt Engineering Techniques

| Technique | Best For | Cost |
|-----------|----------|------|
| ToT (Tree of Thoughts) | Complex decisions, exploration | High |
| GoT (Graph of Thoughts) | Merging ideas, refinement | High |
| Self-Consistency | Algorithm verification | High |
| Reflexion | Learning from failures | Medium-High |
| Self-Refine | Iterative improvement | Medium |
| TDD | Implementation with tests | Medium |
| ReAct | Interactive problem-solving | Medium |
| Chain-of-Code | Mixed logic/semantic tasks | Medium |
| PS+ (Plan-and-Solve Plus) | Structured planning | Low |
| Least-to-Most | Decomposition | Low |

### Phase-Based Technique Selection

Each step is executed in three phases, each with an assigned technique:

| Phase | Purpose | Common Techniques |
|-------|---------|-------------------|
| Planning | Understand and design | PS+, ToT, ReAct |
| Implementation | Write code | TDD, Self-Refine, Reflexion |
| Verification | Validate correctness | TDD, Self-Consistency, GoT |

### CLI Tool

The planning system includes Python scripts for automation:

```bash
# Classify a problem description
python3 .claude/scripts/tangentle_plan.py classify "Fix the login bug"

# Show techniques for a problem type
python3 .claude/scripts/tangentle_plan.py techniques debug

# Assess risk for a step
python3 .claude/scripts/tangentle_plan.py risk migration

# Check plan status
python3 .claude/scripts/tangentle_plan.py status 004

# List all plans
python3 .claude/scripts/tangentle_plan.py list
```

### Configuration

Technique mappings can be customized in `.claude/technique-config.json`:

```json
{
  "problemTypes": {
    "LOGIC": {
      "subtypes": {
        "debug": {
          "techniques": {
            "planning": "react",
            "implementation": ["reflexion"],
            "verification": "self-refine"
          }
        }
      }
    }
  }
}
```

### Self-Correction Engine

High-risk steps use Reflexion-based self-correction with memory bank:

| Risk Level | Same Technique Retries | Alternative Retries | Total Budget |
|------------|------------------------|---------------------|--------------|
| Low | 2 | 1 | 3 |
| Medium | 3 | 2 | 5 |
| High | 3 | 3 | 7 |
| Critical | 5 | 5 | 10 |

**Memory Bank**: Lessons learned from failures persist across retries and can be preserved during rollback.

**Technique Rotation**: When same-technique retries fail, the engine rotates to alternative techniques based on failure patterns:

| Failure Pattern | Suggested Technique |
|-----------------|---------------------|
| Edge case, missing case | TDD |
| Not converging, iteration | Self-Consistency |
| Architecture, complex | ToT |
| Async, timing | ReAct |
| Memory, repeat mistakes | Reflexion |

## Current Plans

### Plan 001: iOS Foundation Setup (Not Started)
Creates the base project with:
- Xcode project structure
- Core Data model (14 entities)
- Repository pattern implementation
- Service layer
- AI service integration
- Minimal UI shell
- Testing infrastructure

### Plan 004: Intelligent Planning System v2 (In Progress)
Upgrades the planning system with:
- Automatic problem type classification
- Phase-based technique selection
- Risk assessment with retry budgets
- Self-correction with memory bank
- Technique-aware prompts and verification

## Communication Style

When helping users with ADHD:
- Be direct and concise (limited working memory)
- Use bullet points and lists
- Bold important information
- Don't over-explain
- Celebrate small wins
- Be supportive, not a taskmaster

## Build & Run

```bash
# Build
cd Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Test
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run on simulator
xcrun simctl boot "iPhone 15"
```

## Documentation Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - Claude instructions |
| `docs/README.md` | Quick start, setup |
| `docs/ARCHITECTURE.md` | Detailed architecture |
| `docs/DATA-MODEL.md` | Entity documentation |
| `docs/TESTING.md` | Comprehensive testing guide |

## Do NOT

- Use TickTick APIs (building our own system)
- Skip the repository layer (always use repositories)
- Put business logic in views
- Use synchronous Core Data operations
- Hardcode API keys
- Create UI before data layer is solid
