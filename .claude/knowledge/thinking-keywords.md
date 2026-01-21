# Thinking Keywords Reference

Control Claude's reasoning depth using thinking keywords. Higher depth means more thorough analysis but uses more context.

## Available Keywords

| Keyword | Depth | Token Budget | When to Use |
|---------|-------|--------------|-------------|
| think | Standard | Default | Simple tasks, quick decisions |
| think hard | Increased | Higher | Complex logic, multi-step problems |
| think harder | More | Higher still | Architectural decisions |
| **ultrathink** | Maximum | ~31,999 tokens | Critical decisions, high-risk changes |

## Usage Examples

### Standard Thinking
```
Think about how to add a loading state to this component.
```
For straightforward tasks with clear solutions.

### Increased Depth
```
Think hard about the error handling approach for this API integration.
```
For tasks requiring consideration of multiple factors.

### Maximum Depth
```
Ultrathink about the database schema changes required for multi-tenancy.
```
For critical architectural decisions with significant consequences.

## Risk-Based Mapping (This Project)

The intelligent planning system automatically maps thinking keywords to risk levels:

| Risk Level | Thinking Keyword | Use When |
|------------|------------------|----------|
| Low | Think about | Documentation, simple fixes, config |
| Medium | Think hard about | Feature implementation, refactoring |
| High | Ultrathink about | Architecture changes, migrations |
| Critical | Ultrathink about | Security changes, data model changes |

### In Generated Prompts

Step prompts include the appropriate keyword based on assessed risk:

```markdown
## Reasoning Depth
Think hard about the following aspects before implementation:
1. What are the potential failure modes?
2. What existing patterns should be followed?
3. What tests will verify success?
4. What could go wrong and how to prevent it?
```

### Risk Assessment Factors

Risk level is determined by:
- **Impact scope**: Single file vs. multi-file vs. system-wide
- **Reversibility**: Easy rollback vs. migration required
- **Domain**: UI polish (low) vs. data model (high)
- **Dependencies**: Standalone vs. many dependents
- **Test coverage**: Well-tested vs. untested areas

## Best Practices

### Do Use Thinking Keywords When
- Starting complex implementation steps
- Making architectural decisions
- Debugging subtle issues
- Planning multi-step changes
- Reviewing critical code

### Don't Overuse
- Simple file reads don't need "ultrathink"
- Routine git operations
- Formatting or linting fixes
- Clear, single-purpose tasks

### Combine with Planning
Use thinking keywords during Phase 2 (Plan) of the workflow:
```
Think hard about the implementation approach and write a plan.md
documenting:
1. Files to modify
2. Order of changes
3. Testing strategy
4. Potential risks
```

## Integration with TDD

For test-driven steps, pair thinking keywords with TDD workflow:
```
Think hard about the test cases needed for UserAuth, then write
failing tests first following TDD workflow.
```

See `tdd-patterns.md` for the complete TDD workflow.

See also:
- `claude-code-mastery.md` for overall workflow
- `context-management.md` for managing token usage
