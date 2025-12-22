# Plan 001: Tangentle iOS Foundation Setup

## Overview
Create a solid foundation for the Tangentle iOS app - an ADHD-friendly executive function assistant. This plan establishes the project structure, Core Data models, repository pattern, dependency injection, and minimal UI shell. The goal is a scalable architecture that supports offline-first operation, future CloudKit sync, and gesture-rich interactions inspired by Timepage.

## Status
- **Created**: 2025-12-17
- **Status**: Not Started
- **Current Step**: 0 of 12

## Tree of Thought Analysis

### What are we building?
An iOS app foundation with:
1. **Xcode project** with proper structure for scalability
2. **Core Data models** for all domain entities (Tasks, Projects, Goals, Strategies, Routines, Habits, FocusModes, Modes)
3. **Repository pattern** for clean data access
4. **Dependency injection** container for testability
5. **Service layer** for business logic
6. **Minimal UI shell** with navigation
7. **Claude/AI integration** preparation
8. **Claude Code workflow** (CLAUDE.md, commands)

### Why are we building it?
- Replace TickTick dependency with custom task management
- Enable offline-first operation with background sync
- Support scalability to hundreds of thousands of users
- Create a gesture-rich, beautiful experience (Timepage inspiration)
- Maintain ADHD-specific optimizations from executive-brain

### Key Decisions

---

### Decision 1: Data Persistence Layer

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Core Data | Apple's native ORM with CloudKit support | Native sync, efficient, mature, works offline | Learning curve, boilerplate, schema migrations |
| B: SwiftData | New declarative persistence (iOS 17+) | Modern syntax, less boilerplate, Swift-native | Newer/less mature, less control, iOS 17 minimum |
| C: Realm | Third-party object database | Simple API, reactive, cross-platform | Third-party dependency, sync costs money |
| D: SQLite + GRDB | Direct SQL with Swift wrapper | Full control, lightweight, portable | More manual work, no built-in sync |

**Selected: Option A (Core Data)** - Best balance of offline-first, CloudKit sync preparation, maturity, and iOS ecosystem integration. SwiftData is appealing but Core Data provides more control for complex sync scenarios and is battle-tested for production scale.

---

### Decision 2: Architecture Pattern

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: MVVM | Model-View-ViewModel | SwiftUI native, reactive, testable | Can become bloated with complex logic |
| B: MVVM + Repository | MVVM with repository abstraction | Clean data access, testable, flexible | More layers, initial setup time |
| C: The Composable Architecture (TCA) | Point-Free's architecture | Highly testable, predictable state | Learning curve, verbose, dependency |
| D: VIPER | Clean architecture variant | Strict separation, scalable | Over-engineered for mobile, verbose |

**Selected: Option B (MVVM + Repository)** - MVVM is SwiftUI-native, adding Repository pattern abstracts data access for testability and future flexibility (swap Core Data for SwiftData, or add remote sync). TCA is overkill for initial setup; can adopt later if needed.

---

### Decision 3: Dependency Injection

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Environment | SwiftUI's @Environment | Native, simple, no external deps | Limited to views, hard to use in services |
| B: Manual DI Container | Custom container class | Full control, no deps, testable | Boilerplate, need to maintain |
| C: Factory | Third-party DI library | Clean syntax, lazy resolution | External dependency |
| D: Swinject | Popular DI framework | Feature-rich, mature | Heavy, learning curve |

**Selected: Option B (Manual DI Container)** - Start with a lightweight custom container. Can use @Environment for view-level injection and custom container for services. No external dependencies, full control, easy to understand.

---

### Decision 4: Entity Relationships Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Flat with IDs | Store foreign key IDs, resolve manually | Simple, flexible, easy migration | More queries, manual resolution |
| B: Full Core Data Relationships | Use Core Data relationship graph | Automatic resolution, cascading | Complex setup, migration headaches |
| C: Hybrid | Core Data for core entities, IDs for cross-cutting | Balance of convenience and flexibility | Inconsistent patterns |

**Selected: Option B (Full Core Data Relationships)** - For a production app with complex entity graph (Tasks→Projects→Goals, Tasks↔Strategies, etc.), Core Data's relationship management is worth the upfront investment. Enables efficient queries and automatic cascade deletes.

---

### Decision 5: iOS Calendar Integration

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: EventKit Read-Only | Read calendar events, display alongside tasks | Simple, low risk, good UX | No write, one-way sync |
| B: EventKit Read-Write | Full calendar integration | Two-way sync, native feel | Complexity, permission handling |
| C: Defer | Skip calendar integration initially | Focus on core features | Feature gap from executive-brain |

**Selected: Option A (EventKit Read-Only)** - Start with read-only to display calendar events alongside tasks. Writing tasks to calendar can come later. Reduces initial complexity while maintaining feature parity with executive-brain's schedule view.

---

### Decision 6: AI Service Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Protocol-based | Define AIService protocol, swap implementations | Testable, flexible, can switch providers | Initial abstraction overhead |
| B: Direct Integration | Hardcode Claude/Gemini clients | Faster initial development | Harder to test, less flexible |
| C: Backend Proxy | Route all AI through own backend | Rate limiting, caching, usage tracking | Requires backend, added latency |

**Selected: Option A (Protocol-based)** - Define `AIService` protocol with implementations for Claude (coaching) and Gemini (scheduling). Enables testing with mock services and easy provider switching. Can add backend proxy later if needed for usage tracking.

---

### Decision 7: Sync Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: CloudKit | Apple's native sync | Free tier, native, automatic | Apple ecosystem only, complex setup |
| B: Custom Backend | Build REST/GraphQL API | Full control, cross-platform | Build and maintain infrastructure |
| C: Firebase | Google's real-time database | Easy setup, real-time, cross-platform | Vendor lock-in, costs at scale |
| D: Defer | Offline-only initially | Focus on core features | No sync between devices |

**Selected: Option D (Defer) with CloudKit preparation** - Start offline-only but structure Core Data with CloudKit-compatible schema (use UUID identifiers, track timestamps). Add CloudKit sync in future plan. This reduces initial complexity while keeping the door open.

---

## Implementation Steps

| Step | Name | Description | Est. Time | Status |
|------|------|-------------|-----------|--------|
| 1 | project-setup | Create Xcode project with folder structure | 30 min | Pending |
| 2 | claude-workflow | Create CLAUDE.md and slash commands | 45 min | Pending |
| 3 | core-data-models | Define all Core Data entities and relationships | 60 min | Pending |
| 4 | model-extensions | Create Swift extensions for Core Data models | 45 min | Pending |
| 5 | repository-protocol | Define repository protocols and base implementation | 45 min | Pending |
| 6 | repositories | Implement concrete repositories for each entity | 60 min | Pending |
| 7 | di-container | Create dependency injection container | 30 min | Pending |
| 8 | services-layer | Create service layer for business logic | 60 min | Pending |
| 9 | ai-service-protocol | Define AI service protocol and implementations | 45 min | Pending |
| 10 | app-shell | Create app entry point and navigation shell | 45 min | Pending |
| 11 | seed-data | Create default strategies and problem types | 30 min | Pending |
| 12 | testing-setup | Set up testing infrastructure with sample tests | 45 min | Pending |

## Files to Create

### Project Structure
```
tangentle-ios/
├── CLAUDE.md                          # Claude instructions
├── .claude/
│   └── commands/                      # Slash commands
├── docs/
│   ├── README.md                      # Project overview
│   ├── ARCHITECTURE.md               # Architecture documentation
│   └── DATA-MODEL.md                 # Entity documentation
├── Tangentle/
│   ├── Tangentle.xcodeproj
│   ├── App/
│   │   ├── TangentleApp.swift        # App entry point
│   │   └── AppDelegate.swift         # App delegate
│   ├── Core/
│   │   ├── Models/                   # Core Data entity extensions
│   │   ├── Services/                 # Business logic services
│   │   ├── Repositories/             # Data access layer
│   │   ├── Utilities/                # Helpers and extensions
│   │   └── DI/                       # Dependency injection
│   ├── Features/
│   │   ├── Tasks/                    # Task feature module
│   │   ├── Projects/                 # Projects feature
│   │   ├── Goals/                    # Goals feature
│   │   ├── Calendar/                 # Calendar view
│   │   ├── Routines/                 # Routines feature
│   │   ├── Habits/                   # Habits feature
│   │   ├── Strategies/               # Strategy coaching
│   │   ├── FocusModes/               # Focus mode management
│   │   ├── Modes/                    # App modes/themes
│   │   └── Settings/                 # Settings feature
│   ├── UI/
│   │   ├── Components/               # Reusable UI components
│   │   ├── Themes/                   # Color schemes, typography
│   │   └── Gestures/                 # Custom gesture recognizers
│   ├── Data/
│   │   ├── Tangentle.xcdatamodeld   # Core Data model
│   │   └── Persistence.swift         # Core Data stack
│   └── Resources/
│       ├── Assets.xcassets
│       └── Localizable.strings
└── TangentleTests/
    ├── Unit/
    └── Integration/
```

### Core Data Entities
- `TGTask` - Tasks with subtasks, priority, status, duration
- `TGProject` - Project containers for tasks
- `TGGoal` - Long-term goals with linked projects
- `TGStrategy` - Productivity strategies with scoring
- `TGStrategyOutcome` - Outcome tracking for strategies
- `TGRoutine` - Daily routines with steps
- `TGRoutineStep` - Individual routine steps
- `TGHabit` - Habit tracking
- `TGFocusMode` - Focus mode definitions
- `TGMode` - App mode configurations
- `TGProblemType` - Avoidance problem type definitions
- `TGTag` - Tags for organization
- `TGSettings` - User settings (singleton)

## Files to Modify
- None (new project)

## Dependencies
- Step 3 (Core Data models) depends on Step 1 (project setup)
- Step 4 (model extensions) depends on Step 3
- Step 5-6 (repositories) depend on Step 3
- Step 7 (DI) depends on Steps 5-6
- Step 8-9 (services) depend on Step 7
- Step 10 (app shell) depends on Steps 7-9
- Step 11 (seed data) depends on Step 10
- Step 12 (testing) depends on all previous steps

## Success Criteria
- [ ] Xcode project builds and runs
- [ ] Core Data model compiles with all entities
- [ ] Repository tests pass (CRUD operations)
- [ ] Service layer can perform basic task operations
- [ ] App launches with navigation shell
- [ ] Default strategies seeded on first launch
- [ ] CLAUDE.md provides clear development guidance
- [ ] Unit tests demonstrate testing patterns

## Rollback Plan
Since this is a new project, rollback involves:
1. Archive the `tangentle-ios` folder
2. Start fresh with corrected approach
3. Each step creates git commits for granular rollback

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Core Data complexity | Medium | High | Start simple, add relationships incrementally |
| Over-engineering | Medium | Medium | Focus on working code first, refine later |
| iOS 17 adoption | Low | Medium | 17.0 is mature, most devices updated |
| Scope creep | High | High | Strict step boundaries, defer nice-to-haves |

## Notes
- This plan creates foundation only - no gesture-rich UI yet
- Calendar integration is read-only placeholder
- AI services are protocol stubs, not fully implemented
- Sync is deferred but architecture is CloudKit-ready
- Focus is on data layer correctness; UI comes in future plans
