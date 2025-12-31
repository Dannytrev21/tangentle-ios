# Plan 003: Comprehensive Testing Infrastructure

## Overview
Establish a complete testing strategy for Tangentle iOS covering unit, integration, component, UI, snapshot, performance, and contract testing. This includes creating a TESTING.md documentation file that serves as the canonical guide for adding new tests, ensuring consistency and best practices across the codebase.

## Status
- **Created**: 2025-12-22
- **Reviewed**: 2025-12-22
- **Status**: Not Started
- **Current Step**: 0 of 11

## Tree of Thought Analysis

### What are we building?
A comprehensive testing infrastructure that includes:
1. **Unit Tests**: For all repositories (15), services (7), and ViewModels
2. **Integration Tests**: Core Data operations, service interactions
3. **Snapshot Tests**: UI components (17) using swift-snapshot-testing
4. **UI/E2E Tests**: Critical user flows (task completion, strategy coaching)
5. **Performance Tests**: Data layer operations benchmarks
6. **Contract Tests**: AI service request/response validation
7. **Test Data Infrastructure**: Factories, fixtures, faker utilities
8. **Documentation**: TESTING.md comprehensive guide

### Why are we building it?
- **Quality Assurance**: Catch regressions before they reach users
- **ADHD User Sensitivity**: Users are sensitive to bugs and lag; comprehensive testing ensures smooth UX
- **Maintainability**: Tests document expected behavior and enable safe refactoring
- **Confidence**: Enable rapid iteration with confidence
- **Onboarding**: New contributors can understand the codebase through tests
- **CI/CD Ready**: Prepare for automated testing pipeline

### Key Decisions

#### Decision 1: Testing Framework Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Swift Testing only | Modern, unified syntax | No performance testing, limited UI test support |
| B | XCTest only | Full feature set, mature | Verbose syntax, older patterns |
| C | Swift Testing + XCTest hybrid | Best of both: modern syntax where applicable, XCTest for performance/UI | Two syntaxes to learn |

**Selected: Option C** - Swift Testing for unit/integration tests (modern `@Test`, `@Suite`, `#expect`), XCTest for performance tests (`measure {}`) and XCUITest for UI tests. This matches existing codebase patterns and leverages each framework's strengths.

#### Decision 2: Snapshot Testing Library

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | swift-snapshot-testing (Point-Free) | Multiple strategies, well-maintained, SwiftUI support | Third-party dependency |
| B | iOSSnapshotTestCase (Uber) | Stable, proven | Image-only, less maintained |
| C | No snapshots | No dependencies | Miss visual regressions |

**Selected: Option A** - swift-snapshot-testing provides the most flexibility with image, text, and custom snapshot strategies. Strong SwiftUI support and active maintenance. Already widely adopted in the iOS community.

#### Decision 3: Test Data Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Factories only | Simple, existing pattern | Limited for complex scenarios |
| B | JSON fixtures | Realistic data, reproducible | Maintenance overhead |
| C | Faker library | Random but realistic | Non-deterministic by default |
| D | All approaches | Right tool for each job | More infrastructure to maintain |

**Selected: Option D** - Use factories (existing) for simple cases, add JSON fixtures for complex scenarios (e.g., strategy coaching flows), and optionally integrate a faker for edge cases. This provides maximum flexibility.

#### Decision 4: Mock Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Manual protocol mocks | Full control, no dependencies | Boilerplate |
| B | Mocking framework (Mockingbird, Cuckoo) | Less boilerplate | Build-time generation, complexity |
| C | Protocol stubs with closures | Flexible, lightweight | Some boilerplate |

**Selected: Option A** - Manual protocol mocks. The codebase already uses protocol-based DI extensively, making manual mocks straightforward. TestContainer already demonstrates this pattern. Avoid external dependencies for mocking.

#### Decision 5: AI Service Testing

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Mocks only | Fast, deterministic | May miss API changes |
| B | Record/replay | Realistic responses | Storage overhead, may become stale |
| C | Contract tests | Verify shapes, no real calls | Doesn't test actual responses |
| D | Mocks + Contract tests | Best of both | More code to maintain |

**Selected: Option D** - Use mocks for unit tests (fast, deterministic) and contract tests to verify request/response shapes match expected API contracts. Add live tests later as an optional test target.

### Testing Strategy

| Test Type | Scope | Files | Priority |
|-----------|-------|-------|----------|
| Unit | Repositories, Services, ViewModels | TangentleTests/Unit/ | Required |
| Integration | Core Data relationships, Service chains | TangentleTests/Integration/ | Required |
| Snapshot | UI Components (17 components) | TangentleTests/Snapshots/ | Required |
| UI/E2E | Task flow, Strategy coaching flow | TangentleUITests/ | Required |
| Performance | Repository queries, large datasets | TangentleTests/Performance/ | Required |
| Contract | AI service request/response shapes | TangentleTests/Contract/ | Required |

### Coverage Targets

| Layer | Target | Rationale |
|-------|--------|-----------|
| Repositories | 90%+ | Data layer is critical, well-defined interfaces |
| Services | 85%+ | Business logic must be thoroughly tested |
| ViewModels | 80%+ | State management and UI logic |
| Views/UI | N/A (measured by component count) | Snapshot coverage, not line coverage |

## Implementation Steps

| Step | Name | Description | Status |
|------|------|-------------|--------|
| 1 | Test Infrastructure Setup | Add swift-snapshot-testing, create TangentleUITests target, reorganize directories, create helpers | Pending |
| 2 | Mock Infrastructure | Create mock implementations for all protocols | Pending |
| 3a | Core Repository Unit Tests | Unit tests for Task, Project, Goal, Strategy repositories | Pending |
| 3b | Supporting Repository Unit Tests | Unit tests for remaining 10 repositories | Pending |
| 4 | Service Unit Tests | Unit tests for all 7 services including AI contract tests | Pending |
| 5 | ViewModel Unit Tests | Tests for TodayViewModel and future ViewModels | Pending |
| 6 | Integration Tests | Core Data relationships, service chains | Pending |
| 7 | Snapshot Tests | Snapshots for all 17 UI components | Pending |
| 8 | UI/E2E Tests | Task completion flow, Strategy coaching flow (requires accessibility identifiers) | Pending |
| 9 | Performance Tests | Repository query benchmarks | Pending |
| 10 | Documentation | TESTING.md guide with patterns and examples | Pending |

**Note**: Step 3 split into 3a/3b for manageable scope. Steps 3a, 3b, and 7 can run in parallel after Step 1.

## Files to Create

### Test Infrastructure
- `TangentleTests/TestHelpers/TestFixtures.swift` - JSON fixture loading utilities
- `TangentleTests/TestHelpers/FakeDataGenerator.swift` - Faker-style data generation
- `TangentleTests/Mocks/MockRepositories.swift` - All repository mocks
- `TangentleTests/Mocks/MockServices.swift` - All service mocks

### Unit Tests (Repositories)
- `TangentleTests/Unit/Repositories/ProjectRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/GoalRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/StrategyRepositoryTests.swift`
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

### Unit Tests (Services)
- `TangentleTests/Unit/Services/TaskServiceTests.swift`
- `TangentleTests/Unit/Services/ScheduleServiceTests.swift`
- `TangentleTests/Unit/Services/SettingsServiceTests.swift`
- `TangentleTests/Unit/Services/AIServiceTests.swift`
- `TangentleTests/Unit/Services/SeedDataServiceTests.swift`

### Integration Tests
- `TangentleTests/Integration/CoreData/TaskProjectRelationshipTests.swift`
- `TangentleTests/Integration/CoreData/StrategyScoringIntegrationTests.swift`
- `TangentleTests/Integration/CoreData/CascadeDeleteTests.swift`
- `TangentleTests/Integration/Services/TaskServiceIntegrationTests.swift`

### Snapshot Tests
- `TangentleTests/Snapshots/Components/AnimatedCheckboxSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/TaskCardSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/TabBarSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/BadgeSnapshotTests.swift`
- `TangentleTests/Snapshots/Components/SwipeableRowSnapshotTests.swift`
- `TangentleTests/Snapshots/Screens/TodayViewSnapshotTests.swift`

### UI Tests
- `TangentleUITests/Flows/TaskFlowTests.swift`
- `TangentleUITests/Flows/StrategyCoachingFlowTests.swift`
- `TangentleUITests/Helpers/UITestHelpers.swift`
- `TangentleUITests/Pages/TodayPage.swift` (Page Object pattern)

### Performance Tests
- `TangentleTests/Performance/RepositoryPerformanceTests.swift`

### Contract Tests
- `TangentleTests/Contract/AIServiceContractTests.swift`

### Documentation
- `docs/TESTING.md` - Comprehensive testing guide

## Files to Modify
- `Tangentle.xcodeproj/project.pbxproj` - Add swift-snapshot-testing dependency, organize test targets
- `TangentleTests/Unit/TestHelpers.swift` - Extend with additional factory methods
- `CLAUDE.md` - Reference TESTING.md in documentation section

## Dependencies
- Step 1 must complete before any other steps (infrastructure + UI test target)
- Step 2 must complete before Steps 4-5 (mocks needed for service/ViewModel unit tests)
- Steps 3a, 3b use real Core Data, only need Step 1 (not mocks)
- Steps 3a, 3b, and 7 can proceed in parallel after Step 1
- Step 4 requires Step 2 (service tests use mocked repositories)
- Step 5 requires Step 2 (ViewModel tests use mocked services)
- Step 6 requires Steps 1, 3a, and 4 (integration uses real repos + services)
- Step 7 can proceed after Step 1 (only needs snapshot library)
- Step 8 requires Step 1 (UI test target) + accessibility identifiers added to components
- Step 9 requires Step 3a (repository tests define patterns)
- Step 10 should be done last to capture final patterns

### Parallel Execution Opportunities
```
After Step 1:
├── Step 2 (Mocks) ──────────> Steps 4, 5
├── Step 3a (Core Repos) ────> Step 6, 9
├── Step 3b (Other Repos)
└── Step 7 (Snapshots)
```

## Success Criteria
- [ ] swift-snapshot-testing added as SPM dependency
- [ ] TangentleUITests target created and configured
- [ ] Test directory structure matches planned organization
- [ ] All 15 repositories have unit tests (90%+ coverage)
- [ ] All 7 services have unit tests (85%+ coverage)
- [ ] TodayViewModel has comprehensive tests (80%+ coverage)
- [ ] Integration tests cover Core Data relationships and cascades
- [ ] Snapshot tests cover all 17 UI components
- [ ] UI components have accessibility identifiers
- [ ] UI tests cover task completion and strategy coaching flows
- [ ] Performance tests benchmark critical repository operations
- [ ] Contract tests validate AI service request/response shapes
- [ ] TESTING.md provides complete guidance for adding new tests
- [ ] All tests pass: `xcodebuild test -scheme Tangentle`
- [ ] Test suite completes in < 5 minutes

## Revision History
| Date | Changes |
|------|---------|
| 2025-12-22 | Initial plan created |
| 2025-12-22 | Review: Split Step 3, added UI test target to Step 1, fixed dependencies |

## Rollback Plan
1. If swift-snapshot-testing causes build issues, remove from Package.swift and delete snapshot tests
2. If UI tests are flaky, quarantine them in a separate test plan
3. If performance tests cause CI timeouts, move to optional test plan
4. Each step creates tests in isolation - can rollback individual test files without affecting others
