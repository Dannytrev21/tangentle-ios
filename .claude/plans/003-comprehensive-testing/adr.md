# ADR: Comprehensive Testing Infrastructure

## Status
Proposed

## Context
Tangentle iOS is an ADHD task management app that requires high reliability and smooth user experience. The current codebase has:
- 15 repositories (1 tested)
- 7 services (1 tested)
- 1 ViewModel (tested)
- 17 UI components (0 snapshot tested)
- 0 UI/E2E tests
- 0 performance tests

Users with ADHD are particularly sensitive to:
- App crashes and data loss (trust issues)
- UI lag and unresponsiveness (attention drift)
- Unexpected behavior changes (cognitive load)

A comprehensive testing strategy is essential to:
1. Catch regressions before they reach users
2. Enable confident refactoring as the app grows
3. Document expected behavior for future contributors
4. Prepare for CI/CD automation

## Tree of Thought Analysis

### Decision 1: Primary Testing Framework

**Context**: Swift Testing is Apple's modern testing framework (iOS 17+), while XCTest is the mature, full-featured option.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Swift Testing only | Use @Test, @Suite, #expect everywhere | Modern syntax, better error messages, parameterized tests | No performance testing, limited UI test integration |
| XCTest only | Use XCTestCase everywhere | Full feature set, mature, all test types supported | Verbose, older patterns |
| Hybrid approach | Swift Testing for unit/integration, XCTest for performance/UI | Best of both worlds | Two syntaxes to learn |

**Decision**: Hybrid approach
**Rationale**:
- Existing tests already use Swift Testing successfully
- Performance tests require XCTest's `measure {}` block
- XCUITest is XCTest-based by design
- Modern syntax for the majority of tests (unit/integration)

### Decision 2: Snapshot Testing Library

**Context**: Apple doesn't provide a snapshot testing framework. Third-party options exist.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| swift-snapshot-testing | Point-Free's library | Multiple strategies (image, text, JSON), SwiftUI support, actively maintained | Third-party dependency |
| iOSSnapshotTestCase | Uber's fork of Facebook's lib | Proven, stable | Image-only, less maintained, no SwiftUI helpers |
| No snapshots | Skip visual regression testing | No dependencies | Miss visual regressions, rely on manual QA |

**Decision**: swift-snapshot-testing
**Rationale**:
- SwiftUI-first support with `assertSnapshot(of: view, as: .image)`
- Multiple snapshot strategies (image for visual, dump for structure)
- Active maintenance and community adoption
- Record mode makes creating baselines easy
- Can snapshot specific device sizes/traits

### Decision 3: Test Data Strategy

**Context**: Tests need data. The approach affects test reliability and maintenance.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Factories only | TestCoreDataStack pattern (existing) | Simple, fast, deterministic | Limited for complex scenarios |
| JSON fixtures | Load predefined data from files | Realistic, reproducible, shareable | Maintenance overhead, can become stale |
| Faker library | Generate random but realistic data | Edge case discovery, variety | Non-deterministic by default, can cause flaky tests |
| Combination | Use appropriate tool for each situation | Maximum flexibility | More infrastructure |

**Decision**: Combination approach
**Rationale**:
- Factories (existing) for simple unit tests - fast and deterministic
- JSON fixtures for complex integration scenarios (e.g., strategy coaching flow with multiple outcomes)
- Faker-style helpers for property-based testing and edge case discovery
- Each approach serves different testing needs

### Decision 4: Mock Implementation Strategy

**Context**: Services depend on repositories via protocols. Mocks are needed for isolated testing.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Manual protocol mocks | Hand-written mock classes | Full control, no dependencies, explicit | Boilerplate code |
| Mocking framework | Mockingbird, Cuckoo, etc. | Less code, auto-generation | Build complexity, learning curve, generated code |
| Protocol stubs with closures | Inject behavior via closures | Flexible per-test customization | Moderate boilerplate |

**Decision**: Manual protocol mocks
**Rationale**:
- Protocol-based DI already established (TestContainer pattern)
- No external dependencies for core testing
- Explicit mock behavior is easier to understand
- MockAIService already exists as a pattern
- Team can see exactly what mocks do

### Decision 5: AI Service Testing Strategy

**Context**: The app uses Claude API for coaching and Gemini API for scheduling. These are external dependencies.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Mocks only | Mock all AI responses | Fast, deterministic, offline | May miss API changes |
| Record/replay | Capture and replay real responses | Realistic | Storage, staleness, may contain sensitive data |
| Contract tests | Verify request/response shapes | Catches schema changes | Doesn't test actual responses |
| Live tests | Hit real APIs in test | Most realistic | Slow, costs money, flaky, requires keys |

**Decision**: Mocks + Contract tests (live tests later)
**Rationale**:
- Mocks for unit tests (fast, deterministic, offline)
- Contract tests to verify request/response shapes match expected API contracts
- Prevents tests from becoming flaky due to network/API issues
- Live tests can be added later as a separate, optional test plan
- No API keys required in CI

### Decision 6: UI Test Approach

**Context**: UI tests need to be reliable and maintainable.

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| Direct XCUITest | Query elements directly in tests | Simple, built-in | Brittle, duplicate queries |
| Page Object pattern | Abstract UI structure into page objects | Maintainable, reusable | More code upfront |
| No UI tests | Rely on manual QA | No flaky tests | Miss regressions, slow feedback |

**Decision**: Page Object pattern
**Rationale**:
- Abstracts UI structure from test logic
- Single place to update when UI changes
- Tests read like user stories
- Standard pattern in mobile testing

## Decision Summary

| Area | Decision | Key Rationale |
|------|----------|---------------|
| Framework | Swift Testing + XCTest hybrid | Modern syntax + full feature set |
| Snapshots | swift-snapshot-testing | SwiftUI support, multiple strategies |
| Test Data | Factories + Fixtures + Faker | Right tool for each job |
| Mocks | Manual protocol mocks | Explicit, no dependencies |
| AI Testing | Mocks + Contract tests | Fast, deterministic, validates contracts |
| UI Tests | Page Object pattern | Maintainable, readable |

## Consequences

### Positive
- Comprehensive coverage across all testing types
- Modern testing patterns with Swift Testing
- Visual regression protection with snapshots
- Fast, deterministic tests for CI
- Contract tests catch API changes early
- Well-documented patterns in TESTING.md

### Negative
- swift-snapshot-testing adds a dependency
- Initial investment to write all tests
- Two testing syntaxes to learn (Swift Testing + XCTest)
- Mock maintenance as protocols evolve
- Snapshot baselines need periodic updates

### Mitigations
- swift-snapshot-testing is a test-only dependency (not in production)
- Step-by-step implementation allows incremental progress
- Document when to use which framework in TESTING.md
- Generate mocks alongside protocol changes
- CI can detect snapshot drift automatically
