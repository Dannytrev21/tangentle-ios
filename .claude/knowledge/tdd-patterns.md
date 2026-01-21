# TDD Patterns for Claude Code

**"The robots LOVE TDD."** - Community consensus

Test-driven development provides Claude with verifiable objectives, eliminating ambiguity about success criteria and reducing hallucination significantly.

## The Six-Step TDD Workflow

### 1. Write Failing Tests First
```
Write tests for the UserAuth module based on these expected input/output pairs.
We're doing TDD—don't create mock implementations.
```

Be explicit about test-first approach to prevent Claude from writing implementation.

### 2. Confirm Tests Fail
```
Run the tests and confirm they fail. Don't write any implementation code at this stage.
```

This verifies tests are actually testing something.

### 3. Commit the Tests
```
Commit these tests once you're satisfied with coverage.
```

Checkpoint before implementation.

### 4. Implement to Pass
```
Write code that passes the tests. Don't modify the tests.
Keep going until all tests pass.
```

Tests are the specification—implementation conforms to them.

### 5. Verify with Subagent (Optional)
```
Use a subagent to verify the implementation isn't overfitting to tests.
```

Fresh eyes catch edge cases.

### 6. Commit Implementation
```
Commit the code once all tests pass.
```

Lock in verified work.

## Pre-Commit Hooks

Use pre-commit hooks to catch errors before they propagate:

```bash
# Install pre-commit
pip install pre-commit

# Example .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: lint
        name: Lint
        entry: npm run lint
        language: system
      - id: test
        name: Test
        entry: npm run test
        language: system
```

**"The robot REALLLLLY wants to commit"** - Hooks catch errors early.

## For Existing Code Modifications

Add this rule to CLAUDE.md:

```markdown
## Existing Code Rule
When modifying existing functions:
1. Ensure a unit test exists first
2. Create one if none exists
3. Then modify the function
4. Run tests to verify changes
```

## Coverage Guidelines

### Aim for 80%+ Coverage
- Focus on business logic
- Test edge cases
- Test error handling

### What to Test
- Public interfaces
- Business rules
- Error conditions
- Integration points
- Edge cases

### What Not to Test
- Private implementation details
- Framework code
- Trivial getters/setters
- External services (mock instead)

## TDD in the Planning System

### Technique Assignment
TDD is a primary implementation technique for:
- `unit-test` problem type
- `integration-test` problem type
- High-risk implementation steps
- Steps modifying existing code

### In Step Prompts
Prompts include TDD instructions:
```markdown
## Testing Requirements
Following TDD methodology:
1. Write failing tests for {feature}
2. Run tests to confirm failure
3. Implement to pass tests
4. Verify all tests pass
5. Check coverage meets 80%+ threshold
```

## Swift Testing Framework

For this iOS project, use Swift Testing:

```swift
import Testing

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

### Running Tests
```bash
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## TDD with Thinking Keywords

Combine TDD with appropriate thinking depth:

```
Think hard about the test cases needed for UserAuth module, considering:
- Happy path scenarios
- Error conditions
- Edge cases
- Boundary values

Then write failing tests first following TDD workflow.
```

## Benefits of TDD with Claude

1. **Clear specifications**: Tests define exactly what's expected
2. **Reduced hallucination**: Concrete test cases ground implementation
3. **Easy verification**: Run tests to confirm correctness
4. **Safe refactoring**: Tests catch regressions
5. **Documentation**: Tests show intended usage

See also:
- `claude-code-mastery.md` for overall workflow
- `thinking-keywords.md` for reasoning depth
