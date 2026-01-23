# Plan Prompts Command

You are generating optimized AI prompts for each step in an implementation plan. These prompts will enable an AI agent to implement each step with high quality and self-correction capability.

## Input
Plan identifier: $ARGUMENTS

## Process

### Step 1: Locate the Plan
Find the plan directory:
```bash
ls -d .claude/plans/$ARGUMENTS* 2>/dev/null | head -1
```

If not found, list available plans and ask user to specify.

### Step 2: Read Plan Context
Read these files to understand the plan:
1. `{plan-dir}/plan.md` - Overall plan
2. `{plan-dir}/adr.md` - Architectural decisions
3. `{plan-dir}/progress.json` - Current state
4. `{plan-dir}/steps/*.md` - All step files

### Step 3: Create Prompts Directory
```bash
mkdir -p {plan-dir}/prompts
```

### Step 4: Generate Prompt for Each Step
For each step file in `{plan-dir}/steps/`, create a corresponding prompt file in `{plan-dir}/prompts/`.

#### Step 4.1: Determine Thinking Keyword for Each Step

For each step, determine the appropriate reasoning depth by reading from progress.json:

1. **Read risk level** from progress.json:
   ```bash
   risk_level=$(cat {plan-dir}/progress.json | jq -r ".steps[{step-index}].riskLevel")
   ```

2. **Map to thinking keyword**:
   | Risk Level | Thinking Keyword | When to Use |
   |------------|------------------|-------------|
   | low | Think about | Routine tasks, documentation |
   | medium | Think hard about | Standard complexity, some risk |
   | high | Ultrathink about | Critical code, complex decisions |
   | critical | Ultrathink about | Maximum reasoning required |

3. **Default handling**:
   - If riskLevel is null/missing: use "Think hard about"
   - If riskLevel is unknown: use "Think hard about"
   - Handle case insensitively: "Low", "LOW", "low" all map to "Think about"

#### Step 4.2: Replace Thinking Keyword Placeholder

When generating each prompt from the template, replace `{THINKING_KEYWORD}` with the mapped keyword:

**Example transformation**:
- Step with riskLevel="low" → "Think about"
- Step with riskLevel="medium" → "Think hard about"
- Step with riskLevel="high" → "Ultrathink about"

**Important**: Replace ALL instances of `{THINKING_KEYWORD}` in the prompt.

**Verification**: After replacement, grep for `{THINKING_KEYWORD}` should return no matches.

Use this optimized prompt template:

```markdown
# Prompt: Step {N} - {Step Name}

## Mission
{One clear sentence describing what to accomplish}

## Reasoning Depth
{THINKING_KEYWORD} the following aspects before implementation:
1. What are the potential failure modes?
2. What existing patterns should be followed?
3. What tests will verify success?
4. What could go wrong and how to prevent it?

## Context
You are implementing step {N} of {total} in the "{Plan Name}" plan.

**Plan Summary**: {Brief description of overall plan}

**This Step**: {Why this step matters and what it enables}

**Dependencies**:
- Requires: {Previous steps that must be complete}
- Enables: {Steps that depend on this one}

## Pre-Implementation Checklist
Before writing any code, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `{path}` | {reason} | Lines {X-Y}: {what to look for} |

### 2. Verify Prerequisites
```bash
# Check that required files/services exist
{verification commands}
```

### 3. Understand Current State
Read the plan context:
```bash
cat {plan-dir}/context.md
cat {plan-dir}/progress.json | jq '.context'
```

## Specification

### Goal
{Detailed description of what to build}

### Requirements
{Numbered list of specific requirements}

### Code Structure
```
{Expected file/code structure}
```

### API/Interface (if applicable)
```javascript
// Expected interface
{interface definition}
```

## Implementation Guide

### TDD Approach (Mandatory for Code Steps)
**The robots LOVE TDD.** Follow this workflow:

1. **Write failing tests first**: Define expected behavior in tests
2. **Confirm tests fail**: Verify tests fail for the right reason
3. **Commit the tests**: Lock in the specification
4. **Implement to pass**: Write minimum code to pass
5. **Refactor**: Clean up while tests stay green
6. **Commit implementation**: Separate commit for implementation

**If modifying existing code**:
- Ensure a unit test exists first
- Create one if none exists
- Then modify the function
- Then run tests to verify changes

### Step-by-Step Instructions
1. **{Action 1}**
   - {Detail}
   - {Detail}

2. **{Action 2}**
   - {Detail}
   - {Detail}

### Patterns to Follow
From `{file}` (lines {X-Y}):
```javascript
{code example}
```

Follow this pattern because: {rationale}

### Edge Cases to Handle
- {Edge case 1}: {how to handle}
- {Edge case 2}: {how to handle}

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: {criterion}
  - Verify: `{command}`

- [ ] **AC2**: {criterion}
  - Verify: `{command}`

- [ ] **AC3**: {criterion}
  - Verify: `{command}`

## Verification Protocol

### 1. Syntax Check
```bash
# Verify no syntax errors
{command}
```
Expected: {expected output}

### 2. Unit Test
```bash
# Run relevant tests
{command}
```
Expected: All tests pass

### 3. Integration Check
```bash
# Verify integration with existing code
{command}
```
Expected: {expected behavior}

### 4. Manual Verification
```bash
# Commands to manually test
{command}
```
Check that: {what to verify}

### Dual Review Pattern (High-Risk Steps)
For high-risk or complex steps:

1. **Claude A** implements the code
2. **Fresh context**: Use `/clear` or new terminal
3. **Claude B** reviews the implementation
4. **Address feedback** from review
5. **Final verification** and commit

When to use:
- High-risk steps (data migrations, security code)
- Complex algorithms
- Steps that have failed verification before
- Code that will be difficult to change later

## Error Recovery

### If Syntax Check Fails
1. Read the error message carefully
2. Check for common issues:
   - Missing imports
   - Typos in variable names
   - Unclosed brackets/quotes
3. Fix and re-run

### If Tests Fail
1. Read test output to identify failing test
2. Check if implementation matches spec
3. Verify test expectations are correct
4. Fix implementation or update test if spec changed

### If Integration Fails
1. Check that dependencies are correctly imported
2. Verify interface matches expected contract
3. Check for circular dependencies
4. Review error logs for specific failure

### If Verification Partially Passes
1. Document what works in context.md
2. Note specific failure in progress.json
3. Create minimal fix rather than rewriting
4. Re-run verification after fix

## Context Management
Monitor your context usage during this step:

| Usage | Action |
|-------|--------|
| 50-69% | Work normally |
| 70-84% | Consider `/compact` after this step |
| 85-92% | Use `/compact` before continuing |
| 93%+ | Use `/clear` and resume from context.md |

**If this is a long step**:
- Commit progress frequently
- Update context.md with current state
- Consider "Document and Clear" pattern for fresh context

**Document and Clear Pattern**:
1. Write current progress to context.md
2. Commit all changes
3. Run `/clear`
4. Resume: "Read context.md and continue from where we left off"

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `{plan-dir}/progress.json`:
```json
{
  "steps[{N-1}]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "notes": "{any relevant notes}"
  },
  "currentStep": {N+1},
  "context.filesCreated": [..., "{new files}"],
  "context.filesModified": [..., "{modified files}"]
}
```

### 2. Update Context
Add to `{plan-dir}/context.md`:
```markdown
## Step {N} Complete - {date}

### What Was Done
{Summary of implementation}

### Files Created
- `{path}`: {purpose}

### Files Modified
- `{path}`: {what changed}

### Key Decisions
- {decision}: {rationale}

### Learnings
- {what was learned}
```

### 3. Update Documentation (if required)
{Specific documentation updates for this step}

### 4. Commit Changes
```bash
git add {files}
git commit -m "{commit message template}"
```

### Git Checkpoints
Git is your safety net. The robot REALLLLLY wants to commit - let it.

**Checkpoint Strategy**:
| When | Command | Purpose |
|------|---------|---------|
| Before risky changes | `git add -A && git commit -m "checkpoint: before {description}"` | Safety net |
| After meaningful progress | `git add -A && git commit -m "progress: {what was completed}"` | Track work |
| After AC passes | `git add -A && git commit -m "AC passed: {criterion}"` | Lock in success |
| After step complete | `git add -A && git commit -m "step {N} complete: {name}"` | Mark milestone |

**Commit Message Prefixes**:
| Prefix | Use Case | Example |
|--------|----------|---------|
| `checkpoint:` | Before risky operations | `checkpoint: before refactoring auth` |
| `progress:` | Partial completion | `progress: tests passing, impl next` |
| `feat:` | New feature/functionality | `feat: add user login` |
| `fix:` | Bug fix | `fix: null pointer in auth` |
| `refactor:` | Code restructuring | `refactor: extract auth service` |
| `test:` | Adding tests | `test: add auth unit tests` |
| `docs:` | Documentation changes | `docs: update README` |

Commit frequently - don't batch up large changes.

### Git Recovery Commands
```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Undo last commit, keep changes unstaged
git reset HEAD~1

# Undo last commit, discard changes
git reset --hard HEAD~1

# Restore specific file from last commit
git checkout HEAD -- {file}

# Restore file from specific commit
git checkout {commit} -- {file}
```

### Pre-Commit Verification
Consider pre-commit hooks to catch issues early:
```bash
# Example pre-commit runs:
# - Lint check
# - Type check
# - Unit tests for changed files
```

"The robot REALLLLLY wants to commit" - hooks catch errors before they propagate.

If pre-commit hooks fail:
1. Read the error output
2. Fix the specific issue
3. Stage the fix
4. Retry commit

### Parallel Work with Git Worktrees
For complex plans or when multiple streams of work are needed:

**Creating Worktrees**:
```bash
# Create worktree for a feature branch
git worktree add ../project-feature-auth feature-auth
git worktree add ../project-feature-dashboard feature-dashboard
```

**Parallel Claude Sessions**:
```bash
# Terminal 1
cd ../project-feature-auth && claude

# Terminal 2
cd ../project-feature-dashboard && claude
```

**Use Cases**:
- Frontend and backend development simultaneously
- Complex refactoring alongside feature work
- One Claude writes code while another reviews
- Different plan steps running in parallel

**Cleanup**:
```bash
# List worktrees
git worktree list

# Remove worktree when done
git worktree remove ../project-feature-auth
```

## Do NOT
- Do NOT skip reading required files first
- Do NOT implement beyond this step's scope
- Do NOT ignore failing tests
- Do NOT forget to update progress.json
- Do NOT leave debugging code
- Do NOT skip documentation updates
- Do NOT mark complete until ALL criteria pass

## Quality Checklist
Before marking complete, verify:
- [ ] All acceptance criteria pass
- [ ] Code follows existing patterns
- [ ] No console.log/debug statements left
- [ ] Error handling is appropriate
- [ ] Documentation is updated
- [ ] progress.json is updated
- [ ] context.md is updated
```

### Step 5: Customize Each Prompt
For each step, customize the template with:

1. **Specific file paths** - Use actual paths from the codebase
2. **Line numbers** - Reference specific lines in existing files
3. **Code examples** - Include relevant patterns from the codebase
4. **Exact commands** - Copy-pasteable verification commands
5. **Real acceptance criteria** - From the step definition

### Step 6: Update progress.json
Mark prompts as generated:
```json
{
  "steps[N].promptGenerated": true
}
```

### Step 7: Output Summary

```
## Prompts Generated for Plan {NNN}

**Plan**: {Plan Name}
**Prompts Created**: {N} prompts in .claude/plans/{NNN}-{slug}/prompts/

### Prompt Files
| Step | File | Risk | Thinking Keyword |
|------|------|------|------------------|
| 1 | 01-{name}.prompt.md | low | Think about |
| 2 | 02-{name}.prompt.md | medium | Think hard about |
| 3 | 03-{name}.prompt.md | high | Ultrathink about |
| ... | ... | ... | ... |

### Next Command
`/plan-next {NNN}` - Start implementing step 1

### Manual Usage
To run a specific step manually:
1. Open `.claude/plans/{NNN}-{slug}/prompts/{NN}-{name}.prompt.md`
2. Copy the entire content
3. Paste to a new Claude Code session
```

## Prompt Quality Standards

### Context Completeness
Every prompt must be executable with ZERO prior context:
- All file paths must be absolute or clearly relative to project root
- All code patterns must be included inline
- All commands must be copy-pasteable
- No references to "previous discussion"

### Verification Rigor
Every acceptance criterion must have:
- Clear pass/fail definition
- Specific command to verify
- Expected output described

### Self-Correction Capability
Every prompt must include:
- Common failure modes
- How to diagnose each failure
- How to recover from each failure
- When to escalate vs. retry

### Progress Integration
Every prompt must include:
- How to update progress.json
- How to update context.md
- What to commit
- How to prepare for next step
