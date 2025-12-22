# Plan 001 Context

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: Tangentle iOS Foundation Setup
- **Current Step**: COMPLETE
- **Last Updated**: 2025-12-21
- **All 12 AI Prompts Generated**: Yes
- **Steps Completed**: 12/12 (100%)

## What This Plan Creates
A complete iOS app foundation including:
- Xcode project with proper structure
- Core Data model with 14 entities
- Repository pattern for data access
- Service layer for business logic
- AI service integration (Claude + Gemini)
- Minimal UI shell with tab navigation
- Default strategy and problem type data
- Testing infrastructure

## Key Architecture Decisions

### Persistence: Core Data
- CloudKit-compatible schema (UUIDs, timestamps)
- Offline-first operation
- Sync deferred to future plan

### Architecture: MVVM + Repository
- ViewModels use @Observable (iOS 17+)
- Repositories abstract data access
- Services contain business logic
- Protocol-first for testability

### Dependency Injection: Manual Container
- AppContainer singleton for production
- TestContainer with in-memory Core Data
- SwiftUI Environment for view injection

### AI Services: Protocol-Based
- ClaudeCoachingService for conversations
- GeminiSchedulingService for prioritization (stub)
- MockAIService for testing
- Graceful fallback when unavailable

## Domain Concepts (from executive-brain)

### Tasks
- 15-30 minute chunks (ADHD-optimized)
- Status: pending, in_progress, waiting_for, completed, deferred, delegated, deleted
- Energy levels: low, medium, high
- Can have subtasks, blockers, tags
- Linked to projects, goals, routines, focus modes

### Strategies
- Productivity techniques with scoring
- Score = successRate × confidence × recencyFactor
- 18+ default strategies seeded
- Outcomes tracked per problem type

### Problem Types
- too_big, unclear, boring, scary, blocked, distracted, low_energy, overwhelmed, forgot, interruptions, other
- Used for avoidance coaching
- Link to suggested strategies

### Focus Modes
- Morning, Peak Focus, Afternoon, Weekend, Evening Shutdown
- Filter tasks by time of day and energy
- Automatic activation based on schedule

## Entities to Create

| Entity | Purpose |
|--------|---------|
| TGTask | Tasks with subtasks and dependencies |
| TGProject | Project containers |
| TGGoal | Long-term goals |
| TGStrategy | Productivity strategies |
| TGStrategyOutcome | Strategy usage tracking |
| TGRoutine | Daily routines |
| TGRoutineStep | Individual routine steps |
| TGHabit | Habit tracking |
| TGHabitCompletion | Habit completion records |
| TGFocusMode | Focus mode definitions |
| TGMode | App mode configurations |
| TGProblemType | Avoidance problem types |
| TGTag | Task tags |
| TGSettings | User settings (singleton) |

## File Structure
```
tangentle-ios/
├── CLAUDE.md
├── .claude/commands/
├── docs/
├── Tangentle/
│   ├── App/
│   ├── Core/
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── Repositories/
│   │   ├── Utilities/
│   │   └── DI/
│   ├── Features/
│   ├── UI/
│   ├── Data/
│   └── Resources/
└── TangentleTests/
```

## What's Been Done
- Plan created with Tree of Thought analysis
- ADR documenting architecture decisions
- 12 step specification files
- Progress tracking infrastructure
- **All 12 AI prompts generated** (2025-12-17)
- CLAUDE.md and .gitignore created
- 12 Claude commands transferred/created

### Step 1 Completed - 2025-12-17

**Summary**: Created the Xcode project with proper folder structure and initial app entry point.

**Files Created**:
- `Tangentle.xcodeproj/project.pbxproj` - Main Xcode project file
- `Tangentle.xcodeproj/xcshareddata/xcschemes/Tangentle.xcscheme` - Build scheme
- `Tangentle/App/TangentleApp.swift` - App entry point
- `Tangentle/App/ContentView.swift` - Placeholder content view
- `Tangentle/Resources/Assets.xcassets/` - Asset catalog with AppIcon and AccentColor

**Verification Results**:
- [x] Xcode project builds successfully
- [x] App runs on iPhone 15 (iOS 17.5) simulator
- [x] Bundle identifier is `com.tangentle.app`
- [x] Deployment target is iOS 17.0
- [x] All folder groups present in project structure

**Key Decisions**:
- Created project.pbxproj manually (command-line compatible)
- Used iOS 17.5 simulator for testing (17.0 not available in current setup)
- Full MVVM folder structure pre-created for future steps

**Learnings**:
- iPhone 15 simulator requires explicit OS version (17.5) when building from CLI

---

### Step 2 Completed - 2025-12-17

**Summary**: Verified CLAUDE.md and commands exist, created project documentation.

**Files Created**:
- `docs/README.md` - Project overview
- `docs/ARCHITECTURE.md` - Architecture documentation
- `docs/DATA-MODEL.md` - Entity documentation

**Verification Results**:
- [x] CLAUDE.md exists and is comprehensive
- [x] All 12 commands exist in .claude/commands/
- [x] docs/README.md created
- [x] docs/ARCHITECTURE.md created
- [x] docs/DATA-MODEL.md created
- [x] Documentation matches planned architecture

**Key Decisions**:
- Documentation kept concise and focused
- DATA-MODEL.md documents entity structure for future reference

---

### Step 3 Completed - 2025-12-17

**Summary**: Created Core Data model with all 14 entities, relationships, and persistence controller.

**Files Created**:
- `Tangentle/Data/Tangentle.xcdatamodeld/Tangentle.xcdatamodel/contents` - Core Data model XML
- `Tangentle/Data/Persistence.swift` - PersistenceController for Core Data stack

**Files Modified**:
- `Tangentle.xcodeproj/project.pbxproj` - Added Core Data files to build

**Verification Results**:
- [x] Tangentle.xcdatamodeld exists in Data/ folder
- [x] All 14 entities defined with correct attributes
- [x] All relationships configured with correct cardinality
- [x] Project builds without Core Data warnings
- [x] PersistenceController.swift created with preview support

**Entities Created** (14 total):
- TGTask (25 relationships, self-referential subtasks/blockers)
- TGProject, TGGoal, TGStrategy, TGStrategyOutcome
- TGRoutine, TGRoutineStep, TGHabit, TGHabitCompletion
- TGFocusMode, TGMode, TGProblemType, TGTag, TGSettings

**Key Decisions**:
- CloudKit flag disabled (`usedWithCloudKit="YES"` removed) - deferred to sync plan
- All entities use `codeGenerationType="class"` for auto-generated NSManagedObject subclasses
- Transformable arrays use `NSSecureUnarchiveFromData` for security
- All non-optional attributes have default values

**Learnings**:
- CloudKit-enabled Core Data requires default values for ALL non-optional attributes
- Disabling CloudKit allows simpler schema during initial development

---

### Step 4 Completed - 2025-12-19

**Summary**: Created Swift extensions for Core Data entities with enums, computed properties, convenience initializers, and business logic.

**Files Created**:
- `Tangentle/Core/Models/Enums.swift` - TaskStatus, Priority, EnergyLevel, OutcomeResult, HabitFrequency, RoutineType, DayOfWeek
- `Tangentle/Core/Models/TGTask+Extensions.swift` - Task status, priority, completion, blocking logic
- `Tangentle/Core/Models/TGStrategy+Extensions.swift` - Strategy scoring algorithm, outcome tracking
- `Tangentle/Core/Models/TGProject+Extensions.swift` - Project completion tracking, TGGoal and TGTag extensions
- `Tangentle/Core/Models/TGHabit+Extensions.swift` - Streak calculations, completion tracking
- `Tangentle/Core/Models/TGSettings+Extensions.swift` - Codable settings structures (Schedule, Task, Display, Coaching)
- `Tangentle/Core/Models/TGRoutine+Extensions.swift` - Routine scheduling, step management
- `Tangentle/Core/Models/TGFocusMode+Extensions.swift` - Focus mode scheduling, TGMode and TGProblemType extensions

**Files Modified**:
- `Tangentle.xcodeproj/project.pbxproj` - Added 8 extension files to build

**Verification Results**:
- [x] Enums.swift created with all shared enums
- [x] TGTask+Extensions with status, priority, computed properties
- [x] TGStrategy+Extensions with scoring logic
- [x] TGProject+Extensions with task arrays
- [x] TGHabit+Extensions with streak tracking
- [x] TGSettings+Extensions with Codable wrappers
- [x] Project builds without errors

**Key Decisions**:
- Use native Swift types for transformable properties (not NSObject casting)
- DayOfWeek uses Int raw values matching Calendar weekday (1=Sunday through 7=Saturday)
- Strategy scoring: successRate × log(attempts + 1) × recencyFactor
- ADHD time buffer: 3x for ≤5min, 1.5x for ≤30min, 2x for longer

**Learnings**:
- Core Data `codeGenerationType="class"` generates properties with specified `customClassName` types directly
- Transformable properties with custom class names don't need NSObject casting

---

### Step 5 Completed - 2025-12-19

**Summary**: Created the generic repository protocol, base implementation, and entity-specific protocol extensions.

**Files Created**:
- `Tangentle/Core/Repositories/Repository.swift` - Generic protocol with default CRUD implementations
- `Tangentle/Core/Repositories/BaseRepository.swift` - Base repository class with transaction and background support
- `Tangentle/Core/Repositories/RepositoryProtocols.swift` - 14 entity-specific repository protocols

**Files Modified**:
- `Tangentle.xcodeproj/project.pbxproj` - Added 3 repository files to build

**Verification Results**:
- [x] Repository.swift with generic protocol and default implementations
- [x] BaseRepository.swift with transaction support
- [x] RepositoryProtocols.swift with entity-specific protocols
- [x] Project builds without errors

**Key Features**:
- Generic `Repository` protocol with associated type for entity
- Default implementations for fetch, fetchOne, fetchById, count, save, delete, deleteAll
- All operations use `async throws` with `context.perform {}` for thread safety
- `BaseRepository` provides transaction support via `performTransaction`
- Background operations via `performInBackground` with separate context
- Helper methods: `makeFetchRequest`, `makePredicate`, `makeSortDescriptor`

**Entity Protocols Created** (14 total):
- TaskRepositoryProtocol, ProjectRepositoryProtocol, GoalRepositoryProtocol
- StrategyRepositoryProtocol, StrategyOutcomeRepositoryProtocol
- RoutineRepositoryProtocol, RoutineStepRepositoryProtocol
- HabitRepositoryProtocol, HabitCompletionRepositoryProtocol
- FocusModeRepositoryProtocol, ModeRepositoryProtocol
- ProblemTypeRepositoryProtocol, TagRepositoryProtocol, SettingsRepositoryProtocol

---

### Step 6 Completed - 2025-12-19

**Summary**: Created 14 concrete repository implementations with entity-specific queries.

**Files Created**:
- `Tangentle/Core/Repositories/TaskRepository.swift` - Today's tasks, overdue, by status/priority/energy
- `Tangentle/Core/Repositories/StrategyRepository.swift` - Top rated, by problem type, coaching queries
- `Tangentle/Core/Repositories/ProjectRepository.swift` - Active, by goal, archived
- `Tangentle/Core/Repositories/GoalRepository.swift` - Active, upcoming deadlines
- `Tangentle/Core/Repositories/RoutineRepository.swift` - Enabled, by type, scheduled for today
- `Tangentle/Core/Repositories/RoutineStepRepository.swift` - Steps by routine
- `Tangentle/Core/Repositories/HabitRepository.swift` - Active, due today, by frequency
- `Tangentle/Core/Repositories/HabitCompletionRepository.swift` - By habit, for date
- `Tangentle/Core/Repositories/FocusModeRepository.swift` - Active, automatic, currently active
- `Tangentle/Core/Repositories/ModeRepository.swift` - Default mode, fetch all
- `Tangentle/Core/Repositories/ProblemTypeRepository.swift` - All, by identifier, defaults
- `Tangentle/Core/Repositories/TagRepository.swift` - All, fetch or create, by name
- `Tangentle/Core/Repositories/StrategyOutcomeRepository.swift` - By strategy, recent
- `Tangentle/Core/Repositories/SettingsRepository.swift` - Singleton pattern with get/update

**Files Modified**:
- `Tangentle.xcodeproj/project.pbxproj` - Added 14 repository files to build

**Verification Results**:
- [x] All 14 repository files created
- [x] Each implements its protocol from RepositoryProtocols.swift
- [x] Specialized queries work (override keyword for fetchActive())
- [x] SettingsRepository provides singleton access
- [x] Project builds without errors

**Key Fix**:
- Added `override` keyword to `fetchActive()` in repositories that extend BaseRepository
- BaseRepository already provides a generic `fetchActive()` implementation

---

### Step 10 Completed - 2025-12-19

**Summary**: Created the app entry point with DI injection, 5-tab navigation, TodayView with ViewModel using @Observable, TaskRow component, and placeholder views for all tabs.

**Files Created**:
- `Tangentle/Features/Tasks/TodayView.swift` - Today's tasks with overdue section
- `Tangentle/Features/Tasks/TodayViewModel.swift` - @Observable ViewModel with task loading
- `Tangentle/Features/Tasks/TasksView.swift` - All tasks placeholder
- `Tangentle/Features/Calendar/CalendarView.swift` - Calendar placeholder
- `Tangentle/Features/Strategies/StrategiesView.swift` - Strategies placeholder
- `Tangentle/Features/Settings/SettingsView.swift` - Settings with basic info
- `Tangentle/UI/Components/TaskRow.swift` - Reusable task row with PriorityBadge

**Files Modified**:
- `Tangentle/App/TangentleApp.swift` - Added DI container injection and first launch setup
- `Tangentle/App/ContentView.swift` - 5-tab TabView navigation
- `Tangentle.xcodeproj/project.pbxproj` - Added 7 new UI files

**Verification Results**:
- [x] App entry point with DI container
- [x] Tab bar shows all 5 tabs (Today, Tasks, Calendar, Strategies, Settings)
- [x] TodayView loads with task list structure
- [x] TaskRow component with priority badges
- [x] Navigation works between tabs
- [x] Project builds without errors

**Key Features Added**:
- `TodayViewModel` using @Observable macro for state management
- `TaskRow` with completion status, project info, duration, priority badge
- `PriorityBadge` component with color-coded priority levels
- Tab navigation with SF Symbols
- Empty state handling with ContentUnavailableView
- Pull-to-refresh on TodayView

---

### Step 9 Completed - 2025-12-19

**Summary**: Expanded AI service protocol with detailed context models, coaching responses, scheduling requests/responses, and problem-type specific coaching advice.

**Files Modified**:
- `Tangentle/Core/Services/ServiceProtocols.swift` - Expanded AIContext, added ScheduleRequest, ScheduleResponse, CoachingResponse, AIServiceError
- `Tangentle/Core/Services/AIService.swift` - Full implementation with problem-type coaching and scheduling logic
- `Tangentle/Core/DI/TestContainer.swift` - Updated MockAIService with new protocol methods

**Verification Results**:
- [x] AIContext expanded with StrategyContext and UserPreferences
- [x] ScheduleRequest/ScheduleResponse for scheduling with reasoning
- [x] CoachingResponse with suggested strategies and follow-up questions
- [x] AIServiceError enum for error handling
- [x] Default coaching advice for all 10+ problem types
- [x] Energy-aware scheduling logic in stubs
- [x] MockAIService updated with new methods
- [x] Project builds without errors

**Key Features Added**:
- `AIContext.StrategyContext` - Historical strategy data with scores
- `AIContext.UserPreferences` - User preferences for coaching
- `ScheduleRequest.TaskInfo` - Simplified task info for scheduling
- `ScheduleResponse.ScheduledTask` - Task with scheduled time and reasoning
- `CoachingResponse` - Full coaching response with strategies
- `AIServiceError` - Error types (noAPIKey, networkError, invalidResponse, etc.)
- Problem-type coaching for: too_big, unclear, boring, scary, blocked, distracted, low_energy, overwhelmed, forgot, interruptions
- Default implementations in protocol extension for optional methods

---

### Step 12 Completed - 2025-12-21 (PLAN COMPLETE)

**Summary**: Created testing infrastructure with Swift Testing framework and sample unit tests.

**Files Created**:
- `TangentleTests/Unit/TestHelpers.swift` - TestCoreDataStack, Date helpers
- `TangentleTests/Unit/TaskRepositoryTests.swift` - Repository CRUD tests
- `TangentleTests/Unit/StrategyServiceTests.swift` - Service logic tests
- `TangentleTests/Unit/TodayViewModelTests.swift` - ViewModel tests with @MainActor

**Verification Results**:
- [x] TestHelpers.swift provides reusable test utilities
- [x] TaskRepositoryTests cover CRUD and queries (6 tests)
- [x] StrategyServiceTests verify scoring and outcomes (4 tests)
- [x] TodayViewModelTests check data loading (4 tests)
- [x] Test build succeeds (xcodebuild build-for-testing)

**Key Patterns Established**:
- `@Suite` for test grouping, `@Test` for individual tests
- `@MainActor` for ViewModel tests (iOS 17+)
- `TestCoreDataStack` for in-memory Core Data
- Date helpers: `.testToday`, `.testYesterday`, `.testTomorrow`

---

## Plan 001 Complete Summary

**Started**: 2025-12-17
**Completed**: 2025-12-21
**Steps**: 12/12 complete

### Foundation Established:
- Xcode project with organized folder structure
- Core Data model (14 entities with relationships)
- Repository pattern with protocols (14 repositories)
- DI container with lazy initialization
- Services layer (Task, Strategy, Schedule, Settings, AI)
- AI service protocol with problem-type coaching
- App shell with 5-tab navigation
- Seed data (18 strategies, 11 problem types, 5 focus modes)
- Testing infrastructure with Swift Testing

### Ready For:
- Plan 002: Gesture-rich UI (Timepage-inspired)
- Plan 003: Claude AI API integration
- Plan 004: CloudKit sync

---

### Step 11 Completed - 2025-12-21

**Summary**: Created SeedDataService to populate default strategies, problem types, focus modes, and settings on first launch.

**Files Created**:
- `Tangentle/Core/Services/SeedDataService.swift` - First-launch seed data service

**Files Modified**:
- `Tangentle/App/TangentleApp.swift` - Wired SeedDataService into seedDefaultData()
- `Tangentle.xcodeproj/project.pbxproj` - Added SeedDataService to build

**Verification Results**:
- [x] SeedDataService.swift created with all defaults
- [x] 18 strategies seeded (2-Minute Version, First Step Only, etc.)
- [x] 11 problem types seeded (too_big, unclear, boring, scary, etc.)
- [x] 5 focus modes seeded (Morning, Peak Focus, Afternoon, Weekend, Evening Shutdown)
- [x] Default settings created (schedule, tasks, display, coaching)
- [x] Seeding runs only on first launch (checks strategy count)
- [x] App builds successfully

**Key Features Added**:
- `SeedDataService` with `seedIfNeeded()` that checks if already seeded
- Static data arrays for strategies, problem types, and focus modes
- All strategies ported from executive-brain domain knowledge
- Calendar weekday-compatible days (1=Sunday through 7=Saturday)
- Settings use Codable structs with `.default` factory methods

---

### Step 8 Completed - 2025-12-19

**Summary**: Created full service layer implementations with business logic for tasks, strategies, scheduling, and settings.

**Files Created**:
- `Tangentle/Core/Services/TaskService.swift` - Task CRUD, subtasks, reordering
- `Tangentle/Core/Services/StrategyService.swift` - Strategy coaching and scoring
- `Tangentle/Core/Services/ScheduleService.swift` - Schedule management, time slots
- `Tangentle/Core/Services/SettingsService.swift` - Settings read/write
- `Tangentle/Core/Services/AIService.swift` - AI service stub for Step 9

**Files Modified**:
- `Tangentle/Core/Services/ServiceProtocols.swift` - Expanded with full interfaces
- `Tangentle.xcodeproj/project.pbxproj` - Replaced StubServices with individual service files

**Files Removed**:
- `Tangentle/Core/Services/StubServices.swift` - Replaced by individual service files

**Verification Results**:
- [x] ServiceProtocols.swift defines all interfaces with helper structs
- [x] TaskService handles all task operations (CRUD, subtasks, reorder)
- [x] StrategyService provides coaching support with scoring
- [x] ScheduleService manages scheduling with time slots
- [x] SettingsService wraps settings access
- [x] AIService provides stub implementation for Step 9
- [x] Project builds without errors

**Key Features Added**:
- `TaskChanges` struct for partial task updates
- `DaySchedule` struct for daily schedule representation
- `TimeSlot` struct for scheduling time slots
- Energy-aware time slot suggestions (peak focus for high priority)
- 30-minute slot generation based on work hours

---

### Step 7 Completed - 2025-12-19

**Summary**: Created the dependency injection container with protocol-based abstractions, SwiftUI environment integration, and test container.

**Files Created**:
- `Tangentle/Core/DI/Container.swift` - DIContainer protocol defining all injectable dependencies
- `Tangentle/Core/DI/AppContainer.swift` - Production container with lazy initialization, singleton pattern
- `Tangentle/Core/DI/ContainerEnvironment.swift` - SwiftUI environment key and View extension
- `Tangentle/Core/DI/TestContainer.swift` - Test container with in-memory Core Data and MockAIService
- `Tangentle/Core/Services/ServiceProtocols.swift` - Service layer protocols (stubs for Step 8)
- `Tangentle/Core/Services/StubServices.swift` - Placeholder service implementations

**Files Modified**:
- `Tangentle.xcodeproj/project.pbxproj` - Added 6 DI/Services files to build

**Verification Results**:
- [x] Container.swift with DIContainer protocol
- [x] AppContainer.swift with lazy initialization
- [x] ContainerEnvironment.swift for SwiftUI injection
- [x] TestContainer.swift with MockAIService
- [x] ServiceProtocols.swift with service interfaces
- [x] StubServices.swift with placeholder implementations
- [x] Project builds without errors

**Key Decisions**:
- Created stub service protocols to satisfy DI container compilation (full implementation in Step 8)
- AppContainer uses singleton pattern (`static let shared`)
- All dependencies use lazy initialization to defer creation until first use
- SwiftUI injection via `environment(\.container, container)` and `.withContainer()` modifier
- MockAIService provides configurable mock responses for testing

**Service Protocols Created**:
- TaskServiceProtocol - Task creation, completion, deletion, fetching
- StrategyServiceProtocol - Strategy fetching, outcome recording
- ScheduleServiceProtocol - Today's schedule, time slot suggestions, rescheduling
- SettingsServiceProtocol - Settings retrieval and updates
- AIServiceProtocol - Coaching advice, task prioritization, schedule suggestions

---

## Files Created
| File | Purpose |
|------|---------|
| .claude/plans/001-ios-foundation-setup/plan.md | Main plan document |
| .claude/plans/001-ios-foundation-setup/adr.md | Architecture decisions |
| .claude/plans/001-ios-foundation-setup/steps/*.md | 12 step specifications |
| .claude/plans/001-ios-foundation-setup/progress.json | Progress tracking |
| .claude/plans/001-ios-foundation-setup/context.md | This file |
| Tangentle.xcodeproj/ | Xcode project |
| Tangentle/App/*.swift | App entry point files |
| Tangentle/Resources/Assets.xcassets/ | Asset catalog |
| docs/README.md | Project overview |
| docs/ARCHITECTURE.md | Architecture documentation |
| docs/DATA-MODEL.md | Entity documentation |
| Tangentle/Data/Tangentle.xcdatamodeld | Core Data model (14 entities) |
| Tangentle/Data/Persistence.swift | Core Data stack controller |
| Tangentle/Core/Models/Enums.swift | Shared enums (TaskStatus, Priority, etc.) |
| Tangentle/Core/Models/TGTask+Extensions.swift | Task computed properties, convenience init |
| Tangentle/Core/Models/TGStrategy+Extensions.swift | Strategy scoring algorithm |
| Tangentle/Core/Models/TGProject+Extensions.swift | Project, Goal, Tag extensions |
| Tangentle/Core/Models/TGHabit+Extensions.swift | Habit streak tracking |
| Tangentle/Core/Models/TGSettings+Extensions.swift | Codable settings wrappers |
| Tangentle/Core/Models/TGRoutine+Extensions.swift | Routine step management |
| Tangentle/Core/Models/TGFocusMode+Extensions.swift | FocusMode, Mode, ProblemType extensions |
| Tangentle/Core/Repositories/Repository.swift | Generic repository protocol with defaults |
| Tangentle/Core/Repositories/BaseRepository.swift | Base repository with transaction support |
| Tangentle/Core/Repositories/RepositoryProtocols.swift | Entity-specific repository protocols |
| Tangentle/Core/Repositories/TaskRepository.swift | Task queries (today, overdue, etc.) |
| Tangentle/Core/Repositories/StrategyRepository.swift | Strategy scoring and filtering |
| Tangentle/Core/Repositories/ProjectRepository.swift | Project management |
| Tangentle/Core/Repositories/GoalRepository.swift | Goal tracking |
| Tangentle/Core/Repositories/RoutineRepository.swift | Routine scheduling |
| Tangentle/Core/Repositories/RoutineStepRepository.swift | Routine steps |
| Tangentle/Core/Repositories/HabitRepository.swift | Habit tracking |
| Tangentle/Core/Repositories/HabitCompletionRepository.swift | Habit completions |
| Tangentle/Core/Repositories/FocusModeRepository.swift | Focus mode queries |
| Tangentle/Core/Repositories/ModeRepository.swift | Mode management |
| Tangentle/Core/Repositories/ProblemTypeRepository.swift | Problem types |
| Tangentle/Core/Repositories/TagRepository.swift | Tag management |
| Tangentle/Core/Repositories/StrategyOutcomeRepository.swift | Strategy outcomes |
| Tangentle/Core/Repositories/SettingsRepository.swift | Settings singleton |
| Tangentle/Core/DI/Container.swift | DIContainer protocol |
| Tangentle/Core/DI/AppContainer.swift | Production DI container |
| Tangentle/Core/DI/ContainerEnvironment.swift | SwiftUI environment integration |
| Tangentle/Core/DI/TestContainer.swift | Test container with mocks |
| Tangentle/Core/Services/ServiceProtocols.swift | Service layer protocols |
| Tangentle/Core/Services/TaskService.swift | Task management service |
| Tangentle/Core/Services/StrategyService.swift | Strategy coaching service |
| Tangentle/Core/Services/ScheduleService.swift | Schedule management service |
| Tangentle/Core/Services/SettingsService.swift | Settings service |
| Tangentle/Core/Services/AIService.swift | AI service (stub for Step 9) |
| Tangentle/Features/Tasks/TodayView.swift | Today's tasks view |
| Tangentle/Features/Tasks/TodayViewModel.swift | Today view model |
| Tangentle/Features/Tasks/TasksView.swift | All tasks placeholder |
| Tangentle/Features/Calendar/CalendarView.swift | Calendar placeholder |
| Tangentle/Features/Strategies/StrategiesView.swift | Strategies placeholder |
| Tangentle/Features/Settings/SettingsView.swift | Settings view |
| Tangentle/UI/Components/TaskRow.swift | Reusable task row component |
| Tangentle/Core/Services/SeedDataService.swift | Seed data service for first launch |
| TangentleTests/Unit/TestHelpers.swift | Test utilities, in-memory Core Data stack |
| TangentleTests/Unit/TaskRepositoryTests.swift | Repository tests |
| TangentleTests/Unit/StrategyServiceTests.swift | Service tests |
| TangentleTests/Unit/TodayViewModelTests.swift | ViewModel tests |

## Plan Complete

All 12 steps have been completed successfully. The Tangentle iOS Foundation is ready.

## Generated Prompts
All prompts are self-contained with complete context:

| Step | File | Focus |
|------|------|-------|
| 1 | `01-project-setup.prompt.md` | Xcode project creation |
| 2 | `02-claude-workflow.prompt.md` | Documentation files |
| 3 | `03-core-data-models.prompt.md` | 14 entities, relationships |
| 4 | `04-model-extensions.prompt.md` | Enums, computed properties |
| 5 | `05-repository-protocol.prompt.md` | Generic CRUD protocol |
| 6 | `06-repositories.prompt.md` | 11 concrete repositories |
| 7 | `07-di-container.prompt.md` | DI container setup |
| 8 | `08-services-layer.prompt.md` | Business logic services |
| 9 | `09-ai-service-protocol.prompt.md` | AI service stubs |
| 10 | `10-app-shell.prompt.md` | Tab navigation, views |
| 11 | `11-seed-data.prompt.md` | Default data seeding |
| 12 | `12-testing-setup.prompt.md` | Swift Testing |

## Things to Remember
- iOS 17.0 minimum deployment target
- Use Swift 5.9+ features (@Observable)
- All entities use UUID (not auto-increment)
- Transformable arrays use NSSecureUnarchiveFromData
- API key via environment: CLAUDE_API_KEY
- 18 default strategies to seed

## Dependencies
- Xcode 15.0+
- macOS Sonoma or later
- Apple Developer account (optional, for device testing)
- Claude API key (for AI coaching features)

## Related Documentation
- See executive-brain for original domain concepts
- See docs/ARCHITECTURE.md for detailed architecture
- See docs/DATA-MODEL.md for entity documentation
