# Step 3b: Supporting Repository Unit Tests

## Context
This step covers the remaining 10 repositories that support the core functionality: Routine, Habit, FocusMode, Mode, ProblemType, Tag, Settings, and outcome tracking repositories.

## Goal
Complete unit test coverage for the remaining 10 repositories with 90%+ coverage target.

## Prerequisites
- Step 1 completed (directory structure, helpers)
- Step 3a completed (establishes patterns)
- Note: Does NOT require Step 2 (mocks) - repository tests use real in-memory Core Data

## High-Level Steps
1. Create tests for Routine and RoutineStep repositories
2. Create tests for Habit and HabitCompletion repositories
3. Create tests for FocusMode and Mode repositories
4. Create tests for ProblemType, Tag, Settings repositories
5. Create tests for StrategyOutcome repository
6. Verify 90%+ coverage for all 10 repositories

## Detailed Requirements

### Repositories to Test

#### 1. RoutineRepository
Tests needed:
- `create()` creates valid routine
- `fetchEnabled()` excludes disabled routines
- `fetchByType()` filters by routine type (morning, evening, custom)
- `fetchScheduledForToday()` returns routines matching day of week
- `delete()` removes routine
- Edge cases: no routines for type, routine with no steps

#### 2. RoutineStepRepository
Tests needed:
- `create()` creates valid step
- `fetchByRoutine()` returns steps for routine in order
- `fetchByRoutine()` returns empty for routine with no steps
- Order is preserved across fetch operations
- Edge cases: routine with many steps

#### 3. HabitRepository
Tests needed:
- `create()` creates valid habit
- `fetchActive()` returns active habits only
- `fetchDueToday()` returns habits due today based on frequency
- `fetchDueToday()` handles daily vs weekly correctly
- `fetchByFrequency()` filters by frequency type
- `delete()` removes habit
- Edge cases: no habits due today, all habits inactive

#### 4. HabitCompletionRepository
Tests needed:
- `create()` creates valid completion record
- `fetchByHabit()` returns completions for specific habit
- `fetchForDate(date:habit:)` filters by both date and habit
- `fetchForDate(date:habit:)` returns empty when no completion exists
- Edge cases: habit with no completions, multiple completions same day

#### 5. FocusModeRepository
Tests needed:
- `create()` creates valid focus mode
- `fetchActive()` returns active modes only
- `fetchAutomatic()` returns auto-triggered modes
- `fetchCurrentlyActive()` returns mode active at current time
- `fetchCurrentlyActive()` returns nil when no mode active
- Edge cases: overlapping time ranges, no modes defined

#### 6. ModeRepository
Tests needed:
- `create()` creates valid mode
- `fetchDefault()` returns the default mode
- `fetchDefault()` returns nil when no default set
- `fetchAll()` returns all modes
- Setting a new default unsets previous default
- Edge cases: no modes defined

#### 7. ProblemTypeRepository
Tests needed:
- `create()` creates valid problem type
- `fetchAll()` returns all problem types
- `fetchByIdentifier()` finds by unique identifier
- `fetchByIdentifier()` returns nil for unknown identifier
- `fetchDefaults()` returns built-in ADHD problem types
- Edge cases: duplicate identifiers should be prevented

#### 8. TagRepository
Tests needed:
- `create()` creates valid tag
- `fetchAll()` returns all tags
- `fetchOrCreate()` returns existing tag if name matches
- `fetchOrCreate()` creates new tag if name doesn't exist
- `fetchByName()` finds by name (case sensitivity?)
- `fetchByName()` returns nil for unknown name
- Edge cases: empty name handling, very long names

#### 9. SettingsRepository
Tests needed:
- `getSettings()` returns existing settings
- `getSettings()` creates settings if none exist (singleton)
- `updateSettings()` persists changes
- Multiple calls to `getSettings()` return same entity
- Edge cases: first launch (no settings)

#### 10. StrategyOutcomeRepository
Tests needed:
- `create()` creates valid outcome
- `fetchByStrategy()` returns outcomes for strategy
- `fetchByStrategy()` returns empty for strategy with no outcomes
- `fetchRecent(limit:)` orders by date descending
- `fetchRecent(limit:)` respects limit parameter
- Edge cases: strategy with many outcomes

## Files to Create
- `TangentleTests/Unit/Repositories/RoutineRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/RoutineStepRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/HabitRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/HabitCompletionRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/FocusModeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/ModeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/ProblemTypeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/TagRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/SettingsRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/StrategyOutcomeRepositoryTests.swift`

## Files to Modify
- None (all new files)

## Patterns to Follow
Reference: Step 3a repository tests for established patterns
Reference: `TangentleTests/Unit/TestHelpers.swift` for factory methods

## Acceptance Criteria
- [ ] All 10 repository test files created
- [ ] Each repository has tests for all protocol methods
- [ ] Edge cases tested (empty, null, duplicates)
- [ ] 90%+ line coverage for all repositories
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- Test files: See "Files to Create" above
- Minimum 50+ tests total across 10 repositories

### What to Test
- CRUD operations
- Custom query methods
- Filtering and sorting
- Edge cases

## Verification Commands
```bash
# Run supporting repository tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/Repositories

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- None for this step

## Error Recovery
If verification fails:
1. Check Core Data model for entity attributes
2. Verify factory methods in TestHelpers cover all entities
3. Check relationship configurations
4. Ensure async operations complete before assertions

## Do NOT
- Test Core Data itself
- Write integration tests (Step 6)
- Add new repository methods
- Modify production code
