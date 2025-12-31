# Step 1: Test Infrastructure Setup

## Context
Before writing tests, we need the proper infrastructure in place. This includes:
- Adding swift-snapshot-testing as a dependency
- **Creating the TangentleUITests target** (doesn't exist yet)
- Reorganizing test directories to match planned structure
- Extending test helpers with additional utilities

## Goal
Establish the foundation for all testing types with proper directory structure, dependencies, test targets, and helper utilities.

## Prerequisites
- None (first step)

## High-Level Steps
1. **Create TangentleUITests target in Xcode project**
2. Add swift-snapshot-testing via Swift Package Manager
3. Create test directory structure
4. Extend TestHelpers.swift with additional factories
5. Create TestFixtures infrastructure for JSON loading
6. Create FakeDataGenerator for randomized test data
7. Verify build succeeds with new dependencies

## Detailed Requirements

### TangentleUITests Target Setup (CRITICAL)
The UI test target does not currently exist and must be created:

1. In Xcode, select File → New → Target
2. Choose "UI Testing Bundle"
3. Name it "TangentleUITests"
4. Set target to test: "Tangentle"
5. Language: Swift
6. This creates:
   - `TangentleUITests/` directory
   - `TangentleUITests/TangentleUITests.swift` (default test file)
   - `TangentleUITests/TangentleUITestsLaunchTests.swift` (launch test)

Alternatively via xcodegen or manual pbxproj editing if preferred.

### Swift Package Manager Setup
Add swift-snapshot-testing to the project:
- Package URL: `https://github.com/pointfreeco/swift-snapshot-testing`
- Version: 1.15.0 or later
- Link to TangentleTests target only (not main app, not TangentleUITests)

### Directory Structure
Create the following directory structure under TangentleTests/:
```
TangentleTests/
├── Unit/
│   ├── Repositories/   # Move existing TaskRepositoryTests.swift here
│   ├── Services/       # Move existing StrategyServiceTests.swift here
│   └── ViewModels/     # Move existing TodayViewModelTests.swift here
├── Integration/
│   ├── CoreData/
│   └── Services/
├── Snapshots/
│   ├── Components/
│   └── Screens/
├── Performance/
├── Contract/
├── Mocks/
├── TestHelpers/        # Move TestHelpers.swift here, add new helpers
└── Fixtures/           # JSON fixtures for complex scenarios
```

### Extended TestHelpers
Add factory methods for all entity types:
- `createGoal(title:targetDate:)` -> TGGoal
- `createRoutine(name:type:scheduledTime:)` -> TGRoutine
- `createRoutineStep(title:order:routine:)` -> TGRoutineStep
- `createHabit(name:frequency:)` -> TGHabit
- `createHabitCompletion(habit:date:)` -> TGHabitCompletion
- `createFocusMode(name:startTime:endTime:)` -> TGFocusMode
- `createMode(name:isDefault:)` -> TGMode
- `createProblemType(identifier:name:)` -> TGProblemType
- `createTag(name:)` -> TGTag
- `createSettings()` -> TGSettings
- `createStrategyOutcome(strategy:result:)` -> TGStrategyOutcome

### TestFixtures Infrastructure
Create a system for loading JSON fixtures:
```swift
struct TestFixtures {
    static func load<T: Decodable>(_ filename: String) throws -> T
    static func loadTasks(_ filename: String) throws -> [TaskFixture]
    static func loadStrategies(_ filename: String) throws -> [StrategyFixture]
}
```

### FakeDataGenerator
Create a faker-style utility for generating test data:
```swift
struct FakeData {
    static func taskTitle() -> String
    static func projectName() -> String
    static func email() -> String
    static func pastDate(within days: Int) -> Date
    static func futureDate(within days: Int) -> Date
    static func duration() -> Int16
    static func priority() -> Priority
    static func energyLevel() -> EnergyLevel
}
```

## Files to Create
- `TangentleUITests/` directory (via Xcode target creation)
- `TangentleTests/TestHelpers/TestHelpers.swift` (moved and extended)
- `TangentleTests/TestHelpers/TestFixtures.swift`
- `TangentleTests/TestHelpers/FakeDataGenerator.swift`
- `TangentleTests/Fixtures/.gitkeep` (placeholder for JSON fixtures)

## Files to Modify
- `Tangentle.xcodeproj/project.pbxproj` - Add SPM dependency, add UI test target
- Move existing test files to new directory structure

## Patterns to Follow
Reference: `TangentleTests/Unit/TestHelpers.swift` lines 1-89 for existing factory pattern

## Acceptance Criteria
- [ ] **TangentleUITests target created and builds**
- [ ] swift-snapshot-testing added as SPM dependency
- [ ] Directory structure matches specification
- [ ] Existing tests moved to appropriate directories
- [ ] TestHelpers extended with all entity factory methods
- [ ] TestFixtures infrastructure created
- [ ] FakeDataGenerator created with basic methods
- [ ] `xcodebuild build` succeeds (both test targets)
- [ ] `xcodebuild test` passes (existing tests still work)
- [ ] `xcodebuild test -only-testing:TangentleUITests` runs (even if empty)

## Testing Requirements
This step creates test infrastructure, not testable code. Verification is that existing tests still pass.

### What to Test
- Build succeeds with new dependency
- Existing tests pass in new locations
- New helper methods compile correctly

## Verification Commands
```bash
# Build project with new dependencies
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Run existing tests to verify they work in new structure
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- None for this step (TESTING.md created in Step 10)

## Error Recovery
If verification fails:
1. Check SPM dependency resolution errors
2. Verify import statements updated in moved files
3. Check target membership of moved files
4. Ensure TestCoreDataStack still finds Core Data model

## Do NOT
- Add snapshot tests yet (Step 7)
- Write new tests beyond infrastructure (Steps 3-6)
- Modify production code
- Change existing test logic (only locations)
