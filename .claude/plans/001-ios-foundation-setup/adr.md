# ADR: Tangentle iOS Foundation Architecture

## Status
Proposed

## Context
We're building Tangentle, an ADHD-friendly executive function assistant for iOS. This app replaces the web-based "executive-brain" system, removing the TickTick dependency in favor of a custom task management system. The app must:

1. Work offline-first with future sync capability
2. Scale to hundreds of thousands of users
3. Provide gesture-rich, Timepage-inspired interactions
4. Maintain ADHD-specific optimizations (energy matching, strategy scoring, small task chunks)
5. Integrate with iOS calendar
6. Support AI coaching (Claude for conversation, Gemini for scheduling)

## Tree of Thought Analysis

### Data Persistence

**Options Considered:**
| Option | Pros | Cons |
|--------|------|------|
| Core Data | Native sync via CloudKit, efficient, mature, offline-first | Learning curve, boilerplate |
| SwiftData | Modern syntax, less boilerplate | Less mature, less control |
| Realm | Simple API, reactive | Third-party, sync costs money |
| SQLite + GRDB | Full control, lightweight | Manual work, no sync |

**Decision: Core Data**
- CloudKit sync is on the roadmap; Core Data + CloudKit is Apple's blessed path
- Battle-tested for production scale
- Efficient memory management for large datasets
- Schema migrations are well-documented

### Architecture Pattern

**Options Considered:**
| Option | Pros | Cons |
|--------|------|------|
| MVVM | SwiftUI native, reactive | Can become bloated |
| MVVM + Repository | Clean data access, testable | More layers |
| TCA | Highly testable, predictable | Learning curve, verbose |
| VIPER | Strict separation | Over-engineered |

**Decision: MVVM + Repository**
- MVVM is natural for SwiftUI's declarative model
- Repository pattern abstracts data access for:
  - Easy testing with mock repositories
  - Future flexibility to swap persistence layer
  - Clean separation of concerns
- Avoids TCA complexity while maintaining testability

### Dependency Injection

**Options Considered:**
| Option | Pros | Cons |
|--------|------|------|
| @Environment | Native SwiftUI | Limited to views |
| Manual DI Container | Full control, no deps | Boilerplate |
| Factory library | Clean syntax | External dependency |
| Swinject | Feature-rich | Heavy |

**Decision: Manual DI Container**
- No external dependencies
- Full control over lifetime and resolution
- Use @Environment for view-level injection
- Custom container for services and repositories

### Entity Relationships

**Decision: Full Core Data Relationships**
- Complex entity graph requires proper relationship management
- Enables efficient queries (fetch tasks with project in one query)
- Automatic cascade deletes (delete project → delete tasks)
- Worth upfront investment for production app

### iOS Calendar Integration

**Decision: EventKit Read-Only (initially)**
- Display calendar events alongside tasks
- Lower complexity, fewer permissions
- Write capability deferred to future plan

### AI Service Architecture

**Decision: Protocol-based**
- Define `AIService` protocol
- Implement `ClaudeCoachingService` for coaching conversations
- Implement `GeminiSchedulingService` for task prioritization
- Easy to test with mock implementations
- Can add backend proxy layer later

### Sync Strategy

**Decision: Defer with CloudKit Preparation**
- Start offline-only to reduce complexity
- Structure Core Data for CloudKit compatibility:
  - UUID identifiers on all entities
  - Track `createdAt`, `updatedAt` timestamps
  - Avoid unique constraints that conflict with sync
- Add CloudKit in future plan

## Decision Summary

| Area | Decision | Rationale |
|------|----------|-----------|
| Persistence | Core Data | CloudKit-ready, mature, efficient |
| Architecture | MVVM + Repository | SwiftUI-native with clean data abstraction |
| DI | Manual Container | No deps, full control, testable |
| Relationships | Full Core Data | Complex graph needs proper management |
| Calendar | Read-only EventKit | Simple first, expand later |
| AI Services | Protocol-based | Testable, flexible, provider-agnostic |
| Sync | Defer (CloudKit prep) | Offline-first, reduce complexity |

## Consequences

### Positive
- **Scalable foundation** - Clean architecture supports growth
- **Testable** - Repository pattern enables unit testing without persistence
- **Flexible** - Protocol-based services can swap implementations
- **Future-proof** - CloudKit preparation means sync is incremental, not rewrite
- **Native experience** - Core Data + SwiftUI = optimal iOS integration
- **Offline-first** - Core Data works seamlessly offline

### Negative
- **Initial setup time** - More boilerplate than simpler approaches
- **Core Data learning curve** - Team must understand NSManagedObject, contexts
- **No immediate sync** - Users start single-device only

### Mitigations
- **Setup time**: Use code generation for boilerplate
- **Learning curve**: Comprehensive documentation in ARCHITECTURE.md
- **No sync**: Clearly communicate roadmap; offline-first is acceptable for MVP

## Entity Model Overview

```
TGTask
├─ id: UUID
├─ title: String
├─ taskDescription: String?
├─ status: TaskStatus (enum)
├─ priority: Int16 (0-5)
├─ estimatedDuration: Int16 (minutes)
├─ scheduledDate: Date?
├─ scheduledTime: Date?
├─ dueDate: Date?
├─ startDate: Date?
├─ completedAt: Date?
├─ energyRequired: EnergyLevel (enum)
├─ createdAt: Date
├─ updatedAt: Date
├─ sortOrder: Int32
│
├─ project: TGProject? (to-one)
├─ goal: TGGoal? (to-one)
├─ routine: TGRoutine? (to-one)
├─ parentTask: TGTask? (to-one, subtask support)
├─ subtasks: [TGTask] (to-many)
├─ focusMode: TGFocusMode? (to-one)
├─ tags: [TGTag] (to-many)
├─ blockedBy: [TGTask] (to-many, dependencies)
├─ blocking: [TGTask] (to-many, inverse)
└─ linkedStrategies: [TGStrategy] (to-many)

TGProject
├─ id: UUID
├─ name: String
├─ emoji: String?
├─ color: String?
├─ projectDescription: String?
├─ isActive: Bool
├─ sortOrder: Int32
├─ createdAt: Date
├─ updatedAt: Date
│
├─ tasks: [TGTask] (to-many)
├─ goal: TGGoal? (to-one)
└─ focusModes: [TGFocusMode] (to-many)

TGGoal
├─ id: UUID
├─ name: String
├─ goalDescription: String?
├─ targetDate: Date?
├─ isActive: Bool
├─ createdAt: Date
├─ updatedAt: Date
│
├─ projects: [TGProject] (to-many)
└─ tasks: [TGTask] (to-many)

TGStrategy
├─ id: UUID
├─ name: String
├─ strategyDescription: String
├─ problemTypes: [String] (transformable)
├─ taskTypes: [String] (transformable)
├─ tags: [String] (transformable)
├─ tweaks: [String] (transformable)
├─ source: String (user/default)
├─ isActive: Bool
├─ usageCount: Int32
├─ createdAt: Date
├─ updatedAt: Date
│
├─ outcomes: [TGStrategyOutcome] (to-many)
└─ linkedTasks: [TGTask] (to-many)

TGStrategyOutcome
├─ id: UUID
├─ date: Date
├─ result: String (success/partial/failure)
├─ problemType: String
├─ taskType: String
├─ taskTitle: String
├─ notes: String?
│
└─ strategy: TGStrategy (to-one)

TGRoutine
├─ id: UUID
├─ name: String
├─ routineDescription: String?
├─ scheduledTime: Date
├─ estimatedDuration: Int16
├─ daysOfWeek: [String] (transformable)
├─ isEnabled: Bool
├─ routineType: String
├─ createdAt: Date
├─ updatedAt: Date
│
├─ steps: [TGRoutineStep] (to-many, ordered)
└─ linkedTasks: [TGTask] (to-many)

TGRoutineStep
├─ id: UUID
├─ name: String
├─ estimatedDuration: Int16
├─ sortOrder: Int32
│
└─ routine: TGRoutine (to-one)

TGHabit
├─ id: UUID
├─ name: String
├─ habitDescription: String?
├─ frequency: String (daily/weekly)
├─ targetCount: Int16
├─ isActive: Bool
├─ streakCount: Int32
├─ lastCompletedAt: Date?
├─ createdAt: Date
├─ updatedAt: Date
│
└─ completions: [TGHabitCompletion] (to-many)

TGHabitCompletion
├─ id: UUID
├─ date: Date
├─ count: Int16
│
└─ habit: TGHabit (to-one)

TGFocusMode
├─ id: UUID
├─ name: String
├─ focusModeDescription: String?
├─ startTime: Date?
├─ endTime: Date?
├─ daysOfWeek: [String] (transformable)
├─ isActive: Bool
├─ isAutomatic: Bool
├─ filterTags: [String] (transformable)
├─ sortOrder: Int32
├─ createdAt: Date
├─ updatedAt: Date
│
├─ includedProjects: [TGProject] (to-many)
└─ tasks: [TGTask] (to-many)

TGMode
├─ id: UUID
├─ name: String
├─ modeDescription: String?
├─ settings: Data (JSON blob for flexibility)
├─ isDefault: Bool
├─ isShared: Bool
├─ createdAt: Date
├─ updatedAt: Date

TGProblemType
├─ id: UUID
├─ identifier: String (too_big, unclear, etc.)
├─ label: String
├─ problemTypeDescription: String
├─ suggestedStrategyIds: [String] (transformable)
├─ isDefault: Bool
├─ sortOrder: Int32

TGTag
├─ id: UUID
├─ name: String
├─ color: String?
├─ sortOrder: Int32
│
└─ tasks: [TGTask] (to-many)

TGSettings (singleton)
├─ id: UUID
├─ scheduleSettings: Data (JSON)
├─ taskSettings: Data (JSON)
├─ displaySettings: Data (JSON)
├─ coachingSettings: Data (JSON)
├─ updatedAt: Date
```

## References
- [Core Data Programming Guide](https://developer.apple.com/documentation/coredata)
- [CloudKit + Core Data](https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [executive-brain codebase](../../../executive-brain/) - Original domain concepts
