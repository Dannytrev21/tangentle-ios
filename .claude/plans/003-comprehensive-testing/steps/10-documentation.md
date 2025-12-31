# Step 10: Documentation (TESTING.md)

## Context
This is the final step. All testing infrastructure is in place, tests are written, and patterns are established. Now we document everything in TESTING.md so future contributors can easily add and maintain tests.

## Goal
Create a comprehensive TESTING.md document that serves as the canonical guide for testing in Tangentle iOS.

## Prerequisites
- Steps 1-9 completed (all testing patterns established)

## High-Level Steps
1. Create TESTING.md with all sections
2. Include code examples from actual tests
3. Document CI/CD setup recommendations
4. Add troubleshooting section
5. Update CLAUDE.md to reference TESTING.md

## Detailed Requirements

### TESTING.md Structure

```markdown
# Testing Guide for Tangentle iOS

This document is the canonical guide for testing in Tangentle iOS. It covers all testing types, patterns, and best practices.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Test Architecture](#test-architecture)
3. [Running Tests](#running-tests)
4. [Unit Tests](#unit-tests)
5. [Integration Tests](#integration-tests)
6. [Snapshot Tests](#snapshot-tests)
7. [UI/E2E Tests](#uie2e-tests)
8. [Performance Tests](#performance-tests)
9. [Contract Tests](#contract-tests)
10. [Test Data](#test-data)
11. [Mocking](#mocking)
12. [CI/CD Integration](#cicd-integration)
13. [Coverage](#coverage)
14. [Troubleshooting](#troubleshooting)
15. [Adding New Tests](#adding-new-tests)
```

### Section: Quick Start
```markdown
## Quick Start

### Run All Tests
```bash
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run Specific Test Suite
```bash
# Unit tests only
xcodebuild test ... -only-testing:TangentleTests/Unit

# Integration tests only
xcodebuild test ... -only-testing:TangentleTests/Integration

# Snapshot tests only
xcodebuild test ... -only-testing:TangentleTests/Snapshots

# UI tests only
xcodebuild test ... -only-testing:TangentleUITests

# Performance tests only
xcodebuild test ... -only-testing:TangentleTests/Performance
```

### Run Single Test File
```bash
xcodebuild test ... -only-testing:TangentleTests/Unit/Repositories/TaskRepositoryTests
```
```

### Section: Test Architecture
Document the test directory structure, frameworks used, and coverage targets.

### Section: Unit Tests
Include:
- Repository test pattern
- Service test pattern
- ViewModel test pattern
- When to use Swift Testing vs XCTest

### Section: Integration Tests
Include:
- Core Data relationship testing
- Service integration patterns
- When integration tests are appropriate

### Section: Snapshot Tests
Include:
- How to add new component snapshots
- How to update baselines
- Theme testing
- Device size matrix

### Section: UI/E2E Tests
Include:
- Page Object pattern explanation
- Adding new page objects
- Writing flow tests
- Handling test data

### Section: Performance Tests
Include:
- When to add performance tests
- How to seed test data
- Understanding metrics
- Baseline management

### Section: Contract Tests
Include:
- AI service contract testing
- Request/response shape validation

### Section: Test Data
Include:
- TestCoreDataStack usage
- Factory methods
- JSON fixtures
- FakeDataGenerator

### Section: Mocking
Include:
- Mock repository pattern
- Mock service pattern
- Configuring mock responses
- Verifying mock calls

### Section: CI/CD Integration
Include:
- Recommended GitHub Actions setup
- Xcode Cloud setup
- Parallelization options
- Caching strategies

### Section: Coverage
Include:
- Coverage targets by layer
- How to measure coverage
- Coverage reporting

### Section: Troubleshooting
Include:
- Common test failures and solutions
- Flaky test debugging
- Snapshot test failures
- UI test element not found

### Section: Adding New Tests
Checklists for adding tests when:
- Creating a new repository
- Creating a new service
- Creating a new ViewModel
- Creating a new UI component
- Creating a new screen

## Content to Include

### Example Code Snippets
Pull actual examples from:
- `TangentleTests/Unit/Repositories/TaskRepositoryTests.swift`
- `TangentleTests/Unit/Services/StrategyServiceTests.swift`
- `TangentleTests/Unit/ViewModels/TodayViewModelTests.swift`
- `TangentleTests/Integration/CoreData/`
- `TangentleTests/Snapshots/`
- `TangentleUITests/`
- `TangentleTests/Performance/`

### Naming Conventions
```
Unit Tests:      test{Method}_when{Condition}_should{Expected}()
Integration:     test{ComponentA}IntegratesWith{ComponentB}()
Snapshot:        test{Component}_{State}_{Theme}()
UI:              test{UserAction}_should{VisibleResult}()
Performance:     test{Operation}_performance()
```

### Coverage Targets Table
| Layer | Target | Current | Notes |
|-------|--------|---------|-------|
| Repositories | 90% | TBD | Data access layer |
| Services | 85% | TBD | Business logic |
| ViewModels | 80% | TBD | UI state |
| Components | N/A | 17/17 | Snapshot count |
| Flows | N/A | 2/2 | E2E test count |

## Files to Create
- `docs/TESTING.md`

## Files to Modify
- `CLAUDE.md` - Add reference to TESTING.md in documentation table

## Patterns to Follow
Reference: All test files created in Steps 1-9
Reference: `CLAUDE.md` for documentation style

## Acceptance Criteria
- [ ] TESTING.md created with all sections
- [ ] Code examples are accurate and runnable
- [ ] All test types documented
- [ ] CI/CD recommendations included
- [ ] Troubleshooting section is practical
- [ ] New test checklists are complete
- [ ] CLAUDE.md references TESTING.md
- [ ] Document is well-formatted and readable

## Testing Requirements
**N/A - Reason**: This step creates documentation only.
**Manual Verification**:
- All code examples compile
- Links in table of contents work
- Examples match actual test patterns

## Verification Commands
```bash
# Verify documentation doesn't break anything
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Check markdown rendering (preview in editor)
```

## Documentation Updates
- This step IS the documentation update

## Error Recovery
If verification fails:
1. Check code examples are syntactically correct
2. Verify file paths in examples match actual structure
3. Ensure markdown formatting is valid

## Do NOT
- Include outdated examples
- Skip any testing type
- Make claims about coverage without verification
- Include time estimates for writing tests
- Over-complicate instructions
